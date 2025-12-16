# K-1 Coloring

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stats</b></span></div>

## Overview

The K-1 Coloring algorithm assigns colors to each node such that no two adjacent nodes share the same color and the number of colors used is minimized.
- <a href="https://arxiv.org/pdf/1205.3809" target="blank">Graph Coloring Algorithms for Multi-core and Massively Multithreaded Architectures</a> (2018)

## Concepts
### Coloring
A coloring of a graph often refers to a proper node coloring, namely a labeling of the graph's nodes with colors such that no two nodes sharing the same edge have the same color. 
Graph coloring is a fundamental problem in computer science used in applications such as scheduling, register allocation, and wireless channel assignment.


### Chromatic Number
<center><img width=350 src="https://img.ultipa.cn/img/2024-07-23-16-43-38-chromatic-number.png"></center>
The smallest number of colors needed to color a graph G is called its chromatic number, and is often denoted χ(G). A graph that can be assigned a (proper) k-coloring is k-colorable, and it is k-chromatic if its chromatic number is exactly k.


## Considerations

Graph coloring is NP-complete 
It is NP-complete to decide if a given graph admits a k-coloring and NP-hard to compute the chromatic number. As a result, greedy algorithm is often used to solve graph coloring problem for large graphs. In fact, such approach does not guarantee the optimal solution and may color neighboring nodes the same. However, increasing the number of iterations can improve accuracy.

## Syntax

- Command: `algo(k1_coloring)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="7">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| loop_num | int | >=1 | `5` | Yes | Number of iterations |
| version | int | `1`, `2` | `2` | Yes | 1 for serial greedy coloring algorithm, 2 for iterative parallel greedy coloring algorithm|
  
## Examples

The example graph is as follows:

<center><img width=350 src="https://img.ultipa.cn/img/2024-07-29-10-38-48-k-1-coloring-example.png"></center>

### File Writeback

| Spec | Content | Description |
| --- | --- | --- |
| filename_community_id | `_id`,`community_id` | Node and its community ID |
| filename_ids | `community_id`,`_id`,`_id`,... | Community ID and the ID of nodes in it |
| filename_num | `community_id`,`count` | Community ID and the number of nodes in it |

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `community_id` | Node property | `uint32`??? 不是string吗 |


### Direct Return 

| <div table-width="15">Alias Ordinal</div> | <div table-width="12">Type</div> | Description | <div table-width="25">Columns</div> |
| --- | --- | --- | --- |
| 0 | []perNode	| Node and its community ID	| `_uuid`, `community_id` |
| 1 | KV | Number of communities, modularity | `community_count`, `modularity` |
  
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

### Stats Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="12">Type</div> | Description | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | KV | Number of communities | `community_count` |
