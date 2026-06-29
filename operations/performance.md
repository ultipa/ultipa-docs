# Performance

This page catalogs the performance levers GQLDB exposes — what they do, when to reach for them, and where the full reference lives. Treat it as a starting index: most rows link to the canonical page for that lever.

## Diagnose Execution Plan

Before changing settings, find out where the time is actually going. GQLDB gives you two complementary tools:

| Tool | What it tells you | Reference |
| -- | -- | -- |
| `EXPLAIN <query>` | Estimated cost, planned operators, estimated row counts. No execution. | <a href="/docs/gql/execution-plan" target="_blank">Execution Plan</a> |
| `PROFILE <query>` | Same as EXPLAIN plus actual per-operator row counts and elapsed time after running the query. | <a href="/docs/gql/execution-plan" target="_blank">Execution Plan</a> |

A profile reading is worth more than any guess about what's slow. If the plan picks a full scan where you expected an index hit, the fix is upstream (add the index, fix the predicate). If the plan looks right but a single operator dominates the time, the fix is at that operator (cardinality, memory, parallelism).

## Indexes

The single largest lever for read latency. GQLDB supports three index families:

| Index | What it accelerates | Reference |
| -- | -- | -- |
| **Property index** | Equality and range predicates on node / edge properties, anywhere a `MATCH` filters by a non-key property. | <a href="/docs/gql/index" target="_blank">Index</a> |
| **Full-text index** | `CONTAINS` / phrase search on string properties, with tokenizer-aware matching. | <a href="/docs/gql/fulltext-index" target="_blank">Full-text Index</a> |
| **Vector index** | Approximate-nearest-neighbor search over dense vector properties: embeddings, image features, etc. | <a href="/docs/ai-and-vectors/vector-index" target="_blank">Vector Index</a> |

If a query scans the whole graph but only returns a handful of rows, you almost certainly want an index. Confirm with `EXPLAIN` before and after to see the operator change.

## Computing Engine

For graph algorithms — PageRank, shortest path, community detection, embeddings — the compute engine builds an in-memory topology representation that is orders of magnitude faster than executing the same logic through the row-oriented GQL pipeline.

| Lever | What it does | Reference |
| -- | -- | -- |
| `ALTER GRAPH <graphName> SET COMPUTE ENABLED` | Enables the compute engine for a graph; builds the topology cache on first algorithm call. | <a href="/docs/computing-engine" target="_blank">Computing Engine</a> |
| Cached properties | Promote frequently accessed properties into the compute cache so algorithms read them without a round trip to LSM. | <a href="/docs/computing-engine" target="_blank">Computing Engine</a> |
| Topology build state | Inspect whether the topology cache is ready, building, or stale. | <a href="/docs/computing-engine" target="_blank">Computing Engine</a> |

Rule of thumb: if a query runs `CALL algo.*`, it needs the compute engine. If it's pure pattern matching, it doesn't.

## Edge ID

Edge `_id` is a per-graph toggle that controls whether edges carry a fast `_id` lookup path. When enabled (the default), each edge gets a UUID-style `_id`, backed by a hidden on-disk index and an in-memory cache; you can match an edge by `_id` in O(1) and assign custom `_id` values at insertion. When disabled, the index and cache go away, edges fall back to system-assigned `e:<N>` identifiers, and `_id`-based edge lookups are rejected.

The lookup is real overhead: roughly **50 bytes per edge** in the in-memory cache (≈5 GB for 100M edges, ≈50 GB for 1B), plus the hidden index on disk and a uniqueness check on every write. Turn it off when the workload never addresses edges by `_id` — typically pure-topology workloads (graph algorithms, k-hop traversal, recommendation engines) and bulk ETL pipelines where insert throughput matters more than per-edge addressability. Nodes don't have an equivalent switch because node `_id` lookup is free (nodes are stored by their `_id` directly).

Toggling on a populated graph runs a background converter that walks every edge; inspect progress with `SHOW EDGE_ID STATUS`. See <a href="/docs/gql/node-and-edge-ids" target="_blank">Node and Edge IDs</a> for the syntax, toggle states, and what happens to existing `_id` values after a transition.

## Memory & Cache Sizing

The right memory settings depend on graph size and access pattern. The flags below are all set at startup; see <a href="/docs/operations/database-installation#important-flags" target="_blank">Database Installation → Important Flags</a> for the full table.

| Flag | What it controls | When to tune |
| -- | -- | -- |
| `-cache-size` | In-memory read cache (4 KB pages). Default `10000` ≈ 40 MB. | Raise for read-heavy workloads on graphs that don't fit in OS page cache. Lower on small instances to free RAM for other consumers. |
| `-mem-limit-bytes` | Soft memory ceiling for the process. `0` = auto from cgroup, `-1` = disabled. | Set explicitly when running alongside other heavy processes on the same host. |
| `-max-msg-size` | Per-message gRPC limit (both directions). | Raise if large `INSERT` payloads or large `RETURN` result sets fail with `ResourceExhausted`. |

## Durability vs Write Throughput

WAL fsync policy is the single biggest write-side knob:

| `-wal-sync-mode` | Behavior | Tradeoff |
| -- | -- | -- |
| `0` None | No fsync; memtable only. | Highest throughput, whole memtable lost on crash. |
| `1` Batch | Group-commit fsync. | Strong throughput, group-commit window lost on crash. |
| `2` Every | fsync on every commit. | Zero data loss, lowest throughput. |
| `3` Async (default) | Background fsync; ~100 ms write-loss window. | Balanced — what most workloads should keep. |

Set via `-wal-sync-mode` at startup or in `-config`. Don't pick `0` for any data you care about — it's a benchmark mode, not a production setting.

## Statistics Freshness

The planner uses `db.stats()` outputs to pick operators. Stale statistics produce stale plans.

| Lever | What it does | Reference |
| -- | -- | -- |
| `db.stats()` | Inspect current statistics: `nodeCount`, `edgeCount`, per-label property frequency. | <a href="/docs/operations/database-info#statistics" target="_blank">Database Info → Statistics</a> |
| `db.reload_stats()` | Force a full rebuild from a fresh scan. O(N + E). | <a href="/docs/operations/database-info#rebuilding-statistics" target="_blank">Database Info → Rebuilding Statistics</a> |

Run `db.reload_stats()` after a bulk import, a restore, or whenever `db.stats()` reports `statsReady = false`. Don't run it on a hot path — it's a maintenance operation.

## Storage Hardware

Disk-bound workloads benefit more from hardware than from any flag:

- **NVMe SSD ≫ SATA SSD ≫ spinning disk.** LSM compaction is read-modify-write heavy; latency-per-IOP wins over raw bandwidth.
- **Local storage > network storage** for write-heavy workloads. EBS `gp3` / `io2` are acceptable for moderate workloads; instance-store NVMe wins for write-heavy.
- **Size = 3× raw graph data.** Headroom for LSM compaction working set + WAL + backups. See <a href="/docs/operations/database-installation#system-requirements" target="_blank">Database Installation → System Requirements</a>.

## HA Read Routing

On HA topologies, v1.0 routes all reads to the leader — no read scale-out. v1.1 introduces opt-in **follower reads** with a driver-side staleness tolerance: reads can route to a follower if the follower's lag is within the configured window. See <a href="/docs/operations/clustering#routing--driver-behavior" target="_blank">Clustering → Routing & Driver Behavior</a>.

For pure read scale today, the path is **vertical** (bigger leader instance) or **app-side caching** in front of the database, not horizontal across followers.

## Bulk Import

Imports are usually faster as a series of large transactions than as one giant transaction or many tiny ones. The two main paths:

| Path | Best for | Reference |
| -- | -- | -- |
| `LOAD CSV` | Files already on disk on the server. Supports dump form and inline import. | <a href="/docs/gql/load-csv" target="_blank">LOAD CSV</a> |
| Driver batched `INSERT` | Data arriving from the application side. Pack 1k–10k entities per transaction. | <a href="/docs/drivers" target="_blank">Ultipa Drivers</a> |

Before a bulk import: disable indexes you'll rebuild after, optionally lower `-wal-sync-mode` to `1` (Batch) for the import window, and run `db.reload_stats()` once the import completes so the planner sees current data.