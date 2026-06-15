# Delta-Stepping Single-Source Shortest Path

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The <b>single-source shortest path (SSSP)</b> problem is that of computing, for each node that is reachable from the source node, the shortest path with the minimum total edge weights among all possible paths; or in the case of unweighted graphs, the shortest path with the minimum number of edges. The cost (or distance) of the shortest path is the total edge weights or the number of edges.

The Delta-Stepping algorithm can be viewed as a variant of Dijkstra's algorithm with its potential for parallelism. 

Related material of the algorithm:

- U. Meyer, P.Sanders, <a target="blank" href="https://www.cs.utexas.edu/~pingali/CS395T/2013fa/papers/delta-stepping.pdf">Δ-Stepping: A Parallel Single Source Shortest Path Algorithm</a> (1998)

## Concepts

### Delta-Stepping Single-Source Shortest Path

The Delta-Stepping Single-Source Shortest Path (SSSP) algorithm introduces the concept of "buckets" and performs relaxation operations in a more coarse-grained manner. The algorithm utilizes a positive real number parameter <i>delta (Δ)</i> to achieve the following:

- Maintain an array <i>B</i> of <i>buckets</i> such that <i>B[i]</i> contains nodes whose distance falls within the range <i>[iΔ, (i+1)Δ)</i>. Thus <i>Δ</i> is also called the "step width" or "bucket width".
- Distinguish between <i>light edges</i> with weight ≤ <i>Δ</i> and <i>heavy edges</i> with weight > <i>Δ</i> in the graph. Light-edge nodes are prioritized during <i>relaxation</i> as they have lower weights and are more likely to yield shorter paths.

> The term <i>relaxation</i> refers to the process of updating the distance of a node <i>v</i> that is connected to node <i>u</i> to a potential shorter distance by considering the path through node <i>u</i>. Specifically, the distance of node v is updated to <i>dist(v) = dist(u) + w(u,v)</i>, where <i>w(u,v)</i> is the weight of the edge <i>(u,v)</i>. This update is performed only if the current <i>dist(v)</i> is greater than <i>dist(u) + w(u,v)</i>.<br><br>In the Delta-Stepping SSSP algorithm, the relaxation also includes assigning the relaxed node to the corresponding bucket based on its updated distance value.

Below is the description of the basic Delta-Stepping SSSP algorithm, along with an example to compute the weighted shortest paths in an undirected graph starting from the source node <i>b</i>, and <i>Δ</i> is set to 3:

1\. At the begining of the algorithm, all nodes have the distance as infinity except for the source node as 0. The source node is assigned to bucket <i>B[0]</i>.

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

By dividing the nodes into buckets and processing them in parallel, the Delta-Stepping algorithm can exploit the available computational resources more efficiently, making it suitable for large-scale graphs and parallel computing environments.

## Considerations

- The Delta-Stepping SSSP algorithm is only applicable to graphs with non-negative edge weights. If negative weights are present, the Delta-Stepping SSSP algorithm might produce false results. In this case, a different algorithm like the <a href="/docs/graph-analytics-algorithms/spfa/">SPFA</a> should be used.
- If there are multiple shortest paths exist between two nodes, all of them will be found.
- In disconnected graphs, the algorithm only outputs the shortest paths from the source node to all nodes belonging to the same connected component as the source node.

## Syntax

- Command: `algo(sssp)`
- Parameters:

| <div table-width="15">Name</div> | <div table-width="8">Type</div> | <div table-width="16">Spec</div> | <div table-width="9">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | `_id` / `_uuid` | / | / | No | ID/UUID of the single source node |
| direction | string | `in`, `out` | / | Yes | Direction of the shortest path, ignore the edge direction if not set |
| edge_schema_property | []`@schema?.property` | Numeric type, must LTE	| / | Yes | One or multiple edge properties to be used as edge weights, where the values of multiple properties are summed up; treat the graph as unweighted if not set |
| record_path | int | `0`, `1` | `0` | Yes | `1` to return the shortest paths, `0` to return the shortest distances |
| sssp_type | string | `delta_stepping` | `dijkstra` | No | To run the Delta-Stepping SSSP algorithm, keep it as `delta_stepping` |
| delta | float | >0 | `2` | Yes | The value of delta |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order	| string | `asc`, `desc` | / | Yes | Sort nodes by the shortest distance from the source node |

## Examples

The example graph is as follows:

<div align=center drawio-diagram='6538' drawio-name='draw_a491e2167bcc45ae9b56d15f1625cd49.jpg'><img src="https://img.ultipa.cn/draw/draw_a491e2167bcc45ae9b56d15f1625cd49.jpg?v='1691401614194'"/></div>

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

```uql
algo(sssp).params({
  uuids: 1,
  edge_schema_property: '@default.value',
  sssp_type: 'delta_stepping',
  delta: 2
}).write({
  file: {
    filename: 'costs'
  }
})
```

Results: File <i>costs</i>

<p tit="File"></p>

```
G,8
F,4
E,5
D,5
C,5
B,2
A,0
```

```uql
algo(sssp).params({
  uuids: 1,
  edge_schema_property: '@default.value',
  sssp_type: 'delta_stepping',
  delta: 2,
  record_path: 1
}).write({
  file: {
    filename: 'paths'
  }
})
```

Results: File <i>paths</i>

<p tit="File"></p>

```
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

```uql
algo(sssp).params({
  uuids: 1,
  edge_schema_property: '@default.value',
  sssp_type: 'delta_stepping',
  delta: 2,
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

```uql
algo(sssp).params({
  uuids: 1,
  edge_schema_property: '@default.value',
  direction: 'out',
  record_path: 1,
  sssp_type: 'delta_stepping',
  delta: 2,
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

```uql
algo(sssp).params({
  uuids: 1,
  edge_schema_property: '@default.value',
  sssp_type: 'delta_stepping'
}).stream() as costs
where costs.totalCost <> [0,5]
return costs
```

Results: <i>costs</i>

| \_uuid | totalCost |
| -- | -- |
| 6 | 4 |
| 2 | 2 |

```uql
algo(sssp).params({
  uuids: 1,
  edge_schema_property: '@default.value',
  sssp_type: 'delta_stepping',
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
</table>