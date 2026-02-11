# Procedure Management

This page covers the lifecycle of stored procedures: creating, calling, listing, and dropping.

## CREATE PROCEDURE

### Basic Syntax

<p tit="Syntax"></p>

```gql
CREATE PROCEDURE procedure_name(param1: TYPE, param2: TYPE)
RETURNS (col1: TYPE, col2: TYPE)
AS {
    -- procedure body
}
```

### With No Parameters

```gql
CREATE PROCEDURE count_all_nodes()
RETURNS (cnt: INTEGER)
AS {
    LET cnt = NODE_COUNT()
    RETURN cnt
}
```

### With Default Values

```gql
CREATE PROCEDURE find_nodes(label: STRING = 'Person', limit: INT = 10)
RETURNS (node_id: STRING)
AS {
    LET i = 0
    FOR node IN SCAN(:$label) {
        IF i >= $limit {
            BREAK
        }
        RETURN node._id AS node_id
        i = i + 1
    }
}
```

### VOID Return Type

Procedures that don't return data use `RETURNS VOID`:

```gql
CREATE PROCEDURE log_event(message: STRING)
RETURNS VOID
AS {
    PRINT $message
}
```

### Dotted Procedure Names

Procedures can be organized using dot notation for logical grouping:

```gql
CREATE PROCEDURE algo.pagerank(iterations: INT = 20, damping: FLOAT = 0.85)
RETURNS (node_id: STRING, rank: FLOAT)
AS {
    -- algorithm implementation
}

CREATE PROCEDURE algo.hits(iterations: INT = 20)
RETURNS (node_id: STRING, hub: FLOAT, authority: FLOAT)
AS {
    -- algorithm implementation
}
```

The dot notation is purely a naming convention — `algo.pagerank` is stored as a single name string. Use `DROP PROCEDURE algo.pagerank` to remove it.

### CREATE OR REPLACE

Overwrites an existing procedure with the same name:

```gql
CREATE OR REPLACE PROCEDURE my_proc(x: INTEGER)
RETURNS (result: INTEGER)
AS {
    RETURN $x * 2 AS result
}
```

## DROP PROCEDURE

```gql
-- Drop a procedure (error if not found)
DROP PROCEDURE my_proc

-- Drop only if it exists (no error if not found)
DROP PROCEDURE IF EXISTS my_proc
```

## SHOW PROCEDURES

Returns a table with columns: `body`, `name`, `parameters`, and `returns`.

```gql
-- List all procedures
SHOW PROCEDURES

-- Filter by name pattern

-- Starts with "find"
SHOW PROCEDURES LIKE 'find%'

-- Starts with "find_" followed by at least 1 character
SHOW PROCEDURES LIKE 'find_%'

-- Contains "path" anywhere in the name
SHOW PROCEDURES LIKE '%path%'

-- Ends with "rank"
SHOW PROCEDURES LIKE '%rank'

-- "get" followed by exactly 3 characters
SHOW PROCEDURES LIKE 'get___'
```

The `LIKE` name pattern uses SQL-style matching (case-insensitive):

| Wildcard | Meaning |
|----------|---------|
| `%` | Matches any sequence of characters (zero or more) |
| `_` | Matches exactly one character |

## CALL

### Call with YIELD

Without `YIELD`, a procedure still returns all its output columns. The `YIELD` clause selects specific columns or renames them:

```gql
CALL greet('World') YIELD message
```

Select specific columns from multi-column output:

```gql
CALL pagerank(20) YIELD node_id, rank
```

Rename columns using `AS`:

```gql
CALL pagerank(20) YIELD node_id AS id, rank AS score
```

### Call without YIELD

Without `YIELD`, all output columns are returned. For VOID procedures, there is no output:

```gql
-- Returns all output columns
CALL greet('World')

-- VOID procedure, no output
CALL log_event('System started')
```

### Using Results in Subsequent Queries

Results from YIELD can flow into subsequent query clauses:

```gql
CALL count_all_nodes() YIELD cnt
MATCH (n:Person) WHERE n.age > cnt*3
RETURN n
```

### CALL ON Projection

Run a procedure on a named graph projection:

```gql
CALL pagerank(20) ON my_projection YIELD node_id, rank
```

This executes the procedure using the topology of the specified projection rather than the full graph.


### Nested CALL Within Procedures

Procedures can call other procedures:

```gql
CREATE PROCEDURE analyze_network(person_id: STRING)
RETURNS (metric: STRING, value: FLOAT)
AS {
    CALL pagerank(20, 0.85) YIELD node_id, rank
    -- Use results from the called procedure
}
```