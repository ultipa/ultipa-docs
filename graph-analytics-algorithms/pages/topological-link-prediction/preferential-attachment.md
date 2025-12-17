# Preferential Attachment

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

Preferential attachment is a common phenomenon in complex network where nodes with more connections are more likely to establish new connections. When both nodes possess a large number of connections, the probability of them forming a connection is significantly higher. This phenomenon was utilized by A. Barabási and R. Albert in their proposed BA model for generating random scale-free networks in 2002:

- R. Albert, A. Barabási, <a href="https://arxiv.org/pdf/cond-mat/0106096.pdf" target="_blank">Statistical mechanics of complex networks</a> (2001)

The Preferential Attachment algorithm gauges the similarity between two nodes by calculating the product of the number of neighbors each node has. It is computed using the following formula:

<center><img width="240" src="https://img.ultipa.cn/2022-08-10-09-24-26-PA.jpg"></center>

where <i>N(x)</i> and <i>N(y)</i> are the sets of adjacent nodes to nodes <i>x</i> and <i>y</i> respectively. 

Higher Preferential Attachment scores indicate greater similarity between nodes, while a score of 0 indicates no similarity between two nodes.

<div align=center drawio-diagram='6589' drawio-name='draw_4b46a0b60fa141698093b656f3600ea2.jpg'><img src="https://img.ultipa.cn/draw/draw_4b46a0b60fa141698093b656f3600ea2.jpg?v='1691983066684'"/></div>

In this example, PA(D,E) = |N(D)| * |N(E)| = |{B, C, E, F}| * |{B, D, F}| = 4 * 3 = 12.

## Considerations

- The Preferential Attachment algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(topological_link_prediction)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="8">Type</div> | <div table-width="13">Spec</div> | <div table-width="13">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | No | ID/UUID of the first set of nodes to calculate;  each node in `ids`/`uuids` will be paired with each node in `ids2`/`uuids2` |
| ids2 / uuids2 | []`_id` / []`_uuid` | / | / | No | ID/UUID of the second set of nodes to calculate;  each node in `ids`/`uuids` will be paired with each node in `ids2`/`uuids2` |
| type | string	| `Preferential_Attachment` | `Adamic_Adar` | No | Type of similarity; for Preferential Attachment, keep it as `Preferential_Attachment` |
| limit | int | >=-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Example

The example graph is as follows:

<div align=center drawio-diagram='6590' drawio-name='draw_f0e1ac612f234b298d9ac04f1fa897ad.jpg'><img src="https://img.ultipa.cn/draw/draw_f0e1ac612f234b298d9ac04f1fa897ad.jpg?v='1691983348642'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `node1`,`node2`,`num` |

```js
algo(topological_link_prediction).params({
  uuids: [3],
  uuids2: [1,5,7],
  type: 'Preferential_Attachment'
}).write({
  file:{ 
    filename: 'pa'
  }
})
```

Results: File <i>pa</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
C,A,3.000000
C,E,6.000000
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
  type: 'Preferential_Attachment'
}) as pa 
return pa 
```

Results: <i>pa</i>

| node1 | node2 | num |
| -- | -- | -- |
| 3 | 1 | 3 |
| 3 | 5 | 6 |
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
  type: 'Preferential_Attachment'
}).stream() as pa
where pa.num >= 2
return pa
```

Results: <i>pa</i>

| node1 | node2 | num |
| -- | -- | -- |
| 3 | 2 | 12 |
| 3 | 4 | 12 |
| 3 | 5 | 6 |
| 3 | 6 | 9 |