# MERGE

## Overview

The `MERGE` statement matches a pattern in the graph; if the pattern is not found, it creates the missing nodes and edges. Optional `ON MATCH SET` and `ON CREATE SET` sub-clauses let you apply different property updates depending on whether the entity already existed or was newly created.

`MERGE` differs from <a target="_blank" href="/docs/gql/insert-overwrite">`INSERT OVERWRITE`</a> and <a target="_blank" href="/docs/gql/upsert">`UPSERT`</a> in matching mode: `INSERT OVERWRITE` and `UPSERT` key on `_id` only, while `MERGE` matches on the full pattern including labels and property values.

<p tit="Syntax"></p>

```
<merge statement> ::=
  "MERGE" <graph pattern>
  [ "ON CREATE SET" <set item list> ]
  [ "ON MATCH SET" <set item list> ]
```

**Details**

- `MERGE` examines the pattern as a whole. If every node and edge in the pattern can be bound, the existing match is used; otherwise the missing pieces are created.
- `ON CREATE SET` runs only on rows where the pattern was newly created.
- `ON MATCH SET` runs once per row produced by an existing match.
- Both `ON MATCH SET` and `ON CREATE SET` are optional and may appear in either order.

## Merging Nodes

Match a `Person` named `Alice`; create one if it does not exist:

```gql
MERGE (p:Person {name: 'Alice'})
RETURN p
```

If no such node exists, a `Person` node named `Alice` is created. If one exists, it is bound to `p` and returned without modification.

### ON CREATE SET

Set additional properties only when the node is newly created:

```gql
MERGE (p:Person {email: 'alice@example.com'})
ON CREATE SET p.name = 'Alice', p.createdAt = date()
RETURN p
```

A new `Person` carries `email`, `name`, and `createdAt`. An existing `Person` is returned unchanged.

### ON MATCH SET

Set properties only when the pattern matched an existing entity:

```gql
MERGE (p:Person {email: 'alice@example.com'})
ON MATCH SET p.lastSeen = date()
RETURN p
```

A new `Person` carries `email` only. An existing `Person` is added with `lastSeen`.

### Combining ON CREATE SET and ON MATCH SET

Differentiate the two paths in a single statement:

```gql
MERGE (p:Person {email: 'alice@example.com'})
ON CREATE SET p.name = 'Alice', p.visits = 1
ON MATCH SET p.visits = p.visits + 1
RETURN p
```

Each invocation creates the row on first call and increments `visits` on every subsequent call.

## Merging Edges

Use `MATCH` to bind the endpoints, then `MERGE` the edge:

```gql
MATCH (a:Person {name: 'Alice'}), (b:Person {name: 'Bob'})
MERGE (a)-[r:Knows]->(b)
ON CREATE SET r.since = 2024
ON MATCH SET r.interactions = r.interactions + 1
RETURN r
```

If a `Knows` edge already runs from `Alice` to `Bob`, its `interactions` counter is incremented; otherwise a new edge is created with `since = 2024`.

> **Edge `_id` in `MERGE`**: `MERGE` matches edges by pattern (label, endpoints, properties), not by `_id`, so it works on both `EDGE_ID`-enabled and disabled graphs. However, if you supply `_id` inside the edge property map (e.g., `MERGE (a)-[r:Knows {_id: 'tx-123'}]->(b)`), the graph must have `EDGE_ID` enabled, otherwise the `_id` write is rejected. See <a target="_blank" href="/docs/gql/graphs-with-edge-id">Graphs with Edge ID</a>.

## Merging Whole Patterns

`MERGE` matches the pattern as a whole. If the entire pattern is found, no changes are made. If it is not, the **whole pattern is created**, including elements that exist elsewhere in the graph.

```gql
MERGE (:Person {name: 'Alice'})-[:Knows]->(:Person {name: 'Bob'})
```

For example, if `Alice` already exists but `Bob` does not exist, the path as a whole does not match. `MERGE` then creates a new `Alice` node, a `Bob` node, and the `Knows` edge between them, leaving the graph with **two `Alice` nodes**.

**Tip:** To avoid creating duplicate endpoints, split the pattern into separate `MERGE` statements — one per element. Each `MERGE` binds its variable to a single node, so the third `MERGE` only has the edge left to look for:

```gql
MERGE (a:Person {name: 'Alice'})
MERGE (b:Person {name: 'Bob1'})
MERGE (a)-[:Knows]->(b)
```

For the example case where `Alice` exists and `Bob` does not, this produces 1 new node (`Bob`) and 1 new edge, no duplicate `Alice`.
