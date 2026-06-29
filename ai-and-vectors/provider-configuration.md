# Provider Configuration

Configure AI providers for embedding generation and completion. Use `SHOW AI PROVIDERS` to see all available providers and their current status.

## API Key

### ai.set_api_key()

Sets the API key for an AI provider. Optionally activates it as the current provider.

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
      <td colspan="3"><code>ai.set_api_key(&lt;provider&gt;, &lt;apiKey&gt; [, &lt;activate&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;provider&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Provider name (see <a href="/docs/ai-and-vectors/overview#Supported-Providers">Supported Providers</a>)</td>
    </tr>
    <tr>
      <td><code>&lt;apiKey&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The API key</td>
    </tr>
    <tr>
      <td><code>&lt;activate&gt;</code></td>
      <td><code>BOOL</code></td>
      <td>Optional. Whether to set this as the active provider (default: <code>true</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

By default, calling `ai.set_api_key()` both sets the key and activates the provider:

```gql
RETURN ai.set_api_key("openai", "sk-...")
```

Each provider stores one API key. Calling `ai.set_api_key()` again for the same provider overwrites the previous key. To set keys for multiple providers without activating them, pass `false` as the third argument, then use `ai.set_provider()` to switch:

```gql
RETURN ai.set_api_key("gemini", "AQ.za...", false)
```

## Embedding Provider

### ai.set_provider()

Sets the active embedding provider. The provider's API key must have been set first via `ai.set_api_key()`.

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
      <td colspan="3"><code>ai.set_provider(&lt;provider&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;provider&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Embedding provider name (see <a href="/docs/ai-and-vectors/overview#Supported-Providers">Supported Providers</a>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.set_provider("openai")
```

### ai.provider()

Returns the name of the current embedding provider.

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
      <td colspan="3"><code>ai.provider()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.provider()
```

### ai.embed_dim()

Returns the embedding dimension of the current provider. Returns `null` if no embedding provider is active or the provider doesn't support embedding.

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
      <td colspan="3"><code>ai.embed_dim()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.embed_dim()
```

### ai.set_embedding_model()

Overrides the embedding model for a given provider at runtime. The override is persisted and re-activates the affected provider, so subsequent `ai.embed()`, `ai.embed_batch()`, and vector-index inserts use the new model immediately.

> **Watch out for dimension changes.** Switching models within the same provider often changes the embedding dimension (e.g. OpenAI `text-embedding-3-small` is 1536-dim, `text-embedding-3-large` is 3072-dim). When the dimension changes, GQLDB emits a warning that includes the old and new dimensions; **existing vector indexes were built for the previous dimension and must be rebuilt with <a href="/docs/ai-and-vectors/vector-index#Rebuilding-an-Index">`ai.rebuild_index()`</a>** or query results will silently mismatch.

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
      <td colspan="3"><code>ai.set_embedding_model(&lt;provider&gt;, &lt;model&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;provider&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Provider name (see <a href="/docs/ai-and-vectors/overview#Supported-Providers">Supported Providers</a>).</td>
    </tr>
    <tr>
      <td><code>&lt;model&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The new embedding model name (provider-specific identifier, e.g. <code>"text-embedding-3-large"</code>).</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.set_embedding_model("openai", "text-embedding-3-large")
-- If the dimension changes, rebuild any vector indexes that depended on the old model:
RETURN ai.rebuild_index("summary_embedding")
```

## Completion Provider

### ai.set_completion_provider()

Sets the active completion provider. The provider's API key must have been set first via `ai.set_api_key()`.

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
      <td colspan="3"><code>ai.set_completion_provider(&lt;provider&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;provider&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Provider name (see <a href="/docs/ai-and-vectors/overview#Supported-Providers">Supported Providers</a>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.set_completion_provider("anthropic")
```

### ai.completion_provider()

Returns the name of the current completion provider.

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
      <td colspan="3"><code>ai.completion_provider()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.completion_provider()
```

### ai.set_completion_model()

Overrides the completion model for a given provider at runtime. The override is persisted and re-activates the affected provider, so subsequent `ai.gql()`, `ai.explain()`, and other completion calls use the new model immediately.

Use this when you want to switch between models offered by the same provider (e.g. `gpt-4o` vs `gpt-4o-mini` on OpenAI, or `claude-3-5-sonnet` vs `claude-3-5-haiku` on Anthropic) without re-running `ai.set_api_key()` or `ai.set_completion_provider()`.

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
      <td colspan="3"><code>ai.set_completion_model(&lt;provider&gt;, &lt;model&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;provider&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Provider name (see <a href="/docs/ai-and-vectors/overview#Supported-Providers">Supported Providers</a>).</td>
    </tr>
    <tr>
      <td><code>&lt;model&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The new completion model name (provider-specific identifier, e.g. <code>"gpt-4o"</code>, <code>"claude-3-5-sonnet"</code>).</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.set_completion_model("openai", "gpt-4o")
```
