# Managing HDC Graphs

## Overview

You can create one or multiple HDC graphs for a graphset as needed. Each HDC graph is hosted on a single HDC server.

Note that each time an HDC server is rebooted, all hosted HDC graphs will be reloaded based on their configurations.

## Showing HDC Graphs

Retrieves information about all HDC graphs of the current graphset:

```uql
hdc.graph.show()
```

Or retrieves a specific HDC graph, such as the one named `hdcGraph_1`:

```uql
hdc.graph.show("hdcGraph_1")
```

It returns a table `_hdcGraphList` with the following fields:

| <div table-width="22">Field</div> | Description |
| -- | -- |
| `name` | Name of the HDC graph. |
| `graph_name` | Name of the current graphset from which the data was loaded. |
| `status` | Current state of the HDC graph, which can be `DONE`, `CREATING`, `FAILED` or `UNKNOWN`. |
| `stats` | Statistics about nodes and edges included in the HDC graph, including their schemas, properties and total counts. |
| `hdc_server_name` | Name of the HDC server hosting the HDC graph. |
| `hdc_server_status` | Current state of this HDC server, which can be `ACTIVE` or `DEAD`. |
| `config` | Configurations for the HDC graph. |

When retrieving a specific HDC graph using `hdc.graph.show("<name>")`, two supplementary tables are returned:

- `_graph_from_<hdcServerName>`: Shows all HDC graphs hosted by `<hdcServerName>`.
- `_algoList_from_<hdcServerName>`: Lists all algorithms installed on `<hdcServerName>`.

Here, `<hdcServerName>` is the HDC server hosting the specified HDC graph.

## Creating an HDC Graph

The `hdc.graph.create().to()` statement creates an HDC graph for the current graphset. The HDC graph creation is executed as a job, you may run `show().job(<id?>)` afterward to verify the success of the creation.

### Syntax

<p tit="Syntax"></p>

```uql
hdc.graph.create("<hdcGraphName>", {
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
}).to("<hdcServerName>")
```

<table>
  <thead>
    <th style="width:10%">Method</th>
    <th style="width:25%" colspan=2>Param</th>
    <th>Description</th>
    <th style="width:11%">Optional</th>
  </thead>
  <tbody>
    <tr>
      <td rowspan=6><code>create()</code></td>
      <td colspan=2><code>&lt;hdcGraphName&gt;</code></td>
      <td>Name of the HDC graph. HDC graphs hosted by the same HDC server cannot have duplicate names. HDC graphs and projections of the same graphset cannot have duplicate names.</td>
      <td>No</td>
    </tr>
    <tr>
      <td rowspan=5>Config Map</td>
      <td><code>nodes</code></td>
      <td>Specifies nodes to load based on schemas and properties. The <code>_uuid</code> is loaded by default, while <code>_id</code> is configurable with <code>load_id</code>. Sets to <code>"*": ["*"]</code> to load all nodes.</td>
      <td>Yes</td>
    </tr>
    <tr>
      <td><code>edges</code></td>
      <td>Specifies edges to load based on schemas and properties. All system properties are loaded by default. Sets to <code>"*": ["*"]</code> to load all edges.</td>
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
    <tr>
      <td><code>to()</code></td>
      <td colspan=2><code>&lt;hdcServerName&gt;</code></td>
      <td>Name of the HDC server to host the HDC graph.</td>
      <td>No</td>
    </tr>
  </tbody>
</table>

<sup>[1]</sup> **Note:** Modifications to the graph structure (schemas and properties) will not be synchronized. For example, if you add a new node schema and insert nodes into it, , neither the schema nor the nodes will be synchronized with the HDC graph.<br>
<sup>[2]</sup> The synchronization occurs after two heartbeats.

### Examples

To load the entire current graphset to `hdc-server-1` as `hdcGraph`:

```uql
hdc.graph.create("hdcGraph", {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}).to("hdc-server-1")
```

To load `account` and `movie` nodes with selected properties and incoming `rate` edges in the current graph to `hdc-server-1` as `hdcGraph_1`, while omitting nodes' `_id` values:

```uql
hdc.graph.create("hdcGraph_1", {
  nodes: {
    "account": ["name", "gender"],
    "movie": ["name", "year"]
  },
  edges: {"rate": ["*"]},
  direction: "in",
  load_id: false,
  update: "static"
}).to("hdc-server-1")
```

## Dropping an HDC Graph

You can drop any HDC graph of the current graphset from the HDC server using the `hdc.graph.drop()` statement.

The following example deletes the HDC graph named `hdcGraph_1`:

```uql
hdc.graph.drop("hdcGraph_1")
```

## HDC Graph List Synchronization

HDC graphs are managed by the database's meta server. The latest HDC graph list is synchronized from the meta server to the name server during each heartbeat cycle. This list on the name server is referenced whenever HDC queries or algorithms are executed.

After creating or dropping an HDC graph, it is advisable to wait for two heartbeat intervals before performing further operations on the affected HDC graph. To adjust the heartbeat interval, update the `heartbeat_interval_s` setting (defaults to 3 seconds) in the `Server` section of the name server configuration.
