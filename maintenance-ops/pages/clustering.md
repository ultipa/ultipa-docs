# Clustering

Operating a GQLDB HA cluster, including observing topology, draining a node for maintenance, adding or removing voters, and recovering from quorum loss. Cluster bring-up (number of nodes, peer lists, witness placement) is covered in <a href="/docs/maintenance-ops/deployment-topologies" target="_blank">Deployment Topologies</a>; this page is about what to do once the cluster is up.

> HA is a paid feature. A Community / Free Tier server refuses to start in HA mode. Confirm your license entitles HA by checking `db.license()`, the `edition` should be `Licensed` and the license payload must include HA membership.

## Roles & Terminology

| Term | Meaning |
| -- | -- |
| **Voter** | A Raft member that contributes to quorum. Both data nodes and the witness are voters. A 3-node cluster has 3 voters; a 2-data + 1-witness cluster has 3 voters (2 data + 1 witness). |
| **Learner** | A node that receives the log but does not vote. Used as a transient state while a new node catches up before promotion. |
| **Leader** | The single voter accepting writes at any given moment. Reads in v1.0 also route to the leader; v1.1 introduces opt-in follower reads. |
| **Follower** | Any voter that is not the current leader. Applies the committed log; serves no client traffic in v1.0. |
| **Witness** | A lightweight companion service holding the Raft log without an FSM or graph data. Counts toward quorum like any other voter. |
| **Term** | Raft monotonic counter, incremented on every leader election. Used to detect stale messages. |
| **Applied index** | The highest log entry index applied to the local LSM. Followers trail the leader by some number of entries. |

## Inspecting Cluster State

```gql
SHOW HA STATUS
```

Returns one row per voter. Columns:

| Column | Meaning |
| -- | -- |
| `node_id` | Stable identity of the voter (set via `-ha-id` at startup). |
| `endpoint` | Voter's `host:port`. |
| `role` | `leader`, `follower`, `learner`, or `witness`. |
| `reachable` | `true` if the local node has heard from this peer recently. |
| `lag_bytes` | Bytes of committed log this voter has yet to apply. `0` for the leader, ~0 for a healthy follower. |
| `applied_idx` | The voter's local applied log index. |
| `term` | Current Raft term as seen by the local node. |

A healthy cluster: every row `reachable = true`, `lag_bytes` small and stable, one and only one `role = leader`.

For deeper introspection:

```gql
SHOW HA LOG TAIL
SHOW HA LOG TAIL LIMIT 100
```

The last N committed Raft entries. Each row carries an `index`, `term`, and `kind` — typically `MUTATION` (a graph write), `SST_INGEST` (a snapshot delivery), or `MEMBERSHIP` (a voter add / remove). Useful to confirm that membership changes you initiated actually committed and to inspect the throughput shape.

```gql
SHOW HA SNAPSHOTS
```

Per-replica snapshot inventory: `snapshot_id`, `taken_at`, `size`, `sst_count`, `retained_until`. Snapshots are how a new joining node catches up before tailing the log.

### gRPC Direct Access

If you can't or don't want to open a GQL session for monitoring (e.g., from a load balancer health check), the same data is exposed on the `HAService` gRPC and on the standard `HealthService.Check`:

| RPC | Returns |
| -- | -- |
| `HAService.GetStatus` | `HAStatus { enabled, ha_id, leader_endpoint, voters[], raft_term, raft_applied_idx }`. |
| `HAService.GetReplicationLag` | `LagInfo` — per-follower lag in bytes and log entries. |
| `HealthService.Check` | Standard gRPC health probe; extended in HA mode with `role`, `lag_bytes`, and `compute_ready` in the response metadata. Compatible with existing health-check tooling. |

The HA-specific fields also surface on `LoginResponse`. A driver discovers the leader by inspecting `LoginResponse.ha_status` after `Login()` — there is no separate "find the leader" round trip.

## Planned Failover (Maintenance)

To take the current leader offline cleanly — for an OS patch, a config change, a hardware swap — make it step down first so the cluster fails over on your schedule, not on a connection timeout:

```
HAService.StepDown
```

The leader gives up its role and triggers an immediate election. A follower wins (usually within a few hundred ms), the old leader becomes a follower, you stop it gracefully, do your maintenance, and start it back up. New writes briefly retry with `LEADER_CHANGED`; transactions open against the deposed leader abort with `TransactionAborted{Reason: "leader_changed"}` and must be retried by the caller.

There is no GQL surface for `StepDown` — invoke the gRPC directly from your ops tooling, or use the manager UI's HA page.

## Adding a Node

Raft requires membership changes to happen one voter at a time. To grow a 2-data + witness cluster into a 3-data cluster, or to replace a permanently failed node:

1. **Provision** a new host with the GQLDB binary and the same license file. Do **not** pre-seed `-db` — the node will receive the data via snapshot.
2. **Start** the new node in HA mode with the existing cluster's peer list.
3. **Issue** `HAService.Join` against any current voter, supplying the new node's endpoint as the join target.
4. The joining node enters **learner** mode — it receives the Raft log but doesn't vote.
5. The leader transfers the latest snapshot (SSTs + metadata) over a side channel. The learner restores it into its local LSM.
6. Once the learner has caught up the log tail, the coordinator emits a Raft configuration-change entry promoting it to voter. The membership change commits like any other entry.
7. If you are growing from 2 data + witness to 3 data, follow with `HAService.RemoveNode` against the witness — again, one change at a time.

`Join` enforces the license: the joining node's hardware fingerprint must be in the license's `voter_fingerprints[]` and the HA expiry must be in the future. Re-imaging a host with the same fingerprint is fine; bringing in a foreign host is rejected with a clear error.

## Removing a Node

```
HAService.RemoveNode { node_id: "follower-2" }
```

Emits a Raft configuration-change entry. The cluster commits it through the normal quorum path and stops sending log to the removed node. The removed process is **not** killed — you stop it manually after the configuration commits.

Removing the current leader is not allowed; call `StepDown` first, then `RemoveNode` against the former leader after it has demoted.

## Glass-Break: ForceFailover

If quorum is permanently lost — e.g., two of three nodes are physically destroyed — the cluster correctly stalls. There is one escape hatch:

```
HAService.ForceFailover
```

This promotes the surviving node into a single-node cluster. **Any committed entries that didn't reach the survivor are lost.** The RPC requires explicit operator confirmation and is logged at WARN with the survivor's applied index for forensics.

After `ForceFailover`, the single survivor accepts writes immediately. Bring new hardware online and use `HAService.Join` to grow back to a 3-voter cluster — same procedure as adding any other voter.

Only use this when you've truly lost quorum. If the other peers are merely unreachable (network partition), forcing failover risks split-brain when they come back.

## Routing & Driver Behavior

In v1.0 the leader is the only node serving client traffic:

- **Writes** must hit the leader. A write to a follower returns `LEADER_CHANGED` with the current leader's endpoint in the error metadata; drivers update their cached leader and retry transparently.
- **Reads** also route to the leader in v1.0. Follower reads with a staleness tolerance are scheduled for v1.1.
- **Sessions** are server-local in v1.0. When a driver fails over to a new leader, it re-issues `Login()` against the new leader using cached credentials. The session token is replaced transparently — the application keeps the same connection object. v1.1 will replicate session-table mutations through Raft for transparent failover.
- **Open transactions** survive a leader change only if no statement has yet been sent. Once `BEGIN` has been routed somewhere, a deposed leader aborts the transaction with `TransactionAborted{Reason: "leader_changed"}`. The application — not the driver — decides whether and how to retry.

## Disk-Full on a Follower

A follower that runs out of disk stops applying new entries and falls behind. The leader keeps streaming until it gives up; eventually the follower is marked unreachable.

Recovery:

1. **Reclaim disk** on the follower (clean up old snapshots, extend the volume).
2. **Restart** the GQLDB process; it resumes log apply from its last applied index.
3. If the leader has already retired the relevant log entries, the follower falls back to **snapshot-and-tail** automatically.

No operator action is needed in the cluster; the recovering follower rejoins quorum once caught up. The cluster keeps serving traffic from the remaining quorum throughout.

## When Not to Use HA

HA protects against **host or rack failure within the quorum**. It does **not** protect against:

| Threat | Why HA doesn't help | What does |
| -- | -- | -- |
| Accidental `TRUNCATE` or destructive query | Replication propagates the destructive change to every follower. | <a href="/docs/maintenance-ops/backup-restore" target="_blank">Backup & Restore</a> — restore from the most recent backup. |
| Logical data corruption (bad app code, schema mistake) | Same — every follower has the bad data. | Backups + integrity tooling (`db.validate_graph()`). |
| Data center loss | All voters likely in one DC in v1.0. | Off-site copies of backups; wait for v1.x multi-region. |
| Operator error in HA admin | E.g., `ForceFailover` on a network partition rather than true quorum loss. | Documented procedures, audit logging on HA RPCs, manager UI confirmations. |

Run backups even with a 3-node cluster.

## Licensing

HA licenses bind to a **fingerprint set with a `max_voters` cap** rather than per-instance fingerprints. You can re-image any voter without invalidating the license, as long as the total voter count stays within the cap. The Community / Free Tier does not entitle HA — startup with `-ha-mode` against a community-tier server fails with a clear error and the process exits.
