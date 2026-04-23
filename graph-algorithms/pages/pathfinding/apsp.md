# All-Pairs Shortest Path (APSP)

## Overview

The All-Pairs Shortest Path (APSP) algorithm computes the shortest path distance between every pair of reachable nodes in the graph. Unlike single-source algorithms (e.g., Delta-Stepping, SPFA) that compute distances from one source, APSP computes distances between all pairs simultaneously.

## Concepts

### All-Pairs Shortest Path

For a graph with `N` nodes, there are up to `N×(N-1)` directed pairs or `N×(N-1)/2` undirected pairs. APSP computes the shortest path distance for each reachable pair. Unreachable pairs (in disconnected graphs) are excluded from results.

This implementation runs parallel BFS from every node to compute all pairwise distances. It is best suited for small to medium graphs due to the `O(V²+VE)` computational cost.

## Considerations

- The algorithm computes unweighted shortest paths.

## Example Graph

<center><img src="images/shortest-example.drawio.svg"/></center>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}),
       (A)-[:default]->(B), (A)-[:default]->(F),
       (B)-[:default]->(C), (B)-[:default]->(D),
       (B)-[:default]->(F), (D)-[:default]->(E),
       (D)-[:default]->(F), (E)-[:default]->(G),
       (F)-[:default]->(E)
```

## Parameters

This algorithm accepts no parameters.

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `source` | `STRING` | Source node identifier (`_id`) |
| `target` | `STRING` | Target node identifier (`_id`) |
| `distance` | `INT` | Shortest path distance (hop count) |

```gql
CALL algo.apsp() YIELD source, target, distance
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.apsp.stream() YIELD source, target, distance
FILTER source = "A"
RETURN source, target, distance
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `pairCount` | `INT` | Total number of reachable source-target pairs |
| `maxDistance` | `INT` | Maximum shortest path distance across all pairs |

```gql
CALL algo.apsp.stats() YIELD pairCount, maxDistance
```