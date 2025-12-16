# Dijkstra's Single-Source Shortest Path

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The <b>single-source shortest path (SSSP)</b> problem is that of computing, for each node that is reachable from the source node, the shortest path with the minimum total edge weights among all possible paths; or in the case of unweighted graphs, the shortest path with the minimum number of edges. The cost (or distance) of the shortest path is the total edge weights or the number of edges.

The original Dijkstra's algorithm was conceived by Dutch computer scientist Edsger W. Dijkstra in 1956 to find the shortest path between two given nodes. Single-source shortest path is a common variant, facilitating effective path planning and network analysis.

## Concepts

### Dijkstra's Single-Source Shortest Path

Below is the basic implementation of the Dijkstra's Single-Source Shortest Path algorithm, along with an example to compute the weighted shortest paths in an undirected graph starting from the source node <i>b</i>:

1\. Create a priority queue to store nodes and their corresponding distances from the source node. Initialize the distance of the source node as 0 and the distances of all other nodes as infinity. All node are marked as unvisited.

<div align=center drawio-diagram='6315' drawio-name="draw_4571683ba8384a1f966b9c8aedc12f2b.jpg"><img src="https://img.ultipa.cn/draw/draw_4571683ba8384a1f966b9c8aedc12f2b.jpg?v='1689215708126'"/></div>

2\. Extract the node with the minimum distance from the queue and mark it as visited, relax all its <i>unvisited</i> neighbors.

<div align=center drawio-diagram='6318' drawio-name="draw_f48205a154934dc7bee0a7a74a929206.jpg"><img src="https://img.ultipa.cn/draw/draw_f48205a154934dc7bee0a7a74a929206.jpg?v='1689215747833'"/></div>

<center><span style="color: #82B366">Visit node <i>b</i>:<br>dist(a) = min(0+2,∞) = 2, dist(c) = min(0+1,∞) = 1</span></center><br>

> The term <i>relaxation</i> refers to the process of updating the distance of a node <i>v</i> that is connected to node <i>u</i> to a potential shorter distance by considering the path through node <i>u</i>. Specifically, the distance of node v is updated to <i>dist(v) = dist(u) + w(u,v)</i>, where <i>w(u,v)</i> is the weight of the edge <i>(u,v)</i>. This update is performed only if the current <i>dist(v)</i> is greater than <i>dist(u) + w(u,v)</i>.
  
> Once a node has been marked as visited, its shortest path has been fixed and its distance will not change during the rest of the algorithm. The algorithm only updates the distances of node that have not been visited yet.

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

- The Dijkstra's algorithm is only applicable to graphs with non-negative edge weights. If negative weights are present, the Dijkstra's algorithm might produce false results. In this case, a different algorithm like the <a href="https://www.ultipa.com/document/ultipa-graph-analytics-algorithms/spfa/">SPFA</a> should be used.
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
| sssp_type | string | `dijkstra` | `dijkstra` | Yes | To run the Dijkstra's SSSP algorithm, keep it as `dijkstra` |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order	| string | `asc`, `desc` | / | Yes | Sort nodes by the shortest distance from the source node |

## Examples

The example graph is as follows:

<div align=center drawio-diagram='6536' drawio-name="draw_5428a498201d400ba015e05b2f4235f0.jpg"><img src="https://img.ultipa.cn/draw/draw_5428a498201d400ba015e05b2f4235f0.jpg?v='1691395226766'"/></div>

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
  edge_schema_property: '@default.value'
}).write({
  file: {
    filename: 'costs'
  }
})
```

Results: File <i>costs</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
G,8
F,4
E,5
D,5
C,5
B,2
A,0
```

```js
algo(sssp).params({
  uuids: 1,
  edge_schema_property: '@default.value',
  sssp_type: 'dijkstra',
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
A--[102]--F--[107]--E--[109]--G
A--[102]--F--[107]--E
A--[101]--B--[105]--D
A--[101]--B--[104]--C
A--[102]--F
A--[101]--B
A
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
  edge_schema_property: '@default.value',
  sssp_type: 'dijkstra',
  record_path: 0,
  order: 'desc'
}) as costs
return costs
```

Results: <i>costs</i>

| \_uuid | totalCost |
| -- | -- |
| 7 | 8 |
| 5 | 5 |
| 4 | 5 |
| 3 | 5 |
| 6 | 4 |
| 2 | 2 |
| 1 | 0 |

```js
algo(sssp).params({
  ids: 'A',
  edge_schema_property: '@default.value',
  direction: 'out',
  record_path: 1, 
  order: 'asc'
}) as paths
return paths
```

Results: <i>paths</i>

<table>
<tr><td>1</td></tr>
<tr><td>1--[101]--2</td></tr>
<tr><td>1--[102]--6</td></tr>
<tr><td>1--[102]--6--[107]--5</td></tr>
<tr><td>1--[101]--2--[105]--4</td></tr>
<tr><td>1--[101]--2--[104]--3</td></tr>
<tr><td>1--[102]--6--[107]--5--[109]--7</td></tr>
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
  uuids: 1,
  edge_schema_property: '@default.value',
  sssp_type: 'dijkstra'
}).stream() as costs
where costs.totalCost <> [0,5]
return costs
```

Results: <i>costs</i>

| \_uuid | totalCost |
| -- | -- |
| 6 | 4 |
| 2 | 2 |

```js
algo(sssp).params({
  ids: 'A',
  edge_schema_property: '@default.value',
  record_path: 1
}).stream() as p
where length(p) <> [0,3]
return p
```

Results: <i>p</i>

<table>
<tr><td>1--[102]--6--[107]--5</td></tr>  
<tr><td>1--[101]--2--[105]--4</td></tr>
<tr><td>1--[101]--2--[104]--3</td></tr>
<tr><td>1--[102]--6</td></tr>
<tr><td>1--[101]--2</td></tr>
