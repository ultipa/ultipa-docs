# Overview

An Ultipa instance can host multiple **graphs**, each representing a dataset of interconnected nodes and edges.

## Showing Graphs

To show graphs in the database:

```gql
SHOW GRAPHS
```

Each graph provides the following essential metadata:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `graph_name` | The unique name of the graph. |
| `current` | Whether the graph is the current graph. |

## Creating Graph

Ultipa supports two types of graphs: **Closed Graph** and **Open Graph**. This design offers both flexibility and control, supporting workflows ranging from agile exploration to production-grade applications demanding strict data integrity requirements.

### Closed Graph

A **closed graph** requires that any node to be inserted must conform to a defined node type, and any edge to be inserted must conform to a defined edge type. This ensures consistent structure, guaranteeing high data integrity and consistency.

<a target="_blank" href="/docs/gql/closed-graph">Learn more about closed graphs →</a>

### Open Graph

The **open graph** is schema-free, requiring no explicit schema definitions before data insertion. You can directly insert nodes and edges into the graph, and their labels and properties are created on the fly. This offers maximum flexibility for early-stage data exploration.

<a target="_blank" href="/docs/gql/open-graph">Learn more about open graphs →</a>

### Using IF NOT EXISTS

You can use the `IF NOT EXISTS` clause to prevent errors when attempting to create a graph that already exists. It allows the statement to be safely executed.

```gql
CREATE GRAPH IF NOT EXISTS myGraph
```

This creates the graph `myGraph` only if a graph with that name does not exist. If `myGraph` already exists, the statement is ignored without throwing an error.

## Dropping Graph

To drop the graph `myGraph`:

```gql
DROP GRAPH myGraph
```

The `IF EXISTS` clause is used to prevent errors when attempting to delete a graph that does not exist. It allows the statement to be safely executed.

```gql
DROP GRAPH IF EXISTS myGraph
```

This deletes the graph `myGraph` only if a graph with that name does exist. If `myGraph` does not exist, the statement is ignored without throwing an error.

## Truncating Graph

The truncating operation deletes nodes and edges from the graph while preserving the graph itself and its graph type (closed graph) or labels (open graph).

You may truncate the entire graph, all nodes or edges, or nodes or edges with a specific label. **Note that truncating nodes will also remove any edges connected to them.**

To truncate `myGraph`:

```gql
TRUNCATE myGraph
```

To truncate all nodes in `myGraph`, note that all edges will be removed too:

```gql
TRUNCATE NODE * ON myGraph
```

To truncate all edges in `myGraph`:

```gql
TRUNCATE EDGE * ON myGraph
```

In a closed graph, you can truncate nodes or edges of a specified schema. For example, to truncate all `User` nodes in `myGraph`, note that all edges connected to `User` nodes will be removed too:

```gql
TRUNCATE NODE User ON myGraph
```

To truncate all `Follows` edges in `myGraph`:

```gql
TRUNCATE EDGE Follows ON myGraph
```

## Naming Conventions

### Graph

Graph names must be unique. Each graph name must:

- Contain 2 to 127 characters.
- Begin with a letter.
- Allowed characters: letters (A-Z, a-z), numbers (0-9) and underscores (<code>_</code>).

### Graph Type

Graph type names must be unique. Each graph type name must:

- Contain 2 to 64 characters.
- Begin with a letter.
- Allowed characters: letters (A-Z, a-z), numbers (0-9) and underscores (<code>_</code>).

### Schema, Label

Each schema name or label must:

- Contain 2 to 127 characters.
- Cannot start with an underscore (`_`) or a tilde (`~`).
- Cannot contain backticks (<code>`</code>).
- Cannot use system property names or <a target="_blank" href="/docs/gql/reserved-words">reserved words</a>.

In a closed graph, node schema names must be unique, and edge schema names must be unique. However, a node schema and an edge schema may share the same name.

### Property

Each property name must:

- Contain 2 to 127 characters.
- Cannot start with an underscore (`_`) or a tilde (<code>~</code>).
- Cannot contain backticks (<code>`</code>).
- Cannot use system property names or <a target="_blank" href="/docs/gql/reserved-words">reserved words</a>.

In a closed graph, property names must be unique among a node schema or an edge schema.
