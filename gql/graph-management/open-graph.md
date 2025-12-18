# Open Graph

## Overview

The **open graph** is schema-free, requiring no explicit schema definitions before data insertion. You can directly insert nodes and edges into the graph, and their labels and properties are created on the fly. This offers maximum flexibility for early-stage data exploration.

In an open graph,

- Each node or edge can have zero, one, or multiple labels.
- Each node or edge has its own set of properties.

Open graphs do not require explicit definitions of labels and properties; they are automatically created as you insert nodes and edges into the graph. However, you still have the option to manually create labels beforehand if desired.

## Creating Open Graph

To create an open graph `g1`:

```gql
CREATE GRAPH g1 ANY
```

The `ANY` keyword identifies an open graph.

## Showing Labels

To show labels in the current graph:

```gql
SHOW LABEL
```

The plural form `SHOW LABELS` is also supported.

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

## Creating Label

You can create new labels within an open graph.

To create a node label `User` within the current graph:

```gql
CREATE NODE LABEL User
```

To create an edge label `Transfers` within the current graph:

```gql
CREATE EDGE LABEL Transfers
```

## Dropping Label

You can delete labels from a graph. Deleting a label will not remove the nodes or edges that use it.

To drop the node label `Person` from the current graph:

```gql
DROP NODE LABEL Person
```

To drop the edge label `LINKS` from the current graph:

```gql
DROP EDGE LABEL LINKS
```
