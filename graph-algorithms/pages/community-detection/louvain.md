# Louvain

## Overview

The Louvain algorithm is a widely used and and well-regarded method for community detection in graphs. It is named after the location of its authors - Vincent D. Blondel et al. from Université catholique de Louvain in Belgium. The algorithm aims to maximize the modularity of the graph, and it has gained popularity due to its efficiency and the quality of its results.

- V.D. Blondel, J. Guillaume, R. Lambiotte, E. Lefebvre, <a target="_blank" href="http://arxiv.org/pdf/0803.0476.pdf">Fast unfolding of communities in large networks</a> (2008)
- H. Lu, <a target="_blank" href="https://arxiv.org/pdf/1410.1237.pdf">Parallel Heuristics for Scalable Community Detection</a> (2014)

## Concepts

### Modularity

The Louvain algorithm is designed to find partitions that maximize <a href="/docs/graph-algorithms/modularity">modularity</a>, a measure of community partition quality that compares the density of edges within communities to what would be expected in a random graph.

### Louvain

The Louvain algorithm begins with a singleton partition, where each node belongs to its own community. It then proceeds iteratively through multiple passes, each consisting of two distinct phases.

#### First Phase: Modularity Optimization

For each node <i>i</i>, the algorithm considers all its neighbors <i>j</i> and calculates the <b>gain of modularity</b> (ΔQ) that would result from moving <i>i</i> from its current community to the community of <i>j</i>. 

Node <i>i</i> is reassigned to the community that yields the maximum ΔQ, provided that this gain exceeds a predefined positive threshold. If no such gain is found, <i>i</i> remains in its original community. 

<div align=center drawio-diagram='6403' drawio-name="draw_f14c5c57dd3b40a8a46c4c046c32bdb9.jpg"><img src="https://img.ultipa.cn/draw/draw_f14c5c57dd3b40a8a46c4c046c32bdb9.jpg?v='1690363130608'"/></div>

Take the graph above as an example, where nodes belonging to the same community are denoted with the same color. Now, consider node <i>d</i>. The modularity gains from moving it into the community <i>{a,b}</i>, <i>{c}</i>, and <i>{e,f}</i> are:

- ΔQ<sub>d→{a,b}</sub> = Q<sub>{a,b,d}</sub> - (Q<sub>{a,b}</sub> + Q<sub>{d}</sub>) = 52/900
- ΔQ<sub>d→{c}</sub> = Q<sub>{c,d}</sub> - (Q<sub>{c}</sub> + Q<sub>{d}</sub>) = 72/900
- ΔQ<sub>d→{e,f}</sub> = Q<sub>{d,e,f}</sub> - (Q<sub>{e,f}</sub> + Q<sub>{d}</sub>) = 36/900

If ΔQ<sub>d→{c}</sub> exceeds the predefined threshold of ΔQ, node <i>d</i> will be moved to community <i>{c}</i>; otherwise, it remains in its original community.

This process is applied sequentially to all nodes and repeated until no further individual move yields an improvement in modularity, or the maximum loop number is reached, completing the first phase. 

#### Second Phase: Community Aggregation

In the second phase, each community is aggregated into a single node. Each of these aggregated nodes has a self-loop whose weight equals the total weight of intra-community edges. The weight of the edge between any two aggregated nodes corresponds to the sum of the weights of all edges between nodes in the respective original communities.

<div align=center drawio-diagram='6398' drawio-name="draw_0634eed944f244749b84757c76f13d57.jpg"><img src="https://img.ultipa.cn/draw/draw_0634eed944f244749b84757c76f13d57.jpg?v='1691655640565'"/></div>

Community aggregation reduces the number of nodes and edges in the graph without altering local or global edge weights. After this compression, nodes within a community are treated as a single unit, allowing modularity optimization to continue at a higher level. This results in a hierarchical (iterative), multi-level community structure.

Once this second phase is completed, the algorithm applies another pass on the aggregated graph. hese passes repeat iteratively until no further modularity gains can be achieved, at which point the final community structure is established.

## Considerations

- If node i has any self-loop, when calculating k<sub>i</sub>, the weight of self-loop is counted only once.
- The Louvain algorithm treats all edges as undirected, ignoring their original direction.
- The output of the Louvain algorithm may vary across executions due to the order in which nodes are processed. However, this variation typically has little impact on the final modularity value.

## Example Graph

<div align=center drawio-diagram='20030' drawio-name='draw_60a63ca3c6df4dac9f7ffe19ee2519f3.jpg'><img src="https://img.ultipa.cn/draw/draw_60a63ca3c6df4dac9f7ffe19ee2519f3.jpg?v='1735530968114'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

```gql
ALTER EDGE default ADD PROPERTY {
    weight float
};
INSERT (A:default {_id: "A"}),
       (B:default {_id: "B"}),
       (C:default {_id: "C"}),
       (D:default {_id: "D"}),
       (E:default {_id: "E"}),
       (F:default {_id: "F"}),
       (G:default {_id: "G"}),
       (H:default {_id: "H"}),
       (I:default {_id: "I"}),
       (J:default {_id: "J"}),
       (K:default {_id: "K"}),
       (L:default {_id: "L"}),
       (M:default {_id: "M"}),
       (N:default {_id: "N"}),
       (A)-[:default {weight: 1}]->(B),
       (A)-[:default {weight: 1.7}]->(C),
       (A)-[:default {weight: 0.6}]->(D),
       (A)-[:default {weight: 1}]->(E),
       (B)-[:default {weight: 3}]->(G),
       (F)-[:default {weight: 1.6}]->(A),
       (F)-[:default {weight: 0.3}]->(H),
       (F)-[:default {weight: 2}]->(J),
       (F)-[:default {weight: 0.5}]->(K),
       (G)-[:default {weight: 2}]->(F),
       (I)-[:default {weight: 1}]->(F),
       (K)-[:default {weight: 0.3}]->(A),
       (K)-[:default {weight: 0.8}]->(L),
       (K)-[:default {weight: 1.2}]->(M),
       (K)-[:default {weight: 2}]->(N);
```

## Parameters

Algorithm name: `louvain`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `phase1_loop_num` | Integer | ≥1 | `5` | Yes | The maximum number of loops in the first phase during each pass. |
| `min_modularity_increase` | Float | [0,1] | `0.01` | Yes | The minimum gain of modularity (ΔQ) to move a node to another community. |
| `edge_schema_property` | []"`<@schema.?><property>`" | / | / | Yes | Numeric edge properties used as weights, summing values across the specified properties; edges without this property are ignored. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results.|
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `count`; this option is only valid in <a href="#Stream-Return">Stream Return</a> when `mode` is set to `2`. |

## File Writeback

This algorithm can generate three files:

| <div table-width="18">Spec</div> | Content |
| --- | --- |
| `filename_community_id` | <ul><li>`_id`/`_uuid`: The node.</li><li>`community_id`: ID of the community the node belongs to.</li></ul> |
| `filename_ids` | <ul><li>`community_id`: ID of the community.</li><li>`_ids`/`_uuids`: Nodes belonging to the community.</li></ul> |
| `filename_num` | <ul><li>`community_id`: ID of the community.</li><li>`count`: Number of nodes in the community.</li></ul> |

  
```gql
CALL algo.louvain.write("my_hdc_graph", {
  return_id_uuid: "id",
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1,
  edge_schema_property: 'weight'
}, {
  file: {
    filename_community_id: "f1",
    filename_ids: "f2",
    filename_num: "f3"
  }
})
```

Result:

  
<p tit="File: f1"></p>

```  
_id,community_id
I,5
G,7
J,5
D,13
N,11
F,5
H,5
B,7
L,11
A,13
E,13
K,11
M,11
C,13
```

<p tit="File: f2"></p>
```
community_id,_ids
13,D;A;E;C;
5,I;J;F;H;
7,G;B;
11,N;L;K;M;
```

<p tit="File: f3"></p>
```
community_id,count
13,4
5,4
7,2
11,4
```
  
</div>

## DB Writeback

Writes the `community_id` values from the results to the specified node property. The property type is `uint32`.

  
```gql
CALL algo.louvain.write("my_hdc_graph", {
  return_id_uuid: "id",
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1,
  edge_schema_property: 'weight'
}, {
  db: {
    property: "communityID"
  }
})
```

## Stats Writeback

```gql
CALL algo.louvain.write("my_hdc_graph", {
  return_id_uuid: "id",
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1,
  edge_schema_property: 'weight'
}, {
  stats: {}
})
```

Result:

| community_count | modularity |
| -- | -- |
| 4 | 0.464280 |

## Full Return

```gql
CALL algo.louvain.run("my_hdc_graph", {
  return_id_uuid: "id",
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1
}) YIELD r
RETURN r
```

Result: 

| \_id | community_id |
| -- | -- |
| I | 5 |
| G | 7 |
| J | 5 |
| D | 9 |
| N | 11 |
| F | 5 |
| H | 5 |
| B | 7 |
| L | 11 |
| A | 9 |
| E | 9 |
| K | 11 |
| M | 11 |
| C | 9 |

## Stream Return

This Stream Return supports two modes:

<table>
<thead>
<tr>
<th style="width:10%;">Item</th>
<th style="width:10%;">Spec</th>
<th>Columns</th>
</tr>
</thead>
<tbody>
<tr>
<td rowspan="2"><code>mode</code></td>
<td><code>1</code> (Default)</td>
<td><ul><li><code>_id</code>/<code>_uuid</code>: The node.</li><li><code>community_id</code>: ID of the community the node belongs to.</li></ul></td>
</tr>
<tr>
<td><code>2</code></td>
<td><ul><li><code>community_id</code>: ID of the community.</li><li><code>count</code>: Number of nodes in the community.</li></ul></td>
</tr>
</tbody>
</table>

  
```gql
CALL algo.louvain.stream("my_hdc_graph", {
  return_id_uuid: "id",
  phase1_loop_num: 6, 
  min_modularity_increase: 0.1
}) YIELD r
RETURN r
```

Result:

| \_id | community_id |
| -- | -- |
| I | 5 |
| G | 7 |
| J | 5 |
| D | 9 |
| N | 11 |
| F | 5 |
| H | 5 |
| B | 7 |
| L | 11 |
| A | 9 |
| E | 9 |
| K | 11 |
| M | 11 |
| C | 9 |

  
```gql
CALL algo.louvain.stream("my_hdc_graph", {
  return_id_uuid: "id",
  phase1_loop_num: 6, 
  min_modularity_increase: 0.1,
  order: "asc"
}, {
  mode: 2
}) YIELD r
RETURN r
```
  

</div>

Result:

| community_id | count |
| -- | -- |
| 7 | 2 |
| 5 | 4 |
| 9 | 4 |
| 11 | 4 |

## Stats Return

  
```gql
CALL algo.louvain.stats("my_hdc_graph", {
  return_id_uuid: "id",
  phase1_loop_num: 6, 
  min_modularity_increase: 0.1
}) YIELD s
RETURN s
```

Result:

| community_count | modularity |
| -- | -- |
| 4 | 0.397778 |

## Algorithm Efficiency

The Louvain algorithm achieves lower time complexity than previous community detection algorithms through its improved greedy optimization, which is usually regarded as <i>O(N*logN)</i>, where <i>N</i> is the number of nodes in the graph, and the result is more intuitive. For instance, in a graph with 10,000 nodes, the complexity of the Louvain algorithm is around <i>O(40000)</i>; in a connected graph with 100 million nodes, the algorithm complexity is around <i>O(800000000)</i>. 

However, upon closer inspection of the algorithm process breakdown, we can see that the complexity of the Louvain algorithm depends not only on the number of nodes but also on the number of edges. Roughly speaking, it can be approximated as <i>O(N * E/N) = O(E)</i>, where <i>E</i> is the number of edges in the graph. This is because the dominant algorithm logic of Louvain is to calculate the weights of edges attached to each node.

The table below shows the performance of the community detection algorithms of Clauset, Newman and Moore, of Pons and Latapy, of Wakita and Tsurumi, and Louvain, in networks of various sizes. For each algorithm/network, it gives the modularity that is gained and the computation time. Empty record indicates a computation time that is over 24 hours. It clearly demonstrates that Louvain achieves a significant (exponential) increase in both modularity and efficiency.

<center><img  src="https://img.ultipa.cn/2021-12-31-15-52-53-louvain-comlexity.png"/></center>

The choice of system architecture and programming language can significantly impact the efficiency and final results of the Louvain algorithm. For example, a serial implementation of the Louvain algorithm in Python may result in hours of computation time for small graphs with around 10,000 nodes. Additionally, the data structure used can influence performance, as the algorithm frequently calculates node degrees and edge weights. 

The native Louvain algorithm adopts C++, but it is a serial implementation. The time consumption can be reduced by using parallel computation as much as possible, thereby improving the efficiency of the algorithm.

For medium-sized graphset with tens of millions of nodes and edges, Ultipa's Louvain algorithm can be completed literally in real time. For large graphs with over 100 million nodes and edges, it can be implemented in seconds to minutes. Furthermore, the efficiency of the Louvain algorithm can be affected by other factors, such as whether data is written back to the database property or disk file. These operations can impact the overall computation time of the algorithm.

<center><img src="https://img.ultipa.cn/2022-09-05-09-32-59-louvain-execution-time.png"/></center>

This is the records of the modularity and execution time of the Louvain algorithm running on a graph with 5 million nodes and 100 million edges. The computation process takes approximately 1 minute, and additional operations, such as writing back to the database or generating a disk file, add around 1 minute to the total execution time.
