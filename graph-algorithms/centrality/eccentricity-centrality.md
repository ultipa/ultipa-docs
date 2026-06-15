# Eccentricity Centrality

## Overview

The eccentricity of a node in a graph is the maximum shortest distance from the node to any other reachable nodes in the graph. This measurement, along with other measurements like closeness centrality and graph diameter, can be considered jointly to determine whether a node is literally located at the very center of the graph.

## Concepts

### Shortest Distance

The shortest distance between two nodes is the number of edges in the shortest path connecting them. Please refer to <a target="_blank" href="/docs/graph-algorithms/closeness-centrality">Closeness Centrality</a> for more details.

### Eccentricity

The eccentricity of a node is the maximum shortest-path distance from that node to any other reachable node. For example, if the shortest distances from node `A` to all other nodes are [1, 2, 3, 1], then `A`'s eccentricity is 3.

Related concepts:  

- **Radius**: The minimum eccentricity across all nodes in the graph.
- **Diameter**: The maximum eccentricity across all nodes in the graph.
- **Center nodes**: Nodes whose eccentricity equals the radius — the most central nodes in the graph.

### Eccentricity Centrality

The eccentricity centrality score of a node is the inverse of its eccentricity. The formula is:

<center><img width=180 src="images/eccentricity-2.png"/></center>

where `x` is the target node,  `y` is any node that connects with `x` along edges (`x` itself is excluded), `d(x,y)` is the shortest distance between `x` and `y`.

<center><img src="images/eccentricity-1.jpg"/></center>

In this graph, the green and red numbers next to each node represent the shortest distances from that node to the green and red nodes, respectively. Eccentricity centrality scores of the green and red nodes are `1/4 = 0.25` and `1/3 = 0.3333` respectively.

Regarding closeness centrality, the green node has score `8/(1+1+1+1+2+3+4+3) = 0.5`, the red node has score `8/(3+3+3+2+1+1+2+1) = 0.5`. When two nodes share the same closeness centrality score, eccentricity centrality can act as a secondary metric to determine which node is closer to the center.

## Considerations

- The eccentricity centrality score of isolated nodes is 0.

## Example Graph

<center><img src="images/eccentricity-example.jpg"/></center>

```gql
INSERT (A:user {_id: "A"}), (B:user {_id: "B"}),
       (C:user {_id: "C"}), (D:user {_id: "D"}),
       (E:user {_id: "E"}), (F:user {_id: "F"}),
       (G:user {_id: "G"}), (H:user {_id: "H"}),
       (I:user {_id: "I"}), (J:user {_id: "J"}),
       (A)-[:vote {weight: 1}]->(B), (A)-[:vote {weight: 2}]->(C),
       (A)-[:vote {weight: 3}]->(D), (E)-[:vote {weight: 2}]->(A),
       (E)-[:vote {weight: 1}]->(F), (F)-[:vote {weight: 4}]->(G),
       (F)-[:vote {weight: 1}]->(I), (G)-[:vote {weight: 2}]->(H),
       (H)-[:vote {weight: 1}]->(I)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `ids` | `LIST` | / | `_id`s of nodes to compute (empty = all nodes). |
| `direction` | `STRING` | `both` | Edge direction: `in`, `out`, or `both`. |
| `weight` | `STRING` or `LIST` | / | Numeric edge property for weighted shortest paths. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `eccentricity`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `eccentricity` | `FLOAT` | Eccentricity (max shortest-path distance from this node) |
| `centrality` | `FLOAT` | Centrality (1/eccentricity, 0 if disconnected) |
| `isCenter` | `INT` | 1 if this node is a center node (min eccentricity in its component), 0 otherwise |
| `componentId` | `INT` | Connected component ID (0-based) |

Eccentricity centrality for all nodes:

```gql
CALL algo.eccentricity({
  order: "desc"
}) YIELD nodeId, eccentricity, centrality, isCenter
```

Result:

| nodeId | eccentricity | centrality | isCenter |
| -- | -- | -- | -- |
| E | 3 | 0.3333333333333333 | 1 |
| F | 3 | 0.3333333333333333 | 1 |
| G | 4 | 0.25 | 0 |
| A | 4 | 0.25 | 0 |
| I | 4 | 0.25 | 0 |
| D | 5 | 0.2 | 0 |
| C | 5 | 0.2 | 0 |
| B | 5 | 0.2 | 0 |
| H | 5 | 0.2 | 0 |
| J | 0 | 0 | 0 |

Weighted eccentricity centrality:

```gql
CALL algo.eccentricity({
  ids: ["A", "B"],
  weight: ["weight"]
}) YIELD nodeId, eccentricity, centrality, isCenter
```

Result:

| nodeId | eccentricity | centrality | isCenter |
| -- | -- | -- | -- |
| A	| 7	| 0.14285714285714285	| 0 |
|	B	|8 | 0.125 | 0 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.eccentricity.stream({
  order: "desc"
}) YIELD nodeId, centrality
FILTER centrality > 0.25
RETURN nodeId, centrality
```

Result:

| nodeId | centrality |
| -- | -- |
| E | 0.3333333333333333 |
| F | 0.3333333333333333 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `radius` | `FLOAT` | Radius (minimum eccentricity across all components) |
| `diameter` | `FLOAT` | Diameter (maximum eccentricity across all components) |
| `centerCount` | `INT` | Number of center nodes |
| `componentCount` | `INT` | Number of connected components |

```gql
CALL algo.eccentricity.stats() YIELD nodeCount, radius, diameter, centerCount, componentCount
```

Result:

| nodeCount | radius | diameter | centerCount |
| -- | -- | -- | -- |
| 10 | 3 | 5 | 2 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `centrality` column in results to a property. Map: explicit column-to-property mapping (e.g., `{centrality: 'gc_score', eccentricity: 'gc_ecc'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `eccentricity` | `INT` | Eccentricity |
| `centrality` | `FLOAT` | Eccentricity centrality score |
| `isCenter` | `INT` | Center node flag |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.eccentricity.write({}, {
  db: {
    property: "gc_score"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
