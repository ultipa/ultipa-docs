# Stored Procedures

## Overview

A stored procedure is a named, reusable, parameterized GQL query template. Stored procedures are graph-scoped — each procedure belongs to a specific graph. They are stored in the meta-server and callable via the `CALL` statement.

Stored procedures allow you to encapsulate complex queries into reusable units, making it easier to maintain and share query logic across applications.

## Showing Procedures

To show all procedures in the current graph:

```gql
SHOW PROCEDURE
```

To show a specific procedure:

```gql
SHOW PROCEDURE find_friends
```

Each procedure provides the following metadata:

| Field | Description |
| -- | -- |
| `name` | The name of the procedure. |
| `parameters` | The parameter definitions. |
| `returns` | The return column definitions. |
| `comment` | The description of the procedure. |
| `body` | The GQL query body. |
| `creator` | The user who created the procedure. |
| `create_time` | The time when the procedure was created. |

## Creating Procedure

### Syntax

```gql
CREATE PROCEDURE <procedureName> (<parameterList>)
  [RETURNS (<returnList>)]
  [COMMENT '<description>']
  AS '<gqlBody>'
```

**Rules:**

- Parameters use the `$paramName TYPE` format; the `$` prefix is required.
- Supported parameter types: `STRING`, `INT`, `INT32`, `INT64`, `UINT64`, `FLOAT`, `DOUBLE`, `BOOL`, `DATETIME`.
- The `RETURNS` clause is optional and declares output column names and types.
- The `COMMENT` clause is optional.
- The `AS` body must be a valid GQL query string containing `$param` placeholders.
- The body must not contain DDL statements (e.g., `CREATE GRAPH`, `DROP PROCEDURE`).
- The procedure name can be up to 128 characters.

### Examples

To create a procedure that finds friends within N hops:

```gql
CREATE PROCEDURE find_friends ($userId STRING, $maxDepth INT)
  RETURNS (friend_name STRING, friend_age INT)
  COMMENT 'Find friends within N hops'
  AS 'MATCH (n {_id: $userId})-[:Knows]->(m:Person) WHERE m.age > $maxDepth
      RETURN m.name AS friend_name, m.age AS friend_age'
```

To create a procedure with no parameters:

```gql
CREATE PROCEDURE count_all_persons ()
  AS 'MATCH (n:Person) RETURN count(n) AS total'
```

## Calling Procedure

### Standalone CALL

To call a stored procedure directly:

```gql
CALL find_friends('U001', 30)
```

### Embedded CALL

To call a stored procedure within a larger query pipeline:

```gql
MATCH (n:Person)
CALL find_friends(n._id, 30) YIELD friend_name
RETURN n.name, friend_name
LIMIT 100
```

In an embedded CALL:

- Each row from the outer query provides arguments to the procedure.
- The `YIELD` clause selects which return columns to project.
- `WHERE` conditions on yielded columns are supported.

### Example with YIELD and WHERE

```gql
MATCH (n:Person)
CALL find_friends(n._id, 20) YIELD friend_name, friend_age
  WHERE friend_age > 25
RETURN n.name, friend_name, friend_age
```

## Dropping Procedure

To drop a procedure:

```gql
DROP PROCEDURE find_friends
```

To drop a procedure only if it exists:

```gql
DROP PROCEDURE IF EXISTS find_friends
```

> Dropping a graph will also remove all procedures associated with that graph.

## Limitations

- The procedure body must be declarative GQL only — no procedural logic (IF/ELSE, WHILE, variable assignment).
- A procedure body cannot call another stored procedure (no nesting).
- Procedure calls execute as independent queries (not transaction-aware).
