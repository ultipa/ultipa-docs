# Graph Type

## Overview

A **graph type** is a reusable schema definition — a list of node types and edge types — that one or more graphs can be instantiated from. Graph types let multiple graphs share the same shape without redeclaring the schema each time.

Graph types are independent objects: dropping a graph type does not affect graphs that were created from it, and conversely.

## Showing Graph Types

Show graph types stored in the database:

```gql
SHOW GRAPH TYPES
```

Each graph type provides the following essential metadata:

| Field | Description |
| -- | -- |
| `name` | The unique name assigned to the graph type. |
| `node_type_count` | Number of node types. |
| `edge_type_count` | Number of edge types. |
| `node_types` | Comma-separated list of node type names. |
| `edge_types` | Comma-separated list of edge type names. |
| `definition` | The type definitions. |
| `bound_graphs` | Graphs that use this graph type. |
| `comment` | The comment of the graph type. |
| `created_at` | Creation time. |
| `updated_at` | Last update time. |

## Creating Graph Types

Create an empty graph type that schema can be added to later:

```gql
CREATE GRAPH TYPE socialType
```

Create a graph type with an inline specification:

```gql
CREATE GRAPH TYPE gType {
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE FOLLOWS ()-[{createdOn TIMESTAMP}]->(),
  EDGE JOINS ()-[]->()
}
```

### Using IF NOT EXISTS, OR REPLACE

You can use the `IF NOT EXISTS` clause to prevent errors when attempting to create a graph type that already exists. It allows the statement to be safely executed.

```gql
CREATE GRAPH TYPE IF NOT EXISTS socialType
```

Use `OR REPLACE` to drop the existing graph type with the same name and create a new one in its place:

```gql
CREATE OR REPLACE GRAPH TYPE socialType {
  NODE Person ({name STRING, email STRING})
}
```

### Copying or Inferring a Graph Type

Create a graph type that is a copy of another **graph type**:

```gql
CREATE GRAPH TYPE communityType AS COPY OF socialType
```

Create a graph type by inferring the schema from an existing **graph** (the right-hand side is a graph name, not a graph type name). The system reads the labels and properties present in the graph and produces a matching type:

```gql
CREATE GRAPH TYPE inferredType LIKE myGraph
```

When `myGraph` is an **open graph**, the inferred type captures only what has actually been inserted — labels seen, and the union of property names and types observed for each label.

## Altering Graph Types

Add a node or edge type to an existing graph type. The body uses the same node/edge body syntax as `CREATE GRAPH TYPE`:

```gql
ALTER GRAPH TYPE socialType ADD NODE Organization ({name STRING})
```

```gql
ALTER GRAPH TYPE socialType ADD EDGE WorksAt (:Person)-[{since DATE}]->(:Organization)
```

Drop a node or edge type from a graph type:

```gql
ALTER GRAPH TYPE socialType DROP NODE Organization
```

```gql
ALTER GRAPH TYPE socialType DROP EDGE IF EXISTS WorksAt
```

`IF EXISTS` is only accepted with the explicit `TYPE` keyword. The short form `DROP NODE name` / `DROP EDGE name` does not accept `IF EXISTS`.

Rename a graph type:

```gql
ALTER GRAPH TYPE socialType RENAME TO communityType
```

Set a comment on a graph type:

```gql
ALTER GRAPH TYPE communityType COMMENT 'Schema for social-network graphs'
```

## Dropping Graph Types

Drop the graph type `socialType`:

```gql
DROP GRAPH TYPE socialType
```

The `IF EXISTS` clause is used to prevent errors when attempting to delete a graph type that does not exist. It allows the statement to be safely executed.

```gql
DROP GRAPH TYPE IF EXISTS socialType
```

Dropping a graph type does not affect graphs that were already instantiated from it.

## Instantiating a Closed Graph

Create a graph that conforms to a named graph type. New inserts on the graph are validated against the type's schema. Four equivalent syntactic forms are accepted:

```gql
-- Bare reference
CREATE GRAPH community socialType

-- `::` separator
CREATE GRAPH community :: socialType

-- `TYPED` keyword
CREATE GRAPH community TYPED socialType

-- `TYPED BY` keyword
CREATE GRAPH community TYPED BY socialType
```

The instantiatized graph is a **closed graph**: inserts must conform to one of the node or edge types defined by the referenced graph type.

> The link between a closed graph and its graph type is established only at instantiation time — the schema is copied from the type into the graph. After that, the two are independent: subsequent `ALTER GRAPH TYPE` changes do not propagate to graphs already created from it, and the bound graph can independently `ALTER GRAPH ... ADD/DROP NODE/EDGE` to evolve its own schema without affecting the type.
