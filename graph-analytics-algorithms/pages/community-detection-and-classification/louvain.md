# Louvain

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stats</b></span></div>

## Overview

The Louvain algorithm is a widely recognized and extensively used algorithm for community detection in graphs. It is named after the location of its authors - Vincent D. Blondel et al. from Université catholique de Louvain in Belgium. The primary objective of the algorithm is to maximize the modularity of the graph, and it has gained popularity due to its high efficiency and the quality of its results.

- V.D. Blondel, J. Guillaume, R. Lambiotte, E. Lefebvre, <a target="_balnk" href="http://arxiv.org/pdf/0803.0476.pdf">Fast unfolding of communities in large networks</a> (2008)
- H. Lu, <a target="_balnk" href="https://arxiv.org/pdf/1410.1237.pdf">Parallel Heuristics for Scalable Community Detection</a> (2014)

## Concepts

### Modularity

In many networks, nodes tend to naturally form groups or communities, characterized by dense connections within a community and relatively sparse connections between communities.

<div align=center drawio-diagram='6559' drawio-name="draw_0f7319e906674632bbfb4dae19225594.jpg"><img src="https://img.ultipa.cn/draw/draw_0f7319e906674632bbfb4dae19225594.jpg?v='1691570533516'"/></div>

Consider an equivalent network G' to G, where G' remains the same community partition and the same number of edges as in G, but the edges are placed randomly. If G exhibits a good community structure, the ratio of intra-community edges to the total number of edges in G should be higher than the expected ratio in G'. A larger disparity between the actual ratio and the expected value indicates a more pronounced presence of a community structure in G. This forms the original concept of <b>modularity</b>. The modularity is one of the widely used methods to evaluate the quality of a community partition, the Louvain algorithm is designed to find partitions that maximize the modularity.

The modularity ranges from -1 to 1. A value close to 1 indicates a stronger community structure, while negative values suggest that the partition is not meaningful. For a connected graph, the modularity value ranges from -0.5 to 1. 

Considering the weights of edges in the graph, the modularity (Q) is defined as

<center><img width=320 src="https://img.ultipa.cn/2021-12-23-14-37-47-louvain.png"></center>

where,

- m is the total sum of edge weights in the graph;
- A<sub>ij</sub> is the sum of edge weights between nodes i and j, and 2m = ∑<sub>ij</sub>A<sub>ij</sub>;
- k<sub>i</sub> is the sum of weights of all edges attached to node i;
- C<sub>i</sub> represents the community to which node iis assigned, δ(C<sub>i</sub>,C<sub>j</sub>) is 1 if C<sub>i</sub>= C<sub>j</sub>, and 0 otherwise.

Note, <math><mfrac><mn><math><msub><mi>k</mi><mn>i</mn></msub><msub><mi>k</mi><mn>j</mn></msub></math></mn><mi>2m</mi></mfrac></math> is the expected sum of weights of edges between nodes i and j if edges are placed at random. Both A<sub>ij</sub> and <math><mfrac><mn><math><msub><mi>k</mi><mn>i</mn></msub><msub><mi>k</mi><mn>j</mn></msub></math></mn><mi>2m</mi></mfrac></math> are divided by 2m because each pair of distinct nodes in a community is considered twice, such as A<sub>ab</sub> = A<sub>ba</sub>, <math><mfrac><mn><math><msub><mi>k</mi><mn>a</mn></msub><msub><mi>k</mi><mn>b</mn></msub></math></mn><mi>2m</mi></mfrac></math> = <math><mfrac><mn><math><msub><mi>k</mi><mn>b</mn></msub><msub><mi>k</mi><mn>a</mn></msub></math></mn><mi>2m</mi></mfrac></math>.

We can also write the above formula as the following:

<center><img width=260 src="https://img.ultipa.cn/2021-12-23-14-38-05-louvain2.png"></center>

where,

- <math><mmultiscripts><mi>∑</mi><mi>in</mi><mi>c</mi></mmultiscripts></math> is the sum of weights of edges inside community <i>C</i>, i.e., the <b>intra-community weight</b>;
- <math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi>c</mi></mmultiscripts></math> is the sum of weights of edges incident to nodes in community <i>C</i>, i.e, the <b>total-community weight</b>;
- m has the same meaning as above, and 2m = ∑<sub>c</sub><math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi>c</mi></mmultiscripts></math>.

<div align=center drawio-diagram='6395' drawio-name="draw_2eb6fd4262954600a29f652213a6ee09.jpg"><img src="https://img.ultipa.cn/draw/draw_2eb6fd4262954600a29f652213a6ee09.jpg?v='1690360083168'"/></div>

Nodes in this graph are assigned into 3 communities, take community C<sub>1</sub> as example:

- <math><mmultiscripts><mi>∑</mi><mi>in</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> = A<sub>aa</sub> + A<sub>ab</sub> + A<sub>ac</sub> + A<sub>ad</sub> + A<sub>ba</sub> + A<sub>ca</sub> + A<sub>da</sub> = 1.5 + 1 + 0.5 + 3 + 1 + 0.5 + 3 = 10.5
- (<math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math>)<sup>2</sup> = k<sub>a</sub>k<sub>a</sub> + k<sub>a</sub>k<sub>b</sub> + k<sub>a</sub>k<sub>c</sub> + k<sub>a</sub>k<sub>d</sub> + k<sub>b</sub>k<sub>a</sub> + k<sub>b</sub>k<sub>b</sub> + k<sub>b</sub>k<sub>c</sub> + k<sub>b</sub>k<sub>d</sub> + k<sub>c</sub>k<sub>a</sub> + k<sub>c</sub>k<sub>b</sub> + k<sub>c</sub>k<sub>c</sub> + k<sub>c</sub>k<sub>d</sub> + k<sub>d</sub>k<sub>a</sub> + k<sub>d</sub>k<sub>b</sub> + k<sub>d</sub>k<sub>c</sub> + k<sub>d</sub>k<sub>d</sub> + = (k<sub>a</sub> + k<sub>b</sub> + k<sub>c</sub> + k<sub>d</sub>)<sup>2</sup> = (6 + 2.7 + 2.8 + 3)<sup>2</sup> = 14.5<sup>2</sup>

### Louvain

The Louvain algorithm starts from a singleton partition, in which each node is in its own community. Then algorithm iteratively runs through passes, and each pass is made of two phases.

#### First Phase: Modularity Optimization

For each node <i>i</i>, consider its neighbors <i>j</i> of <i>i</i>, compute the <b>gain of modularity</b> (ΔQ) that would take place by reassigning <i>i</i> from its current community to the community of <i>j</i>. 

Node <i>i</i> is then placed in the community that offers the maximum ΔQ, but only if ΔQ is greater than a predefined positive threshold. If no such gain is possible, node <i>i</i> stays in its original community. 

<div align=center drawio-diagram='6403' drawio-name="draw_f14c5c57dd3b40a8a46c4c046c32bdb9.jpg"><img src="https://img.ultipa.cn/draw/draw_f14c5c57dd3b40a8a46c4c046c32bdb9.jpg?v='1690363130608'"/></div>

Take the above graph as example, nodes in the same community are denoted in the same color. If now considers node <i>d</i>, the respective gains of modularity of moving it to the community <i>{a,b}</i>, <i>{c}</i>, and <i>{e,f}</i> are:

- ΔQ<sub>d→{a,b}</sub> = Q<sub>{a,b,d}</sub> - (Q<sub>{a,b}</sub> + Q<sub>{d}</sub>) = 52/900
- ΔQ<sub>d→{c}</sub> = Q<sub>{c,d}</sub> - (Q<sub>{c}</sub> + Q<sub>{d}</sub>) = 72/900
- ΔQ<sub>d→{e,f}</sub> = Q<sub>{d,e,f}</sub> - (Q<sub>{e,f}</sub> + Q<sub>{d}</sub>) = 36/900

If ΔQ<sub>d→{c}</sub> is greater than the predefined threshold of ΔQ, node <i>d</i> will be moved to community <i>{c}</i>, otherwise it stays in its original community.

This process is sequentially applied for all nodes and repeated until no individual move can improve the modularity or the maximum loop number is reached, completing the first phase. 

#### Second Phase: Community Aggregation

In the second phase, each community is aggregated into a node, each aggregated node has a self-loop with weight corresponds to the intra-community weight. The weights of edges between these new nodes are given by the sum of weights of the edges between nodes in the corresponding two communities.

<div align=center drawio-diagram='6398' drawio-name="draw_0634eed944f244749b84757c76f13d57.jpg"><img src="https://img.ultipa.cn/draw/draw_0634eed944f244749b84757c76f13d57.jpg?v='1691655640565'"/></div>

Community aggregation reduces the number of nodes and edges in the graph without altering the weight of the local or the entire graph. After compression, nodes within a community are treated as a whole, but they are no longer isolated for modularity optimization, achieving a hierarchical (iterative) community division effect.

Once this second phase is completed, another pass is applied to the aggregate graph. The passes are iterated until there are no more changes, and a maximum modularity is attained.

## Considerations

- If node i has any self-loop, when calculating k<sub>i</sub>, the weight of self-loop is counted only once.
- The Louvain algorithm ignores the direction of edges but calculates them as undirected edges. 
- The output of the Louvain algorithm may vary with each execution, depending on the order in which the nodes are considered. However, it does not have a significant influence on the modularity that is obtained.

## Syntax

- Command: `algo(louvain)`
- Parameters:

| <div table-width="23">Name</div> | <div table-width="7">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| phase1_loop_num | int | ≥1 | `5` | Yes | The maximum loop number of the first phase during each pass |
| min_modularity_increase | float | [0,1] | `0.01` | Yes | The minimum gain of modularity (ΔQ) to move a node to another community |
| edge_schema_property | []`@<schema>?.<property>` | Numeric type, must LTE | / | Yes | Edge properties to use as weights, where the values of multiple properties are summed up; all edge weights are considered as 1 if not set |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order | string | `asc`, `desc` | / | Yes | Sort communities by the number of nodes in it (only valid in mode 2 of the `stream()` execution) |

## Examples

The example graph is as follows:

<div align=center drawio-diagram='6399' drawio-name="draw_35e2c0a29dfc4830a9e29992b0e68957.jpg"><img src="https://img.ultipa.cn/draw/draw_35e2c0a29dfc4830a9e29992b0e68957.jpg?v='1690257105974'"/></div>

### File Writeback

| Spec | Content | Description |
| --- | --- | --- |
| filename_community_id | `_id`,`community_id` | Node and its community ID |
| filename_ids | `community_id`,`_id`,`_id`,... | Community ID and the ID of nodes in it |
| filename_num | `community_id`,`count` | Community ID and the number of nodes in it |

```uql
algo(louvain).params({ 
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1,
  edge_schema_property: 'weight'
}).write({
  file:{
    filename_community_id: 'communityID',
    filename_ids: 'ids',
    filename_num: 'num'
  }
})
```

Statistics: community_count = 4, modularity = 0.464280<br>
Results: Files <i>communityID</i>, <i>ids</i>, <i>num</i>

<p tit="File: communityID"></p>

```uql
M,2
N,2
K,2
L,2
J,8
I,8
G,13
H,8
F,8
C,12
E,12
D,12
A,12
B,13
```

<p tit="File: ids"></p>

```uql
8,J,I,H,F,
12,C,E,D,A,
2,M,N,K,L,
13,G,B,
```

<p tit="File: num"></p>

```uql
8,4
12,4
2,4
13,2
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `community_id` | Node property | `uint32` |

```uql
algo(louvain).params({ 
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1,
  edge_schema_property: 'weight'
}).write({
  db:{
    property: 'communityID'
  }
})
```

Statistics: community_count = 4, modularity = 0.464280<br>
Results: The community ID of each node is written to a new property named <i>communityID</i>

### Direct Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="12">Type</div> | Description | <div table-width="25">Columns</div> |
| --- | --- | --- | --- |
| 0 | []perNode	| Node and its community ID	| `_uuid`, `community_id` |
| 1 | KV | Number of communities, modularity | `community_count`, `modularity` |

```uql
algo(louvain).params({ 
  phase1_loop_num: 6, 
  min_modularity_increase: 0.5,
  edge_schema_property: 'weight'
}) as results, stats
return results, stats
```

Results: <i>results</i> and <i>stats</i>

| \_uuid | community_id |
| -- | -- |
| 13 | 2 |
| 14 | 2 |
| 11 | 2 |
| 12 | 2 |
| 10 | 8 |
| 9 | 8 |
| 7 | 13 |
| 8 | 8 |
| 6 | 8 |
| 3 | 12 |
| 5 | 12 |
| 4 | 12 |
| 1 | 12 |
| 2 | 13 |

| community_count | modularity |
| -- | -- |
| 4 | 0.46428 |

### Stream Return

<table>
<thead>
<tr>
<th style="width: 6%;">Spec</th>
<th style="width: 10%;">Content</th>
<th style="width: 8%">Alias Ordinal</th>
<th style="width: 17%;">Type</th>
<th>Description</th>
<th>Columns</th>
</tr>
</thead>
<tbody>
<tr>
<td rowspan="2">mode</td>
<td><code>1</code> or if not set</td>
<td rowspan="2">0</td>
<td>[]perNode</td>
<td>Node and its community ID</td>
<td><code>_uuid</code>, <code>community_id</code></td>
</tr>
<tr>
<td><code>2</code></td>
<td>[]perCommunity</td>
<td>Community and the number of nodes in it</td>
<td><code>community_id</code>, <code>count</code></td>
</tr>
</tbody>
</table>

```uql
algo(louvain).params({ 
  phase1_loop_num: 6, 
  min_modularity_increase: 0.5,
  edge_schema_property: 'weight'
}).stream() as results
group by results.community_id
return table(results.community_id, max(results._uuid))
```

Results: <i>table(results.community_id, max(results._uuid))</i>

| results.community_id | max(results.\_uuid) |
| -- | -- |
| 12 | 5 |
| 13 | 7 |
| 2 | 14 |
| 8 | 10 |

```uql
algo(louvain).params({ 
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1,
  order: "desc"
}).stream({
  mode: 2
}) as results
return results
```

Results: <i>results</i>

| community_id | count |
| -- | -- |
| 8 | 4 |
| 12 | 4 |
| 2 | 4 |
| 13 | 2 |

### Stats Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="12">Type</div> | Description | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | KV | Number of communities, modularity | `community_count`, `modularity` |

```uql
algo(louvain).params({ 
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1
}).stats() as stats
return stats
```

Results: <i>stats</i>

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