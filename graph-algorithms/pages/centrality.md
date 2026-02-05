# Centrality Algorithms

## Overview

Centrality algorithms identify the most important or influential nodes in a graph. Different algorithms measure importance differently:

| Algorithm | Measures | Best For |
| -- | -- | -- |
| **PageRank** | Influence from incoming links | Web pages, citations, social influence |
| **Betweenness** | Bridge nodes between communities | Information flow bottlenecks |
| **Closeness** | Average distance to all nodes | Efficient spreaders |
| **Degree** | Direct connections | Hub identification |

## PageRank

PageRank measures node importance based on incoming relationships. Nodes with many incoming links from other important nodes score higher.

| Parameter | Syntax | Description |
| -- | -- | -- |
| `algo.pageRank` | `CALL algo.pageRank(nodeLabel, edgeType, {options})` | Run PageRank algorithm |
| `iterations` | `iterations: n` | Number of iterations (default 20) |
| `dampingFactor` | `dampingFactor: 0.85` | Probability of following links (default 0.85) |

Find most influential users in social network:

```gql
CALL algo.pageRank('Person', 'FOLLOWS', {iterations: 20})
YIELD nodeId, score
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name AS person, score
ORDER BY score DESC
LIMIT 10
```

| person | score |
| -- | -- |
| Alice | 0.892 |
| Bob | 0.756 |
| Carol | 0.634 |

PageRank with custom damping factor:

```gql
CALL algo.pageRank('Paper', 'CITES', {
  iterations: 30,
  dampingFactor: 0.90
})
YIELD nodeId, score
MATCH (paper:Paper) WHERE id(paper) = nodeId
RETURN paper.title, paper.year, score
ORDER BY score DESC
LIMIT 5
```

Store PageRank scores on nodes:

```gql
CALL algo.pageRank('Person', 'FOLLOWS', {writeProperty: 'pageRankScore'})
YIELD nodesProcessed, iterations, dampingFactor

// Later query by stored score
MATCH (p:Person)
WHERE p.pageRankScore > 0.5
RETURN p.name, p.pageRankScore
```

Personalized PageRank from specific node:

```gql
MATCH (source:Person {name: 'Alice'})
CALL algo.pageRank.stream('Person', 'FOLLOWS', {
  sourceNodes: [source],
  iterations: 20
})
YIELD nodeId, score
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name, score
ORDER BY score DESC
```

## Betweenness Centrality

Betweenness centrality measures how often a node lies on the shortest path between other nodes. High betweenness indicates bridge nodes that control information flow.

Find bridge nodes in network:

```gql
CALL algo.betweenness('Person', 'KNOWS')
YIELD nodeId, score
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name AS person, score AS betweenness
ORDER BY betweenness DESC
LIMIT 10
```

| person | betweenness |
| -- | -- |
| Eve | 245.5 |
| Frank | 189.2 |
| Grace | 156.8 |

Find critical infrastructure nodes:

```gql
CALL algo.betweenness('Router', 'CONNECTS', {
  direction: 'BOTH'
})
YIELD nodeId, score
MATCH (r:Router) WHERE id(r) = nodeId
WHERE score > 100
RETURN r.name, r.location, score AS criticality
ORDER BY criticality DESC
```

Approximate betweenness for large graphs:

```gql
CALL algo.betweenness.sampled('Person', 'KNOWS', {
  strategy: 'random',
  probability: 0.1
})
YIELD nodeId, score
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name, score
```

## Closeness Centrality

Closeness centrality measures how close a node is to all other nodes. Nodes with high closeness can reach others quickly and are good for spreading information.

Find nodes closest to all others:

```gql
CALL algo.closeness('Person', 'KNOWS')
YIELD nodeId, score
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name, score AS closeness
ORDER BY closeness DESC
LIMIT 10
```

| name | closeness |
| -- | -- |
| Alice | 0.72 |
| Bob | 0.68 |
| Carol | 0.65 |

Find best distribution centers:

```gql
CALL algo.closeness('Location', 'ROAD_TO', {
  direction: 'BOTH'
})
YIELD nodeId, score
MATCH (loc:Location) WHERE id(loc) = nodeId
RETURN loc.city, loc.state, score AS accessibility
ORDER BY accessibility DESC
LIMIT 5
```

Harmonic centrality (handles disconnected graphs):

```gql
CALL algo.closeness.harmonic('Person', 'KNOWS')
YIELD nodeId, score
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name, score
```

## Degree Centrality

Degree centrality is the simplest centrality measure - it counts the number of connections. High degree nodes are hubs with many direct relationships.

Find hubs by connection count:

```gql
CALL algo.degree('Person', 'KNOWS', {direction: 'BOTH'})
YIELD nodeId, score
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name, score AS connections
ORDER BY connections DESC
LIMIT 10
```

| name | connections |
| -- | -- |
| Alice | 42 |
| Bob | 38 |
| Carol | 35 |

Separate in-degree and out-degree:

```gql
CALL algo.degree('Person', 'FOLLOWS', {direction: 'IN'})
YIELD nodeId, score AS followers
MATCH (p:Person) WHERE id(p) = nodeId
WITH p, followers
CALL algo.degree('Person', 'FOLLOWS', {direction: 'OUT'})
YIELD nodeId AS nid, score AS following
WHERE id(p) = nid
RETURN p.name, followers, following,
       followers - following AS influence_ratio
ORDER BY influence_ratio DESC
```

Native GQL degree calculation:

```gql
MATCH (p:Person)-[r:KNOWS]-()
RETURN p.name, COUNT(r) AS degree
ORDER BY degree DESC
LIMIT 10
```

Weighted degree centrality:

```gql
CALL algo.degree('Person', 'TRANSACTS', {
  direction: 'BOTH',
  weightProperty: 'amount'
})
YIELD nodeId, score
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name, score AS transactionVolume
ORDER BY transactionVolume DESC
```
