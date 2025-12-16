# Total Neighbors

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The Total Neighbors algorithm computes the total number of distinct neighbors of two nodes as a measure of their similarity.

This algorithm takes into account the entire neighborhood of both nodes, giving a more comprehensive view of their similarity compared to algorithms that only focus on common neighbors. It is computed using the following formula:

<center><img width="220" src="https://img.ultipa.cn/2022-08-10-11-38-04-TU.jpg"></center>

where <i>N(x)</i> and <i>N(y)</i> are the sets of adjacent nodes to nodes <i>x</i> and <i>y</i> respectively. 

More total neighbors indicate greater similarity between nodes, while a number of 0 indicates no similarity between two nodes.

<div align=center drawio-diagram='6594' drawio-name='draw_cf9f39ce32334d1e9c8afedd35c05c9b.jpg'><img src="https://img.ultipa.cn/draw/draw_cf9f39ce32334d1e9c8afedd35c05c9b.jpg?v='1691985837823'"/></div>

In this example, TN(D,E) = |N(D) ∪ N(E)| = |{B, C, E, F} ∪ {B, D, F}| = |{B, C, D, E, F}| = 5.

## Considerations

- The Total Neighbors algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(topological_link_prediction)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="8">Type</div> | <div table-width="13">Spec</div> | <div table-width="13">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | No | ID/UUID of the first set of nodes to calculate;  each node in `ids`/`uuids` will be paired with each node in `ids2`/`uuids2` |
| ids2 / uuids2 | []`_id` / []`_uuid` | / | / | No | ID/UUID of the second set of nodes to calculate;  each node in `ids`/`uuids` will be paired with each node in `ids2`/`uuids2` |
| type | string	| `Total_Neighbors` | `Adamic_Adar` | No | Type of similarity; for Total Neighbors, keep it as `Total_Neighbors` |
| limit | int | >=-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Example

The example graph is as follows:

<div align=center drawio-diagram='6593' drawio-name='draw_4287e458a03547f0b2bc7cb8201871a9.jpg'><img src="https://img.ultipa.cn/draw/draw_4287e458a03547f0b2bc7cb8201871a9.jpg?v='1691985670307'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `node1`,`node2`,`num` |

```js
algo(topological_link_prediction).params({
  uuids: [3],
  uuids2: [1,5,7],
  type: 'Total_Neighbors'
}).write({
  file:{ 
    filename: 'tn'
  }
})
```

Results: File <i>tn</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
C,A,3.000000
C,E,3.000000
C,G,3.000000
```

### Direct Return

| Alias Ordinal | Type | <div table-width="31">Description</div> | <div table-width="24">Columns</div> |
| ----- | ---- | ----------- | ----------- |
| 0 | []perNodePair | Node pair and its similarity | `node1`, `node2`, `num` |

```js
algo(topological_link_prediction).params({
  ids: 'C',
  ids2: ['A','C','E','G'],
  type: 'Total_Neighbors'
}) as tn 
return tn 
```

Results: <i>tn</i>

| node1 | node2 | num |
| -- | -- | -- |
| 3 | 1 | 3 |
| 3 | 5 | 3 |
| 3 | 7 | 3 |

### Stream Return

| Alias Ordinal | Type | <div table-width="31">Description</div> | <div table-width="24">Columns</div> |
| ----- | ---- | ----------- | ----------- |
| 0 | []perNodePair | Node pair and its similarity | `node1`, `node2`, `num` |

```js
find().nodes() as n
with collect(n._id) as nID
algo(topological_link_prediction).params({
  ids: 'C',
  ids2: nID,
  type: 'Total_Neighbors'
}).stream() as tn
where tn.num >= 4
return tn
```

Results: <i>tn</i>

| node1 | node2 | num |
| -- | -- | -- |
| 3 | 2 | 6 |
| 3 | 4 | 5 |
| 3 | 6 | 5 |
null
