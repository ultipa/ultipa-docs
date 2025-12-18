## RETURN

## Overview

The `RETURN` statement allows you to specify items to include in the query result. Each item is defined by an expression that can include variables, properties, functions, constants, etc.

<p tit="Syntax"></p>

```gql
<return statement> ::= 
  "RETURN" [ "DISTINCT" | "ALL" ] { <"*"> | <return items> } [ <group by clause> ]
                          
<return items> ::= 
  <return item> [ { "," <return item> }... ]

<return item> ::= 
  <value expression> [ "AS" <identifier> ]
  
<group by clause> ::= 
  "GROUP BY" <grouping key> [ { "," <grouping key> }... ]
```

**Details**

- The asterisk `*` returns all columns in the intermediate result table. See <a href="#Returning-All">Returning All</a>.
- The keyword `AS` can be used to rename a return item. See <a href="#Return-Item-Alias">Return Item Alias</a>.
- The `RETURN` statement supports the `GROUP BY` clause. See <a href="#Returning-with-Grouping">Returning with Grouping</a>.
- The `DISTINCT` operator can be used to deduplicate records. If neither `DISTINCT` nor `ALL` is specified, `ALL` is implicitly applied. See <a href="#Returning-Distinct-Records">Returning Distinct Records</a>.

## Example Graph

<div align=center drawio-diagram='15735' drawio-name="draw_1ba1d5628722444894a94a69c1b18d8c.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_1ba1d5628722444894a94a69c1b18d8c.jpg?v='1738726313830'"/></div>

<div tab="code">
  
<p tit="Create this graph"></p>

```gql
CREATE GRAPH myGraph { 
  NODE Student ({name string, gender string}),
  NODE Course ({name string, credit uint32}),
  EDGE Take ()-[{year uint32, term string}]->()
} PARTITION BY HASH(Crc32) SHARDS [1]
```

<p tit="Insert data to the graph"></p> 

```gql
INSERT (alex:Student {_id: 's1', name: 'Alex', gender: 'male'}),
       (susan:Student {_id: 's2', name: 'Susan', gender: 'female'}),
       (art:Course {_id: 'c1', name: 'Art', credit: 13}),
       (literature:Course {_id: 'c2', name: 'Literature', credit: 15}),
       (alex)-[:Take {year: 2024, term: 'Spring'}]->(art),
       (susan)-[:Take {year: 2023, term: 'Fall'}]->(art),
       (susan)-[:Take {year: 2023, term: 'Spring'}]->(literature)
```

</div>

## Returning Nodes

A variable bound to nodes returns all information about each node.

```gql
MATCH (n:Course)
RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| c1 | <span style="color: #999;">Sys-gen</span> | Course | {name: "Art", credit: 13} |
| c2 | <span style="color: #999;">Sys-gen</span> | Course | {name: "Literature", credit: 15} |

## Returning Edges

A variable bound to edges returns all information about each edge.

```gql
MATCH ()-[e]->()
RETURN e
```

Result: `e`

| <div table-width="9">_uuid</div> | <div table-width="6">_from</div> | <div table-width="5">_to</div> | <div table-width="12">_from_uuid</div> | <div table-width="12">_to_uuid</div> | <div table-width="10">schema</div> | values |
| -- | -- | -- | -- | -- | -- | -- |
| <span style="color: #999;">Sys-gen</span> | s2 | c1 | <span style="color: #999;">UUID of s2</span> | <span style="color: #999;">UUID of c1</span> | Take | {year: 2023, term: "Fall"} |
| <span style="color: #999;">Sys-gen</span> | s2 | c2 | <span style="color: #999;">UUID of s2</span> | <span style="color: #999;">UUID of c2</span> | Take | {year: 2023, term: "Spring"} |
| <span style="color: #999;">Sys-gen</span> | s1 | c1 | <span style="color: #999;">UUID of s1</span> | <span style="color: #999;">UUID of c1</span> | Take | {year: 2024, term: "Spring"} |

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
| Take | Course |
| Take | Course |

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

`s`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| s2 | <span style="color: #999;">Sys-gen</span> | Student | {name: "Susan", gender: "female"} |
| s2 | <span style="color: #999;">Sys-gen</span> | Student | {name: "Susan", gender: "female"} |

`c`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| c1 | <span style="color: #999;">Sys-gen</span> | Course | {name: "Art", credit: 13} |
| c2 | <span style="color: #999;">Sys-gen</span> | Course | {name: "Literature", credit: 15} |

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

## Returning with Aggregation

Aggregation functions, such as `sum()` and `max()`, can be directly applied in the `RETURN` statement. 

```gql
MATCH (:Student {name:"Susan"})-[]->(c:Course)
RETURN sum(c.credit)
```

Result:

| sum(c.credit) |
| -- |
| 28 |

Due to the use of the aggregate function, the `c` returned by this query contains only one record, as expected:

```gql
MATCH (:Student {name:"Susan"})-[]->(c:Course)
RETURN c, sum(c.credit)
```

Result:

`c`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| c1 | <span style="color: #999;">Sys-gen</span> | Course | {name: "Art", credit: 13} |

`sum(c.credit)`

| sum(c.credit) |
| -- |
| 28 |

## Returning by CASE

```gql
MATCH (n:Course)
RETURN n.name, CASE WHEN n.credit > 14 THEN "Y" ELSE "N" END AS Recommended
```

Result:

| n.name | Recommended |
| -- | -- |
| Art | N |
| Literature | Y |

## Returning Limited Records

The `LIMIT` statement can be used to restrict the number of records retained for each return item.

```gql
MATCH (n:Course)
RETURN n.name LIMIT 1
```

Result:

| n.name |
| -- |
| Art |

## Returning Ordered Records

The `ORDER BY` statement can be used to sort the records.

```gql
MATCH (n:Course)
RETURN n ORDER BY n.credit DESC
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| c2 | <span style="color: #999;">Sys-gen</span> | Course | {name: "Literature", credit: 15} |
| c1 | <span style="color: #999;">Sys-gen</span> | Course | {name: "Art", credit: 13} |

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
| 2024 | Spring |
| 2023 | Fall |

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
