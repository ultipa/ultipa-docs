# Execution Plan

When a GQL query is submitted, it goes through parsing, optimization, and execution. To inspect how a query will be or was executed, prefix it with `EXPLAIN` or `PROFILE`.

## EXPLAIN

Generates the execution plan for a query without running it. Returns a tree of execution operators showing the steps the query engine will take.

<p tit="Syntax"></p>

```gql
EXPLAIN <query>
```

<p tit="Example"></p>

```gql
EXPLAIN
MATCH (n:Account)
RETURN n.name
LIMIT 10
```

Returns a single-column table `QUERY PLAN` containing the plan tree:

```
Return{expr:[n.name]  row_type:n.name:STRING}
->    With{exprs:[n_2  as  n],row_type:n:  NODE}
      ->    Limit{limit:10,phase:DEFAULT,row_type:n_2:  NODE}
              ->    NodeSearch{alias:n_2,access_method:{condition:@Account,index_name:label,query_type:SK_LABEL_SCAN},row_type:n_2:  NODE}
```

### EXPLAIN (FORMAT JSON)

Returns the execution plan in JSON format instead of the default tree format.

```gql
EXPLAIN (FORMAT JSON)
MATCH (n:Account)
RETURN n.name
LIMIT 10
```

Returns a single-column table `QUERY PLAN (JSON)` containing the plan as a JSON string.

### EXPLAIN ANALYZE

Runs the query and returns a comparison of actual execution metrics against the planner's estimates.

```gql
EXPLAIN ANALYZE
MATCH (n:Account)
RETURN n.name
LIMIT 10
```

Returns a single-column table `EXPLAIN ANALYZE` containing a report with:

- **Execution Summary**: Actual execution time, actual rows returned, estimated rows, estimated cost, and estimate accuracy.
- **Operation Details**: A breakdown of each planned operation with its estimated cost and estimated rows.

### EXPLAIN OPTIMIZER

Shows the optimizer configuration and rule trace for the query. This helps understand which optimization rules were considered and whether they were applied.

```gql
EXPLAIN OPTIMIZER
MATCH (n:Account)
RETURN n.name
LIMIT 10
```

Returns a single-column table `EXPLAIN OPTIMIZER` containing:

- **Optimizer Configuration**: Lists optimizer rules and whether each is enabled (e.g., COUNT Optimization, TopN Optimization, Predicate Pushdown, Path Reversal, Vector k-NN, CSE).
- **Optimizer Trace**: Shows each rule evaluated during planning, whether it was applied, and the reason.

## PROFILE

Runs the query and returns a profiling table that breaks down execution into phases, showing time and memory usage for each.

<p tit="Syntax"></p>

```gql
PROFILE <query>
```

<p tit="Example"></p>

```gql
PROFILE
MATCH (n:Account)
RETURN n.name
LIMIT 10
```

Returns a table with the following columns:

| Field | Description |
| -- | -- |
| `Phase` | The execution phase: `Parse`, `Plan`, `Execute`, or `TOTAL`. |
| `Time_ms` | Time spent in the phase, in milliseconds. |
| `Alloc_MB` | Memory allocated during the phase, in megabytes. |
| `Rows_In` | Number of rows input to the phase. |
| `Rows_Out` | Number of rows output from the phase. |
| `Details` | Additional information about the phase (e.g., AST type, row count). |

Sample output:

| Phase | Time_ms | Alloc_MB | Rows_In | Rows_Out | Details |
| -- | -- | -- | -- | -- | -- |
| Parse | 0.85 | 0.02 | 0 | 0 | AST: *ast.Query |
| Plan | 0.01 | 0.00 | 0 | 0 | Query planning |
| Execute | 3.20 | 0.15 | 0 | 10 | 10 rows |
| TOTAL | 4.06 | 0.17 | 0 | 10 | 10 total rows |
