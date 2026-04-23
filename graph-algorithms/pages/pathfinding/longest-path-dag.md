# Longest Path (DAG)

## Overview

The Longest Path (DAG) algorithm finds the longest path from any source node (in-degree 0) to every other node in a directed acyclic graph (DAG). It uses topological sort followed by dynamic programming to compute the longest distance efficiently.

Applications:

- **Project scheduling**: Finding the critical path — the longest chain of dependent tasks that determines the minimum project duration.
- **Pipeline depth**: Determining the maximum number of sequential stages in a data processing pipeline.
- **Dependency analysis**: Identifying the deepest dependency chain in build systems or package managers.

## Concepts

### DAG

See <a target="_blank" href="/docs/graph-algorithms/topological-sort#Directed-Acyclic-Graph-DAG">Topological Sort</a>.

### Longest Path in DAG

Finding the longest path in a general graph is NP-hard. However, in a DAG, it can be solved in linear time because the absence of cycles guarantees a topological ordering — nodes can be processed in a sequence where every edge goes from an earlier node to a later one.

<center><img src="images/longestpathdag-1.drawio.svg"></center>

The algorithm works in two steps:

1\. **Topological sort**: Order all nodes so that for every edge `u→v`, node `u` comes before `v`. See <a href="/docs/graph-algorithms/topological-sort">Topological Sort</a>.

| Node | Level |
| -- | -- |
| A, F, H | 0 |
| B, C, D, E | 1 |
| G | 2 |

2\. **Dynamic programming**: Process nodes in topological order. For each node `v`, compute `longestDistance(v) = max(longestDistance(u) + 1)` for all predecessors (incoming neighbors) `u` of `v`.

Source nodes (in-degree 0) have `longestDistance = 0`.

| Node `v` | Incoming From (`u`) | `longestDistance(v)` |
| -- | -- | -- |
| A, F, H | None | 0 |
| B | A | max(0) + 1 = 1 |
| C | A | max(0) + 1 = 1 |
| D | A or F | max(0, 0) + 1 = 1 |
| E | A or F | max(0, 0) + 1 = 1 |
| G | E or H | max(1, 0) + 1 = 2 |

Longest path distance = 2 (`A→E→G` or `F→E→G`).

## Considerations

- The algorithm only works on directed acyclic graphs (DAGs). If the graph contains a cycle, an error is returned.
- The algorithm follows outgoing edges only.

## Example Graph

<center><img src="images/longestpathdag-example.drawio.svg"></center>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (A)-[:default]->(B), (A)-[:default]->(D),
       (B)-[:default]->(C), (B)-[:default]->(E),
       (C)-[:default]->(F), (D)-[:default]->(E),
       (E)-[:default]->(F), (F)-[:default]->(G),
       (H)-[:default]->(D), (H)-[:default]->(G)
```

## Parameters

This algorithm accepts no parameters.

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `longestDistance` | `INT` | Longest distance from any source node |
| `predecessor` | `STRING` | Predecessor node on the longest path |

```gql
CALL algo.longestpathdag() YIELD nodeId, longestDistance, predecessor
```

Result:

| nodeId | longestDistance | predecessor |
| -- | -- | -- |
| A | 0 | |
| H | 0 | |
| B | 1 | A |
| D | 1 | A |
| C | 2 | B |
| E | 2 | B |
| F | 3 | C |
| G | 4 | F |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.longestpathdag.stream() YIELD nodeId, longestDistance
ORDER BY longestDistance DESC
RETURN longestDistance LIMIT 1
```

Result:

| longestDistance |
| -- |
| 4 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes in the DAG |
| `maxDistance` | `INT` | Maximum longest path distance |

```gql
CALL algo.longestpathdag.stats() YIELD nodeCount, maxDistance
```

Result:

| nodeCount | maxDistance |
| -- | -- |
| 8 | 4 |
