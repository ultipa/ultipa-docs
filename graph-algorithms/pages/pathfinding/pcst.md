# Prize-Collecting Steiner Tree (PCST)

## Overview

The Prize-Collecting Steiner Tree (PCST) algorithm finds a subtree that balances two competing goals: **collecting node prizes** and **minimizing edge costs**. Unlike the standard <a href="/docs/graph-algorithms/steiner">Steiner tree</a> which must connect all specified terminals, PCST decides which nodes are worth including based on the trade-off between their prize value and the cost of reaching them.

Applications:

- **Network design**: Deciding which customers to connect when wiring is expensive.
- **Feature selection**: Selecting a connected subgraph of high-value nodes in biological networks.
- **Revenue optimization**: Balancing service coverage cost against customer value.

## Concepts

### Prize-Collecting Steiner Tree

Each node has a **prize** (value gained by including it) and each edge has a **cost** (price paid to use it). The algorithm finds a connected subtree that maximizes `total prize - λ × total cost`.

The `λ` parameter controls the trade-off:

- **High lambda**: Penalizes edge costs more → smaller tree, only high-prize nodes included.
- **Low lambda**: Penalizes costs less → larger tree, more nodes included.

The algorithm works by:

1. Build a <a href="/docs/graph-algorithms/mst">minimum spanning tree</a> of the graph, connecting all nodes.
2. Examine each leaf node (node with only one edge in the tree). If the leaf's prize is less than `λ × edge cost`, remove it — the cost of reaching it outweighs its value.
3. Repeat step 2 — removing a node may create new leaf nodes that can also be pruned.
4. Stop when every remaining leaf node is worth keeping (`prize ≥ λ × edge cost`).

## Considerations

- The algorithm treats all edges as undirected.

## Example Graph

<center><img src="images/pcst-example.drawio.svg"/></center>

```gql
INSERT (A:default {_id: "A", prize: 10}), (B:default {_id: "B", prize: 5}),
       (C:default {_id: "C", prize: 8}), (D:default {_id: "D", prize: 3}),
       (E:default {_id: "E", prize: 12}), (F:default {_id: "F", prize: 6}),
       (G:default {_id: "G", prize: 4}), (H:default {_id: "H", prize: 2}),
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
| `prizeProperty` | `STRING` | / | Node property to use as prize value. If unset, all nodes have zero prize. |
| `weightProperty` | `STRING` | / | Edge property to use as cost. If unset, all edges have unit cost. |
| `lambda` | `FLOAT` | `1.0` | Trade-off parameter. Higher values penalize edge costs more, producing smaller trees. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `inTree` | `BOOL` | Whether the node is included in the tree |
| `totalCost` | `FLOAT` | Total edge cost of the tree |
| `totalPrize` | `FLOAT` | Total prize of nodes in the tree |

```gql
CALL algo.pcst({
  prizeProperty: "prize",
  weightProperty: "distance",
  lambda: 1
}) YIELD nodeId, inTree, totalCost, totalPrize
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.pcst.stream({
  prizeProperty: "prize",
  weightProperty: "distance",
  lambda: 1
}) YIELD nodeId, inTree
FILTER inTree = true
RETURN nodeId
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes in the graph |
| `nodesInTree` | `INT` | Number of nodes included in the tree |
| `totalCost` | `FLOAT` | Total edge cost of the tree |
| `totalPrize` | `FLOAT` | Total prize of nodes in the tree |

```gql
CALL algo.pcst.stats({
  prizeProperty: "prize",
  weightProperty: "distance",
  lambda: 1
}) YIELD nodeCount, nodesInTree, totalCost, totalPrize
```
