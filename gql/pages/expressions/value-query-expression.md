# Value Query Expression

The value query expression allows you to specify a scalar value derived from a nested query specification. The output of this expression is expected to be either a single value or `null`.

<p tit="Syntax"></p>

```
<value query expression> ::= "VALUE" "{" <query> "}"
```

**Details**

- The `<query>` must conclude with a result statement that adheres to the following requirements:
  - Must include a `RETURN` statement with a single return item, and must not contain `GROUP BY`.
  - The return item in the `RETURN` statement must either utilize an aggregation function or explicitly include `LIMIT 1`. If neither is specified, `LIMIT 1` will be implicitly applied to ensure only a single result is returned.

## Example Graph

<div align=center drawio-diagram='19567' drawio-name="draw_f63d47fa3ab24298bbe4f596ec2cb349.jpg"><img src="https://img.ultipa.cn/draw/draw_f63d47fa3ab24298bbe4f596ec2cb349.jpg?v='1732517313170'"/></div>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7}),
       (p1)-[:Cites]->(p2),
       (p2)-[:Cites]->(p3)
```

## Examples

```gql
LET avgScore = VALUE {MATCH (n) RETURN avg(n.score)}
MATCH (n) WHERE n.score > avgScore
RETURN n.title
```

Result:

| n.title |
| -- |
| Optimizing Queries |