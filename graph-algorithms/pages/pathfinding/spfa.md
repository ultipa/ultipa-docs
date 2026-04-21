# Shortest Path Faster Algorithm (SPFA)

## Overview

The Shortest Path Faster Algorithm (SPFA) is an improvement of the Bellman–Ford algorithm which computes the shortest paths from a source node to all other reachable nodes (i.e., single-source shortest paths) in a graph. It is especially well-suited for graphs with negative-weight edges.

The algorithm was first published by E.F. Moore in 1959, but it was later rediscovered and popularized under the name "Shortest Path Faster Algorithm (SPFA)" by FanDing Duan in 1994. 

- F. Duan, <a target="_blank" href="https://xueshu.baidu.com/usercenter/paper/show?paperid=39798c8bf2d1b5236cdaae3152d490ed&site=xueshu_se">关于最短路径的SPFA快速算法 [About the SPFA algorithm]</a> (1994)

## Concepts

### Shortest Path Faster Algorithm (SPFA)

Given a graph `G = (V, E)` and a source node <i>s∈V</i>, array <i>d[]</i> is used to store the distances of the shortest paths from <i>s</i> to all nodes. Initialize all elements in <i>d[]</i> to infinity, except for <i>d[s] = 0</i>.

The basic idea of SPFA is the same as the <a target="_blank" href="https://en.wikipedia.org/wiki/Bellman%E2%80%93Ford_algorithm">Bellman–Ford algorithm</a> in that each node is used as a candidate to relax its adjacent nodes. However, SPFA improves efficiency by avoiding unnecessary iterations over all nodes. Instead, it maintains a first-in, first-out queue <i>Q</i> to store candidate nodes, and a node is added to the queue only when it has been relaxed. 

> The term <i>relaxation</i> refers to the process of updating the distance of a node <i>v</i> that is connected to node <i>u</i> to a potential shorter distance by considering the path through node <i>u</i>. Specifically, the distance of node v is updated to <i>d[v] = d[u] + w(u,v)</i>, where <i>w(u,v)</i> is the weight of the edge <i>(u,v)</i>. This update is performed only if the current <i>d[v]</i> is greater than <i>d[u] + w(u,v)</i>.

At the begining of the algorithm, all nodes are assigned an initial distance of infinity, except for the source node, which is set to 0. The source node is viewed as first relaxed and pushed into the queue.

During each iteration, SPFA dequeues a node <i>u</i> from <i>Q</i> as a candidate. For each edge <i>(u,v)</i> in the graph, if node <i>v</i> can be relaxed, the following steps are performed:

- Relax node <i>v</i>: <i>d[v] = d[v] + w(u,v)</i>.
- Push node <i>v</i> into <i>Q</i> if <i>v</i> is not in <i>Q</i>.

This process repeats until no more nodes can be relaxed.

The steps below illustrate how to compute the SPFA with source node <i>A</i> and find the weighted shortest paths in the outgoing direction:

<div align=center drawio-diagram='6336' drawio-name="draw_7b49715522cd46079f5c9f81f152083f.jpg"><img src="https://img.ultipa.cn/draw/draw_7b49715522cd46079f5c9f81f152083f.jpg?v='1689056307984'"/></div>

## Considerations

- SPFA can handle graphs with negative edge weights under the conditions that (1) the source node does not have access to any node within a <i>negative cycle</i>, and (2) the shortest paths are directed. A negative cycle is a cycle where the sum of the edge weights is negative. If the graph contains such cycles or if shortest paths are undirected when negative weights exist, SPFA will output infinite results. This occurs because the algorithm can repeatedly traverse the negative cycle or edge, continually lowering the path cost each time.
- If multiple shortest paths exist between two nodes, the algorithm will find all of them.
- In disconnected graphs, the algorithm only outputs the shortest paths from the source node to all nodes belonging to the same connected component as the source node.

## Example Graph

<div align=center drawio-diagram='19978' drawio-name='draw_0750d2ce44a14b9bb8e526b14c363d5f.jpg'><img src="https://img.ultipa.cn/draw/draw_0750d2ce44a14b9bb8e526b14c363d5f.jpg?v='1735031394043'"/></div>

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
| `impl_type` | String | `spfa` | `beta` | No | Specifies the implementation type of the SSSP algorithm; for the SPFA, keep it as `spfa`; `beta` is Ultipa's default shortest path algorithm. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. Edges can only be represented by `_uuid`. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `totalCost`. |

## File Writeback

  
```gql
CALL algo.sssp.write("my_hdc_graph", {
  ids: "A",
  edge_schema_property: "@default.value",
  impl_type: "spfa",
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
D,5
F,4
B,2
E,5
C,5
G,8

```  

  
```gql
CALL algo.sssp.write("my_hdc_graph", {
  ids: "A",
  edge_schema_property: "@default.value",
  impl_type: "spfa",
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
5,A--[101]--B--[104]--C
4,A--[102]--F
2,A--[101]--B
```

## Full Return

  
```gql
CALL algo.sssp.run("my_hdc_graph", {
  ids: 'A',
  edge_schema_property: 'value',
  impl_type: 'spfa',
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
  impl_type: 'spfa',
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
