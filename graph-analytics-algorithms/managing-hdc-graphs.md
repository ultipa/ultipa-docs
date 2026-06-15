# Managing HDC Graphs

An HDC graph resides in the memory of an HDC (High-Density Computing) server and contains all or part of the data loaded from a graph, which is physically stored across one or multiple shard servers.

To load the entire current graph onto `hdc-server-1` as `hdcGraph`:

<div tab="code">

```gql
CREATE HDC GRAPH hdcGraph ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}
```

```uql
hdc.graph.create("hdcGraph", {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}).to("hdc-server-1")
```
  
</div>

To load `account` and `movie` nodes with selected properties and incoming `rate` edges in the current graph onto `hdc-server-1` as `hdcGraph_1`, while omitting nodes' `_id` values:

<div tab="code">

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

```uql
hdc.graph.create("hdcGraph_1", {
  nodes: {
    "account": ["name", "gender"],
    "movie": ["name", "year"]
  },
  edges: {"*": ["*"]},
  direction: "in",
  load_id: false,
  update: "static"
}).to("hdc-server-1")
```
  
</div>

For details, see **Managing HDC Graphs** (<a target="_blank" href="/docs/gql/managing-hdc-graphs">GQL</a> or <a target="_blank" href="/docs/uql/managing-hdc-graphs">UQL</a>).
