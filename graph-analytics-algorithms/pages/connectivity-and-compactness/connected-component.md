# Connected Component

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stats</b></span></div>

## Overview

The Connected Component algorithm identifies the connected components in a graph, which is the essential indicator to examine the connectivity and topology characteristics of the graph.

The number of connected components in a graph can serve as a coarse-grained metering method. If the number of connected components remains unchanged after certain operations or modifications to the graph, it suggests that the macroscopic connectivity and topology characteristics of the graph have not been altered significantly.

This information is valuable in various graph analysis scenarios. For example, in social networks, if the number of connected components remains the same over time, it implies that the overall connectivity patterns and community structures within the network have not experienced substantial changes.

## Concepts

### Connected Component

A connected component is a maximal subset of nodes in a graph where all nodes in that subset are reachable from one another by following edges in the graph. A maximal subset means that no additional nodes can be added to the subset without breaking the connectivity requirement.

The number of connected components in a graph indicates the level of disconnectedness or the presence of distinct subgraphs within the overall graph. A graph that has exactly one component, consisting of the whole graph, is called a <i>connected graph</i>.

### Weakly and Strongly Connected Component

There are two important concepts related to connected component: <b>weakly connected component (WCC)</b> and <b>strongly connected component (SCC)</b>:

- A WCC refers to a subset of nodes in a directed or undirected graph where there exists a path between any pair of nodes, regardless of the direction of the edges. 
- A SCC is a subset of nodes in a directed graph where there is a directed path between every pair of nodes. In other words, for any two nodes <i>u</i> and <i>v</i> in a SCC, there is a directed path from <i>u</i> to <i>v</i> and also from <i>v</i> to <i>u</i>. In directed path, all edges have the same direction.

<div align=center drawio-diagram='6017' drawio-name='draw_2f5f2e1e0d644c729e5b3cd09344fcb5.jpg'><img src="https://img.ultipa.cn/draw/draw_2f5f2e1e0d644c729e5b3cd09344fcb5.jpg?v='1684744743791'"/></div>

This example shows the 3 strongly connected components and 2 weakly connected components of a graph. The number of SCCs in a graph is always equal to or greater than the number of WCCs, as determining a SCC requires stricter conditions compared to a WCC.

## Considerations

- Each isolated node in the graph is a connected component, and it is both a strongly connected component and a weakly connected component.

## Syntax

- Command: `algo(connected_component)`
- Parameters:

| <div table-width="10">Name</div> | <div table-width="7">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| cc_type | int | `1`, `2` | `1` | Yes | `1` means weakly connected component (WCC), `2` means strongly connected component (SCC) |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order | string | `asc`, `desc` | / | Yes | Sort results by the count of nodes in each connected component (only valid in mode 2 of the `stream()` execution) |

> In Ultipa's Connected Component algorithm, each connected component is denoted as a community.

## Examples

The example graph is as follows:

<div align='center' drawio-diagram='6018' drawio-name='draw_042ef56059474e65b807a0fece46b87f.jpg'><img src="https://img.ultipa.cn/draw/draw_042ef56059474e65b807a0fece46b87f.jpg?v='1684746408422'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename_community_id | `_id`,`community_id` |
| filename_ids | `community_id`,`_id`,`_id`,... |
| filename_num | `community_id`,`count` |

```js
algo(connected_component).params({
  cc_type: 1
}).write({
  file:{ 
    filename_community_id: 'f1',
    filename_ids: 'f2',
    filename_num: 'f3'
  }
})
```

Statistics: community_count = 2<br>
Results: Files <i>f1</i>, <i>f2</i>, <i>f3</i>

<p run-tag="false" graph="" tit="File: f1" ></p>

```js
Alice,0
Bill,0
Bob,0
Sam,0
Joe,0
Anna,0
Cathy,6
Mike,6
```

<p run-tag="false" graph="" tit="File: f2" ></p>

```js
0,Alice,Bill,Bob,Sam,Joe,Anna,
6,Cathy,Mike,
```

<p run-tag="false" graph="" tit="File: f3" ></p>

```js
0,6
6,2
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `community_id` | Node property | `int64` |

```js
algo(connected_component).params().write({
  db:{ 
    property: 'wcc_id'
  }
})
```

Statistics: community_count = 2<br>
Results: The community ID of each node is written to a new property named <i>wcc_id</i>

### Direct Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="12">Type</div> | Description | <div table-width="25">Columns</div> |
| --- | --- | --- | --- |
| 0 | []perNode | Node and its community ID | `_uuid`, `community_id` |
| 1 | KV | Number of communities | `community_count` |

```js
algo(connected_component).params({
  cc_type: 2
}) as r1, r2
return r1, r2
```

Results: <i>r1</i> and <i>r2</i>

| \_uuid | community_id |
| --- | --- | 
| 8 | 0 |
| 7 | 0 |
| 6 | 0 |
| 5 | 3 |
| 4 | 0 |
| 3 | 0 |
| 2 | 6 |
| 1 | 7 |

| community_count |
| --- | 
| 4 |

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
algo(connected_component).params({
  cc_type: 2
}).stream() as r
return r
```

Results: <i>r</i>

| \_uuid | community_id |
| --- | --- | 
| 8 | 0 |
| 7 | 0 |
| 6 | 0 |
| 5 | 3 |
| 4 | 0 |
| 3 | 0 |
| 2 | 6 |
| 1 | 7 |

```js
algo(connected_component).params({
  cc_type: 2,
  order: 'asc'
}).stream({
  mode: 2
}) as r
return r
```

Results: <i>r</i>

| community_id | count |
| --- | --- |
| 6 | 1 |
| 7 | 1 |
| 3 | 1 |
| 0 | 5 |

### Stats Return

| Alias Ordinal | Type | Description | Columns |
| --- | --- | --- | --- |
| 0	| KV | Number of communities | `community_count` |

```js
algo(connected_component).params().stats() as count
return count
```

Results: <i>count</i>

| community_count |
| --- | 
