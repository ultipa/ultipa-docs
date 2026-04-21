# K-Nearest Neighbors

## Overview

KNN (K-Nearest Neighbors) finds the K most similar nodes for each node based on neighborhood structure. Useful for building similarity graphs and recommendation systems. For each node, the algorithm identifies its K closest neighbors by comparing neighborhood overlap using the specified similarity metric: jaccard, cosine, or overlap.

## Concepts

This algorithm compares nodes based on their **neighborhood structure** (not node properties). Each node is represented by its set of neighbors, and similarity is computed between these neighbor sets.

Three metrics are supported:

- **Jaccard**: Intersection over union of neighbor sets. See <a href="/docs/graph-analytics-algorithms/jaccard-similarity">Jaccard Similarity</a> for details.
- **Cosine**: Cosine similarity between binary neighbor vectors (1 = neighbor present, 0 = absent). This is topology-based, not property-based.
- **Overlap**: Intersection over the smaller neighbor set. See <a href="/docs/graph-analytics-algorithms/overlap-similarity">Overlap Similarity</a> for details.

## Considerations

- The algorithm treats all edges as undirected.
- Self-loops are ignored when computing neighborhoods.

## Example Graph

<div align=center><img src="images/knn-example.drawio.svg"/></div>


```gql
INSERT (Sue:user {_id: "Sue"}), (Dave:user {_id: "Dave"}),
       (Ann:user {_id: "Ann"}), (Mark:user {_id: "Mark"}),
       (May:user {_id: "May"}), (Jay:user {_id: "Jay"}),
       (Billy:user {_id: "Billy"}),
       (Dave)-[:know]->(Sue), (Dave)-[:know]->(Ann),
       (Mark)-[:know]->(Dave), (May)-[:know]->(Mark),
       (May)-[:know]->(Jay), (Jay)-[:know]->(Ann),
       (Ann)-[:know]->(Billy), (Mark)-[:know]->(Ann)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `k` | `INT` | `10` | Number of nearest neighbors to find per node. |
| `metric` | `STRING` | `jaccard` | Similarity metric to use: `jaccard`, `cosine`, or `overlap`. |
| `degreeCutoff` | `INT` | `0` | Minimum degree to include a node (0 = no cutoff). |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `node1` | `STRING` | Source node identifier (`_id`) |
| `node2` | `STRING` | Neighbor node identifier (`_id`) |
| `similarity` | `FLOAT` | Similarity score |
| `rank` | `INT` | Neighbor rank (1 = most similar) |

```gql
CALL algo.knn({
  k: 2,
  metric: "jaccard"
}) YIELD node1, node2, similarity, rank
```

Result:

| node1 | node2 | similarity | rank |
| -- | -- | -- | -- |
| May | Ann | 0.5 | 1 |
| May | Dave | 0.25 | 2 |
| Mark | Jay | 0.6666666666666666 | 1 |
| Mark | Sue | 0.3333333333333333 | 2 |
| Jay | Mark | 0.6666666666666666 | 1 |
| Jay | Billy | 0.5 | 2 |
| Sue | Mark | 0.3333333333333333 | 1 |
| Sue | Ann | 0.25 | 2 |
| Dave | Billy | 0.3333333333333333 | 1 |
| Dave | May | 0.25 | 2 |
| Billy | Jay | 0.5 | 1 |
| Billy | Dave | 0.3333333333333333 | 2 |
| Ann | May | 0.5 | 1 |
| Ann | Sue | 0.25 | 2 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.knn.stream({
  k: 3,
  metric: "cosine",
  degreeCutoff: 3
}) YIELD node1, node2, similarity, rank
RETURN node1, node2, similarity, rank
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `pairCount` | `INT` | Number of neighbor pairs found |
| `minSimilarity` | `FLOAT` | Minimum similarity score |
| `maxSimilarity` | `FLOAT` | Maximum similarity score |
| `avgSimilarity` | `FLOAT` | Average similarity score |

```gql
CALL algo.knn.stats({
  k: 3,
  metric: "jaccard"
}) YIELD nodeCount, pairCount, minSimilarity, maxSimilarity, avgSimilarity
```

Result:

| nodeCount | pairCount | minSimilarity | maxSimilarity | avgSimilarity |
| -- | -- | -- | -- | -- |
| 7 | 19 | 0.16666666666666666 | 0.6666666666666666 | 0.3684210526315789 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `similarity` column in results to a property. Map: explicit column-to-property mapping (e.g., `{similarity: 'sim_score', rank: 'sim_rank'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `similarity` | `FLOAT` | Similarity score |
| `rank` | `INT` | Neighbor rank (1 = most similar) |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.knn.write({k: 5, metric: "jaccard"}, {
  db: {
    property: "sim_score"                                     // String: writes similarity to one property
    // property: {similarity: "sim_score", rank: "sim_rank"}  // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
