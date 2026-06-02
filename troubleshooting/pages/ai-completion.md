# AI Completion

Issues around the natural-language pipeline (`ai.gql()`) and supporting functions (`ai.explain()`, `ai.trace()`, `ai.set_api_key()`, …).

## I want to choose between RETURN ai.gql(...) and CALL ai.gql({nl: ...})

`ai.gql` is registered as **both** a scalar function and a streaming procedure. Pick the form that matches what you want back.

| Form | Returns | Use when |
| -- | -- | -- |
| `RETURN ai.gql("...")` | The generated GQL string (blocks until generation completes) | You just want the query string and don't care about per-stage progress, token counts, or tool calls. |
| `CALL ai.gql({nl: "..."}) YIELD stage, data, ...` | One row per pipeline stage (`start`, `routing`, `grounding`, `generation`, `tool`, `validation`, `final`, ...) | You want a live trace — latency per stage, token usage, which tools the model called, what it tried before settling. |

The scalar form takes up to 3 positional arguments: `ai.gql(nl, instruction?, timeout_ms?)`. The procedure form takes a map with named keys (`nl`, `instruction`, `timeout_ms`, `conversation_id`).

## CALL ai.gql(...) runs but I don't see the answer rows

**Symptom:** The stream returns rows like `{stage: "final", data: {gql: "MATCH ..."}}` but no actual graph rows matching the user's question.

**Cause:** `ai.gql()` only **generates** the GQL query — it never executes it. The `final` row carries the generated string in `data.gql`; the rest are pipeline trace events (routing, grounding, generation, tool, validation).

**Fix:** Take `data.gql` from the `final` row and run it as a second statement:

```gql
-- Step 1: get the generated query
CALL ai.gql({nl: "How many papers did Alex write?"})
YIELD stage, data
FILTER stage = "final"
RETURN data.gql
```

```gql
-- Step 2: run the returned string
MATCH (p:Paper) WHERE p.author = 'Alex' RETURN count(p)
```

In application code, capture `data.gql` from step 1 and submit it as a second query.

## CALL ai.gql(...) returns nothing / errors with "no completion provider"

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

## Generation hits max_steps and returns a wrong-shape query

**Symptom:** The last `generation` row's `data.termination` is `"max_steps"` (not `"final"`), and the returned `data.gql` is a best-guess top-N preview instead of, e.g., a `count(...)` aggregation the question asked for.

**Cause:** The LLM used up its step budget exploring tools (`get_label_property`, `get_overview`, `sample_query`, `validate_gql`) before producing a final candidate, so it returned the most recent partial.

**Fix:** Raise the step budget:

```gql
RETURN ai.set_ai_config("max_steps", 8)
```

Default is `4`. Tool-heavy domains (large schemas, ambiguous questions) typically want 6–10. Check current config with `RETURN ai.ai_config()`.

## "How many" questions return a top-N list, not a count

**Symptom:** `CALL ai.gql({nl: "How many papers did Alex write?"})` returns `MATCH (p:Paper) WHERE p.author = 'Alex' RETURN p.title, p.score ORDER BY p.score DESC LIMIT 5` instead of a `count()`.

**Cause:** The model is sometimes biased toward "show me" templates over aggregation, especially when the schema has rich properties. The `final.data.count` field reports **rows in the result set** (5 here), not the answer to the question.

**Fix:** Phrase the prompt to be explicit about the aggregation:

```gql
CALL ai.gql({nl: "Return the COUNT of papers by Alex"})
```

Or capture the generated query and inspect it before running.

## Skill or trace lookup returns NULL

**Symptom:** `RETURN ai.skill_nl("top_authors")` returns NULL even though you ran `ai.save_skill("top_authors", "...")` earlier.

**Cause:** Skills are scoped to the current graph. If you switched graphs or restarted the server, the per-graph skill store doesn't surface skills from the previous graph.

**How to confirm:**

```gql
RETURN ai.list_skills()
```

If the list is empty, the current graph has no skills.

**Fix:** Re-issue `ai.save_skill(...)` in the current graph, or `USE` the graph that had the original skill.

## Embedding fails with "embedding provider not configured"

**Symptom:** `ai.embed("...")` returns an error or `NULL`.

**Cause:** The completion provider and embedding provider are independent. `ai.set_completion_provider("openai")` does not activate embeddings — that needs `ai.set_provider(...)`.

**Fix:**

```gql
RETURN ai.set_provider("openai")
RETURN ai.embed_dim()           -- confirms embedding is wired
```

See <a href="/docs/ai-and-vectors/provider-configuration" target="_blank">Provider Configuration</a>.
