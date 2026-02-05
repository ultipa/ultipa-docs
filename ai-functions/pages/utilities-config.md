# Utilities & Configuration

## Overview

Vector utilities and AI provider configuration for embedding generation.

## Vector Utilities

Functions for working with vectors:

| Function | Description |
| -- | -- |
| `AI.DIMENSION(v)` | Get number of dimensions |
| `AI.NORMALIZE(v)` | Normalize to unit vector |
| `AI.MAGNITUDE(v)` | Get vector length |
| `AI.ADD(v1, v2)` | Add two vectors |
| `AI.TOLIST(v)` | Convert to list |

Get vector properties:

```gql
LET v = AI.VECTOR([3.0, 4.0])
RETURN
  AI.DIMENSION(v) AS dims,
  AI.MAGNITUDE(v) AS magnitude
```

| dims | magnitude |
| -- | -- |
| 2 | 5.0 |

Normalize embeddings:

```gql
MATCH (d:Document)
SET d.normalized_embedding = AI.NORMALIZE(d.embedding)
```

Combine and normalize vectors:

```gql
MATCH (p:Product)
LET combined = AI.ADD(p.text_embedding, p.image_embedding)
SET p.combined_embedding = AI.NORMALIZE(combined)
```

Convert vector to list:

```gql
MATCH (d:Document {id: 'DOC-1'})
RETURN d.title, AI.TOLIST(d.embedding) AS embedding_array
```

## Provider Configuration

Configure AI providers for embedding generation.

**Supported Providers:**

- OpenAI (text-embedding-3-small, text-embedding-3-large)
- Anthropic (Claude)
- Cohere (embed-english-v3.0)
- Ollama (local models)
- Google (Gemini)
- Custom HTTP endpoints

Configure OpenAI API key:

```gql
CALL AI.SETAPIKEY('openai', $OPENAI_API_KEY)
```

Set default embedding provider:

```gql
CALL AI.SETPROVIDER('openai')
```

Get current provider:

```gql
RETURN AI.PROVIDER() AS current_provider
```

| current_provider |
| -- |
| openai |

Configure local Ollama model:

```gql
CALL AI.SETPROVIDER('ollama', {
  endpoint: 'http://localhost:11434',
  model: 'nomic-embed-text'
})
```

Configure custom HTTP endpoint:

```gql
CALL AI.SETPROVIDER('custom', {
  endpoint: 'https://my-embeddings.example.com/embed',
  headers: {'Authorization': 'Bearer ' + $API_KEY},
  model: 'my-custom-model'
})
```

## Embedding Models

Different models produce different dimension vectors:

| Provider | Model | Dimensions | Best For |
| -- | -- | -- | -- |
| OpenAI | text-embedding-3-small | 1536 | General purpose |
| OpenAI | text-embedding-3-large | 3072 | High accuracy |
| Cohere | embed-english-v3.0 | 1024 | English text |
| Ollama | nomic-embed-text | 768 | Local/private |

Specify embedding model:

```gql
LET embedding = AI.embed('text to embed', 'text-embedding-3-large')
RETURN AI.DIMENSION(embedding) AS dimensions
```

| dimensions |
| -- |
| 3072 |

Verify dimension compatibility:

```gql
LET embedding = AI.embed('test text')
LET dims = AI.DIMENSION(embedding)

// Ensure consistency with existing embeddings
MATCH (d:Document)
WHERE d.embedding IS NOT NULL
LET existing_dims = AI.DIMENSION(d.embedding)
RETURN dims = existing_dims AS compatible
```

> **Warning:** All vectors in the same index must have the same dimensions. Choose your model carefully before creating embeddings.
