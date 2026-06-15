# p-Cohesion

## Overview

The p-Cohesion algorithm computes a per-node cohesion value that measures how well each node is embedded within a densely connected neighborhood. The concept of p-cohesion was first proposed by S. Morris in a contagion model describing interactions within large populations:

- S. Morris, <a target='blank' href="http://snap.stanford.edu/class/cs224w-readings/morris98contagion.pdf">Contagion</a>. The Review of Economic Studies, 67(1), 57–78 (2000)

## Concepts

### p-Cohesion

One natural measure of the **cohesion** of a group is the relative frequency of ties among its members compared to non-members. Let cohesion be a constant `p` ∈ (0,1). A **p-Cohesion** is a connected subgraph in which every node has, at least, a proportion `p` of its neighbors within the subgraph. In other words, each node has at most, a proportion `(1 − p)` of its neighbors outside the subgraph.

The p-Cohesion model offers two key advantages over other cohesive subgraph models:

- With a high `p` value, p-Cohesion ensures both strong internal cohesiveness and sparse connections to outside nodes.
- It considers the proportion of neighbors within the group rather than a fixed number (such as the `k` value in <a href="/docs/graph-algorithms/k-core">k-Core</a>), making it better suited for graphs with varying node degrees.

The example graph below illustrates this. Suppose `p = 0.6`. A grey label next to each node shows the minimum number of internal neighbors required for the node to remain in a p-Cohesion.

<center><img src="images/pcohesion-1.jpg"/></center>

Below are the minimal p-Cohesion subgraphs, in terms of node count, that include node `a` and node `j`, respectively.

<center><img src="images/pcohesion-2.jpg"/></center>

### Cohesion Value

Finding the maximum `p` for which a node belongs to a p-cohesive subgraph is computationally hard, so this algorithm uses a tractable proxy based on <a href="/docs/graph-algorithms/k-core">k-Core</a> decomposition:

1. Compute each node's **coreness**: the largest `k` such that the node belongs to a k-core (a subgraph where every member has at least `k` neighbors inside).
2. Normalize by the node's total degree: `cohesion(v) = coreness(v) / degree(v)`.

The resulting value lies in `[0, 1]` and reflects the proportion of `v`'s neighbors that remain with `v` in the deepest k-core containing it. A higher value indicates the node is embedded in a more tightly connected neighborhood.

> The cohesion value is a per-node ranking metric — it does not name the specific subgraph the node belongs to, and it differs from the literal maximum `p` of the ratio-based p-Cohesion definition above (it's a lower bound on that quantity). For most analytical use cases the ranking it produces is what matters.

## Considerations

- The algorithm treats all edges as undirected.

## Example Graph

<center><img src="images/pcohesion-example.jpg"/></center>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (I:default {_id: "I"}), (J:default {_id: "J"}),
       (K:default {_id: "K"}), (L:default {_id: "L"}),
       (K)-[:default]->(J), (K)-[:default]->(L),
       (J)-[:default]->(L), (L)-[:default]->(C),
       (C)-[:default]->(A), (A)-[:default]->(B),
       (C)-[:default]->(B), (A)-[:default]->(D),
       (B)-[:default]->(G), (B)-[:default]->(D),
       (D)-[:default]->(C), (C)-[:default]->(E),
       (C)-[:default]->(F), (D)-[:default]->(E),
       (E)-[:default]->(F), (D)-[:default]->(F),
       (D)-[:default]->(H), (I)-[:default]->(H),
       (F)-[:default]->(I)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `p` | `FLOAT` | / | Cohesion threshold (0 < `p` ≤ 1). When set, only nodes with cohesion ≥ `p` are returned. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `cohesion` | `FLOAT` | Maximal p-cohesion value for this node |

```gql
CALL algo.pcohesion({
  p: 0.7
}) YIELD nodeId, cohesion
```

Result:

| nodeId | cohesion |
| -- | -- |
| E | 1 |
| G | 1 |
| F | 0.75 |
| A | 1 |
| B | 0.75 |
| I | 1 |
| H | 1 |
| K | 1 |
| J | 1 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.pcohesion.stream({
  p: 0.8
}) YIELD nodeId, cohesion
RETURN nodeId, cohesion
```

Result:

| nodeId | cohesion |
| -- | -- |
| E | 1 |
| G | 1 |
| A | 1 |
| I | 1 |
| H | 1 |
| K | 1 |
| J | 1 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `minCohesion` | `FLOAT` | Minimum cohesion value |
| `maxCohesion` | `FLOAT` | Maximum cohesion value |
| `avgCohesion` | `FLOAT` | Average cohesion value |

```gql
CALL algo.pcohesion.stats({
  p: 0.8
}) YIELD nodeCount, minCohesion, maxCohesion, avgCohesion
```

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `cohesion` column in results to a property. Map: explicit column-to-property mapping (e.g., `{cohesion: 'p_cohesion'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `cohesion` | `FLOAT` | Maximal p-cohesion value |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.pcohesion.write({}, {
  db: {
    property: "p_cohesion"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
