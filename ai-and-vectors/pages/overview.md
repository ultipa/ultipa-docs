# AI & Vectors

Ultipa GQLDB provides built-in AI features for working with vectors, embeddings, similarity search, and natural language query generation. The vector and embedding utilities are scalar functions, while the natural-language pipeline (`ai.gql`) is exposed as a streaming procedure. All names use the `ai.` prefix.

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

- **Completion providers** use large language models to generate GQL queries from natural language. Functions like `ai.gql()` use the completion provider.

Some providers support both embedding and completion, while others support only one. You can configure different providers for each role (e.g., OpenAI for embeddings, Anthropic for completion).

## Feature Summary

### Provider Configuration

| Function | Description |
| -- | -- |
| <a href="/docs/ai-and-vectors/provider-configuration#ai-set_api_key">ai.set_api_key()</a> | Sets the API key for an AI provider. |
| <a href="/docs/ai-and-vectors/provider-configuration#ai-set_provider">ai.set_provider()</a> | Sets the active embedding provider. |
| <a href="/docs/ai-and-vectors/provider-configuration#ai-provider">ai.provider()</a> | Returns the name of the current embedding provider. |
| <a href="/docs/ai-and-vectors/provider-configuration#ai-embed_dim">ai.embed_dim()</a> | Returns the embedding dimension of the current provider. |
| <a href="/docs/ai-and-vectors/provider-configuration#ai-set_completion_provider">ai.set_completion_provider()</a> | Sets the active completion provider. |
| <a href="/docs/ai-and-vectors/provider-configuration#ai-completion_provider">ai.completion_provider()</a> | Returns the name of the current completion provider. |

### AI Completion

| Procedure/Function | Description |
| -- | -- |
| <a href="/docs/ai-and-vectors/ai-completion#ai-gql">ai.gql()</a> | Streaming procedure. Converts natural language to a GQL query. |
| <a href="/docs/ai-and-vectors/ai-completion#ai-explain">ai.explain()</a> | Runs the NL-to-GQL pipeline and returns the generated query with a full reasoning trace (schema, generation steps, tool calls, validation, token usage). Does not execute. |
| <a href="/docs/ai-and-vectors/ai-completion#ai-trace">ai.trace()</a> | Returns the most recent NL-to-GQL pipeline trace, or `NULL` if none. |
| <a href="/docs/ai-and-vectors/ai-completion#ai-traces">ai.traces([n])</a> | Returns the most recent `n` traces (newest first). |
| <a href="/docs/ai-and-vectors/ai-completion#ai-rate">ai.rate()</a> | Attaches a 1–5 rating and optional comment to the most recent trace. Ratings of 1 or 2 also purge the `(NL, GQL)` pair from per-graph query memory. |
| <a href="/docs/ai-and-vectors/ai-completion#ai-save_skill">ai.save_skill()</a> | Saves a named NL template. Passing an empty NL deletes the skill. |
| <a href="/docs/ai-and-vectors/ai-completion#ai-list_skills">ai.list_skills()</a> | Lists every saved skill as records. |
| <a href="/docs/ai-and-vectors/ai-completion#ai-drop_skill">ai.drop_skill()</a> | Removes a saved skill by name. |
| <a href="/docs/ai-and-vectors/ai-completion#ai-skill_nl">ai.skill_nl()</a> | Returns the NL template of a saved skill so it can be piped into `ai.gql()`. |
| <a href="/docs/ai-and-vectors/ai-completion#ai-ai_config">ai.ai_config()</a> | Returns the current NL-to-GQL pipeline configuration. |
| <a href="/docs/ai-and-vectors/ai-completion#ai-set_ai_config">ai.set_ai_config()</a> | Sets a configuration parameter for the NL-to-GQL pipeline. |

### Vectors

| Function | Description |
| -- | -- |
| <a href="/docs/ai-and-vectors/vectors#ai-vector">ai.vector()</a> | Converts a list of numbers to a `VECTOR` type.  |
| <a href="/docs/ai-and-vectors/vectors#ai-embed">ai.embed()</a> | Generates an embedding vector from text using the configured AI provider. |
| <a href="/docs/ai-and-vectors/vectors#ai-embed_batch">ai.embed_batch()</a> | Generates embedding vectors for multiple texts in a single batched call. |

### Vector Similarity Search

| Function | Description |
| -- | -- |
| <a href="/docs/ai-and-vectors/vector-similarity-search#ai-cosine">ai.cosine()</a> | Computes cosine similarity between two vectors. |
| <a href="/docs/ai-and-vectors/vector-similarity-search#ai-euclidean">ai.euclidean()</a> | Computes Euclidean distance between two vectors. |
| <a href="/docs/ai-and-vectors/vector-similarity-search#ai-dot">ai.dot()</a> | Computes dot product of two vectors. |
| <a href="/docs/ai-and-vectors/vector-similarity-search#ai-distance">ai.distance()</a> | Computes cosine distance (1 - cosine similarity). |

### Vector Utilities

| Function | Description |
| -- | -- |
| <a href="/docs/ai-and-vectors/vector-utilities#ai-dimension">ai.dimension()</a> | Gets the number of dimensions in a vector. |
| <a href="/docs/ai-and-vectors/vector-utilities#ai-magnitude">ai.magnitude()</a> | Gets the magnitude (L2 norm) of a vector. |
| <a href="/docs/ai-and-vectors/vector-utilities#ai-normalize">ai.normalize()</a> | Normalizes a vector to unit length. |
| <a href="/docs/ai-and-vectors/vector-utilities#ai-tolist">ai.toList()</a> | Converts a vector to a list of numbers. |
| <a href="/docs/ai-and-vectors/vector-utilities#ai-add">ai.add()</a> | Adds two vectors element-wise. |
| <a href="/docs/ai-and-vectors/vector-utilities#ai-subtract">ai.subtract()</a> | Subtracts two vectors element-wise. |
| <a href="/docs/ai-and-vectors/vector-utilities#ai-scale">ai.scale()</a> | Multiplies a vector by a scalar. |
| <a href="/docs/ai-and-vectors/vector-utilities#ai-rebuild_index">ai.rebuild_index()</a> | Rebuilds an HNSW vector index. |
| <a href="/docs/ai-and-vectors/vector-utilities#ai-set_index_option">ai.set_index_option()</a> | Updates a runtime vector index option. |
