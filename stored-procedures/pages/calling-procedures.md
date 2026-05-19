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

The yielded columns **replace** the outer binding row — variables from earlier clauses are not visible after a named `CALL ... YIELD`. To carry variables through, project them in a `RETURN` before the `CALL`, or use the inline `CALL { ... }` form with explicit variable import (see <a target="_blank" href="/docs/gql/call">CALL</a>).

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

This is the lookup-failure path only. If a named procedure resolves and runs successfully but yields zero rows, the result is still an empty table — `OPTIONAL` does not insert a NULL-padded row in that case. Rich NULL-padding semantics (preserve outer rows when the subquery is empty) apply only to the inline subquery form `OPTIONAL CALL { ... }` documented in <a target="_blank" href="/docs/gql/call#optional-call">CALL</a>.
