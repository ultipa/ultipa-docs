# Procedure Body Language

The block following `AS { ... }` in a `CREATE PROCEDURE` statement is written in a procedural language that extends GQL. Standard GQL statements — `MATCH`, `INSERT`, `SET`, `DELETE`, `MERGE`, `RETURN`, and all GQL functions — are valid inside the body, and additional procedural constructs are layered on top for control flow, variable binding, error handling, parallelism, and high-performance graph computation.

This page is a roadmap to the rest of the section. Each construct has its own page with details and examples.

## Constructs Available in the Body

| Category | Constructs |
|---|---|
| <a href="/docs/stored-procedures/data-operations">Data Operations</a> | `LET`, temp property assignment, `MATCH`, `INSERT`, `SET`, `DELETE`, `RETURN`, `PRINT`, `FLUSH`, `BATCH_INSERT_NODES`, `BATCH_INSERT_EDGES` |
| <a href="/docs/stored-procedures/control-flow">Control Flow</a> | `IF` / `ELSE IF` / `ELSE`, `FOR`, `WHILE`, `BREAK`, `CONTINUE`, `TRY` / `CATCH`, `THROW`, `ATOMIC { ... }` |
| <a href="/docs/stored-procedures/iterators-and-traversal">Iterators and Traversal</a> | `SCAN`, `EDGES`, `NEIGHBORS`, `RANGE`, `FOR ... IN MATCH` |
| <a href="/docs/stored-procedures/parallel-execution">Parallel Execution</a> | `PARALLEL FOR`, slice properties, parallel reductions |
| <a href="/docs/stored-procedures/builtin-functions">Built-in Functions</a> | Topology, neighbor aggregation, slice operations |
| <a href="/docs/stored-procedures/expressions">Expressions</a> | Operators, conversions, accessors |

## Rules That Apply Across the Body

A few rules cut across every page in this section.

### Variable Binding

- `LET <name> = <expression>` declares **and** reassigns a variable. Bare assignment (`x = 1` without `LET`) is rejected at parse time with `bare assignment 'x = ...' requires LET keyword`.
- The only bare-assignment form supported is property assignment on a node or edge — e.g., `n.score = 0.5` — which writes to an in-memory **temp property** for the duration of the call.

### Parameter Substitution

Procedure parameters declared in the signature are read inside the body with the `$name` syntax. They are not re-declared with `LET`. Substitution works anywhere an expression is allowed:

| Context | Example |
|---|---|
| Inline `MATCH`, `INSERT`, `SET`, `DELETE` | `MATCH (n WHERE n._id = $node_id)` |
| Function arguments | `SUBSTRING($text, 1, $len)` |
| String concatenation | `'user-' \|\| $suffix` |
| `SCAN` / `EDGES` label filter | `FOR n IN SCAN(:$label) { ... }` |
| Hop-range bounds in `FOR ... IN MATCH` | `(start)-[:KNOWS]->{1,$max_hops}(end)` |

### Statements vs Expressions

The body is a sequence of statements. Inline subqueries are not supported — every clause is its own statement. Function calls (e.g., `INIT_SLICE_PROP('rank', 0.0)`) can appear as standalone statements when their side effect is the point.

### Returning Rows

A non-VOID procedure must execute at least one `RETURN <expr1>, <expr2>, ...` statement to emit a row. `RETURN` inside a loop streams one row per iteration. A bare `RETURN` (no values) exits the procedure immediately — equivalent to an early exit in any procedural language.

### Compute Engine Dependency

Some body-language features require the compute engine to be enabled on the graph:

```gql
ALTER GRAPH <graphName> SET COMPUTE ENABLED
```

These features are: topology functions (`NODE_COUNT`, `OUT_DEGREE`, `IN_DEGREE`), neighbor aggregation functions (`SUM_OUT_NEIGHBOR_PROP`, etc.), slice property functions (`INIT_SLICE_PROP`, `GET_SLICE_PROP`, `SET_SLICE_PROP`, ...), parallel reductions, and `PARALLEL FOR` with `SCAN()`. Without the compute engine, they return `0` or default values rather than erroring.

Standard GQL inside the body (`MATCH`, `INSERT`, `SET`, etc.) runs through the regular query planner and does not depend on the compute engine.
