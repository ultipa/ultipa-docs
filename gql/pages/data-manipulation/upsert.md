# UPSERT

## Overview

The `UPSERT` statement allows you to update nodes and edges in the graph. If no existing node or edge with the same `_id` is found, it inserts a new one instead.

When the data already exists, `UPSERT` performs a per-entity **merge**:

| Aspect | Behavior on a matching `_id` |
| -- | -- |
| Properties | The supplied properties **update** existing values; properties not in the write are **preserved**. |
| Labels (nodes) | The supplied labels are **unioned** with the existing label set. |
| Label (edges) | The supplied label **replaces** the existing one. |
| Edge Endpoints | Can **move** an edge to different endpoints. |

`UPSERT` is useful in import or sync workflows where the same script may be re-run: existing rows get refreshed properties without manual existence checks, and unaffected fields stay intact. To wholesale-replace an entity (and remove unlisted properties or labels), use <a target="_blank" href="/docs/gql/insert-overwrite">`INSERT OVERWRITE`</a> instead.

## Upserting Nodes

A node will be updated if `_id` is supplied and that `_id` already exists on a node in the graph. Otherwise, a new node will be inserted.

```gql
-- Insert node with _id as U1
INSERT (:User {_id: "U1", name: "Jumpy88", age: 34})

-- Upsert node U1
-- Node U1 becomes (:User&Employee {_id: "U1", name: "mochaeach", age: 34, level: 1})
UPSERT (:Employee {_id: "U1", name: "mochaeach", level: 1})

-- Upsert node U2
-- No such node _id exists, a new node is inserted
UPSERT (:User {_id: "U2", name: "rowlock"})

-- Upsert with _id omitted, a new node is inserted with system-generated _id
UPSERT (:User {name: "Brainy"})
```

## Upserting Edges

Upserting edges keys on the edge's `_id` and therefore requires `EDGE_ID` to be enabled on the graph. `EDGE_ID` is enabled by default on newly created graphs; on a graph created with `EDGE_ID` disabled (or toggled off later), `UPSERT` on an edge is rejected. See <a target="_blank" href="/docs/gql/node-and-edge-ids">Node and Edge IDs</a>.

When `EDGE_ID` is enabled, an edge will be updated if `_id` is supplied and that `_id` already exists on an edge in the graph. Otherwise, a new edge will be inserted.

```gql
-- Insert edge with _id as f-123
MATCH (u1 {_id: 'U1'}), (u2 {_id: 'U2'})
INSERT (u1)-[:FOLLOWS {_id: 'f-123', year: 2026, score: 2}]->(u2)

-- Upsert edge f-123
-- Edge f-123 becomes (u1)-[:LIKES {_id: 'f-123', year: 2026, score: 1, weight: 3}]->(u2)
MATCH (u1 {_id: 'U1'}), (u2 {_id: 'U2'})
UPSERT (u1)-[:LIKES {_id: 'f-123', score: 1, weight: 3}]->(u2)

-- Upsert edge f-123 with different destination node
-- Edge f-123 becomes (u1)-[:LIKES {_id: 'f-123', year: 2025, score: 1, weight: 3}]->(u3)
MATCH (u1 {_id: 'U1'})
UPSERT (u1)-[:LIKES {_id: 'f-123', year: 2025}]->(u3:User {_id: 'U3'})

-- Upsert with _id omitted, a new edge is inserted with system-generated UUID v4 _id
MATCH (u1 {_id: 'U1'}), (u2 {_id: 'U2'})
UPSERT (u1)-[:FOLLOWS {year: 2026}]->(u2)
```