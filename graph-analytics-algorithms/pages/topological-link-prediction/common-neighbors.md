# Common Neighbors

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The Common Neighbors algorithm computes the number of common neighbors between two nodes as a measure of their similarity.

The logic behind this algorithm is that if two nodes have a high number of neighbors in common, they are likely to be similar or connected in some meaningful way. It is computed using the following formula:

<center><img width="220" src="https://img.ultipa.cn/2022-08-09-18-06-06-CN.jpg"></center>

where <i>N(x)</i> and <i>N(y)</i> are the sets of adjacent nodes to nodes <i>x</i> and <i>y</i> respectively. 

More common neighbors indicate greater similarity between nodes, while a number of 0 indicates no similarity between two nodes.

<div align=center drawio-diagram='6585' drawio-name='draw_bb7c3956ecc64222863a9995d462f049.jpg'><img src="https://img.ultipa.cn/draw/draw_bb7c3956ecc64222863a9995d462f049.jpg?v='1691981900636'"/></div>

In this example, CN(D,E) = |N(D) ∩ N(E)| = |{B, F}| = 2.

## Considerations

- The Common Neighbors algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(topological_link_prediction)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="8">Type</div> | <div table-width="13">Spec</div> | <div table-width="13">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | No | ID/UUID of the first set of nodes to calculate;  each node in `ids`/`uuids` will be paired with each node in `ids2`/`uuids2` |
| ids2 / uuids2 | []`_id` / []`_uuid` | / | / | No | ID/UUID of the second set of nodes to calculate;  each node in `ids`/`uuids` will be paired with each node in `ids2`/`uuids2` |
| type | string	| `Common_Neighbors` | `Adamic_Adar` | No | Type of similarity; for Common Neighbors, keep it as `Common_Neighbors` |
| limit | int | >=-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Example

The example graph is as follows:

<div align=center drawio-diagram='6586' drawio-name='draw_f0371ee6a9cf4adf94a2a46ad69b3869.jpg'><img src="https://img.ultipa.cn/draw/draw_f0371ee6a9cf4adf94a2a46ad69b3869.jpg?v='1691982146945'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `node1`,`node2`,`num` |

```uql
algo(topological_link_prediction).params({
  uuids: [3],
  uuids2: [1,5,7],
  type: 'Common_Neighbors'
}).write({
  file:{ 
    filename: 'cn'
  }
})
```

Results: File <i>cn</i>

<p tit="File"></p>

```
C,A,1.000000
C,E,2.000000
C,G,1.000000
```

### Direct Return

| Alias Ordinal | Type | <div table-width="31">Description</div> | <div table-width="24">Columns</div> |
| ----- | ---- | ----------- | ----------- |
| 0 | []perNodePair | Node pair and its similarity | `node1`, `node2`, `num` |

```uql
algo(topological_link_prediction).params({
  ids: 'C',
  ids2: ['A','C','E','G'],
  type: 'Common_Neighbors'
}) as cn 
return cn 
```

Results: <i>cn</i>

| node1 | node2 | num |
| -- | -- | -- |
| 3 | 1 | 1 |
| 3 | 5 | 2 |
| 3 | 7 | 1 |

### Stream Return

| Alias Ordinal | Type | <div table-width="31">Description</div> | <div table-width="24">Columns</div> |
| ----- | ---- | ----------- | ----------- |
| 0 | []perNodePair | Node pair and its similarity | `node1`, `node2`, `num` |

```uql
find().nodes() as n
with collect(n._id) as nID
algo(topological_link_prediction).params({
  ids: 'C',
  ids2: nID,
  type: 'Common_Neighbors'
}).stream() as cn
where cn.num >= 2
return cn
```

Results: <i>cn</i>

| node1 | node2 | num |
| -- | -- | -- |
| 3 | 4 | 2 |
| 3 | 5 | 2 |