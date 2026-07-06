# Vectors

## What are Vectors

Embeddings are a way of turning structured data (e.g., text) or unstructured data (e.g., images) into lists of numbers that capture their meaning. That list of numbers is the **vector**.

Here's the core idea. Computers can't directly understand "cat" or "happy" as concepts. So we represent each item as a point in a high-dimensional space, written as a vector like `[0.21, -0.88, 0.43, ...]`. These vectors might have hundreds or thousands of dimensions. The critical part is that **similar things end up close together in that space**, and dissimilar things end up far apart. So the vector for "cat" lands near the vector for "kitten" and "dog", but far from "airplane". The geometry of the space encodes semantic relationships.

## How are Vectors Created

Various **embedding models** are trained on large amounts of data and learn to assign each item a vector so that meaningful patterns are encoded in its position. Items with similar meaning end up close together in the space, while dissimilar items end up far apart.

## How are Vectors Used

Every use of vectors rests on a single idea: **similarity between two items can be measured as distance in the vector space.** Once you can measure that, a range of capabilities follows:

- **Vector search**: Embed a query (usually written in natural language), then retrieve the stored vectors closest to it. This powers semantic search and retrieval-augmented generation (RAG) for LLMs.
- **Recommendation**: Surface items near the ones a user already likes.
- **Clustering and classification**: Group items by their proximity in the space, or label them based on where they fall.
- **Multi-modal search**: Search across text, images, and other media within a shared vector space.

These differ in shape — some retrieve, some group, some label — but all draw on the same notion of vector similarity.

## Loading Vectors into GQLDB

GQLDB supports the `VECTOR(N)` property type, where `N` is the dimension of the vector. If you already have precomputed vectors, you can import them into `VECTOR(N)` properties. To assign a `VECTOR(N)` value using GQL, use the `ai.vector()` or `ai.embed()` function.

## Quick Start

### 1. Set Embedding Model

```gql
-- View all AI providers and their embedding models (e.g., OpenAI with text-embedding-3-small)
SHOW AI PROVIDERS

-- Set the API key for an AI provider, such as OpenAI
RETURN ai.set_api_key("openai", "sk-...")

-- Check the current active AI provider for embedding and the embedding dimension
RETURN ai.provider(), ai.embed_dim()

-- Switch to another embedding model if necessary
RETURN ai.set_embedding_model("openai", "text-embedding-3-large")
```

### 2. Prepare Example Graph

The example graph consists of 10 `Book` nodes, each with properties `title`, `author`, and `summary` (edges are omitted):

<p tit="GQL" fold="true"></p>

```gql
CREATE GRAPH example;
USE example;

INSERT (:Book {_id: 'B1', title: 'Pride and Prejudice', author: 'Jane Austen', summary: 'Elizabeth Bennet navigates love and social class in Regency-era England, clashing with the proud Mr. Darcy before realizing their true feelings for each other. The novel explores themes of marriage, reputation, and personal growth with Austen\'s sharp wit.'}),
       (:Book {_id: 'B2', title: '1984', author: 'George Orwell', summary: 'In a dystopian future, Winston Smith struggles under the oppressive rule of Big Brother, where thought control, surveillance, and propaganda dictate every aspect of life. His rebellion leads to devastating consequences, highlighting themes of totalitarianism and free will.'}),
       (:Book {_id: 'B3', title: 'To Kill a Mockingbird', author: 'Harper Lee', summary: 'Set in the racially segregated American South, young Scout Finch learns about justice, morality, and compassion as her father, Atticus, defends a Black man falsely accused of a crime. The novel critiques racial injustice and moral integrity.'}),
       (:Book {_id: 'B4', title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', summary: 'Jay Gatsby, a wealthy but mysterious man, throws lavish parties in an attempt to win back his lost love, Daisy Buchanan. Through the eyes of Nick Carraway, the novel explores themes of the American Dream, class, and the illusions of wealth.'}),
       (:Book {_id: 'B5', title: 'Moby-Dick', author: 'Herman Melville', summary: 'Ishmael joins a whaling expedition led by the obsessed Captain Ahab, who is determined to hunt the white whale, Moby-Dick. The novel explores themes of fate, obsession, and the limits of human knowledge through rich symbolism and philosophical depth.'}),
       (:Book {_id: 'B6', title: 'Crime and Punishment', author: 'Fyodor Dostoevsky', summary: 'Raskolnikov, a destitute student in St. Petersburg, commits murder under the belief that he is above moral law. As guilt consumes him, he is drawn into a psychological battle with an investigator, ultimately finding redemption through suffering and confession.'}),
       (:Book {_id: 'B7', title: 'Brave New World', author: 'Aldous Huxley', summary: 'In a future society where pleasure, consumerism, and genetic engineering maintain stability, Bernard Marx questions the cost of happiness. When he introduces a \'savage\' to this world, the encounter exposes the dark side of a society that sacrifices individuality for order.'}),
       (:Book {_id: 'B8', title: 'The Catcher in the Rye', author: 'J.D. Salinger', summary: 'Teenager Holden Caulfield narrates his journey through New York City after being expelled from prep school, revealing his struggles with identity, alienation, and the transition into adulthood. His cynical yet vulnerable perspective has resonated with generations of readers.'}),
       (:Book {_id: 'B9', title: 'Frankenstein', author: 'Mary Shelley', summary: 'Victor Frankenstein, a scientist obsessed with creating life, brings a monstrous being to existence but abandons it in fear. The novel explores themes of scientific responsibility, the nature of humanity, and the consequences of unchecked ambition.'}),
       (:Book {_id: 'B10', title: 'One Hundred Years of Solitude', author: 'Gabriel García Márquez', summary: 'Following the Buendía family across multiple generations in the fictional town of Macondo, this novel blends history, myth, and magical realism to explore themes of fate, solitude, and the cyclical nature of time.'})
```

### 3. Create Vectors

Use the embedding model set in step 1 to embed each book's `summary`, and store the generated vector on a new property `summaryEmbedding`:

```gql
MATCH (n:Book)
SET n.summaryEmbedding = ai.embed(n.summary)
RETURN n._id, n.summaryEmbedding
```

### 4. Semantic Search

With the embeddings stored, you can find the books whose summaries are closest in meaning to a query. Embed the query text first, then rank each book by the cosine similarity between its `summaryEmbedding` and the query vector:

```gql
LET query = ai.embed('a young person coming of age')
MATCH (n:Book)
RETURN n.title, ai.cosine(n.summaryEmbedding, query) AS similarity
ORDER BY similarity DESC LIMIT 3
```

Result:

| n.title | similarity |
| -- | -- |
| The Catcher in the Rye | 0.3950163722038269 |
| To Kill a Mockingbird | 0.2520180344581604 |
| Crime and Punishment | 0.24258658289909363 |

The top match, *The Catcher in the Rye*, is the classic coming-of-age story — yet none of the query words ("young person coming of age") appear in its summary. That's semantic search: it matches on **meaning**, not keywords, so it surfaces the right book where a keyword search would find nothing.

> **Judge by ranking, not absolute score.** Cosine values for a short query against longer text are often modest (here the best match is ~0.40), and the typical range varies by embedding model. What matters is the relative order, `0.40` is a clear top hit. Don't read it as "only 40% relevant," and don't apply a fixed threshold (e.g. `> 0.7`) without calibrating it to your model and data.

This scans every `Book` and scores it (a brute-force search), fine for a small graph. On a large graph, create a vector index on `summaryEmbedding` so the same query is served by fast approximate nearest-neighbor search instead; see <a href="/docs/ai-and-vectors/vector-index" target="_blank">Vector Index</a>.

## Vector Creation Functions

### vector()

Converts a list of numbers — or a vector string with an explicit dimension and coordinate type — to a `VECTOR(N)` type. This is useful when you need to explicitly create a value for storing in a `VECTOR(N)` property or passing to similarity functions. `ai.vector()` is a synonym.

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
      <td colspan="3"><code>vector(&lt;list&gt;)</code> or <code>vector('&lt;string&gt;', &lt;dimension&gt;, &lt;coordinate type&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="5"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>A list of numeric values (1-argument form).</td>
    </tr>
    <tr>
      <td><code>&lt;string&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The vector as a bracketed string, e.g. <code>'[1.1, 1.2, 1.3]'</code>.</td>
    </tr>
    <tr>
      <td><code>&lt;dimension&gt;</code></td>
      <td><code>INT</code></td>
      <td>The number of coordinates in the string.</td>
    </tr>
    <tr>
      <td><code>&lt;coordinate type&gt;</code></td>
      <td>keyword</td>
      <td>A float type (<code>FLOAT</code>, <code>FLOAT32</code>, <code>FLOAT64</code>, <code>DOUBLE</code>, <code>REAL</code>) or an integer type (<code>INT</code>, <code>INTEGER</code>, <code>INT8</code>, <code>INT16</code>, <code>INT32</code>, <code>INT64</code>). An integer type requires every coordinate to be whole-numbered.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
-- Each dimension value is stored as 32-bit floats, so minor precision differences may occur (e.g., `0.1` becomes `0.10000000149011612`)
RETURN vector([0.1, 0.2, 0.3])
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

The 3-argument form takes the vector as a bracketed string. Coordinates are always stored as 32-bit floats regardless of the declared coordinate type (it is a validation constraint, not a separate storage type):

```gql
-- FLOAT coordinate type accepts decimals
RETURN vector('[1.1, 1.2, 1.3]', 3, FLOAT)

-- INT requires whole-number coordinates
RETURN vector('[1, 2, 3]', 3, INT)

-- Error: coordinate 1 (1.1) is not representable as INT
RETURN vector('[1.1, 1.2, 1.3]', 3, INT)
```

> The list form `vector([1.1, 1.2, 1.3])` is the recommended, stable syntax. The 3-argument constructor is a draft-standard form that may change, and using it emits a warning.

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

An AI provider must be configured with `ai.set_api_key()` before using this function.

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
## Vector Similarity Functions

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
RETURN ai.cosine(ai.vector([1.0, 0.0, 0.0]), ai.vector([1.0, 1.0, 0.0]))
```

Result: 0.7071067690849304

### ai.euclidean()

Computes Euclidean (L2) distance between two vectors. Lower values indicate more similarity. `ai.l2()` is a synonym.

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
RETURN ai.euclidean(ai.vector([1.0, 0.0]), ai.vector([0.0, 1.0]))
```

Result: 1.4142135381698608

### ai.euclidean_squared()

Computes the squared Euclidean distance between two vectors — sum of `(Ai − Bi)²` with no final square root. Produces the same ordering as `ai.euclidean()` but is cheaper to compute, so it's preferred when you only need to rank nearest neighbors and don't care about the absolute distance value.

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
      <td colspan="3"><code>ai.euclidean_squared(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
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
RETURN ai.euclidean_squared(ai.vector([0.0, 0.0]), ai.vector([3.0, 4.0]))
```

Result: 25

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
RETURN ai.dot(ai.vector([1.0, 2.0, 3.0]), ai.vector([4.0, 5.0, 6.0]))
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
RETURN ai.distance(ai.vector([1.0, 0.0, 0.0]), ai.vector([1.0, 1.0, 0.0]))
```

Result: 0.2928932309150696

### ai.manhattan()

Computes the Manhattan (L1) distance between two vectors — sum of `|Ai − Bi|`. Lower values indicate more similarity.

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
      <td colspan="3"><code>ai.manhattan(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
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
RETURN ai.manhattan(ai.vector([0.0, 0.0]), ai.vector([3.0, 4.0]))
```

Result: 7

### ai.hamming()

Computes the Hamming distance between two vectors — count of coordinates that differ.

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
      <td colspan="3"><code>ai.hamming(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
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
RETURN ai.hamming(ai.vector([1.0, 2.0, 3.0]), ai.vector([1.0, 9.0, 3.0]))
```

Result: 1

### vector_distance()

A single function call covers all six distance metrics, with all results in the **distance form** ("smaller = more similar"). 

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
      <td colspan="3"><code>vector_distance(&lt;vector1&gt;, &lt;vector2&gt;, &lt;metric&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector.</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code>.</td>
    </tr>
    <tr>
      <td><code>&lt;metric&gt;</code></td>
      <td><code>STRING</code> or bare keyword</td>
      <td>One of <code>EUCLIDEAN</code>, <code>EUCLIDEAN_SQUARED</code>, <code>MANHATTAN</code>, <code>COSINE</code>, <code>DOT</code>, <code>HAMMING</code>. Bare-keyword and quoted-string forms are equivalent.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN vector_distance(ai.vector([0.0, 0.0]), ai.vector([3.0, 4.0]), EUCLIDEAN)
```

Result: 5

Mapping to the per-metric `ai.*` aliases on the same `(v1, v2)`:

| Metric | Equivalent `ai.*` expression |
| -- | -- |
| `EUCLIDEAN` | `ai.euclidean(v1, v2)` |
| `EUCLIDEAN_SQUARED` | `ai.euclidean_squared(v1, v2)` |
| `MANHATTAN` | `ai.manhattan(v1, v2)` |
| `HAMMING` | `ai.hamming(v1, v2)` |
| `COSINE` | `ai.distance(v1, v2)`, i.e. `1 − ai.cosine(v1, v2)` |
| `DOT` | `-ai.dot(v1, v2)` （negates the dot product so "smaller = more similar" ordering matches the other metrics） |

## Vector Inspection Functions

### ai.dimension()

Returns the number of dimensions in a vector. `vector_dimension_count()` is a synonym.

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
      <td colspan="3"><code>ai.dimension(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.dimension(ai.vector([3.0, 4.0]))
```

Result: 2

### ai.magnitude()

Returns the magnitude (L2 norm) of a vector. `ai.norm()` is a synonym.

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
      <td colspan="3"><code>ai.magnitude(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.magnitude(ai.vector([3.0, 4.0]))
```

Result: 5

### ai.normalize()

Normalizes a vector to a unit vector (magnitude of 1).

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
      <td colspan="3"><code>ai.normalize(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.normalize(ai.vector([3.0, 4.0]))
```

Result:

```json
{
  "values": [
    0.6000000238418579,
    0.800000011920929
  ]
}
```

### ai.toList()

Converts a vector to a list of numbers.

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
      <td colspan="3"><code>ai.toList(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.toList(ai.embed("Introduction to graph databases"))
```

Result: [-0.0258026123046875, -0.0126800537109375, …, 0.0162200927734375, -0.017486572265625]

### vector_norm()

Returns the norm (length) of a vector under the given metric. `vector_norm(v, EUCLIDEAN)` is identical to `ai.magnitude(v)`; the `MANHATTAN` form returns the L1 norm (sum of `|Ai|`) and has no `ai.*` equivalent.

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
      <td colspan="3"><code>vector_norm(&lt;vector&gt;, &lt;metric&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value.</td>
    </tr>
    <tr>
      <td><code>&lt;metric&gt;</code></td>
      <td><code>STRING</code> or bare keyword</td>
      <td>One of <code>EUCLIDEAN</code> (L2 norm) or <code>MANHATTAN</code> (L1 norm). Bare-keyword and quoted-string forms are equivalent.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN vector_norm(ai.vector([3.0, 4.0]), EUCLIDEAN)
```

Result: 5

### vector_serialize()

Converts a vector to its textual list form (`"[N1, N2, …]"`). The string counterpart to `ai.toList()`, which returns a `LIST<FLOAT>`.

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
      <td colspan="3"><code>vector_serialize(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN vector_serialize(ai.vector([0.1, 0.2, 0.3]))
```

Result: `"[0.1, 0.2, 0.3]"`

## Vector Arithmetic Functions

### ai.add()

Adds two vectors element-wise.

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
      <td colspan="3"><code>ai.add(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
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
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.toList(ai.add(ai.vector([1.0, 2.0]), ai.vector([3.0, 4.0])))
```

Result: [4, 6]

### ai.subtract()

Subtracts the second vector from the first element-wise.

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
      <td colspan="3"><code>ai.subtract(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
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
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.toList(ai.subtract(ai.vector([5.0, 3.0]), ai.vector([1.0, 2.0])))
```

Result: [4, 1]

### ai.scale()

Multiplies a vector by a scalar value.

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
      <td colspan="3"><code>ai.scale(&lt;vector&gt;, &lt;scalar&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><code>&lt;scalar&gt;</code></td>
      <td>Numeric</td>
      <td>The scalar multiplier</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.toList(ai.scale(ai.vector([1.0, 2.0, 3.0]), 2))
```

Result: [2, 4, 6]

