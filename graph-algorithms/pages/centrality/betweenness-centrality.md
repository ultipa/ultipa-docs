# Betweenness Centrality

## Overview

Betweenness centrality measures the likelihood of a node being on the shortest paths between any two other nodes. This metric effectively identifies "bridge" nodes that facilitate connectivity between different parts of a graph.

Betweenness centrality scores range from 0 to 1 (when normalized), with higher scores indicating nodes that exert greater influence over the flow and connectivity of the network.

References:

- L.C. Freeman, <a href="https://www.researchgate.net/profile/Linton-Freeman-2/publication/216637282_A_Set_of_Measures_of_Centrality_Based_on_Betweenness/links/54415c660cf2a76a3cc7e199/A-Set-of-Measures-of-Centrality-Based-on-Betweenness.pdf" target="_blank">A Set of Measures of Centrality Based on Betweenness</a> (1977)
- L.C. Freeman, <a href="https://www.albany.edu/~ravi/pdfs/freeman_1978.pdf" target="_blank">Centrality in Social Networks Conceptual Clarification</a> (1978)

## Concepts

### Shortest Path

The shortest paths between two nodes are the paths that contain the fewest edges. When considering edge weights, the (weighted) shortest paths are those with the lowest total weight sum.

### Betweenness Centrality

The betweenness centrality of a node `x` is computed by:

<div align=center><img width=170 src="https://img.ultipa.cn/img/2025-04-30-12-19-59-bc.jpg"></div>

where,

- `i` and `j` are two distinct nodes in the graph, excluding `x`.
- <code>σ<sub>ij</sub></code> is the total number of shortest paths between `i` and `j`.
- <code>σ<sub>ij</sub>(x)</code> is the number of shortest paths between `i` and `j` that pass through node `x`.
- <code>σ<sub>ij</sub>(x)/σ<sub>ij</sub></code> gives the probability that `x` lies in the shortest paths between `i` and `j`. Note that if `i` and `j` are not connected, <code>σ<sub>ij</sub>(x)/σ<sub>ij</sub></code> is 0.

The final value is normalized by the factor `(k – 1)(k – 2)/2`, where `k` is the total number of nodes in the graph. This normalization ensures the result lies within a fixed range, making it comparable across graphs of different sizes.

<center><img src="https://img.ultipa.cn/img/2025-04-30-14-13-19-bc.jpg"></center>

The betweenness centrality of node `A` is computed as: `(1/2 + 1 + 2/3 + 1/2 + 1 + 2/3) / (4 * 3 / 2) = 0.722222`.

## Example Graph

<div align=center><img src="images/betweenness-example.drawio.svg"/></div>

Run the following statements on an empty graph to insert data:

```gql
INSERT (Sue:user {_id: "Sue"}), (Dave:user {_id: "Dave"}),
       (Ann:user {_id: "Ann"}), (Mark:user {_id: "Mark"}),
       (May:user {_id: "May"}), (Jay:user {_id: "Jay"}),
       (Billy:user {_id: "Billy"}),
       (Dave)-[:know]->(Sue), (Dave)-[:know]->(Ann),
       (Mark)-[:know]->(Dave), (May)-[:know]->(Mark),
       (May)-[:know]->(Jay), (Jay)-[:know]->(Ann)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `ids` | `LIST` | / | `_id`s of nodes to compute (empty = all nodes). |
| `direction` | `STRING` | `both` | Edge direction: `in`, `out`, or `both`. |
| `normalized` | `BOOL` | `false` | Whether to normalize scores to [0, 1]. |
| `samplingSize` | `INT` | `0` | Number of source nodes to sample (0 = all). Recommended for large graphs. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `score`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `score` | `FLOAT` | Betweenness centrality score |
| `rank` | `INT` | Rank position (1 = highest betweenness) |

Normalized betweenness centrality for all nodes:

```gql
CALL algo.betweenness({
  normalized: true,
  order: "desc"
}) YIELD nodeId, score, rank
```

Result:

| nodeId | score | rank |
| -- | -- | -- |
| Dave | 0.6666666666666666 | 1 |
| Mark | 0.26666666666666666 | 2 |
| Ann | 0.26666666666666666 | 3 |
| May | 0.13333333333333333 | 4 |
| Jay | 0.13333333333333333 | 5 |
| Sue | 0 | 6 |
| Billy | 0 | 7 |

With sampling for large graphs:

```gql
CALL algo.betweenness({
  normalized: true,
  samplingSize: 100,
  order: "desc"
}) YIELD nodeId, score, rank
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.betweenness.stream({
  normalized: true,
  order: "desc"
}) YIELD nodeId, score
FILTER score > 0.5
RETURN nodeId, score
```

Result:

| nodeId | score |
| -- | -- |
| Dave | 0.6666666666666666 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `minScore` | `FLOAT` | Minimum betweenness score |
| `maxScore` | `FLOAT` | Maximum betweenness score |
| `avgScore` | `FLOAT` | Average betweenness score |

```gql
CALL algo.betweenness.stats({normalized: true}) YIELD nodeCount, minScore, maxScore, avgScore
```

Result:

| nodeCount | minScore | maxScore | avgScore |
| -- | -- | -- | -- |
| 7 | 0 | 0.6666666666666666 | 0.2095238095238095 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `score` column in results to a property. Map: explicit column-to-property mapping (e.g., `{score: 'bc_score', rank: 'bc_rank'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `score` | `FLOAT` | Betweenness centrality score |
| `rank` | `INT` | Rank position |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.betweenness.write({normalized: true}, {
  db: {
    property: "bc_score"                                // String: writes score to one property
    // property: {score: "bc_score", rank: "bc_rank"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
