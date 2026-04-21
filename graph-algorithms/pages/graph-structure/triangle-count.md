# Triangle Count

## Overview

The Triangle Count algorithm identifies and counts triangles in a graph, where each triangle consists of three mutually connected nodes. Triangles indicate the presence of loops and strong connectivity patterns, making them important for graph structure analysis.

In social networks, triangles indicate cohesive communities. In financial or transaction networks, triangles may signal suspicious or fraudulent behavior.

## Concepts

### Triangle

A triangle is formed by three nodes that are all connected to each other. The graph below contains 2 triangles: `{a, b, c}` and `{b, c, d}`.

<div align=center><img src="images/trianglecount-1.drawio.svg"/></div>

The algorithm counts the number of triangles each node participates in and also computes the local clustering coefficient as a byproduct.

## Considerations

- The algorithm treats all edges as undirected.
- Triangles are counted by **nodes** — multi-edges between the same pair of nodes are deduplicated and counted as a single connection.

## Example Graph

<div align=center><img src="images/trianglecount-example.drawio.svg"/></div>


```gql
INSERT (C1:default {_id: "C1"}), (C2:default {_id: "C2"}),
       (C3:default {_id: "C3"}), (C4:default {_id: "C4"}),
       (C5:default {_id: "C5"}), (C6:default {_id: "C6"}),
       (C4)-[:default]->(C1), (C4)-[:default]->(C1),
       (C4)-[:default]->(C2), (C1)-[:default]->(C2),
       (C2)-[:default]->(C3), (C1)-[:default]->(C3),
       (C3)-[:default]->(C5), (C3)-[:default]->(C6)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `triangles`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `triangles` | `INT` | Number of triangles the node participates in |
| `coefficient` | `FLOAT` | Local clustering coefficient |

```gql
CALL algo.trianglecount({
  order: "desc"
}) YIELD nodeId, triangles, coefficient
```

Result:

| nodeId | triangles | coefficient |
| -- | -- | -- |
| C2 | 2 | 0.6666666666666666 |
| C3 | 1 | 0.16666666666666666 |
| C1 | 2 | 0.6666666666666666 |
| C6 | 0 | 0 |
| C4 | 1 | 1 |
| C5 | 0 | 0 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.trianglecount.stream() YIELD nodeId, triangles
FILTER triangles > 0
RETURN nodeId, triangles
```

Result:

| nodeId | triangles |
| -- | -- |
| C2 | 2 |
| C3 | 1 |
| C1 | 2 |
| C4 | 1 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `totalTriangles` | `INT` | Total number of unique triangles in the graph |
| `avgCoefficient` | `FLOAT` | Average clustering coefficient |

```gql
CALL algo.trianglecount.stats() YIELD nodeCount, totalTriangles, avgCoefficient
```

Result:

| nodeCount | totalTriangles | avgCoefficient |
| -- | -- | -- |
| 6 | 2 | 0.4166666666666667 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `triangles` column in results to a property. Map: explicit column-to-property mapping (e.g., `{triangles: 'tri_count', coefficient: 'lcc'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `triangles` | `INT` | Triangle count |
| `coefficient` | `FLOAT` | Local clustering coefficient |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.trianglecount.write({}, {
  db: {
    property: "tri_count"                                       // String: writes triangles to one property
    // property: {triangles: "tri_count", coefficient: "lcc"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
