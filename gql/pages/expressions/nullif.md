# NULLIF

The `NULLIF` expression is a conditional expression that compares two values and returns `null` if they are equal; otherwise, it returns the first value. It is often used to handle cases where specific values should be treated as `null`, which can be helpful for conditional data cleansing or handling default values.

<p tit="Syntax"></p>

```gql
<nullif expression> ::=
  "NULLIF" "(" <value expression> "," <value expression> ")"
```

The `NULLIF(V1, V2)` expression is equivalent to the following <a href="/docs/gql/case">`CASE`</a> expression:

<p tit="CASE Expression"></p>

```gql
CASE
  WHEN V1 = V2 THEN NULL
  ELSE V1
END
```

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='17503' drawio-name='draw_22fa34b5e90d4ab0b8d5329265a00004.jpg'><img src="https://img.ultipa.cn/draw/draw_22fa34b5e90d4ab0b8d5329265a00004.jpg?v='1728716974864'"/></div>

To create this graph, run the following query against an empty graph:

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
    Paper ({title string, score int32, author string, publisher string})
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
    Cites ()-[{weight int32}]->()
};
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex', publisher:'PulsePress'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack', publisher:'BrightLeaf'}),
       (p1)-[:Cites {weight:2}]->(p2),
       (p2)-[:Cites {weight:1}]->(p3)
```

## Example

```gql
MATCH (n:Paper)
RETURN n.title, NULLIF(n.author, "Alex")
```

Result:

| n.title | NULLIF(n.author, "Alex") |
| -- | -- |
| Efficient Graph Search | `null` |
| Optimizing Queries | `null` |
| Path Patterns | Zack |
