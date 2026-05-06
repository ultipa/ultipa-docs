# Execution Plan

When a GQL query is submitted, it goes through parsing, optimization, and execution. To inspect how a query will be or was executed, prefix it with `EXPLAIN` or `PROFILE`.

## EXPLAIN

Generates the execution plan for a query without running it. The default text format returns the estimated cost and rows along with a numbered list of operations.

```gql
EXPLAIN
MATCH (n:Student)
RETURN n.name
LIMIT 10
```

Returns a single-column table `QUERY PLAN`:

```output
Execution Plan:
  Estimated Cost: 2
  Estimated Rows: 0

Operations:
  1. MATCH (1 patterns) [cost: 1000]
  2. RETURN (1 items) [cost: 50]
```

### EXPLAIN (FORMAT TREE)

Returns the plan as a tree visualization with cost and row estimates per node.

```gql
EXPLAIN (FORMAT TREE) 
MATCH (n:Student)
RETURN n.name
LIMIT 10
```

Returns a single-column table `QUERY PLAN`:

```output
Query Plan:
  Total Cost: 2, Estimated Rows: 0

└── Query Pipeline (2 operations) (cost: 1050, rows: 0)
    ├── MATCH (1 patterns) (cost: 1000)
    └── RETURN (1 items) (cost: 50)
```

### EXPLAIN (FORMAT JSON)

Returns the execution plan as JSON.

```gql
EXPLAIN (FORMAT JSON) 
MATCH (n:Student)
RETURN n.name
LIMIT 10
```

Returns a single-column table `QUERY PLAN (JSON)` containing the plan as a JSON string:

```json
{
  "query": "EXPLAIN (FORMAT JSON) MATCH (n:Student)\nRETURN n.name\nLIMIT 10",
  "format": "tree",
  "planTree": {
    "type": "Pipeline",
    "description": "Query Pipeline (2 operations)",
    "estimatedCost": 1050,
    "estimatedRows": 0,
    "children": [
      {
        "type": "MATCH",
        "description": "MATCH (1 patterns)",
        "estimatedCost": 1000,
        "estimatedRows": -1,
        "properties": { "optional": false, "patterns": 1 }
      },
      {
        "type": "RETURN",
        "description": "RETURN (1 items)",
        "estimatedCost": 50,
        "estimatedRows": -1,
        "properties": { "asterisk": false, "distinct": false, "itemCount": 1 }
      }
    ]
  },
  "operations": [
    {
      "type": "MATCH",
      "description": "MATCH (1 patterns)",
      "estimatedCost": 1000,
      "estimatedRows": -1,
      "properties": { "optional": false, "patterns": 1 }
    },
    {
      "type": "RETURN",
      "description": "RETURN (1 items)",
      "estimatedCost": 50,
      "estimatedRows": -1,
      "properties": { "asterisk": false, "distinct": false, "itemCount": 1 }
    }
  ],
  "totalCost": 2,
  "totalRows": 0
}
```

`estimatedRows: -1` indicates the per-operation row estimate is unknown; the overall `totalRows` and the `Pipeline` node carry the planner's aggregate estimate.

### EXPLAIN ANALYZE

Runs the query and returns a comparison of actual execution metrics against the planner's estimates.

```gql
EXPLAIN ANALYZE
MATCH (n:Student)
RETURN n.name
LIMIT 10
```

Returns a single-column table `EXPLAIN ANALYZE`:

```output
EXPLAIN ANALYZE
================

Query: EXPLAIN ANALYZE MATCH (n:Student)
RETURN n.name
LIMIT 10

Execution Summary:
-----------------
  Actual Execution Time: 287.958µs
  Actual Rows Returned:  2
  Estimated Rows:        0
  Estimated Cost:        2

Operation Details:
-----------------
  Op                Est.Cost   Est.Rows
  MATCH                1000          ?
  RETURN                 50          ?
```

`?` in the `Est.Rows` column means the per-operation row estimate is unknown at plan time. An additional `Estimate Accuracy` line appears in the summary when `Estimated Rows > 0`.

### EXPLAIN OPTIMIZER

Shows the optimizer configuration and rule trace for the query.

```gql
EXPLAIN OPTIMIZER
MATCH (n:Student)
RETURN n.name
LIMIT 10
```

Returns a single-column table `EXPLAIN OPTIMIZER`:

```output
EXPLAIN OPTIMIZER
=================

Query: EXPLAIN OPTIMIZER MATCH (n:Student)
RETURN n.name
LIMIT 10

Optimizer Configuration:
-----------------------
  COUNT Optimization:     Enabled
  TopN Optimization:      Enabled
  Predicate Pushdown:     Enabled
  Path Reversal:          Enabled
  Vector k-NN:            Enabled
  CSE:                    Enabled

Optimizer Trace:
---------------
  Phase    Rule                    Applied  Reason
  -------  ----------------------  -------  ------
  AST      PredicateEquivalence    No       No duplicate predicates
  AST      PredicatePushdown       Maybe    Check for inline WHERE
  AST      PathReversal            No       Single pattern
  Plan     CountOptimization       No       Not a COUNT query
  Plan     TopNOptimization        No       No ORDER BY + LIMIT
```

## PROFILE

Runs the query and returns a profiling table that breaks down execution into phases, showing time and memory usage for each.

```gql
PROFILE
MATCH (n:Student)
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
| Parse | 0.897 | 0.01592 | 0 | 0 | AST: *ast.Query |
| Plan | 0.406 | 0 | 0 | 0 | Query planning |
| Execute | 2.452 | 0.01540 | 0 | 2 | 2 rows |
| TOTAL | 4.155 | 0.03135 | 0 | 2 | 2 total rows |
