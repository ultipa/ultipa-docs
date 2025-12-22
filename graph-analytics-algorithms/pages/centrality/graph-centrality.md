# Graph Centrality

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

Graph centrality of a node is measured by the maximum shortest distance from the node to all other reachable nodes. This measurement, along with other measurements like closeness centrality and graph diameter, can be considered jointly to determine whether a node is literally located at the very center of the graph.

Graph centrality takes on values between 0 to 1, nodes with higher scores are closer to the center.

## Concepts

### Shortest Distance

The shortest distance between two nodes is the number of edges in the shortest path connecting them. Please refer to <a target="_blank" href="/docs/graph-analytics-algorithms/closeness-centrality">Closeness Centrality</a> for more details.

### Graph Centrality

The graph centrality score of a node, as defined by this algorithm, is the inverse of the maximum shortest distance from that node to all other reachable nodes. The formula is:

<div align=center><img width=180 src="https://img.ultipa.cn/img/2023-03-07-14-21-05-gc.jpg"></div>

where `x` is the target node,  `y` is any node that connects with `x` along edges (`x` itself is excluded), `d(x,y)` is the shortest distance between `x` and `y`.

<div align=center drawio-diagram='1454' drawio-name="draw_26771c0b3279432fb74d7ceb6502c9c5.jpg"><img src="https://img.ultipa.cn/draw/draw_26771c0b3279432fb74d7ceb6502c9c5.jpg?v='1643192998970'"/></div>

In this graph, the green and red numbers next to each node represent the shortest distances from that node to the green and red nodes, respectively. Graph centrality scores of the green and red nodes are `1/4 = 0.25` and `1/3 = 0.3333` respectively. 

Regarding closeness centrality, the green node has score `8/(1+1+1+1+2+3+4+3) = 0.5`, the red node has score `8/(3+3+3+2+1+1+2+1) = 0.5`. When two nodes share the same closeness centrality score, graph centrality can act as a secondary metric to determine which node is closer to the center. 

> Graph Centrality algorithm consumes considerable computing resources. For a graph with <i>V</i> nodes, it is recommended to perform (uniform) sampling when <i>V</i> > 10,000, and the suggested number of samples is the base-10 logarithm of the number of nodes (`log(V)`).<br><br>For each execution of the algorithm, sampling is performed only once, centrality score of each node is computed based on the shortest distance between the node and all sample nodes.

## Considerations

- The graph centrality score of isolated nodes is 0. 
- The Graph Centrality algorithm ignores the direction of edges but calculates them as undirected edges.

## Example Graph

<div align=center drawio-diagram='19736' drawio-name="draw_ff2b86ae207948b19e5f0c913137d31a.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_ff2b86ae207948b19e5f0c913137d31a.jpg?v='1751449980368'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  user ()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  vote ()-[{weight uint32}]->()
};
INSERT (A:user {_id: "A"}),
       (B:user {_id: "B"}),
       (C:user {_id: "C"}),
       (D:user {_id: "D"}),
       (E:user {_id: "E"}),
       (F:user {_id: "F"}),
       (G:user {_id: "G"}),
       (H:user {_id: "H"}),
       (I:user {_id: "I"}),
       (J:user {_id: "J"}),
       (A)-[:vote {weight: 1}]->(B),
       (A)-[:vote {weight: 2}]->(C),
       (A)-[:vote {weight: 3}]->(D),
       (E)-[:vote {weight: 2}]->(A),
       (E)-[:vote {weight: 1}]->(F),
       (F)-[:vote {weight: 4}]->(G),
       (F)-[:vote {weight: 1}]->(I),
       (G)-[:vote {weight: 2}]->(H),
       (H)-[:vote {weight: 1}]->(I);
```

```uql
create().node_schema("user").edge_schema("vote");
create().edge_property(@vote, "weight", uint32);
insert().into(@user).nodes([{_id:"A"},{_id:"B"},{_id:"C"},{_id:"D"},{_id:"E"},{_id:"F"},{_id:"G"},{_id:"H"},{_id:"I"},{_id:"J"}]);
insert().into(@vote).edges([{_from:"A", _to:"B", weight:1}, {_from:"A", _to:"C", weight:2}, {_from:"A", _to:"D", weight:3}, {_from:"E", _to:"A", weight:2}, {_from:"E", _to:"F", weight:1}, {_from:"F", _to:"G", weight:4}, {_from:"F", _to:"I", weight:1}, {_from:"G", _to:"H", weight:2}, {_from:"H", _to:"I", weight:1}]);
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

Algorithm name: `graph_centrality`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | []`_id` | / | / | Yes | Specifies nodes for computation by their `_id`. If unset, computation includes all nodes. |
| `uuids` | []`_uuid` | / | / | Yes | Specifies nodes for computation by their `_uuid`. If unset, computation includes all nodes. |
| `direction` | String | `in`, `out` | / | Yes | Specifies that all edges in the shortest paths must be either incoming (`in`) or outgoing (`out`). |
| `edge_schema_property` | []"`<@schema.?><property>`" | / | / | Yes | Numeric edge properties used as weights, summing values across the specified properties; edges without this property are ignored. |
| `impl_type` | String | `dijkstra`, `delta_stepping`, `spfa`, `beta` | `beta` | Yes | Specifies the weighted shortest paths to be computed by the <a target="_blank" href="/docs/graph-analytics-algorithms/dijkstra-sssp">Dijkstra</a>, <a target="_blank" href="/docs/graph-analytics-algorithms/delta-stepping-sssp">Delta-Stepping</a>, <a target="_blank" href="/docs/graph-analytics-algorithms/spfa">SPFA</a> or the default (`beta`) Ultipa shortest path algorithm. This is only valid when `edge_schema_property` is used. |
| `sample_size` | Integer | `-1`, `-2`, `[1, \|V\|]` | `-2` | Yes | Specifies the sampling strategy for computation; Sets to `-1` to sample `log(\|V\|)` nodes, or a number between `[1, \|V\|]` to sample a specific number of nodes (`\|V\|` is the total number of nodes in the graph). Sets to `-2` to perform no sampling. This option is only valid when all nodes are involved in the computation. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned; `-1` includes all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `graph_centrality`. |

## File Writeback

<div tab="code">
  
```gql
CALL algo.graph_centrality.write("my_hdc_graph", {
  return_id_uuid: "id"
}, {
  file: {
    filename: "graph_centrality"
  }
})
```

```uql
algo(graph_centrality).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id"
}).write({
  file: {
    filename: "graph_centrality"
  }
})
```

</div>

Result:

<p tit="File: graph_centrality"></p>

```
_id,graph_centrality
J,0
D,0.2
F,0.333333
H,0.2
B,0.2
A,0.25
E,0.333333
C,0.2
I,0.25
G,0.25
```

## DB Writeback

Writes the `graph_centrality` values from the results to the specified node property. The property type is `float`.

<div tab="code">

```gql
CALL algo.graph_centrality.write("my_hdc_graph", {}, 
{
  db: {
    property: "gc"
  }
})
```

```uql
algo(graph_centrality).params({
  projection: "my_hdc_graph"
}).write({
  db:{ 
    property: 'gc'
  }
})
```
  
</div>

## Full Return

<div tab="code">
  
```gql
CALL algo.graph_centrality.run("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["A", "B"],
  edge_schema_property: "weight"
}) YIELD gc
RETURN gc
```

```uql
exec{
  algo(graph_centrality).params({
    return_id_uuid: "id",
    ids: ["A", "B"],
    edge_schema_property: "weight"
  }) as gc
  return gc
} on my_hdc_graph
```

</div>

Result:

| \_id | graph_centrality |
| -- | -- |
| A | 0.142857 |
| B | 0.125 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.graph_centrality.stream("my_hdc_graph", {
  return_id_uuid: "id"
}) YIELD gc
FILTER gc.graph_centrality > 0.25
RETURN gc
```

```uql
exec{
  algo(graph_centrality).params({
    return_id_uuid: "id"
  }).stream() as gc
  where gc.graph_centrality > 0.25
  return gc
} on my_hdc_graph
````

</div>

Result:

| \_id | graph_centrality |
| -- | -- |
| E | 0.333333 |
| F | 0.333333 |
