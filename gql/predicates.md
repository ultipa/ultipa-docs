# Predicates

A predicate specifies a condition that can be evaluated to give a boolean value (`true` or `false`).

## All Predicates

| <div table-width="30">Category</div> | Predicates |
| -- | -- |
| <a href="#Comparison-Predicates">Comparison Predicates</a> | `=`, `<>` (or `!=`), `>`, `<`, `>=`, `<=`, `=~` (or `REGEXP`), `BETWEEN` |
| <a href="#Exists-Predicate">Exists Predicate</a> | `EXISTS` |
| <a href="#Null-Predicates">Null Predicates</a> | `IS NULL`, `IS NOT NULL` |
| <a href="#Labeled-Predicates">Labeled Predicates</a> | `IS LABELED`, `IS NOT LABELED`, `:` |
| <a href="#Value-Type-Predicates">Value Type Predicates</a> | `IS TYPED`, `IS NOT TYPED` |
| <a href="#Directed-Predicate">Directed Predicate</a> | `IS DIRECTED`, `IS NOT DIRECTED` |

## Comparison Predicates

Compares two values or expressions and returns true or false. GQL supports the following comparison operators:

- Equal to: `=`
- Not equal to: `<>` (or `!=`)
- Greater than: `>`
- Less than: `<`
- Greater than or equal to: `>=`
- Less than or equal to: `<=`
- Regular match: `=~` (or `REGEXP`)
- Range check: `BETWEEN ... AND`, `NOT BETWEEN ... AND`

The `>`, `<`, `>=`, and `<=` can be used only with numeric, textual, temporal, boolean, and `null` values.

```gql
MATCH (n:Paper)
WHERE n.score BETWEEN 6 AND 8 // equivalent to: n.score >= 6 AND n.score <= 8
RETURN n.title, n.score
```

```gql
MATCH (n:Paper)
WHERE n.score NOT BETWEEN 6 AND 8 // equivalent to: n.score < 6 OR n.score > 8
RETURN n.title, n.score
```

```gql
LET email = "johndoe@gmail.com"
RETURN email =~ "[a-zA-Z0-9_.-]+@[a-zA-Z0-9]+\.(com|cn)" // true
```

```gql
LET email = "johndoe@gmail.com"
RETURN email REGEXP "[a-zA-Z0-9_.-]+@[a-zA-Z0-9]+\.(com|cn)" // true
```

### Comparing Numeric Values 

```gql
RETURN 30.1 > 30 // true
```

### Comparing Textual Values

The first differing character (from left to right) determines the result of the comparison. The characters are compared based on their Unicode values.

```gql
RETURN "campus" < "camera" // false
```

This query returns `false` because the first differing character, `p`, has a higher Unicode value than `e` (Unicode of `p` is `112`, while `e` is `101`).

```gql
LET email = "johndoe@gmail.com"
RETURN email =~ "[a-zA-Z0-9_.-]+@[a-zA-Z0-9]+\.(com|cn)" // true
```

### Comparing Temporal Values

Temporal values are treated like numeric values, as time is measured in units such as seconds, hours, days, and years. In GQL, the comparison between two temporal values is based on their duration—the difference between the two points in time. If the duration is 0, the values are equal; if negative, the left value is smaller; otherwise, the left value is greater.

```gql
RETURN date("1897-10-01") < date("1987-10-02") // true
```

### Comparing List Values

Two lists are considered equal if they contain the same elements in the exact same order.

```gql
RETURN [1,2,3] = [1,2,3],  // true
       [] = [],            // true
       [1,2,3] = [1,3,2]   // false
```

### Comparing Records

Two records are considered equal if they have the same fields with identical values.

```gql
RETURN {a:1, b:2} = {a:1, b:2},  // true
       {a:1, b:2} = {a:2, b:2},  // false
       {a:1} = {b:1}             // false
```

### Comparing Nodes/Edges/Paths

Two nodes or edges are equal if they have the same `_id`.

```gql
MATCH (n1 {_id: "P1"}), (n2 {_id: "P1"}), (n3 {_id: "P3"})
RETURN n1 = n2, n1=n3 // true, false
```

Paths are similar to lists, as they consist of sequences of nodes and edges.

### Cross-Type Comparisons

Comparisons between different type categories (e.g., string vs. number, boolean vs. integer) are not supported. Values must be of the same type or within the same category (e.g., integer and float) to be compared. Use explicit conversion functions like `cast()` when needed.

<p tit="GQL - Error">

```gql
RETURN "42" > 10 // cannot compare STRING with INTEGER
```

## Exists Predicate

The `EXISTS` predicate evaluates whether a specified subquery returns any results. If it finds matching data, the predicate evaluates to true; otherwise, it evaluates to false.

```syntax
<exists predicate> ::= "EXISTS" "{" <query> "}"
```

The `<query>` must contain at least one statement (e.g., `MATCH`). A `RETURN` statement is not required as `EXISTS` only checks whether the subquery produces any rows.

Checks whether any path originating from node `P1` exists in the graph:

```gql
RETURN EXISTS {
  MATCH ({_id: "P1"})->()
}
```

`EXISTS` can also be used in the `WHERE` clause of a `MATCH` statement. Variables from the outer query are accessible inside the subquery:

```gql
MATCH (n:Paper)
WHERE n.score > 7 AND EXISTS { MATCH (n)<-[:Cites]-() }
RETURN n.title
```

## Null Predicates

Specifies a test for a `null` value. GQL supports the following null predicates:

- `IS NULL` (or `IS UNKNOWN`)
- `IS NOT NULL` (or `IS NOT UNKNOWN`)

```gql
MATCH (n:Paper)
WHERE n.publisher IS NOT NULL
RETURN n
```

## Labeled Predicates

Determines whether a graph element satisfies a label expression. GQL supports the following labeled predicates:

- `IS LABELED`
- `IS NOT LABELED`
- `:`

```gql
MATCH (n) WHERE n IS NOT LABELED Paper
RETURN n
```

```gql
MATCH (n) WHERE n:Paper
RETURN n
```

## Value Type Predicates

Determines whether a value conforms to a specific type. GQL supports the following value type predicates:

- `IS TYPED`
- `IS NOT TYPED`

Supported value type keywords: `INT`/`INTEGER`, `FLOAT`, `DOUBLE`, `BOOL`/`BOOLEAN`, `STRING`, `TEXT`, `LIST`, `MAP`, `DATE`, `TIME`, `DATETIME`, `DURATION`, `PATH`, `NODE`, `EDGE`, `NULL`.

```gql
RETURN "hello" IS TYPED STRING,
       42 IS TYPED INT,
       3.14 IS TYPED FLOAT,
       [1,2] IS TYPED LIST,
       "hello" IS NOT TYPED INT
```

## Directed Predicate

Determines whether an edge is directed. GQL supports the following directed predicates:

- `IS DIRECTED`
- `IS NOT DIRECTED`

```gql
MATCH ()-[r]->()
WHERE r IS DIRECTED
RETURN r
```

> All edges in GQLDB are stored as directed (with a source and target). `IS DIRECTED` always evaluates to `true` for an edge value, and `IS NOT DIRECTED` always to `false`. The predicates are kept for GQL-standard conformance; undirectedness in GQLDB lives at the pattern level (e.g. `-[r]-` matches an edge in either direction) and in algorithm semantics, not on the stored edge itself.