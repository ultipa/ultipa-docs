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
| `graph_type` | The type of the graph (`OPEN` or `CLOSED`). |
| `node_count` | The number of nodes in the graph. |
| `edge_count` | The number of edges in the graph. |
| `node_label_count` | The number of node labels in the graph. |
| `edge_label_count` | The number of edge labels in the graph. |
| `procedure_count` | The number of stored procedures in the graph. |
| `fulltext_index_count` | The number of full-text indexes in the graph. |
| `trigger_count` | The number of triggers in the graph. |
| `created_at` | The creation time of the graph. |
| `comment` | The comment of the graph. |

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

Ultipa supports two kinds of graphs: **Open Graph** and **Closed Graph**. This design offers both flexibility and control, supporting workflows ranging from agile exploration to production-grade applications demanding strict data integrity requirements.

<p tit="Syntax"></p>

```
<create graph statement> ::= 
  "CREATE GRAPH" [ "IF NOT EXISTS" ] <graph name> [ <graph kind> ]

<graph kind> ::= <open graph> | <closed graph>

<open graph> ::= [ "ANY" ] [ <with features> ]

<closed graph> ::= <graph type specification> [ "WITH EDGE_ID" [ "DISABLED" ] ]

<with features> ::= 
  "WITH ONTOLOGY" | "WITH EDGE_ID" [ "DISABLED" ] |
  "WITH ONTOLOGY, EDGE_ID" [ "DISABLED" ] | "WITH EDGE_ID" [ "DISABLED" ] ", ONTOLOGY"
```

**Details**

- If `<graph kind>` is omitted, creates an open graph by default. Learn more about <a target="_blank" href="/docs/gql/open-graphs">Open graphs</a> and <a target="_blank" href="/docs/gql/closed-graphs">Closed graphs</a>.
- `WITH ONTOLOGY` makes an open graph an ontology graph. Learn more about <a target="_blank" href="/docs/ontology/">Ontology</a>.
- Edge ID is enabled by default, `WITH EDGE_ID DISABLED` disables it. Learn more about <a target="_blank" href="/docs/gql/node-and-edge-ids">Node and Edge IDs</a>.

You can use the `IF NOT EXISTS` clause to prevent errors when attempting to create a graph that already exists. It allows the statement to be safely executed.

```gql
CREATE GRAPH IF NOT EXISTS myGraph
```

This creates the graph `myGraph` only if a graph with that name does not exist. If `myGraph` already exists, the statement is ignored without throwing an error.

## Cloning Graphs

<p tit="Syntax"></p>

```
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

-- Truncate all nodes in myGraph, all edges will also be removed
TRUNCATE NODE * ON myGraph

-- Truncate User nodes in myGraph, edges connected to them will also be removed
TRUNCATE NODE User ON myGraph

-- Truncate all edges in myGraph
TRUNCATE EDGE * ON myGraph

-- Truncate Follows edges in myGraph
TRUNCATE EDGE Follows ON myGraph
```