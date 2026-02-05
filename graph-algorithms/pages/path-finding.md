# Path Finding Algorithms

## Overview

Path finding algorithms discover routes between nodes. Different algorithms optimize for different criteria:

| Algorithm | Use Case | Weighted |
| -- | -- | -- |
| **BFS** | Shortest path by hops | No |
| **DFS** | Explore all paths | No |
| **Dijkstra** | Shortest weighted path | Yes |
| **A*** | Shortest path with heuristic | Yes |
| **All Shortest Paths** | All equal-length paths | Optional |

**Note:** GQL also provides native path syntax using SHORTEST/ALL SHORTEST in MATCH patterns.

## BFS & DFS Traversal

Breadth-First Search (BFS) explores neighbors level by level, finding shortest paths by hop count. Depth-First Search (DFS) explores as deep as possible before backtracking.

BFS shortest path (unweighted):

```gql
CALL algo.bfs('Person', 'KNOWS', {
  sourceNode: 'Alice',
  targetNode: 'Eve'
})
YIELD path, distance
RETURN path, distance
```

| path | distance |
| -- | -- |
| Alice -> Bob -> Carol -> Eve | 3 |

Native GQL shortest path (preferred):

```gql
MATCH p = SHORTEST 1 (a:Person WHERE a.name = 'Alice')
          -[:KNOWS]-{1,10}
          (e:Person WHERE e.name = 'Eve')
RETURN p, LENGTH(p) AS hops
```

DFS to find all paths:

```gql
CALL algo.dfs('Person', 'KNOWS', {
  sourceNode: 'Alice',
  targetNode: 'Eve',
  maxDepth: 5
})
YIELD path
RETURN path
LIMIT 10
```

BFS with max depth:

```gql
CALL algo.bfs.stream('Person', 'KNOWS', {
  sourceNode: 'Alice',
  maxDepth: 3
})
YIELD nodeId, distance
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name, distance
ORDER BY distance
```

## Dijkstra Shortest Path

Dijkstra's algorithm finds the shortest weighted path between nodes. Essential for routing, logistics, and network optimization.

| Parameter | Syntax | Description |
| -- | -- | -- |
| `algo.dijkstra` | `CALL algo.dijkstra(source, target, weightProperty, {options})` | Weighted shortest path |
| `weightProperty` | `weightProperty: "cost"` | Edge property for weights |

Shortest weighted path:

```gql
MATCH (start:City {name: 'New York'})
MATCH (end:City {name: 'Los Angeles'})
CALL algo.dijkstra(start, end, 'distance')
YIELD path, totalCost
RETURN [n IN NODES(path) | n.name] AS route, totalCost AS miles
```

| route | miles |
| -- | -- |
| [New York, Chicago, Denver, Los Angeles] | 2800 |

Multiple weighted paths:

```gql
MATCH (start:City {name: 'Boston'})
MATCH (end:City {name: 'Seattle'})
CALL algo.dijkstra.stream(start, end, 'travelTime', {
  pathCount: 3
})
YIELD path, totalCost
RETURN [n IN NODES(path) | n.name] AS route,
       totalCost AS hours
```

Single source shortest paths (to all nodes):

```gql
MATCH (start:City {name: 'Chicago'})
CALL algo.dijkstra.singleSource(start, 'distance')
YIELD nodeId, totalCost
MATCH (city:City) WHERE id(city) = nodeId
RETURN city.name, totalCost AS distanceFromChicago
ORDER BY totalCost
```

With edge filter:

```gql
MATCH (start:City {name: 'Miami'})
MATCH (end:City {name: 'Seattle'})
CALL algo.dijkstra(start, end, 'distance', {
  relationshipTypes: ['HIGHWAY', 'INTERSTATE'],
  direction: 'BOTH'
})
YIELD path, totalCost
RETURN path, totalCost
```

Cost-optimized routing:

```gql
MATCH (warehouse:Location {type: 'warehouse'})
MATCH (customer:Location {type: 'customer', id: 'C123'})
CALL algo.dijkstra(warehouse, customer, 'deliveryCost')
YIELD path, totalCost
RETURN warehouse.name, totalCost AS cost,
       LENGTH(path) AS stops
```

## All Shortest Paths

When multiple paths have the same length, you may want all of them. Native GQL syntax and algorithms both support this.

Native GQL all shortest paths:

```gql
MATCH p = ALL SHORTEST (a:Person WHERE a.name = 'Alice')
          -[:KNOWS]-{1,10}
          (e:Person WHERE e.name = 'Eve')
RETURN p, LENGTH(p) AS hops
```

Algorithm-based all shortest paths:

```gql
MATCH (start:Person {name: 'Alice'})
MATCH (end:Person {name: 'Eve'})
CALL algo.allShortestPaths(start, end, 'KNOWS')
YIELD path
RETURN [n IN NODES(path) | n.name] AS route
LIMIT 10
```

All weighted shortest paths:

```gql
MATCH (start:City {name: 'Boston'})
MATCH (end:City {name: 'Phoenix'})
CALL algo.dijkstra.allShortestPaths(start, end, 'distance')
YIELD path, totalCost
RETURN [n IN NODES(path) | n.name] AS route, totalCost
```

K shortest paths (allowing longer alternatives):

```gql
MATCH (start:City {name: 'Seattle'})
MATCH (end:City {name: 'Miami'})
CALL algo.kShortestPaths(start, end, 'distance', {k: 5})
YIELD path, totalCost, rank
RETURN rank, [n IN NODES(path) | n.name] AS route, totalCost
```

| rank | route | totalCost |
| -- | -- | -- |
| 1 | [Seattle, Denver, Dallas, Miami] | 3200 |
| 2 | [Seattle, Salt Lake, Dallas, Miami] | 3350 |
| 3 | [Seattle, Denver, Atlanta, Miami] | 3400 |

## A* Algorithm

A* is an informed search algorithm that uses a heuristic to guide the search toward the target, making it faster than Dijkstra for geographic routing.

A* with geographic heuristic:

```gql
MATCH (start:City {name: 'New York'})
MATCH (end:City {name: 'San Francisco'})
CALL algo.astar(start, end, 'distance', {
  latitudeProperty: 'lat',
  longitudeProperty: 'lon'
})
YIELD path, totalCost
RETURN [n IN NODES(path) | n.name] AS route, totalCost
```

A* for game pathfinding (grid-based):

```gql
MATCH (start:Tile {x: 0, y: 0})
MATCH (end:Tile {x: 10, y: 10})
CALL algo.astar(start, end, 'movementCost', {
  heuristic: 'manhattan',
  xProperty: 'x',
  yProperty: 'y'
})
YIELD path, totalCost
RETURN LENGTH(path) AS steps, totalCost
```
