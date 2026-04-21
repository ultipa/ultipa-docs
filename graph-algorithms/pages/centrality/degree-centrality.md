# Degree Centrality

## Overview

The Degree Centrality finds important nodes in the network, it measures the number of incoming and/or outgoing edges incident to the node, or the sum of weights of those edges. Degree is the simplest and most efficient graph algorithm since it only considers the 1-hop neighborhood of nodes. Degree plays a vital role in scientific computing, feature extraction, supernode recognition and other fields.

## Concepts

### In-Degree and Out-Degree

The number of incoming edges a node has is called its <b>in-degree</b>; accordingly, the number of outgoing edges is called <b>out-degree</b>. If ignores edge direction, it is <b>degree</b>.

<div align=center drawio-diagram='1443' drawio-name="draw_c79beb875cd64cdfa0e3cb4647110abb.jpg"><img src="https://img.ultipa.cn/draw/draw_c79beb875cd64cdfa0e3cb4647110abb.jpg?v='1642759847524'"/></div>

In this graph, the red node has in-degree of 4 and out-degree of 3, and its degree is 7. A directed self-loop is regarded as both an incoming and an outgoing edge.

### Weighted Degree

In many applications, each edge of a graph has an associated numeric value, called <b>weight</b>. In weighted graph, <b>weighted degree</b> of a node is the sum of weights of all its neighbor edges. Unweighted degree is equivalent to when all edge weights are 1.

<div align=center drawio-diagram='1444' drawio-name='draw_bd6ced106a164be3865f9a21d578ede7.jpg'><img src="https://img.ultipa.cn/draw/draw_bd6ced106a164be3865f9a21d578ede7.jpg?v='1642759974332'"/></div>

In this weighted graph, the red node has weighted in-degree of `0.5 + 0.3 + 2 + 1 = 3.8` and weighted out-degree of `1 + 0.2 + 2 = 3.2`, and its weighted degree is `3.2 + 3.8 = 7`.

## Considerations

- The degree of an isolated node depends only on its self-loop. If it has no self-loop, degree is 0.
- Every self-loop is counted as two edges attaching to its node. Directed self-loop is viewed as an incoming edge and an outgoing edge.

## Example Graph

<div align=center drawio-diagram='19442' drawio-name='draw_cece848c2c7548dab62312fa5c57f0a3.jpg'><img src="https://img.ultipa.cn/draw/draw_cece848c2c7548dab62312fa5c57f0a3.jpg?v='1730948974639'"/></div>


```gql
INSERT (Mike:user {_id: "Mike"}), (Cathy:user {_id: "Cathy"}),
       (Anna:user {_id: "Anna"}), (Joe:user {_id: "Joe"}),
       (Sam:user {_id: "Sam"}), (Bob:user {_id: "Bob"}),
       (Bill:user {_id: "Bill"}), (Tim:user {_id: "Tim"}),
       (Mike)-[:follow {score: 1.9}]->(Cathy), (Cathy)-[:follow {score: 1.8}]->(Mike),
       (Mike)-[:follow {score: 1.2}]->(Anna), (Cathy)-[:follow {score: 2.6}]->(Anna),
       (Cathy)-[:follow {score: 0.2}]->(Joe), (Joe)-[:follow {score: 4.2}]->(Anna),
       (Bob)-[:follow {score: 1.7}]->(Joe), (Sam)-[:follow {score: 3.5}]->(Bob),
       (Sam)-[:follow {score: 0.8}]->(Anna), (Bill)-[:follow {score: 2.3}]->(Anna)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `ids` | `LIST` | / | `_id`s of nodes to compute (empty = all nodes). |
| `direction` | `STRING` | `both` | Edge direction: `in`, `out`, or `both`. |
| `normalized` | `BOOL` | `false` | Whether to normalize scores. When `true`, uses `score_base` to determine the denominator. |
| `score_base` | `STRING` | `max` | Normalization base, only effective when `normalized` is `true`. `max` divides by the max degree; `count` divides by node count - 1. |
| `weight` | `STRING` or `LIST` | / | Edge property name(s) for weighted degree. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `score`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `degree` | `FLOAT` | Degree count (or weighted sum) |
| `score` | `FLOAT` | Degree score (normalized if `normalized` is true) |
| `inDegree` | `INT` | In-degree count |
| `outDegree` | `INT` | Out-degree count |
| `weightScores` | `MAP` | Per-property weighted degree breakdown (only present when `weight` is used) |

Normalized degree for all nodes:

```gql
CALL algo.degree({
  normalized: true,
  order: "desc"
}) YIELD nodeId, degree, score, inDegree, outDegree
```

Result:

| nodeId | degree | score | inDegree | outDegree |
| -- | -- | -- | -- | -- |
| Anna | 5 | 1 | 5 | 0 |
| Cathy | 4 | 0.8 | 1 | 3 |
| Joe | 3 | 0.6 | 2 | 1 |
| Mike | 3 | 0.6 | 1 | 2 |
| Bob | 2 | 0.4 | 1 | 1 |
| Sam | 2 | 0.4 | 0 | 2 |
| Bill | 1 | 0.2 | 0 | 1 |
| Tim | 0 | 0 | 0 | 0 |

Out-degree top 3:

```gql
CALL algo.degree({
  direction: "out",
  order: "desc",
  limit: 3
}) YIELD nodeId, degree
```

Result:

| nodeId | degree |
| -- | -- |
| Cathy | 3 |
| Mike | 2 |
| Sam | 2 |

Weighted degree:

```gql
CALL algo.degree({
  weight: "score",
  order: "desc"
}) YIELD nodeId, degree, weightScores
```

Result:

| nodeId | degree | weightScores |
| -- | -- | -- |
| Anna | 11.1 | {score: 11.1} |
| Cathy | 6.5 | {score: 6.5} |
| Joe | 6.1 | {score: 6.1} |
| Bob | 5.2 | {score: 5.2} |
| Mike | 4.9 | {score: 4.9} |
| Sam | 4.3 | {score: 4.3} |
| Bill | 2.3 | {score: 2.3} |
| Tim | 0 | {score: 0} |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

Find neighbors of the node with the highest out-degree:

```gql
CALL algo.degree.stream({
  direction: "out",
  order: "desc",
  limit: 1
}) YIELD nodeId, degree
MATCH (src WHERE src._id = nodeId)-(neigh)
RETURN DISTINCT neigh._id
```

Result:

| neigh.\_id |
| -- |
| Anna |
| Joe |
| Mike |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `minScore` | `FLOAT` | Minimum degree score |
| `maxScore` | `FLOAT` | Maximum degree score |
| `avgScore` | `FLOAT` | Average degree score |

```gql
CALL algo.degree.stats() YIELD nodeCount, minScore, maxScore, avgScore
```

Result:

| nodeCount | minScore | maxScore | avgScore |
| -- | -- | -- | -- |
| 8 | 0 | 5 | 2.5 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `score` column to a property. Map: explicit column-to-property mapping (e.g., `{score: 'deg_score', inDegree: 'in_deg'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `degree` | `FLOAT` | Degree count |
| `score` | `FLOAT` | Degree score |
| `inDegree` | `INT` | In-degree count |
| `outDegree` | `INT` | Out-degree count |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.degree.write({}, {
  db: {
    property: "deg_score"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
