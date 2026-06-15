# Closeness Centrality

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span> <span class="flag" style="background:#014d4e;color:#fff;"><b>Distributed</b></span></div>

## Overview

Closeness centrality of a node is measured by the average shortest distance from the node to all other reachable nodes. The closer a node is to all other nodes, the more central the node is. This algorithm is widely used in applications such as discovering key social nodes and finding best locations for functional places.

> Closeness Centrality algorithm is best to be applied in connected graph. For disconnected graph, its variant, the <a target="_blank" href="/docs/graph-analytics-algorithms/harmonic-centrality">Harmonic Centrality</a>, is recommended.

Closeness centrality takes on values between 0 to 1, nodes with higher scores have shorter distances to all other nodes. 

Closeness centrality was originally defined by Alex Bavelas in 1950:

- A. Bavelas, <a href="https://doi.org/10.1121/1.1906679" target="_blank">Communication patterns in task-oriented groups</a> (1950)

## Concepts

### Shortest Distance

The shortest distance of two nodes is the number of edges contained in the shortest path between them. The shortest path is determined using the BFS principle, if node A is regarded as the start node and node B is one of the K-hop neighbors of node A, then K is the shortest distance between A and B. Please read <a target="_blank" href="/docs/graph-analytics-algorithms/khop-all">K-Hop All</a> for the details about BFS and K-hop neighbor.

<div align=center drawio-diagram='1451' drawio-name="draw_c40a965f5b194538bcccd9b73d07e6d8.jpg"><img src="https://img.ultipa.cn/draw/draw_c40a965f5b194538bcccd9b73d07e6d8.jpg?v='1645510498262'"/></div>

Examine the shortest distance between the red and green nodes in the above graph. Since the graph is undirected, no matter which node (red or green) to start, the other node is the 2-hop neighbor. Thus, the shortest distance between them is 2.

<div align='center' drawio-diagram='4736' drawio-name='draw_606d8502031a460aacb3f68929cf7dce.jpg'><img src="https://img.ultipa.cn/draw/draw_606d8502031a460aacb3f68929cf7dce.jpg?v='1677468316183'"/></div>

Examine the shortest distance between the red and green nodes after converting the undirected graph to directed graph, the edge direction should be considered now. The outgoing shortest distance from the red node to the green node is 4, and the incoming shortest distance from the green node to the red node is 3.

When edge weights are considered, the shortest distance between two nodes is the least sum of weights of the edges in the path between them. 

Examine the shortest distance between the red and green nodes after assigning weights to edges. To minimize the total weight, a path with more edges is chosen, resulting in a total weight of 5.

<div align=center drawio-diagram='19980' drawio-name='draw_91b86ecdfb9043ed9c921fa73a43707e.jpg'><img src="https://img.ultipa.cn/draw/draw_91b86ecdfb9043ed9c921fa73a43707e.jpg?v='1735033396179'"/></div>

### Closeness Centrality

Closeness centrality score of a node defined by this algorithm is the inverse of the arithmetic mean of the shortest distances from the node to all other reachable nodes. The formula is:

<div align=center><img width=150 src="https://img.ultipa.cn/img/2023-03-07-13-54-04-cc.jpg"></div>

where `x` is the target node,  `y` is any node that connects with `x` along edges (`x` itself is excluded), `k-1` is the number of `y`, `d(x,y)` is the shortest distance between `x` and `y`.

<div align=center drawio-diagram='1453' drawio-name="draw_6b97cd73f2834a2f9c623a26f6c65b5c.jpg"><img src="https://img.ultipa.cn/draw/draw_6b97cd73f2834a2f9c623a26f6c65b5c.jpg?v='1643165984784'"/></div>

Calculate closeness centrality score of the red node in the incoming direction in the graph above. Only the blue, yellow and purple nodes can reach the red node in this direction, so the score is `3 / (2 + 1 + 2) = 0.6`. Since the green and grey nodes cannot reach the red node in the incoming direction, they are not included in the calculation.

> Closeness Centrality algorithm consumes considerable computing resources. For a graph with <i>V</i> nodes, it is recommended to perform (uniform) sampling when <i>V</i> > 10,000, and the suggested number of samples is the base-10 logarithm of the number of nodes (`log(V)`).<br><br>For each execution of the algorithm, sampling is performed only once, centrality score of each node is computed based on the shortest distance between the node and all sample nodes.

## Considerations

- The closeness centrality score of isolated nodes is 0. 
- When computing closeness centrality for a node, the unreachable nodes are excluded. For example, this includes isolated nodes, nodes in other connected components, or nodes within the same connected component that are unreachable in the specified direction.

## Example Graph

<div align=center drawio-diagram='19733' drawio-name="draw_4dfe957f3d8d4077b12f6f80375f5f9b.jpg"><img src="https://img.ultipa.cn/draw/draw_4dfe957f3d8d4077b12f6f80375f5f9b.jpg?v='1735021461876'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  user ()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  vote ()-[{strength uint32}]->()
};
INSERT (A:user {_id: "A"}),
       (B:user {_id: "B"}),
       (C:user {_id: "C"}),
       (D:user {_id: "D"}),
       (E:user {_id: "E"}),
       (F:user {_id: "F"}),
       (G:user {_id: "G"}),
       (H:user {_id: "H"}),
       (A)-[:vote {strength: 1}]->(B),
       (A)-[:vote {strength: 3}]->(E),
       (B)-[:vote {strength: 1}]->(B),
       (B)-[:vote {strength: 2}]->(C),
       (C)-[:vote {strength: 3}]->(A),
       (D)-[:vote {strength: 2}]->(A),
       (F)-[:vote {strength: 2}]->(G),
       (G)-[:vote {strength: 3}]->(B),
       (H)-[:vote {strength: 1}]->(G);
```

```uql
create().node_schema("user").edge_schema("vote");
create().edge_property(@vote, "strength", uint32);
insert().into(@user).nodes([{_id:"A"},{_id:"B"},{_id:"C"},{_id:"D"},{_id:"E"},{_id:"F"},{_id:"G"},{_id:"H"}]);
insert().into(@vote).edges([{_from:"A", _to:"B", strength:1}, {_from:"A", _to:"E", strength:3}, {_from:"B", _to:"B", strength:1}, {_from:"B", _to:"C", strength:2}, {_from:"C", _to:"A", strength:3}, {_from:"D", _to:"A", strength:2}, {_from:"F", _to:"G", strength:2}, {_from:"G", _to:"B", strength:3}, {_from:"H", _to:"G", strength:1}]);
```

</div>

## Running on HDC Graphs

### Creating HDC Graph

To load the entire graph to the HDC server `hdc-server-1` as `my_hdc_graph`:

<div tab="code">
  
```gql
CREATE HDC GRAPH my_hdc_graph ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}
```

```uql
hdc.graph.create("my_hdc_graph", {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}).to("hdc-server-1")
```

</div>

### Parameters

Algorithm name: `closeness_centrality`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | []`_id` | / | / | Yes | Specifies nodes for computation by their `_id`. If unset, computation includes all nodes. |
| `uuids` | []`_uuid` | / | / | Yes | Specifies nodes for computation by their `_uuid`. If unset, computation includes all nodes. |
| `direction` | String | `in`, `out` | / | Yes |  Specifies that all edges in the shortest paths must be either incoming (`in`) or outgoing (`out`). |
| `edge_schema_property` | []"`<@schema.?><property>`" | / | / | Yes | Specifies numeric edge properties used as weights by summing their values. Only properties of numeric type are considered, and edges without these properties are ignored. |
| `impl_type` | String | `dijkstra`, `delta_stepping`, `spfa`, `beta` | `beta` | Yes | Specifies the algorithm used to compute weighted shortest paths: <a target="_blank" href="/docs/graph-analytics-algorithms/dijkstra-sssp">Dijkstra</a>, <a target="_blank" href="/docs/graph-analytics-algorithms/delta-stepping-sssp">Delta-Stepping</a>, <a target="_blank" href="/docs/graph-analytics-algorithms/spfa">SPFA</a>, or the default (`beta`) Ultipa algorithm. Valid only when `edge_schema_property` is specified. |
| `sample_size` | Integer | `-1`, `-2`, `[1, \|V\|]` | `-2` | Yes | Specifies the sampling strategy for computation:<br><ul><li>`-1`: Sample `log(\|V\|)` nodes</li><li>`[1, \|V\|]`: Sample a specific number of nodes (`\|V\|` is the total number of nodes in the graph)</li><li>`-2`: Disable sampling </li></ul>Valid only when all nodes are involved in the computation. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both in the results to represent nodes. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `closeness_centrality`. |

### File Writeback

<div tab="code">
  
```gql
CALL algo.closeness_centrality.write("my_hdc_graph", {
  return_id_uuid: "id"
}, {
  file: {
    filename: "closeness"
  }
})
```

```uql
algo(closeness_centrality).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id"
}).write({
  file: {
    filename: "closeness"
  }
})
```

</div>

Result:

<p tit="File: closeness" ></p>

```
_id,closeness_centrality
A,0.583333
E,0.388889
C,0.5
G,0.538462
D,0.388889
F,0.368421
H,0.368421
B,0.636364
```

### DB Writeback

Writes the `closeness_centrality` values from the results to the specified node property. The property type is `float`.

<div tab="code">
  
```gql
CALL algo.closeness_centrality.write("my_hdc_graph", {}, 
{
  db: {
    property: "cc"
  }
})
```

```uql
algo(closeness_centrality).params({
  projection: "my_hdc_graph"
}).write({
  db:{ 
    property: 'cc'
  }
})
```

</div>
  
### Full Return

<div tab="code">
  
```gql
CALL algo.closeness_centrality.run("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["A", "B"],
  edge_schema_property: "strength"
}) YIELD cc
RETURN cc
```

```uql
exec{
  algo(closeness_centrality).params({
    return_id_uuid: "id",
    ids: ["A", "B"],
    edge_schema_property: "strength"
  }) as cc
  return cc
} on my_hdc_graph
```

</div>

Result:

| \_id | closeness_centrality |
| -- | -- |
| A | 0.291667 |
| B | 0.318182 |

### Stream Return

<div tab="code">
  
```gql
CALL algo.closeness_centrality.stream("my_hdc_graph", {
  return_id_uuid: "id",
  direction : "out",
  order: "desc",
  sample_size: -2
}) YIELD cc
FILTER cc.closeness_centrality > 0.5
RETURN cc
```

```uql
exec{
  algo(closeness_centrality).params({
    return_id_uuid: "id",
    direction : "out",
    order: "desc",
    sample_size: -2
  }).stream() as cc
  where cc.closeness_centrality > 0.5
  return cc
} on my_hdc_graph
````

</div>

Result:

| \_id | closeness_centrality |
| -- | -- |
| A | 0.75 |
| C | 0.6 |

## Running on Distributed Projections

### Creating Distributed Projection

To project the entire graph to its shard servers as `myProj`:

<div tab="code">

```gql
CREATE PROJECTION myProj OPTIONS {
  nodes: {"*": ["*"]}, 
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true
}
```
  
```uql
create().projection("myProj", {
  nodes: {"*": ["*"]}, 
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true
})
```

</div>

### Parameters

Algorithm name: `closeness_centrality`

| <div table-width="15">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `direction` | String | `in`, `out` | / | Yes |  Specifies that the shortest paths should only contain incoming edges (`in`) or outgoing edges (`out`). |
| `sample_rate` | Float | (0, 1] | 1 | Yes | Specifies the proportion of edges to sample for computation. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned; `-1` includes all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `closeness_centrality`. |

### File Writeback

<div tab="code">
  
```gql
CALL algo.closeness_centrality.write("myProj", {}, 
{
  file: {
    filename: "closeness"
  }
})
```

```uql
algo(closeness_centrality).params({
  projection: "myProj"
}).write({
  file: {
    filename: "closeness"
  }
})
```

</div>

Result:

<p tit="File: closeness"></p>

```
_id,closeness_centrality
H,0.368421052631579
F,0.368421052631579
E,0.388888888888889
D,0.388888888888889
B,0.636363636363636
A,0.583333333333333
G,0.538461538461538
C,0.5
```

### DB Writeback

Writes the `closeness_centrality` values from the results to the specified node property. The property type is `double`.

<div tab="code">
  
```gql
CALL algo.closeness_centrality.write("myProj", {}, 
{
  db: {
    property: "cc"
  }
})
```

```uql
algo(closeness_centrality).params({
  projection: "myProj"
}).write({
  db:{ 
    property: 'cc'
  }
})
```

</div>
