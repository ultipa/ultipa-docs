# Procedure Management

This page covers the lifecycle of stored procedures: creating, listing, altering, and dropping.

## Showing Procedures

Show procedures in the current graph:

```gql
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

Returns a table with columns: `name`, `description`, `tags`, `parameters`, `returns`, and `body`.

The `LIKE` name pattern uses SQL-style matching (case-insensitive):

| Wildcard | Meaning |
|----------|---------|
| `%` | Matches any sequence of characters (zero or more) |
| `_` | Matches exactly one character |

## Creating Procedures

```syntax
<create procedure statement> ::=
  "CREATE" [ "OR REPLACE" ] "PROCEDURE" <procedure name> [ <comment> ] [ <tags> ] <parameters>
  "RETURNS" { <return columns> | "VOID" }
  "AS {" <procedure body> "}"

<comment> ::= "COMMENT" <comment string>

<tags> ::= "TAGS [" <tag string> { "," <tag string> }... "]"

<parameters> ::= "(" [ <parameter> { "," <parameter> }... ] ")"

<parameter> ::= <parameter name> ":" <parameter type> [ "=" <default value> ]

<return columns> ::= "(" <return column> { "," <return column> }... ")" 

<return column> ::= <column name> ":" <column type>
```

**Details**

- The procedure name must be a unqiue single identifier within a graph. Dotted names like `algo.pagerank` are reserved for GQLDB build-in algorithms which can be referenced in `CALL`, not for user-defined procedures.
- To write the `<procedure body>`, see <a target="_blank" href="/docs/stored-procedures/procedure-body-language">Procedure Body Language</a>.
- Parameter and return-column declarations accept the following types:

| Type | Aliases | Description | Example Values |
|------|---------|-------------|----------------|
| `STRING` | — | Text value | `'hello'`, `'Alice'` |
| `INTEGER` | `INT` | 64-bit signed integer | `42`, `-1`, `0` |
| `FLOAT` | — | 64-bit floating point | `3.14`, `0.85` |
| `BOOLEAN` | — | Boolean value | `true`, `false` |
| `NODE` | — | Graph node | Node from `MATCH` |
| `EDGE` | — | Graph edge | Edge from `MATCH` |
| `PATH` | — | Graph path | Path from `MATCH` |
| `LIST<T>` | — | Typed list, `T` is any of the above | `LIST<STRING>`, `LIST<INTEGER>` |

Other GQL value types — `DATE`, `TIME`, `TIMESTAMP`, `ZONED_DATETIME`, `DURATION`, `MAP`, `POINT`, `BYTES`, etc. — cannot be declared as procedure parameters or return columns. They can still appear inside the procedure body as values produced by functions or property reads (e.g., `LET d = date()`).

### With No Parameters

```gql
CREATE PROCEDURE count_all_nodes()
RETURNS (cnt: INTEGER)
AS {
    LET cnt = NODE_COUNT()
    RETURN cnt
}
```

### With Parameters

Parameters are declared in the procedure signature with `<name>: <type>` syntax:

```gql
CREATE PROCEDURE to_sentence(
    name: STRING,
    age: INTEGER
)
RETURNS (msg: STRING)
AS {
    RETURN $name || ' is ' || TOSTRING($age) || ' years old.' AS msg
}
```

### With Parameter Default Values

```gql
CREATE PROCEDURE find_nodes(label: STRING = 'Person', limit: INT = 10)
RETURNS (node_id: STRING)
AS {
    LET i = 0
    FOR n IN SCAN(:$label) {
        IF i >= $limit {
            BREAK
        }
        RETURN n._id AS node_id
        LET i = i + 1
    }
}
```

When calling, arguments are matched to parameters by position. Named arguments are not supported. You can omit trailing parameters that have defaults:

```gql
CALL find_nodes()            -- label=default, limit=default
CALL find_nodes('Book')      -- label='Book', limit=default
CALL find_nodes('Book', 5)   -- label='Book', limit=5
```

Default values are supported only for the primitive types `STRING`, `INTEGER`/`INT`, `FLOAT`, and `BOOLEAN`. Specifying a default on `NODE`, `EDGE`, `PATH`, or `LIST<T>` is rejected at call time.

### VOID Returns

Use `RETURNS VOID` for procedures that only perform side effects and don't need to return data, such as modifying graph data (`INSERT`, `DELETE`, `SET`), initializing properties, or logging.

```gql
CREATE PROCEDURE log_event(message: STRING)
RETURNS VOID
AS {
    PRINT $message
}
```

### Multiple Returns

Each `RETURN` statement adds a row to the result set. Use `RETURN` inside a loop to stream multiple rows:

```gql
CREATE PROCEDURE list_labels()
RETURNS (node_id: STRING, label: STRING)
AS {
    FOR n IN SCAN() {
        FOR lbl IN LABELS(n) {
            RETURN n._id AS node_id, lbl AS node_label
        }
    }
}
```

### Commenting and Tags

Attach a human-readable description and a list of tags to a procedure. Both clauses go between the procedure name and the parameter list, and either is optional. They are stored with the definition and surfaced by `SHOW PROCEDURES`:

```gql
CREATE PROCEDURE greet
COMMENT 'Build a personalized greeting for a user'
TAGS ['utility', 'demo']
(name: STRING)
RETURNS (greeting: STRING)
AS {
    RETURN 'Hello ' || $name AS greeting
}
```

After creating it, `SHOW PROCEDURES` reflects both fields:

| name | comment | tags | parameters | returns | body |
| -- | -- | -- | -- | -- | -- |
| greet | Build a personalized greeting for a user | utility, demo | (name: STRING) | (greeting: STRING) | RETURN 'Hello ' \|\| $name AS greeting |

### Using OR REPLACE

Overwrites an existing procedure with the same name:

```gql
CREATE OR REPLACE PROCEDURE my_proc(x: INTEGER)
RETURNS (result: INTEGER)
AS {
    RETURN $x * 2 AS result
}
```

## Altering Procedures

Update the comment or tags of an existing procedure without rewriting its body:

```gql
-- Update comment only
ALTER PROCEDURE my_proc COMMENT 'Doubles its input'

-- Replace the tag list (an empty list clears the tags)
ALTER PROCEDURE my_proc TAGS ['math', 'utility']

-- Update both in one statement
ALTER PROCEDURE my_proc COMMENT 'Doubles its input' TAGS ['math']
```

## Dropping Procedures

Drop the procedure `my_proc`:

```gql
DROP PROCEDURE my_proc
```

The `IF EXISTS` clause is used to prevent errors when attempting to procedure a graph that does not exist. It allows the statement to be safely executed.

```gql
DROP PROCEDURE IF EXISTS my_proc
```

This deletes the procedure `my_proc` only if a procedure with that name does exist. If `my_proc` does not exist, the statement is ignored without throwing an error.