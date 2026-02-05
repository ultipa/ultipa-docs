# Similarity & Search

## Overview

Compare vectors and perform semantic search to find related content.

## Similarity Functions

Compare vectors using different similarity measures:

| Function | Description | Range | Best For |
| -- | -- | -- | -- |
| `AI.COSINE(v1, v2)` | Cosine similarity | -1 to 1 | Text embeddings |
| `AI.EUCLIDEAN(v1, v2)` | Euclidean distance | 0 to ∞ | Spatial data |
| `AI.DOT(v1, v2)` | Dot product | varies | Normalized vectors |

**Cosine Similarity** is most common for text because it measures angle (direction), not magnitude.

Semantic search using cosine similarity:

```gql
LET query = AI.embed('graph database tutorial')
MATCH (d:Document)
RETURN d.title, AI.COSINE(d.embedding, query) AS similarity
ORDER BY similarity DESC
LIMIT 5
```

| d.title | similarity |
| -- | -- |
| Introduction to Graph Databases | 0.94 |
| GQL Query Language Guide | 0.87 |
| Database Design Patterns | 0.72 |

Find nearest products by Euclidean distance:

```gql
MATCH (p1:Product {id: 'A'}), (p2:Product)
WHERE p1 <> p2
RETURN p2.name, AI.EUCLIDEAN(p1.embedding, p2.embedding) AS distance
ORDER BY distance ASC
LIMIT 5
```

| p2.name | distance |
| -- | -- |
| Similar Product 1 | 0.23 |
| Similar Product 2 | 0.45 |
| Related Product | 0.67 |

Find related article pairs:

```gql
MATCH (a:Article), (b:Article)
WHERE a.id < b.id  // Avoid duplicates
RETURN a.title, b.title, AI.DOT(a.embedding, b.embedding) AS similarity
ORDER BY similarity DESC
LIMIT 10
```

## Vector Search

For large datasets, use vector indexes for efficient approximate nearest neighbor (ANN) search.

Create vector index for fast search:

```gql
CREATE VECTOR INDEX doc_search
FOR (d:Document)
ON (d.embedding)
OPTIONS {
  dimensions: 1536,
  similarity: 'cosine'
}
```

Efficient ANN search using index:

```gql
LET query = AI.embed('how to model relationships in graphs')
CALL db.index.vector.search('doc_search', query, 10)
YIELD node, score
RETURN node.title, score
```

| node.title | score |
| -- | -- |
| Graph Relationship Modeling | 0.96 |
| Introduction to GQL | 0.89 |
| Entity Relationship Design | 0.82 |

Vector search combined with graph traversal:

```gql
LET query = AI.embed('machine learning applications')
CALL db.index.vector.search('doc_search', query, 5)
YIELD node AS doc, score
MATCH (doc)-[:AUTHORED_BY]->(author:Person)
MATCH (author)-[:WORKS_AT]->(company:Company)
RETURN doc.title, score, author.name, company.name
```

| doc.title | score | author.name | company.name |
| -- | -- | -- | -- |
| ML in Practice | 0.95 | Alice Chen | TechCorp |
| Deep Learning Guide | 0.91 | Bob Smith | AI Labs |

## Hybrid Search

Combine vector similarity with traditional graph queries for best results.

Vector search with property filters:

```gql
LET query = AI.embed('cloud computing tutorial')
MATCH (d:Document)
WHERE d.category = 'Technology'
  AND d.published > date('2023-01-01')
  AND AI.COSINE(d.embedding, query) > 0.7
RETURN d.title, d.published, AI.COSINE(d.embedding, query) AS relevance
ORDER BY relevance DESC
LIMIT 10
```

Combine graph relationships with similarity:

```gql
MATCH (doc:Document {id: 'DOC-123'})-[:AUTHORED_BY]->(author)
MATCH (author)-[:AUTHORED_BY]-(other:Document)
WHERE other <> doc
RETURN other.title, AI.COSINE(doc.embedding, other.embedding) AS similarity
ORDER BY similarity DESC
LIMIT 5
```

Retrieve context for RAG applications:

```gql
LET question = 'How do I create a graph index?'
LET questionVector = AI.embed(question)
CALL db.index.vector.search('doc_search', questionVector, 3)
YIELD node, score
RETURN COLLECT_LIST(node.content) AS context
```

| context |
| -- |
| [Creating indexes in GQL..., Index best practices..., Index types include...] |
