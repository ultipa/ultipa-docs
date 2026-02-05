# Procedure Management

This page covers the lifecycle of stored procedures: creating, calling, listing, and dropping.

## CREATE PROCEDURE

### Basic Syntax

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
RETURNS (count: INTEGER)
AS {
    LET count = NODE_COUNT()
    RETURN count
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

```gql
-- List all procedures
SHOW PROCEDURES

-- Filter by name pattern
SHOW PROCEDURES LIKE 'find_%'
SHOW PROCEDURES LIKE '%rank%'
```

Returns a table with columns: name, parameters, return type, and body.

## CALL

### Basic Call with YIELD

The `YIELD` clause captures the output columns of a procedure:

```gql
CALL greet('World') YIELD message
```

### Call without YIELD

For VOID procedures or when output is not needed:

```gql
CALL log_event('System started')
```

### Using Results in Subsequent Queries

Results from CALL can flow into subsequent query clauses:

```gql
CALL count_all_nodes() YIELD count
MATCH (n:Person)
RETURN n LIMIT count
```

### Qualified Names (Namespaces)

Procedures can be organized in namespaces using dot notation:

```gql
CALL algo.pagerank(20, 0.85) YIELD node_id, rank
CALL graph.shortest_path('a', 'b') YIELD path_length
```

### CALL ON Projection

Run a procedure on a named graph projection:

```gql
CALL pagerank(20) ON my_projection YIELD node_id, rank
```

This executes the procedure using the topology of the specified projection rather than the full graph.

### Inline CALL (Subquery)

Execute an inline subquery as a procedure call:

```gql
MATCH (n:Person)
CALL {
    MATCH (n)-[:KNOWS]->(friend)
    RETURN friend
}
RETURN n, friend
```

### OPTIONAL CALL

Like a LEFT JOIN — returns NULL for non-matching rows instead of filtering them out:

```gql
MATCH (n:Person)
OPTIONAL CALL {
    MATCH (n)-[:WORKS_AT]->(c:Company)
    RETURN c.name AS company
}
RETURN n.name, company
```

### Variable Import with CALL

Explicitly specify which variables to import from the outer scope:

```gql
MATCH (n:Person)
CALL (n) {
    MATCH (n)-[:KNOWS]->(friend)
    RETURN friend._id AS friend_id
}
RETURN n.name, friend_id
```

Without variable specification:

```gql
CALL () {
    MATCH (n:Person)
    RETURN COUNT(n) AS total
}
RETURN total
```

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
