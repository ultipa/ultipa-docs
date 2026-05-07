# Overview

An Ultipa instance can host multiple **graphs**, each representing a dataset of interconnected nodes and edges.

## Showing Graphs

Show graphs in the database:

```gql
SHOW GRAPHS
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

## Creating Graph

Ultipa supports two types of graphs: **Open Graph** and **Closed Graph**. This design offers both flexibility and control, supporting workflows ranging from agile exploration to production-grade applications demanding strict data integrity requirements.

### Open Graph

An **open graph** is schema-free, requiring no explicit schema definitions before data insertion. You can directly insert nodes and edges into the graph, and their labels and properties are created on the fly. This offers maximum flexibility for early-stage data exploration.

<a target="_blank" href="/docs/gql/open-graph">Learn more about open graphs →</a>

### Closed Graph

A **closed graph** requires that any node or edge to be inserted must conform to a defined node or edge type. This ensures consistent structure, guaranteeing high data integrity and consistency.

<a target="_blank" href="/docs/gql/closed-graph">Learn more about closed graphs →</a>

### Ontology Graph

Ontology support enables RDF/OWL-style class hierarchies and the `@prefix:name` label syntax. Create an ontology-enabled graph with `WITH ONTOLOGY`:

```gql
CREATE GRAPH myOntologyGraph WITH ONTOLOGY
```

For details on ontology features, see <a target="_blank" href="/docs/ontology/">Ontology</a>.

### Using IF NOT EXISTS

You can use the `IF NOT EXISTS` clause to prevent errors when attempting to create a graph that already exists. It allows the statement to be safely executed.

```gql
CREATE GRAPH IF NOT EXISTS myGraph
```

This creates the graph `myGraph` only if a graph with that name does not exist. If `myGraph` already exists, the statement is ignored without throwing an error.

## Selecting Graph

Most GQL queries operate on a specific graph. Use the `USE` statement to set the current graph:

```gql
USE myGraph
```

Or, 

```gql
USE GRAPH myGraph
```

All subsequent queries in the session will run against `myGraph` until another `USE` is issued.

## Altering Graph

### Renaming

```gql
ALTER GRAPH myGraph RENAME TO newName
```

### Setting Comment

```gql
ALTER GRAPH myGraph COMMENT "This is a description"
```

### Converting Between Open and Closed

A closed graph can be converted to an open graph, and vice versa.

Convert a closed graph to open. Existing type definitions are preserved but no longer enforced:

```gql
ALTER GRAPH myGraph SET OPEN
```

Convert an open graph to closed:

```gql
ALTER GRAPH myGraph SET CLOSED
```

After conversion, the graph has no node/edge types defined. You must add types (via `ALTER GRAPH ... ADD NODE/EDGE [TYPE]`) before inserting new data. Existing data is not validated against the new types, only future inserts are checked.

## Dropping Graph

Drop the graph `myGraph`:

```gql
DROP GRAPH myGraph
```

The `IF EXISTS` clause is used to prevent errors when attempting to delete a graph that does not exist. It allows the statement to be safely executed.

```gql
DROP GRAPH IF EXISTS myGraph
```

This deletes the graph `myGraph` only if a graph with that name does exist. If `myGraph` does not exist, the statement is ignored without throwing an error.

## Truncating Graph

The truncating operation deletes all nodes, edges, and index data from the graph while preserving the graph itself. For closed graphs, the graph type is preserved.

You may truncate the entire graph, all nodes or edges, or nodes or edges with a specific label. **Note that truncating nodes will also remove any edges connected to them.**

To truncate `myGraph`:

```gql
TRUNCATE GRAPH myGraph
```

To truncate all nodes in `myGraph`, note that all edges will be removed too:

```gql
TRUNCATE NODE * ON myGraph
```

To truncate all edges in `myGraph`:

```gql
TRUNCATE EDGE * ON myGraph
```

You can truncate nodes or edges of a specified label (open graph) or type (closed graph). 

For example, to truncate all `User` nodes in `myGraph`, note that all edges connected to `User` nodes will be removed too:

```gql
TRUNCATE NODE User ON myGraph
```

To truncate all `Follows` edges in `myGraph`:

```gql
TRUNCATE EDGE Follows ON myGraph
```
