# Deployment Topologies

GQLDB supports three deployment shapes:

- Single-node
- 3-node HA
- 2-data + 1 witness HA

All three run the same server distribution; HA mode is enabled with a single flag and a peer list. There is no separate "cluster edition" of the database.

## Topology Overview

| Topology | Replicas | Tolerated loss | Quorum | Use case |
| -- | -- | -- | -- | -- |
| **Single-node** | 1 data | None | n/a | Development, evaluation, batch workloads where the host is the unit of recovery (offline backup is the redundancy story). |
| **3-node HA** | 3 full data | 1 of 3 | 2/3 | Production. Most read capacity. Three full-spec boxes. |
| **2-data + 1 witness** | 2 full data + 1 witness | 1 of 3 | 2/3 | Production at near-2-node cost. The witness is a lightweight companion service (~50 MB RSS) that holds the Raft log only, no FSM, no graph data. |

Both HA topologies provide **zero data loss inside the quorum** and **automatic sub-second failover**. The Raft safety guarantee is identical between them — the witness counts toward the quorum exactly like a third data replica would.

> **Why not pure 2-node primary-standby?** A 2-node design without a third vote can't do automatic failover safely without external fencing (STONITH). It pushes split-brain risk onto operators and produces a "looks like HA, isn't HA" deployment in practice. If you can't afford even a witness, run a single node and rely on backups — that's an honest, well-defined recovery path.

## Single-Node

The simplest deployment. GQLDB runs as a standalone database service with file-system-backed LSM storage in the configured `-db` directory. WAL durability is configurable; the default `SyncAsync` mode has a ~100 ms write-loss window on hard crash.

```bash
./ultipa-gqldb-1.x.y-linux-amd64 \
  -db ./my.gdb -admin-pass admin11 -port 60123 \
  -license-file ./your.license -rbac
```

Single-node recovery story:

- **Process crash on healthy disk:** WAL replay restores up to the last fsync; loss bounded by the WAL sync mode (`Every` = 0 loss, `SyncAsync` = ~100 ms, `Batch` = group-commit window, `None` = whole memtable).
- **Host failure / disk failure:** restore from the most recent `db.backup()` or offline snapshot. See <a href="/docs/maintenance-ops/backup-restore" target="_blank">Backup & Restore</a>.

This is appropriate for non-production workloads and for production deployments where the operator explicitly accepts host-level downtime in exchange for simpler operations.

## 3-Node HA

Three identical data replicas running on three hosts. Each holds a full copy of the graph and participates in the Raft consensus group. Writes commit when a quorum (2 of 3) has durably acknowledged. Reads are served by the leader; followers stand by for failover.

```bash
# On each of the three hosts, with appropriate peer list
./ultipa-gqldb-1.x.y-linux-amd64 \
  -db ./my.gdb -admin-pass admin11 -port 60123 \
  -license-file ./your.license -rbac \
  -ha-mode \
  -ha-peers host-a:60124,host-b:60124,host-c:60124 \
  -ha-id host-a
```

Sizing:

- **CPU / memory:** each node is sized identically; plan as 3× a single-node production install.
- **Disk:** 3× the raw data size, plus headroom for LSM compaction and WAL.
- **Network:** low-latency LAN between replicas (sub-millisecond ideal); Raft is sensitive to RTT. The same DC is the default assumption; cross-DC HA is deferred to a later release.

Failure handling:

- **Single node loss:** the remaining two form a quorum; automatic failover completes in under a second. Writes resume immediately on the new leader.
- **Two nodes lost:** quorum is lost; the surviving node serves nothing until at least one peer returns. This is correct behavior — proceeding would risk split-brain.

## 2-Data + 1 Witness

Two full data replicas plus one **witness**. The witness is a separate, lightweight companion service (`ultipa-gqldb-witness`) that participates in Raft elections and durably stores the full Raft log, but does **not** hold the FSM or graph data.

```bash
# Data node A
./ultipa-gqldb-1.x.y-linux-amd64 \
  -db ./my.gdb -admin-pass admin11 -port 60123 \
  -license-file ./your.license -rbac \
  -ha-mode \
  -ha-peers data-a:60124,data-b:60124,witness:60124 \
  -ha-id data-a

# Witness (separate companion service)
./ultipa-gqldb-witness-1.x.y-linux-amd64 \
  -log-dir ./witness-log -port 60124 \
  -ha-peers data-a:60124,data-b:60124,witness:60124 \
  -ha-id witness
```

Why the witness keeps the full Raft log: a witness that votes but doesn't durably store the log is unsafe — a quorum of `{data-a, witness}` could commit entries that exist only in `data-a`'s volatile state. The standard Raft safety contract requires every voting member to durably store the log. The witness honors that.

Sizing:

| Resource | Witness |
| -- | -- |
| CPU / memory | 1 core, 1 GB RAM is plenty (~50 MB RSS typical) |
| Disk | Tens of MB to a few GB depending on write rate and snapshot retention |
| Network | Low-latency LAN to both data nodes |

Where to host the witness:

| Location | Notes |
| -- | -- |
| Shared infra (control-plane VM, ops jump box) | Acceptable for cost-sensitive deployments. Needs network reach to both data nodes; failure of the shared host counts as one of the three permitted single-node failures. |
| Dedicated micro-VM in a third rack / AZ | Required if "rack failure" is in your threat model. A witness in the same rack as one of the data nodes loses you the "tolerates one rack failure" property. |

Failure handling:

- **Loss of the witness alone:** the two data nodes still form a 2/3 quorum; the cluster keeps serving reads and writes normally.
- **Loss of one data node:** the surviving data node plus the witness form quorum. Writes continue; reads continue. Failover completes in under a second.
- **Loss of one data node + the witness:** quorum is lost. The surviving data node is correct but stalled until at least one peer returns.

## Choosing a Topology

<p tit="Decision Tree"></p>

```
Need HA?
  ├── No  →  Single-node, rely on backups
  └── Yes
      ├── Have 3 full-spec hosts in one DC?    →  3-node
      └── Want HA at near-2-node hardware cost? →  2-data + 1 witness
```

Both HA shapes give the same safety guarantee. The choice is cost and read-capacity:

- **Pick 3-node** if you want maximum read throughput (3 hot replicas for follower reads) and don't mind 3× storage and 3 full data processes.
- **Pick 2-data + witness** if you want HA but the third box is hard to justify. You give up the third hot replica for reads; you keep the data-loss guarantee.

## HA Admin Surface

When `-ha-mode` is enabled, additional administration becomes available. The full details belong in <a href="/docs/maintenance-ops/clustering" target="_blank">Clustering</a>; the headline pieces:

- `SHOW HA STATUS` — current leader, follower lag, quorum state.
- `SHOW HA LOG TAIL` — last N Raft log entries.
- `SHOW HA SNAPSHOTS` — snapshot history per replica.
- `HAService` gRPC: `GetStatus`, `Join`, `RemoveNode`, `StepDown`, `ForceFailover`, `GetReplicationLag` for cluster-membership operations and planned failover testing.

## Licensing for HA

HA licenses are scoped to a **fingerprint set with a `max_voters` cap** rather than per-instance fingerprints. This means you can rotate or replace replicas (e.g., re-image a host) without the license rejecting the new node, as long as the total voting members stays under the cap. Single-node licenses remain per-instance.

## What's Out of Scope

The current HA implementation focuses on **survive any single-node failure with no data loss within the quorum**. The following are deferred:

- **Multi-region / cross-DC replication** — deferred to a later release; current HA assumes a single low-latency network.
- **Horizontal sharding / vertex partitioning** — single-graph deployments only; large graphs scale vertically (more CPU / RAM / disk per node).
- **HTAP / OLAP worker tier** — the same nodes serve OLTP and OLAP workloads.

If your workload shape doesn't fit the single-region HA assumption (e.g., active-active across DCs, multi-graph sharding), the current options are: run separate clusters per region with application-level routing, or wait for the multi-region work.
