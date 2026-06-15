# Monitoring

Three `SHOW COMPUTE` statements report runtime state and configured settings. All accept either the current graph or a named graph.

## SHOW COMPUTE STATUS

Reports the live runtime state of the computing engine of the current graph:

```gql
SHOW COMPUTE STATUS
```

Returns a `(property, value)` row set:

| Property | Type | Notes |
| -- | -- | -- |
| `graph` | string | Graph name. Always present. |
| `enabled` | boolean | Whether compute is enabled. Always present. |
| `syncMode` | string | `SYNC` or `ASYNC`. Always present. |
| `available` | boolean | `true` once the topology snapshot is ready for queries. Poll this to detect build completion. Always present. |
| `nodeCount` | integer | Nodes currently in the cache. Always present (`0` if not built yet). |
| `edgeCount` | integer | Edges currently in the cache. Always present (`0` if not built yet). |
| `topologyMemory` | string | Formatted bytes used by the topology cache. Always present. |
| `propertyMemory` | string | Formatted bytes used by the property cache. Always present. |
| `totalMemory` | string | Sum of topology + property memory. Always present. |
| `buildState` | string | Current build lifecycle state (e.g., `NONE`, `BUILDING`, `READY`). Always present. |
| `topologyVersion` | integer | Snapshot version, incremented on every rebuild. Present after first build. |
| `memoryLimit` | string | Configured cap. Present only when set. |
| `topologyLimit` | string | Configured cap. Present only when set. |
| `propertyLimit` | string | Configured cap. Present only when set. |
| `buildInProgress` | boolean | Present only when a build is running. |
| `buildProgress` | float | Present only when `buildInProgress=true`; range `0.0`–`1.0`. |
| `buildDuration` | string | Present once a build has finished, e.g. `2.5s`. |
| `buildError` | string | Present only when the last build failed. |

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
