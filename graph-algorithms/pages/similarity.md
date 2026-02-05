# Similarity Algorithms

## Overview

Similarity algorithms measure how alike two nodes are based on their connections and neighborhood structure. Unlike vector similarity (AI functions), graph similarity uses topology.

| Algorithm | Measures | Best For |
| -- | -- | -- |
| **Node Similarity** | Shared neighbors ratio | Recommendations |
| **Jaccard** | Intersection over union | Set comparison |
| **Cosine** | Normalized dot product | Weighted relationships |
| **Overlap** | Intersection over minimum | Subset detection |

**Use Cases:**
- Recommendation engines ("users who liked X also liked Y")
- Duplicate detection
- Link prediction
- Entity resolution

## Node Similarity

Node similarity computes the Jaccard similarity between node neighborhoods. Nodes that share many neighbors are considered similar.

| Parameter | Syntax | Description |
| -- | -- | -- |
| `algo.nodeSimilarity` | `CALL algo.nodeSimilarity(nodeLabel, edgeType, {options})` | Compute node similarities |
| `topK` | `topK: 10` | Return top K similar pairs per node |
| `similarityCutoff` | `similarityCutoff: 0.5` | Minimum similarity threshold |

Find similar users by purchase behavior:

```gql
CALL algo.nodeSimilarity('Customer', 'PURCHASED')
YIELD node1, node2, similarity
MATCH (c1:Customer) WHERE id(c1) = node1
MATCH (c2:Customer) WHERE id(c2) = node2
RETURN c1.name, c2.name, similarity
ORDER BY similarity DESC
LIMIT 20
```

| c1.name | c2.name | similarity |
| -- | -- | -- |
| Alice | Bob | 0.85 |
| Alice | Carol | 0.72 |
| Dave | Eve | 0.68 |

Item-based collaborative filtering:

```gql
CALL algo.nodeSimilarity('Product', 'PURCHASED', {
  direction: 'INCOMING',
  topK: 5,
  similarityCutoff: 0.3
})
YIELD node1, node2, similarity
MATCH (p1:Product) WHERE id(p1) = node1
MATCH (p2:Product) WHERE id(p2) = node2
RETURN p1.name AS product,
       COLLECT_LIST({similar: p2.name, score: similarity}) AS recommendations
```

Recommend products to user:

```gql
MATCH (user:Customer {name: 'Alice'})-[:PURCHASED]->(bought:Product)
WITH user, COLLECT_LIST(bought) AS purchasedProducts

CALL algo.nodeSimilarity('Product', 'PURCHASED', {direction: 'INCOMING'})
YIELD node1, node2, similarity
WHERE node1 IN [p IN purchasedProducts | id(p)]
  AND NOT node2 IN [p IN purchasedProducts | id(p)]

MATCH (recommended:Product) WHERE id(recommended) = node2
RETURN recommended.name, SUM(similarity) AS relevanceScore
ORDER BY relevanceScore DESC
LIMIT 10
```

Store similarities as relationships:

```gql
CALL algo.nodeSimilarity('Customer', 'PURCHASED', {
  writeRelationshipType: 'SIMILAR_TO',
  writeProperty: 'score',
  similarityCutoff: 0.5
})
YIELD nodesCompared, relationshipsWritten

// Later query similar customers
MATCH (c:Customer {name: 'Alice'})-[s:SIMILAR_TO]->(similar:Customer)
RETURN similar.name, s.score
ORDER BY s.score DESC
```

## Jaccard Similarity

Jaccard similarity measures the ratio of shared neighbors to total neighbors. Values range from 0 (no overlap) to 1 (identical neighborhoods).

Jaccard similarity between specific nodes:

```gql
MATCH (a:Person {name: 'Alice'})-[:KNOWS]-(friendA)
MATCH (b:Person {name: 'Bob'})-[:KNOWS]-(friendB)
WITH a, b,
     COLLECT_LIST(DISTINCT friendA) AS setA,
     COLLECT_LIST(DISTINCT friendB) AS setB
RETURN a.name, b.name,
       algo.similarity.jaccard(setA, setB) AS jaccard
```

| a.name | b.name | jaccard |
| -- | -- | -- |
| Alice | Bob | 0.67 |

Find potential friends (high Jaccard = many mutual friends):

```gql
MATCH (user:Person {name: 'Alice'})
MATCH (other:Person)
WHERE other <> user
  AND NOT (user)-[:KNOWS]-(other)

MATCH (user)-[:KNOWS]-(mutual)-[:KNOWS]-(other)
WITH user, other, COUNT(DISTINCT mutual) AS mutualFriends
MATCH (user)-[:KNOWS]-(f1)
MATCH (other)-[:KNOWS]-(f2)
WITH user, other, mutualFriends,
     COUNT(DISTINCT f1) AS userFriends,
     COUNT(DISTINCT f2) AS otherFriends
LET jaccard = mutualFriends * 1.0 / (userFriends + otherFriends - mutualFriends)
WHERE jaccard > 0.3
RETURN other.name, mutualFriends, jaccard
ORDER BY jaccard DESC
```

Batch Jaccard computation:

```gql
CALL algo.similarity.jaccard.stream('Person', 'KNOWS', {
  topK: 5,
  similarityCutoff: 0.4
})
YIELD node1, node2, similarity
MATCH (p1:Person) WHERE id(p1) = node1
MATCH (p2:Person) WHERE id(p2) = node2
WHERE p1.department = p2.department
RETURN p1.name, p2.name, similarity
```

## Graph-Based Cosine Similarity

Cosine similarity measures similarity based on the angle between node vectors. In graph context, nodes are represented by their neighbor connection weights.

Cosine similarity with weighted edges:

```gql
CALL algo.similarity.cosine.stream('Person', 'INTERACTS', {
  relationshipWeightProperty: 'strength',
  topK: 10
})
YIELD node1, node2, similarity
MATCH (p1:Person) WHERE id(p1) = node1
MATCH (p2:Person) WHERE id(p2) = node2
RETURN p1.name, p2.name, similarity
ORDER BY similarity DESC
```

Compare specific pair with weighted relationships:

```gql
MATCH (a:Person {name: 'Alice'})-[r1:RATES]->(item)
MATCH (b:Person {name: 'Bob'})-[r2:RATES]->(item)
WITH a, b,
     COLLECT_LIST({item: item.name, scoreA: r1.rating, scoreB: r2.rating}) AS ratings
RETURN a.name, b.name,
       algo.similarity.cosine(
         [r IN ratings | r.scoreA],
         [r IN ratings | r.scoreB]
       ) AS cosineSim
```

## Overlap Coefficient

The overlap coefficient measures how much the smaller set is contained in the larger set. Useful for detecting subset relationships.

Find subset relationships:

```gql
MATCH (a:Category)-[:CONTAINS]->(itemA)
MATCH (b:Category)-[:CONTAINS]->(itemB)
WHERE a <> b
WITH a, b,
     COLLECT_LIST(DISTINCT itemA) AS setA,
     COLLECT_LIST(DISTINCT itemB) AS setB
LET overlapSize = SIZE([x IN setA WHERE x IN setB])
LET overlap = overlapSize * 1.0 / MIN(SIZE(setA), SIZE(setB))
WHERE overlap > 0.8
RETURN a.name AS category, b.name AS potentialParent, overlap
```

| category | potentialParent | overlap |
| -- | -- | -- |
| Smartphones | Electronics | 0.95 |
| Fiction | Books | 0.88 |

Find highly overlapping groups:

```gql
CALL algo.similarity.overlap.stream('Person', 'MEMBER_OF', {
  direction: 'OUTGOING'
})
YIELD node1, node2, similarity
WHERE similarity > 0.9
MATCH (g1:Group) WHERE id(g1) = node1
MATCH (g2:Group) WHERE id(g2) = node2
RETURN g1.name, g2.name, similarity AS overlap
```

## Link Prediction

Similarity can predict missing or future connections. High similarity between unconnected nodes suggests a potential link.

Adamic-Adar link prediction:

```gql
CALL algo.linkPrediction.adamicAdar('Person', 'KNOWS')
YIELD node1, node2, score
WHERE NOT EXISTS((node1)-[:KNOWS]-(node2))
MATCH (p1:Person) WHERE id(p1) = node1
MATCH (p2:Person) WHERE id(p2) = node2
RETURN p1.name, p2.name, score AS likelihood
ORDER BY likelihood DESC
LIMIT 20
```

| p1.name | p2.name | likelihood |
| -- | -- | -- |
| Alice | Frank | 4.82 |
| Bob | Grace | 3.91 |

Common neighbors link prediction:

```gql
MATCH (a:Person {name: 'Alice'})
MATCH (b:Person)
WHERE a <> b AND NOT (a)-[:KNOWS]-(b)
MATCH (a)-[:KNOWS]-(common)-[:KNOWS]-(b)
WITH a, b, COUNT(DISTINCT common) AS commonNeighbors
WHERE commonNeighbors >= 3
RETURN b.name AS suggestedConnection, commonNeighbors
ORDER BY commonNeighbors DESC
LIMIT 10
```

Preferential attachment:

```gql
CALL algo.linkPrediction.preferentialAttachment('Person', 'KNOWS')
YIELD node1, node2, score
WHERE NOT EXISTS((node1)-[:KNOWS]-(node2))
MATCH (p1:Person) WHERE id(p1) = node1
MATCH (p2:Person) WHERE id(p2) = node2
WHERE p1.company = p2.company  // Same company filter
RETURN p1.name, p2.name, score
ORDER BY score DESC
LIMIT 10
```
