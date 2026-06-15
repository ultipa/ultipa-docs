# Managing Distributed Projections

## Overview

A distributed projection resides in the memory of the corresponding shard servers where the data is persistently stored. It can hold either full or partial data from a graph. The term "distributed projection" indicates that data within it can be distributed across the memory of multiple shards.

> All distributed projections of a graph are lost when the data in the graph is migrated to different shards.

## Showing Distributed Projections

Retrieves information about all distributed projections of the current graph:

<div tab="code">

```gql
SHOW PROJECTION
```

```uql
show().projection()
```

</div>

It returns a table `_projectionList` with the following fields:

| <div table-width="18">Field</div> | Description |
| -- | -- |
| `name` | Name of the projection. |
| `graph_name` | Name of the current graphset from which the data was loaded. |
| `status` | Current state of the projection, which can be `DONE` or `CREATING`, `FAILED` or `UNKNOWN`. |
| `stats` | Node and edge statistics per shard, including `address` of the leader replica of the current graphset, `edge_in_count`, `edge_out_count` and `node_count`. |
| `config` | Configurations for the distributed projection. |

## Creating a Distributed Projection

The projection creation is executed as a job, you may run `SHOW JOB <id?>` (GQL) or `show().job(<id?>)` (UQL) afterward to verify the success of the creation. 

### Syntax

<div tab="code">

```gql
CREATE PROJECTION <projectionName> OPTIONS {
  nodes: {
    "<schema1>": ["<property1>", "<property2>", ...],
    "<schema2>": ["<property1>", "<property2>", ...],
    ...
  },
  edges: {
    "<schema1>": ["<property1>", "<property2>", ...],
    "<schema2>": ["<property1>", "<property2>", ...],
    ...
  },
  direction: "<edgeDirection>",
  load_id: <boolean>
}
```

```uql
create().projection("<projectionName>", {
  nodes: {
    "<schema1>": ["<property1>", "<property2>", ...],
    "<schema2>": ["<property1>", "<property2>", ...],
    ...
  },
  edges: {
    "<schema1>": ["<property1>", "<property2>", ...],
    "<schema2>": ["<property1>", "<property2>", ...],
    ...
  },
  direction: "<edgeDirection>",
  load_id: <boolean>
})
```

</div>

<table>
  <thead>
    <th style="width:22%">Param</th>
    <th>Description</th>
    <th style="width:11%">Optional</th>
  </thead>
  <tbody>
    <tr>
      <td><code>&lt;projectionName&gt;</code></td>
      <td>Name of the projection. Projections of the same graph cannot have duplicate names. Projections and HDC graphs of the same graph cannot have duplicate names.</td>
      <td>No</td>
    </tr>
    <tr>
      <td><code>nodes</code></td>
      <td>Specifies nodes to project based on schemas and properties. The <code>_uuid</code> is loaded by default, while <code>_id</code> is configurable with <code>load_id</code>. Sets to <code>"*": ["*"]</code> to load all nodes.	</td>
      <td>Yes</td>
    </tr>
    <tr>
      <td><code>edges</code></td>
      <td>Specifies edges to project based on schemas and properties. All system properties are loaded by default. Sets to <code>"*": ["*"]</code> to load all edges.</td>
      <td>Yes</td>
    </tr>
    <tr>
      <td><code>direction</code></td>
      <td>Since each edge is physically stored twice - as an incoming edge along its destination node and an outgoing edge with its source node - you can choose to project only incoming edges with <code>in</code>, only outgoing edges with <code>out</code>, or both with <code>undirected</code> (the default setting). Please note that <code>in</code> or <code>out</code> restricts graph traversal during computation to the specified direction.</td>
      <td>No</td>
    </tr>
    <tr>
      <td><code>load_id</code></td>
      <td>Sets to <code>false</code> to project nodes without <code>_id</code> values to save the memory space; it defaults to <code>true</code>.</td>
      <td>Yes</td>
    </tr>
  </tbody>
</table>

### Examples

To project the entire current graphset to its shard servers as `distGraph`:

<div tab="code">

```gql
CREATE PROJECTION distGraph OPTIONS {
  nodes: {"*": ["*"]}, 
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true
}
```

```uql
create().projection("distGraph", {
  nodes: {"*": ["*"]}, 
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true
})
```

</div>
  
  
To project `account` and `movie` nodes with selected properties and incoming `rate` edges in the current graph to its shard servers as `distGraph_1`, while omitting nodes' `_id` values:

<div tab="code">

```gql
CREATE PROJECTION distGraph_1 OPTIONS {
  nodes: {
    "account": ["name", "gender"],
    "movie": ["name", "year"]
  },
  edges: {"rate": ["*"]},
  direction: "in",
  load_id: false
}
```

```uql
create().projection("distGraph_1", {
  nodes: {
    "account": ["name", "gender"],
    "movie": ["name", "year"]
  },
  edges: {"rate": ["*"]},
  direction: "in",
  load_id: false
})
```

</div>
  
## Dropping a Distributed Projection

Deletes the distributed projection named `distGraph_1`:

<div tab="code">

```gql
DROP PROJECTION distGraph_1
```

```uql
drop().projection("distGraph_1")
```
    
</div>
