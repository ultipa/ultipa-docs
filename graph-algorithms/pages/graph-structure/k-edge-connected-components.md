# k-Edge Connected Components

## Overview

The k-Edge Connected Components algorithm finds groups of nodes that have strong interconnections based on their edges. By considering the connectivity of edges rather than just the nodes themselves, the algorithm can reveal clusters within the graph where nodes are tightly linked to each other. This information can be valuable for social network analysis, web graph analysis, biological network analysis, and more.

Related material of the algorithm:

- T. Wang, Y. Zhang, F.Y.L. Chin, H. Ting, Y.H. Tsin, S. Poon, <a target='blank' href="https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0136264#abstract0">A Simple Algorithm for Finding All k-Edge-Connected Components</a> (2015)

## Concepts

### Edge Connectivity

The <b>edge connectivity</b> of a graph is a measure that quantifies the minimum number of edges that need to be removed in order to disconnect the graph or reduce its connectivity. Given a graph <i>G = (V, E)</i>, <i>G</i> is <b>k-edge connected</b> if it remains connected after the removal of any `k-1` or fewer edges from <i>G</i>.

The edge connectivity can also be interpreted as the maximum number of edge-disjoint paths between any two nodes in the graph. If the edge connectivity of a graph is `k`, it means that there are `k` edge-disjoint paths between any pair of nodes in the graph.

Below shows a 3-edge connected graph and the edge-disjoint paths between each node pair.

<div align='center' drawio-diagram='6176' drawio-name="draw_516ca76c533f42d59c83973efe95125e.jpg"><img src="https://img.ultipa.cn/draw/draw_516ca76c533f42d59c83973efe95125e.jpg?v='1687142427889'"/></div>

> <b>Edge-disjoint</b> paths are paths that do not have any edge in common.

### k-Edge Connected Components

Instead of determining whether the entire graph <i>G</i> is k-edge connected, the algorithm finds the maximal subsets of nodes <i>V<sub>i</sub> ⊆ V</i>, where the subgraphs induced by <i>V<sub>i</sub></i> are k-edge connected.

For example, in social networks, finding a group of people who are strongly connected is more important than computing the connectivity of the entire social network.

## Considerations

- The algorithm is exact for `k = 2`. For `k ≥ 3`, it uses a conservative approximation via iterative bridge removal and degree peeling.
- The algorithm treats all edges as undirected.

## Example Graph

<div align='center' drawio-diagram='6177' drawio-name="draw_350441442b224f7bad64fb8983024db2.jpg"><img src="https://img.ultipa.cn/draw/draw_350441442b224f7bad64fb8983024db2.jpg?v='1687145644126'"/></div>


```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (I:default {_id: "I"}), (J:default {_id: "J"}),
       (K:default {_id: "K"}), (L:default {_id: "L"}),
       (M:default {_id: "M"}), (N:default {_id: "N"}),
       (A)-[:default]->(B), (B)-[:default]->(C),
       (A)-[:default]->(C), (A)-[:default]->(D),
       (A)-[:default]->(E), (C)-[:default]->(D),
       (E)-[:default]->(D), (E)-[:default]->(F),
       (D)-[:default]->(J), (F)-[:default]->(G),
       (F)-[:default]->(I), (G)-[:default]->(H),
       (F)-[:default]->(H), (G)-[:default]->(I),
       (H)-[:default]->(I), (I)-[:default]->(J),
       (J)-[:default]->(K), (J)-[:default]->(M),
       (K)-[:default]->(L), (J)-[:default]->(L),
       (M)-[:default]->(K), (M)-[:default]->(L),
       (M)-[:default]->(N), (N)-[:default]->(L)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `k` | `INT` | `2` | Edge connectivity requirement (k ≥ 2). |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `componentId` | `INT` | Component identifier |

```gql
CALL algo.kedgeconnected({
  k: 3
}) YIELD nodeId, componentId
```

Result:

| nodeId | componentId |
| -- | -- |
| E | 0 |
| D | 1 |
| G | 2 |
| F | 2 |
| A | 3 |
| C | 4 |
| B | 5 |
| M | 6 |
| L | 6 |
| N | 7 |
| I | 2 |
| H | 2 |
| K | 6 |
| J | 6 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.kedgeconnected.stream({
  k: 3
}) YIELD nodeId, componentId
RETURN componentId, COLLECT(nodeId) AS members
GROUP BY componentId
```

Result:

| componentId | members |
| -- | -- |
| 0 | [E] |
| 1 | [D] |
| 2 | [G, F, I, H] |
| 3 | [A] |
| 4 | [C] |
| 5 | [B] |
| 6 | [M, L, K, J] |
| 7 | [N] |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `componentCount` | `INT` | Number of k-edge-connected components |
| `largestComponentSize` | `INT` | Size of the largest component |
| `smallestComponentSize` | `INT` | Size of the smallest component |

```gql
CALL algo.kedgeconnected.stats({
  k: 3
}) YIELD nodeCount, componentCount, largestComponentSize, smallestComponentSize
```

Result:

| nodeCount | componentCount | largestComponentSize | smallestComponentSize |
| -- | -- | -- | -- |
| 14 | 8 | 4 | 1 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `componentId` column in results to a property. Map: explicit column-to-property mapping (e.g., `{componentId: 'kecc_id'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `componentId` | `INT` | Component identifier |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.kedgeconnected.write({k: 3}, {
  db: {
    property: "kecc_id"                     // String: writes componentId to one property
    // property: {componentId: "kecc_id"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
