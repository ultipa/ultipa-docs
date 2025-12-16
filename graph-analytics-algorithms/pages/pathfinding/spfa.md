# Shortest Path Faster Algorithm (SPFA)

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The Shortest Path Faster Algorithm (SPFA) is an improvement of the Bellman–Ford algorithm which computes the shortest path between a source node and all reachable nodes (i.e., single-source shortest paths) in a graph. The algorithm is particularly suitable for graphs that contain negative-weight edges.

The SPFA algorithm was first published by E.F. Moore in 1959, but the name, “Shortest Path Faster Algorithm (SPFA),” was given by FanDing Duan who rediscovered the algorithm in 1994.

- F. Duan, <a target="blank" href="https://xueshu.baidu.com/usercenter/paper/show?paperid=39798c8bf2d1b5236cdaae3152d490ed&site=xueshu_se">关于最短路径的SPFA快速算法 [About the SPFA algorithm]</a> (1994)

## Concepts

### Shortest Path Faster Algorithm (SPFA)

Given a graph <i>G = (V, E)</i> and a source node <i>s∈V</i>, array <i>d[]</i> is used to store the distances of the shortest paths from <i>s</i> to all nodes. Initialize all elements in <i>d[]</i> by infinity except for <i>d[s] = 0</i>.

The basic idea of SPFA is the same as the <a target="blank" href="https://en.wikipedia.org/wiki/Bellman%E2%80%93Ford_algorithm">Bellman–Ford algorithm</a> in that each node is used as a candidate to relax its adjacent nodes. The improvement over the latter is that instead of trying all nodes unnecessary, SPFA maintains a first-in, first-out queue <i>Q</i> to store candidate nodes and only adds a node to the queue if it is relaxed. 

> The term <i>relaxation</i> refers to the process of updating the distance of a node <i>v</i> that is connected to node <i>u</i> to a potential shorter distance by considering the path through node <i>u</i>. Specifically, the distance of node v is updated to <i>d[v] = d[u] + w(u,v)</i>, where <i>w(u,v)</i> is the weight of the edge <i>(u,v)</i>. This update is performed only if the current <i>d[v]</i> is greater than <i>d[u] + w(u,v)</i>.

At the begining of the algorithm, all nodes have the distance as infinity except for the source node as 0. The source node is viewed as first relaxed and pushed into the queue.

During each iteration, SPFA dequeues a node <i>u</i> from <i>Q</i> as a candidate. For each edge <i>(u,v)</i> in the graph, if node <i>v</i> can be relaxed, the following steps are performed:

- Relax node <i>v</i>: <i>d[v] = d[v] + w(u,v)</i>.
- Push node <i>v</i> into <i>Q</i> if <i>v</i> is not in <i>Q</i>.

This process repeats until no more nodes can be relaxed.

The steps below illustrate how to compute the SPFA with source node <i>A</i> and find the weighted shortest paths in the outgoing direction:

<div align=center drawio-diagram='6336' drawio-name="draw_7b49715522cd46079f5c9f81f152083f.jpg"><img src="https://img.ultipa.cn/draw/draw_7b49715522cd46079f5c9f81f152083f.jpg?v='1689056307984'"/></div>

## Considerations

- The SPFA can handle graphs with negative edge weights under the conditions that (1) the source node cannot access any node within a <i>negative cycle</i>, and (2) the shortest paths are directed. A negative cycle is a cycle where the sum of the edge weights is negative. When negative cycles are present or the shortest paths are undirected when negative weights exist, the algorithm will output infinite results. This happens because it repeatedly traverses through the negative cycle or negative edge, leading to continually decreasing costs each time.
- If there are multiple shortest paths exist between two nodes, all of them will be found.
- In disconnected graphs, the algorithm only outputs the shortest paths from the source node to all nodes belonging to the same connected component as the source node.

## Syntax

- Command: `algo(sssp)`
- Parameters:

| <div table-width="15">Name</div> | <div table-width="8">Type</div> | <div table-width="9">Spec</div> | <div table-width="9">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | `_id` / `_uuid` | / | / | No | ID/UUID of the single source node |
| direction | string | `in`, `out` | / | Yes | Direction of the shortest path, ignore the edge direction if not set |
| edge_schema_property | []`@schema?.property` | Numeric type, must LTE	| / | Yes | One or multiple edge properties to be used as edge weights, where the values of multiple properties are summed up; treat the graph as unweighted if not set |
| record_path | int | `0`, `1` | `0` | Yes | `1` to return the shortest paths, `0` to return the shortest distances |
| sssp_type | string | `spfa` | `dijkstra` | No | To run the SPFA, keep it as `spfa` |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order	| string | `asc`, `desc` | / | Yes | Sort nodes by the shortest distance from the source node |

## Examples

The example graph is as follows:

<div align=center drawio-diagram='6551' drawio-name="draw_1f867733d9644c89bd785f5390e8e4fc.jpg"><img src="https://img.ultipa.cn/draw/draw_1f867733d9644c89bd785f5390e8e4fc.jpg?v='1691466119634'"/></div>

### File Writeback

<table>
<thead>
<tr>
  <th style="width:10%">Spec</th>
  <th style="width:15%"><code>record_path</code></th>
  <th style="width:18%">Content</th>
  <th>Description</th>
</tr>
</thead>
<tbody>
<tr>
  <td rowspan="2">filename</td>
  <td>0</td>
  <td><code>_id</code>,<code>totalCost</code></td>
  <td>The shortest distance/cost from the source node to each other node</td>
</tr>
<tr>
  <td>1</td>
  <td><code>_id</code>--<code>_uuid</code>--<code>_id</code></td>
  <td>The shortest path from the source node to each other node, the path is represented by the alternating ID of nodes and UUID of edges that form the path</td>
</tr>
</tbody>
</table>

```js
algo(sssp).params({
  uuids: 1,
  edge_schema_property: '@default.value',
  direction: 'out',
  sssp_type: 'spfa'
}).write({
  file: {
    filename: 'costs'
  }
})
```

Results: File <i>costs</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
A,0
B,2
C,5
D,5
E,-3
F,-4
G,0
```

```js
algo(sssp).params({
  uuids: 1,
  edge_schema_property: '@default.value',
  direction: 'out',
  sssp_type: 'spfa',
  record_path: 1
}).write({
  file: {
    filename: 'paths'
  }
})
```

Results: File <i>paths</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
A--[101]--B--[104]--C
A--[101]--B--[105]--D
A--[101]--B
A
A--[101]--B--[103]--F--[107]--E--[109]--G
A--[101]--B--[103]--F--[107]--E
A--[101]--B--[103]--F
```

### Direct Return

<table>
<thead>
<tr>
  <th style="width:8%">Alias Ordinal</th>
  <th style="width:15%"><code>record_path</code></th>
  <th style="width:11%">Type</th>
  <th>Description</th>
  <th style="width:18%">Columns</th>
</tr>
</thead>
<tbody>
<tr>
  <td rowspan="2">0</td>
  <td>0</td>
  <td>[]perNode</td>
  <td>The shortest cost/distance from the source node to each other node</td>
  <td><code>_uuid</code>, <code>totalCost</code></td>
</tr>
<tr>
  <td>1</td>
  <td>[]perPath</td>
  <td>The shortest path from the source node to each other node, the path is represented by the alternating UUID of nodes and UUID of edges that form the path</td>
  <td>/</td>
</tr>
</tbody>
</table>

```js
algo(sssp).params({
  uuids: 1,
  edge_schema_property: 'value',
  sssp_type: 'spfa',
  record_path: 0,
  direction: 'in'
}) as costs
return costs
```

Results: <i>costs</i>

| \_uuid | totalCost |
| -- | -- |
| 1 | 0 |
| 2 | -2 |
| 4 | 6 |
| 6 | 4 |

```js
algo(sssp).params({
  ids: 'A',
  edge_schema_property: '@default.value',
  sssp_type: 'spfa',
  direction: 'in',
  record_path: 1
}) as paths
return paths
```

Results: <i>paths</i>

<table>
<tr><td>1--[102]--6--[106]--4</td></tr>
<tr><td>1--[102]--6</td></tr>
<tr><td>1</td></tr>
<tr><td>1--[102]--6--[103]--2</td></tr>
</table>

### Stream Return

<table>
<thead>
<tr>
  <th style="width:8%">Alias Ordinal</th>
  <th style="width:15%"><code>record_path</code></th>
  <th style="width:11%">Type</th>
  <th>Description</th>
  <th style="width:18%">Columns</th>
</tr>
</thead>
<tbody>
<tr>
  <td rowspan="2">0</td>
  <td>0</td>
  <td>[]perNode</td>
  <td>The shortest cost/distance from the source node to each other node</td>
  <td><code>_uuid</code>, <code>totalCost</code></td>
</tr>
<tr>
  <td>1</td>
  <td>[]perPath</td>
  <td>The shortest path from the source node to each other node, the path is represented by the alternating UUID of nodes and UUID of edges that form the path</td>
  <td>/</td>
</tr>
</tbody>
</table>

```js
algo(sssp).params({
  ids: 'A',
  edge_schema_property: '@default.value',
  sssp_type: 'spfa',
  direction: 'out'
}).stream() as costs
where costs.totalCost < 0
return costs
```

Results: <i>costs</i>

| \_uuid | totalCost |
| -- | -- |
| 5 | -3 |
| 6 | -4 |

```js
algo(sssp).params({
  ids: 'A',
  edge_schema_property: '@default.value',
  sssp_type: 'spfa',
  direction: 'out',
  record_path: 1
}).stream() as p
where length(p) <> [0,3]
return p
```

Results: <i>p</i>

<table>
<tr><td>1--[101]--2--[104]--3</td></tr>  
<tr><td>1--[101]--2--[105]--4</td></tr>
<tr><td>1--[101]--2</td></tr>
<tr><td>1--[101]--2--[103]--6</td></tr>
