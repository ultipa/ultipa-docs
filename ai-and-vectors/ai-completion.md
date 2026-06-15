# AI Completion

AI completion functions use a large language model to generate or execute GQL queries from natural language. 

> Use <a target="_blank" href="/docs/ai-and-vectors/provider-configuration#ai-set_completion_provider">ai.set_completion_provider()</a> to set the active completion AI provider.

## Example Graph

<center><img src="images/ai-completion-example.drawio.svg"></center>

```gql
INSERT (alice:Person {_id: 'U1', name: 'Alice', age: 28, city: 'New York'}),
       (bob:Person {_id: 'U2', name: 'Bob', age: 32, city: 'New York'}),
       (carol:Person {_id: 'U3', name: 'Carol', age: 25, city: 'Boston'}),
       (david:Person {_id: 'U4', name: 'David', age: 30, city: 'Boston'}),
       (eve:Person {_id: 'U5', name: 'Eve', age: 27, city: 'Seattle'}),
       (alice)-[:FRIEND]->(bob), (alice)-[:FRIEND]->(carol),
       (bob)-[:FRIEND]->(david), (carol)-[:FRIEND]->(david),
       (david)-[:FRIEND]->(eve)
```

## NL-to-GQL: ai.gql()

`ai.gql()` converts a natural language question into a GQL query using the configured completion provider. It is registered in **two forms**:

| Form | Returns | When to use |
| -- | -- | -- |
| **Function:** `RETURN ai.gql()` | The generated GQL string or a `{gql, rows, count}` map | You only need the query string (and optionally its result rows), and don't care about per-stage timing, token counts, or tool calls. |
| **Procedure:** `CALL ai.gql()` | One row per pipeline stage | You want a live trace: latency per stage, token usage, which tools the model called, what it tried before settling. |

### Function Form

The function form supports four positional arguments:

| Argument | Type | Default | Description |
| -- | -- | -- | -- |
| `nl` | `STRING` | / | **Required.** The natural-language question to translate. |
| `instruction` | `STRING` | `""` | Extra guidance for the LLM on top of the auto-loaded schema. |
| `timeout_ms` | `INTEGER` | `0` | Per-call timeout bounding the entire pipeline. `0` means no timeout. |
| `execute` | `BOOLEAN` | `false` | When `true`, the generated query is also executed and the result is returned as a `{gql, rows, count}` map. Only **read-only queries** are allowed; mutating queries are rejected. |

Simplest: NL in, GQL string out.

```gql
RETURN ai.gql("Names of Alice's friends")
```

Result: 

| ai.gql("Names of Alice's friends") |
| -- |
| `MATCH (a:Person)-[:FRIEND]->(b:Person) WHERE a.name = 'Alice' RETURN b.name` |

Generate and execute:

```gql
RETURN ai.gql("Names of Alice's friends", "", 0, true)
```

Result:

```json
{
  "gql": "MATCH (a:Person)-[:FRIEND]->(b:Person) WHERE a.name = 'Alice' RETURN b.name",
  "rows": [
    { "b.name": "Bob" },
    { "b.name": "Carol" }
  ],
  "count": 2
}
```

### Procedure Form

Parameters are passed as a single map literal. The procedure form is a superset of the function form, it accepts the same `nl` / `instruction` / `timeout_ms` / `execute` arguments, plus three procedure-only parameters:

<table>
  <thead>
    <tr><th>Parameter</th><th>Type</th><th>Default</th><th>Description</th></tr>
  </thead>
  <tbody>
    <tr>
      <td><code>nl</code></td>
      <td colspan="3" rowspan="4">See <a href="#Function-Form">Function Form</a> above.</td>
    </tr>
    <tr><td><code>instruction</code></td></tr>
    <tr><td><code>timeout_ms</code></td></tr>
    <tr><td><code>execute</code></td></tr>
    <tr>
      <td><code>conversation_id</code></td>
      <td><code>STRING</code></td>
      <td>/</td>
      <td>Thread id for multi-turn refinement. Prior turns sharing this id are surfaced in the LLM prompt; successful turns are appended back automatically, so follow-ups like <em>"now filter to Bologna"</em> refine the previous query instead of starting fresh.</td>
    </tr>
    <tr>
      <td><code>dry_run</code></td>
      <td><code>BOOLEAN</code></td>
      <td><code>false</code></td>
      <td>Only meaningful with <code>execute: true</code>. Runs grounding + generation + validation but <strong>skips execution</strong>; the <code>final</code> event carries the generated GQL with <code>data.dry_run = true</code>. Use as a plan-before-execute preview.</td>
    </tr>
    <tr>
      <td><code>max_rows_scanned</code></td>
      <td><code>INTEGER</code></td>
      <td><code>0</code></td>
      <td>Only meaningful with <code>execute: true</code>. <strong>Cost gate</strong>: if the preflight estimate of rows the query would touch exceeds this cap, the pipeline emits an <code>error</code> stage row and does <strong>not</strong> execute. <code>0</code> = no cap.</td>
    </tr>
  </tbody>
</table>

```gql
CALL ai.gql({nl: "Names of Alice's friends"})
YIELD stage, detail, elapsed_ms, tokens_input, tokens_output, tokens_cached, data
```

Result (one row per pipeline stage):

| stage | detail | elapsed_ms | tokens_input | tokens_output | tokens_cached | data |
| -- | -- | --: | --: | --: | --: | -- |
| `start` | Names of Alice's friends | 0 | 0 | 0 | 0 | `{require_read: false}` |
| `routing` | MATCH intent — using LLM path | 0 | 0 | 0 | 0 | `{}` |
| `grounding` | 1 labels, 1 patterns selected | 925 | 0 | 0 | 0 | `{pattern_count: 1, node_labels: ["Person"], edge_labels: ["FRIEND"]}` |
| `generation` | MATCH (a:Person)-[:FRIEND]->(b:Person) WHERE a.name = 'Alice' RETURN b.name | 2165 | 5263 | 27 | 2816 | `{tool_calls: 0, duration_ms: 1240, has_text: true, step: 0}` |
| `generation` | final candidate: MATCH (a:Person)-[:FRIEND]->(b:Person) WHERE a.name = 'Alice' RETURN b.name | 2165 | 5263 | 27 | 2816 | `{candidate: "MATCH (a:Person)-[:FRIEND]->(b:Person) WHERE a.name = 'Alice' RETURN b.name", steps: 1, termination: "final"}` |
| `validation` | passed | 2166 | 5263 | 27 | 2816 | `{passed: true, class: "read"}` |
| `final` | MATCH (a:Person)-[:FRIEND]->(b:Person) WHERE a.name = 'Alice' RETURN b.name | 2166 | 5263 | 27 | 2816 | `{gql: "MATCH (a:Person)-[:FRIEND]->(b:Person) WHERE a.name = 'Alice' RETURN b.name"}` |

With extra guidance and a 15-second cap, filtering down to the final GQL string:

```gql
CALL ai.gql({
  nl: "Friends of friends of David",
  instruction: "FRIEND edges are bidirectional even though stored directed; consider both directions",
  timeout_ms: 15000
})
YIELD stage, data
FILTER stage = "final"
RETURN data.gql
```

Result:

| data.gql |
| -- |
| `MATCH (a:Person {name: 'Alice'})-[:FRIEND]-()-[:FRIEND]-(fof:Person) WHERE fof <> a RETURN DISTINCT fof.name` |

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
CALL ai.gql({nl: "Names of Alice's friends"}) YIELD stage, data
FILTER stage = "final"
RETURN data.gql

-- Stage trace only, no payload
CALL ai.gql({nl: "Names of Alice's friends"}) 
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

### Common Intents

The system prompt steers algorithm-shaped questions to `CALL algo.<name>(...) YIELD ...` rather than a naive `MATCH ... RETURN`. Common mappings:

| Intent | Algorithm |
| -- | -- |
| Most important / influential nodes | `algo.pagerank`, `algo.betweenness` |
| Communities / clusters | `algo.louvain`, `algo.wcc` |
| Shortest path | `algo.shortestpath` |
| Neighborhood expansion | `algo.khop_fast` |
| Similar nodes | `algo.similarity`, `algo.knn` |
| Embeddings | `algo.node2vec`, `algo.fastrp` |

Example — asking for "the most influential people" emits:

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
RETURN ai.explain("Find ALL of Alice's friends")
```

Result:

```json
{
  "gql": "MATCH (a:Person {name: 'Alice'})-[:FRIEND]->(f:Person) RETURN f",
  "trace": {
    "total_duration_ms": 4753,
    "schema": {
      "label_count": 1,
      "pattern_count": 1,
      "node_labels": ["Person"],
      "edge_labels": ["FRIEND"]
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
              "args": {"query": "MATCH (a:Person {name: 'Alice'})-[:FRIEND]->(f:Person) RETURN f"},
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
          "assistant_text": "MATCH (a:Person {name: 'Alice'})-[:FRIEND]->(f:Person) RETURN f",
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
    "nl": "Find ALL of Alice's friends",
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
CALL ai.gql({nl: "How many friends does Alice have?"}) YIELD stage, data
FILTER stage = "final"
RETURN data.gql

-- 2. Rate it — a low rating purges this NL/GQL pair from memory
RETURN ai.rate(2, "model returned the friend list instead of a count")
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
