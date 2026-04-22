# Bridges

## Overview

The Bridges algorithm finds **bridge edges** in a graph — edges whose removal would disconnect the graph (or increase the number of connected components). Bridge edges represent critical connections and potential vulnerabilities in a network.

## Concepts

### Bridge Edge

A bridge (also called a cut edge) is an edge in an undirected graph whose removal increases the number of connected components. In other words, removing a bridge edge splits a connected part of the graph into two separate parts.

<center><img src="images/bridges-1.drawio.svg"/></center>

In this graph, the edge `B - C` is a bridge because removing it disconnects `C` from `A` and `B`. However, if there's also an edge `A - C`, then `B - C` is no longer a bridge since `C` can still reach `A` through the alternative path.

Bridge detection is important for:
- **Network reliability**: Identifying single points of failure in infrastructure networks.
- **Graph structure analysis**: Understanding the articulation structure of a graph.
- **Preprocessing**: Decomposing a graph into 2-edge-connected components.

## Considerations

- The algorithm treats all edges as undirected.
- Isolated nodes produce no bridge edges.

## Example Graph

<center><img src="images/bridges-articulationpoints-example.drawio.svg"/></center>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (A)-[:default]->(B), (B)-[:default]->(C),
       (C)-[:default]->(A), (C)-[:default]->(D),
       (D)-[:default]->(E), (E)-[:default]->(F),
       (F)-[:default]->(D)
```

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `sourceId` | `STRING` | Source node identifier (`_id`) |
| `targetId` | `STRING` | Target node identifier (`_id`) |
| `isBridge` | `BOOL` | Whether the edge is a bridge |

Find all bridge edges:

```gql
CALL algo.bridges() YIELD sourceId, targetId, isBridge
```

Result:

| sourceId | targetId | isBridge |
| -- | -- | -- |
| D | C | true |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.bridges.stream() YIELD sourceId, targetId
RETURN sourceId, targetId
```

Result:

| sourceId | targetId |
| -- | -- |
| D | C |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `bridgeCount` | `INT` | Number of bridge edges |

```gql
CALL algo.bridges.stats() YIELD nodeCount, bridgeCount
```

Result:

| nodeCount | bridgeCount |
| -- | -- |
| 6 | 1 |
