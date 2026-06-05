# LET

## Overview

The `LET` statement allows you to define new variables and adds corresponding columns to the intermediate result table. Each variable is assigned a value using the `=` operator.

```syntax
<let statement> ::= 
  "LET" <let variable definition> [ { "," <let variable definition> }... ]

<let variable definition> ::= 
  <variable> "=" <value expression>
```

**Details**

- `LET` adds new columns to the intermediate result table without changing the number of rows.
- Re-defining an existing variable in `LET` overwrites its value.
- Variables defined in the same `LET` cannot reference each other.

## Example Graph

<center><img src="images/let-example.jpg"/></center>

Create this graph, run the following query against an empty graph:

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7}),
       (p1)-[:Cites]->(p2),
       (p2)-[:Cites]->(p3)
```

## Defining Variables

```gql
LET threshold = 7
MATCH (p:Paper) WHERE p.score > threshold
RETURN p.title, p.score - threshold
```

Result:

| p.title | p.score - threshold |
| -- | -- |
| Optimizing Queries | 2 |

## Using Queries in LET

You can assign the result of a subquery to a variable using `VALUE { ... }`:

```gql
MATCH (p:Paper)
LET avgScore = VALUE { MATCH (p2:Paper) RETURN avg(p2.score) }
FILTER p.score > avgScore
RETURN p.title, p.score
```

Result:

| p.title | p.score |
| -- | -- |
| Optimizing Queries | 9 |

## Referencing Variables in LET

If any variable is referenced in `LET`, it will be evaluated it row by row.

This query references `x` in `LET` and determines whether its `score` property is greater than 7:

```gql
MATCH (x:Paper)
LET recommended = x.score > 7
RETURN x.title, recommended
```

It is equivalent to:

```gql
MATCH (x:Paper)
CALL (x) {
  LET recommended = x.score > 7
  RETURN x, recommended
}
RETURN x.title, recommended
```

Result:

| x.title | recommended |
| -- | -- |
| Optimizing Queries | true |
| Efficient Graph Search | false |
| Path Patterns | false |