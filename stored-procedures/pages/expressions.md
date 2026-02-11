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
    node.visited = true
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
IF node.email IS NOT NULL {
    PRINT node.email
}

IF path IS NULL {
    PRINT 'No path found'
}
```

## IN / NOT IN

Check membership in a list:

<p tit="Procedure Body Language"></p>

```gql
IF node._id IN ['alice', 'bob', 'charlie'] {
    PRINT 'Found known person'
}

IF label NOT IN excluded_labels {
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

### Searched CASE

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

### Transform

<p tit="Procedure Body Language"></p>

```gql
-- [expr FOR var IN list]
LET doubled = [x * 2 IN RANGE(1, 6)]

-- [expr | var IN list]
LET names = [node.name | node IN friends]
```

### Filter and Transform

<p tit="Procedure Body Language"></p>

```gql
-- [expr FOR var IN list WHERE condition]
LET active_names = [node.name | node IN friends WHERE node.active = true]

-- With complex expressions
LET scores = [GET_SLICE_PROP(n._internal_id, 'rank') | n IN nodes WHERE OUT_DEGREE(n) > 5]
```

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
LET value = myMap['key']
LET name = record['name']
```

## Property Access

<p tit="Procedure Body Language"></p>

```gql
-- Node properties
LET name = node.name
LET id = node._id
LET internal = node._internal_id
LET labels = node._labels

-- Edge properties
LET weight = edge.weight
LET from = edge._from
LET to = edge._to

-- Path properties
LET len = path.length
LET nodes = path.nodes
LET edges = path.edges
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