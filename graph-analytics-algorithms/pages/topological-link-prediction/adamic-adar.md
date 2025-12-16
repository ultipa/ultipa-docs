# Adamic-Adar Index

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The Adamic-Adar Index (AA Index) is a node similarity metric named after its creators Lada Adamic and Eytan Adar. This index measures the potential connection strength between two nodes based on the shared neighbors they have in the graph.

- L.A. Adamic, E. Adar, <a href="http://cond.org/fnn.pdf" target="_blank">Friends and Neighbors on the Web</a> (2003)

The underlying idea of the AA Index is that common neighbors with low degree provide more valuable information about the similarity between two nodes than common neighbors with high degrees. It is computed using the following formula:

<div align=center><img width=290 src="https://img.ultipa.cn/2022-08-10-09-53-17-AA.jpg"></div>

where <i>N(u)</i> is the set of nodes adjacent to <i>u</i>. For each common neighbor <i>u</i> of the two nodes, the AA Index first calculates the reciprocal of the logarithm of its degree <i>|N(u)|</i>, then sums up these reciprocal values for all common neighbors.

Higher AA Index scores indicate greater similarity between nodes, while a score of 0 indicates no similarity between two nodes.

<div align=center drawio-diagram='6570' drawio-name='draw_74f94d72d0804bbda280f06a5cf2b398.jpg'><img src="https://img.ultipa.cn/draw/draw_74f94d72d0804bbda280f06a5cf2b398.jpg?v='1691662039000'"/></div>

In this example, N(D) ∩ N(E) = {B, F}, where <math><mfrac><mn>1</mn><mi>log|N(B)|</mi></mfrac></math> = <math><mfrac><mn>1</mn><mi>log4</mi></mfrac></math> = 1.6610, <math><mfrac><mn>1</mn><mi>log|N(F)|</mi></mfrac></math> = <math><mfrac><mn>1</mn><mi>log3</mi></mfrac></math> = 2.0959, thus AA(D,E) = 1.6610 + 2.0959 = 3.7569.

## Considerations

- The AA Index algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(topological_link_prediction)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="8">Type</div> | <div table-width="13">Spec</div> | <div table-width="13">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | No | ID/UUID of the first set of nodes to calculate;  each node in `ids`/`uuids` will be paired with each node in `ids2`/`uuids2` |
| ids2 / uuids2 | []`_id` / []`_uuid` | / | / | No | ID/UUID of the second set of nodes to calculate;  each node in `ids`/`uuids` will be paired with each node in `ids2`/`uuids2` |
| type | string	| `Adamic_Adar` | `Adamic_Adar` | Yes | Type of similarity; for AA Index, keep it as `Adamic_Adar` |
| limit | int | >=-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Example

The example graph is as follows:

<div align=center drawio-diagram='6584' drawio-name="draw_eb5168a0389a46b8a4a7227b5800a5fd.jpg"><img src="https://img.ultipa.cn/draw/draw_eb5168a0389a46b8a4a7227b5800a5fd.jpg?v='1691977669197'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `node1`,`node2`,`num` |

```js
algo(topological_link_prediction).params({
  uuids: [3],
  uuids2: [1,5,7]
}).write({
  file:{ 
    filename: 'aa'
  }
})
```

Results: File <i>aa</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
C,A,1.660964
C,E,3.321928
C,G,2.095903
```

### Direct Return

| Alias Ordinal | Type | <div table-width="31">Description</div> | <div table-width="24">Columns</div> |
| ----- | ---- | ----------- | ----------- |
| 0 | []perNodePair | Node pair and its similarity | `node1`, `node2`, `num` |

```js
algo(topological_link_prediction).params({
  ids: 'C',
  ids2: ['A','C','E','G'],
  type: 'Adamic_Adar'
}) as aa 
return aa 
```

Results: <i>aa</i>

| node1 | node2 | num |
| -- | -- | -- |
| 3 | 1 | 1.66096404744368 |
| 3 | 5 | 3.32192809488736 |
| 3 | 7 | 2.09590327428938 |

### Stream Return

| Alias Ordinal | Type | <div table-width="31">Description</div> | <div table-width="24">Columns</div> |
| ----- | ---- | ----------- | ----------- |
| 0 | []perNodePair | Node pair and its similarity | `node1`, `node2`, `num` |

```js
find().nodes() as n
with collect(n._id) as nID
algo(topological_link_prediction).params({
  ids: 'C',
  ids2: nID
}).stream() as aa
where aa.num >= 2
return aa
```

Results: <i>aa</i>

| node1 | node2 | num |
| -- | -- | -- |
| 3 | 4 | 3.75686732173307 |
| 3 | 5 | 3.32192809488736 |
