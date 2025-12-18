# Expressions

## CASE

The `CASE` expression is a conditional expression that allows you to evaluate one or more conditions and return different results based on those conditions.

GQL supports two forms of the `CASE` expression: 

- <a href="#Simple-CASE">Simple CASE</a>
- <a href="#General-CASE">General CASE</a>

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='17246' drawio-name='draw_f488b7dd47684069a6a187a919ad9667.jpg'><img src="https://img.ultipa.cn/draw/draw_f488b7dd47684069a6a187a919ad9667.jpg?v='1728532237619'"/></div>

To create this graph, run the following query against an empty graph:

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex', publisher:'PulsePress'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack', publisher:'BrightLeaf'}),
       (p1)-[:Cites {weight:2}]->(p2),
       (p2)-[:Cites {weight:1}]->(p3)
```
  
## Simple CASE

The simple `CASE` expression evaluates a single value against multiple possible values, returning the result associated with the first matching value.

<p tit="Syntax"></p>

```gql
<simple case> ::=
  "CASE" <case operand> 
    "WHEN" <when operand list> "THEN" <result>
    [ { "WHEN" <when operand list> "THEN" <result> }... ]
    [ "ELSE" <result> ]
  "END"
     
<when operand list> ::= <when operand> [ { "," <when operand> }... ]
```

**Details**

- `<case operand>` is an expression such as a variable reference, an aggregate function, etc.
- Execution Flow:
  - The `<case operand>` is compared sequentially against each `<when operand list>`.
  - If a `<when operand list>` matches `<case operand>`, the corresponding `<result>` is returned.
  - If no matches are found, returns the `<result>` specified by the `ELSE` clause. If `ELSE` is omitted, `null` is returned by default.
- When the `<when operand list>` contains multiple `<when operand>`s, if any `<when operand>` evaluates to true, the `<when operand list>` is considered true.
- The `<when operand>` can explicitly include operators such as `=`, `<>`, `>`, `<`, `>=`, `<=`, `IS NULL`, `IS NOT NULL`, etc. The `=` is implicitly used when no operator but only a constant is specified.

```gql
MATCH (n:Paper WHERE n.score > 6)
RETURN CASE count(n) WHEN 3 THEN "Y" ELSE "N" END AS result
```
  
Result:
  
| result |
| -- |
| N |  
  
```gql
MATCH (n:Paper)
RETURN n.title, n.score,
CASE n.score 
  WHEN <7 THEN "Low"
  WHEN 7,8 THEN "Medium"
ELSE "High" END AS scoreLevel
```

Result:

| n.title | n.socre | scoreLevel |
| -- | -- | -- |
| Efficient Graph Search | 6 | Low |
| Optimizing Queries | 9 | High |
| Path Patterns | 7 | Medium |

```gql
MATCH (n:Paper)
RETURN n.title,
CASE n.publisher 
  WHEN IS NULL THEN "Unknown"
ELSE n.publisher END AS Publisher
```

Result:

| n.title | Publisher |
| -- | -- |
| Efficient Graph Search | PulsePress |
| Optimizing Queries | Unknown |
| Path Patterns | BrightLeaf |

## General CASE

The general `CASE` expression evaluates multiple conditions, returning the result associated with the first condition that evaluates to true.

<p tit="Syntax"></p>

```gql
<general case> ::=
  "CASE"
    "WHEN" <condition> "THEN" <result>
    [ { "WHEN" <condition> "THEN" <result> }... ]
    [ "ELSE" <result> ]
  "END"
```

**Details**

- The `<condition>` is a boolean value expression that evaluates to true or false.
- Execution Flow:
  - The `<condition>`s are evaluated sequentially.
  - When a `<condition>` evaluates to true, the corresponding `<result>` is returned immediately.
  - If no `<condition>`s are true, returns the `<result>` specified by the `ELSE` clause. If `ELSE` is omitted, `null` is returned by default.

```gql
MATCH (n:Paper)
RETURN n.title,
CASE
  WHEN n.publisher IS NULL THEN "Publisher N/A"
  WHEN n.score < 7 THEN -1
  ELSE n.author
END AS note
```
  
Result:
  
| n.title | note |
| -- | -- |
| Optimizing Queries | Publisher N/A |
| Efficient Graph Search | -1 |
| Path Patterns | Zack |
## NULLIF

The `NULLIF` expression is a conditional expression that compares two values and returns `null` if they are equal; otherwise, it returns the first value. It is often used to handle cases where specific values should be treated as `null`, which can be helpful for conditional data cleansing or handling default values.

<p tit="Syntax"></p>

```gql
<nullif expression> ::= 
  "NULLIF" "(" <value expression> "," <value expression> ")"
```

The `NULLIF(V1, V2)` expression is equivalent to the following <a href="https://www.ultipa.com/document/gql/case">`CASE`</a> expression:

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
## COALESCE

The `COALESCE` expression is a conditional expression that returns the first non-null value from a list of provided expressions. This is useful for substituting a default value when encountering null values, especially in scenarios where you want to avoid null results in calculations or display.

<p tit="Syntax"></p>

```gql
<coalesce expression> ::= 
  "COALESCE" "(" <value expression> { "," <value expression> }... ")"
```

The `COALESCE(V1, V2, V3)` expression is equivalent to the following <a href="https://www.ultipa.com/document/gql/case">`CASE`</a> expression:

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
## LET Value Expression

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
## Value Query Expression

The value query expression allows you to specify a scalar value derived from a nested query specification. The output of this expression is expected to be either a single value or `null`.

<p tit="Syntax"></p>

```gql
<value query expression> ::= "VALUE" <nested query specification>
   
<nested query specification> ::= "{" <query specification> "}"
```

**Details**

- The query specification must conclude with a result statement that adheres to the following requirements:
  - Must include a `RETURN` statement with a single return item, and must not contain a `GROUP BY` clause.
  - The return item in the `RETURN` statement must either utilize an aggregation function or explicitly include `LIMIT 1`. If neither is specified, `LIMIT 1` will be implicitly applied to ensure only a single result is returned.

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='19567' drawio-name="draw_f63d47fa3ab24298bbe4f596ec2cb349.jpg"><img src="https://img.ultipa.cn/draw/draw_f63d47fa3ab24298bbe4f596ec2cb349.jpg?v='1732517313170'"/></div>

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
LET avgScore = VALUE {MATCH (n) RETURN avg(n.score)}
MATCH (n) WHERE n.score > avgScore
RETURN n.title
```

Result:

| n.title |
| -- |
| Optimizing Queries |
| Path Patterns |
null
