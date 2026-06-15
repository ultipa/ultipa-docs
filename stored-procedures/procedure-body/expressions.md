# Expressions

Complete reference for all expression types available in stored procedures.

## Arithmetic Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `+` | Addition | `a + b` |
| `-` | Subtraction | `a - b` |
| `*` | Multiplication | `a * b` |
| `/` | Division | `a / b` |
| `%` | Modulo | `a % b` |
| `^` | Exponentiation | `a ^ b` |

<p tit="Procedure Body Language"></p>

```gql
LET sum = x + y
LET ratio = count / total
LET remainder = i % 2
LET squared = x ^ 2
```

## Comparison Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Equal | `a = b` |
| `<>` | Not equal | `a <> b` |
| `!=` | Not equal (alias) | `a != b` |
| `<` | Less than | `a < b` |
| `>` | Greater than | `a > b` |
| `<=` | Less than or equal | `a <= b` |
| `>=` | Greater than or equal | `a >= b` |

## Logical Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `AND` | Logical AND | `a AND b` |
| `OR` | Logical OR | `a OR b` |
| `NOT` | Logical NOT | `NOT a` |
| `XOR` | Exclusive OR | `a XOR b` |

<p tit="Procedure Body Language"></p>

```gql
IF age > 18 AND active = true {
    PRINT 'Active adult'
}

IF score > 0.9 OR rank < 10 {
    PRINT 'Notable'
}

IF NOT visited {
    n.visited = true
}
```

## String Concatenation

Use `||` for string concatenation:

<p tit="Procedure Body Language"></p>

```gql
LET greeting = 'Hello, ' || name || '!'
LET info = 'Count: ' || TOSTRING(count) || ', Score: ' || TOSTRING(score)
```

## NULL Checks

| Expression | Description |
|------------|-------------|
| `expr IS NULL` | True if value is NULL |
| `expr IS NOT NULL` | True if value is not NULL |

<p tit="Procedure Body Language"></p>

```gql
IF n.email IS NOT NULL {
    PRINT n.email
}

IF p IS NULL {
    PRINT 'No path found'
}
```

## IN / NOT IN

Check membership in a list:

<p tit="Procedure Body Language"></p>

```gql
IF n._id IN ['alice', 'bob', 'charlie'] {
    PRINT 'Found known person'
}

IF nodeLabel NOT IN excluded_labels {
    -- process
}
```

## CASE Expression

### Simple CASE

<p tit="Procedure Body Language"></p>

```gql
LET category = CASE status
    WHEN 'active' THEN 'A'
    WHEN 'pending' THEN 'P'
    WHEN 'inactive' THEN 'I'
    ELSE 'U'
END
```

### General CASE

<p tit="Procedure Body Language"></p>

```gql
LET tier = CASE
    WHEN score > 0.9 THEN 'platinum'
    WHEN score > 0.7 THEN 'gold'
    WHEN score > 0.5 THEN 'silver'
    ELSE 'bronze'
END
```

## List Comprehension

Build a new list from an existing list by iterating and optionally filtering / transforming. The base form names the loop variable, then `IN <list>`, with an optional `WHERE`/`FILTER` clause and an optional `| <expr>` mapping clause.

| Form | Meaning |
|---|---|
| `[ <var> IN <list> ]` | Iterate; result is the input list |
| `[ <var> IN <list> \| <expr> ]` | Map each element through `<expr>` |
| `[ <var> IN <list> WHERE <condition> ]` | Keep elements matching `<condition>` |
| `[ <var> IN <list> WHERE <condition> \| <expr> ]` | Filter, then map |
| `[ <var> IN <list> FILTER <condition> ]` | Same as `WHERE` form |
| `[ <var> IN <list> FILTER <condition> \| <expr> ]` | Same as `WHERE` + map form |

### Transform

<p tit="Procedure Body Language"></p>

```gql
-- Map each element through an expression
LET doubled = [x IN RANGE(1, 6) | x * 2]
LET names = [n IN friends | n.name]
```

### Filter and Transform

<p tit="Procedure Body Language"></p>

```gql
-- Filter, then map
LET active_names = [n IN friends WHERE n.active = true | n.name]

-- With complex expressions on either side
LET scores = [n IN nodes WHERE OUT_DEGREE(n) > 5 | GET_SLICE_PROP(n._internal_id, 'rank')]
```

`WHERE` and `FILTER` are interchangeable inside a list comprehension.

## REDUCE

Aggregate a list into a single value:

<p tit="Procedure Body Language"></p>

```gql
LET total = REDUCE(acc = 0, x IN numbers | acc + x)
LET product = REDUCE(acc = 1, x IN values | acc * x)
```

## Subscript Access

### List Indexing

<p tit="Procedure Body Language"></p>

```gql
LET first = myList[0]
LET third = myList[2]
```

### List Slicing

<p tit="Procedure Body Language"></p>

```gql
LET sub = myList[1:3]    -- elements at index 1 and 2
LET head = myList[0:5]   -- first 5 elements
```

### Map Access

<p tit="Procedure Body Language"></p>

```gql
LET v = myMap['key']
LET name = record['name']
```

## Property Access

<p tit="Procedure Body Language"></p>

```gql
-- Node properties
LET name = n.name
LET id = n._id
LET internal = n._internal_id
LET nodeLabels = n._labels

-- Edge properties
LET weight = e.weight
LET src = e._from
LET dest = e._to

```

Path values do not support property-style access — use functions instead:

| Built-in | Returns |
|---|---|
| `LENGTH(path)` or `PATH_LENGTH(path)` | `INTEGER` hop count |
| `NODES(path)` | `LIST<NODE>` of nodes along the path |
| `RELATIONSHIPS(path)` | `LIST<EDGE>` of edges along the path |

```gql
LET len = LENGTH(p)
LET ns = NODES(p)
LET es = RELATIONSHIPS(p)
```

## Subquery Expression

Use a subquery as an expression to assign its result to a variable:

<p tit="Procedure Body Language"></p>

```gql
LET result = (MATCH (n:Person WHERE n.age > 30) RETURN COUNT(n) AS cnt)
```

This returns the result of the inner query as a value.

## EXISTS / NOT EXISTS

Check whether a subquery returns any results:

<p tit="Procedure Body Language"></p>

```gql
IF EXISTS {
    MATCH (n)-[:KNOWS]->(m WHERE m.name = 'Alice')
} {
    PRINT 'Knows Alice'
}

IF NOT EXISTS {
    MATCH (n)-[:BLOCKED]->(m)
} {
    PRINT 'Not blocked'
}
```

## MAP Expression

Transform each element of a list:

<p tit="Procedure Body Language"></p>

```gql
LET result = MAP(x IN myList | x * 2)
```

## Operator Precedence

From highest to lowest:

| Precedence | Operators |
|------------|-----------|
| 1 (highest) | `.` (property access), `[]` (subscript) |
| 2 | `^` (exponentiation) |
| 3 | Unary `-`, `NOT` |
| 4 | `*`, `/`, `%` |
| 5 | `+`, `-` |
| 6 | `||` (concatenation) |
| 7 | `=`, `<>`, `!=`, `<`, `>`, `<=`, `>=` |
| 8 | `IS NULL`, `IS NOT NULL`, `IN`, `NOT IN` |
| 9 | `AND` |
| 10 | `XOR` |
| 11 (lowest) | `OR` |

Use parentheses to override default precedence:

<p tit="Procedure Body Language"></p>

```gql
LET result = (a + b) * (c - d)
IF (x > 0 AND y > 0) OR z = 0 { ... }
```