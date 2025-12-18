# Resource Allocation

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The Resource Allocation algorithm operates under the assumption that nodes transmit resources to each other through their shared neighbors, who act as transmitters. In its basic form, we consider each transmitter possessing a single unit of resource, which is evenly distributed among its neighbors. Consequently, the similarity between two nodes can be gauged by the magnitude of resources that one node transmits to the other. This concept was introduced by Tao Zhou, Linyuan Lü, and Yi-Cheng Zhang in 2009:

- T. Zhou, L. Lü, Y. Zhang, <a href="https://arxiv.org/pdf/0901.0553.pdf" target="_blank">Predicting Missing Links via Local Information</a> (2009)

It is computed using the following formula:

<center><img width="260" src="https://img.ultipa.cn/2022-08-10-09-56-21-RA.jpg"></center>

where <i>N(u)</i> is the set of nodes adjacent to <i>u</i>. For each common neighbor <i>u</i> of the two nodes, the Resource Allocation first calculates the reciprocal of its degree |N(u)|, then sums up these reciprocal values for all common neighbors.

When calculating the degree for nodes in the graphset:
- edges connecting two same nodes will be counted only once;
- self-loop will be ignored.

Higher Resource Allocation scores indicate greater similarity between nodes, while a score of 0 indicates no similarity between two nodes.

<div align=center drawio-diagram='6591' drawio-name='draw_b86689aa4f2e4c5598dd981e0958996c.jpg'><img src="https://img.ultipa.cn/draw/draw_b86689aa4f2e4c5598dd981e0958996c.jpg?v='1691984801387'"/></div>

In this example, N(D) ∩ N(E) = {B, F}, RA(D,E) = <math><mfrac><mn>1</mn><mi>|N(B)|</mi></mfrac></math> + <math><mfrac><mn>1</mn><mi>|N(F)|</mi></mfrac></math> = <math><mfrac><mn>1</mn><mi>4</mi></mfrac></math> + <math><mfrac><mn>1</mn><mi>3</mi></mfrac></math> = 0.5833.

## Considerations

- The Resource Allocation algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(topological_link_prediction)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="8">Type</div> | <div table-width="13">Spec</div> | <div table-width="13">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | No | ID/UUID of the first set of nodes to calculate;  each node in `ids`/`uuids` will be paired with each node in `ids2`/`uuids2` |
| ids2 / uuids2 | []`_id` / []`_uuid` | / | / | No | ID/UUID of the second set of nodes to calculate;  each node in `ids`/`uuids` will be paired with each node in `ids2`/`uuids2` |
| type | string	| `Resource_Allocation` | `Adamic_Adar` | No | Type of similarity; for Resource Allocation, keep it as `Resource_Allocation` |
| limit | int | >=-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Example

The example graph is as follows:

<div align=center drawio-diagram='6592' drawio-name='draw_4852484853184e96bd5e861849ccc940.jpg'><img src="https://img.ultipa.cn/draw/draw_4852484853184e96bd5e861849ccc940.jpg?v='1691985028310'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `node1`,`node2`,`num` |

```js
algo(topological_link_prediction).params({
  uuids: [3],
  uuids2: [1,5,7],
  type: 'Resource_Allocation'
}).write({
  file:{ 
    filename: 'ra'
  }
})
```

Results: File <i>ra</i>

<p tit="File"></p>

```js
C,A,0.250000
C,E,0.500000
C,G,0.333333
```

### Direct Return

| Alias Ordinal | Type | <div table-width="31">Description</div> | <div table-width="24">Columns</div> |
| ----- | ---- | ----------- | ----------- |
| 0 | []perNodePair | Node pair and its similarity | `node1`, `node2`, `num` |

```js
algo(topological_link_prediction).params({
  ids: 'C',
  ids2: ['A','C','E','G'],
  type: 'Resource_Allocation'
}) as ra 
return ra 
```

Results: <i>ra</i>

| node1 | node2 | num |
| -- | -- | -- |
| 3 | 1 | 0.25 |
| 3 | 5 | 0.5 |
| 3 | 7 | 0.333333333333333 |

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
  type: 'Resource_Allocation'
}).stream() as ra
where ra.num >= 0.3
return ra
```

Results: <i>ra</i>

| node1 | node2 | num |
| -- | -- | -- |
| 3 | 4 | 0.583333333333333 |
| 3 | 5 | 0.5 |
| 3 | 7 | 0.333333333333333 |