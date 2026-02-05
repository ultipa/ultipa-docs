# Community Detection

## Overview

Community detection algorithms identify groups of densely connected nodes. These clusters often represent real-world communities, topics, or organizational units.

| Algorithm | Approach | Best For |
| -- | -- | -- |
| **Louvain** | Modularity optimization | Large graphs, hierarchical communities |
| **Label Propagation** | Iterative label spreading | Fast clustering, streaming |
| **Connected Components** | Reachability | Finding isolated subgraphs |
| **Triangle Count** | Clustering coefficient | Network density analysis |

## Louvain Algorithm

The Louvain algorithm detects communities by optimizing modularity. It's highly scalable and produces hierarchical community structures.

| Parameter | Syntax | Description |
| -- | -- | -- |
| `algo.louvain` | `CALL algo.louvain(nodeLabel, edgeType, {options})` | Run Louvain community detection |
| `resolution` | `resolution: 1.0` | Higher values = smaller communities |
| `includeIntermediateCommunities` | `includeIntermediateCommunities: true` | Return hierarchy levels |

Detect communities in social network:

```gql
CALL algo.louvain('Person', 'KNOWS')
YIELD nodeId, communityId
MATCH (p:Person) WHERE id(p) = nodeId
RETURN communityId, COLLECT_LIST(p.name) AS members, COUNT(*) AS size
ORDER BY size DESC
```

| communityId | members | size |
| -- | -- | -- |
| 1 | [Alice, Bob, Carol, Dave] | 4 |
| 2 | [Eve, Frank, Grace] | 3 |
| 3 | [Henry, Ivy] | 2 |

Hierarchical communities:

```gql
CALL algo.louvain('Person', 'KNOWS', {
  includeIntermediateCommunities: true
})
YIELD nodeId, communityId, intermediateCommunityIds
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name, communityId AS finalCommunity,
       intermediateCommunityIds AS hierarchy
```

Adjust community granularity:

```gql
CALL algo.louvain('Person', 'KNOWS', {
  resolution: 2.0  // More, smaller communities
})
YIELD nodeId, communityId
MATCH (p:Person) WHERE id(p) = nodeId
RETURN communityId, COUNT(*) AS size
ORDER BY size DESC
```

Store community assignments:

```gql
CALL algo.louvain('Person', 'KNOWS', {
  writeProperty: 'community'
})
YIELD communityCount, modularity

// Query by community
MATCH (p:Person)
WHERE p.community = 1
RETURN p.name
```

Weighted community detection:

```gql
CALL algo.louvain('Person', 'INTERACTS', {
  relationshipWeightProperty: 'strength'
})
YIELD nodeId, communityId
MATCH (p:Person) WHERE id(p) = nodeId
RETURN communityId, COLLECT_LIST(p.name) AS members
```

## Label Propagation

Label Propagation is a fast, near-linear time algorithm. Nodes adopt the most frequent label among their neighbors until convergence.

Fast community detection:

```gql
CALL algo.labelPropagation('Person', 'KNOWS')
YIELD nodeId, communityId
MATCH (p:Person) WHERE id(p) = nodeId
RETURN communityId, COLLECT_LIST(p.name) AS members
ORDER BY SIZE(members) DESC
```

| communityId | members |
| -- | -- |
| 101 | [Alice, Bob, Carol] |
| 205 | [Dave, Eve] |

Seed with initial labels:

```gql
MATCH (p:Person)
WHERE p.department IS NOT NULL
SET p.seedLabel = p.department

CALL algo.labelPropagation('Person', 'KNOWS', {
  seedProperty: 'seedLabel'
})
YIELD nodeId, communityId
MATCH (p:Person) WHERE id(p) = nodeId
RETURN communityId, COLLECT_LIST(p.name) AS members
```

Limit iterations:

```gql
CALL algo.labelPropagation('Person', 'KNOWS', {
  maxIterations: 10
})
YIELD nodeId, communityId, didConverge
RETURN communityId, COUNT(*) AS size, didConverge
```

## Connected Components

Connected components identify isolated subgraphs where all nodes can reach each other. Weakly connected ignores edge direction; strongly connected requires paths in both directions.

Find weakly connected components:

```gql
CALL algo.wcc('Person', 'KNOWS')
YIELD nodeId, componentId
MATCH (p:Person) WHERE id(p) = nodeId
RETURN componentId, COLLECT_LIST(p.name) AS members, COUNT(*) AS size
ORDER BY size DESC
```

| componentId | members | size |
| -- | -- | -- |
| 0 | [Alice, Bob, Carol, Dave, Eve] | 5 |
| 1 | [Frank, Grace] | 2 |
| 2 | [Henry] | 1 |

Find strongly connected components (directed):

```gql
CALL algo.scc('Person', 'FOLLOWS')
YIELD nodeId, componentId
MATCH (p:Person) WHERE id(p) = nodeId
RETURN componentId, COLLECT_LIST(p.name) AS members
ORDER BY SIZE(members) DESC
```

Find isolated nodes:

```gql
CALL algo.wcc('Person', 'KNOWS')
YIELD nodeId, componentId
WITH componentId, COLLECT_LIST(nodeId) AS nodeIds
WHERE SIZE(nodeIds) = 1
MATCH (p:Person) WHERE id(p) IN nodeIds
RETURN p.name AS isolatedNode
```

Component statistics:

```gql
CALL algo.wcc.stats('Person', 'KNOWS')
YIELD componentCount, nodeCount, minComponentSize, maxComponentSize
RETURN componentCount, nodeCount,
       minComponentSize, maxComponentSize
```

| componentCount | nodeCount | minComponentSize | maxComponentSize |
| -- | -- | -- | -- |
| 15 | 1000 | 1 | 850 |

## Triangle Count & Clustering

Triangle counting measures local clustering. Nodes with high triangle counts are well-embedded in tight-knit groups. The clustering coefficient indicates network density.

Count triangles per node:

```gql
CALL algo.triangleCount('Person', 'KNOWS')
YIELD nodeId, triangleCount, coefficient
MATCH (p:Person) WHERE id(p) = nodeId
RETURN p.name, triangleCount, coefficient
ORDER BY triangleCount DESC
LIMIT 10
```

| name | triangleCount | coefficient |
| -- | -- | -- |
| Alice | 15 | 0.71 |
| Bob | 12 | 0.65 |
| Carol | 10 | 0.58 |

Global clustering coefficient:

```gql
CALL algo.triangleCount.stats('Person', 'KNOWS')
YIELD globalTriangleCount, averageClusteringCoefficient
RETURN globalTriangleCount, averageClusteringCoefficient
```

Find tightly-knit groups:

```gql
CALL algo.triangleCount('Person', 'KNOWS')
YIELD nodeId, coefficient
MATCH (p:Person) WHERE id(p) = nodeId
WHERE coefficient > 0.7
RETURN p.name, p.department, coefficient AS clustering
ORDER BY clustering DESC
```

Native GQL triangle pattern matching:

```gql
MATCH (a:Person)-[:KNOWS]-(b:Person)-[:KNOWS]-(c:Person)-[:KNOWS]-(a)
WHERE id(a) < id(b) AND id(b) < id(c)  // Avoid counting same triangle 3x
RETURN a.name, b.name, c.name
```
