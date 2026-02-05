# Graph Algorithms

## Overview

GQLDB provides built-in graph algorithms for analyzing graph structure and discovering patterns. These algorithms are called using the `CALL algo.*` syntax and can be combined with GQL queries.

**Algorithm Categories:**

| Category | Purpose | Examples |
| -- | -- | -- |
| **Centrality** | Find important nodes | PageRank, Betweenness, Closeness, Degree |
| **Community Detection** | Discover clusters | Louvain, Label Propagation, Connected Components |
| **Path Finding** | Find routes | Dijkstra, BFS, DFS, A* |
| **Similarity** | Find similar nodes | Node Similarity, Jaccard, Cosine |

## Basic Usage

Algorithms are called using the `CALL` statement with `YIELD` to capture results:

```gql
CALL algo.pageRank('Person', 'FOLLOWS')
YIELD nodeId, score
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name, score
ORDER BY score DESC
LIMIT 10
```

## Common Parameters

Most algorithms accept these parameters:

| Parameter | Description |
| -- | -- |
| `nodeLabel` | Label of nodes to include |
| `edgeType` | Type of edges to traverse |
| `direction` | Edge direction: 'OUTGOING', 'INCOMING', or 'BOTH' |
| `writeProperty` | Property name to store results on nodes |

## Persisting Results

Many algorithms can write results back to nodes:

```gql
// Compute and store PageRank scores
CALL algo.pageRank('Person', 'FOLLOWS', {writeProperty: 'pageRankScore'})
YIELD nodesProcessed

// Later query by stored score
MATCH (p:Person)
WHERE p.pageRankScore > 0.5
RETURN p.name, p.pageRankScore
ORDER BY p.pageRankScore DESC
```

## Streaming vs Batch

Algorithms ending in `.stream` return results row by row without persisting:

```gql
// Stream results
CALL algo.pageRank.stream('Person', 'FOLLOWS')
YIELD nodeId, score
RETURN nodeId, score
```

See the following pages for detailed information:

- [Centrality Algorithms](/docs/graph-algorithms/centrality)
- [Community Detection](/docs/graph-algorithms/community-detection)
- [Path Finding](/docs/graph-algorithms/path-finding)
- [Similarity Algorithms](/docs/graph-algorithms/similarity)
