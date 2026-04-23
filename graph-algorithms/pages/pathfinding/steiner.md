# Steiner Tree

## Overview

The Steiner Tree algorithm finds a minimum-weight tree that connects a set of **terminal nodes** through a specified **root node**. Unlike a <a href="/docs/graph-algorithms/mst">minimum spanning tree</a> which connects all nodes, a Steiner tree only needs to connect the specified terminals — it may include additional intermediate nodes (called **Steiner nodes**) if they help reduce the total weight.

Applications:

- **Network design**: Finding the cheapest way to connect a subset of locations.
- **VLSI circuit design**: Connecting pins with minimum wiring.
- **Multicast routing**: Connecting a set of receivers to a source.

## Concepts

### Steiner Tree

Given a graph, a root node, and a set of terminal nodes, the **Steiner tree** is the minimum-weight subgraph that connects the root to all terminals. The problem is NP-hard, so this implementation uses an approximation:

1. For each terminal node, find the shortest path from the root to that terminal.
2. Union all these shortest paths into a single tree.
3. Remove redundant edges to produce a minimal tree.

This heuristic may not find the optimal Steiner tree, but runs efficiently and produces good results in practice.

## Considerations

- The algorithm follows outgoing edges only.

## Example Graph

<center><img src="images/mst-kspanningtree-steiner-example.drawio.svg"/></center>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (A)-[:default {distance: 1}]->(B), (A)-[:default {distance: 2.4}]->(C),
       (A)-[:default {distance: 1.2}]->(D), (A)-[:default {distance: 0.7}]->(E),
       (A)-[:default {distance: 2.2}]->(F), (A)-[:default {distance: 1.6}]->(G),
       (A)-[:default {distance: 0.4}]->(H), (B)-[:default {distance: 1.3}]->(C),
       (C)-[:default {distance: 1}]->(D), (D)-[:default {distance: 1.65}]->(H),
       (E)-[:default {distance: 1.27}]->(F), (E)-[:default {distance: 0.9}]->(G),
       (F)-[:default {distance: 0.45}]->(G)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `rootNode` | `STRING` | / | **Required.** Root node `_id`. |
| `terminalNodes` | `LIST` | / | **Required.** List of terminal node `_id`s that must be connected. |
| `weightProperty` | `STRING` | / | Edge property to use as weight. If unset, all edges have unit weight. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `sourceId` | `STRING` | Source node of the Steiner tree edge |
| `targetId` | `STRING` | Target node of the Steiner tree edge |
| `weight` | `FLOAT` | Edge weight |

```gql
CALL algo.steiner({
  rootNode: "A",
  terminalNodes: ["C", "F"],
  weightProperty: "distance"
}) YIELD sourceId, targetId, weight
```

Result:

| sourceId | targetId | weight |
| -- | -- | -- |
| A | B | 1 |
| B | C | 1.3 |
| A | E | 0.7 |
| E | F | 1.27 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.steiner.stream({
  rootNode: "A",
  terminalNodes: ["C", "F", "E"],
  weightProperty: "distance"
}) YIELD sourceId, targetId, weight
RETURN sourceId, targetId, weight
```

Result:

| sourceId | targetId | weight |
| -- | -- | -- |
| A | B | 1 |
| B | C | 1.3 |
| A | E | 0.7 |
| E | F | 1.27 |

Terminal `E` is already on the path `A→E→F`, so adding it doesn't introduce new edges.

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `edgeCount` | `INT` | Number of edges in the Steiner tree |
| `totalWeight` | `FLOAT` | Total weight of the Steiner tree |

```gql
CALL algo.steiner.stats({
  rootNode: "A",
  terminalNodes: ["C", "F", "E"],
  weightProperty: "distance"
}) YIELD edgeCount, totalWeight
```

Result:

| edgeCount | totalWeight |
| -- | -- |
| 4 | 4.27 |
