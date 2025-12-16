# Leiden

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stats</b></span></div>

## Overview

The Leiden algorithm is a community detection algorithm designed to maximize modularity in a graph. It was developed to address potential issues in the results obtained by the popular <a href="https://www.ultipa.com/document/ultipa-graph-analytics-algorithms/louvain">Louvain</a> algorithm, where some communities may not be well-connected or even disconnected. The Leiden algorithm is faster compared to the Louvain algorithm and guarantees to produce partitions in which all communities are internally connected. The algorithm is also named after the location of its authors.

- V.A. Traag, L. Waltman, N.J. van Eck, <a target="balnk" href="https://arxiv.org/pdf/1810.08473.pdf">From Louvain to Leiden: guaranteeing well-connected communities</a> (2019)
- V.A. Traag, P. Van Dooren, Y. Nesterov, <a target="blank" href="https://arxiv.org/pdf/1104.3083v1.pdf">Narrow scope for resolution-limit-free community detection</a> (2011)

## Concepts

### Modularity

The concept of modularity is explained in the <a href="https://www.ultipa.com/document/ultipa-graph-analytics-algorithms/louvain">Louvain</a> algorithm. The modularity formula used in the Leiden algorithm is extended to handle different levels of community granularity:

<center><img width=330 src="https://img.ultipa.cn/img/2023-08-10-14-17-41-leiden-modularity.jpg" /></center>

<i>γ</i> > 0 is the <b>resolution parameter</b> that modulates the density of connections within communities and between communities. When <i>γ</i> > 1, it leads to more, smaller and well-connected communities; when <i>γ</i> <  1, it leads to fewer, larger and less well-connected communities.

### Leiden

The Leiden algorithm starts from a singleton partition, in which each node is in its own community. Then algorithm iteratively runs through passes, and each pass is made of three phases:

#### First Phase: Fast Modularity Optimization

Unlike the first phase of the <a href="https://www.ultipa.com/document/ultipa-graph-analytics-algorithms/louvain">Louvain</a> algorithm, which keeps visiting all nodes in the graph until no node movements can increase the modularity; the Leiden algorithm takes a more efficient approach, it only visits all nodes once, afterwards it visits only nodes whose neighborhood has changed. To do that, the Leiden algorithm maintains a queue and initializes it by adding all nodes in the graph in a random order.

Then repeat the following steps until the queue is empty: 
- Remove the first node from the front of the queue. 
- Reassign the node to a different community which has the maximum gain of modularity (ΔQ); or keep the node in its original community if there is no positive gain. 
- If the node is moved to a different community, add to the rear of the queue all neighbors of the node that do not belong to the node’s new community and that are not yet in the queue. 

The first phase ends with a partition P of the base or aggregate graph.

#### Second Phase: Refinement

This phase is designed to get a refined partition P<sub>refined</sub> of P to guarantee that all communities are <i>well-connected</i>. 

P<sub>refined</sub> is initially set to a singleton partition, in which each node in the base or aggregate graph is in its own community. Refine each community C ∈ P as follows.

1\. Consider only nodes v ∈ C that are <i>well-connected</i> within C:

<center><img width=310 src="https://img.ultipa.cn/img/2023-08-10-18-34-20-well1.jpg" /></center>

where,

- W(v,C-v) is the sum of edge weights between node v and the rest of nodes in C;
- k<sub>v</sub> is the sum of weights of all edges attached to node v;
- <math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi>c</mi></mmultiscripts></math> the sum of weights of all edges attached to nodes in C.

<div align=center drawio-diagram='6395' drawio-name="draw_2eb6fd4262954600a29f652213a6ee09.jpg"><img src="https://img.ultipa.cn/draw/draw_2eb6fd4262954600a29f652213a6ee09.jpg?v='1690360083168'"/></div>

Take community C<sub>1</sub> in the above graph as example, where 

- m = 18.1
- <math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> = k<sub>a</sub> + k<sub>b</sub> + k<sub>c</sub> + k<sub>d</sub> = 6 + 2.7 + 2.8 + 3 = 14.5

Set <i>γ</i> as 1.2, then:

- W(a, C<sub>1</sub>) - γ/m ⋅ k<sub>a</sub> ⋅ (<math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> - k<sub>a</sub>) = 4.5 - 1.2/18.1\*6\*(14.5 - 6) = 1.12
- W(b, C<sub>1</sub>) - γ/m ⋅ k<sub>b</sub> ⋅ (<math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> - k<sub>b</sub>) = 1 - 1.2/18.1\*2.7\*(14.5 - 2.7) = -1.11
- W(c, C<sub>1</sub>) - γ/m ⋅ k<sub>c</sub> ⋅ (<math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> - k<sub>c</sub>) = 0.5 - 1.2/18.1\*2.8\*(14.5 - 2.8) = -1.67
- W(d, C<sub>1</sub>) - γ/m ⋅ k<sub>d</sub> ⋅ (<math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> - k<sub>d</sub>) = 3 - 1.2/18.1\*3\*(14.5 - 3) = 0.71

In this case, only nodes a and d are considered <i>well-connected</i> in community C<sub>1</sub>.

2\. Visit each node v in random order, if it is still on its own in a community in P<sub>refined</sub>, randomly merge it to a community C' ∈ P<sub>refined</sub> for which the modularity increases. It is required that C' must be well-connected with C:

<center><img width=320 src="https://img.ultipa.cn/img/2023-08-10-18-39-30-well2.jpg" /></center>

Note that in this phase, each node is not necessarily greedily merged with the community that yields the maximum gain of modularity. However, the larger the gain, the more likely a community is to be selected. The degree of randomness in the selection of a community is determined by a parameter θ > 0: 

<center><img width=270 src="https://img.ultipa.cn/img/2023-07-27-14-31-33-theta.jpg" /></center>

Randomness in the selection of a community allows the partition space to be explored more broadly.

After the refinement phase is concluded, communities in P often are split into multiple communities in P<sub>refined</sub>, but not always.

#### Third Phase: Community Aggregation

The aggregate graph is created based on P<sub>refined</sub>. However, the partition for the aggregate graph is based on P. The aggregation process is the same as <a href="https://www.ultipa.com/document/ultipa-graph-analytics-algorithms/louvain">Louvain</a>.

<div align=center drawio-diagram='6566' drawio-name="draw_6f703198f7754ec4bcebd6168a3f9068.jpg"><img src="https://img.ultipa.cn/draw/draw_6f703198f7754ec4bcebd6168a3f9068.jpg?v='1691655725180'"/></div>
<center>P - color blocks, P<sub>refined</sub> - node colors</center><br>

Once this third phase is completed, another pass is applied to the aggregate graph. The passes are iterated until there are no more changes, and a maximum modularity is attained.

## Considerations

- If node i has any self-loop, when calculating k<sub>i</sub>, the weight of self-loop is counted only once.
- The Leiden algorithm ignores the direction of edges but calculates them as undirected edges. 

## Syntax

- Command: `algo(leiden)`
- Parameters:

| <div table-width="23">Name</div> | <div table-width="7">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| phase1_loop_num | int | ≥1 | `5` | Yes | The maximum loop number of the first phase during each pass |
| min_modularity_increase | float | [0,1] | `0.01` | Yes | The minimum gain of modularity (ΔQ) to move a node to another community in the first phase |
| edge_schema_property | []`@<schema>?.<property>` | Numeric type, must LTE | / | Yes | Edge properties to use as weights, where the values of multiple properties are summed up; all edge weights are considered as 1 if not set |
| gamma | float | >0 | 1 | Yes | The resolution parameter γ |
| theta | float | >0 | 0.01 | Yes | The parameter θ which controls the degree of randomness during community merging in the second phase |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order | string | `asc`, `desc` | / | Yes | Sort communities by the number of nodes in it (only valid in mode 2 of the `stream()` execution) |

## Examples

### File Writeback

| Spec | Content | Description |
| --- | --- | --- |
| filename_community_id | `_id`,`community_id` | Node and its community ID |
| filename_ids | `community_id`,`_id`,`_id`,... | Community ID and the ID of nodes in it |
| filename_num | `community_id`,`count` | Community ID and the number of nodes in it |

```js
algo(leiden).params({ 
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

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `community_id` | Node property | `uint32` |

```js
algo(leiden).params({ 
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1,
  edge_schema_property: 'weight'
}).write({
  db:{
    property: 'communityID'
  }
})
```

### Direct Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="12">Type</div> | Description | <div table-width="25">Columns</div> |
| --- | --- | --- | --- |
| 0 | []perNode	| Node and its community ID	| `_uuid`, `community_id` |
| 1 | KV | Number of communities, modularity | `community_count`, `modularity` |

```js
algo(leiden).params({ 
  phase1_loop_num: 6, 
  min_modularity_increase: 0.5,
  edge_schema_property: 'weight'
}) as results, stats
return results, stats
```

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

```js
algo(leiden).params({ 
  phase1_loop_num: 6, 
  min_modularity_increase: 0.5,
  edge_schema_property: 'weight'
}).stream() as results
group by results.community_id
return table(results.community_id, max(results._uuid))
```

```js
algo(leiden).params({ 
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1,
  order: "desc"
}).stream({
  mode: 2
}) as results
return results
```

### Stats Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="12">Type</div> | Description | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | KV | Number of communities, modularity | `community_count`, `modularity` |

```js
algo(leiden).params({ 
  phase1_loop_num: 5, 
  min_modularity_increase: 0.1
}).stats() as stats
return stats
