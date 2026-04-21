# Vectors

Create and manage vector embeddings for semantic search, recommendations, and AI-powered graph queries. Use `ai.setprovider()` to set the active embedding AI provider.

## What are Vectors?

**Vectors** (or **embeddings**) are arrays of numbers that represent the semantic meaning of data. They enable:

- **Semantic Search:** Find content by meaning, not just keywords
- **Recommendations:** Suggest similar items based on features
- **Clustering:** Group related items together
- **RAG (Retrieval Augmented Generation):** Enhance AI with your data

**How they work:**

- Text, images, or other data is converted to a vector
- Similar items have vectors that are "close" in vector space
- Distance/similarity measures find related items

## Use Cases

Common use cases for vectors in graph databases:

- **Semantic Search:** Find documents by meaning, not just keywords
- **Recommendation Systems:** "Users who liked X also liked Y"
- **Knowledge Graph Enhancement:** Connect entities based on semantic similarity
- **Duplicate Detection:** Find near-duplicate content
- **Multi-modal Search:** Search across text, images, and other media

Semantic search example:

```gql
// Find documents about graph databases
// even if they don't contain those exact words
LET query = ai.embed('how do nodes connect in a network')
MATCH (d:Document)
WHERE ai.cosine(d.embedding, query) > 0.8
RETURN d.title
```

Product recommendation:

```gql
MATCH (p:Product {id: 'PROD-123'})
MATCH (similar:Product)
WHERE similar <> p AND ai.cosine(p.embedding, similar.embedding) > 0.85
RETURN similar.name, similar.price
LIMIT 5
```

## Vector Creation

### ai.vector()

Converts a list of numbers to a `VECTOR` type. Values are stored as 32-bit floats, so minor precision differences may occur (e.g., `0.1` becomes `0.10000000149011612`). This is useful when you need to explicitly create a `VECTOR` value for storing in a `VECTOR` property or passing to similarity functions.

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
      <td colspan="3"><code>ai.vector(&lt;list&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>A list of numeric values</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.vector([0.1, 0.2, 0.3])
```

Result:

```json
{
  "values": [
    0.10000000149011612,
    0.20000000298023224,
    0.30000001192092896
  ]
}
```

### ai.embed()

Generates an embedding vector from text using the configured AI provider.

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
      <td colspan="3"><code>ai.embed(&lt;text&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;text&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The text to generate an embedding for</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

An AI provider must be configured with `ai.setapikey()` before using this function.

```gql
LET embedding = ai.embed("Introduction to graph databases")
RETURN embedding, ai.dimension(embedding) AS dimensions
```

Result:

```json
{
  "embedding": {
    "values": [
      -0.0258026123046875,
      -0.0126800537109375,
      …
      0.0162200927734375,
      -0.017486572265625
    ]
  },
  "dimensions": 1536
}
```

### ai.embed_batch()

Generates embedding vectors for multiple texts in a single batched call. Supports up to 2048 inputs, internally chunked for efficiency. `Null` or non-string elements produce `null` vectors at the same index.

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
      <td colspan="3"><code>ai.embed_batch(&lt;texts&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;texts&gt;</code></td>
      <td><code>LIST</code></td>
      <td>A list of strings to generate embeddings for</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST&lt;VECTOR&gt;</code></td>
    </tr>
  </tbody>
</table>

```gql
LET texts = ["graph databases", "machine learning", "data science"]
RETURN ai.embed_batch(texts)
```

Result:

```json
[
  {
    "values": [
      -0.000690460205078125,
      0.034271240234375,
      …
      0.033294677734375,
      -0.00782012939453125
    ]
  },
  {
    "values": [
      -0.0121917724609375,
      -0.0113372802734375,
     …
      -0.01312255859375,
      -0.0019989013671875
    ]
  },
  {
    "values": [
      0.0034503936767578125,
      -0.010650634765625,
      …      
      0.00691986083984375,
      0.02203369140625
    ]
  }
]
```