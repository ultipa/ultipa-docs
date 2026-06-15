# COALESCE

The `COALESCE` expression is a conditional expression that returns the first non-null value from a list of provided expressions. This is useful for substituting a default value when encountering null values, especially in scenarios where you want to avoid null results in calculations or display.

<p tit="Syntax"></p>

```gql
<coalesce expression> ::=
  "COALESCE" "(" <value expression> { "," <value expression> }... ")"
```

The `COALESCE(V1, V2, V3)` expression is equivalent to the following <a href="/docs/gql/case">`CASE`</a> expression:

<p tit="CASE Expression"></p>

```gql
CASE
  WHEN NOT V1 IS NULL THEN V1
  WHEN NOT V2 IS NULL THEN V2
  ELSE V3
END
```

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='17511' drawio-name='draw_6f2a63f541354536943f8973f25ad2cf.jpg'><img src="https://img.ultipa.cn/draw/draw_6f2a63f541354536943f8973f25ad2cf.jpg?v='1728717725703'"/></div>

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
RETURN n.title, COALESCE(n.publisher, "N/A") AS publisher
```

Result:

| n.title | publisher |
| -- | -- |
| Efficient Graph Search | PulsePress |
| Optimizing Queries | N/A |
| Path Patterns | BrightLeaf |
