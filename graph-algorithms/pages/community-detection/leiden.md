# Leiden

## Overview

The Leiden algorithm is a community detection method designed to optimize modularity while addressing some of the limitations of the widely used <a target="_blank" href="/docs/graph-analytics-algorithms/louvain">Louvain</a> algorithm. Unlike Louvain, which may produce poorly connected or even disconnected communities, Leiden guarantees well-connected communities. Additionally, the Leiden algorithm is faster. It is named after the city of Leiden, where it was developed.

References:

- V.A. Traag, L. Waltman, N.J. van Eck, <a target="balnk" href="https://arxiv.org/pdf/1810.08473.pdf">From Louvain to Leiden: guaranteeing well-connected communities</a> (2019)
- V.A. Traag, P. Van Dooren, Y. Nesterov, <a target="_blank" href="https://arxiv.org/pdf/1104.3083v1.pdf">Narrow scope for resolution-limit-free community detection</a> (2011)

## Concepts

### Modularity

The Leiden algorithm optimizes <a href="/docs/graph-algorithms/modularity">modularity</a> with an additional **resolution parameter** `γ` (gamma):

<center><img width=330 src="https://img.ultipa.cn/img/2023-08-10-14-17-41-leiden-modularity.jpg" /></center>

The parameter `γ` controls the granularity of the detected communities by modulating the balance between intra-community and inter-community connections:

- When `γ` > 1, the algorithm favors more and smaller communities that are tightly connected internally.
- When 0 < `γ` < 1, it favors fewer and larger communities that may be less densely connected internally.

### Leiden

When the Leiden algorithm starts, each node is placed in its own community. The algorithm then iteratively proceeds through passes, each consisting of three phases:

#### First Phase: Fast Modularity Optimization

In the first phase of <a target="_blank" href="/docs/graph-analytics-algorithms/louvain">Louvain</a>, the algorithm repeatedly visits all nodes in the graph until no further node movements can increase the modularity. The Leiden algorithm improves efficiency by only visiting all nodes once initially, and afterwards, only revisiting nodes whose neighborhoods have changed. 

To achieve this, the Leiden algorithm maintains a queue, initializes it with all nodes in the graph in a random order, then repeats the following steps until the queue is empty:

- Remove the first node `v` from the front of the queue. 
- Reassign node `v` to a different community `C` that provides the maximum gain of modularity (`ΔQ`), or keep `v` in its current community if there is no positive gain. 
- If `v` is moved to a new community `C`, add to the rear of the queue all neighbors of `v` that do not belong to `C` and that are not already in the queue. 

#### Second Phase: Refinement

This phase produces a refined partition <code>P<sub>refined</sub></code> based on the partition `P` obtained from the first phase. Initially, <code>P<sub>refined</sub></code> is set as a singleton partition, where each node—either from the original graph or the aggregated graph—is placed in its own community. Then, each community `C ∈ P` is refined individually as follows:

1\. Find each node `v ∈ C` that is well-connected within `C` by this formula:

<center><img width=310 src="https://img.ultipa.cn/img/2023-08-10-18-34-20-well1.jpg" /></center>

where,

- `W(v,C-v)` is the sum of edge weights between node `v` and the other nodes in `C`.
- <code>k<sub>v</sub></code> is the total edge weights between node `v` and the other nodes in the graph.
- <code><math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi>c</mi></mmultiscripts></math></code> is the sum of `k` of all nodes in `C`.
- `m` is the sum of all edge weights in the graph.

<div align=center drawio-diagram='6395' drawio-name="draw_2eb6fd4262954600a29f652213a6ee09.jpg"><img src="https://img.ultipa.cn/draw/draw_2eb6fd4262954600a29f652213a6ee09.jpg?v='1690360083168'"/></div>

Take community <code>C<sub>1</sub></code> in the graph above as an example, where 

- m = 18.1
- <math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> = k<sub>a</sub> + k<sub>b</sub> + k<sub>c</sub> + k<sub>d</sub> = 6 + 2.7 + 2.8 + 3 = 14.5

Set `γ` as 1.2, then:

- W(a, C<sub>1</sub>) - γ/m ⋅ k<sub>a</sub> ⋅ (<math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> - k<sub>a</sub>) = 4.5 - 1.2/18.1\*6\*(14.5 - 6) = 1.12
- W(b, C<sub>1</sub>) - γ/m ⋅ k<sub>b</sub> ⋅ (<math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> - k<sub>b</sub>) = 1 - 1.2/18.1\*2.7\*(14.5 - 2.7) = -1.11
- W(c, C<sub>1</sub>) - γ/m ⋅ k<sub>c</sub> ⋅ (<math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> - k<sub>c</sub>) = 0.5 - 1.2/18.1\*2.8\*(14.5 - 2.8) = -1.67
- W(d, C<sub>1</sub>) - γ/m ⋅ k<sub>d</sub> ⋅ (<math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> - k<sub>d</sub>) = 3 - 1.2/18.1\*3\*(14.5 - 3) = 0.71

Therefore, nodes `a` and `d` are considered well-connected in <code>C<sub>1</sub></code>.

2\. Visit each node `v`. If it remains in its own singleton community in <code>P<sub>refined</sub></code>, randomly merge it into a community <code>C' ∈ P<sub>refined</sub></code> that increases the modularity. The merge is allowed only if `C'` is well-connected with `C`, determined by the following condition:

<center><img width=320 src="https://img.ultipa.cn/img/2023-08-10-18-39-30-well2.jpg" /></center>

Note that each node `v` is not necessarily merged greedily with the community that yields the maximum gain of modularity. Instead, the larger the modularity gain, the more likely that community is to be selected. The degree of randomness in selecting a community `C'` is determined by a parameter `θ` (theta) as: 

<center><img width=270 src="https://img.ultipa.cn/img/2023-07-27-14-31-33-theta.jpg" /></center>

Randomness in the selection of a community allows the partition space to be explored more broadly.

#### Third Phase: Community Aggregation

The aggregate graph is constructed based on the <code>P<sub>refined</sub></code> obtained from the previous phase. This aggregation process is the same as in <a target="_blank" href="/docs/graph-analytics-algorithms/louvain">Louvain</a>. Note that each node is a single community in the aggregate graph in Louvain. However, the aggregate graph in Leiden is partitioned based on `P`, so multiple nodes may belong to the same community.

<div align=center drawio-diagram='6566' drawio-name="draw_6f703198f7754ec4bcebd6168a3f9068.jpg"><img src="https://img.ultipa.cn/draw/draw_6f703198f7754ec4bcebd6168a3f9068.jpg?v='1691655725180'"/></div>
<center><code>P</code> is denoted by color blocks, <code>P<sub>refined</sub></code> is denoted by node colors</center><br>

Once this third phase is completed, another pass is applied to the aggregate graph. These passes are iterated until no further changes occur in the node communities, and the modularity reaches its maximum.

## Considerations

- If node `v` has any self-loop, when calculating <code>k<sub>v</sub></code>, the weight of self-loop is counted only once.
- The Leiden algorithm treats all edges as undirected, ignoring their original direction.

## Example Graph

<div align=center drawio-diagram='20033' drawio-name='draw_a70aa6018fab4b9c973d0e84b6e487ed.jpg'><img src="https://img.ultipa.cn/draw/draw_a70aa6018fab4b9c973d0e84b6e487ed.jpg?v='1735542565235'"/></div>

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

Algorithm name: `leiden`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `phase1_loop_num` | Integer | ≥1 | `5` | Yes | The maximum number of loops in the first phase during each pass. |
| `min_modularity_increase` | Float | [0,1] | `0.01` | Yes | The minimum gain of modularity (`ΔQ`) to move a node to another community. |
| `edge_schema_property` | []"`<@schema.?><property>`" | / | / | Yes | Specifies numeric edge properties used as weights by summing their values. Only properties of numeric type are considered, and edges without these properties are ignored. |
| `gamma` | Float | >0 | 1 | Yes | The resolution parameter `γ`. |
| `theta` | Float | ≥0 | 0.01 | Yes | The parameter `θ` which controls the degree of randomness during community merging in the second phase; sets to `0` to disable randomness to acquire the maximum gain of modularity (`ΔQ`). |
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
CALL algo.leiden.write("my_hdc_graph", {
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
D,9
N,11
F,5
H,5
B,7
L,11
A,9
E,9
K,11
M,11
C,9
```

<p tit="File: f2"></p>
```
community_id,_ids
5,I;J;F;H;
7,G;B;
9,D;A;E;C;
11,N;L;K;M;
```

<p tit="File: f3"></p>
```
community_id,count
5,4
7,2
9,4
11,4
```
  
</div>

## DB Writeback

Writes the `community_id` values from the results to the specified node property. The property type is `uint32`.

  
```gql
CALL algo.leiden.write("my_hdc_graph", {
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
CALL algo.leiden.write("my_hdc_graph", {
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
| 4 | 0.548490 |

## Full Return

```gql
CALL algo.leiden.run("my_hdc_graph", {
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
CALL algo.leiden.stream("my_hdc_graph", {
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
CALL algo.leiden.stream("my_hdc_graph", {
  return_id_uuid: "id",
  phase1_loop_num: 6, 
  min_modularity_increase: 0.1
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
CALL algo.leiden.stats("my_hdc_graph", {
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
