# Managing HDC Graphs

## Overview

You can create one or multiple HDC graphs for a graph as needed. Each HDC graph is hosted on a single HDC server.

Note that each time an HDC server is rebooted, all hosted HDC graphs will be reloaded based on their configurations.

## Showing HDC Graphs

Retrieves information about all HDC graphs of the current graph:

```gql
SHOW HDC GRAPH
```

Retrieves all HDC graphs of the current graph hosted on the HDC server `hdc-server-1`:

```gql
SHOW HDC GRAPH ON "hdc-server-1"
```

It returns a table `_hdcGraphList` with the following fields:

| <div table-width="22">Field</div> | Description |
| -- | -- |
| `name` | Name of the HDC graph. |
| `graph_name` | Name of the current graphset from which the data was loaded. |
| `status` | Current state of the HDC graph, which can be `DONE` or `CREATING`, `FAILED` or `UNKNOWN`. |
| `stats` | Statistics about nodes and edges included in the HDC graph, including their schemas (labels), properties and total counts. |
| `hdc_server_name` | Name of the HDC server hosting the HDC graph. |
| `hdc_server_status` | Current state of this HDC server, which can be `ACTIVE` or `DEAD`. |
| `config` | Configurations for the HDC graph. |

## Creating an HDC Graph

The `CREATE HDC GRAPH` statement can be used to create an HDC graph for the current graph. The HDC graph creation is executed as a job, you may run `SHOW JOB <id?>` afterward to verify the success of the creation.

### Syntax

<p tit="Syntax"></p>

```gql
CREATE HDC GRAPH [IF NOT EXISTS] <hdcGraphName> ON "<hdcServerName>" OPTIONS {
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
  load_id: <boolean>,
  update: "<static_or_sync>"
}
```

<table>
  <thead>
    <th style="width:28%" colspan=2>Param</th>
    <th>Description</th>
    <th style="width:11%">Optional</th>
  </thead>
  <tbody>
    <tr>
      <td colspan=2><code>&lt;hdcGraphName&gt;</code></td>
      <td>Name of the HDC graph. HDC graphs hosted by the same HDC server cannot have duplicate names. HDC graphs and projections of the same graph cannot have duplicate names.</td>
      <td>No</td>
    </tr>
    <tr>
      <td colspan=2><code>&lt;hdcServerName&gt;</code></td>
      <td>Name of the HDC server to host the HDC graph.</td>
      <td>No</td>
    </tr>
    <tr>
      <td rowspan=5><code>OPTIONS</code></td>
      <td><code>nodes</code></td>
      <td>Specifies nodes to load based on labels and properties. The <code>_uuid</code> is loaded by default, while <code>_id</code> is configurable with <code>load_id</code>. Sets to <code>"*": ["*"]</code> to load all nodes.</td>
      <td>Yes</td>
    </tr>
    <tr>
      <td><code>edges</code></td>
      <td>Specifies edges to load based on labels and properties. All system properties are loaded by default. Sets to <code>"*": ["*"]</code> to load all edges.</td>
      <td>Yes</td>
    </tr>
    <tr>
      <td><code>direction</code></td>
      <td>Since each edge is physically stored twice - as an incoming edge along its destination node and an outgoing edge with its source node - you can choose to load only incoming edges with <code>in</code>, only outgoing edges with <code>out</code>, or both (the default setting) with <code>undirected</code>. Please note that <code>in</code> or <code>out</code> restricts graph traversal during computation to the specified direction.</td>
      <td>Yes</td>
    </tr>
    <tr>
      <td><code>load_id</code></td>
      <td>Sets to <code>false</code> to load nodes without <code>_id</code> values to save the memory space; it defaults to <code>true</code>.</td>
      <td>Yes</td>
    </tr>
    <tr>
      <td><code>update</code></td>
      <td>Sets the data sync mode as:<ul><li><code>static</code>: This is the default. Any data change in the physical storage will not be synchronized to the HDC graph.</li><li><code>sync</code>: The insertion, update, and deletion of nodes and edges will be synchronized to the HDC graph.<sup>[1] [2]</sup></li></ul></td>
      <td>Yes</td>
    </tr>
  </tbody>
</table>

<sup>[1]</sup> **Note:** Modifications to the graph structure (schemas and properties) will not be synchronized. For example, if you add a new node schema and insert nodes into it, neither the schema nor the nodes will be synchronized with the HDC graph.<br>
<sup>[2]</sup> The synchronization occurs after two heartbeats.

### Examples

To load the entire current graph to `hdc-server-1` as `hdcGraph`:

```gql
CREATE HDC GRAPH hdcGraph ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}
```

To load `account` and `movie` nodes with selected properties and incoming `rate` edges in the current graph to `hdc-server-1` as `hdcGraph_1`, while omitting nodes' `_id` values:

```gql
CREATE HDC GRAPH hdcGraph_1 ON "hdc-server-1" OPTIONS {
  nodes: {
    "account": ["name", "gender"],
    "movie": ["name", "year"]
  },
  edges: {"rate": ["*"]},
  direction: "in",
  load_id: false,
  update: "static"
}
```

The `IF NOT EXISTS` clause is used to prevent errors when attempting to create an HDC graph that already exists. It allows the statement to be safely executed.

```gql
CREATE HDC GRAPH IF NOT EXISTS hdcGraph ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}
```

This creates the HDC graph `hdcGraph` only if an HDC graph with that name does not exist. If `hdcGraph` already exists, the statement is ignored without throwing an error.

## Dropping an HDC Graph

You can drop any HDC graph of the current graph from the HDC server using the `DROP HDC GRAPH` statement.

The following example deletes the HDC graph named `hdcGraph_1`:

```gql
DROP HDC GRAPH hdcGraph_1
```

## HDC Graph List Synchronization

HDC graphs are managed by the database's meta server. The latest HDC graph list is synchronized from the meta server to the name server during each heartbeat cycle. This list on the name server is referenced whenever HDC queries or algorithms are executed. 

After creating or dropping an HDC graph, it is advisable to wait for two heartbeat intervals before performing further operations on the affected HDC graph. To adjust the heartbeat interval, update the `heartbeat_interval_s` setting (defaults to 3 seconds) in the `Server` section of the name server configuration.
