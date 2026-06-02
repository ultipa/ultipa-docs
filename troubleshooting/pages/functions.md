# Functions

Issues around built-in function calls — name resolution, deprecation warnings, missing arguments, type mismatches.

## "function 'X' is deprecated; use 'Y' instead" warning

**Symptom:** Your query runs and returns the right result, but `Response.Warnings` (in every driver) contains:

```
function "DB.NODELABELS" is deprecated; use "DB.NODE_LABELS" instead
```

**Cause:** As of the ISO/IEC 39075 naming-convention migration, multi-word function names use `UPPER_SNAKE_CASE` canonically. The previous spellings — camelCase (`toInteger`, `db.nodeLabels`) and no-separator (`dateformat`, `pointget`) — still resolve via aliases, but each call emits a per-request deprecation warning.

**Fix:** Update the call to the canonical form. The common renames:

| Legacy | Canonical |
| -- | -- |
| `toInteger`, `toFloat`, `toString`, `toBoolean`, `toList`, `toMap` | `to_integer`, `to_float`, `to_string`, `to_boolean`, `to_list`, `to_map` |
| `dateadd`, `datediff`, `dateformat`, `dayofweek` | `date_add`, `date_diff`, `date_format`, `day_of_week` |
| `typeof` | `type_of` |
| `pointget` | `point_get` |
| `listcontains`, `listunion` | `list_contains`, `list_union` |
| `db.nodeLabels`, `db.edgeLabels`, `db.labelProperty`, `db.reloadStats` | `db.node_labels`, `db.edge_labels`, `db.label_property`, `db.reload_stats` |
| `ai.setapikey`, `ai.setprovider`, `ai.embeddim` | `ai.set_api_key`, `ai.set_provider`, `ai.embed_dim` |
| `ai.setCompletionProvider`, `ai.completionProvider` | `ai.set_completion_provider`, `ai.completion_provider` |
| `ai.aiConfig`, `ai.setAIConfig` | `ai.ai_config`, `ai.set_ai_config` |

Single-word names (`upper`, `cardinality`, `coalesce`, `normalize`, `nullif`, `log10`, `point3d`) are exempt and kept unbroken per ISO.

## TOINTEGER, to_integer, ToInteger all work — is that intentional?

**Symptom:** Function lookup seems to accept any case and ignore underscores.

**Cause:** Yes, intentional. The registry's `normalizeName` (`pkg/function/registry.go:41`) does `strings.ToUpper(strings.ReplaceAll(name, "_", ""))`. So:

- `to_integer`, `TO_INTEGER`, `tointeger`, `TOINTEGER`, `ToInteger`, `To_Integer` all resolve to the same function.
- Only the legacy spellings explicitly registered as aliases (`TOINTEGER`, `db.nodeLabels`, …) fire deprecation warnings; arbitrary case-variations of the canonical form do not.

**Fix:** None needed — but for consistency with ISO/IEC 39075, write `to_integer`, not `tointeger`. Style only; semantics are identical.

## ai.gql() — scalar or procedure?

Both forms exist. `RETURN ai.gql("...")` blocks and returns the generated query string; `CALL ai.gql({nl: "..."}) YIELD stage, data` streams one row per pipeline stage. See <a href="/docs/troubleshooting/ai-completion" target="_blank">AI Completion troubleshooting</a> for which form to pick.

## Function exists but call errors with "unknown function"

**Symptom:**

```
RETURN db.node_labels()
-- error: unknown function: DB.NODE_LABELS
```

**Cause:** Either the function is namespaced (`db.*`, `ai.*`) and lives in a registration path that isn't loaded for your build, or the function name is genuinely typo'd.

**How to confirm:**

```gql
SHOW FUNCTIONS LIKE 'DB.%'
```

If the function appears here, the registry has it — your call has a typo or quoting issue. If it doesn't appear, the function is not registered in this build.

**Fix:** Compare the `SHOW FUNCTIONS` row against your call. The most common issues:

- Quoting the function name: `RETURN 'db.node_labels'()` is a string, not a function call. Remove the quotes.
- Calling a procedure as a function: see the procedure-hint case above.
- Older build: features land incrementally; consult the change log for the function's first-shipped version.

## db.node_labels() returns an empty list

**Symptom:** `RETURN db.node_labels()` returns `[]` even though the current graph has labeled nodes.

**Cause:** `db.node_labels()` reports labels as known to the schema/statistics, not by scanning data. For a freshly-loaded graph, statistics may not have been built yet — or for an open-mode graph, labels are tracked only when nodes are inserted via the LPG path (not via bulk-import shortcuts that bypass label tracking).

**How to confirm:**

```gql
MATCH (n) RETURN DISTINCT labels(n)
```

If this returns labels but `db.node_labels()` does not, statistics are stale.

**Fix:** Rebuild statistics:

```gql
RETURN db.reload_stats()
```

`db.rebuild_stats()` and `db.repair_stats()` are aliases for the same function.

## Property-existence check returns NULL on a missing property

**Symptom:** `n.unknown_property` returns NULL instead of erroring, and `WHERE n.foo = 1` silently filters everything out when `foo` doesn't exist on the node.

**Cause:** GQL property access is null-tolerant by design. Missing properties evaluate to NULL, and NULL in a comparison is neither true nor false — so the row is filtered out.

**Fix:** Use `property_exists` for an explicit check:

```gql
MATCH (n) WHERE property_exists(n, 'foo') RETURN n
```

Or `IS NOT NULL`:

```gql
MATCH (n) WHERE n.foo IS NOT NULL RETURN n
```

## to_integer("3.14") returns NULL, not 3

**Symptom:** `RETURN to_integer("3.14")` returns NULL.

**Cause:** `to_integer` parses STRING as integer literal — `"3.14"` is not a valid integer literal, so the conversion fails and the function returns NULL by design (consistent with SQL `CAST`). `to_integer(3.14)` (a FLOAT, not a STRING) **does** return 3 (truncated).

**Fix:** If the input is a STRING with decimal content, convert through FLOAT first:

```gql
RETURN to_integer(to_float("3.14"))   -- 3
```

Or use `cast`:

```gql
RETURN cast("3.14" AS FLOAT) AS f, cast("3.14" AS FLOAT) AS i   -- same idea
```
