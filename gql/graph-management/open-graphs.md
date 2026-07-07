# Open Graphs

## Overview

An **open graphs** is schema-free, requiring no explicit schema definitions before data insertion. You can directly insert nodes and edges, and their labels and properties are created on the fly. This offers maximum flexibility for early-stage data exploration.

In an open graph,

- Each node has zero, one, or multiple labels, each edge has zero or one label.
- Each node or edge has its own set of properties.

Open graphs do not require explicit definitions of labels and properties; they are automatically created as you insert nodes and edges into the graph.

## Creating Open Graphs

Create an open graph:

```gql
-- The simplest form, a graph is open by default
CREATE GRAPH g1

-- You can also state the open type explicitly with the ANY keyword
CREATE GRAPH g1 ANY

-- Use IF NOT EXISTS to prevent errors when attempting to create a graph that already exists
CREATE GRAPH IF NOT EXISTS g1

-- Disable edge id
CREATE GRAPH g1 WITH EDGE_ID DISABLED
```

## Showing Labels

Show labels in the current graph:

```gql
SHOW LABELS
SHOW NODE LABELS
SHOW EDGE LABELS
```

To inspect a single label:

```gql
DESCRIBE LABEL myLabel

-- DESC is a shorthand for DESCRIBE
DESC LABEL myLabel
```

Each label provides the following essential metadata:

| Field | Description |
| -- | -- |
| `label` | The name of the label. |
| `type` | The type of the label, `NODE` or `EDGE`. |