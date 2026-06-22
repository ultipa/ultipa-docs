# Overview

In GQL, an **expression** is any syntactic form that produces a value when evaluated. Expressions appear inside `WHERE` clauses, `RETURN` items, list constructors, function arguments, and anywhere else the language asks for a value.

This section covers the dedicated expression forms GQL provides:

| Form | Purpose |
| -- | -- |
| <a href="/docs/gql/case">CASE</a> | Choose a value based on conditions |
| <a href="/docs/gql/let-value-expression">LET Value Expression</a> | Bind local names inside a single expression with `LET ... IN ... END` |
| <a href="/docs/gql/value-query-expression">Value Query Expression</a> | Produce a single value from a `VALUE { ... }` subquery |
| <a href="/docs/gql/count-query-expression">Count Query Expression</a> | Count the rows of a `COUNT { ... }` subquery (non-standard; prefer `VALUE { ... RETURN count(*) }`) |
| <a href="/docs/gql/list-expressions">List Expressions</a> | List comprehension and list quantifiers over an existing list |
| <a href="/docs/gql/current-values">Current Values</a> | Session and temporal keywords such as `CURRENT_USER`, `CURRENT_GRAPH`, and `CURRENT_TIMESTAMP` |
