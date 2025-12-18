# Harmonic Centrality

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

Harmonic Centrality is a variant of <a target="_blank" href="/doc/graph-analytics-algorithms/closeness-centrality">Closeness Centrality</a>. The average shortest distance measurement proposed by harmonic centrality is compatible with infinite values which would occur in a disconnected graph. Harmonic centrality was first proposed by M. Marchiori and V. Latora in 2000, and then by A. Dekker and Y. Rochat in 2005 and 2009:

- M. Marchiori, V. Latora, <a target="_blank" href="https://arxiv.org/pdf/cond-mat/0008357.pdf">Harmony in the Small-World</a> (2000)
- A. Dekker, <a target="_blank" href="https://www.cmu.edu/joss/content/articles/volume6/dekker/">Conceptual Distance in Social Network Analysis</a> (2005)
- Y. Rochat, <a target="_blank" href="https://docslib.org/doc/524811/closeness-centrality-extended-to-unconnected-graphs-the-harmonic-centrality-index">Closeness Centrality Extended to Unconnected Graphs: The Harmonic Centrality Index</a> (2009)

Harmonic centrality ranges from 0 to 1; higher scores indicate that a node is closer to other nodes in the graph.

## Concepts

### Shortest Distance

The shortest distance between two nodes is defined as the number of edges in the shortest path connecting them. Please refer to <a target="_blank" href="/doc/graph-analytics-algorithms/closeness-centrality">Closeness Centrality</a> for more details.

### Harmonic Mean

The harmonic mean is the reciprocal of the arithmetic mean of the reciprocals of the variables. The formula for calculating the arithmetic mean `A` and the harmonic mean `H` is as follows:

<center><img width="300" src="https://img.ultipa.cn/2022-08-08-11-08-40-mean.jpg"></center>

A classic application of harmonic mean is to calculate the average speed when traveling back and forth at different speeds. Suppose there is a round trip, the forward and backward speeds are 30 km/h and 10 km/h respectively. What is the average speed for the entire trip?

The arithmetic mean `A = (30+10)/2 = 20 km/h` is not appropriate in this case. Since the backward journey takes three times as long as the forward, during most time of the entire trip the speed stays at 10 km/h, so we expect the average speed to be closer to 10 km/h. 

Assuming the one-way distance is 1, the average speed that takes travel time into consideration is `2/(1/30+1/10) = 15 km/h`. This value, the harmonic mean, is adjusted by the time spent during each journey.

### Harmonic Centrality

Harmonic centrality score of a node defined by this algorithm is the inverse of the harmonic mean of the shortest distances from the node to all other nodes. The formula is:

<div align=center><img width=160 src="https://img.ultipa.cn/img/2023-03-07-14-09-45-hc.jpg"></div>

where `x` is the target node,  `y` is any node in the graph other than `x`, `k-1` is the number of `y`, `d(x,y)` is the shortest distance between `x` and `y`, `d(x,y) = +∞` when `x` and `y` are not reachable to each other, in this case `1/d(x,y) = 0`.

<div align='center' drawio-diagram='2849' drawio-name='draw_f26abcc1ee494ff5a8f1c4286f20f31a.jpg'><img src="https://img.ultipa.cn/draw/draw_f26abcc1ee494ff5a8f1c4286f20f31a.jpg?v='1659930545560'"/></div>

The harmonic centrality of node <i>a</i> in the above graph is `(1 + 1/2 + 1/+∞ + 1/+∞) / 4 = 0.375`, and the harmonic centrality of node <i>d</i> is `(1/+∞ + 1/+∞ + 1/+∞ + 1) / 4 = 0.25`.

> Harmonic Centrality algorithm consumes considerable computing resources. For a graph with <i>V</i> nodes, it is recommended to perform (uniform) sampling when <i>V</i> > 10,000, and the suggested number of samples is the base-10 logarithm of the number of nodes (`log(V)`).<br><br>For each execution of the algorithm, sampling is performed only once, centrality score of each node is computed based on the shortest distance between the node and all sample nodes.

## Considerations

- The harmonic centrality score of isolated nodes is 0. 

## Example Graph

<div align=center drawio-diagram='19734' drawio-name="draw_9505cf4d05b6463aac6c69057482c569.jpg"><img src="https://img.ultipa.cn/draw/draw_9505cf4d05b6463aac6c69057482c569.jpg?v='1735028023494'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  user ()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  vote ()-[{score uint32}]->()
};
INSERT (A:user {_id: "A"}),
       (B:user {_id: "B"}),
       (C:user {_id: "C"}),
       (D:user {_id: "D"}),
       (E:user {_id: "E"}),
       (F:user {_id: "F"}),
       (G:user {_id: "G"}),
       (H:user {_id: "H"}),
       (A)-[:vote {score: 2}]->(B),
       (A)-[:vote {score: 3}]->(E),
       (B)-[:vote {score: 4}]->(B),
       (B)-[:vote {score: 2}]->(C),
       (C)-[:vote {score: 3}]->(A),
       (D)-[:vote {score: 1}]->(A),
       (F)-[:vote {score: 1}]->(G);
```

```uql
create().node_schema("user").edge_schema("vote");
create().edge_property(@vote, "score", uint32);
insert().into(@user).nodes([{_id:"A"},{_id:"B"},{_id:"C"},{_id:"D"},{_id:"E"},{_id:"F"},{_id:"G"},{_id:"H"}]);
insert().into(@vote).edges([{_from:"A", _to:"B", score:2}, {_from:"A", _to:"E", score:3}, {_from:"B", _to:"B", score:4}, {_from:"B", _to:"C", score:2}, {_from:"C", _to:"A", score:3}, {_from:"D", _to:"A", score:1}, {_from:"F", _to:"G", score:1}]);
```

</div>

## Creating HDC Graph

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

## Parameters

Algorithm name: `harmonic_centrality`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | []`_id` | / | / | Yes | Specifies nodes for computation by their `_id`. If unset, computation includes all nodes. |
| `uuids` | []`_uuid` | / | / | Yes | Specifies nodes for computation by their `_uuid`. If unset, computation includes all nodes. |
| `direction` | String | `in`, `out` | / | Yes |  Specifies that all edges in the shortest paths must be either incoming (`in`) or outgoing (`out`). |
| `edge_schema_property` | []"`<@schema.?><property>`" | / | / | Yes | Specifies numeric edge properties used as weights by summing their values. Only properties of numeric type are considered, and edges without these properties are ignored. |
| `impl_type` | String | `dijkstra`, `delta_stepping`, `spfa`, `beta` | `beta` | Yes | 	Specifies the algorithm used to compute weighted shortest paths: <a target="_blank" href="/docs/graph-analytics-algorithms/dijkstra-sssp">Dijkstra</a>, <a target="_blank" href="/docs/graph-analytics-algorithms/delta-stepping-sssp">Delta-Stepping</a>, <a target="_blank" href="/docs/graph-analytics-algorithms/spfa">SPFA</a> or the default (`beta`) Ultipa algorithm. Valid only when `edge_schema_property` is specified. |
| `sample_size` | Integer | `-1`, `-2`, `[1, \|V\|]` | `-2` | Yes | Specifies the sampling strategy for computation:<br><ul><li>`-1`: Sample `log(\|V\|)` nodes</li><li>`[1, \|V\|]`: Sample a specific number of nodes (`\|V\|` is the total number of nodes in the graph)</li><li>`-2`: Disable sampling </li></ul>Valid only when all nodes are involved in the computation. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both in the results to represent nodes. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `harmonic_centrality`. |

## File Writeback

<div tab="code">
  
```gql
CALL algo.harmonic_centrality.write("my_hdc_graph", {
  return_id_uuid: "id",
  order: "desc"
}, {
  file: {
    filename: "harmonic"
  }
})
```

```uql
algo(harmonic_centrality).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  order: "desc"
}).write({
  file: {
    filename: "harmonic"
  }
})
```

</div>

Result:

<p tit="File: harmonic"></p>

```
_id,harmonic_centrality
A,0.571429
B,0.428571
C,0.428571
D,0.357143
E,0.357143
F,0.142857
G,0.142857
H,0
```

## DB Writeback

Writes the `harmonic_centrality` values from the results to the specified node property. The property type is `float`.

<div tab="code">

```gql
CALL algo.harmonic_centrality.write("my_hdc_graph", {}, 
{
  db: {
    property: "hc"
  }
})
```

```uql
algo(harmonic_centrality).params({
  projection: "my_hdc_graph"
}).write({
  db:{ 
    property: 'hc'
  }
})
```

</div>

## Full Return

<div tab="code">
  
```gql
CALL algo.harmonic_centrality.run("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["A", "B"],
  edge_schema_property: "score"
}) YIELD hc
RETURN hc
```

```uql
exec{
  algo(harmonic_centrality).params({
    return_id_uuid: "id",
    ids: ["A", "B"],
    edge_schema_property: "score"
  }) as hc
  return hc
} on my_hdc_graph
```

</div>

Result:

| \_id | harmonic_centrality |
| -- | -- |
| A | 0.309523 |
| B | 0.219048 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.harmonic_centrality.stream("my_hdc_graph", {
  direction: "in",
  return_id_uuid: "id"
}) YIELD hc
FILTER hc.harmonic_centrality = 0
RETURN hc
```

```uql
exec{
  algo(harmonic_centrality).params({
    direction: "in",
    return_id_uuid: "id"
  }).stream() as hc
  where hc.harmonic_centrality == 0
  return hc
} on my_hdc_graph
````

</div>

Result:

| \_id | harmonic_centrality |
| -- | -- |
| D | 0 |
| F | 0 |
| H | 0 |
