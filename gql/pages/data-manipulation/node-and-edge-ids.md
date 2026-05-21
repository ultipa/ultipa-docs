# Node and Edge IDs

In a graph, both nodes and edges have the built-in unique identifier `_id`.

## Node IDs

Each edge has a unique identifier `_id`:

| Property | Value Type | Description |
| -- | -- | -- |
| `_id` | `STRING` | Value can be either system-generated (UUID v4) or manually assigned during insertion. Once assigned, a node's `_id` is immutable. |

## Edge IDs

Each edge has a unique identifier `_id` and two endpoint references.

| Property | Value Type | Description |
| -- | -- | -- |
| `_id` | `STRING` | If the graph's `EDGE_ID` is enabled, value can be either system-generated (UUID v4) or manually assigned during insertion.<br><br> If the graph's `EDGE_ID` is disabled, value is only system-generated (in the `e:<N>` form, where `<N>` is the internal numeric ID, such as `e:1`) during insertion, custom values cannot be assigned. <br><br>Once assigned, a edge's `_id` is immutable while the graph remains in its current `EDGE_ID` status.<br><br>See below for details. |
| `_from` | `STRING` | The `_id` of the source node. |
| `_to` | `STRING` | The `_id` of the destination node. |

### EDGE_ID on Graph Creation

The `EDGE_ID` is enabled by default at graph creation:

```gql
-- EDGE_ID is enabled by default
CREATE GRAPH myGraph

-- WITH EDGE_ID is also accepted but is a no-op since enabled is the default
CREATE GRAPH myGraph WITH EDGE_ID
```

The `EDGE_ID` can be disabled at graph creation:

```gql
CREATE GRAPH myGraph WITH EDGE_ID DISABLED
```

### Toggling EDGE_ID

You can disable `EDGE_ID` on an existing graph at any time:

```gql
ALTER GRAPH myGraph SET EDGE_ID DISABLED
```

After disabling `EDGE_ID` on a graph, the hidden edge `_id` index is dropped and the in-memory cache is cleared. 

Disabling `EDGE_ID` does not immediately erase the UUID v4 `_id` values already stored on existing edges. Each edge retains its originally assigned `_id` until it is rewritten by `SET` on one of its properties, at which point the `_id` reverts to the system-assigned `e:<N>` form.

Enable `EDGE_ID` on an existing graph:

```gql
ALTER GRAPH myGraph SET EDGE_ID ENABLED
```

After enabling `EDGE_ID` on a graph, a background converter assigns UUIDs to legacy edges and the system auto-creates a hidden `_id` index for edges; progress can be inspected with `SHOW EDGE_ID STATUS`.

### Checking EDGE_ID Status

Inspect `EDGE_ID` status of the current graph:

```gql
SHOW EDGE_ID STATUS
```

The result includes the following fields:

| Field | Description |
| -- | -- |
| `graph` | The graph name. |
| `status` | The current `EDGE_ID` state, one of `DISABLED`, `ENABLING`, `ENABLED`, or `DISABLING`. |
| `progress` | Number of edges processed by the background converter. |
| `total` | Total number of edges to process. |
| `percent` | Conversion completion percentage. |
| `skipped` | Number of edges the converter passed over without rewriting: decode errors, deleted edges (tombstones), or edges whose `_id` was already a valid UUID and present in the cache. |
| `started_at` | When the current conversion started. |

The `ENABLING` and `DISABLING` states appear only while a background converter is running. On a steady-state graph, `status` is either `ENABLED` or `DISABLED`, and the progress columns reflect the most recent transition (or zeros if no transition has ever run).

### Inserting with Edge ID

When `EDGE_ID` is enabled, an `_id` can be supplied explicitly or omitted:

```gql
-- Explicit _id (requires EDGE_ID enabled)
MATCH (a {_id: 'a'}), (b {_id: 'b'})
INSERT (a)-[:Knows {_id: 'tx-12345'}]->(b)

-- Auto-generated UUID v4 _id (when _id is omitted)
MATCH (a {_id: 'a'}), (b {_id: 'b'})
INSERT (a)-[:Knows]->(b)
```

When `EDGE_ID` is disabled, providing `_id` in an `INSERT` on an edge is rejected:

```gql
ALTER GRAPH myGraph SET EDGE_ID DISABLED

-- Auto-generated _id in the e:<N> form (when _id is omitted)
MATCH (a {_id: 'a'}), (b {_id: 'b'})
INSERT (a)-[:Knows]->(b)
```

### Matching by Edge ID

Matching an edge by `_id`, whether via `WHERE e._id = 'X'` or the inline form `[e {_id: 'X'}]`, **requires `EDGE_ID` to be enabled** on the graph. When `EDGE_ID` is disabled, GQLDB blocks `_id`-based edge lookups.

```gql
-- Edge _id lookup (requires EDGE_ID enabled)
MATCH ()-[e WHERE e._id = 'tx-12345']->() RETURN e
```

Reading `_id` (e.g., `RETURN e._id`) always works regardless of the `EDGE_ID` status.

## Why Edge ID is a Toggle but Node ID is Not

A node and an edge with `EDGE_ID` enabled both support fast O(1) `_id` lookup, but for different reasons.

**Nodes** are stored directly by their `_id`, so looking up `MATCH (n {_id: 'U1'})` goes straight to the right node, no extra structure is needed.

**Edges** are stored by where they connect (source, label, destination), not by `_id`. So to look an edge up by `_id`, the database has to maintain a separate hidden index that maps each `_id` back to its edge. That hidden index — plus an in-memory cache that makes it fast — is exactly what the `EDGE_ID` feature provides.

| | Nodes | Edges (`EDGE_ID` on) |
|---|---|---|
| How they're stored | Indexed by `_id` | Indexed by their endpoints |
| `_id` lookup | Direct, always available | Goes through the `EDGE_ID` hidden index + cache |
| Extra disk / memory cost | None | The hidden index on disk, plus a per-edge cache entry in memory |

That's why nodes don't have an `EDGE_ID`-style switch: their `_id` lookup costs nothing extra. Edges only have the option because the hidden index and cache are real overhead — turning `EDGE_ID` off gives that overhead back, in exchange for losing `_id`-based edge lookup.

## When to Disable EDGE_ID

Although enabled by default, you may want to disable `EDGE_ID` to skip its overhead in workloads that never need to address an edge by `_id`:

- **Memory.** Each enabled edge keeps a ~50-byte entry in the in-memory edge `_id` cache. At scale this is significant: 100M edges ≈ 5 GB, 1B edges ≈ 50 GB.
- **Storage.** A hidden `_id` property index is maintained on disk while `EDGE_ID` is enabled. Disabling drops the index entirely.
- **Write throughput.** Every edge insert / overwrite must generate (or accept) a UUID, perform a uniqueness check in the cache, and update the hidden index. Bulk-load and ETL pipelines are measurably faster with `EDGE_ID` off.
- **Workload doesn't need it.** Pure topology workloads — graph algorithms (PageRank, centrality, community detection), k-hop traversal, recommendation engines — walk the graph through endpoints and labels and never address individual edges by `_id`.
- **Backward compatibility.** Pre-existing schemas, drivers, or queries written before `EDGE_ID` may rely on the no-`_id` edge model. Disabling keeps that behavior.
