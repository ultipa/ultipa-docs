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

When calling, you can omit parameters with defaults:

```gql
CALL pagerank() YIELD node_id, rank          -- uses all defaults
CALL pagerank(50) YIELD node_id, rank        -- iterations=50, rest default
CALL pagerank(50, 0.90) YIELD node_id, rank  -- iterations=50, damping=0.90
```

## Supported Types

| Type | Aliases | Description | Example Values |
|------|---------|-------------|----------------|
| `STRING` | — | Text value | `'hello'`, `'Alice'` |
| `INTEGER` | `INT` | 64-bit signed integer | `42`, `-1`, `0` |
| `FLOAT` | — | 64-bit floating point | `3.14`, `0.85` |
| `BOOLEAN` | — | Boolean value | `true`, `false` |
| `NODE` | — | Graph node | Node from MATCH |
| `EDGE` | — | Graph edge | Edge from MATCH |
| `PATH` | — | Graph path | Path from traversal |
| `LIST<T>` | — | Typed list | `LIST<STRING>`, `LIST<INTEGER>` |

### LIST Types

Lists can be parameterized with element types:

```gql
CREATE PROCEDURE process_ids(ids: LIST<STRING>)
RETURNS (count: INTEGER)
AS {
    LET count = SIZE($ids)
    FOR id IN $ids {
        PRINT id
    }
    RETURN count
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
- Embedded MATCH/INSERT/SET/DELETE queries
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

Procedures return named, typed columns:

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

Procedures that don't return data:

```gql
CREATE PROCEDURE init_scores(value: FLOAT)
RETURNS VOID
AS {
    INIT_SLICE_PROP('score', $value)
    -- No RETURN needed, or use empty RETURN
    RETURN
}
```

### Multiple Returns (Streaming)

Each RETURN statement in a loop adds a row to the result set:

```gql
CREATE PROCEDURE list_friends(person_id: STRING)
RETURNS (friend_id: STRING, friend_name: STRING)
AS {
    MATCH (p {_id: $person_id})
    FOR neighbor IN NEIGHBORS(p, OUT, :KNOWS) {
        -- Each RETURN adds a row
        RETURN neighbor._id AS friend_id, neighbor.name AS friend_name
    }
}
```

## Type Coercion Rules

The procedure runtime applies automatic type coercion in these cases:

| From | To | Rule |
|------|----|------|
| `INTEGER` | `FLOAT` | Lossless promotion: `42` → `42.0` |
| `FLOAT` | `INTEGER` | Truncation: `3.7` → `3` |
| Any | `STRING` | Via `TOSTRING()` |
| `STRING` | `INTEGER` | Via `TOINTEGER()` |
| `STRING` | `FLOAT` | Via `TOFLOAT()` |
| `INTEGER` | `BOOLEAN` | `0` → `false`, non-zero → `true` |
| `FLOAT` | `BOOLEAN` | `0.0` → `false`, non-zero → `true` |
| `NULL` | `BOOLEAN` | `NULL` → `false` |

### Arithmetic Coercion

When mixing INTEGER and FLOAT in arithmetic:
- Both operands are promoted to FLOAT
- If both inputs were INTEGER and the result is a whole number, INTEGER is returned

```gql
LET a = 10      -- INTEGER
LET b = 3.0     -- FLOAT
LET c = a + b   -- FLOAT: 13.0
LET d = a * 2   -- INTEGER: 20
```
