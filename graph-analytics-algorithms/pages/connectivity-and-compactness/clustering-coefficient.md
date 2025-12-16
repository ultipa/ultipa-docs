# Local Clustering Coefficient

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The Local Clustering Coefficient algorithm calculates  the density of connection among the immediate neighbors of a node. It quantifies the ratio of actual connections among the neighbors to the maximum possible connections.

The local clustering coefficient provides insights into the cohesion of a node's ego network. In the context of a social network, the local clustering coefficient helps understand the degree of interconnectedness among an individual's friends or acquaintances. A high local clustering coefficient suggests that the person's friends are likely to be connected to each other, indicating the presence of a closely-knit social group, such as a family. Conversely, a low local clustering coefficient indicates a more dispersed or loosely interconnected ego network, where the person's friends do not have strong connections with each other.

## Concepts

### Local Clustering Coefficient

Mathematically, the local clustering coefficient of a node in an undirected graph is calculated as the ratio of the number of connected neighbor pairs to the total number of possible neighbor pairs:

<center><img width=400 src="https://img.ultipa.cn/img/2023-07-18-16-59-16-coef.jpg"></center>

where <i>n</i> is the number of nodes contained in the 1-hop neighborhood of node <i>v</i> (denoted as <i>N(v)</i>), <i>i</i> and <i>j</i> are any two distinct nodes within <i>N(v)</i>, <i>δ(i,j)</i> is equal to 1 if <i>i</i> and <i>j</i> are connected, and 0 otherwise.

<div align=center drawio-diagram='6367' drawio-name='draw_cadeb0a4ab4648b7b3b7b8f2c05e12c0.jpg'><img src="https://img.ultipa.cn/draw/draw_cadeb0a4ab4648b7b3b7b8f2c05e12c0.jpg?v='1689671244074'"/></div>

In this example, the local clustering coefficient of the red node is <i>1/(5*4/2) = 0.1</i>.

## Considerations

- The Local Clustering Coefficient algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(clustering_coefficient)`
- Parameters:

| <div table-width="8">Name</div> | <div table-width="8">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | Yes | ID/UUID of nodes to calculate the local clustering coefficient, calculate for all nodes if not set |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order | string | `asc`, `desc` | / | Yes | Sort nodes by the value of the local clustering coefficient |

## Examples

The example graph is as follows:

<div align=center drawio-diagram='6368' drawio-name="draw_9c12167c9fb84e5cafab7ebc1c706830.jpg"><img src="https://img.ultipa.cn/draw/draw_9c12167c9fb84e5cafab7ebc1c706830.jpg?v='1689671817622'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`centrality` |

```js
algo(clustering_coefficient).params({ 
  ids: ['Lee', 'Choi']
}).write({
  file:{
    filename: 'lcc'
 }
})
```

Results: File <i>lcc</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
Lee,0.266667
Choi,1
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `centrality` | Node property | `float` |

```js
algo(clustering_coefficient).params().write({
  db:{
    property: 'lcc'
 }
})
```

Results: The value of the local clustering coefficient for each node is written to a new property named <i>lcc</i>

### Direct Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="11">Type</div> | Description | <div table-width="19">Columns</div> |
| ---| --- | --- | --- |
| 0 | []perNode | Node and its local clustering coefficient | `_uuid`, `centrality` |

```js
algo(clustering_coefficient).params({
  order: 'desc'
}) as lcc 
return lcc
```

Results: <i>lcc</i>

| \_uuid | centrality |
| --- | --- |
| 2 | 1 |
| 6 | 1 |
| 3 | 0.666667 |
| 4 | 0.666667 |
| 7 | 0.666667 |
| 1 | 0.266667 |
| 5 | 0 |

### Stream Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="11">Type</div> | Description | <div table-width="19">Columns</div> |
| ---| --- | --- | --- |
| 0 | []perNode | Node and its local clustering coefficient | `_uuid`, `centrality` |

```js
algo(clustering_coefficient).params().stream() as lcc
where lcc.centrality == 1
return count(lcc)
```

