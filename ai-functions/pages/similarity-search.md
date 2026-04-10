# Similarity & Search

## Overview

Compare vectors and perform semantic search to find related content.

## Similarity Functions

### ai.cosine()

Computes cosine similarity between two vectors. Returns a value between -1 and 1, where 1 means identical direction.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.cosine(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v1 = ai.vector([1.0, 0.0, 0.0])
LET v2 = ai.vector([1.0, 1.0, 0.0])
RETURN ai.cosine(v1, v2)
```

Result: 0.7071067690849304

### ai.euclidean()

Computes Euclidean distance between two vectors. Lower values indicate more similarity.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.euclidean(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v1 = ai.vector([1.0, 0.0])
LET v2 = ai.vector([0.0, 1.0])
RETURN ai.euclidean(v1, v2)
```

Result: 1.4142135381698608

### ai.dot()

Computes the dot product of two vectors.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.dot(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v1 = ai.vector([1.0, 2.0, 3.0])
LET v2 = ai.vector([4.0, 5.0, 6.0])
RETURN ai.dot(v1, v2)
```

Result: 32

### ai.distance()

Computes the cosine distance between two vectors (1 - cosine similarity). Lower values indicate more similarity.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.distance(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET v1 = ai.vector([1.0, 0.0, 0.0])
LET v2 = ai.vector([1.0, 1.0, 0.0])
RETURN ai.distance(v1, v2)
```

Result: 0.2928932309150696

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
LET query = ai.embed('how to model relationships in graphs')
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
LET query = ai.embed('machine learning applications')
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
LET query = ai.embed('cloud computing tutorial')
MATCH (d:Document)
WHERE d.category = 'Technology'
  AND d.published > date('2023-01-01')
  AND ai.cosine(d.embedding, query) > 0.7
RETURN d.title, d.published, ai.cosine(d.embedding, query) AS relevance
ORDER BY relevance DESC
LIMIT 10
```

Combine graph relationships with similarity:

```gql
MATCH (doc:Document {id: 'DOC-123'})-[:AUTHORED_BY]->(author)
MATCH (author)-[:AUTHORED_BY]-(other:Document)
WHERE other <> doc
RETURN other.title, ai.cosine(doc.embedding, other.embedding) AS similarity
ORDER BY similarity DESC
LIMIT 5
```

Retrieve context for RAG applications:

```gql
LET question = 'How do I create a graph index?'
LET questionVector = ai.embed(question)
CALL db.index.vector.search('doc_search', questionVector, 3)
YIELD node, score
RETURN COLLECT_LIST(node.content) AS context
```

| context |
| -- |
| [Creating indexes in GQL..., Index best practices..., Index types include...] |
