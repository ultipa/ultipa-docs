# K-Spanning Tree

## Overview

The K-Spanning Tree algorithm partitions a graph into `k` connected components by computing a minimum spanning tree and then removing the `k-1` heaviest edges. This produces a **k-spanning forest** — a set of `k` subtrees that together cover all nodes.

## Concepts

### K-Spanning Tree

The algorithm works in two steps:

1. **Build MST**: Compute the <a href="/docs/graph-algorithms/mst">minimum spanning tree</a> of the graph.
2. **Split**: Remove the `k-1` heaviest edges from the MST. Each removal disconnects a component, producing `k` separate connected components.

The heaviest edges in the MST typically connect loosely related parts of the graph, so removing them produces natural clusters.

For example, with `k=3` on a graph whose MST has edge weights [1, 2, 3, 4, 5, 6], removing the 2 heaviest edges (5 and 6) splits the MST into 3 components.

## Considerations

- The algorithm treats all edges as undirected.
- If the graph already has more than `k` connected components, `k` has no additional effect.

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
| `k` | `INT` | `2` | Number of connected components to produce. |
| `weightProperty` | `STRING` | / | Edge property to use as weight. If unset, all edges have unit weight. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `sourceId` | `STRING` | Source node of the edge |
| `targetId` | `STRING` | Target node of the edge |
| `weight` | `FLOAT` | Edge weight |
| `component` | `INT` | Component ID after splitting |

```gql
CALL algo.kspanningtree({
  k: 3,
  weightProperty: "distance"
}) YIELD sourceId, targetId, weight, component
```

Result:

| sourceId | targetId | weight | component |
| -- | -- | -- | -- |
| A | H | 0.4 | 0 |
| F | G | 0.45 | 0 |
| A | E | 0.7 | 0 |
| E | G | 0.9 | 0 |
| C | D | 1 | 1 |

The result produces 3 components: `{A, E, F, G, H}` (component 0), `{C, D}` (component 1), and `{B}` (component 2). Since the output only contains **edges**, isolated nodes like `B` (which has no edges in the k-spanning forest) do not appear in the results but still form their own component.

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.kspanningtree.stream({
  k: 2,
  weightProperty: "distance"
}) YIELD sourceId, targetId, weight, component
RETURN list_union(collect_list(sourceId), collect_list(targetId)) AS nodes, component
GROUP BY component
```

Result:

| nodes | component |
| -- | -- |
| ["A", "E", "F", "B", "G", "H"] | 0 |
| ["C", "D"] | 1 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `edgeCount` | `INT` | Number of edges in the k-spanning forest |
| `componentCount` | `INT` | Number of connected components |
| `totalWeight` | `FLOAT` | Total weight of the k-spanning forest |

```gql
CALL algo.kspanningtree.stats({
  k: 3,
  weightProperty: "distance"
}) YIELD edgeCount, componentCount, totalWeight
```

Result:

| edgeCount | componentCount | totalWeight |
| -- | -- | -- |
| 5 | 3 | 3.45 |
