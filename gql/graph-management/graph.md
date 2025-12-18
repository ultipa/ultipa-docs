# Graph Management

## Overview

An Ultipa instance can host multiple **graphs** (or **graphsets**), each representing a dataset of interconnected nodes and edges.

## Showing Graphs

To show graphs in the database:

```gql
SHOW GRAPH
```

The plural form `SHOW GRAPHS` is also supported.

Each graph provides the following essential metadata:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `id` | The unique id assigned to the graph. |
| `name` | The unique name of the graph. |
| `total_nodes` | The total count of nodes in the graph. |
| `total_edges` | The total count of edges in the graph. |
| `description` | The comment given to the graph. |
| `status` | The state of the graph, which can be `NORMAL`, `LOADING_SNAPSHOT`, `CREATING`, `DROPPING`, or `SCALING`. |
| `shards` | The IDs of shards where the graph data is distributed. |
| `partition_by` | The function that computes the hash value for the sharding key. |
| `schema_free` | Whether the graph is an open graph (schema-free). |
| `meta_version` | The version number utilized by meta servers to synchronize DDL (Data Definition Language) operations on the graph with shard servers. |

## Creating Graph

Ultipa supports two types of graphs: **Typed Graph** and **Open Graph**. This design offers both flexibility and control, supporting workflows ranging from agile exploration to production-grade applications demanding strict data integrity requirements.

### Typed Graph

The **typed graph** is constrained by its **graph type** (or schema), which imposes a strict framework that governs data insertion: *nodes and edges with schemas or properties not defined cannot be added.* While the graph type can be altered after a graph is created, its defined data model ensures consistent structure, guaranteeing high data integrity and consistency.

In a typed graph,

- Each node or edge belongs to exactly one schema.
- Each schema is associated with a set of properties; each property is defined with a specific value type.

To create a graph `g1` with a graph type specification defining schemas and properties:
  
```gql
CREATE GRAPH g1 { 
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME}]->(),
  EDGE Joins ()-[]->()
}
```

<a target="_blank" href="/docs/gql/typed-graph">Learn more about typed graphs →</a>

### Open Graph

The **open graph** is schema-free, requiring no explicit schema definitions before data insertion. You can directly insert nodes and edges into the graph, and their labels and properties are created on the fly. This offers maximum flexibility for early-stage data exploration.

In an open graph,

- Each node or edge can have zero, one, or multiple labels.
- Each node or edge has its own set of properties.

To create an open graph `g2`:

```gql
CREATE GRAPH g2 ANY
```

The `ANY` keyword identifies an open graph.

<a target="_blank" href="/docs/gql/open-graph">Learn more about open graphs →</a>

### Using IF NOT EXISTS

You can use the `IF NOT EXISTS` clause to prevent errors when attempting to create a graph that already exists. It allows the statement to be safely executed.

```gql
CREATE GRAPH IF NOT EXISTS g1 { 
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME}]->(),
  EDGE Joins ()-[]->()
}
```

This creates the graph `g1` only if a graph with that name does not exist. If `g1` already exists, the statement is ignored without throwing an error.

### Adding Comment

You can add comments to the graph to improve clarity and understanding.

To create a graph `g3` with a comment:

```gql
CREATE GRAPH g3 ANY COMMENT 'Social graph'
```

## Graph Sharding and Storage

The graph data is physically stored on the **shard servers** that constitute the <a target="_blank" href="/docs/graph-database/ultipa-powerhouse-v5">Ultipa database deployment</a>. Depending on your setup, you can run one or multiple shard servers. 

When creating a graph, you can assign a single shard to store its data or distribute the data across multiple shards. This sharded architecture enables **horizontal scaling** of your data volume while maintaining high-performance querying.

```gql
CREATE GRAPH g4 { 
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME}]->(),
  EDGE Joins ()-[]->()
}
PARTITION BY HASH(CityHash64) SHARDS [1,2,3]
```

<a target="_blank" href="/docs/gql/graph-sharding-and-storage">Learn more about graph sharding and storage →</a>

## Altering Graph

You can alter the name and comment of a graph.

To rename the graph `amz` to `amazon`:

```gql
ALTER GRAPH amz RENAME TO amazon
```

To update the comment of the graph `amz`:

```gql
ALTER GRAPH amz COMMENT 'Amazon dataset'
```

You can also perform both operations in a single statement:

```gql
ALTER GRAPH amz RENAME TO amazon COMMENT 'Amazon dataset'
```

## Dropping Graph

To drop the graph `g1`:

```gql
DROP GRAPH g1
```

The `IF EXISTS` clause is used to prevent errors when attempting to delete a graph that does not exist. It allows the statement to be safely executed.

```gql
DROP GRAPH IF EXISTS g1
```

This deletes the graph `g1` only if a graph with that name does exist. If `g1` does not exist, the statement is ignored without throwing an error.

By default, a graph cannot be deleted if it still has existing <a target="_blank" href="/docs/gql/hdc-graph-overview">HDC graphs</a>. To bypass this restriction, use the `FORCE` keyword:

```gql
FORCE DROP GRAPH g1
```

## Truncating Graph

The truncating operation deletes nodes and edges from the graph while preserving the graph itself and its graph type (typed graph) or labels (open graph).

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

In a typed graph, you can truncate nodes or edges of a specified schema. For example, to truncate all `User` nodes in `myGraph`, note that all edges connected to `User` nodes will be removed too:

```gql
TRUNCATE NODE User ON myGraph
```

To truncate all `Follows` edges in `myGraph`:

```gql
TRUNCATE EDGE Follows ON myGraph
```

## Compacting Graph

The compact operation clears the invalid and redundant graph data from the server disk but makes no changes to the valid data. The compact operation runs as a job, you may run `SHOW JOB <id?>` afterward to verify its completion.

To compact `myGraph`:

```gql
COMPACT GRAPH myGraph
```

> Some data manipulation operations may generate redundant data, such as the old records retained after being updated or deleted. It's suggested to regularly compact graphs to reclaim storage space and improve query efficiency.

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

In a typed graph, node schema names must be unique, and edge schema names must be unique. However, a node schema and an edge schema may share the same name.

### Property

Each property name must:

- Contain 2 to 127 characters.
- Cannot start with an underscore (`_`) or a tilde (<code>~</code>).
- Cannot contain backticks (<code>`</code>).
- Cannot use system property names or <a target="_blank" href="/docs/gql/reserved-words">reserved words</a>.

In a typed graph, property names must be unique among a node schema or an edge schema.
