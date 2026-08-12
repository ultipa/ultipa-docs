# Calling Procedures

This page covers how to invoke a stored procedure with `CALL` and feed its results into the rest of a query.

## Call with YIELD

The `YIELD` clause names the columns produced by a procedure, and optionally renames them. Using a `greet(name: STRING) RETURNS (greeting: STRING)` procedure:

```gql
CALL greet('World') YIELD greeting

-- Rename a yielded column with AS
CALL greet('World') YIELD greeting AS msg
```

## Call without YIELD

Without `YIELD`, all output columns are returned. For `VOID` procedures, there is no output:

```gql
-- Returns the greeting column
CALL greet('World')

-- VOID procedure, no output
CALL log_event('System started')
```

## Using Results in Subsequent Queries

Results from `YIELD` can flow into subsequent query clauses. Using a `count_all_nodes() RETURNS (cnt: INTEGER)` procedure:

```gql
CALL count_all_nodes() YIELD cnt
MATCH (n:Person) WHERE n.age > cnt * 3
RETURN n
```

The yielded columns are **added** to each incoming row, so variables from earlier clauses remain visible after the `CALL`.

## Per-Row Execution

A named `CALL` executes once for each row of the incoming binding table, and that row's variables are visible inside the call. Arguments can therefore reference them:

```gql
MATCH (n:Person)
CALL score_node(n._id) YIELD score
RETURN n._id, score
```

Each incoming row is combined with the rows the procedure yields for it. A procedure that yields one row per call leaves the row count unchanged; a procedure that yields several multiplies the rows; a procedure that yields none drops the row unless the call is marked `OPTIONAL`.

Avoid yielding a column whose name is already bound in the query. The collision is not reported: the procedure's column silently overwrites the existing variable for the rest of the query. In `MATCH (n:Person) CALL score_node(n._id) YIELD n`, later clauses see the procedure's `n`, not the matched node.

### VOID Procedures in a Query

A `VOID` procedure produces no columns and leaves the incoming rows untouched, so it can be placed anywhere in a query without affecting the result:

```gql
MATCH (n)
CALL log_event('visited')
RETURN n._id
```

This returns every `n._id`, and `log_event` runs once per node. Note that `PRINT` writes to the server's log rather than to the query result; see <a target="_blank" href="/docs/stored-procedures/data-operations#PRINT">PRINT</a>.

## OPTIONAL CALL

Prefix `CALL` with `OPTIONAL` to suppress the "procedure not found" error when the named procedure does not exist. Compare:

```gql
-- Errors with: procedure 'maybe_proc' not found
CALL maybe_proc() YIELD result
RETURN result
```

```gql
-- No error; returns an empty result with column `result`
OPTIONAL CALL maybe_proc() YIELD result
RETURN result
```

`OPTIONAL` also changes what happens when a procedure resolves and runs but yields no rows for a given input row. Without it the row is dropped by the join; with it the row is kept and the yielded columns are filled with NULL:

```gql
-- Persons for whom score_node yields nothing are dropped
MATCH (n:Person)
CALL score_node(n._id) YIELD score
RETURN n._id, score

-- Every Person is kept; score is NULL where the procedure yielded nothing
MATCH (n:Person)
OPTIONAL CALL score_node(n._id) YIELD score
RETURN n._id, score
```

The same NULL-padding applies to the inline subquery form `OPTIONAL CALL { ... }`, documented in <a target="_blank" href="/docs/gql/call#OPTIONAL-CALL">CALL</a>.
