# Harmonic Centrality

## Overview

Harmonic Centrality is a variant of <a target="_blank" href="/docs/graph-analytics-algorithms/closeness-centrality">Closeness Centrality</a>. The average shortest distance measurement proposed by harmonic centrality is compatible with infinite values which would occur in a disconnected graph. Harmonic centrality was first proposed by M. Marchiori and V. Latora in 2000, and then by A. Dekker and Y. Rochat in 2005 and 2009:

- M. Marchiori, V. Latora, <a target="_blank" href="https://arxiv.org/pdf/cond-mat/0008357.pdf">Harmony in the Small-World</a> (2000)
- A. Dekker, <a target="_blank" href="https://www.cmu.edu/joss/content/articles/volume6/dekker/">Conceptual Distance in Social Network Analysis</a> (2005)
- Y. Rochat, <a target="_blank" href="https://docslib.org/docs/524811/closeness-centrality-extended-to-unconnected-graphs-the-harmonic-centrality-index">Closeness Centrality Extended to Unconnected Graphs: The Harmonic Centrality Index</a> (2009)

Harmonic centrality ranges from 0 to 1; higher scores indicate that a node is closer to other nodes in the graph.

## Concepts

### Shortest Distance

The shortest distance between two nodes is defined as the number of edges in the shortest path connecting them. Please refer to <a target="_blank" href="/docs/graph-analytics-algorithms/closeness-centrality">Closeness Centrality</a> for more details.

### Harmonic Mean

The harmonic mean is the reciprocal of the arithmetic mean of the reciprocals of the variables. The formula for calculating the arithmetic mean `A` and the harmonic mean `H` is as follows:

<center><img width="300" src="https://img.ultipa.cn/2022-08-08-11-08-40-mean.jpg"></center>

A classic application of harmonic mean is to calculate the average speed when traveling back and forth at different speeds. Suppose there is a round trip, the forward and backward speeds are 30 km/h and 10 km/h respectively. What is the average speed for the entire trip?

The arithmetic mean `A = (30+10)/2 = 20 km/h` is not appropriate in this case. Since the backward journey takes three times as long as the forward, during most time of the entire trip the speed stays at 10 km/h, so we expect the average speed to be closer to 10 km/h.

Assuming the one-way distance is 1, the average speed that takes travel time into consideration is `2/(1/30+1/10) = 15 km/h`. This value, the harmonic mean, is adjusted by the time spent during each journey.

### Harmonic Centrality

Harmonic centrality score of a node defined by this algorithm is the inverse of the harmonic mean of the shortest distances from the node to all other nodes. The formula is:

<div align=center><img width=160 src="https://img.ultipa.cn/img/2023-03-07-14-09-45-hc.jpg"></div>

where `x` is the target node,  `y` is any node in the graph other than `x`, `k-1` is the number of `y`, `d(x,y)` is the shortest distance between `x` and `y`, `d(x,y) = +∞` when `x` and `y` are not reachable to each other, in this case `1/d(x,y) = 0`.

<div align='center' drawio-diagram='2849' drawio-name='draw_f26abcc1ee494ff5a8f1c4286f20f31a.jpg'><img src="https://img.ultipa.cn/draw/draw_f26abcc1ee494ff5a8f1c4286f20f31a.jpg?v='1659930545560'"/></div>

The harmonic centrality of node <i>a</i> in the above graph is `(1 + 1/2 + 1/+∞ + 1/+∞) / 4 = 0.375`, and the harmonic centrality of node <i>d</i> is `(1/+∞ + 1/+∞ + 1/+∞ + 1) / 4 = 0.25`.

## Considerations

- The harmonic centrality score of isolated nodes is 0.

## Example Graph

<div align=center drawio-diagram='19734' drawio-name="draw_9505cf4d05b6463aac6c69057482c569.jpg"><img src="https://img.ultipa.cn/draw/draw_9505cf4d05b6463aac6c69057482c569.jpg?v='1735028023494'"/></div>

```gql
INSERT (A:user {_id: "A"}), (B:user {_id: "B"}),
       (C:user {_id: "C"}), (D:user {_id: "D"}),
       (E:user {_id: "E"}), (F:user {_id: "F"}),
       (G:user {_id: "G"}), (H:user {_id: "H"}),
       (A)-[:vote {score: 2}]->(B), (A)-[:vote {score: 3}]->(E),
       (B)-[:vote {score: 4}]->(B), (B)-[:vote {score: 2}]->(C),
       (C)-[:vote {score: 3}]->(A), (D)-[:vote {score: 1}]->(A),
       (F)-[:vote {score: 1}]->(G)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `ids` | `LIST` | / | `_id`s of nodes to compute (empty = all nodes). |
| `direction` | `STRING` | `both` | Edge direction: `in`, `out`, or `both`. |
| `weight` | `STRING` or `LIST` | / | Numeric edge property for weighted shortest paths. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `score`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `score` | `FLOAT` | Harmonic centrality score (higher = more central) |
| `rank` | `INT` | Rank position (1 = highest harmonic centrality) |

Harmonic centrality for all nodes:

```gql
CALL algo.harmonic({
  order: "desc"
}) YIELD nodeId, score, rank
```

Result:

| nodeId | score | rank |
| -- | -- | -- |
| A | 0.5714285714285714 | 1 |
| C | 0.42857142857142855 | 2 |
| B | 0.42857142857142855 | 3 |
| E | 0.3571428571428571 | 4 |
| D | 0.3571428571428571 | 5 |
| G | 0.14285714285714285 | 6 |
| F | 0.14285714285714285 | 7 |
| H | 0 | 8 |

Weighted harmonic centrality:

```gql
CALL algo.harmonic({
  ids: ["A", "B"],
  weight: ["score"]
}) YIELD nodeId, score, rank
```

Result:

| nodeId | score | rank |
| -- | -- | -- |
| A	| 0.3095238095238095 | 1 |
| B	| 0.21904761904761902	| 2 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.harmonic.stream({
  direction: "in"
}) YIELD nodeId, score
FILTER score = 0
RETURN nodeId, score
```

Result:

| nodeId | score |
| -- | -- |
| D | 0 |
| F | 0 |
| H | 0 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `minScore` | `FLOAT` | Minimum harmonic centrality score |
| `maxScore` | `FLOAT` | Maximum harmonic centrality score |
| `avgScore` | `FLOAT` | Average harmonic centrality score |

```gql
CALL algo.harmonic.stats() YIELD nodeCount, minScore, maxScore, avgScore
```

Result:

| nodeCount | minScore | maxScore | avgScore |
| -- | -- | -- | -- |
| 8 | 0 | 0.5714285714285714 | 0.3035714285714286 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `score` column in results to a property. Map: explicit column-to-property mapping (e.g., `{score: 'hc_score', rank: 'hc_rank'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `score` | `FLOAT` | Harmonic centrality score |
| `rank` | `INT` | Rank position |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.harmonic.write({}, {
  db: {
    property: "hc_score"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
