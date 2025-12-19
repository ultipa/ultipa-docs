# HDC Graph Queries

## Overview

To execute a query on an HDC graph, use the syntax:

<p tit="Syntax"></p>

```uql
exec{
  <query>
} on <hdcGraphName>
```

HDC graphs support queries that retrieve data from the database with enhanced efficiency, but **do not allow operations that modify the graph structure or data**.

## Example Graph

<div align=center drawio-diagram='19393' drawio-name="draw_8b08732074a64162927def2266261f67.jpg"><img src="https://img.ultipa.cn/draw/draw_8b08732074a64162927def2266261f67.jpg?v='1730692035357'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

```uql
create().node_schema("entity").edge_schema("link");
create().edge_property(@link, "weight", float);
insert().into(@entity).nodes([{_id:"A"},{_id:"B"},{_id:"C"},{_id:"D"}]);
insert().into(@link).edges([{_from:"A", _to:"B", weight:1},{_from:"A", _to:"C", weight:1.5},{_from:"A", _to:"D", weight:0.5},{_from:"B", _to:"C", weight:2},{_from:"C", _to:"D", weight:0.5}]);
```

## Queries on HDC Graphs

To create an HDC graph `hdcGraph` of the entire graph:

```uql
hdc.graph.create("hdcGraph", {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}).to("hdc-server-1")
```

To run a query on `hdcGraph`:

```uql
exec{
  n({_id == "A"}).e()[2].n({_id == "C"}) as p
  return p{*}
} on hdcGraph
```

Result: `p`

<div align=center drawio-diagram='19935' drawio-name='draw_0eb00333690049479d8b4020de569179.jpg'><img src="https://img.ultipa.cn/draw/draw_0eb00333690049479d8b4020de569179.jpg?v='1734517654685'"/></div>

## Limited Graph Traversal Direction

If an HDC graph is created with the `direction` option set to `in` or `out`, graph traversal is restricted to incoming or outgoing edges, respectively. Queries attempting to traverse in the missing direction throw errors or yield empty results.

To create an HDC graph `hdcGraph_in_edges` of the graph with nodes and incoming edges:

```uql
hdc.graph.create("hdcGraph_in_edges", {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "in",
  load_id: true,
  update: "static"
}).to("hdc-server-1")
```

This query attempts to traverse the outgoing edges from node `A` on `hdcGraph_in_edges`, but no result will be returned:

```uql
exec{
  n({_id == "A"}).re().n() as p
  return p{*}
} on hdcGraph_in_edges
```

## Exclusion of Node IDs

If an HDC graph is created with the `load_id` option set to `false`, it does not contain the `_id` values for nodes. Queries referencing `_id` throw errors or yield empty results.

To create an HDC graph `hdcGraph_no_id` of the graph without nodes' `_id` values:

```uql
hdc.graph.create("hdcGraph_no_id", {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: false,
  update: "static"
}).to("hdc-server-1")
```

This query utilizes `_id` to filter nodes on `hdcGraph_no_id`, error occurs as the HDC graph lacks nodes' `_id`:

```uql
exec{
  n({_id == "A"}).e()[2].n({_id == "C"}) as p
  return p{*}
} on hdcGraph_no_id
```

## Exclusion of Properties

If an HDC graph is created without certain properties, queries referencing these properties throw errors or yield empty results.

To create an HDC graph `hdcGraph_no_weight` of the graph, which includes all node properties but only the system properties of `link` edges:

```uql
hdc.graph.create("hdcGraph_no_weight", {
  nodes: {"*": ["*"]},
  edges: {"link": []},
  direction: "undirected",
  load_id: true,
  update: "static"
}).to("hdc-server-1")
```

This query finds the shortest path between two nodes on `hdcGraph_no_weight`, weighted by the edge property `@link.weight`. An error occurs because the `weight` property is missing:

```uql
exec{
  ab().src({_id == "A"}).dest({_id == "C"}).depth(2).shortest(@link.weight) as p
  return p
} on hdcGraph_no_weight
```
