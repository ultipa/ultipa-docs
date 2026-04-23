# A* Shortest Path

## Overview

The A* (A-star) algorithm finds the shortest path between a source node and a target node, similar to <a href="/docs/graph-algorithms/dijkstra-shortest-path">Dijkstra's algorithm</a>, but uses a heuristic function to guide the search toward the target more efficiently.

## Concepts

### A* Algorithm

A* extends Dijkstra's algorithm by adding a **degree-based heuristic estimate**. At each step, instead of expanding the node with the smallest known distance `dist(n)`, A* expands the node with the smallest `f(n) = dist(n) + h(n)`, where:

- `dist(n)` is the actual distance from the source to node `n`
- `h(n)` is the heuristic estimate of remaining cost from node `n` to the target based on node `n`'s degree: `h(n) = 1 / (1 + degree(n))`

Nodes with higher degree get lower heuristic values, making them appear more promising — the intuition being that well-connected nodes are more likely to lead toward the target. The heuristic allows A* to explore fewer nodes than Dijkstra while still finding the optimal path.

Find the shortest path from `A` to `G` following outgoing edges in this graph:

<center><img src="images/astar-1.drawio.svg"/></center>

First, compute the heuristic `h(n)` for each node based on out-degree. For the target node, `h(n) = 0`. For nodes with no outgoing edges, `h(n) = 1`.

| | A | B | C | D | E | F | G |
| -- | -- | -- | -- | -- | -- | -- | -- |
| <b>Out-degree</b> | 2 | 3 | 0 | 2 | 1 | 1 | 0 |
| <b>`h(n)`</b> | 0.333 | 0.25 | 1 | 0.333 | 0.5 | 0.5 | 0 |

Visit nodes step-by-step in the graph from the source `A`. In each step, update `dist` and `f` for the outgoing neighbors of the visited node, and pick the next unvisited node with the lowest `f`:

**Step 1**: Visit `A`, update `B` and `F`

| Node | `dist(n)` | `h(n)` | `f(n)` | Visited | Picked |
| -- | -- | -- | -- | -- | -- |
| <span style="color:#999;">A</span> | <span style="color:#999;">0</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">Yes</span> | |
| B | 1 | 0.25 | 1.25 | No | Yes |
| F | 1 | 0.5 | 1.5 | No | Yes |

**Step 2**: Visit `B`, update `C`, `D`, and `F` (remains unchanged)

| Node | `dist(n)` | `h(n)` | `f(n)` | Visited | Picked |
| -- | -- | -- | -- | -- | -- |
| <span style="color:#999;">A</span> | <span style="color:#999;">0</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">Yes</span> | |
| <span style="color:#999;">B</span> | <span style="color:#999;">1</span> | <span style="color:#999;">0.25</span> | <span style="color:#999;">1.25</span> | <span style="color:#999;">Yes</span> | |
| F | 1 | 0.5 | 1.5 | No | Yes |
| C | 2 | 1 | 3 | No | No |
| D | 2 | 0.333 | 2.333 | No | No |

**Step 3**: Visit `F`, update `E`

| Node | `dist(n)` | `h(n)` | `f(n)` | Visited | Picked |
| -- | -- | -- | -- | -- | -- |
| <span style="color:#999;">A</span> | <span style="color:#999;">0</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">Yes</span> | |
| <span style="color:#999;">B</span> | <span style="color:#999;">1</span> | <span style="color:#999;">0.25</span> | <span style="color:#999;">1.25</span> | <span style="color:#999;">Yes</span> | |
| <span style="color:#999;">F</span> | <span style="color:#999;">1</span> | <span style="color:#999;">0.5</span> | <span style="color:#999;">1.5</span> | <span style="color:#999;">Yes</span> | |
| C | 2 | 1 | 3 | No | No |
| D | 2 | 0.333 | 2.333 | No | Yes |
| E | 2 | 0.5 | 2.5 | No | No |

**Step 4**: Visit `D`, update `E` (remains unchanged) and `F` (visited)

| Node | `dist(n)` | `h(n)` | `f(n)` | Visited | Picked |
| -- | -- | -- | -- | -- | -- |
| <span style="color:#999;">A</span> | <span style="color:#999;">0</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">Yes</span> | |
| <span style="color:#999;">B</span> | <span style="color:#999;">1</span> | <span style="color:#999;">0.25</span> | <span style="color:#999;">1.25</span> | <span style="color:#999;">Yes</span> | |
| <span style="color:#999;">F</span> | <span style="color:#999;">1</span> | <span style="color:#999;">0.5</span> | <span style="color:#999;">1.5</span> | <span style="color:#999;">Yes</span> | |
| <span style="color:#999;">D</span> | <span style="color:#999;">2</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">2.333</span> | <span style="color:#999;">Yes</span> | |
| C | 2 | 1 | 3 | No | No |
| E | 2 | 0.5 | 2.5 | No | Yes |

**Step 5**: Visit `E`, it reaches the target node `G`

| Node | `dist(n)` | `h(n)` | `f(n)` | Visited | Picked |
| -- | -- | -- | -- | -- | -- |
| <span style="color:#999;">A</span> | <span style="color:#999;">0</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">Yes</span> | |
| <span style="color:#999;">B</span> | <span style="color:#999;">1</span> | <span style="color:#999;">0.25</span> | <span style="color:#999;">1.25</span> | <span style="color:#999;">Yes</span> | |
| <span style="color:#999;">F</span> | <span style="color:#999;">1</span> | <span style="color:#999;">0.5</span> | <span style="color:#999;">1.5</span> | <span style="color:#999;">Yes</span> | |
| <span style="color:#999;">D</span> | <span style="color:#999;">2</span> | <span style="color:#999;">0.333</span> | <span style="color:#999;">2.333</span> | <span style="color:#999;">Yes</span> | |
| <span style="color:#999;">E</span> | <span style="color:#999;">2</span> | <span style="color:#999;">0.5</span> | <span style="color:#999;">2.5</span> | <span style="color:#999;">Yes</span> | |
| C | 2 | 1 | 3 | No | No |
| G | 3 | 0 | 3 | No | Yes |

The path found is `A->F->E->G`, distance = 3.

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
| `startNode` | `STRING` | / | **Required.** Source node `_id`. |
| `endNode` | `STRING` | / | **Required.** Target node `_id`. |
| `weight` | `STRING` | / | Edge property to use as weight. If unset, all edges have unit weight. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) in the path |
| `distance` | `FLOAT` | Distance from source to this node |
| `path` | `LIST` | Full shortest path as list of node `_id`s |

```gql
CALL algo.astar({
  startNode: "A",
  endNode: "G",
  weight: "value"
}) YIELD nodeId, distance, path
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.astar.stream({
  startNode: "A",
  endNode: "G",
  weight: "value"
}) YIELD nodeId, distance
RETURN nodeId, distance
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Number of nodes in the shortest path |
| `totalDistance` | `FLOAT` | Total distance of the shortest path |

```gql
CALL algo.astar.stats({
  startNode: "A",
  endNode: "G",
  weight: "value"
}) YIELD nodeCount, totalDistance
```
