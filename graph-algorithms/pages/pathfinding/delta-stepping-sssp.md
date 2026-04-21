# Delta-Stepping Single-Source Shortest Path

## Overview

The <b>single-source shortest path (SSSP)</b> problem involves finding the shortest paths from a given source node to all other reachable nodes in a graph. In weighted graphs, the shortest path minimizes the total edge weights; in unweighted graphs, it minimizes the number of edges (hops). The cost or distance of a path refers to this total weight or count.

The Delta-Stepping algorithm is a parallelizable variant of Dijkstra's algorithm, designed to improve performance on large graphs by dividing work into manageable steps.

Related material of the algorithm:

- U. Meyer, P. Sanders, <a target="_blank" href="https://www.cs.utexas.edu/~pingali/CS395T/2013fa/papers/delta-stepping.pdf">Δ-Stepping: A Parallel Single Source Shortest Path Algorithm</a> (1998)

## Concepts

### Delta-Stepping Single-Source Shortest Path

The Delta-Stepping Single-Source Shortest Path (SSSP) algorithm introduces the concept of "buckets" and performs relaxation operations in a more coarse-grained manner. The algorithm utilizes a positive real number parameter <i>delta (Δ)</i> to achieve the following:

- Maintain an array <i>B</i> of <i>buckets</i> such that <i>B[i]</i> contains nodes whose distance falls within the range <i>[iΔ, (i+1)Δ)</i>. Thus <i>Δ</i> is also called the "step width" or "bucket width".
- Distinguish between <i>light edges</i> with weight ≤ <i>Δ</i> and <i>heavy edges</i> with weight > <i>Δ</i> in the graph. Light-edge nodes are prioritized during <i>relaxation</i> as they have lower weights and are more likely to yield shorter paths.

> The term <i>relaxation</i> refers to the process of updating the distance of a node <i>v</i> that is connected to node <i>u</i> to a potential shorter distance by considering the path through node <i>u</i>. Specifically, the distance of node v is updated to <i>dist(v) = dist(u) + w(u,v)</i>, where <i>w(u,v)</i> is the weight of the edge <i>(u,v)</i>. This update is performed only if the current <i>dist(v)</i> is greater than <i>dist(u) + w(u,v)</i>.<br><br>In the Delta-Stepping SSSP algorithm, the relaxation also includes assigning the relaxed node to the corresponding bucket based on its updated distance value.

Below is the description of the basic Delta-Stepping SSSP algorithm, along with an example to compute the weighted shortest paths in an undirected graph starting from the source node <i>b</i>, and <i>Δ</i> is set to 3:

1\. At the begining of the algorithm, all nodes are assigned an initial distance of infinity, except for the source node, which is set to 0. The source node is then placed into bucket <i>B[0]</i>.

<div align=center drawio-diagram='6338' drawio-name="draw_5efe262b9d55403bb207d91f98978610.jpg"><img src="https://img.ultipa.cn/draw/draw_5efe262b9d55403bb207d91f98978610.jpg?v='1690868991937'"/></div>

2\. In each iteration, remove all nodes from the first nonempty bucket <i>B[i]</i>:
- Relax all light-edge neighbors of the removed nodes, the relaxed nodes might be assigned to <i>B[i]</i> or <i>B[i+1]</i>; defer the relaxation of the heavy-edge neighbors.
- If <i>B[i]</i> is refilled, repeat the above operation until <i>B[i]</i> is empty.
- Relax all deferred heavy-edge neighbors.

<div align=center drawio-diagram='6339' drawio-name="draw_d6aa4c182255474c9fc3a7497026cadd.jpg"><img src="https://img.ultipa.cn/draw/draw_d6aa4c182255474c9fc3a7497026cadd.jpg?v='1689214052735'"/></div>

<center><span style="color: #82B366">Remove node <i>b</i> from <i>B[0]</i>:<br>Relax light-edge neighbors <i>a</i> with <i>dist(a) = min(0+2,∞) = 2</i>, and <i>d</i> with <i>dist(b) = min(0+3,∞) = 3</i>.</span></center><br>

<div align=center drawio-diagram='6346' drawio-name="draw_4621a1562f9c4a39b8baa59c1473e65a.jpg"><img src="https://img.ultipa.cn/draw/draw_4621a1562f9c4a39b8baa59c1473e65a.jpg?v='1689214040424'"/></div>
  
<center><span style="color: #82B366">Remove node <i>a</i> from <i>B[0]</i>:<br>Light-edge neighbor <i>b</i> cannot be relaxed.<br>Relax heavy-edge neighbor <i>c</i> with <i>dist(c) = min(0+5,∞) = 5</i>, <i>d</i> cannot be relaxed.</span></center><br>

3\. Repeat step 2 until all buckets are empty.

<div align=center drawio-diagram='6340' drawio-name="draw_d5e799ee7a6d49c092985cbfdec248d1.jpg"><img src="https://img.ultipa.cn/draw/draw_d5e799ee7a6d49c092985cbfdec248d1.jpg?v='1689214188453'"/></div>

<center><span style="color: #82B366">Remove nodes <i>d</i> and <i>c</i> from <i>B[1]</i>:<br>Relax light-edge neighbor <i>g</i> with <i>dist(g) = min(5+2,∞) = 7</i>, <i>b</i>, <i>c</i> and <i>d</i> cannot be relaxed.<br>Relax heavy-edge neighbor <i>e</i> with <i>dist(e) = min(5+4,∞) = 9</i>, <i>a</i> and <i>b</i> cannot be relaxed.</span></center><br>

<div align=center drawio-diagram='6347' drawio-name="draw_2bf5a342706b466caa35c251dac05881.jpg"><img src="https://img.ultipa.cn/draw/draw_2bf5a342706b466caa35c251dac05881.jpg?v='1689214248468'"/></div>

<center><span style="color: #82B366">Remove node <i>g</i> from <i>B[2]</i>:<br>Light-edge neighbor <i>c</i> cannot be relaxed.<br>Relax heavy-edge neighbor <i>f</i> with <i>dist(f) = min(7+5,∞) = 12</i>.</span></center><br>

<div align=center drawio-diagram='6348' drawio-name="draw_ce6687f10f154b228eed39d760afd1f2.jpg"><img src="https://img.ultipa.cn/draw/draw_ce6687f10f154b228eed39d760afd1f2.jpg?v='1689214310161'"/></div>

<center><span style="color: #82B366">Remove node <i>e</i> from <i>B[3]</i>:<br>Relax light-edge neighbor <i>f</i> with <i>dist(f) = min(9+1,12) = 10</i>.</span></center><br>

<div align=center drawio-diagram='6349' drawio-name="draw_0c6f83a20c18478e86b1145df27561cd.jpg"><img src="https://img.ultipa.cn/draw/draw_0c6f83a20c18478e86b1145df27561cd.jpg?v='1689214362303'"/></div>

<center><span style="color: #82B366">Remove node <i>f</i> from <i>B[3]</i>:<br>Light-edge neighbor <i>e</i> cannot be relaxed.<br>Heavy-edge neighbor <i>g</i> cannot be relaxed.<br>The algorithm ends here since all buckets are empty.</span></center><br>

By dividing nodes into buckets and processing them in parallel, the Delta-Stepping algorithm efficiently leverages available computational resources, making it well-suited for large-scale graphs and parallel computing environments.

## Considerations

- The Delta-Stepping SSSP algorithm is only applicable to graphs with non-negative edge weights. If negative weights are present, the Delta-Stepping SSSP algorithm might produce false results. In this case, a different algorithm like the <a target="_blank" href="/docs/graph-analytics-algorithms/spfa/">SPFA</a> should be used.
- If multiple shortest paths exist between two nodes, the algorithm will find all of them.
- In disconnected graphs, the algorithm only outputs the shortest paths from the source node to all nodes belonging to the same connected component as the source node.

## Example Graph

<div align=center drawio-diagram='19977' drawio-name='draw_6a00bd2616f94d09b627f90daaa5ff5f.jpg'><img src="https://img.ultipa.cn/draw/draw_6a00bd2616f94d09b627f90daaa5ff5f.jpg?v='1735030269000'"/></div>

Run the following statements on an empty graph to define its structure and insert data:


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



## Parameters

Algorithm name: `sssp`

| <div table-width="17">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="9">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | `_id` | / | / | No | Specifies a single source node by its `_id`. |
| `uuids` | `_uuid` | / | / | No | Specifies a single source node by its `_uuid`. |
| `direction` | String | `in`, `out` | / | Yes | Specifies that the shortest paths should only contain incoming edges (`in`) or outgoing edges (`out`); edge direction is ignored if it is unset. |
| `edge_schema_property` | []"`<@schema.?><property>`"| / | / | Yes | Specifies numeric edge properties used as weights by summing their values. Only properties of numeric type are considered, and edges without these properties are ignored. |
| `record_path` | Integer | `0`, `1` | `0` | Yes | Whether to include the shortest paths in the results; sets to `1` to return the `totalCost` and the shortest paths, or to `0` to return the `totalCost` only. |
| `impl_type` | String | `delta_stepping` | `beta` | No | Specifies the implementation type of the SSSP algorithm; for the Delta-Stepping SSSP, keep it as `delta_stepping`; `beta` is Ultipa's default shortest path algorithm. |
| `delta` | Float |	>0	| `2` |	Yes	| The value of *delta*; only valid when `impl_type` is set to `delta_stepping`. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. Edges can only be represented by `_uuid`. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `totalCost`. |

## File Writeback

  
```gql
CALL algo.sssp.write("my_hdc_graph", {
  ids: "A",
  edge_schema_property: "@default.value",
  impl_type: "delta_stepping",
  return_id_uuid: "id"
}, {
  file: {
    filename: "costs"
  }
})
```



Result:

<p tit="File: costs"></p>

```
_id,totalCost
G,8
D,5
F,4
B,2
E,5
C,5
```

  
```gql
CALL algo.sssp.write("my_hdc_graph", {
  ids: "A",
  edge_schema_property: '@default.value',
  impl_type: 'delta_stepping',
  delta: 2,
  record_path: 1,
  return_id_uuid: "id"
}, {
  file: {
    filename: "paths"
  }
})
```



Result:

<p tit="File: costs"></p>

```
totalCost,_ids
8,A--[102]--F--[107]--E--[109]--G
5,A--[101]--B--[105]--D
5,A--[102]--F--[107]--E
5,A--[103]--B--[104]--C
4,A--[102]--F
2,A--[101]--B
```

## Full Return

  
```gql
CALL algo.sssp.run("my_hdc_graph", {
  ids: 'A',
  edge_schema_property: 'value',
  impl_type: 'delta_stepping',
  delta: 3,
  record_path: 0,
  return_id_uuid: 'id',
  order: 'desc'
}) YIELD r
RETURN r
```



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

  
```gql
CALL algo.sssp.stream("my_hdc_graph", {
  ids: 'A',
  edge_schema_property: '@default.value',
  impl_type: 'delta_stepping',
  record_path: 1,
  return_id_uuid: 'id'
}) YIELD r
RETURN r
```



Result:

| <div table-width="15">totalCost</div> | \_ids |
| -- | -- |
| 8 | ["A","102","F","107","E","109","G"] |
| 5 | ["A","101","B","105","D"] |
| 5 | ["A","102","F","107","E"] |
| 5 | ["A","101","B","104","C"] |
| 4 | ["A","102","F"] |
| 2 | ["A","101","B"] |
