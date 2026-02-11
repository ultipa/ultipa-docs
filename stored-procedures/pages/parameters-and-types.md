# Parameters and Types

This page covers the type system for stored procedure parameters and return values.

## Parameter Declaration

Parameters are declared in the procedure signature with `name: TYPE` syntax:

```gql
CREATE PROCEDURE example(
    name: STRING,
    age: INTEGER,
    score: FLOAT,
    active: BOOLEAN
)
RETURNS VOID
AS {
    PRINT $name || ' is ' || TOSTRING($age) || ' years old'
}
```

### Default Values

Parameters can have default values using `= value`:

```gql
CREATE PROCEDURE pagerank(
    iterations: INT = 20,
    damping: FLOAT = 0.85,
    label: STRING = 'Person'
)
RETURNS (node_id: STRING, rank: FLOAT)
AS {
    -- $iterations defaults to 20 if not provided
    -- $damping defaults to 0.85 if not provided
}
```

When calling, arguments are matched to parameters by position. Named arguments are not supported. You can omit trailing parameters that have defaults:

```gql
CALL pagerank() YIELD node_id, rank          -- uses all defaults
CALL pagerank(50) YIELD node_id, rank        -- iterations=50, rest default
CALL pagerank(50, 0.90) YIELD node_id, rank  -- iterations=50, damping=0.90, label defaults to 'Person'
```

## Supported Types

| Type | Aliases | Description | Example Values |
|------|---------|-------------|----------------|
| `STRING` | — | Text value | `'hello'`, `'Alice'` |
| `INTEGER` | `INT` | 64-bit signed integer | `42`, `-1`, `0` |
| `FLOAT` | — | 64-bit floating point | `3.14`, `0.85` |
| `BOOLEAN` | — | Boolean value | `true`, `false` |
| `DATE` | — | Calendar date | `DATE '2024-01-15'` |
| `TIME` | — | Time of day | `TIME '14:30:00'` |
| `TIMESTAMP` | — | Local date and time | `TIMESTAMP '2024-01-15T14:30:00'` |
| `ZONED_DATETIME` | — | Date and time with timezone | `ZONED_DATETIME '2024-01-15T14:30:00+08:00'` |
| `DURATION` | — | Time duration | `DURATION 'P1Y2M3D'` |
| `NODE` | — | Graph node | Node from `MATCH` |
| `EDGE` | — | Graph edge | Edge from `MATCH` |
| `PATH` | — | Graph path | Path from `MATCH` |
| `LIST<T>` | — | Typed list | `LIST<STRING>`, `LIST<INTEGER>` |

Lists can be parameterized with element types:

```gql
CREATE PROCEDURE process_ids(ids: LIST<STRING>)
RETURNS (cnt: INTEGER)
AS {
    LET cnt = SIZE($ids)
    FOR id IN $ids {
        PRINT id
    }
    RETURN cnt
}
```

## Parameter Substitution

Inside the procedure body, parameters are accessed using `$paramName`:

```gql
CREATE PROCEDURE find_person(name: STRING, min_age: INTEGER)
RETURNS (person_id: STRING)
AS {
    -- $name and $min_age are substituted into queries
    MATCH (p:Person WHERE p.name = $name AND p.age >= $min_age)
    RETURN p._id AS person_id
}
```

Parameter substitution works in:
- Embedded `MATCH`/`INSERT`/`SET`/`DELETE` queries
- Expressions and conditions
- Function arguments
- String concatenation

```gql
CREATE PROCEDURE dynamic_scan(label: STRING)
RETURNS VOID
AS {
    -- $label is substituted into the SCAN expression
    FOR node IN SCAN(:$label) {
        PRINT node._id
    }
}
```

## Return Specification

### Column Returns

Use `RETURNS (col1: TYPE, col2: TYPE, ...)` to define named, typed output columns:

```gql
CREATE PROCEDURE get_stats()
RETURNS (total_nodes: INTEGER, avg_degree: FLOAT)
AS {
    LET n = NODE_COUNT()
    -- compute average degree...
    RETURN n AS total_nodes, avg_deg AS avg_degree
}
```

### VOID Returns

Use `RETURNS VOID` for procedures that only perform side effects and don't need to return data, such as modifying graph data (`INSERT`, `DELETE`, `SET`), initializing properties, or logging:

```gql
CREATE PROCEDURE init_scores(value: FLOAT)
RETURNS VOID
AS {
    INIT_SLICE_PROP('score', $value)
}
```

### Multiple Returns (Streaming)

Each `RETURN` statement adds a row to the result set. Use `RETURN` inside a loop to stream multiple rows:

```gql
CREATE PROCEDURE list_labels()
RETURNS (node_id: STRING, label: STRING)
AS {
    FOR node IN SCAN() {
        FOR lbl IN LABELS(node) {
            RETURN node._id AS node_id, lbl AS label
        }
    }
}
```

### Early Return

A bare `RETURN` (without values) exits the procedure immediately, skipping any remaining statements. This works in both VOID and non-VOID procedures:

```gql
CREATE PROCEDURE safe_delete(node_id: STRING)
RETURNS VOID
AS {
    MATCH (n {_id: $node_id})
    IF IN_DEGREE(n) + OUT_DEGREE(n) > 0 {
        RETURN  -- Exit early, node has connections
    }
    DELETE n
}
```

## Implicit Type Coercion

The only implicit type coercion is `INTEGER` to `FLOAT`. This happens automatically in binary operations when one operand is INTEGER and the other is FLOAT:

```gql
LET a = 10      -- INTEGER
LET b = 3.0     -- FLOAT
LET c = a + b   -- FLOAT: 13.0 (a is promoted to FLOAT)
LET d = a * 2   -- INTEGER: 20 (both INTEGER, stays INTEGER)
```

### Explicit Type Conversion

Other type conversions require explicit function calls:

| Function | Conversion | Example |
|----------|-----------|---------|
| `TOSTRING()` | Any → `STRING` | `TOSTRING(42)` → `'42'` |
| `TOINTEGER()` | `STRING`/`FLOAT` → `INTEGER` | `TOINTEGER('42')` → `42` |
| `TOFLOAT()` | `STRING`/`INTEGER` → `FLOAT` | `TOFLOAT('3.14')` → `3.14` |

### Truthiness

Values are evaluated as boolean in conditions (`IF`, `WHILE`). The truthiness rules are:

| Type | Truthy | Falsy |
|------|--------|-------|
| `BOOLEAN` | `true` | `false` |
| `INTEGER` | Non-zero | `0` |
| `FLOAT` | Non-zero | `0.0` |
| `STRING` | Non-empty | `''` |
| `LIST` | Non-empty | Empty list |
| `NULL` | — | Always falsy |
| `NODE`, `EDGE` | Always truthy | — |
| `DATE`, `TIME`, `TIMESTAMP`, `ZONED_DATETIME` | Always truthy | — |
