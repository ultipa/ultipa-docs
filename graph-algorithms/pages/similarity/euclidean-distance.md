# Euclidean Distance

## Overview

In mathematics, the Euclidean distance between two points in Euclidean space is the length of a line segment between the two points. In the graph, <i>N</i> numeric node properties (features) are specified to represent each node's position in an N-dimensional Euclidean space.

## Concepts

### Euclidean Distance

In 2-dimensional space, the formula to compute the Euclidean distance between points A(x<sub>1</sub>, y<sub>1</sub>) and B(x<sub>2</sub>, y<sub>2</sub>) is:

<center><img width=270 src="https://img.ultipa.cn/2022-08-09-15-15-45-d2.jpg"></center>

In 3-dimensional space, the formula to compute the Euclidean distance between points A(x<sub>1</sub>, y<sub>1</sub>, z<sub>1</sub>) and B(x<sub>2</sub>, y<sub>2</sub>, z<sub>2</sub>) is:

<center><img width=360 src="https://img.ultipa.cn/2022-08-09-15-15-47-d3.jpg"></center>

Generalized to N-dimensional space, the formula to compute the Euclidean distance is:

<center><img width=210 src="https://img.ultipa.cn/2022-08-09-15-15-49-dn.jpg"></center>

where <i>xi<sub>1</sub></i> represents the <i>i</i>-th dimensional coordinates of the first point, and <i>xi<sub>2</sub></i> represents the <i>i</i>-th dimensional coordinates of the second point.

Euclidean distance ranges from 0 to +∞; smaller values indicate greater similarity between the two nodes.

### Normalized Euclidean Distance

This algorithm returns the **normalized** Euclidean distance which scales the result into the range 0 to 1:

<center><img width=270 src="https://img.ultipa.cn/2022-08-09-15-23-53-dnorm.jpg"></center>

Values closer to 1 indicate greater similarity.

## Considerations

- The calculation of Euclidean distance between two nodes is independent of their connectivity in the graph — it uses node properties only.

## Example Graph

<div align=center drawio-diagram='19795' drawio-name='draw_977329a8246f44c5b1792416e52b7f61.jpg'><img src="https://img.ultipa.cn/draw/draw_977329a8246f44c5b1792416e52b7f61.jpg?v='1733998496314'"/></div>


```gql
INSERT (:product {_id: "product1", price: 50, weight: 160, width: 20, height: 152}),
       (:product {_id: "product2", price: 42, weight: 90, width: 30, height: 90}),
       (:product {_id: "product3", price: 24, weight: 50, width: 55, height: 70}),
       (:product {_id: "product4", price: 38, weight: 20, width: 32, height: 66})
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `type` | `STRING` | `jaccard` | Type of similarity to compute: `euclidean`. |
| `ids` | `LIST` | / | First group of node `_id`s. If empty, all nodes are used. |
| `ids2` | `LIST` | / | Second group of node `_id`s for pairing mode. If empty, selection mode is used. |
| `node_property` | `LIST` | / | **Required.** Numeric node properties to form a vector for each node. |
| `degreeCutoff` | `INT` | `0` | Minimum degree to include a node (0 = no cutoff). |
| `order` | `STRING` | / | Sorts results by `similarity`: `asc` or `desc`. |
| `limit` | `INT` | `-1` | Maximum total results returned (-1 = all). |
| `top_limit` | `INT` | `-1` | Maximum results per source node in selection mode (-1 = all). |

Supports three computation modes:

- **All-pairs**: When both `ids` and `ids2` are empty, computes similarity between all node pairs in the graph.
- **Pairing**: When both `ids` and `ids2` are specified, computes similarity between each node in `ids` and each node in `ids2`.
- **Selection**: When only `ids` is specified (no `ids2`), computes similarity between each node in `ids` and all other nodes. Use `top_limit` to limit results per source node.

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `node1` | `STRING` | First node identifier (`_id`) |
| `node2` | `STRING` | Second node identifier (`_id`) |
| `similarity` | `FLOAT` | Normalized Euclidean distance (closer to 1 = more similar) |

Euclidean similarity in pairing mode:

```gql
CALL algo.similarity({
  type: "euclidean",
  ids: ["product1"],
  ids2: ["product2", "product3", "product4"],
  node_property: ["price", "weight", "width", "height"]
}) YIELD node1, node2, similarity
```

Result:

| node1 | node2 | similarity |
| -- | -- | -- |
| product1 | product2 | 0.010484136264957374 |
| product1 | product3 | 0.006898369064315755 |
| product1 | product4 | 0.00601761870467499 |

Euclidean similarity in selection mode (top 1 per source node):

```gql
CALL algo.similarity({
  type: "euclidean",
  ids: ["product1", "product3"],
  node_property: ["price", "weight", "width", "height"],
  top_limit: 1
}) YIELD node1, node2, similarity
```

Result:

| node1 | node2 | similarity |
| -- | -- | -- |
| product1 | product2 | 0.010484136264957374 |
| product3 | product4 | 0.024091011098206213 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.similarity.stream({
  type: "euclidean",
  ids: ["product1"],
  node_property: ["price", "weight", "width", "height"],
  order: "desc"
}) YIELD node1, node2, similarity
RETURN node1, node2, similarity
```

Result:

| node1 | node2 | similarity |
| -- | -- | -- |
| product1 | product2 | 0.010484136264957374 |
| product1 | product3 | 0.006898369064315755 |
| product1 | product4 | 0.00601761870467499 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `pairCount` | `INT` | Number of node pairs computed |
| `minSimilarity` | `FLOAT` | Minimum normalized distance |
| `maxSimilarity` | `FLOAT` | Maximum normalized distance |
| `avgSimilarity` | `FLOAT` | Average normalized distance |

```gql
CALL algo.similarity.stats({
  type: "euclidean",
  node_property: ["price", "weight", "width", "height"]
}) YIELD pairCount, minSimilarity, maxSimilarity, avgSimilarity
```

Result:

| pairCount | minSimilarity | maxSimilarity | avgSimilarity |
| -- | -- | -- | -- |
| 12 | 0.00601761870467499 | 0.024091011098206213 | 0.013147026110302051 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `similarity` column in results to a property. Map: explicit column-to-property mapping (e.g., `{similarity: 'euc_score'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `similarity` | `FLOAT` | Normalized Euclidean distance |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.similarity.write({
  type: "euclidean",
  ids: ["product1", "product2"],
  node_property: ["price", "weight", "width", "height"]
}, {
  db: {
    property: "euc_score"                    // String: writes similarity to one property
    // property: {similarity: "euc_score"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
