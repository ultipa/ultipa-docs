# RETURN

## Overview

The `RETURN` statement allows you to specify items to include in the query result. Each item is defined by an expression that can include variables, properties, functions, constants, etc.

<p tit="Syntax"></p>

```
<return statement> ::= 
  "RETURN" [ "DISTINCT" | "ALL" ] { < "*" > | <return items> } [ <group by clause> ]
                          
<return items> ::= <return item> [ { "," <return item> }... ]

<return item> ::= <value expression> [ "AS" <identifier> ]
  
<group by clause> ::= 
  "GROUP BY" <grouping key> [ { "," <grouping key> }... ] [ <having clause> ]

<having clause> ::= "HAVING" <search condition>
```

**Details**

- The asterisk `*` returns all columns in the intermediate result table. See <a href="#Returning-All">Returning All</a>.
- The keyword `AS` can be used to rename a return item. See <a href="#Return-Item-Alias">Return Item Alias</a>.
- The `RETURN` statement supports the `GROUP BY` clause. See <a href="#Returning-with-Grouping">Returning with Grouping</a>.
- The `<having clause>` can follow `GROUP BY` to filter groups based on aggregate results. See <a href="#Filtering-Groups-with-HAVING">Filtering Groups with HAVING</a>.
- The `DISTINCT` operator can be used to deduplicate records. If neither `DISTINCT` nor `ALL` is specified, `ALL` is implicitly applied. See <a href="#Returning-Distinct-Records">Returning Distinct Records</a>.

## Example Graph

<div align=center drawio-diagram='15735' drawio-name="draw_1ba1d5628722444894a94a69c1b18d8c.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_1ba1d5628722444894a94a69c1b18d8c.jpg?v='1738726313830'"/></div>

```gql
INSERT (alex:Student {_id: 's1', name: 'Alex', gender: 'male'}),
       (susan:Student {_id: 's2', name: 'Susan', gender: 'female'}),
       (art:Course {_id: 'c1', name: 'Art', credit: 13}),
       (literature:Course {_id: 'c2', name: 'Literature', credit: 15}),
       (alex)-[:Take {year: 2024, term: 'Spring'}]->(art),
       (susan)-[:Take {year: 2023, term: 'Fall'}]->(art),
       (susan)-[:Take {year: 2023, term: 'Spring'}]->(literature)
```

## Returning Nodes

A variable bound to nodes returns all information about each node.

```gql
MATCH (n:Course)
RETURN n
```

Result:

| _id | label | name | credit |
| -- | -- | -- | -- |
| c2 | Course | Literature | 15 |
| c1 | Course | Art | 13 |

## Returning Edges

A variable bound to edges returns all information about each edge.

```gql
MATCH ()-[e]->()
RETURN e
```

Result:

| _id | _from | _to | label | year | term |
| -- | -- | -- | -- | -- | -- |
| e:3 | s2 | c2 | Take | 2023 | Spring |
| e:2 | s2 | c1 | Take | 2023 | Fall |
| e:1 | s1 | c1 | Take | 2024 | Spring |

## Returning Paths

A variable bound to paths returns all information about the nodes and edges included in each path.

```gql
MATCH p = ()-[:Take {term: "Spring"}]->()
RETURN p
```

Result: `p`

<div align=center drawio-diagram='17030' drawio-name="draw_b58ea87eac1046d4bffd03ddd1119a86.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_b58ea87eac1046d4bffd03ddd1119a86.jpg?v='1738737362935'"/></div>

## Returning Labels

The function `labels()` can be used to return the labels of nodes and edges.

```gql
MATCH ({_id: "s2"})-[e]->(n)
RETURN labels(e), labels(n)
```

Result:

| labels(e) | labels(n) |
| -- | -- |
| ["Take"] | ["Course"] |
| ["Take"] | ["Course"] |

## Returning Properties

The period operator `.` can be used to extract the value of a specified property from a variable bound to nodes or edges. The `null` value will be returned if the specified property is not found on the nodes or edges. 

```gql
MATCH (:Student {name:"Susan"})-[]->(c:Course)
RETURN c.name, c.credit, c.type
```

Result:

| c.name | c.credit | c.type |
| -- | -- | -- |
| Literature | 15 | `null` |
| Art | 13 | `null` |

## Returning All

The asterisk `*` returns all columns in the intermediate result table. Note that the `RETURN` statement cannot include the `GROUP BY` clause when using `*`. 

```gql
MATCH (s:Student {name:"Susan"})-[]->(c:Course)
RETURN *
```

Result:

<div tab="code">

<p tit="s"></p>

```json
[
  {"id": "s2", "labels": ["Student"], "properties": {"name": "Susan", "gender": "female"}},
  {"id": "s2", "labels": ["Student"], "properties": {"name": "Susan", "gender": "female"}},
]
```

<p tit="c"></p>

```json
[
   {"id": "c2", "labels": ["Course"], "properties": {"name": "Literature", "credit": 15}},
   {"id": "c1", "labels": ["Course"], "properties": {"name": "Art", "credit": 13}}
]
```

</div>

## Return Item Alias

The `AS` keyword allows you to assign an alias to a return item.

```gql
MATCH (s:Student)-[t:Take]->(c:Course)
RETURN s.name AS Student, c.name AS Course, t.year AS TakenIn
```

Result:

| Student | Course | TakenIn |
| -- | -- | -- |
| Alex | Art | 2024 |
| Susan | Art | 2023 |
| Susan | Literature | 2023 |

## Returning Limited Records

The `LIMIT` statement can be used to restrict the number of records retained for each return item.

```gql
MATCH (n:Course)
RETURN n.name LIMIT 1
```

Result:

| n.name |
| -- |
| Literature |

## Returning Ordered Records

The `ORDER BY` statement can be used to sort the records.

```gql
MATCH (n:Course)
RETURN n ORDER BY n.credit DESC
```

Result:

| _id | name | credit |
| -- | -- | -- |
| c2 | Literature | 15 |
| c1 | Art | 13 |

## Returning Computed Values

A `RETURN` item can be any value expression, not only a variable or property reference. The expression is evaluated per row and the result becomes a column in the output. Computed values cover arithmetic, function calls, string concatenation, conditional `CASE` expressions, comparisons, and any composition of these.

Arithmetic on properties:

```gql
MATCH (n:Course)
RETURN n.name, n.credit, n.credit * 2 AS double_credit
```

Result:

| n.name | n.credit | double_credit |
| -- | -- | -- |
| Art | 13 | 26 |
| Literature | 15 | 30 |

Function call on a property:

```gql
MATCH (n:Student)
RETURN n.name, upper(n.name) AS upper_name
```

Result:

| n.name | upper_name |
| -- | -- |
| Alex | ALEX |
| Susan | SUSAN |

```gql
MATCH (:Student {name:"Susan"})-[]->(c:Course)
RETURN sum(c.credit)
```

Result:

| sum(c.credit) |
| -- |
| 28 |

Comparison and conditional:

```gql
MATCH (n:Course)
RETURN n.name, CASE WHEN n.credit >= 14 THEN 'high' ELSE 'low' END AS credit_level
```

Result:

| n.name | credit_level |
| -- | -- |
| Art | low |
| Literature | high |

## Returning with Grouping

The `GROUP BY` clause allows you to specify the keys to group the query result. After grouping, each group will keep only one record.

### Grouping by One Key

```gql
MATCH ()-[e:Take]->()
RETURN e.term GROUP BY e.term
```

Result:

| e.term |
| -- |
| Spring |
| Fall |

In the GQL standard, the grouping key must be a direct variable reference, where this query must be written as `RETURN e.term AS <varName> GROUP BY <varName>`. Ultipa simplifies this by allowing direct grouping on expressions, removing the need to introduce intermediate variables.

### Grouping by Multiple Keys

```gql
MATCH ()<-[e:Take]-()
RETURN e.year, e.term GROUP BY e.year, e.term
```

Result:

| e.year | e.term |
| --  | -- |
| 2023 | Spring |
| 2023 | Fall |
| 2024 | Spring |

### Grouping and Aggregation

When grouping is applied, any aggregation operation in the `RETURN` statement is performed on each group.

This query counts the number of `Take` edges for each `Term`:

```gql
MATCH ()-[e:Take]->()
RETURN e.term, count(e) GROUP BY e.term
```

Result:

| e.term | count(e) |
| -- | -- |
| Spring | 2 |
| Fall | 1 |

### Filtering Groups with HAVING

The `HAVING` clause filters groups produced by `GROUP BY` based on aggregate results. It must follow `GROUP BY` and is evaluated after grouping and aggregation, allowing the search condition to reference aggregate functions or their aliases.

`HAVING` differs from `WHERE`/`FILTER`: `WHERE` and `FILTER` filter records before grouping and cannot reference aggregate results, while `HAVING` filters groups after aggregation.

This query returns terms in which more than one `Take` edge exists:

```gql
MATCH ()-[e:Take]->()
RETURN e.term AS term, count(e) AS cnt
GROUP BY e.term
HAVING cnt > 1
```

Result:

| term | cnt |
| -- | -- |
| Spring | 2 |

This query returns years in which the total credit of taken courses exceeds 20:

```gql
MATCH ()-[e:Take]->(c:Course)
RETURN e.year AS year, sum(c.credit) AS totalCredit
GROUP BY e.year
HAVING totalCredit > 20
```

Result:

| year | totalCredit |
| -- | -- |
| 2023 | 28 |

## Returning Distinct Records

The `DISTINCT` operator deduplicates records for all return items. When `DISTINCT` is specified, each return item is implicly an operand of a grouping operation.

```gql
MATCH ()-[e]->()
RETURN DISTINCT e.year
```

This is equivalent to:

```gql
MATCH ()-[e]->()
RETURN e.year GROUP BY e.year
```

Result: 

| e.year |
| -- |
| 2023 |
| 2024 |

```gql
MATCH ()-[e]->()
RETURN DISTINCT e.year, e.term
```

This is equivalent to:

```gql
MATCH ()-[e]->()
RETURN e.year, e.term GROUP BY e.year, e.term 
```

Result: 

| e.year | e.term |
| -- | -- |
| 2023 | Fall |
| 2023 | Spring |
| 2024 | Spring |
