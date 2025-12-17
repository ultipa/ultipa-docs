# Cosine Similarity

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

In cosine similarity, data objects in a dataset are treated as vectors, and it uses the cosine value of the angle between two vectors to indicate the similarity between them. In the graph, specifying <i>N</i> numeric properties (features) of nodes to form N-dimensional vectors, two nodes are considered similar if their vectors are similar.

Cosine similarity ranges from -1 to 1; 1 means that the two vectors have the same direction, -1 means that the two vectors have the opposite direction.

<div align=center drawio-diagram='4963' drawio-name="draw_3f64dd50cd0a4e6695fae0cacda3892c.jpg"><img src="https://img.ultipa.cn/draw/draw_3f64dd50cd0a4e6695fae0cacda3892c.jpg?v='1681111944016'"/></div>

In 2-dimensional space, the cosine similarity between vectors A(a<sub>1</sub>, a<sub>2</sub>) and B(b<sub>1</sub>, b<sub>2</sub>) is computed as:

<center><img width=350 src="https://img.ultipa.cn/2022-08-09-14-00-10-cos2.jpg"></center>

In 3-dimensional space, the cosine similarity between vectors A(a<sub>1</sub>, a<sub>2</sub>, a<sub>3</sub>) and B(b<sub>1</sub>, b<sub>2</sub>, b<sub>3</sub>) is computed as:

<center><img width=480 src="https://img.ultipa.cn/2022-08-09-14-00-13-cos3.jpg"></center>

The following diagram shows the relationship between vectors A and B in 2D and 3D spaces, as well as the angle θ between them:

<div align=center drawio-diagram='4946' drawio-name="draw_16853a553f024f75b352985ae55be8c9.jpg"><img src="https://img.ultipa.cn/draw/draw_16853a553f024f75b352985ae55be8c9.jpg?v='1680746413239'"/></div>

Generalize to N-dimensional space, the cosine similarity is computed as:

<center><img width=420 src="https://img.ultipa.cn/2022-03-16-15-04-04-cosineS.png"></center>

## Considerations

- Theoretically, the calculation of cosine similarity between two nodes does not depend on their connectivity.
- The value of cosine similarity is independent of the length of the vectors, but only the direction of the vectors.

## Syntax

- Command: `algo(similarity)`
- Parameters:

| <div table-width="15">Name</div> | <div table-width="9">Type</div> | <div table-width="9">Spec</div> | <div table-width="8">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | No | ID/UUID of the first group of nodes to calculate |
| ids2 / uuids2 | []`_id` / []`_uuid` | / | / | Yes | ID/UUID of the second group of nodes to calculate |
| type | string | `cosine` | `cosine` | Yes | Type of similarity; for Cosine Similarity, keep it as `cosine` |
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
  node_schema_property: ['price', 'weight', 'width', 'height']
}).write({
  file:{ 
    filename: 'cs_result'
  }
})
```

Results: File <i>cs_result</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
product1,product2,0.986529
product1,product3,0.878858
product1,product4,0.816876
```

```js
algo(similarity).params({
  uuids: [1,2,3,4],
  node_schema_property: ['price', 'weight', 'width', 'height'],
  type: 'cosine'
}).write({
  file:{ 
    filename: 'list'
  }
})
```

Results: File <i>list</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
product1,product2,0.986529
product1,product3,0.878858
product1,product4,0.816876
product2,product1,0.986529
product2,product3,0.934217
product2,product4,0.881988
product3,product2,0.934217
product3,product4,0.930153
product3,product1,0.878858
product4,product3,0.930153
product4,product2,0.881988
product4,product1,0.816876
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
  type: 'cosine'
}) as cs
return cs
```

Results: <i>cs</i>

| node1	| node2	| similarity |
| ----- | ----- | ---------- |
| 1	| 2	| 0.986529413529119 |
| 1	| 3	| 0.878858407519654 |
| 1	| 4	| 0.816876150267203 |
| 2 | 3 | 0.934216530725663 |
| 2 | 4 | 0.88198819302226 |

```js
algo(similarity).params({
  uuids: [1,2],
  type: 'cosine',
  node_schema_property: ['price', 'weight', 'width', 'height'],
  top_limit: 1
}) as top
return top
```

Results: <i>top</i>

| node1	| node2	| similarity |
| ----- | ----- | ---------- |
| 1 | 2 | 0.986529413529119 |
| 2 | 1 | 0.986529413529119 |

### Stream Return

| <div table-width='15'>Alias Ordinal</div> | <div table-width='15'>Type</div> | Description | Columns |
| --- | --- | --- | --- |
| 0 | []perNodePair | Node pair and its similarity | `node1`, `node2`, `similarity` |

```js
algo(similarity).params({
  uuids: [3], 
  uuids2: [1,2,4],
  node_schema_property: ['@product.price', '@product.weight', '@product.width'],
  type: 'cosine'
}).stream() as cs
where cs.similarity > 0.8
return cs
```

Results: <i>cs</i>

| node1	| node2	| similarity |
| ----- | ----- | ---------- |
| 3	| 2	| 0.883292081301959 |
| 3	| 4 | 0.877834381494613 |

```js
algo(similarity).params({
  uuids: [1,3],
  node_schema_property: ['price', 'weight', 'width', 'height'],
  type: 'cosine',
  top_limit: 1
}).stream() as top
return top
```

Results: <i>top</i>

| node1	| node2	| similarity |
| ----- | ----- | ---------- |
| 1 | 2 | 0.986529413529119 |
| 3 | 2 | 0.934216530725663 |