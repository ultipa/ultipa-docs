# AI Functions

Ultipa GQLDB provides built-in AI functions for working with vectors, embeddings, similarity search, and natural language query generation. All AI functions use the `ai.` prefix.

## Function Summary

### Provider Configuration

| Function | Description |
| -- | -- |
| `ai.setapikey()` | Set API key for an AI provider |
| `ai.setprovider()` | Set the active embedding provider |
| `ai.provider()` | Get the current embedding provider |
| `ai.embeddim()` | Get the embedding dimension of the current provider |
| `ai.setCompletionProvider()` | Set the active completion provider |
| `ai.completionProvider()` | Get the current completion provider |

### AI Completion

| Function | Description |
| -- | -- |
| `ai.gql()` | Convert natural language to a GQL query |
| `ai.read()` | Convert natural language to a read-only GQL query and execute it |
| `ai.explain()` | Run the NL-to-GQL pipeline and return the query with a reasoning trace |
| `ai.trace()` | Return the most recent NL-to-GQL pipeline trace |
| `ai.setAIConfig()` | Set a configuration parameter for the NL-to-GQL pipeline |
| `ai.aiConfig()` | Return the current NL-to-GQL pipeline configuration |
| `CALL ai.gql()` | Streaming procedure: convert natural language to GQL with real-time progress |
| `CALL ai.read()` | Streaming procedure: convert and execute with real-time progress |

### Vectors

| Function | Description |
| -- | -- |
| `ai.vector()` | Create a vector from a list of numbers |
| `ai.embed()` | Generate an embedding vector from text |
| `ai.embed_batch()` | Generate embeddings for multiple texts in a batch |

### Similarity & Search

| Function | Description |
| -- | -- |
| `ai.cosine()` | Compute cosine similarity between two vectors |
| `ai.euclidean()` | Compute Euclidean distance between two vectors |
| `ai.dot()` | Compute dot product of two vectors |
| `ai.distance()` | Compute cosine distance (1 - cosine similarity) |

### Utilities

| Function | Description |
| -- | -- |
| `ai.dimension()` | Get the number of dimensions in a vector |
| `ai.magnitude()` | Get the magnitude (L2 norm) of a vector |
| `ai.normalize()` | Normalize a vector to unit length |
| `ai.toList()` | Convert a vector to a list of numbers |
| `ai.add()` | Add two vectors element-wise |
| `ai.subtract()` | Subtract two vectors element-wise |
| `ai.scale()` | Multiply a vector by a scalar |
| `ai.rebuildIndex()` | Rebuild an HNSW vector index |
| `ai.setIndexOption()` | Update a runtime vector index option |
