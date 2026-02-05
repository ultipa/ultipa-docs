# AI & Vector Functions

## Overview

AI and vector functions enable semantic search, similarity comparison, and embedding generation in GQL. Vectors (embeddings) are arrays of numbers that represent the semantic meaning of data.

## Vector Creation

### AI.VECTOR()

Creates a vector from an array of numbers.

**Syntax:**

```
AI.VECTOR(list) -> vector
```

**Example:**

```gql
LET v = AI.VECTOR([0.1, 0.2, 0.3, 0.4, 0.5])
RETURN AI.DIMENSION(v) AS dimensions
```

Result:

| dimensions |
| -- |
| 5 |

### AI.EMBED()

Generates an embedding vector from text using an AI provider.

**Syntax:**

```
AI.EMBED(text, model?) -> vector
```

**Example:**

```gql
LET embedding = AI.EMBED('Introduction to graph databases')
RETURN AI.DIMENSION(embedding) AS dimensions
```

```gql
// Use specific embedding model
LET embedding = AI.EMBED('text to embed', 'text-embedding-3-large')
RETURN AI.DIMENSION(embedding) AS dimensions
```

## Similarity Functions

### AI.COSINE()

Calculates cosine similarity between two vectors. Returns a value between -1 and 1, where 1 means identical direction.

**Syntax:**

```
AI.COSINE(vector1, vector2) -> float
```

**Example:**

```gql
LET query = AI.EMBED('graph database tutorial')
MATCH (d:Document)
RETURN d.title, AI.COSINE(d.embedding, query) AS similarity
ORDER BY similarity DESC
LIMIT 5
```

### AI.EUCLIDEAN()

Calculates Euclidean distance between two vectors. Lower values indicate more similarity.

**Syntax:**

```
AI.EUCLIDEAN(vector1, vector2) -> float
```

**Example:**

```gql
MATCH (p1:Product {id: 'A'}), (p2:Product)
WHERE p1 <> p2
RETURN p2.name, AI.EUCLIDEAN(p1.embedding, p2.embedding) AS distance
ORDER BY distance ASC
LIMIT 5
```

### AI.MANHATTAN()

Calculates Manhattan distance between two vectors.

**Syntax:**

```
AI.MANHATTAN(vector1, vector2) -> float
```

### AI.DOT()

Calculates dot product of two vectors. Best used with normalized vectors.

**Syntax:**

```
AI.DOT(vector1, vector2) -> float
```

**Example:**

```gql
MATCH (a:Article), (b:Article)
WHERE a.id < b.id
RETURN a.title, b.title, AI.DOT(a.embedding, b.embedding) AS similarity
ORDER BY similarity DESC
LIMIT 10
```

### AI.DISTANCE()

General distance function with configurable metric.

**Syntax:**

```
AI.DISTANCE(vector1, vector2, metric?) -> float
```

## Vector Utilities

### AI.DIMENSION()

Returns the number of dimensions in a vector.

**Syntax:**

```
AI.DIMENSION(vector) -> int
```

**Example:**

```gql
LET v = AI.VECTOR([3.0, 4.0])
RETURN AI.DIMENSION(v) AS dims
```

Result:

| dims |
| -- |
| 2 |

### AI.MAGNITUDE()

Returns the length (magnitude) of a vector.

**Syntax:**

```
AI.MAGNITUDE(vector) -> float
```

**Example:**

```gql
LET v = AI.VECTOR([3.0, 4.0])
RETURN AI.MAGNITUDE(v) AS magnitude
```

Result:

| magnitude |
| -- |
| 5.0 |

### AI.NORMALIZE()

Normalizes a vector to a unit vector (magnitude of 1).

**Syntax:**

```
AI.NORMALIZE(vector) -> vector
```

**Example:**

```gql
MATCH (d:Document)
SET d.normalized_embedding = AI.NORMALIZE(d.embedding)
```

### AI.TOLIST()

Converts a vector to a list of numbers.

**Syntax:**

```
AI.TOLIST(vector) -> list
```

**Example:**

```gql
MATCH (d:Document {id: 'DOC-1'})
RETURN d.title, AI.TOLIST(d.embedding) AS embedding_array
```

## Vector Arithmetic

### AI.ADD()

Adds two vectors element-wise.

**Syntax:**

```
AI.ADD(vector1, vector2) -> vector
```

**Example:**

```gql
MATCH (p:Product)
LET combined = AI.ADD(p.text_embedding, p.image_embedding)
SET p.combined_embedding = AI.NORMALIZE(combined)
```

### AI.SUBTRACT()

Subtracts the second vector from the first.

**Syntax:**

```
AI.SUBTRACT(vector1, vector2) -> vector
```

### AI.SCALE()

Multiplies a vector by a scalar value.

**Syntax:**

```
AI.SCALE(vector, scalar) -> vector
```

## Provider Configuration

### AI.SETAPIKEY()

Sets the API key for an AI provider.

**Syntax:**

```
CALL AI.SETAPIKEY(provider, apiKey)
```

**Example:**

```gql
CALL AI.SETAPIKEY('openai', $OPENAI_API_KEY)
```

### AI.PROVIDER()

Returns the current AI provider.

**Syntax:**

```
AI.PROVIDER() -> string
```

**Example:**

```gql
RETURN AI.PROVIDER() AS current_provider
```

### AI.EMBEDDIM()

Returns the embedding dimensions for the current provider/model.

**Syntax:**

```
AI.EMBEDDIM(model?) -> int
```

## Embedding Models

Different models produce different dimension vectors:

| Provider | Model | Dimensions | Best For |
| -- | -- | -- | -- |
| OpenAI | text-embedding-3-small | 1536 | General purpose |
| OpenAI | text-embedding-3-large | 3072 | High accuracy |
| Cohere | embed-english-v3.0 | 1024 | English text |
| Ollama | nomic-embed-text | 768 | Local/private |

> All vectors in the same index must have the same dimensions. Choose your model carefully before creating embeddings.
