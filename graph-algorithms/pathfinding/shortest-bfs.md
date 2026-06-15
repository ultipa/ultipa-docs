# Shortest Path (BFS)

## Overview

The Shortest Path (BFS) algorithm finds the shortest path between a source node and a target node in an unweighted graph using bidirectional breadth-first search. By searching simultaneously from both the source and target, it meets in the middle for significant speedup on large graphs compared to a single-direction BFS.

## Concepts

### Why BFS for Shortest Paths

In unweighted graphs, <a href="/docs/graph-algorithms/bfs">BFS</a> naturally finds the shortest path because it explores nodes level by level — the first time it reaches a node is always via the fewest hops. This makes BFS the optimal choice for unweighted shortest path problems, while other algorithms like <a href="/docs/graph-algorithms/dijkstra-shortest-path">Dijkstra's algorithm</a> is needed for weighted graphs.

### Bidirectional BFS

Standard BFS explores outward from the source node layer by layer until reaching the target. **Bidirectional BFS** improves on this by running two BFS searches in parallel — one from the source and one from the target. The search terminates when the two frontiers meet, typically exploring far fewer nodes than a single-direction search.

At each step, the algorithm expands the smaller frontier first, ensuring balanced exploration.

## Considerations

- This algorithm requires the compute engine topology. Run `ALTER GRAPH <graphName> SET COMPUTE ENABLED` before using it.
- The algorithm treats all edges as unweighted (each edge has cost 1).
- Returns distance `-1` if no path exists between source and target.

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

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `source` | `STRING` | / | **Required.** Source node `_id`. |
| `target` | `STRING` | / | **Required.** Target node `_id`. |
| `direction` | `STRING` | `out` | Edge direction: `in`, `out`, or `both`. |
| `maxDepth` | `INT` | `10` | Maximum search depth. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `distance` | `INT` | Shortest path distance (-1 if no path exists) |
| `path` | `STRING` | Shortest path as node `_id`s (e.g., "A -> B -> D") |

```gql
CALL algo.shortest_bfs({
  source: "A",
  target: "G"
}) YIELD distance, path
```

Result:

| distance | path |
| -- | -- |
| 3 | A -> F -> E -> G |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `distance` | `INT` | Shortest path distance (-1 if no path exists) |
| `nodesExplored` | `INT` | Total nodes explored during search |

```gql
CALL algo.shortest_bfs.stats({
  source: "A",
  target: "G"
}) YIELD distance, nodesExplored
```

Result:

| distance | nodesExplored |
| -- | -- |
| 3 | 7 |
