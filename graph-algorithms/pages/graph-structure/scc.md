# Strongly Connected Components (SCC)

## Overview

The SCC algorithm identifies the strongly connected components in a directed graph using Kosaraju's algorithm. A strongly connected component is a maximal subset of nodes where there is a directed path between every pair of nodes in both directions.

## Concepts

### Connected Component

A connected component is a maximal subset of nodes in a graph where all nodes in that subset are reachable from one another by following edges. A maximal subset means that no additional nodes can be added to the subset without breaking the connectivity requirement.

### Strongly Connected Component

A **strongly connected component (SCC)** is a maximal subset of nodes in a directed graph where for any two nodes `u` and `v`, there exists a directed path from `u` to `v` and from `v` to `u`. All edges along these paths follow the original direction.

Unlike <a href="/docs/graph-algorithms/wcc">WCC</a> which ignores edge direction, SCC respects it — two nodes are in the same SCC only if they can reach each other following directed edges.

<div align=center drawio-diagram='6017' drawio-name='draw_2f5f2e1e0d644c729e5b3cd09344fcb5.jpg'><img src="https://img.ultipa.cn/draw/draw_2f5f2e1e0d644c729e5b3cd09344fcb5.jpg?v='1684744743791'"/></div>

This example shows 3 strongly connected components and 2 weakly connected components. The number of SCCs is always ≥ the number of WCCs, since SCCs impose stricter connectivity conditions.

## Considerations

- The algorithm respects edge direction.
- Each isolated node constitutes its own strongly connected component.

## Example Graph

<div align=center drawio-diagram='19810' drawio-name="draw_5cf4c0fcf3f444b69bdfefe8c2fc1a68.jpg"><img src="https://img.ultipa.cn/draw/draw_5cf4c0fcf3f444b69bdfefe8c2fc1a68.jpg?v='1734329095581'"/></div>

```gql
INSERT (Mike:member {_id: "Mike"}), (Cathy:member {_id: "Cathy"}),
       (Anna:member {_id: "Anna"}), (Joe:member {_id: "Joe"}),
       (Sam:member {_id: "Sam"}), (Bob:member {_id: "Bob"}),
       (Bill:member {_id: "Bill"}), (Alice:member {_id: "Alice"}),
       (Cathy)-[:helps]->(Mike), (Anna)-[:helps]->(Sam),
       (Anna)-[:helps]->(Joe), (Joe)-[:helps]->(Bob),
       (Bob)-[:helps]->(Joe), (Bob)-[:helps]->(Bill),
       (Bill)-[:helps]->(Alice), (Bill)-[:helps]->(Anna),
       (Alice)-[:helps]->(Anna)
```

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `componentId` | `INT` | Component identifier |
| `componentSize` | `INT` | Number of nodes in component |

```gql
CALL algo.scc() YIELD nodeId, componentId, componentSize
```

Result:

| nodeId | componentId | componentSize |
| -- | -- | -- |
| Mike | 0 | 1 |
| Bill | 2 | 5 |
| Alice | 2 | 5 |
| Anna | 2 | 5 |
| Bob | 2 | 5 |
| Joe | 2 | 5 |
| Cathy | 3 | 1 |
| Sam | 1 | 1 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.scc.stream() YIELD nodeId, componentId, componentSize
RETURN componentId, COLLECT(nodeId) AS members, componentSize
GROUP BY componentId
```

Result:

| componentId | members | componentSize |
| -- | -- | -- |
| 0 | [Mike] | 1 |
| 2 | [Bill, Alice, Anna, Bob, Joe] | 5 |
| 3 | [Cathy] | 1 |
| 1 | [Sam] | 1 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `communityCount` | `INT` | Number of strongly connected components |
| `largestCommunitySize` | `INT` | Size of the largest component |
| `smallestCommunitySize` | `INT` | Size of the smallest component |

```gql
CALL algo.scc.stats() YIELD nodeCount, communityCount, largestCommunitySize, smallestCommunitySize
```

Result:

| nodeCount | communityCount | largestCommunitySize | smallestCommunitySize |
| -- | -- | -- | -- |
| 8 | 4 | 5 | 1 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `componentId` column in results to a property. Map: explicit column-to-property mapping (e.g., `{componentId: 'scc_id'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `componentId` | `INT` | Component identifier |
| `componentSize` | `INT` | Component size |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.scc.write({}, {
  db: {
    property: "scc_id"                     // String: writes componentId to one property
    // property: {componentId: "scc_id"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
