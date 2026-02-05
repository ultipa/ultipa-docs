# Vector Fundamentals

## Overview

Understanding vectors and embeddings in graph databases.

## What are Vectors?

**Vectors** (or **embeddings**) are arrays of numbers that represent the semantic meaning of data. They enable:

- **Semantic Search** - Find content by meaning, not just keywords
- **Recommendations** - Suggest similar items based on features
- **Clustering** - Group related items together
- **RAG (Retrieval Augmented Generation)** - Enhance AI with your data

**How they work:**

- Text, images, or other data is converted to a vector
- Similar items have vectors that are "close" in vector space
- Distance/similarity measures find related items

```gql
// Example: Vector representation
// "Introduction to Graph Databases" might become:
// [0.12, -0.45, 0.78, 0.23, -0.89, 0.56, ...]
// (typically 384 to 1536 dimensions)
```

## Use Cases

Common use cases for vectors in graph databases:

**Semantic Search**

Find documents by meaning, not just keywords

**Recommendation Systems**

"Users who liked X also liked Y"

**Knowledge Graph Enhancement**

Connect entities based on semantic similarity

**Duplicate Detection**

Find near-duplicate content

**Multi-modal Search**

Search across text, images, and other media

Semantic search example:

```gql
// Find documents about graph databases
// even if they don't contain those exact words
LET query = AI.embed('how do nodes connect in a network')
MATCH (d:Document)
WHERE AI.COSINE(d.embedding, query) > 0.8
RETURN d.title
```

Product recommendation:

```gql
MATCH (p:Product {id: 'PROD-123'})
MATCH (similar:Product)
WHERE similar <> p AND AI.COSINE(p.embedding, similar.embedding) > 0.85
RETURN similar.name, similar.price
LIMIT 5
```

## Creating Vectors

Two ways to create vectors in GQL:

| Function | Syntax | Description |
| -- | -- | -- |
| AI.VECTOR() | `AI.VECTOR([n1, n2, ...])` | Create vector from array of numbers |
| AI.embed() | `AI.embed(text, model?)` | Generate embedding from text using AI |

Create vector from array:

```gql
LET v = AI.VECTOR([0.1, 0.2, 0.3, 0.4, 0.5])
RETURN AI.DIMENSION(v) AS dimensions
```

| dimensions |
| -- |
| 5 |

Generate embedding from text:

```gql
LET embedding = AI.embed('Introduction to graph databases')
RETURN AI.DIMENSION(embedding) AS dimensions
```

| dimensions |
| -- |
| 1536 |

Store document with embedding:

```gql
INSERT (:Document {
  title: 'Graph Database Tutorial',
  content: 'Graphs are powerful data structures...',
  embedding: AI.embed('Graph Database Tutorial: Graphs are powerful data structures...')
})
```

Batch generate embeddings for existing documents:

```gql
MATCH (d:Document)
WHERE d.embedding IS NULL
SET d.embedding = AI.embed(d.title + ' ' + d.content)
```

Use specific embedding model:

```gql
MATCH (d:Document)
SET d.embedding = AI.embed(d.content, 'text-embedding-3-small')
```
