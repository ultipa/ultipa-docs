# Monitoring

Three `SHOW COMPUTE` statements report runtime state and configured settings. `SHOW COMPUTE STATUS` and `SHOW COMPUTE CONFIG` default to the current graph and accept `ON GRAPH <name>` to target another. `SHOW COMPUTE GRAPHS` is a global listing — no per-graph form.

## SHOW COMPUTE STATUS

Reports the live runtime state of the computing engine.

```gql
-- Current graph, compact form
SHOW COMPUTE STATUS

-- Named graph
SHOW COMPUTE STATUS ON GRAPH social

-- Per-component memory breakdown + planner stats
SHOW COMPUTE STATUS ALL
SHOW COMPUTE STATUS ALL ON GRAPH social
```

The basic form returns a compact `(property, value)` row set. Append `ALL` to add a per-component memory breakdown and planner statistics — this is an `O(N)` pass intended for operator debugging, not routine polling.

**Identity & live cache**

| Property | Type | Notes |
| -- | -- | -- |
| `graph` | string | Graph name. Always present. |
| `enabled` | boolean | Whether compute is enabled. Always present. |
| `syncMode` | string | `SYNC` or `ASYNC`. Always present. |
| `available` | boolean | `true` once the topology snapshot is ready for queries. Poll this to detect build completion. Always present. |
| `nodeCount` | integer | Nodes currently in the cache. During a build, falls back to the in-flight build's estimate when the snapshot is not yet published. Always present (`0` if neither is available). |
| `edgeCount` | integer | Edges currently in the cache. Same fallback rule as `nodeCount`. |
| `topologyMemory` | string | Formatted bytes used by the topology cache. Always present. |
| `propertyMemory` | string | Formatted bytes used by the property cache. Always present. |
| `totalMemory` | string | Sum of topology + property memory. Always present. |
| `topologyVersion` | integer | Snapshot version, incremented on every rebuild. Present after first build. |

**Sync / delta diagnostics** (`ASYNC` mode signals; surfaced for wedge debugging)

| Property | Type | Notes |
| -- | -- | -- |
| `syncQueueDepth` | integer | Current pending writes in the sync queue. Always present (`0` is meaningful as a baseline). |
| `syncQueueCapacity` | integer | Configured queue capacity. Present only when configured. |
| `syncFallbacks` | integer | Times the engine fell back to a slow path because the queue was saturated. Present only when `> 0`. |
| `syncErrors` | integer | Apply errors counted since process start. Present only when `> 0`. |
| `lastApplyMs` | integer | Latency of the most recent delta apply, in ms. Present only when `> 0`. |
| `maxApplyMsLast1m` | integer | Maximum apply latency in the last minute, in ms. Present only when `> 0`. |
| `deltaSize` | integer | Bytes of un-compacted delta. Always present. |
| `deltaPendingCompact` | boolean | `true` when a delta compaction is queued. Present only when `true`. |
| `lastBuildEndedAt` | integer | Unix timestamp of the last completed build. Present only when set. |

**Process-level memory**

| Property | Type | Notes |
| -- | -- | -- |
| `nodeIdCacheMemory` | string | Always-resident `_id` → internal-id map. Counts against the heap but not against `topologyMemory` / `propertyMemory`. Present when `> 0`. |
| `goMemLimit` | string | Effective `GOMEMLIMIT` (`unlimited (GOMEMLIMIT not set)` when unset). The Go runtime's soft memory cap — the actual ceiling on a build, regardless of physical RAM. Always present. |
| `goMemInUse` | string | Bytes the Go runtime has mapped and not released. Tracks against `goMemLimit`. Always present. |
| `heapInUse` | string | `runtime.MemStats.HeapInuse` — the in-use heap. Always present. |
| `memLimitUsedPct` | float | `goMemInUse / goMemLimit * 100`. Present only when `goMemLimit` is finite and `> 0`. Watch for `> ~90` — the Go GC starts spending most of its time collecting beyond that. |

**Configured limits** (mirrored from `SHOW COMPUTE CONFIG`)

| Property | Type | Notes |
| -- | -- | -- |
| `memoryLimit` | string | Configured total-memory cap. Present only when set. |
| `topologyLimit` | string | Configured topology cap. Present only when set. |
| `propertyLimit` | string | Configured property cap. Present only when set. |

**Build lifecycle**

| Property | Type | Notes |
| -- | -- | -- |
| `buildState` | string | Current build lifecycle state (e.g. `NONE`, `BUILDING`, `READY`). Always present. |
| `buildInProgress` | boolean | Present only when a build is running. |
| `buildProgress` | float | Present only when `buildInProgress=true`; range `0.0`–`1.0`. |
| `nodesLoaded` | integer | Nodes scanned so far in the in-flight build. Present only during build. |
| `edgesLoaded` | integer | Edges scanned so far in the in-flight build. Present only during build. |
| `secsSinceProgress` | integer | Seconds since the build last advanced. Present only during build, only when `>= 30`. A growing value flags a wedge as distinct from a slow build. |
| `buildDuration` | string | Wall-clock duration of the last build (e.g. `2.5s`). Present once a build has finished. |
| `buildError` | string | Error message of the last failed build. Present only when the last build failed. |

> `available=true` while `buildInProgress=true` is normal: in concurrent mode the topology publishes for queries before the property cache finishes loading.

### `ALL`: per-component breakdown

Adding `ALL` appends extra rows after the regular output:

| Property | Type | Notes |
| -- | -- | -- |
| `memoryBreakdown` | string | Header row: `per-component (topology rows sum to topologyMemory; property rows measured live)`. Present when any component reports memory. |
| `<topology component>` | string | One row per topology component, formatted bytes. Rows sum to `topologyMemory`. |
| `<property component>` | string | One row per property component, formatted bytes. Measured live from the cache structures, so the sum may differ slightly from `propertyMemory` — that difference is itself a signal. |
| `plannerStatsDegreeKeys` | integer | Number of degree-distribution keys held by the planner. Present only on engines that derive planner stats. |
| `plannerStatsDeriveMs` | integer | Wall-clock cost of the last planner-stats derivation, in ms. Same availability rule. |
| `plannerStatsTopologyVersion` | integer | Topology version the planner stats were derived against. Same availability rule. |

If the compute manager is not available for the graph, the result is a three-row table — `graph`, `enabled=false`, and a `status` message — instead of the full output.

## SHOW COMPUTE CONFIG

Reports the **persisted** configuration (not live state) of the current graph. Useful for verifying a setup before enabling, or after a restart.

```gql
SHOW COMPUTE CONFIG
```

Rows returned:

| Property | Value | Notes |
| -- | -- | -- |
| `graph` | Graph name. | Always present. |
| `enabled` | `true` / `false`. | Always present. |
| `syncMode` | `SYNC` or `ASYNC`. | Present once any `SET COMPUTE` statement has been issued for the graph. |
| `memoryLimit` | Formatted bytes, or `unlimited` when not set. | Same as above. |
| `topologyLimit` | Formatted bytes, or `unlimited` when not set. | Same as above. |
| `propertyLimit` | Formatted bytes, or `unlimited` when not set. | Same as above. |
| `configVersion` | Integer; bumped on every config change. | Same as above. |
| `nodePropertyCache` | Formatted spec string, e.g. `:Person(name, age), :Company(*)`, or `(none)` when nothing is cached. | Same as above. |
| `edgePropertyCache` | Same shape, for edge labels. | Same as above. |

For a graph that has never been touched with any `SET COMPUTE` statement, only `graph` and `enabled=false` are returned — there is no compute config to report yet.

## SHOW COMPUTE GRAPHS

Tabular listing of all graphs in the database with compute enabled. Disabled graphs are omitted.

```gql
SHOW COMPUTE GRAPHS
```

| Column | Type | Meaning |
| -- | -- | -- |
| `graph` | string | Graph name. |
| `enabled` | boolean | Always `true` (disabled graphs are filtered out). |
| `available` | boolean | `true` once the cache is ready. |
| `nodes` | integer | Nodes in the cache. |
| `edges` | integer | Edges in the cache. |
| `memory` | string | Formatted bytes (topology + property). |

Use this to audit which graphs are paying memory cost for the cache, and to find candidates for `ALTER GRAPH ... SET COMPUTE DISABLED` if their workload no longer benefits.
