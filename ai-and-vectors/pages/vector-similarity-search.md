# Vector Similarity Search

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

## Vector Index Search

For large datasets, create a vector index for efficient approximate nearest neighbor (ANN) search. See <a href="/docs/gql/vector-index">Vector Index</a> for full syntax.

Create a vector index:

```gql
CREATE VECTOR INDEX doc_search ON NODE Document (embedding) OPTIONS {
  dimensions: 1536,
  metric: "cosine"
}
```

### k-NN Search

Find the k nearest neighbors using `ORDER BY ... LIMIT`. The optimizer automatically uses the vector index:

```gql
LET query = ai.embed('how to model relationships in graphs')
MATCH (d:Document)
RETURN d.title, ai.cosine(d.embedding, query) AS similarity
ORDER BY similarity DESC
LIMIT 10
```

### Range Search

Find all vectors above a similarity threshold:

```gql
LET query = ai.embed('cloud computing tutorial')
MATCH (d:Document)
WHERE ai.cosine(d.embedding, query) > 0.7
RETURN d.title, ai.cosine(d.embedding, query) AS relevance
ORDER BY relevance DESC
```

### Hybrid Search

Combine vector similarity with graph traversal and property filters:

```gql
LET query = ai.embed('machine learning applications')
MATCH (d:Document)
WHERE ai.cosine(d.embedding, query) > 0.8
  AND d.category = 'Technology'
MATCH (d)-[:AUTHORED_BY]->(author:Person)
RETURN d.title, ai.cosine(d.embedding, query) AS similarity, author.name
ORDER BY similarity DESC
LIMIT 5
```

### RAG Context Retrieval

Retrieve context for Retrieval Augmented Generation:

```gql
LET query = ai.embed('How do I create a graph index?')
MATCH (d:Document)
RETURN d.content, ai.cosine(d.embedding, query) AS score
ORDER BY score DESC
LIMIT 3
```
