# AI Completion

AI completion functions use a large language model to generate or execute GQL queries from natural language. Use `ai.set_completion_provider()` to set the active completion AI provider.

## Example Graph

<center><img src="images/ai-completion-example.png"></center>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack'}),
       (p1)-[:Cites {weight:2}]->(p2),
       (p2)-[:Cites {weight:1}]->(p3)
```

## NL-to-GQL Pipeline

### ai.gql()

`ai.gql()` converts a natural language question into a GQL query using the configured completion provider. It is registered in **two forms** — pick the one that matches what you want back:

| Form | Returns | When to use |
| -- | -- | -- |
| **Function:** `RETURN ai.gql("...")` | The generated GQL string (blocks until the pipeline finishes) | You only need the query string and don't care about per-stage timing, token counts, or tool calls. Up to 3 positional args: `ai.gql(nl [, instruction [, timeout_ms]])`. |
| **Procedure:** `CALL ai.gql({nl: "..."}) YIELD stage, data, ...` | One row per pipeline stage (start, routing, grounding, generation, tool, validation, final, ...) | You want a live trace — latency per stage, token usage, which tools the model called, what it tried before settling. |

The two share the same underlying pipeline; the scalar form just blocks and returns the final row's `data.gql`.

#### Function Form

```gql
-- Simplest: NL in, GQL string out
RETURN ai.gql("Find all papers written by Alex")
-- Result: "MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p"
```

```gql
-- With extra guidance and a 15-second cap
RETURN ai.gql(
  "friends of friends of Alice",
  "FRIEND edges are bidirectional even though stored directed; consider both directions.",
  15000
)
```

#### Procedure Form

Parameters are passed as a single map literal:

| Parameter | Type | Description |
| -- | -- | -- |
| `nl` | `STRING` | **Required.** The natural-language question to translate. |
| `instruction` | `STRING` | Extra guidance for the LLM on top of the auto-loaded schema (e.g. multi-hop relationship hints, domain rules). Falls back to the session-level value set via `ai.set_ai_config('instruction', '...')` when omitted. Empty string disables it. |
| `timeout_ms` | `INTEGER` | Per-call timeout bounding the entire pipeline. On expiry, an `error` row is emitted and the stream closes. `0` or missing = no timeout. |
| `conversation_id` | `STRING` | Thread id for multi-turn refinement. Prior turns sharing this id are surfaced in the LLM prompt; successful turns are appended back automatically, so follow-ups like *"now filter to Bologna"* refine the previous query instead of starting fresh. |

```gql
CALL ai.gql({nl: "Find all papers written by Alex"})
YIELD stage, detail, elapsed_ms, tokens_input, tokens_output, tokens_cached, data
```

With extra guidance and a 15-second cap:

```gql
CALL ai.gql({
  nl: "friends of friends of Alice",
  instruction: "FRIEND edges are bidirectional even though stored directed; consider both directions.",
  timeout_ms: 15000
})
YIELD stage, data
FILTER stage = "final"
RETURN data.gql
```

Result:

| stage | detail | elapsed_ms | tokens_input | tokens_output | tokens_cached | data |
| -- | -- | --: | --: | --: | --: | -- |
| `start` | Find all papers written by Alex | 0 | 0 | 0 | 0 | `{}` |
| `routing` | MATCH intent — using LLM path | 0 | 0 | 0 | 0 | `{}` |
| `grounding` | 2 labels, 1 patterns selected | 1441 | 0 | 0 | 0 | `{node_labels: ["Paper"], edge_labels: ["Cites"], pattern_count: 1}` |
| `generation` | requested 1 tool call(s) | 10188 | 5267 | 29 | 0 | `{has_text: false, step: 0, tool_calls: 1, duration_ms: 8746}` |
| `tool` | validate_gql → {"class":"read","valid":true} | 10188 | 5267 | 29 | 0 | `{name: "validate_gql", args: {query: "MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p"}, result: {class: "read", construct: "", valid: true}, is_error: false, duration_ms: 0}` |
| `generation` | MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p | 18026 | 10573 | 45 | 4864 | `{has_text: true, step: 1, tool_calls: 0, duration_ms: 7838}` |
| `generation` | final candidate: MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p | 18026 | 10573 | 45 | 4864 | `{candidate: "MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p", steps: 2, termination: "final"}` |
| `validation` | passed | 18027 | 10573 | 45 | 4864 | `{class: "read", passed: true}` |
| `final` | MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p | 18027 | 10573 | 45 | 4864 | `{gql: "MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p"}` |

`ai.gql()` produces multiple rows of output as the **NL-to-GQL pipeline** executes. The pipeline automatically includes the current graph's schema (labels, properties, edge patterns) as context for the LLM.

### Pipeline Stages

| Stage | Description |
| -- | -- |
| `start` | Initiated. |
| `routing` | Intent classification. |
| `grounding` | Schema selection. |
| `generation` | LLM query generation. May repeat across refinement loops. |
| `tool` | LLM invoked an agent tool (`validate_gql`, `sample_query`, `show_algorithms`, ...). |
| `validation` | AST check on the candidate query. |
| `refinement` | Validation failed; asking the LLM to repair (loops back to `generation`). |
| `final` | Success; `data.gql` holds the generated query. |
| `error` | Terminal failure. Can replace `final` after any preceding stage. |

The happy path is `start → routing → grounding → generation → (tool ↔ generation)* → validation → final`. On failure at any step the stream emits an `error` row and ends; if a refinement budget remains, the pipeline first tries `refinement → generation` before giving up.

Each returned row carries the `stage` plus six telemetry columns: 
- `detail` (one-line human summary)
- `elapsed_ms` (wall time since `CALL` began)
- `tokens_input` / `tokens_output` / `tokens_cached` (cumulative LLM token counters)
- `data` (stage-specific payload — e.g. the generated GQL on `final`, tool args + result on `tool`).

You can omit any column you don't care about. Common patterns:

```gql
-- Just the final query
CALL ai.gql({nl: "Find all papers written by Alex"}) YIELD stage, data
FILTER stage = "final"
RETURN data.gql

-- Stage trace only, no payload
CALL ai.gql({nl: "Find all papers written by Alex"}) 
YIELD stage, detail, elapsed_ms

-- Just token accounting
CALL ai.gql({nl: "..."}) YIELD stage, tokens_input, tokens_output, tokens_cached
FILTER stage = "final"
RETURN tokens_input, tokens_output, tokens_cached
```

### Agent Tools

During the `generation` stage the LLM can call any of the following tools. Each call surfaces as a `tool` row in the stream with `data.name`, `data.args`, and `data.result`:

| Tool | Purpose |
| -- | -- |
| `get_label_property` | Look up the properties defined on a specific node or edge label. |
| `get_overview` | Get the current graph's label counts and edge patterns. |
| `classify_query` | Ask the read-only classifier whether a candidate query is read or write. |
| `validate_gql` | Parse + validate a candidate query against the current schema. |
| `sample_query` | Execute a candidate read-only query against the graph with a hard `LIMIT` injected and a short timeout — lets the model verify shape and approximate result size before committing. |
| `show_algorithms` | List the 77 built-in algorithms (optionally filtered by `category`). Returns the same payload as `SHOW ALGOS`. |
| `describe_algorithm` | Look up signature, parameters, and YIELD columns for a specific algorithm. |

**Common Intents → `CALL algo.*`**

The system prompt steers algorithm-shaped questions to `CALL algo.<name>(...) YIELD ...` rather than a naive `MATCH ... RETURN`. Common mappings:

| Intent | Algorithm |
| -- | -- |
| Most important / influential nodes | `algo.pagerank`, `algo.betweenness` |
| Communities / clusters | `algo.louvain`, `algo.wcc` |
| Shortest path | `algo.shortestpath` |
| Neighborhood expansion | `algo.khop_fast` |
| Similar nodes | `algo.similarity`, `algo.knn` |
| Embeddings | `algo.node2vec`, `algo.fastrp` |

Example — asking for "the most important papers" emits:

```gql
CALL algo.pagerank() YIELD nodeId, score
ORDER BY score DESC LIMIT 10
```

## Pipeline Inspection

These functions let you re-run, replay, or audit the NL-to-GQL pipeline.

### ai.explain()

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
      <td colspan="3"><code>RECORD</code></td>
    </tr>
  </tbody>
</table>

The returned map contains:

| Field | Type | Description |
| -- | -- | -- |
| `gql` | STRING | The generated GQL query. |
| `trace` | MAP | Pipeline details including schema used, generation steps, tool calls, validation result, and token usage. |

```gql
RETURN ai.explain("Find ALL papers written by Alex")
```

Result:

```json
{
  "gql": "MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p",
  "trace": {
    "total_duration_ms": 4753,
    "schema": {
      "label_count": 2,
      "pattern_count": 1,
      "node_labels": ["Paper"],
      "edge_labels": ["Cites"]
    },
    "generation": {
      "used_tool_use": true,
      "termination": "final",
      "steps": [
        {
          "assistant_text": "",
          "duration_ms": 1517,
          "tool_calls": [
            {
              "name": "validate_gql",
              "args": {"query": "MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p"},
              "result": {
                "class": "read",
                "construct": "",
                "valid": true
              },
              "is_error": false,
              "duration_ms": 1
            }
          ]
        },
        {
          "assistant_text": "MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p",
          "duration_ms": 1837,
          "tool_calls": []
        }
      ]
    },
    "validation": {
      "passed": true,
      "class": "read",
      "construct": "",
      "parse_err": ""
    },
    "token_usage": {
      "cached_input_tokens": 6144,
      "total_tokens": 12674,
      "calls": 2,
      "by_model": {
        "openai/gpt-4o-mini": {
          "provider": "openai",
          "model": "gpt-4o-mini",
          "input_tokens": 12629,
          "output_tokens": 45
        }
      }
    },
    "nl": "Find ALL papers written by Alex",
    "termination": "success",
    "examples": [],
    "refinements": []
  }
}
```

### ai.trace()

Returns the most recent NL-to-GQL pipeline trace recorded by `ai.gql()` or `ai.explain()`. Returns `NULL` if no pipeline call has run in the current session. Useful for debugging when a generated query is incorrect — you can inspect which labels were selected, what tool calls were made, and where the pipeline went wrong.

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
      <td colspan="3"><code>RECORD</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.trace()
```

### ai.traces()

Returns the most recent `n` pipeline traces as a list of maps (newest first). When `n` is `0` or omitted, returns the full retained history (capped at 32). Use this to compare runs side-by-side rather than only seeing the latest trace.

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
      <td colspan="3"><code>ai.traces([&lt;n&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;n&gt;</code></td>
      <td><code>INT</code></td>
      <td>Optional. Maximum number of traces to return. Must be non-negative.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST&lt;RECORD&gt;</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.traces(3)
```

## Feedback

### ai.rate()

`ai.rate()` is the feedback hook into per-graph query memory. It acts on the **most recent** pipeline trace (the one `ai.trace()` would return) and does three things:

1. **Stamps the trace:** attaches your 1–5 rating and optional comment, so future `ai.trace()` / `ai.traces()` calls show which runs were judged good or bad.
2. **Auto-purges bad examples:** if `rating ≤ 2` **and** the run was a `success` **and** query memory is enabled, the `(NL, GQL)` pair is removed from memory. A wrong answer never gets recalled as a few-shot example for similar future prompts. Ratings of `3`, `4`, `5` don't change memory, they're decoration only.
3. **Returns a `BOOL`:** `true` when a trace was found and rated, `false` when no trace exists yet or the rating is out of range.

Without query memory enabled (`ai.set_ai_config('query_memory_enabled', true)`), step 2 is a no-op and `ai.rate()` only stamps the trace. The function earns its keep when query memory is on.

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
      <td colspan="3"><code>ai.rate(&lt;rating&gt; [, &lt;comment&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;rating&gt;</code></td>
      <td><code>INT</code></td>
      <td>Score from 1 (worst) to 5 (best).</td>
    </tr>
    <tr>
      <td><code>&lt;comment&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Optional free-text note attached to the trace.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

Typical loop:

```gql
-- 1. Generate a query and inspect the result
CALL ai.gql({nl: "How many papers did Alex write?"}) YIELD stage, data
FILTER stage = "final"
RETURN data.gql

-- 2. Rate it — a low rating purges this NL/GQL pair from memory
RETURN ai.rate(2, "model returned top-N instead of count")
```

Now any future *"how many ..."* prompt won't recall this bad answer. If you'd rated it `5`, the pair would stick around and be surfaced as a positive example.

## Skills

A skill is a named natural-language template that you can recall later and pipe into `ai.gql()`. Useful for capturing prompts that worked well so you (or other sessions) can reuse them by name.

### ai.save_skill()

Registers a named NL template. Passing an empty NL deletes the skill (idempotent). Returns `true`.

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
      <td colspan="3"><code>ai.save_skill(&lt;name&gt;, &lt;nl_template&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;name&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Identifier for the skill.</td>
    </tr>
    <tr>
      <td><code>&lt;nl_template&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Natural-language template (or empty string to delete).</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.save_skill("top_authors", "Who are the top 5 most-cited authors?")
```

### ai.list_skills()

Returns every saved skill as a list of `{name, nl, created_at}` records.

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
      <td colspan="3"><code>ai.list_skills()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST&lt;RECORD&gt;</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.list_skills()
```

Result:

```json
[
  {
    "name": "top_authors", 
    "nl": "Who are the top 5 most-cited authors?", 
    "created_at": "2026-05-28T11:42:03Z"
  }
]
```

### ai.drop_skill()

Removes a saved skill by name. Returns `true` when a skill was deleted, `false` when the name was unknown.

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
      <td colspan="3"><code>ai.drop_skill(&lt;name&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;name&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Identifier of the skill to delete.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.drop_skill("top_authors")
```

### ai.skill_nl()

Returns the NL template of a saved skill so it can be piped into `ai.gql()`. Returns `NULL` when the name is unknown.

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
      <td colspan="3"><code>ai.skill_nl(&lt;name&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;name&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Identifier of the saved skill.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
CALL ai.gql({nl: ai.skill_nl("top_authors")})
YIELD stage, data
FILTER stage = "final"
RETURN data.gql
```

## Pipeline Configuration

### ai.ai_config()

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
      <td colspan="3"><code>ai.ai_config()</code></td>
    </tr>
    <tr>
      <td><b>Arguments</b></td>
      <td colspan="3">None</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>RECORD</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.ai_config()
```

Result:

```json
{
  "max_steps": 4,
  "max_refinements": 2,
  "schema_top_k": 8,
  "patterns_top_k": 8,
  "examples_top_k": 3,
  "query_memory_enabled": false,
  "query_memory_size": 256,
  "pipeline": "agentic"
}
```

### ai.set_ai_config()

Sets a configuration parameter for the NL-to-GQL pipeline.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:35%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.set_ai_config(&lt;key&gt;, &lt;value&gt;)</code></td>
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
| `max_steps` | `INT` | Maximum number of pipeline steps |
| `max_refinements` | `INT` | Maximum query refinement attempts |
| `schema_top_k` | `INT` | Number of top schema elements to include |
| `patterns_top_k` | `INT` | Number of top edge patterns to include |
| `examples_top_k` | `INT` | Number of similar query examples to include |
| `query_memory_enabled` | `BOOL` | Enable per-graph in-memory query memory. Successful `(NL, GQL)` pairs are kept in a ring buffer and recalled as few-shot examples for similar future questions. Recall uses cosine similarity when an embedder is configured, token overlap otherwise. Off by default. |
| `query_memory_size` | `INT` | Maximum number of remembered queries per graph (ring-buffer size). |
| `pipeline` | `STRING` | Pipeline mode to use |

```gql
RETURN ai.set_ai_config("max_refinements", 3)
```

Enable per-graph query memory:

```gql
RETURN ai.set_ai_config("query_memory_enabled", true)
```

## Troubleshooting

### CALL ai.gql(...) returns nothing / errors with "no completion provider"

**Symptom:** Either the call returns an empty result or the first row has `stage = "error"` with detail `no completion provider configured`.

**Cause:** No completion provider has been activated for the session.

**How to confirm:**

```gql
SHOW AI PROVIDERS
```

The `status` column should show `configured` for at least one row with `supports = completion`. If everything is `unconfigured`, no provider is active.

**Fix:**

```gql
RETURN ai.set_api_key("openai", "sk-...")
RETURN ai.set_completion_provider("openai")
```

The API key persists to disk encrypted (`ai.set_api_key` survives restart). The completion-provider selection is also persisted per-graph.

### Generation hits max_steps and returns a wrong-shape query

**Symptom:** The last `generation` row's `data.termination` is `"max_steps"` (not `"final"`), and the returned `data.gql` is a best-guess top-N preview instead of, e.g., a `count(...)` aggregation the question asked for.

**Cause:** The LLM used up its step budget exploring tools (`get_label_property`, `get_overview`, `sample_query`, `validate_gql`) before producing a final candidate, so it returned the most recent partial.

**Fix:** Raise the step budget

```gql
RETURN ai.set_ai_config("max_steps", 8)
```

Default is `4`. Tool-heavy domains (large schemas, ambiguous questions) typically want 6–10. Check current config with `RETURN ai.ai_config()`.

### "How many" questions return a top-N list, not a count

**Symptom:** `CALL ai.gql({nl: "How many papers did Alex write?"})` returns `MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p.title, p.score ORDER BY p.score DESC LIMIT 5` instead of a `count()`.

**Cause:** The model is sometimes biased toward "show me" templates over aggregation, especially when the schema has rich properties. The `final.data.count` field reports **rows in the result set** (5 here), not the answer to the question.

**Fix:** Phrase the prompt to be explicit about the aggregation

```gql
CALL ai.gql({nl: "Return the COUNT of papers by Alex"})
```

Or capture the generated query and inspect it before running.

### Skill or trace lookup returns NULL

**Symptom:** `RETURN ai.skill_nl("top_authors")` returns `NULL` even though you ran `ai.save_skill("top_authors", "...")` earlier.

**Cause:** Skills are scoped to the current graph. If you switched graphs or restarted the server, the per-graph skill store doesn't surface skills from the previous graph.

**How to confirm:**

```gql
RETURN ai.list_skills()
```

If the list is empty, the current graph has no skills.

**Fix:** Re-issue `ai.save_skill(...)` in the current graph, or `USE` the graph that had the original skill.