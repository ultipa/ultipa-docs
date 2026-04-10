# AI Completion

AI completion functions use a large language model to generate or execute GQL queries from natural language. Using `ai.setapikey()` to configure both the embedding and completion provider at once, no extra setup is needed. To use a different provider for completion (e.g., Anthropic for completion, OpenAI for embeddings), use `ai.setapikey()` with `false` to set the key without activating, then `ai.setCompletionProvider()` to switch.

## ai.gql()

Converts a natural language question into a GQL query using the configured completion provider. The function automatically includes the current graph's schema (labels, properties, edge patterns) as context for the LLM.

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
      <td colspan="3"><code>ai.gql(&lt;question&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;question&gt;</code></td>
      <td><code>STRING</code></td>
      <td>A natural language question about the graph data</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.gql("Find all papers written by Alex")
```

Result:

| ai.gql |
| -- |
| MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p |

## ai.read()

Converts a natural language question into a read-only GQL query, executes it, and returns the results. Only read operations are allowed, any generated query containing write operations (`INSERT`, `DELETE`, `SET`, etc.) is rejected.

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
      <td colspan="3"><code>ai.read(&lt;question&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;question&gt;</code></td>
      <td><code>STRING</code></td>
      <td>A natural language question about the graph data</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>RECORD</code></td>
    </tr>
  </tbody>
</table>

The returned record contains:

| Field | Type | Description |
| -- | -- | -- |
| `query` | `STRING` | The generated GQL query |
| `results` | `LIST` | The query results |
| `count` | `INT` | Number of result rows |

```gql
RETURN ai.read("How many papers did Alex write?")
```

Result:

```json
{
  "query": "MATCH (p:Paper) WHERE p.author = 'Alex' RETURN COUNT(p) AS count",
  "results": [
    {
      "count": 2
    }
  ],
  "count": 1
}
```

## ai.setCompletionProvider()

Sets the active completion provider. The provider's API key must have been set first via `ai.setapikey()`.

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
      <td colspan="3"><code>ai.setCompletionProvider(&lt;provider&gt;)</code></td>
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
      <td>Provider name: <code>"openai"</code>, <code>"gemini"</code>, <code>"xai"</code>, or <code>"anthropic"</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.setCompletionProvider("openai")
```

## ai.completionProvider()

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
      <td colspan="3"><code>ai.completionProvider()</code></td>
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
RETURN ai.completionProvider()
```

## ai.explain()

Runs the NL-to-GQL pipeline and returns the generated query alongside a reasoning trace (schema used, tool calls, refinements). Does not execute the query.

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
      <td colspan="3"><code>ai.explain(&lt;question&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;question&gt;</code></td>
      <td><code>STRING</code></td>
      <td>A natural language question</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>MAP</code></td>
    </tr>
  </tbody>
</table>

The returned map contains `gql` (the generated query) and `trace` (pipeline details).

```gql
RETURN ai.explain("Find all papers written by Alex")
```

## ai.trace()

Returns the most recent NL-to-GQL pipeline trace recorded by `ai.gql()`, `ai.read()`, or `ai.explain()`. Returns `NULL` if no pipeline call has run in the current session.

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
      <td colspan="3"><code>ai.trace()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>MAP</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.gql("Find papers by Alex")
RETURN ai.trace()
```

## ai.setAIConfig()

Sets a configuration parameter for the NL-to-GQL pipeline.

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
      <td colspan="3"><code>ai.setAIConfig(&lt;key&gt;, &lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;key&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Configuration key</td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td><code>STRING</code> / <code>INT</code> / <code>FLOAT</code> / <code>BOOL</code></td>
      <td>Configuration value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

Available configuration keys:

| Key | Type | Description |
| -- | -- | -- |
| `max_steps` | INT | Maximum number of pipeline steps |
| `max_refinements` | INT | Maximum query refinement attempts |
| `schema_top_k` | INT | Number of top schema elements to include |
| `patterns_top_k` | INT | Number of top edge patterns to include |
| `examples_top_k` | INT | Number of similar query examples to include |
| `query_memory_enabled` | BOOL | Enable query memory for learning from past queries |
| `query_memory_size` | INT | Maximum number of queries to remember |
| `pipeline` | STRING | Pipeline mode to use |

```gql
RETURN ai.setAIConfig("max_refinements", 3)
```

## ai.aiConfig()

Returns the current NL-to-GQL pipeline configuration.

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
      <td colspan="3"><code>ai.aiConfig()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>MAP</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.aiConfig()
```

## Streaming Procedures

The streaming versions of `ai.gql` and `ai.read` provide real-time progress updates as the NL-to-GQL pipeline executes. Use `CALL` to invoke them.

### CALL ai.gql()

Converts natural language to a GQL query, streaming one row per pipeline stage.

```gql
CALL ai.gql({nl: "Find 10 people"})
YIELD stage, detail, elapsed_ms, data
```

| Column | Type | Description |
| -- | -- | -- |
| `stage` | STRING | Pipeline stage: `start`, `grounding`, `examples`, `generation`, `tool`, `validation`, `refinement`, `execution`, `final`, `error` |
| `detail` | STRING | Short human-readable summary |
| `elapsed_ms` | INT | Milliseconds since the call began |
| `tokens_input` | INT | Cumulative LLM input tokens |
| `tokens_output` | INT | Cumulative LLM output tokens |
| `tokens_cached` | INT | Cumulative cached-prefix input tokens |
| `data` | MAP | Stage-specific payload (e.g., generated GQL on `final` stage) |

### CALL ai.read()

Converts natural language to a read-only GQL query, executes it, and streams pipeline progress. Write/DDL queries are rejected.

```gql
CALL ai.read({nl: "Who are Alice's friends?"})
YIELD stage, detail, elapsed_ms, data
```

Returns the same columns as `CALL ai.gql()`.