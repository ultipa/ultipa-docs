# Yen's K-Shortest Paths

## Overview

Yen's algorithm finds the K shortest simple paths between a source node and a target node. Unlike Dijkstra's shortest path which returns only the single best path, Yen's algorithm returns multiple alternative paths ranked by cost, providing route diversity. This algorithm is commonly used to identify backup paths in case the primary path fails.

The algorithm was proposed by Jin Y. Yen in 1971:

- J.Y. Yen, <a target="_blank" href="https://people.csail.mit.edu/minilek/yen_kth_shortest.pdf">Finding the K Shortest Loopless Paths in a Network</a> (1971)

## Concepts

### K-Shortest Paths

Given a source and target, there may be many paths connecting them. Yen's algorithm finds the top `K` paths with the lowest cost, where each path contains no repeated nodes.

The algorithm works by:

1. Find the shortest path from source to target using <a target="_blank" href="/docs/graph-algorithms/dijkstra-shortest-path">Dijkstra's algorithm</a>. This becomes the 1st shortest path.
2. For each previously found path, consider every node along it as a potential **spur node** (deviation point). At each spur node:
   - Temporarily remove edges that overlap with previously found paths at this spur node, to force a different route.
   - Find the shortest path from the spur node to the target using Dijkstra's algorithm. This is the **spur path**.
   - Combine the portion of the original path from source to the spur node (**root path**) with the spur path to form a **candidate path**.
3. Among all candidate paths, select the one with the lowest cost as the next shortest path.
4. Repeat steps 2-3 until`K` paths are found or no more candidates exist.

## Considerations

- The algorithm only finds simple paths (no cycles).
- All edge weights must be non-negative.

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
| `source` | `STRING` | / | **Required.** Source node `_id`. |
| `target` | `STRING` | / | **Required.** Target node `_id`. |
| `k` | `INT` | `3` | Number of shortest paths to find. |
| `direction` | `STRING` | `out` | Edge direction: `out`, `in`, or `both`. |
| `weight` | `STRING` | / | Edge property to use as weight. If unset, all edges have unit weight. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `path` | `LIST` | Ordered list of node `_id`s in the path |
| `cost` | `FLOAT` | Total path cost |
| `rank` | `INT` | Path rank (1 = shortest) |

```gql
CALL algo.yens({
  source: "A",
  target: "G",
  k: 3,
  weight: "value"
}) YIELD path, cost, rank
```

Result:

| path | cost | rank |
| -- | -- | -- |
| ["A", "F", "E", "G"] | 8 | 1 |
| ["A", "B", "D", "E", "G"] | 10 | 2 |
| ["A", "B", "D", "F", "E", "G"] | 11 | 3 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.yens.stream({
  source: "A",
  target: "G",
  k: 3,
  weight: "value"
}) YIELD path, cost, rank
RETURN path, cost, rank
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `pathsFound` | `INT` | Number of shortest paths found |
| `minCost` | `FLOAT` | Cost of the shortest path |
| `maxCost` | `FLOAT` | Cost of the longest path among K shortest |

```gql
CALL algo.yens.stats({
  source: "A",
  target: "G",
  k: 3,
  weight: "value"
}) YIELD pathsFound, minCost, maxCost
```

Result:

| pathsFound | minCost | maxCost |
| -- | -- | -- |
| 3 | 8 | 11 |
