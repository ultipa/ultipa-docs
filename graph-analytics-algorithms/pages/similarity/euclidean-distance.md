# Euclidean Distance

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

In mathematics, the Euclidean distance between two points in Euclidean space is the length of a line segment between the two points. In the graph, specifying <i>N</i> numeric properties (features) of nodes to indicate the location of the node in an N-dimensional Euclidean space.

## Concepts

### Euclidean Distance

In 2-dimensional space, the formula to compute the Euclidean distance between points A(x<sub>1</sub>, y<sub>1</sub>) and B(x<sub>2</sub>, y<sub>2</sub>) is:

<center><img width=270 src="https://img.ultipa.cn/2022-08-09-15-15-45-d2.jpg"></center>

In 3-dimensional space, the formula to compute the Euclidean distance between points A(x<sub>1</sub>, y<sub>1</sub>, z<sub>1</sub>) and B(x<sub>2</sub>, y<sub>2</sub>, z<sub>2</sub>) is:

<center><img width=360 src="https://img.ultipa.cn/2022-08-09-15-15-47-d3.jpg"></center>

Generalize to N-dimensional space, the formula to compute the Euclidean distance is:

<center><img width=210 src="https://img.ultipa.cn/2022-08-09-15-15-49-dn.jpg"></center>

where <i>xi<sub>1</sub></i> represents the <i>i</i>-th dimensional coordinates of the first point, <i>xi<sub>2</sub></i> represents the <i>i</i>-th dimensional coordinates of the second point.

The Euclidean distance ranges from 0 to +∞; the smaller the value, the more similar the two nodes.

### Normalized Euclidean Distance

Normalized Euclidean distance scales the Euclidean distance into range from 0 to 1; the closer to 1, the more similar the two nodes.

Ultipa adopts the following formula to normalize the Euclidean distance:

<center><img width=270 src="https://img.ultipa.cn/2022-08-09-15-23-53-dnorm.jpg"></center>

## Considerations

- Theoretically, the calculation of Euclidean distance between two nodes does not depend on their connectivity.

## Syntax

- Command: `algo(similarity)`
- Parameters:

| <div table-width="15">Name</div> | <div table-width="9">Type</div> | <div table-width="15">Spec</div> | <div table-width="8">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | No | ID/UUID of the first group of nodes to calculate |
| ids2 / uuids2 | []`_id` / []`_uuid` | / | / | Yes | ID/UUID of the second group of nodes to calculate |
| type | string | `euclideanDistance`, `euclidean` | `cosine` | No | Type of similarity; `euclideanDistance` is to compute Euclidean Distance, `euclidean` is to compute Normalized Euclidean Distance |
| node_schema_property | []`@<schema>?.<property>` | Numeric type, must LTE | / | No | Specify two or more node properties to form the vectors, all properties must belong to the same (one) schema |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| top_limit	| int | ≥-1 | `-1` | Yes | In the selection mode, limit the maximum number of results returned for each node specified in `ids`/`uuids`, `-1` to return all results with similarity > 0; in the pairing mode, this parameter is invalid |

The algorithm has two calculation modes:

1. <b>Pairing: </b>when both `ids`/`uuids` and `ids2`/`uuids2` are configured, pairing each node in `ids`/`uuids` with each node in `ids2`/`uuids2` (ignore the same node) and computing pair-wise similarities.
2. <b>Selection: </b>when only `ids`/`uuids` is configured, for each target node in it, computing pair-wise similarities between it and all other nodes in the graph. The returned results include all or limited number of nodes that have similarity > 0 with the target node and is ordered by the descending similarity.

## Examples

The example graph has 4 products (edges are ignored), each product has properties <i>price</i>, <i>weight</i>, <i>weight</i> and <i>height</i>:

<div align='center' drawio-diagram='3123' drawio-name='draw_5cb4504e589a45b7b1d33d7b784e4b77.jpg'><img src="https://img.ultipa.cn/draw/draw_5cb4504e589a45b7b1d33d7b784e4b77.jpg?v='1662111270178'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `node1`,`node2`,`similarity` |

```js
algo(similarity).params({
  uuids: [1], 
  uuids2: [2,3,4],
  node_schema_property: ['price', 'weight', 'width', 'height'],
  type: 'euclideanDistance'
}).write({
  file:{ 
    filename: 'ed'
  }
})
```

Results: File <i>ed</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
product1,product2,94.3822
product1,product3,143.962
product1,product4,165.179
```

```js
algo(similarity).params({
  uuids: [1,2,3,4],
  node_schema_property: ['price', 'weight', 'width', 'height'],
  type: 'euclidean'
}).write({
  file:{ 
    filename: 'ed_list'
  }
})
```

Results: File <i>ed_list</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
product1,product2,0.010484
product1,product3,0.006898
product1,product4,0.006018
product2,product3,0.018082
product2,product4,0.013309
product2,product1,0.010484
product3,product4,0.024091
product3,product2,0.018082
product3,product1,0.006898
product4,product3,0.024091
product4,product2,0.013309
product4,product1,0.006018
```

### Direct Return

| <div table-width='15'>Alias Ordinal</div> | <div table-width='15'>Type</div> | Description | Columns |
| --- | --- | --- | --- |
| 0 | []perNodePair | Node pair and its similarity | `node1`, `node2`, `similarity` |

```js
algo(similarity).params({
  uuids: [1,2], 
  uuids2: [2,3,4],
  node_schema_property: ['price', 'weight', 'width', 'height'],
  type: 'euclideanDistance'
}) as distance
return distance
```

Results: <i>distance</i>

| node1	| node2	| similarity |
| ----- | ----- | ---------- |
| 1	| 2	| 94.3822017119753 |
| 1	| 3	| 143.96180048888 |
| 1	| 4	| 165.178691119648 |
| 2 | 3 | 54.3046959295419 |
| 2 | 4 | 74.1350119714025 |

```js
algo(similarity).params({
  uuids: [1,2],
  type: 'euclidean',
  node_schema_property: ['price', 'weight', 'width', 'height'],
  top_limit: 1
}) as top
return top
```

Results: <i>top</i>

| node1	| node2	| similarity |
| ----- | ----- | ---------- |
| 1 | 2 | 0.0104841362649574 |
| 2 | 3 | 0.0180816471945529 |

### Stream Return

| <div table-width='15'>Alias Ordinal</div> | <div table-width='15'>Type</div> | Description | Columns |
| --- | --- | --- | --- |
| 0 | []perNodePair | Node pair and its similarity | `node1`, `node2`, `similarity` |

```js
algo(similarity).params({
  uuids: [3], 
  uuids2: [1,2,4],
  node_schema_property: ['@product.price', '@product.weight', '@product.width'],
  type: 'euclidean'
}).stream() as distance
where distance.similarity > 0.01
return distance
```

Results: <i>distance</i>

| node1	| node2	| similarity |
| ----- | ----- | ---------- |
| 3	| 2	| 0.019422 |
| 3	| 4 | 0.024206 |

```js
algo(similarity).params({
  uuids: [1,3],
  node_schema_property: ['price', 'weight', 'width', 'height'],
  type: 'euclideanDistance',
  top_limit: 1
}).stream() as top
return top
```

Results: <i>top</i>

| node1	| node2	| similarity |
| ----- | ----- | ---------- |
| 1 | 4 | 165.1787 |
| 3 | 1 | 143.9618 |
null
