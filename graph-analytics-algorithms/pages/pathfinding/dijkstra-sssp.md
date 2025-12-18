# Dijkstra's Single-Source Shortest Path

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

The <b>single-source shortest path (SSSP)</b> problem involves finding the shortest paths from a given source node to all other reachable nodes in a graph. In weighted graphs, the shortest path minimizes the total edge weights; in unweighted graphs, it minimizes the number of edges (hops). The cost or distance of a path refers to this total weight or count.

The concept was introduced by Dutch computer scientist Edsger W. Dijkstra in 1956, originally to determine the shortest path between two nodes. The single-source shortest path is a common variant, facilitating efficient path planning and network analysis.

## Concepts

### Dijkstra's Single-Source Shortest Path

Below is the basic implementation of the Dijkstra's Single-Source Shortest Path algorithm, along with an example to compute the weighted shortest paths in an undirected graph starting from the source node <i>b</i>:

1\. Create a priority queue to store nodes and their corresponding distances from the source node. Initialize the distance of the source node as 0 and the distances of all other nodes as infinity. All nodes are marked as unvisited.

<div align=center drawio-diagram='6315' drawio-name="draw_4571683ba8384a1f966b9c8aedc12f2b.jpg"><img src="https://img.ultipa.cn/draw/draw_4571683ba8384a1f966b9c8aedc12f2b.jpg?v='1689215708126'"/></div>

2\. Extract the node with the minimum distance from the queue, mark it as visited, and relax each of its <i>unvisited</i> neighbors.

<div align=center drawio-diagram='6318' drawio-name="draw_f48205a154934dc7bee0a7a74a929206.jpg"><img src="https://img.ultipa.cn/draw/draw_f48205a154934dc7bee0a7a74a929206.jpg?v='1689215747833'"/></div>

<center><span style="color: #82B366">Visit node <i>b</i>:<br>dist(a) = min(0+2,∞) = 2, dist(c) = min(0+1,∞) = 1</span></center><br>

> The term <i>relaxation</i> refers to the process of updating the distance of a node <i>v</i> that is connected to node <i>u</i> to a potential shorter distance by considering the path through node <i>u</i>. Specifically, the distance of node v is updated to <i>dist(v) = dist(u) + w(u,v)</i>, where <i>w(u,v)</i> is the weight of the edge <i>(u,v)</i>. This update is performed only if the current <i>dist(v)</i> is greater than <i>dist(u) + w(u,v)</i>.
  
> Once a node is marked as visited, its shortest path is fixed, and its distance will no longer change throughout the remainder of the algorithm. The algorithm only updates the distances of nodes that have not yet been visited.

3\. Repeat step 2 until all nodes are visited.

<div align=center drawio-diagram='6319' drawio-name="draw_703ab5f2ba344b6f9e98b4210edeb4dc.jpg"><img src="https://img.ultipa.cn/draw/draw_703ab5f2ba344b6f9e98b4210edeb4dc.jpg?v='1689216069621'"/></div>

<center><span style="color: #82B366">Visit node <i>c</i>:<br>dist(d) = min(1+3, ∞) = 4, dist(e) = min(1+4, ∞) = 5, dist(g) = min(1+2, ∞) = 3</span></center><br>

<div align=center drawio-diagram='6320' drawio-name="draw_f23e42fc70ce4a3199c214a95368ce91.jpg"><img src="https://img.ultipa.cn/draw/draw_f23e42fc70ce4a3199c214a95368ce91.jpg?v='1689216090060'"/></div>

<center><span style="color: #82B366">Visit node <i>a</i>:<br>dist(d) = min(2+4, 4) = 4</span></center><br> 

<div align=center drawio-diagram='6324' drawio-name="draw_d038072002da4439b2fbc941c8c1e41c.jpg"><img src="https://img.ultipa.cn/draw/draw_d038072002da4439b2fbc941c8c1e41c.jpg?v='1689216106878'"/></div>

<center><span style="color: #82B366">Visit node <i>g</i>:<br>dist(f) = min(3+5, ∞) = 8</span></center><br>

<div align=center drawio-diagram='6325' drawio-name="draw_fa3b39e312dc4ffd85483d35895ce796.jpg"><img src="https://img.ultipa.cn/draw/draw_fa3b39e312dc4ffd85483d35895ce796.jpg?v='1689216119382'"/></div>

<center><span style="color: #82B366">Visit node <i>d</i>:<br>No neighbor can be relaxed</span></center><br>

<div align=center drawio-diagram='6326' drawio-name="draw_6269dd734f1847b6a9ac40366dbce51a.jpg"><img src="https://img.ultipa.cn/draw/draw_6269dd734f1847b6a9ac40366dbce51a.jpg?v='1689216255161'"/></div>

<center><span style="color: #82B366">Visit node <i>e</i>:<br>dist(f) = min(5+8, 8) = 8</span></center><br>

<div align=center drawio-diagram='6327' drawio-name="draw_f9813078c9934fe689656ceb635ca931.jpg"><img src="https://img.ultipa.cn/draw/draw_f9813078c9934fe689656ceb635ca931.jpg?v='1689216129914'"/></div>

<center><span style="color: #82B366">Visit node <i>f</i>:<br>No neighbor can be relaxed<br>The algorithm ends here as all nodes are visited</span></center><br>

## Considerations

- The Dijkstra's algorithm applies only to graphs with non-negative edge weights. If negative weights exist, Dijkstra's algorithm may yield incorrect results. In this case, a different algorithm like the <a target="_blank"  href="/docs/graph-analytics-algorithms/spfa/">SPFA</a> should be used instead.
- If multiple shortest paths exist between two nodes, the algorithm will find all of them.
- In disconnected graphs, the algorithm only outputs the shortest paths from the source node to nodes within the same connected component.

## Example Graph

<div align=center drawio-diagram='19967' drawio-name="draw_7af94365879e4db296e631ae113fa4c9.jpg"><img src="https://img.ultipa.cn/draw/draw_7af94365879e4db296e631ae113fa4c9.jpg?v='1734942494454'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER EDGE default ADD PROPERTY {
  value int32
};
INSERT (A:default {_id: "A"}),
       (B:default {_id: "B"}),
       (C:default {_id: "C"}),
       (D:default {_id: "D"}),
       (E:default {_id: "E"}),
       (F:default {_id: "F"}),
       (G:default {_id: "G"}),
       (A)-[:default {value: 2}]->(B),
       (A)-[:default {value: 4}]->(F),
       (B)-[:default {value: 3}]->(C),
       (B)-[:default {value: 3}]->(D),
       (B)-[:default {value: 6}]->(F),
       (D)-[:default {value: 2}]->(E),
       (D)-[:default {value: 2}]->(F),
       (E)-[:default {value: 3}]->(G),
       (F)-[:default {value: 1}]->(E);
```

```uql
create().edge_property(@default, "value", int32);
insert().into(@default).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}, {_id:"G"}]);
insert().into(@default).edges([{_from:"A", _to:"B", value:2}, {_from:"A", _to:"F", value:4}, {_from:"B", _to:"F", value:6}, {_from:"B", _to:"C", value:3}, {_from:"B", _to:"D", value:3}, {_from:"D", _to:"F", value:2}, {_from:"F", _to:"E", value:1}, {_from:"D", _to:"E", value:2}, {_from:"E", _to:"G", value:3}]);
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

Algorithm name: `sssp`

| <div table-width="17">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="9">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | `_id` | / | / | No | Specifies a single source node by its `_id`. |
| `uuids` | `_uuid` | / | / | No | Specifies a single source node by its `_uuid`. |
| `direction` | String | `in`, `out` | / | Yes | Specifies that the shortest paths should only contain incoming edges (`in`) or outgoing edges (`out`); edge direction is ignored if it is unset. |
| `edge_schema_property` | []"`<@schema.?><property>`"| / | / | Yes | Specifies numeric edge properties used as weights by summing their values. Only properties of numeric type are considered, and edges without these properties are ignored. |
| `record_path` | Integer | `0`, `1` | `0` | Yes | Whether to include the shortest paths in the results; sets to `1` to return the `totalCost` and the shortest paths, or to `0` to return the `totalCost` only. |
| `impl_type` | String | `dijkstra` | `beta` | No | Specifies the implementation type of the SSSP algorithm; for the Dijkstra's SSSP, keep it as `dijkstra`; `beta` is Ultipa's default shortest path algorithm. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. Edges can only be represented by `_uuid`. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `totalCost`. |

## File Writeback

<div tab="code">
  
```gql
CALL algo.sssp.write("my_hdc_graph", {
  ids: "A",
  edge_schema_property: "@default.value",
  impl_type: "dijkstra",
  return_id_uuid: "id"
}, {
  file: {
    filename: "costs"
  }
})
```

```uql
algo(sssp).params({
  projection: "my_hdc_graph",
  ids: "A",
  edge_schema_property: "@default.value",
  impl_type: "dijkstra",
  return_id_uuid: "id"
}).write({
  file: {
      filename: "costs"
  }
})
```

</div>

Result:

<p tit="File: costs"></p>

```
_id,totalCost
D,5
F,4
B,2
E,5
C,5
G,8
```  

<div tab="code">
  
```gql
CALL algo.sssp.write("my_hdc_graph", {
  ids: "A",
  edge_schema_property: "@default.value",
  impl_type: "dijkstra",
  record_path: 1,
  return_id_uuid: "id"
}, {
  file: {
    filename: "paths"
  }
})
```

```uql
algo(sssp).params({
  projection: "my_hdc_graph",
  ids: "A",
  edge_schema_property: "@default.value",
  impl_type: "dijkstra",
  record_path: 1,
  return_id_uuid: "id"
}).write({
  file: {
      filename: "paths"
  }
})
```

</div>

Result:

<p tit="File: costs"></p>

```
totalCost,_ids
8,A--[102]--F--[107]--E--[109]--G
5,A--[101]--B--[105]--D
5,A--[102]--F--[107]--E
5,A--[101]--B--[104]--C
4,A--[102]--F
2,A--[101]--B
```

## Full Return

<div tab="code">
  
```gql
CALL algo.sssp.run("my_hdc_graph", {
  ids: 'A',
  edge_schema_property: 'value',
  impl_type: 'dijkstra',
  record_path: 0,
  return_id_uuid: 'id',
  order: 'desc'
}) YIELD r
RETURN r
```

```uql
exec{
  algo(sssp).params({
    ids: 'A',
    edge_schema_property: 'value',
    impl_type: 'dijkstra',
    record_path: 0,
    return_id_uuid: 'id',
    order: 'desc'
  }) as r
  return r
} on my_hdc_graph
```

</div>

Result:

| \_id | totalCost |
| -- | -- |
| G | 8 |
| D | 5 |
| E | 5 |
| C | 5 |
| F | 4 |
| B | 2 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.sssp.stream("my_hdc_graph", {
  ids: 'A',
  edge_schema_property: '@default.value',
  impl_type: 'dijkstra',
  record_path: 1,
  return_id_uuid: 'id'
}) YIELD r
RETURN r
```

```uql
exec{
  algo(sssp).params({
    ids: 'A',
    edge_schema_property: '@default.value',
    impl_type: 'dijkstra',
    record_path: 1,
    return_id_uuid: 'id'
  }).stream() as r
  return r
} on my_hdc_graph
```

</div>

Result:

| <div table-width="15">totalCost</div> | \_ids |
| -- | -- |
| 8 | ["A","102","F","107","E","109","G"] |
| 5 | ["A","101","B","105","D"] |
| 5 | ["A","102","F","107","E"] |
| 5 | ["A","101","B","104","C"] |
| 4 | ["A","102","F"] |
| 2 | ["A","101","B"] |
