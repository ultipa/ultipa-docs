## MATCH

## Overview

The `MATCH` statement allows you to specify a <a target="blank" href="https://www.ultipa.com/docs/gql/graph-pattern-matching">graph pattern</a> to search for in the graph. It is the fundamental statement for retrieving data from the graph database and binding them to variables for use in subsequent parts of the query. 

## Example Graph

<div align=center drawio-diagram='16819' drawio-name="draw_424cccded4bd4528afeef4a4f514e0a8.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_424cccded4bd4528afeef4a4f514e0a8.jpg?v='1751440637006'"/></div>

<div tab="code">

<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph { 
  NODE User ({name string}),
  NODE Club ({since uint32}),
  EDGE Follows ()-[{createdOn date}]->(),
  EDGE Joins ()-[{memberNo uint32}]->()
}
```

<p tit="Insert data to the graph"></p>

```gql
INSERT (rowlock:User {_id: 'U01', name: 'rowlock'}),
       (brainy:User {_id: 'U02', name: 'Brainy'}),
       (purplechalk:User {_id: 'U03', name: 'purplechalk'}),
       (mochaeach:User {_id: 'U04', name: 'mochaeach'}),
       (lionbower:User {_id: 'U05', name: 'lionbower'}),
       (c01:Club {_id: 'C01', since: 2005}),
       (c02:Club {_id: 'C02', since: 2005}),
       (rowlock)-[:Follows {createdOn: '2024-01-05'}]->(brainy),
       (mochaeach)-[:Follows {createdOn: '2024-02-10'}]->(brainy),
       (brainy)-[:Follows {createdOn: '2024-02-01'}]->(purplechalk),
       (purplechalk)-[:Follows {createdOn: '2024-05-03'}]->(lionbower),
       (brainy)-[:Joins {memberNo: 1}]->(c01),
       (lionbower)-[:Joins {memberNo: 2}]->(c01),
       (mochaeach)-[:Joins {memberNo: 9}]->(c02)
```

</div>

## Matching All Nodes

```gql
MATCH (n)
RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U05 | <span style="color: #999;">Sys-gen</span> | User | {name: "lionbower"} |
| U04 | <span style="color: #999;">Sys-gen</span> | User | {name: "mochaeach"} |
| U03 | <span style="color: #999;">Sys-gen</span> | User | {name: "purplechalk"} |
| U02 | <span style="color: #999;">Sys-gen</span> | User | {name: "Brainy"} |
| U01 | <span style="color: #999;">Sys-gen</span> | User | {name: "rowlock"} |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |

## Matching All Edges

```gql
MATCH ()-[e]->()
RETURN e
```

Result: `e`

| <div table-width="9">_uuid</div> | <div table-width="6">_from</div> | <div table-width="5">_to</div> | <div table-width="12">_from_uuid</div> | <div table-width="10">_to_uuid</div> | <div table-width="10">schema</div> | values |
| -- | -- | -- | -- | -- | -- | -- |
| <span style="color: #999;">Sys-gen</span> | U01 | U02 | <span style="color: #999;">UUID of U01</span> | <span style="color: #999;">UUID of U02</span> | Follows | {createdOn: "2024-01-05" } |
| <span style="color: #999;">Sys-gen</span> | U02 | U03 | <span style="color: #999;">UUID of U02</span> | <span style="color: #999;">UUID of U03</span> | Follows | {createdOn: "2024-02-01"} |
| <span style="color: #999;">Sys-gen</span> | U03 | U05 | <span style="color: #999;">UUID of U03</span> | <span style="color: #999;">UUID of U05</span> | Follows | {createdOn: "2024-05-03"} |
| <span style="color: #999;">Sys-gen</span> | U04 | U02 | <span style="color: #999;">UUID of U04</span> | <span style="color: #999;">UUID of U02</span> | Follows | {createdOn: "2024-02-10"} |
| <span style="color: #999;">Sys-gen</span> | U02 | C01 | <span style="color: #999;">UUID of U02</span> | <span style="color: #999;">UUID of C01</span> | Joins | {memberNo: 1} |
| <span style="color: #999;">Sys-gen</span> | U05 | C01 | <span style="color: #999;">UUID of U05</span> | <span style="color: #999;">UUID of C01</span> | Joins | {memberNo: 2} |
| <span style="color: #999;">Sys-gen</span> | U04 | C02 | <span style="color: #999;">UUID of U04</span> | <span style="color: #999;">UUID of C02</span> | Joins | {memberNo: 9} |

Notice that if you don't specifiy the edge direction,  either as outgoing or incoming, each edge in the graph will be returned twice, as two paths are considered distinct when their element sequences differ, i.e., `(n1)-[e]->(n2)` and `(n2)<-[e]-(n1)` are different paths.

<p tit="GQL - Each edge will be returned twice"></p>

```gql
MATCH ()-[e]-()
RETURN e
```

## Matching with Labels/Schema

Both node pattern and edge pattern support the <a target="blank" href="https://www.ultipa.com/docs/gql/node-and-edge-patterns#Label/Schema-Expression">label/schema expression</a> to specify schemas (in typed graphs) or labels (in open graphs).

To retrieve all `Club` nodes:

```gql
MATCH (n:Club)
RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |

To retrieve all nodes connected to `Brainy` with `Follows` or `Joins` edges:

```gql
MATCH (:User {name: 'Brainy'})-[:Follows|Joins]-(n)
RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U03 | <span style="color: #999;">Sys-gen</span> | User | {name: "purplechalk"} |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |

## Matching with Property Specification

<a target="blank" href="https://www.ultipa.com/docs/gql/node-and-edge-patterns#Property-Specification">Property specification</a> can be included in node and edge patterns to apply **joint equalities** to filter nodes and edges with key-value pairs.

To retrieve `Club` nodes whose `_id` and `since` have specific values:    

```gql
MATCH (n:Club {_id: 'C01', since: 2005})
RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |

To retrieve the name of the member of club `C01` whose `memberNo` is 1:

```gql
MATCH (:Club {_id: 'C01'})<-[:Joins {memberNo: 1}]-(n)
RETURN n.name
```

Result: `n`

| n.name |
| -- |
| Brainy |

## Matching with Abbreviated Edges

You can use <a target="_blank" href="https://www.ultipa.com/docs/gql/node-and-edge-patterns#Abbreviated-Edge-Pattern">abbreviated edge patterns</a> when you do not need to filter edges or assign them to a variable. Even with the abbreviated form, you may still specify the direction of the edge when necessary.

To retrieve nodes connected with `mochaeach` with any outgoing edges:

```gql
MATCH (:User {name: 'mochaeach'})->(n)
RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U02 | <span style="color: #999;">Sys-gen</span> | User | {name: "Brainy"} |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |

## Matching Paths

To retrieve users followed by `mochaeach`, and the clubs joined by those users:

```gql
MATCH p = (:User {name: 'mochaeach'})-[:Follows]->(:User)-[:Joins]->(:Club)
RETURN p
```

Result: `p`

<div align=center drawio-diagram='17009' drawio-name="draw_cb84c2f9b0934edcb3fa1028b8285232.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_cb84c2f9b0934edcb3fa1028b8285232.jpg?v='1751440836394'"/></div>

## Matching with WHERE Clauses

The `WHERE` clause can be used within an element pattern (node or edge pattern), a parenthesized path pattern, or immediately after a graph pattern in the `MATCH` statement to specify various search conditions.

### Element Pattern WHERE Clause

To retrieve 1-step paths with outgoing `Follows` edges, where their `createdOn` values are greater than a specified date:  

```gql
MATCH p = ()-[e:Follows WHERE e.createdOn > '2024-04-01']->()
RETURN p
```

Result: `p`

<div align=center drawio-diagram='17010' drawio-name="draw_b8d0a6bf849d4425bdfaf2c01aaa92cf.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_b8d0a6bf849d4425bdfaf2c01aaa92cf.jpg?v='1751440899521'"/></div>

### Parenthesized Path Pattern WHERE Clause

To retrieve one- or two-step paths containing outgoing `Follows` edges, where their `createdOn` values are smaller than a specified value:

```gql
MATCH p = (()-[e:Follows]->() WHERE e.createdOn < "2024-02-05"){1,2}
RETURN p
```

Result: `p`

<div align=center drawio-diagram='17011' drawio-name="draw_82881fe33fb6492b86e5fc3927023a76.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_82881fe33fb6492b86e5fc3927023a76.jpg?v='1751441025693'"/></div>

### Graph Pattern WHERE Clause

To retrieve members of club `C01` whose `memberNo` is greater than 1:

```gql
MATCH (c:Club)<-[e:Joins]->(n)
WHERE c._id = 'C01' AND e.memberNo > 1
RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U05 | <span style="color: #999;">Sys-gen</span> | User | {name: "lionbower"} |

## Matching Quantified Paths

A <a target="_blank" href="https://www.ultipa.com/docs/gql/quantified-paths">quantified path</a> is a variable-length path where the complete path or a part of it is repeated a specified number of times.

To retrieve distinct nodes related to `lionbower` in 1 to 3 hops:

```gql
MATCH (:User {name: 'lionbower'})-[]-{1,3}(n)
RETURN collect_list(DISTINCT n._id) AS IDs
```

Result: 

| IDs |
| -- |
| ["C01","U01","U02","U03","U04"] |

To retrieve paths that begin with one- or two-step subpaths containing `Follows` edges, where their `createdOn` values are greater than a specified value, and these subpaths must connect to node `C01`:

```gql
MATCH p = (()-[e:Follows]->() WHERE e.createdOn > "2024-01-31"){1,2}()-({_id:"C01"})
RETURN p
```

Result: `p`

<div align=center drawio-diagram='17013' drawio-name="draw_3ac0889a47e8431383481910dddb5772.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_3ac0889a47e8431383481910dddb5772.jpg?v='1751441119734'"/></div>

## Matching Shortest Paths

A <a target="_blank" href="https://www.ultipa.com/docs/gql/shortest-paths">shortest paths</a> between two nodes are the paths that has the fewest edges.

To retrieve all the shortest paths between `lionbower` and `purplechalk` within 5 hops:

```gql
MATCH p = ALL SHORTEST (n1:User)-[]-{,5}(n2:User)
WHERE n1.name = 'lionbower' AND n2.name = 'purplechalk'
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20306' drawio-name="draw_1291039e2d5c466aaaa75fe99f1de2f5.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_1291039e2d5c466aaaa75fe99f1de2f5.jpg?v='1751441157706'"/></div>

## Matching Multiple Paths

When a `MATCH` statement contains multiple path patterns, each pattern is matched independently against the graph to produce its own result set. These result sets are then combined by performing an **equi-join** on the shared node or edge variables.

To retrieve users who joined club `C02` and also follow `Brainy`:

```gql
MATCH (u)-[:Joins]->(:Club {_id: 'C02'}), (u)-[:Follows]->(:User {name: 'Brainy'})
RETURN u
```

Result: `u`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U04 | <span style="color: #999;">Sys-gen</span> | User | {name: "mochaeach"} |

The above query is equivalent to the following using two `MATCH`s:

```gql
MATCH (u)-[:Joins]->(:Club {_id: 'C02'})
MATCH (u)-[:Follows]->(:User {name: 'Brainy'})
RETURN u
```

If the path patterns share no common variables, the result sets are combined using a **Cartesian product** — a behavior that is usually undesired. For example,

```gql
MATCH (c:Club), (u:User)-[f:Follows WHERE f.createdOn > '2024-02-01']->()
RETURN c._id, u.name
```

Result:

| c.\_id | u.name |
| -- | -- |
| C02 | mochaeach |
| C02 | purplechalk |
| C01 | mochaeach |
| C01 | purplechalk |

## MATCH YIELD

The `YIELD` clause can be used to select specific node, edge, or path variables from the `MATCH` statement, making them accessible for reference in subsequent parts of the query. Variables not selected with `YIELD` will no longer be available. If the `YIELD` clause is omitted, all variables are passed through by default.

This query only returns `c`, as `n` is not involved in `YIELD`:

```gql
MATCH (n:User)-[:Joins]->(c:Club)
YIELD c
RETURN *
```

Result: `c`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |

This query returns `n1` and `e`, `n2` is not included:

```gql
MATCH (n1:Club)
MATCH (n2:Club)<-[e:Joins WHERE e.memberNo < 3]-() YIELD e
RETURN *
```

`n1`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | {since: 2005} |

`e`

| <div table-width="9">_uuid</div> | <div table-width="6">_from</div> | <div table-width="5">_to</div> | <div table-width="14">_from_uuid</div> | <div table-width="14">_to_uuid</div> | <div table-width="10">schema</div> | values |
| -- | -- | -- | -- | -- | -- | -- |
| <span style="color: #999;">Sys-gen</span> | U02 | C01 | <span style="color: #999;">UUID of U02</span> | <span style="color: #999;">UUID of C01</span> | Joins | {memberNo: 1} |
| <span style="color: #999;">Sys-gen</span> | U02 | C01 | <span style="color: #999;">UUID of U02</span> | <span style="color: #999;">UUID of C01</span> | Joins | {memberNo: 1} |
| <span style="color: #999;">Sys-gen</span> | U05 | C01 | <span style="color: #999;">UUID of U05</span> | <span style="color: #999;">UUID of C01</span> | Joins | {memberNo: 2} |
| <span style="color: #999;">Sys-gen</span> | U05 | C01 | <span style="color: #999;">UUID of U05</span> | <span style="color: #999;">UUID of C01</span> | Joins | {memberNo: 2} |

This query throws syntax error since `n2` is not selected in the `YIELD` clause, thus it cannot be accessed by the `RETURN` statement:

<p tit="GQL - Syntax Error"></p>

```gql
MATCH (n1:User), (n2:Club)
YIELD n1
RETURN n1, n2
```
