# Open Graph

## Overview

The **open graph** is schema-free, requiring no explicit schema definitions before data insertion. You can directly insert nodes and edges into the graph, and their labels and properties are created on the fly. This offers maximum flexibility for early-stage data exploration.

In an open graph,

- Each node has zero, one, or multiple labels, each edge has zero or one label.
- Each node or edge has its own set of properties.

Open graphs do not require explicit definitions of labels and properties; they are automatically created as you insert nodes and edges into the graph.

## Creating Open Graphs

Create an open graph `g1`:

```gql
CREATE GRAPH g1
```

The optional `ANY` keyword can be used to explicitly indicate an open graph:

```gql
CREATE GRAPH g1 ANY
```

A graph created without a graph type specification is an open graph by default.

## Showing Labels

Show labels in the current graph:

```gql
SHOW LABELS
```

Show node labels in the current graph:

```gql
SHOW NODE LABELS
```

Show edge labels in the current graph:

```gql
SHOW EDGE LABELS
```

Each label provides the following essential metadata:

| <div table-width="17">Field</div> | Description |
| -- | -- |
| `label` | The name of the label. |
| `type` | The type of the label, `NODE` or `EDGE`. |