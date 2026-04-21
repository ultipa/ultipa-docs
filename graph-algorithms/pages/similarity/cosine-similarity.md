# Cosine Similarity

## Overview

In cosine similarity, data objects in a dataset are treated as vectors, and it uses the cosine value of the angle between two vectors to indicate the similarity between them. In the graph, <i>N</i> numeric node properties (features) are specified to form N-dimensional vectors; two nodes are considered similar if their vectors are similar.

Cosine similarity ranges from -1 to 1, where 1 indicates that the two vectors point in the same direction, and -1 indicates they point in opposite directions.

## Concepts

### Cosine Similarity

<div align=center drawio-diagram='4963' drawio-name="draw_3f64dd50cd0a4e6695fae0cacda3892c.jpg"><img src="https://img.ultipa.cn/draw/draw_3f64dd50cd0a4e6695fae0cacda3892c.jpg?v='1681111944016'"/></div>

In 2-dimensional space, the cosine similarity between vectors <code>A = [a<sub>1</sub>, a<sub>2</sub>]</code> and <code>B = [b<sub>1</sub>, b<sub>2</sub>]</code> is computed as:

<center><img width=350 src="https://img.ultipa.cn/2022-08-09-14-00-10-cos2.jpg"></center>

In 3-dimensional space, the cosine similarity between vectors <code>A = [a<sub>1</sub>, a<sub>2</sub>, a<sub>3</sub>]</code> and <code>B = [b<sub>1</sub>, b<sub>2</sub>, b<sub>3</sub>]</code> is computed as:

<center><img width=480 src="https://img.ultipa.cn/2022-08-09-14-00-13-cos3.jpg"></center>

The following diagram shows the relationship between vectors `A` and `B` in 2D and 3D spaces, as well as the angle θ between them:

<div align=center drawio-diagram='4946' drawio-name="draw_16853a553f024f75b352985ae55be8c9.jpg"><img src="https://img.ultipa.cn/draw/draw_16853a553f024f75b352985ae55be8c9.jpg?v='1680746413239'"/></div>

Generalized to N-dimensional space, cosine similarity is computed as:

<center><img width=420 src="https://img.ultipa.cn/2022-03-16-15-04-04-cosineS.png"></center>

## Considerations

- The calculation of cosine similarity between two nodes is independent of their connectivity in the graph.
- The value of cosine similarity is independent of the length of the vectors, but only the direction of the vectors.

## Example Graph

<div align=center drawio-diagram='19792' drawio-name='draw_bc765c50cae2418590031a17fdcb6fe4.jpg'><img src="https://img.ultipa.cn/draw/draw_bc765c50cae2418590031a17fdcb6fe4.jpg?v='1733988639804'"/></div>

```gql
INSERT (:product {_id: "product1", price: 50, weight: 160, width: 20, height: 152}),
       (:product {_id: "product2", price: 42, weight: 90, width: 30, height: 90}),
       (:product {_id: "product3", price: 24, weight: 50, width: 55, height: 70}),
       (:product {_id: "product4", price: 38, weight: 20, width: 32, height: 66})
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `type` | `STRING` | `jaccard` | Type of similarity to compute: `cosine`. |
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
| `similarity` | `FLOAT` | Computed cosine similarity score |

Cosine similarity in pairing mode:

```gql
CALL algo.similarity({
  type: "cosine",
  ids: ["product1"],
  ids2: ["product2", "product3", "product4"],
  node_property: ["price", "weight", "width", "height"]
}) YIELD node1, node2, similarity
```

Result:

| node1 | node2 | similarity |
| -- | -- | -- |
| product1 | product2 | 0.9865294135291195 |
| product1 | product3 | 0.8788584075196542 |
| product1 | product4 | 0.8168761502672031 |

Cosine similarity in selection mode (top 1 per source node):

```gql
CALL algo.similarity({
  type: "cosine",
  ids: ["product1", "product3"],
  node_property: ["price", "weight", "width", "height"],
  top_limit: 1
}) YIELD node1, node2, similarity
```

Result:

| node1 | node2 | similarity |
| -- | -- | -- |
| product1 | product2 | 0.9865294135291195 |
| product3 | product2 | 0.9342165307256634 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.similarity.stream({
  type: "cosine",
  ids: ["product1"],
  node_property: ["price", "weight", "width", "height"],
  order: "desc"
}) YIELD node1, node2, similarity
RETURN node1, node2, similarity
```

Result:

| node1 | node2 | similarity |
| -- | -- | -- |
| product1 | product2 | 0.9865294135291195 |
| product1 | product3 | 0.8788584075196542 |
| product1 | product4 | 0.8168761502672031 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `pairCount` | `INT` | Number of node pairs computed |
| `minSimilarity` | `FLOAT` | Minimum similarity score |
| `maxSimilarity` | `FLOAT` | Maximum similarity score |
| `avgSimilarity` | `FLOAT` | Average similarity score |

```gql
CALL algo.similarity.stats({
  type: "cosine",
  node_property: ["price", "weight", "width", "height"]
}) YIELD pairCount, minSimilarity, maxSimilarity, avgSimilarity
```

Result:

| pairCount | minSimilarity | maxSimilarity | avgSimilarity |
| -- | -- | -- | -- |
| 12 | 0.8168761502672031 | 0.9865294135291195 | 0.9047702651283608 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `similarity` column in results to a property. Map: explicit column-to-property mapping (e.g., `{similarity: 'cos_score'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `similarity` | `FLOAT` | Computed cosine similarity score |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.similarity.write({
  type: "cosine",
  ids: ["product1", "product2"],
  node_property: ["price", "weight", "width", "height"]
}, {
  db: {
    property: "sim_score"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
