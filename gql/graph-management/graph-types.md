# Graph Types

> **Scope of this page.** This page covers **named graph types**, the catalog objects created via `CREATE GRAPH TYPE`.<br><br>The inline (`CREATE GRAPH <graph> { … }`), `LIKE`, and `AS COPY OF` forms produce closed graphs whose graph type is embedded directly in the graph, they do not create a named graph type. For those, see <a href="/docs/gql/closed-graphs" target="_blank">Closed Graphs</a>.

## Overview

A **graph type** is a **named, reusable schema definition**, including a list of node types and edge types. Named graph types let multiple graphs share the same shape without redeclaring the schema each time.

## Showing Graph Types

Show graph types stored in the database:

```gql
SHOW GRAPH TYPES
```

To inspect a single graph type:

```gql
DESCRIBE GRAPH TYPE socialType

-- DESC is a shorthand for DESCRIBE
DESC GRAPH TYPE socialType
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

You have three ways to create a graph type:

```syntax
<create graph type statement> ::= 
  "CREATE" { "GRAPH TYPE" [ "IF NOT EXISTS" ] | "OR REPLACE GRAPH TYPE" } <graph type name>
  <inline graph type> | <cloned graph type> | <inferred graph type>
```

### Inline Specification

Define the node and edge types directly in the `CREATE GRAPH TYPE` statement.

```syntax
<inline graph type> ::= "{" [ <element type> [ { "," <element type> }... ] ] "}"

<element type> = <node type> | <edge type>
```

Learn more about <a target="_blank" href="/docs/gql/closed-graphs#Node-Types">node types</a> and <a target="_blank" href="/docs/gql/closed-graphs#Edge-Types">edge types</a>.

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

### Cloning a Graph Type

```syntax
<cloned graph type> ::= "AS COPY OF" <graph type name>
```

Create a graph type that is a copy of another **graph type**:

```gql
CREATE GRAPH TYPE socialType AS COPY OF gType
```

### Inferring a Graph Type

```syntax
<inferred graph type> ::= "LIKE" <graph name>
```

Create a graph type by inferring the schema from an existing **graph** (the right-hand side is a graph name, not a graph type name). The system reads the labels and properties present in the graph and produces a matching type:

```gql
CREATE GRAPH TYPE inferredType LIKE myGraph
```

When `myGraph` is an **open graph**, the inferred type captures only what has actually been inserted — labels seen, and the union of property names and types observed for each label.

### Using IF NOT EXISTS

You can use the `IF NOT EXISTS` clause to prevent errors when attempting to create a graph type that already exists. It allows the statement to be safely executed.

```gql
CREATE GRAPH TYPE IF NOT EXISTS socialType {
  NODE Person ({name STRING, email STRING})
}
```

### Using OR REPLACE

You can use `OR REPLACE` to drop the existing graph type with the same name and create a new one in its place:

```gql
CREATE OR REPLACE GRAPH TYPE socialType {
  NODE Person ({name STRING, email STRING})
}
```

## Adding Node/Edge Types

Add node and edge types to a graph type:

```gql
-- Add node type Organization to socialType
ALTER GRAPH TYPE socialType ADD NODE Organization ({name STRING})

-- Add edge type WorksAt to socialType
ALTER GRAPH TYPE socialType ADD EDGE WorksAt (:Person)-[{since DATE}]->(:Organization)
```

## Dropping Node/Edge Types

Drop node and edge types from a graph type:

```gql
-- Drop node type Organization from socialType
ALTER GRAPH TYPE socialType DROP NODE Organization

-- Drop edge type WorksAt from socialType
ALTER GRAPH TYPE socialType DROP EDGE IF EXISTS WorksAt
```

## Renaming Graph Types

Rename `socialType` to `communityType`:

```gql
ALTER GRAPH TYPE socialType RENAME TO communityType
```

## Commenting Graph Types

Set comment for `communityType`:

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

## Bounding to Graphs

Create a graph using a named graph type, see <a target="_blank" href="/docs/gql/closed-graphs">Closed Graphs</a>. Once a graph is bound to a graph type, the binding semantics are strict:

- The binding is immutable for the bound graph's lifetime. You can unbound it, but there is no rebind to switch types.
- Any changes on a graph type propagates automatically to every bound graph. Altering a node or edge type on the named graph type immediately re-shapes the schema of every graph bound to it.
- Direct schema evolution is rejected on a bound graph. Detach it first if you want this graph to diverge.
- A graph type cannot be dropped while any graph is bound to it.
