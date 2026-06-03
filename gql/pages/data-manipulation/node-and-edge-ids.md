# Node and Edge IDs

Every node and edge in a graph carries two built-in identifiers:

- **`_id`**: the **user-facing** identifier. A string you can assign yourself or let the system generate. Nodes always have it; edges have it only when the per-graph edge `_id` toggle is enabled. Use `_id` for application data models and any identifier you want to control or reference from outside the database.
- **`_uuid`**: the **system-internal** identifier. A decimal-string-encoded `uint64` automatically assigned by the engine. Always populated for every node and edge, regardless of the edge `_id` toggle. Use `_uuid` (or its function form `internal_id()`) when you need an identifier that's guaranteed to resolve, especially for edges in edge `_id` disabled graphs.

## Node _id

Each node has a unique identifier `_id`:

| Property | Value Type | Description |
| -- | -- | -- |
| `_id` | `STRING` | Value can be either system-generated (UUID v4) or manually assigned during insertion. Once assigned, a node's `_id` is immutable. |

## Edge _id

Each edge has a unique identifier `_id` and two endpoint references.

| Property | Value Type | Description |
| -- | -- | -- |
| `_id` | `STRING` | If the graph's edge `_id` is enabled, value can be either system-generated (UUID v4) or manually assigned during insertion.<br><br> If the graph's edge `_id` is disabled, value is only system-generated (in the `e:<N>` form, where `<N>` is the internal numeric ID, such as `e:1`) during insertion, custom values cannot be assigned. <br><br>Once assigned, a edge's `_id` is immutable while the graph remains in its current edge `_id` status.<br><br>See below for details. |
| `_from` | `STRING` | The `_id` of the source node. |
| `_to` | `STRING` | The `_id` of the destination node. |

### Edge _id on Graph Creation

The edge `_id` is enabled by default at graph creation:

```gql
-- Edge _id is enabled by default
CREATE GRAPH myGraph

-- WITH EDGE_ID is accepted but is a no-op since enabled is the default
CREATE GRAPH myGraph WITH EDGE_ID
```

The edge `_id` can be disabled at graph creation:

```gql
CREATE GRAPH myGraph WITH EDGE_ID DISABLED
```

### Toggling Edge `_id`

You can disable edge `_id` on an existing graph at any time:

```gql
ALTER GRAPH myGraph SET EDGE_ID DISABLED
```

After disabling edge `_id` on a graph, the hidden edge `_id` index is dropped and the in-memory cache is cleared. 

Disabling edge `_id` does not immediately erase the UUID v4 `_id` values already stored on existing edges. Each edge retains its originally assigned `_id` until it is rewritten by `SET` on one of its properties, at which point the `_id` reverts to the system-assigned `e:<N>` form.

Enable edge `_id` on an existing graph:

```gql
ALTER GRAPH myGraph SET EDGE_ID ENABLED
```

After enabling edge `_id` on a graph, a background converter assigns UUIDs to legacy edges and the system auto-creates a hidden `_id` index for edges; progress can be inspected with `SHOW EDGE_ID STATUS`.

### Checking Edge `_id` Status

Inspect edge `_id` status of the current graph:

```gql
SHOW EDGE_ID STATUS
```

The result includes the following fields:

| Field | Description |
| -- | -- |
| `graph` | The graph name. |
| `status` | The current edge `_id` state, one of `DISABLED`, `ENABLING`, `ENABLED`, or `DISABLING`. |
| `progress` | Number of edges processed by the background converter. |
| `total` | Total number of edges to process. |
| `percent` | Conversion completion percentage. |
| `skipped` | Number of edges the converter passed over without rewriting: decode errors, deleted edges (tombstones), or edges whose `_id` was already a valid UUID and present in the cache. |
| `started_at` | When the current conversion started. |

The `ENABLING` and `DISABLING` states appear only while a background converter is running. On a steady-state graph, `status` is either `ENABLED` or `DISABLED`, and the progress columns reflect the most recent transition (or zeros if no transition has ever run).

### Inserting with Edge _id

When edge `_id` is enabled, an `_id` can be supplied explicitly or omitted:

```gql
-- Explicit _id (requires edge _id enabled)
MATCH (a {_id: 'a'}), (b {_id: 'b'})
INSERT (a)-[:Knows {_id: 'tx-12345'}]->(b)

-- Auto-generated UUID v4 _id (when _id is omitted)
MATCH (a {_id: 'a'}), (b {_id: 'b'})
INSERT (a)-[:Knows]->(b)
```

When edge `_id` is disabled, providing `_id` in an `INSERT` on an edge is rejected:

```gql
ALTER GRAPH myGraph SET EDGE_ID DISABLED

-- Auto-generated _id in the e:<N> form (when _id is omitted)
MATCH (a {_id: 'a'}), (b {_id: 'b'})
INSERT (a)-[:Knows]->(b)
```

### Matching by Edge _id

Matching an edge by `_id`, whether via `WHERE e._id = 'X'` or the inline form `[e {_id: 'X'}]`, **requires edge `_id` to be enabled** on the graph. When edge `_id` is disabled, GQLDB blocks `_id`-based edge lookups.

```gql
-- Edge _id lookup (requires edge _id enabled)
MATCH ()-[e WHERE e._id = 'tx-12345']->() RETURN e
```

Reading `_id` (e.g., `RETURN e._id`) always works regardless of the edge `_id` status.

## Why Edge _id is a Toggle but Node _id is Not

A node and an edge with edge `_id` enabled both support fast O(1) `_id` lookup, but for different reasons.

**Nodes** are stored directly by their `_id`, so looking up `MATCH (n {_id: 'U1'})` goes straight to the right node, no extra structure is needed.

**Edges** are stored by where they connect (source, label, destination), not by `_id`. So to look an edge up by `_id`, the database has to maintain a separate hidden index that maps each `_id` back to its edge. That hidden index — plus an in-memory cache that makes it fast — is exactly what the edge `_id` feature provides.

| | Nodes | Edges (edge `_id` on) |
|---|---|---|
| How they're stored | Indexed by `_id` | Indexed by their endpoints |
| `_id` lookup | Direct, always available | Goes through the edge `_id` hidden index + cache |
| Extra disk / memory cost | None | The hidden index on disk, plus a per-edge cache entry in memory |

That's why nodes don't have an edge-`_id`-style switch: their `_id` lookup costs nothing extra. Edges only have the option because the hidden index and cache are real overhead — turning edge `_id` off gives that overhead back, in exchange for losing `_id`-based edge lookup.

## When to Disable Edge _id

Although enabled by default, you may want to disable edge `_id` to skip its overhead in workloads that never need to address an edge by `_id`:

- **Memory.** Each enabled edge keeps a ~50-byte entry in the in-memory edge `_id` cache. At scale this is significant: 100M edges ≈ 5 GB, 1B edges ≈ 50 GB.
- **Storage.** A hidden `_id` property index is maintained on disk while edge `_id` is enabled. Disabling drops the index entirely.
- **Write throughput.** Every edge insert / overwrite must generate (or accept) a UUID, perform a uniqueness check in the cache, and update the hidden index. Bulk-load and ETL pipelines are measurably faster with edge `_id` off.
- **Workload doesn't need it.** Pure topology workloads — graph algorithms (PageRank, centrality, community detection), k-hop traversal, recommendation engines — walk the graph through endpoints and labels and never address individual edges by `_id`.
- **Backward compatibility.** Pre-existing schemas, drivers, or queries written before edge `_id` may rely on the no-`_id` edge model. Disabling keeps that behavior.

## Internal ID (_uuid)

Every node and edge also carries a **system-internal numeric identifier** exposed as the `_uuid` property and the `internal_id()` function. Unlike `_id`, the internal ID is **always available**, including for edges in an edge `_id` disabled graph.

| Property | Value Type | Description |
| -- | -- | -- |
| `_uuid` | `STRING` | The system-assigned `uint64` identifier, formatted as a decimal string (returned as a string because the value can exceed the signed-64-bit range). Always populated and immutable. |

Both forms return the same value:

```gql
-- Property-form access
MATCH (n)-[e]->()
RETURN n._uuid, e._uuid

-- Function-form access (works on any expression, including computed elements)
MATCH (n)-[e]->()
RETURN internal_id(n), internal_id(e)
```

### Matching by `_uuid`

You **can** filter by `_uuid`, but only via the `WHERE` clause, and the lookup is a **full scan** (there is no `_uuid` index).

```gql
MATCH (n) WHERE n._uuid = '12345' RETURN n
MATCH ()-[e WHERE e._uuid = '67890']->() RETURN e
```

So `_uuid` is best thought of as a **stable identifier you can always read and emit**, not a **fast lookup key**. If your workflow is "return a `_uuid` from one query, then `MATCH` an entity by that `_uuid` later," it works through the `WHERE` clause but pays a scan cost. Prefer `_id` when you need fast lookup-by-handle round trips.

## When to use which

| Need | Use |
| -- | -- |
| Stable user-facing identifier you control (custom strings, UUIDs you assigned) | `_id` |
| Identifier that always resolves, even when edge `_id` is disabled | `_uuid` |
| Identifier for debugging, logging, or cross-system correlation | `_uuid` — guaranteed unique within the graph and never null |
| Node/Edge fast lookup | `_id` (edges require edge `_id` enabled) |

The `_uuid` is **not** a substitute for `_id` in user-facing data models. It exists primarily so the database always has a guaranteed-unique handle for every element, regardless of feature toggles. Treat it as an operational / diagnostic identifier rather than a stable application key - bulk restore, edge `_id` toggle, and similar operations may renumber `_uuid`s.
