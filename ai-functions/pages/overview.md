# AI Functions

Ultipa GQLDB provides built-in AI functions for working with vectors, embeddings, similarity search, and natural language query generation. All AI functions use the `ai.` prefix.

## Supported Providers

List all registered AI providers with their configuration and status:

```gql
SHOW AI PROVIDERS
```

Result:

| provider | supports | embedding_model | embedding_dim | completion_model | base_url | status | Description|
| -- | -- | -- | -- | -- | -- | -- | -- |
| openai | embedding,completion | text-embedding-3-small | 1536 | gpt-4o-mini | https://api.openai.com/v1 | configured | OpenAI (GPT, text-embedding-3 family) |
| gemini | embedding,completion | gemini-embedding-001 | 3072 | gemini-2.5-flash | https://generativelanguage.googleapis.com/v1beta | configured | Google Gemini (native GenerateContent/Embed API) |
| qwen | embedding,completion | text-embedding-v3 | 1024 | qwen3-max | https://dashscope-intl.aliyuncs.com/compatible-mode/v1 | unconfigured | Alibaba DashScope Qwen (OpenAI-compatible) |
| lmstudio | embedding,completion | `null` | `null` | `null` | http://localhost:1234/v1 | unconfigured | LM Studio (local OpenAI-compatible server) |
| anthropic | completion | `null` | `null` | claude-sonnet-4-5 | https://api.anthropic.com/v1 | unconfigured | Anthropic Claude (completion only) |
| xai | completion | `null` | `null` | grok-4-1-fast-reasoning | https://api.x.ai/v1 | unconfigured | xAI Grok (OpenAI-compatible, completion only) |
| deepseek | completion | `null` | `null` | deepseek-chat | https://api.deepseek.com/v1 | unconfigured | DeepSeek (OpenAI-compatible, completion only) |
| minimax | completion | `null` | `null` | MiniMax-M2 | https://api.minimax.io/v1 | unconfigured | MiniMax (OpenAI-compatible, completion only) |

Use this to verify which providers have API keys configured, which are active, and whether they support embedding, completion, or both.

## Embedding vs Completion

AI functions rely on two types of AI providers:

- **Embedding providers** convert text into high-dimensional vectors (embeddings) that capture semantic meaning. These vectors enable similarity search, recommendations, and clustering. Functions like `ai.embed()` and `ai.cosine()` use the embedding provider.

- **Completion providers** use large language models to generate or execute GQL queries from natural language. Functions like `ai.gql()` and `ai.read()` use the completion provider.

Some providers support both embedding and completion, while others support only one. You can configure different providers for each role (e.g., OpenAI for embeddings, Anthropic for completion).

## Function Summary

### Provider Configuration

| Function | Description |
| -- | -- |
| `ai.setapikey()` | Sets the API key for an AI provider. |
| `ai.setprovider()` | Sets the active embedding provider. |
| `ai.provider()` | Returns the name of the current embedding provider. |
| `ai.embeddim()` | Returns the embedding dimension of the current provider. |
| `ai.setCompletionProvider()` | Sets the active completion provider. |
| `ai.completionProvider()` | Returns the name of the current completion provider. |

### AI Completion

| Function | Description |
| -- | -- |
| `ai.gql()` | Converts natural language to a GQL query. |
| `ai.read()` | Converts natural language to a read-only GQL query and execute it. |
| `ai.explain()` | Runs the NL-to-GQL pipeline and return the query with a reasoning trace. |
| `ai.trace()` | Returns the most recent NL-to-GQL pipeline trace. |
| `ai.aiConfig()` | Returns the current NL-to-GQL pipeline configuration. |
| `ai.setAIConfig()` | Sets a configuration parameter for the NL-to-GQL pipeline. |

### Vectors

| Function | Description |
| -- | -- |
| `ai.vector()` | Converts a list of numbers to a `VECTOR` type.  |
| `ai.embed()` | Generates an embedding vector from text using the configured AI provider. |
| `ai.embed_batch()` | Generates embedding vectors for multiple texts in a single batched call. |

### Vector Similarity Search

| Function | Description |
| -- | -- |
| `ai.cosine()` | Computes cosine similarity between two vectors. |
| `ai.euclidean()` | Computes Euclidean distance between two vectors. |
| `ai.dot()` | Computes dot product of two vectors. |
| `ai.distance()` | Computes cosine distance (1 - cosine similarity). |

### Vector Utilities

| Function | Description |
| -- | -- |
| `ai.dimension()` | Gets the number of dimensions in a vector. |
| `ai.magnitude()` | Gets the magnitude (L2 norm) of a vector. |
| `ai.normalize()` | Normalizes a vector to unit length. |
| `ai.toList()` | Converts a vector to a list of numbers. |
| `ai.add()` | Adds two vectors element-wise. |
| `ai.subtract()` | Subtracts two vectors element-wise. |
| `ai.scale()` | Multiplies a vector by a scalar. |
| `ai.rebuild_index()` | Rebuilds an HNSW vector index. |
| `ai.set_index_option()` | Updates a runtime vector index option. |
