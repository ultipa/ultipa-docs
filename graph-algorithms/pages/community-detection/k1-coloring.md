# K-1 Coloring

## Overview

The K-1 Coloring algorithm assigns colors to nodes so that no two adjacent nodes share the same color, while minimizing the total number of colors used.

- U.V. Çatalyürek, J. Feo, A.H. Gebremedhin, M. Halappanavar, A. Pothen, <a href="https://arxiv.org/pdf/1205.3809" target="_blank">Graph Coloring Algorithms for Multi-core and Massively Multithreaded Architectures</a> (2018)

## Concepts

### Distance-1 Graph Coloring

Distance-1 graph coloring, also known as K-1 graph coloring, is a concept in graph theory where the goal is to assign colors (represented by integers `0`, `1`, `2`, ...) to the nodes of a graph such that no two nodes at distance 1 from each other (i.e., adjacent nodes) share the same color. The objective is also to minimize the number of colors used.

One of the most famous applications of graph coloring is geographical map coloring, where regions on a map are represented as nodes, and edges connect adjacent regions (those sharing a border). The task is to color the regions so that no two adjacent regions have the same color.

This concept has many practical applications beyond maps. For example, in school scheduling, each class is represented as a node, and edges indicate conflicts (such as two classes needing the same room). By coloring the graph, each class is assigned a "color" that represents a different time slot, ensuring no two conflicting classes are scheduled simultaneously.

### Greedy Coloring Algorithm

The graph coloring problem is NP-hard to solve optimally, but near-optimal solutions can be obtained using a greedy algorithm.

At the beginning of the greedy algorithm, each node `v` in the graph is initialized as uncolored. The algorithm processes each node `v` as below:

<div align=center drawio-diagram='20039' drawio-name='draw_995b203c523049b6b7db1f7689f97744.jpg'><img src="https://img.ultipa.cn/draw/draw_995b203c523049b6b7db1f7689f97744.jpg?v='1735629065995'"/></div>

- For every adjacent node `w` of `v`, mark the color of `w` as forbidden for `v`.
- Assign the smallest available color to `v` that is different from all its forbidden colors.

The algorithm uses an iterative parallel approach: in each iteration, colors are tentatively assigned in parallel, then conflicts (adjacent nodes with the same color) are detected and re-colored in the next iteration.

## Considerations

- The algorithm treats all edges as undirected.
- The greedy approach does not guarantee the minimum number of colors — it produces a near-optimal solution.
- Results may vary between runs due to parallel execution order.

## Example Graph

<div align=center drawio-diagram='20043' drawio-name='draw_f3d5090e0ba04447bdaaafb3a26063a8.jpg'><img src="https://img.ultipa.cn/draw/draw_f3d5090e0ba04447bdaaafb3a26063a8.jpg?v='1735636153998'"/></div>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (A)-[:default]->(B), (A)-[:default]->(C),
       (A)-[:default]->(D), (A)-[:default]->(E),
       (A)-[:default]->(G), (D)-[:default]->(E),
       (D)-[:default]->(F), (E)-[:default]->(F),
       (G)-[:default]->(D), (G)-[:default]->(H)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `maxIterations` | `INT` | `10` | Maximum number of conflict resolution iterations. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `color`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `color` | `INT` | Assigned color |
| `colorCount` | `INT` | Total number of colors used |

```gql
CALL algo.k1coloring() YIELD nodeId, color, colorCount
```

Result:

| nodeId | color | colorCount |
| -- | -- | -- |
| E | 1 | 4 |
| D | 2 | 4 |
| G | 1 | 4 |
| F | 0 | 4 |
| A | 3 | 4 |
| C | 0 | 4 |
| B | 0 | 4 |
| H | 0 | 4 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.k1coloring.stream() YIELD nodeId, color
RETURN color, COLLECT(nodeId) AS nodes, COUNT(nodeId) AS size
GROUP BY color
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `colorCount` | `INT` | Total number of colors used |

```gql
CALL algo.k1coloring.stats() YIELD nodeCount, colorCount
```

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `color` column in results to a property. Map: explicit column-to-property mapping (e.g., `{color: 'node_color'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `color` | `INT` | Assigned color |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.k1coloring.write({}, {
  db: {
    property: "node_color"                    // String: writes color to one property
    // property: {color: "node_color"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
