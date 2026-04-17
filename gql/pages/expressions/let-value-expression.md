# LET Value Expression

The LET value expression allows you to define variables and use them immediately in an expression. It can be used for improving readability and simplifying more complex expressions.

<p tit="Syntax"></p>

```gql
<let value expression> ::=
 "LET" <let variable definition list> "IN" <value expression> "END"

<let variable definition list> ::=
  <let variable definition> [ { "," <let variable definition> }... ]

<let variable definition> ::= <binding variable> "=" <value expression>
```

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='17526' drawio-name="draw_f21555f32dd3458395ec106fe00b0ea2.jpg"><img src="https://img.ultipa.cn/draw/draw_f21555f32dd3458395ec106fe00b0ea2.jpg?v='1732517414371'"/></div>

To create this graph, run the following query against an empty graph:

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7}),
       (p1)-[:Cites]->(p2),
       (p2)-[:Cites]->(p3)
```

## Examples

```gql
RETURN LET x = 2, y = 1 IN x^2+y END AS result
```

Result:

| result |
| -- |
| 5 |

```gql
MATCH (n:Paper)
RETURN n.title, LET plus = 1 IN n.score + plus END AS newScore
```

Result:

| n.title | newScore |
| -- | -- |
| Optimizing Queries | 10 |
| Efficient Graph Search | 7 |
| Path Patterns | 8 |
