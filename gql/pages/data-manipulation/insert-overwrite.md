# INSERT OVERWRITE

## Overview

The `INSERT OVERWRITE` statement allows you to overwrite nodes and edges in the graph. If no existing node or edge with the same `_id` is found, it inserts a new one instead.

When the data already exists, `INSERT OVERWRITE` performs a wholesale **replace**:

| Aspect | Behavior on a matching `_id` |
| -- | -- |
| Properties | The supplied properties **replace** the entire property set; properties not in the write are **dropped**. |
| Labels (nodes) | The supplied label set **replaces** the existing one. |
| Label (edge) | The supplied label **replaces** the existing one. |
| Edge Endpoints | Can **move** an edge to different endpoints. |

Use `INSERT OVERWRITE` when the input is the complete authoritative state for that `_id`. To merge new fields into an existing entity (preserving anything not in the write), use <a target="_blank" href="/docs/gql/upsert">`UPSERT`</a> instead.

## Overwriting Nodes

A node will be overwritten if `_id` is supplied and that `_id` already exists on a node in the graph. Otherwise, a new node will be inserted.

```gql
-- Insert node with _id as U1
INSERT (:User {_id: "U1", name: "Jumpy88", age: 34})

-- Insert/Overwrite node U1
-- Node U1 becomes (:Employee {_id: "U1", name: "mochaeach", level: 1})
INSERT OVERWRITE (:Employee {_id: "U1", name: "mochaeach", level: 1})

-- Insert/Overwrite node U2
-- No such node _id exists, a new node is inserted
INSERT OVERWRITE (:User {_id: "U2", name: "rowlock"})

-- Insert/Overwrite with _id omitted, a new node is inserted with system-generated _id
INSERT OVERWRITE (:User {name: "Brainy"})
```

## Overwriting Edges

Upserting edges keys on the edge's `_id` and therefore requires `EDGE_ID` to be enabled on the graph. On a graph with `EDGE_ID` disabled, `INSERT OVERWRITE` on an edge is rejected with an error. See <a target="_blank" href="/docs/gql/graphs-with-edge-id">Graphs with Edge ID</a>.

When `EDGE_ID` is enabled, an edge will be overwritten if `_id` is supplied and that `_id` already exists on an edge in the graph. Otherwise, a new edge will be inserted.

```gql
-- Enable EDGE_ID on myGraph
ALTER GRAPH myGraph SET EDGE_ID ENABLED

-- Insert edge with _id as f-123
MATCH (u1 {_id: 'U1'}), (u2 {_id: 'U2'})
INSERT (u1)-[:FOLLOWS {_id: 'f-123', year: 2026, score: 2}]->(u2)

-- Insert/Overwrite edge f-123
-- Edge f-123 becomes (u1)-[:LIKES {_id: 'f-123', score: 1, weight: 3}]->(u2)
MATCH (u1 {_id: 'U1'}), (u2 {_id: 'U2'})
INSERT OVERWRITE (u1)-[:LIKES {_id: 'f-123', score: 1, weight: 3}]->(u2)

-- Insert/Overwrite edge f-123 with different destination node
-- Edge f-123 becomes (u1)-[:LIKES {_id: 'f-123', year: 2025}]->(u3)
MATCH (u1 {_id: 'U1'})
INSERT OVERWRITE (u1)-[:LIKES {_id: 'f-123', year: 2025}]->(u3:User {_id: 'U3'})

-- Insert/Overwrite with _id omitted, a new edge is inserted with system-generated UUID v4 _id
MATCH (u1 {_id: 'U1'}), (u2 {_id: 'U2'})
INSERT OVERWRITE (u1)-[:FOLLOWS {year: 2026}]->(u2)
```