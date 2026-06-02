# LOAD CSV

Issues around `LOAD CSV` in both the dump form (inspect rows) and the inline-import form (`INTO <label>`).

## "no such file" on a relative path

**Symptom:**

```
LOAD CSV FROM 'data/users.csv'
-- error: open data/users.csv: no such file or directory
```

but `data/users.csv` exists on the server machine.

**Cause:** Relative paths resolve against the **server process's current working directory** — the directory the gqldb binary was launched from — not the `.gdb` data folder, not the directory of any session config, and not the client's directory.

**How to confirm:** Check how you started the server. If you launched with a wrapper script that does `cd "$(dirname "$0")"` first (the typical case), the working directory is the script's directory. If you launched the binary directly from a shell, it's whatever that shell's `pwd` was at launch.

**Fix:** Use an absolute path or a `file:///` URI:

```gql
LOAD CSV FROM '/Users/me/data/users.csv' AS row WITH HEADER
LOAD CSV FROM 'file:///Users/me/data/users.csv' AS row WITH HEADER
```

In production, **always** use absolute paths — they don't drift if the binary is re-launched from a different directory or as a different user.

## Edge import says "Imported 0 edges (N skipped)"

**Symptom:**

```
LOAD CSV FROM '/data/transfers.csv' WITH HEADER
INTO TRANSFERS EDGE FROM User('_from') TO User('_to')
MAPPING (...)
-- Result: Imported 0 edges (3047 skipped) into TRANSFERS from /data/transfers.csv
```

**Cause:** The edge importer pre-resolves each row's endpoints by `_id` against the live graph (`pkg/executor/ddl/ddl_load_csv.go:319,327`). Rows whose source or target node doesn't exist are skipped silently instead of erroring the whole import — and if every row's endpoints are missing, you get 0 imported / all skipped.

**How to confirm:** Take a `_from` value from your CSV and look it up:

```gql
MATCH (n:User) WHERE n._id = 'USR_000000' RETURN n
```

If this returns no rows, the User nodes haven't been imported with the IDs your edge CSV references.

**Fix:** Import the node CSV **first**, and include `_id` in the node import's `MAPPING` so the bulk importer uses your IDs instead of auto-generating UUIDs:

```gql
LOAD CSV FROM '/data/users.csv' WITH HEADER
INTO User MAPPING (
  _id: '_id',                       -- critical: maps your CSV id to the node's _id
  name: 'name',
  balance: 'balance' AS FLOAT
)
```

Then re-run the edge import. The label names in `EDGE FROM User(...) TO User(...)` are documentation only — the actual lookup is by `_id`, no label check — so the User nodes can carry any label, but the `_id` values must match.

## MATCH ... INSERT after LOAD CSV silently does nothing

**Symptom:**

```gql
LOAD CSV FROM '/data/users.csv' AS row WITH HEADER
INSERT (:User {_id: row._id, name: row.name})
-- error: RETURN (input schema=[]): undefined variable: row
```

or the statement parses but inserts zero rows.

**Cause:** The `row` binding produced by `LOAD CSV`'s dump form **does not flow into the next statement**. `LOAD CSV` is a top-level statement in the grammar; its rows are returned to the client as the query's final result and are not made available as bindings to a chained `INSERT` / `MATCH` / `RETURN`.

**Fix:** Use the inline-import form for materializing CSV rows into the graph:

```gql
LOAD CSV FROM '/data/users.csv' WITH HEADER
INTO User MAPPING (
  _id: '_id',
  name: 'name',
  age: 'age' AS INT
)
```

The inline-import form does the equivalent of `LOAD CSV ... INSERT (...)` in a single self-contained statement, with proper batching and validation. See <a href="/docs/gql/load-csv#inline-import-form" target="_blank">Inline Import Form</a>.

## INTO &lt;label&gt; errors with "default mapping requires WITH HEADER"

**Symptom:**

```
LOAD CSV FROM '/data/users.csv' INTO User
-- error: LOAD CSV INTO: default mapping requires WITH HEADER
```

**Cause:** Without `MAPPING (...)`, the importer derives column → property names from the header row. With no `WITH HEADER` and no explicit `MAPPING`, it has no way to name properties.

**Fix:** Either add `WITH HEADER`:

```gql
LOAD CSV FROM '/data/users.csv' WITH HEADER INTO User
```

Or provide an explicit `MAPPING`:

```gql
LOAD CSV FROM '/data/users.csv' INTO User MAPPING (
  _id: 'col0',
  name: 'col1'
)
```

Without a header, columns are addressed positionally as `col0`, `col1`, ….

## QUOTE '&lt;char&gt;' is being ignored

**Symptom:** You set `QUOTE '|'` expecting `|` to be the field-quote character, but the parser still interprets `"` as the quote.

**Cause:** The grammar accepts any single character after `QUOTE` for forward compatibility, but the runtime only honors `"` — the underlying `encoding/csv` reader doesn't expose a custom-quote setting (`pkg/executor/ddl/ddl_load_csv.go:588-590`).

**Fix:** Pre-process your file to use the standard double-quote character, or write `QUOTE '"'` explicitly to make the doc intent obvious. Any other value is a silent no-op.

## EDGE FROM ... TO ... errors with "requires EDGE_ID enabled"

**Symptom:**

```
LOAD CSV FROM '/data/edges.csv' WITH HEADER
INTO TRANSFERS EDGE FROM Person('_from') TO Person('_to') MAPPING (...)
-- error: LOAD CSV INTO ... EDGE: requires EDGE_ID enabled on graph "g"
```

**Cause:** Edge import needs the graph to track edge IDs because each row is materialized as a distinct edge entity. Graphs created with `CREATE GRAPH ... WITH EDGE_ID DISABLED` can't accept edge bulk imports.

**Fix:**

```gql
ALTER GRAPH g SET EDGE_ID ENABLE
```

Then re-run the edge import. New graphs default to `EDGE_ID ENABLED`, so this only matters for graphs explicitly created with the disabled option.
