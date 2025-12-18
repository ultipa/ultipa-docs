# NEXT

## Overview

The `NEXT` statement chains multiple linear or composite query statements, where the result of one query is carried forward to the next. This allows for advanced linear composition, enabling more complex queries.

<p tit="Syntax"></p>

```gql
<advanced linear composition> ::=
  <query statement> <next statement> [ { <next statement> }... ]

<next statement> ::=
  "NEXT" [ <yield clause> ] <query statement>

<query statement> ::=
  <linear query statement> | <composite query statement>
          
<yield clause> ::= 
  "YIELD" <yield item> [ { "," <yield item> }... ]

<yield item> ::=
  <column name> [ "AS" <binding variable> ]
```

**Details**

- The conclusion of each `<query statement>` must contain a `RETURN` statement, specifying the variables that can be referenced in the `<query statement>` immediately after `NEXT`.
- The `NEXT` statement supports the `YIELD` clause. See <a href="#NEXT-YIELD">NEXT YIELD</a>.

## Example Graph

<div align=center drawio-diagram='17169' drawio-name="draw_de9012b244ac483dacabd9ab09435793.jpg"><img src="https://img.ultipa.cn/draw/draw_de9012b244ac483dacabd9ab09435793.jpg?v='1727342377222'"/></div>

<div tab="code">

<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph { 
  NODE User ({name string}),
  NODE Club (),
  EDGE Follows ()-[{}]->(),
  EDGE Joins ()-[{memberNo uint32}]->()
} PARTITION BY HASH(Crc32) SHARDS [1]
```  

<p tit="Insert data to the graph"></p>

```gql
INSERT (rowlock:User {_id: 'U01', name: 'rowlock'}),
       (brainy:User {_id: 'U02', name: 'Brainy'}),
       (purplechalk:User {_id: 'U03', name: 'purplechalk'}),
       (mochaeach:User {_id: 'U04', name: 'mochaeach'}),
       (lionbower:User {_id: 'U05', name: 'lionbower'}),
       (c01:Club {_id: 'C01'}),
       (c02:Club {_id: 'C02'}),
       (rowlock)-[:Follows]->(brainy),
       (mochaeach)-[:Follows]->(brainy),
       (purplechalk)-[:Follows]->(mochaeach),
       (purplechalk)-[:Follows]->(lionbower),
       (brainy)-[:Joins {memberNo: 1}]->(c01),
       (lionbower)-[:Joins {memberNo: 2}]->(c01),
       (mochaeach)-[:Joins {memberNo: 9}]->(c02)
```

</div>

## Basic Usage

This query returns users who are members of `C01` while also followed by `U03`:

```gql
MATCH ({_id: "C01"})<-[:Joins]-(u1:User)
RETURN u1
NEXT
MATCH ({_id: "U03"})-[:Follows]->(u2:User) WHERE u2 = u1
RETURN u2
```

Result: `u2`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U05 | <span style="color: #999;">Sys-gen</span> | User | {name: "lionbower"} |

This query throws error since `name` is out of scope:

<p tit="GQL - Error Occurs"></p>

```gql
LET name = "rowlock"
RETURN name
NEXT
MATCH ({_id: "C01"})<-[:Joins]-(u:User)
RETURN u
NEXT
RETURN name IN collect_list(u.name)
```

## Using Grouped Result

This query returns the names of users who joined the club with the largest number of members:

```gql
MATCH (c:Club)<-[:Joins]-()
RETURN c, count(c) AS cnt GROUP BY c
ORDER BY cnt DESC LIMIT 1
NEXT
MATCH (c)<-[:Joins]-(u)
RETURN c._id, collect_list(u.name)
```

Result:

| c.\_id | collect_list(u.name) |
| -- | -- |
| C01 | ["Brainy","lionbower"] |

## Using Aggregated Result

This query inserts a new `Joins` edge from `U01` to `C01` and sets the `memberNo` property to the next highest value:

```gql
MATCH ({_id: "C01"})<-[e1:Joins]-()
RETURN max(e1.memberNo) AS maxNo
NEXT
MATCH (u {_id: "U01"}), (c {_id: "C01"})
INSERT (c)<-[e2:Joins {memberNo: maxNo + 1}]-(u)
RETURN e2
```

Result: `e2`

| <div table-width="9">_uuid</div> | <div table-width="6">_from</div> | <div table-width="5">_to</div> | <div table-width="15">_from_uuid</div> | <div table-width="15">_to_uuid</div> | <div table-width="8">schema</div> | values |
| -- | -- | -- | -- | -- | -- | -- |
| <span style="color: #999;">Sys-gen</span> | U01 | C01 | <span style="color: #999;">UUID of U01</span> | <span style="color: #999;">UUID of C01</span> | Joins | {memberNo: 3} |

## NEXT YIELD

The `YIELD` clause can be used to select specific variables from the previous query statement and rename them if necessary, making them accessible for reference in the next query statement. Variables not selected with `YIELD` will no longer be available. If the `YIELD` clause is omitted, all variables bound in the previous query statement are passed through by default.

This query finds clubs joined by users followed by `purplechalk`:

```gql
LET name = "purplechalk"
MATCH (:User {name: name})-[:Follows]->(u:User)
RETURN *
NEXT YIELD u
MATCH (u)-[:Joins]->(c:Club)
RETURN u.name, c._id
```

Result:

| u.name | c.\_id |
| -- | -- |
| mochaeach | C02 |
| lionbower | C01 |
null
