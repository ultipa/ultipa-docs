# Graphset

## Overview

An instance of the Ultipa graph database hosts one or more **graphsets** (or **graphs**), each representing a dataset or domain of interconnected nodes and edges.

A graphset in Ultipa is either **schema-free** or **schema-constrained**.

## Showing Graphsets

Retrieves graphsets in the database:

```uql
// Shows all graphsets
show().graph()

//Shows all graphsets with additional details (total_nodes, total_edges, etc.)
show().graph().more()

// Shows the specified graphset
show().graph("myGraph")

// Shows the specified graphset with additional details (total_nodes, total_edges, etc.)
show().graph("myGraph").more()
```

It returns the following tables:

- The `_graph` table contains all graphsets in the database.
- Each `_graph_shard_<N>` table contains the graphsets that have data stored in the shard with id `<N>`.

Each table includes fields that provide essential details about each graphset:

| <div table-width="17">Field</div> | Description |
| -- | -- |
| `id` | The unique id of the graphset. |
| `name` | The unique name assigned to the graphset. |
| `description` | The description given to the graphset. |
| `status` | The current state of the graphset, which can be `NORMAL`, `LOADING_SNAPSHOT`, `CREATING`, `DROPPING`, or `SCALING`. |
| `shards` | The ids of shards where the graph data is distributed. |
| `partition_by` | The function that computes the hash value for the sharding key, which is essential for sharding the graph data. |
| `meta_version` | The version number utilized by meta servers to synchronize DDL (Data Definition Language) operations on the graphset with shard servers. |
| `total_nodes` | The total count of nodes in the graphset. Only available in `_graph` when the `more()` method is used. |
| `total_edges` | The total count of edges in the graphset. Only available in `_graph` when the `more()` method is used. |
| `schema_free` | Whether the graph is schema-free. |

## Creating Graphsets

You can create a graphset using the `create().graph()` statement.

<p tit="Syntax"></p>

```uql
create().graph("<name>", "<desc?>")
  .schemaFree()
  .shards(<shardList>)
  .partitionByHash(<hashFunc>, <shardKey?>)
```

<table>
  <thead>
    <tr>
      <th style="width:16%;">Method</th>
      <th style="width:15%;">Param</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="2"><code>graph()</code></td>
      <td><code>&lt;name&gt;</code></td>
      <td>The unique name of the graphset. Naming conventions are:<br><ul><li>2 to 127 characters.</li><li>Begins with a letter.</li><li>Allowed characters: letters (A-Z, a-z), numbers (0-9) and underscores (<code>_</code>).</li></ul></td>
    </tr>
    <tr>
      <td><code>&lt;desc?&gt;</code></td>
      <td>Optional. Description of the graphset.</td>
    </tr>
    <tr>
      <td><code>schemaFree()</code></td>
      <td>/</td>
      <td>Optional. Indicates whether the graph is <b>schema-free</b>. A schema-free graph doesn't require explicit schema definitions before inserting data. You can directly insert nodes and edges into the graph, and the corresponding schemas and properties will be automatically created on the fly.</td>
    </tr>
    <tr>
      <td><code>shards()</code></td>
      <td><code>&lt;shardList&gt;</code></td>
      <td>Optional. The list of ids of shards where the graph data will be stored. Defaults to all shards.</td>
    </tr>
    <tr>
      <td rowspan="2"><code>partitionByHash()</code></td>
      <td><code>&lt;hashFunc&gt;</code></td>
      <td>Optional. The function (<code>Crc32</code>, <code>Crc64WE</code>, <code>Crc64XZ</code>, or <code>CityHash64</code>) that computes the hash value for the sharding key, which is essential for sharding the graph data. Defaults to <code>Crc32</code>. For more information, refer to <a target="_blank" href="https://en.wikipedia.org/wiki/Cyclic_redundancy_check">Crc</a> and <a target="_blank" href="https://github.com/google/cityhash">CityHash</a>.</td>
    </tr>
    <tr>
      <td><code>&lt;shardKey?&gt;</code></td>
      <td>Optional. The node property used as the sharding key. Only <code>_id</code> is supported now.</td>
    </tr>
    </tbody>
</table>

To create a graphset named `g1` and distribute its data to shards `[1,2,3]` using the `CityHash64` function based on the `_id` of nodes:

```uql
create().graph("g1").shards([1,2,3]).partitionByHash(CityHash64, _id)
```

To create a graph `g2`:

```uql
create().graph("g2")
```

To create a schema-free graph `g3`:

```uql
create().graph("g3").schemaFree()
```

## Altering Name and Description

You can modify name and description of a graphset using the `alter().graph().set()` statement.

To alter both name and description of the graphset `myGraph`

```uql
alter().graph("myGraph").set({name: "superGraph", description: "Graph used for transactions"})
```

To alter name of the graphset `myGraph`:

```uql
alter().graph("myGraph").set({name: "superGraph"})
```

To alter description of the graphset `myGraph`:

```uql
alter().graph("myGraph").set({description: "Graph used for transactions"})
```

To remove description of the graphset `myGraph`:

```uql
alter().graph("myGraph").set({description: ""})
```

## Migrating Graphset Data

As data in a graphset is distributed across shards, data migration may become necessary sometime — whether to more shards when existing ones become overloaded, or to distribute data across additional geographical locations. Conversely, migrating to fewer shards can free up underutilized resources, reduce costs, and simplify management. Use the `alter().graph().shards().partitionConfig()` statement to migrate data for a graph.

<p tit="Syntax"></p>

```uql
alter().graph("<graphName>").shards(<shardList>).partitionConfig({strategy: "<rsStrat>"})
```

| <div table-width="13">Method</div> | <div table-width="18">Param</div> | Description | <div table-width="11">Optional</div> |
| -- | -- | -- | -- |
| `graph()` | `<graphName>` | Specifies the graphset. | No |
| `shards()` | `<shardList>` | Non-empty list of ids of shards where the graph data will be stored. This must differ from the current shard list and align with the `strategy` set in `partitionConfig()`. | No |
| `partitionConfig()` | Config map | Specifies the migration `strategy`, which can be set as follows:<ul><li>`balance`: Redistributes all graph data evenly across the new shards.</li><li>`quickly_expand`: Quickly migrates some data from existing shards to newly added shards. The `<shardList>` must include all current shards.</li><li>`quickly_shrink`: Quickly migrates data from removed shards to the remaining shards. The `<shardList>` can only be a subset of the current shards.</li></ul>When this method is omitted, `balance` is used by default. | Yes |

Assuming the graphset `myGraph` is currently distributed across shards `1` and `2`. To migrate `myGraph` from shards `[1,2]` to `[1,4,5]`:

```uql
alter().graph('myGraph').shards([1,4,5]).partitionConfig({strategy: "balance"})
```

To migrate `myGraph` from shards `[1,2]` to `[3]`:

```uql
alter().graph('myGraph').shards([3]).partitionConfig({strategy: "balance"})
```

To quickly migrate `myGraph` from shards `[1,2]` to `[1,2,4]`:

```uql
alter().graph('myGraph').shards([1,2,4]).partitionConfig({strategy: "quickly_expand"})
```

To quickly migrate `myGraph` from shards `[1,2]` to `[1]`:

```uql
alter().graph('myGraph').shards([1]).partitionConfig({strategy: "quickly_shrink"})
```

## Dropping Graphsets

You can drop one or more graphsets using a single `drop()` statement. Each graphset is specified by chaining a `graph()` method. Dropping a graphset deleting the entire graphset from the database.

To drop the graphset `myGraph`:

```uql
drop().graph("myGraph")
```

To drop two graphsets:

```uql
drop().graph("myGraph_1").graph("myGraph_2")
```

By default, a graphset cannot be deleted if it still has existing HDC graphs. To bypass this restriction and force the deletion, use the `force()` method:

```uql
drop().graph("myGraph_1").graph("myGraph_2").force()
```

## Truncating a Graphset

You can truncate a graph using the `truncate().graph()` statement. This operation deletes nodes and edges within the graph while preserving the graph itself and its defined graph type.

You may choose to truncate the entire graph, all nodes, all edges, or only the nodes or edges of a specific schema. **Note that truncating nodes will also remove any edges connected to them.**

```uql
// Truncates the graphset 'myGraph' (all nodes and edges will be deleted)
truncate().graph("myGraph")

// Truncates all @user nodes (edges attached to them will be deleted too)
truncate().graph("myGraph").nodes(@user)

// Truncates all nodes (all edges will be deleted too)
truncate().graph("myGraph").nodes("*")

// Truncates all @link edges
truncate().graph("myGraph").edges(@link)

// Truncates all edges
truncate().graph("myGraph").edges("*")
```

## Compacting a Graphset

You can compact a graphset using the `compact().graph()` statement. This operation clears the invalid and redundant graph data from the server disk but does not make any changes to the valid data. The compact operation runs as a job, you may run `show().job(<id?>)` afterward to verify its completion.

To compact the graphset `myGraph`:

```uql
compact().graph("myGraph")
```

> Data manipulation operations can generate redundant data, such as the old records retained after being updated or deleted. It's suggested to regularly compact graphsets to reclaim storage space and improve query efficiency.
