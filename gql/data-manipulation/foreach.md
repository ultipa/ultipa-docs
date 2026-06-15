# FOREACH

## Overview

The `FOREACH` statement iterates over a list and runs a write block once for each element.

> For row-by-row reading without writes, use the <a target="_blank" href="/docs/gql/for">`FOR`</a> statement instead. `FOR` unnests a list into rows of the intermediate result table; `FOREACH` does not produce rows and only performs side effects.

```syntax
<foreach statement> ::=
  "FOREACH" "(" <variable> "IN" <list value expression> "|" <foreach body> ")"

<foreach body> ::= <write statement> [ <write statement> ]...
```

**Details**

- `<variable>` is bound to each element of `<list value expression>` in turn.
- The body must consist of write statements: `INSERT`, `MERGE`, `SET`, `REMOVE`, `DELETE`, or a nested `FOREACH`.

## Iterating a Literal List

Insert one `Person` node for each name in the list:

```gql
FOREACH (name IN ['Alice', 'Bob', 'Carol'] |
  INSERT (:Person {name: name})
)
```

## Iterating a Range

Combined with the `range()` function, `FOREACH` can create a fixed number of related entities:

```gql
MATCH (start:Person {name: 'Alice'})
FOREACH (i IN range(1, 5) |
  MERGE (start)-[:Step {order: i}]->(:Checkpoint {num: i})
)
```

This creates checkpoints `1` through `5` and connects each one to `Alice` through a `Step` edge whose `order` equals the loop counter:

<center><img src="images/foreach-1.drawio.svg"></center>

## Iterating a List of Records

Each element can be a record. Reference its fields with the dot operator:

```gql
FOREACH (item IN [{name: 'Alice', age: 30}, {name: 'Bob', age: 25}] |
  MERGE (p:Person {name: item.name})
  ON MATCH SET p.age = item.age
)
```

## Updating Bound Variables

`FOREACH` can run after a `MATCH` to apply per-iteration updates to bound variables.

```gql
MATCH (p:Person {name: 'Alice'})
FOREACH (tag IN ['active', 'verified'] |
  SET p.tags = coalesce(p.tags, []) + [tag]
)
```

Use `coalesce()` to handle the case where the property does not yet exist. Without it, `p.tags + [tag]` evaluates to `null` on the first iteration and the assignment leaves `p.tags` unset. After the loop, `tags` of `Alice` is `['active', 'verified']`.

## Nested FOREACH

`FOREACH` blocks may be nested. The following statement creates one `Team` node per `(department, level)` pair:

```gql
FOREACH (dept IN ['Engineering', 'Sales'] |
  FOREACH (level IN [1, 2, 3] |
    MERGE (:Team {department: dept, level: level})
  )
)
```

The Cartesian product of the two lists produces 6 `Team` nodes:

| department | level |
| -- | -- |
| Engineering | 1 |
| Engineering | 2 |
| Engineering | 3 |
| Sales | 1 |
| Sales | 2 |
| Sales | 3 |
