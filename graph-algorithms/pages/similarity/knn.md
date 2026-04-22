# K-Nearest Neighbors (KNN)

## Overview

KNN (K-Nearest Neighbors) finds the K most similar nodes for each node based on neighborhood structure. Useful for building similarity graphs and recommendation systems. For each node, the algorithm identifies its K closest neighbors by comparing neighborhood overlap using the specified similarity metric: jaccard, cosine, or overlap.

Three metrics are supported:

- **Jaccard**: Intersection over union of neighbor sets. See <a href="/docs/graph-algorithms/jaccard-similarity">Jaccard Similarity</a> for details.
- **Overlap**: Intersection over the smaller neighbor set. See <a href="/docs/graph-algorithms/overlap-similarity">Overlap Similarity</a> for details.
- **Cosine**: Cosine similarity between node property vectors. See <a href="/docs/graph-algorithms/cosine-similarity">Cosine Similarity</a> for details.

## Example Graph

<center><img src="images/knn-example.drawio.svg"/></center>

```gql
INSERT (Sue:user {_id: "Sue", age: 28, score: 85}),
       (Dave:user {_id: "Dave", age: 35, score: 72}),
       (Ann:user {_id: "Ann", age: 30, score: 90}),
       (Mark:user {_id: "Mark", age: 32, score: 78}),
       (May:user {_id: "May", age: 26, score: 88}),
       (Jay:user {_id: "Jay", age: 29, score: 82}),
       (Billy:user {_id: "Billy", age: 24, score: 65}),
       (Dave)-[:know]->(Sue), (Dave)-[:know]->(Ann),
       (Mark)-[:know]->(Dave), (May)-[:know]->(Mark),
       (May)-[:know]->(Jay), (Jay)-[:know]->(Ann),
       (Ann)-[:know]->(Billy), (Mark)-[:know]->(Ann)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `k` | `INT` | `10` | Number of nearest neighbors to find per node. |
| `metric` | `STRING` | `jaccard` | Similarity metric to use: `jaccard`, `overlap`, or `cosine`. |
| `node_property` | `LIST` | / | Numeric node properties to form vectors (required for `cosine` metric). |
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
  k: 1,
  metric: "cosine",
  node_property: ["age", "score"]
}) YIELD node1, node2, similarity, rank
RETURN node1, node2, similarity, rank
```

Result:

| node1 | node2 | similarity | rank |
| -- | -- | -- | -- |
| May | Sue | 0.9995215341318416 | 1 |
| Mark | Billy | 0.9993659036354446 | 1 |
| Jay | Billy | 0.999905156811448 | 1 |
| Sue | Ann | 0.9999937570038613 | 1 |
| Dave | Mark | 0.9980061858262149 | 1 |
| Billy | Jay | 0.999905156811448 | 1 |
| Ann | Sue | 0.9999937570038613 | 1 |

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
  metric: "overlap"
}) YIELD nodeCount, pairCount, minSimilarity, maxSimilarity, avgSimilarity
```

Result:

| nodeCount | pairCount | minSimilarity | maxSimilarity | avgSimilarity |
| -- | -- | -- | -- | -- |
| 7 | 19 | 0.3333333333333333 | 1 | 0.8596491228070174 |

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
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.knn.write({k: 5, metric: "jaccard"}, {
  db: {
    property: "sim_score"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
