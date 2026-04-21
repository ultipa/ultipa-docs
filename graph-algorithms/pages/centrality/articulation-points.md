# Articulation Points

## Overview

The Articulation Points algorithm finds **cut vertices** in a graph — nodes whose removal would disconnect the graph (or increase the number of connected components). Articulation points represent critical nodes and potential vulnerabilities in a network.

The algorithm uses Tarjan's DFS-based approach.

## Concepts

### Articulation Point

An articulation point (also called a cut vertex) is a node in an undirected graph whose removal, along with all its incident edges, increases the number of connected components. Removing an articulation point splits a connected part of the graph into two or more separate parts.

Articulation point detection is closely related to <a target="_blank" href="/docs/graph-analytics-algorithms/bridges">bridge detection</a>. A bridge edge always connects to at least one articulation point (unless the bridge connects two leaf nodes). However, an articulation point does not necessarily have a bridge edge.

Articulation point detection is important for:
- **Network reliability**: Identifying single points of failure in infrastructure or communication networks.
- **Graph structure analysis**: Finding the biconnected components of a graph.
- **Critical node protection**: Prioritizing the protection or redundancy of critical nodes.

## Considerations

- The algorithm treats all edges as undirected.
- Isolated nodes are not articulation points.

## Example Graph

<div align=center><img src="images/bridges-2.drawio.svg"/></div>

Run the following statements on an empty graph to insert data:

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
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `isCutVertex` | `BOOL` | Whether the node is an articulation point |

Find all articulation points:

```gql
CALL algo.articulationpoints() YIELD nodeId, isCutVertex
```

Result:

| nodeId | isCutVertex |
| -- | -- |
| E | false |
| D | true |
| F | false |
| A | false |
| C | true |
| B | false |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.articulationpoints.stream() YIELD nodeId, isCutVertex
FILTER isCutVertex = true
RETURN nodeId
```

Result:

| nodeId |
| -- |
| D |
| C |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `cutVertexCount` | `INT` | Number of articulation points |

```gql
CALL algo.articulationpoints.stats() YIELD nodeCount, cutVertexCount
```

Result:

| nodeCount | cutVertexCount |
| -- | -- |
| 6 | 2 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `isCutVertex` column in results to a property. Map: explicit column-to-property mapping (e.g., `{isCutVertex: 'is_cut'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `isCutVertex` | `BOOL` | Whether the node is an articulation point |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.articulationpoints.write({}, {
  db: {
    property: "is_cut"                     // String: writes isCutVertex to one property
    // property: {isCutVertex: "is_cut"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
