# Graphs with Edge ID

## Overview

By default, edges receive a system-generated `_id` in the `e:<N>` form (where `<N>` is the internal numeric ID), and custom values cannot be assigned. The `EDGE_ID` feature lets edges carry a user-facing `_id`, either a manually assigned non-empty string (e.g., `'tx-12345'`) or an auto-generated UUID v4 (e.g., `550e8400-e29b-41d4-a716-446655440000`) when `_id` is omitted at insert time.

When `EDGE_ID` is enabled on a graph, edges support:

- Auto-generated UUID v4 if `_id` is not supplied at insert time
- Manual assignment of any non-empty string `_id` at insert time
- O(1) edge lookup by `_id` via an in-memory cache
- Direct read access such as `MATCH ()-[e WHERE e._id = 'tx-12345']->() RETURN e`

`EDGE_ID` is **opt-in per graph** and **disabled by default**. The feature can be enabled at graph creation or toggled on an existing graph at any time.

### Uniqueness

`_id` is unique per graph: inserting two edges with the same `_id` errors.

### Immutability

Once assigned, an edge's `_id` is immutable. Attempts to update `_id` are rejected. 

## Creating Graphs with EDGE_ID Enabled

Use the `WITH EDGE_ID` clause when creating a graph:

```gql
CREATE GRAPH myGraph WITH EDGE_ID
```

## Toggling EDGE_ID for Graphs

Enable `EDGE_ID` on an existing graph. A background converter assigns UUIDs to legacy edges; progress can be inspected with `SHOW EDGE_ID STATUS`.

```gql
ALTER GRAPH myGraph SET EDGE_ID ENABLED
```

Disable `EDGE_ID`. The hidden `_id` index is dropped and the in-memory cache is cleared.

```gql
ALTER GRAPH myGraph SET EDGE_ID DISABLED
```

Disabling `EDGE_ID` does **not** immediately erase the `_id` values already stored on existing edges. Each edge retains its originally assigned `_id` until it is rewritten by a subsequent `SET` on one of its properties, at which point the `_id` reverts to the system-assigned `e:<N>` form. Lookups by `_id` no longer resolve.

## Checking EDGE_ID Status

Inspect the current `EDGE_ID` state of the current graph, including whether the feature is enabled and the progress of any in-flight conversion:

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

## Inserting Edges with ID

When `EDGE_ID` is enabled, an `_id` can be supplied explicitly or omitted (the system then auto-generates a UUID v4):

```gql
-- Explicit _id (must be a non-empty string)
MATCH (a {_id: 'a'}), (b {_id: 'b'})
INSERT (a)-[:Knows {_id: 'tx-12345'}]->(b)

-- Auto-generated UUID v4 (when _id is omitted)
MATCH (a {_id: 'a'}), (b {_id: 'b'})
INSERT (a)-[:Knows]->(b)
```

When `EDGE_ID` is disabled, providing `_id` in an `INSERT` on an edge is rejected.

## Matching Edges by ID

Matching an edge by `_id`, whether via `WHERE e._id = 'X'` or the inline form `[e {_id: 'X'}]`, **requires `EDGE_ID` to be enabled** on the graph. When `EDGE_ID` is disabled, GQLDB blocks `_id`-based edge lookups.

Reading `_id` (e.g., `RETURN e._id`) always works regardless of the `EDGE_ID` setting.

```gql
-- Single lookup (requires EDGE_ID enabled)
MATCH ()-[e WHERE e._id = 'tx-12345']->() RETURN e

-- Batch lookup (requires EDGE_ID enabled)
MATCH ()-[e WHERE e._id IN ['tx-1', 'tx-2', 'tx-3']]->() RETURN e
```