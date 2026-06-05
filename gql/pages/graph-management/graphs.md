# Overview

An Ultipa instance can host multiple **graphs**, each representing a dataset of interconnected nodes and edges.

## Showing Graphs

Show graphs in the database:

```gql
SHOW GRAPHS
```

To inspect a single graph:

```gql
DESCRIBE GRAPH myGraph

-- DESC is a shorthand for DESCRIBE
DESC GRAPH myGraph
```

Each graph provides the following metadata:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `graph_id` | The ID of the graph. |
| `graph_name` | The unique name of the graph. |
| `current` | Whether the graph is the current graph. |
| `graph_mode` | The mode of the graph (`OPEN`, `CLOSED` or `ONTOLOGY`). |
| `bounded_graph_type` | The named graph type this graph is bound to. |
| `node_count` | The number of nodes in the graph. |
| `edge_count` | The number of edges in the graph. |
| `node_label_count` | The number of node labels in the graph. |
| `edge_label_count` | The number of edge labels in the graph. |
| `procedure_count` | The number of stored procedures in the graph. |
| `fulltext_index_count` | The number of full-text indexes in the graph. |
| `trigger_count` | The number of triggers in the graph. |
| `created_at` | The creation time of the graph. |
| `comment` | The comment of the graph. |
| `status` | Lifecycle status. `READY` (the common case) means the graph accepts queries and writes; other values (e.g. `COPYING`, `FAILED`) surface in-flight or failed background operations. While not `READY`, queries and writes against this graph are rejected. |
| `copy_source` | When the graph was created by `CREATE GRAPH … AS COPY OF …` and the data copy is still in progress, the name of the source graph. Empty otherwise. |
| `copy_progress_pct` | Background-copy completion percentage (`0`–`100`). Empty / `0` when no background copy is in progress. |
| `copy_started_at` | Timestamp when the background copy began. Empty when no background copy is in progress. |

## Selecting Current Graph

Most GQL queries operate on a specific graph. Use the `USE` statement to set the current graph:

```gql
USE myGraph

-- USE is a shorthand for USE GRAPH
USE GRAPH myGraph
```

All subsequent queries in the session will run against `myGraph` until another `USE` is issued.

To get the name of the current graph at query time, use the `CURRENT_GRAPH` bare keyword. It returns the graph name as a `STRING`:

```gql
RETURN CURRENT_GRAPH
```

## Creating Graphs

You can create an **open graph** or a **closed graph**. This design offers both flexibility and control, supporting workflows ranging from agile exploration to production-grade applications demanding strict data integrity.

> GQLDB also supports the **ontology graph** for modeling RDF data with OWL semantics (classes, object/data properties, characteristics, etc.). See <a target="_blank" href="/docs/ontology/">Ontology</a> for details.

```syntax
<create graph statement> ::= 
  "CREATE GRAPH" [ "IF NOT EXISTS" ] <graph name> [ <graph mode> ]

<graph mode> ::= <open graph> | <closed graph> | <ontology graph>

<open graph> ::= [ "ANY" ] [ "WITH EDGE_ID DISABLED" ]

<closed graph> ::= <graph type specification> [ "WITH EDGE_ID DISABLED" ]
```

**Details**

- If `<graph mode>` is omitted, creates an open graph by default. Learn more about <a target="_blank" href="/docs/gql/open-graphs">Open graphs</a> and <a target="_blank" href="/docs/gql/closed-graphs">Closed graphs</a>.
- Edge `_id` is enabled by default, `WITH EDGE_ID DISABLED` disables it. Learn more about <a target="_blank" href="/docs/gql/node-and-edge-ids">Node and Edge IDs</a>.

You can use the `IF NOT EXISTS` clause to prevent errors when attempting to create a graph that already exists. It allows the statement to be safely executed.

```gql
CREATE GRAPH IF NOT EXISTS myGraph
```

This creates the graph `myGraph` only if a graph with that name does not exist. If `myGraph` already exists, the statement is ignored without throwing an error.

## Cloning Graphs

```syntax
<clone graph statement> ::= 
  "CREATE GRAPH" [ "IF NOT EXISTS" ] <graph name> "AS COPY OF" <graph name>
```

A new graph can be created from an existing one, cloning both data and schema (if it's a closed graph):

```gql
CREATE GRAPH newGraph AS COPY OF myGraph
```

## Converting Between Open and Closed

A closed graph can be converted to an open graph, and vice versa.

Convert a closed graph to open. Existing type definitions are preserved but no longer enforced:

```gql
ALTER GRAPH myGraph SET OPEN
```

Convert an open graph to closed:

```gql
ALTER GRAPH myGraph SET CLOSED
```

After conversion, the graph has no node/edge types defined. You must add node and edge types before inserting new data. Existing data is not validated against the new types, only future inserts are checked.

## Renaming Graphs

Rename `myGraph` to `newGraph`:

```gql
ALTER GRAPH myGraph RENAME TO newGraph
```

## Commenting Graphs

Set comment for `myGraph`:

```gql
ALTER GRAPH myGraph COMMENT "This is a description"
```

## Dropping Graphs

Drop the graph `myGraph`:

```gql
DROP GRAPH myGraph
```

The `IF EXISTS` clause is used to prevent errors when attempting to delete a graph that does not exist. It allows the statement to be safely executed.

```gql
DROP GRAPH IF EXISTS myGraph
```

This deletes the graph `myGraph` only if a graph with that name does exist. If `myGraph` does not exist, the statement is ignored without throwing an error.

## Truncating Graphs

The truncating operation deletes all nodes, edges, and index data from the graph while preserving the graph itself. For closed graphs, the graph type is preserved.

You may truncate the entire graph, all nodes or edges, or nodes or edges with a specific label (open graph) or type (closed graph). **Note that truncating nodes will also remove any edges connected to them.**

```gql
-- Truncate the entire graph
TRUNCATE GRAPH myGraph

-- Truncate all nodes in the current graph
TRUNCATE NODE *

-- Truncate User nodes in the current graph
TRUNCATE NODE User

-- Truncate all edges in the current graph
TRUNCATE EDGE *

-- Truncate Follows edges in the current graph
TRUNCATE EDGE Follows
```