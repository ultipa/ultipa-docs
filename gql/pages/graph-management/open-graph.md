# Open Graph

## Overview

The **open graph** is schema-free, requiring no explicit schema definitions before data insertion. You can directly insert nodes and edges into the graph, and their labels and properties are created on the fly. This offers maximum flexibility for early-stage data exploration.

In an open graph:

- Each node or edge can have zero, one, or multiple labels.
- Each node or edge has its own set of properties — no pre-definition required.
- Labels support **boolean expressions** in queries (AND, OR, NOT, wildcard).
- Labels can be **added and removed** dynamically after entity creation.

> Each graph can only be typed or open. The mode cannot be changed after creation.

## Creating Open Graph

To create an open graph `g1`:

```gql
CREATE GRAPH g1 ANY
```

The `ANY` keyword identifies an open graph.

## Modifying Labels

### Adding Labels

```gql
MATCH (n:Person {_id: 'p1'}) SET n:VIP
MATCH (n {_id: 'p1'}) SET n:Experienced, n:Veteran
```

Adding labels to edges:

```gql
MATCH ()-[r {note: 'test'}]->() SET r:NEW_TYPE
```

### Removing Labels

```gql
MATCH (n {_id: 'p3'}) REMOVE n:Employee
MATCH (n {_id: 'p4'}) REMOVE n:Person, n:Manager
```

Removing labels from edges:

```gql
MATCH ()-[r {since: 2021}]->() REMOVE r:WORKS_WITH
```

- Removing a non-existent label is silently ignored.
- Adding a label that already exists is idempotent.

## Label DDL

### Showing Labels

To show labels in the current graph:

```gql
SHOW LABELS
```

To show node labels in the current graph:

```gql
SHOW NODE LABEL
```

To show edge labels in the current graph:

```gql
SHOW EDGE LABEL
```

Each label provides the following essential metadata:

| <div table-width="17">Field</div> | Description |
| -- | -- |
| `label_name` | The name of the label. |
| `label_id` | The ID of the label. |

### Creating Label

You can create new labels within an open graph.

To create a node label `User` within the current graph:

```gql
CREATE NODE LABEL User
```

To create an edge label `Transfers` within the current graph:

```gql
CREATE EDGE LABEL Transfers
```

### Dropping Label

You can delete labels from a graph. Deleting a label will not remove the nodes or edges that use it.

To drop the node label `Person` from the current graph:

```gql
DROP NODE LABEL Person
```

To drop the edge label `LINKS` from the current graph:

```gql
DROP EDGE LABEL LINKS
```

## Dynamic Properties

In an open graph, properties are fully dynamic:

```gql
INSERT (:Person {_id: 'p1', name: 'Alice', age: 30, hobbies: 'reading', score: 95.5})
INSERT (:Person {_id: 'p2', name: 'Bob', department: 'IT'})
```

Different entities can have different property sets. Use `property_exists()` to check for a property:

```gql
MATCH (n {_id: 'p1'}) RETURN property_exists(n, name)
```

## Limitations

- Schema DDL operations are not supported in open graphs (`ALTER GRAPH ... ADD/DROP NODE/EDGE`, `ALTER NODE/EDGE ... ADD/DROP/RENAME PROPERTY`, `CREATE INDEX`, `CREATE FULLTEXT`, `CREATE TRIGGER`).
- RPC batch import (`insertNodesBatchBySchema` / `insertEdgesBatchBySchema`) is not available for open graphs.
- The mode cannot be switched after the graph is created.
- Property types are inferred at write time. The same property name may have different types across different entities.
