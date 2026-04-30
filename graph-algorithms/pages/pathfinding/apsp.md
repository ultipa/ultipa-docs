# All-Pairs Shortest Path (APSP)

## Overview

The All-Pairs Shortest Path (APSP) algorithm computes the shortest path distance between every pair of reachable nodes in the graph. Unlike single-source algorithms (e.g., Delta-Stepping, SPFA) that compute distances from one source, APSP computes distances between all pairs simultaneously.

## Concepts

### All-Pairs Shortest Path

For a graph with `N` nodes, there are up to `N×(N-1)` directed pairs or `N×(N-1)/2` undirected pairs. APSP computes the shortest path distance for each reachable pair. Unreachable pairs (in disconnected graphs) are excluded from results.

This implementation runs parallel BFS from every node to compute all pairwise distances. It is best suited for small to medium graphs due to the `O(V²+VE)` computational cost.

## Example Graph

<center><img src="images/shortest-example.drawio.svg"/></center>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}),
       (A)-[:default {value: 2}]->(B), (A)-[:default {value: 4}]->(F),
       (B)-[:default {value: 3}]->(C), (B)-[:default {value: 3}]->(D),
       (B)-[:default {value: 6}]->(F), (D)-[:default {value: 2}]->(E),
       (D)-[:default {value: 2}]->(F), (E)-[:default {value: 3}]->(G),
       (F)-[:default {value: 1}]->(E)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `direction` | `STRING` | `out` | Edge direction for traversal: `out`, `in`, or `both`. |
| `weight` | `STRING` | / | Edge property to use as weight. If unset, all edges have unit weight. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `source` | `STRING` | Source node identifier (`_id`) |
| `target` | `STRING` | Target node identifier (`_id`) |
| `distance` | `FLOAT` | Shortest path distance |

```gql
CALL algo.apsp({weight: "value"}) YIELD source, target, distance
```

Result:

| source | target | distance |
| -- | -- | -- |
| A | B | 2 |
| A | F | 4 |
| A | C | 5 |
| A | D | 5 |
| A | E | 5 |
| A | G | 8 |
| B | C | 3 |
| B | D | 3 |
| B | F | 5 |
| B | E | 5 |
| B | G | 8 |
| D | E | 2 |
| D | F | 2 |
| D | G | 5 |
| E | G | 3 |
| F | E | 1 |
| F | G | 4 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.apsp.stream({weight: "value"}) YIELD source, target, distance
FILTER source = "A"
RETURN source, target, distance
```

Result:

| source | target | distance |
| -- | -- | -- |
| A | E | 5 |
| A | D | 5 |
| A | G | 8 |
| A | F | 4 |
| A | C | 5 |
| A | B | 2 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `pairCount` | `INT` | Total number of reachable source-target pairs |
| `maxDistance` | `FLOAT` | Maximum shortest path distance across all pairs |

```gql
CALL algo.apsp.stats({weight: "value"}) YIELD pairCount, maxDistance
```

Result:

| pairCount | maxDistance |
| -- | -- |
| 17 | 8 |