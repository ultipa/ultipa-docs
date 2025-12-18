## CALL

## Overview

The `CALL` statement is used to invoke an **inline procedure** or a **named procedure**.

## Calling Inline Procedures

An **inline procedure** is a user-defined procedure embedded within a query, commonly used to execute subqueries or perform data modifications. It enables complex logic such as looping and enhances efficiency by managing resources more effectively—especially when working with large graphs—thereby reducing memory overhead.

<p tit="Syntax"></p>

```gql
<call inline procedure statement> ::= 
  [ "OPTIONAL" ] "CALL" [ "(" [ <variable reference list> ] ")" ] "{" 
    <statement block>
  "}"

<variable reference list> ：：=
  <variable reference> [ { "," <variable reference> }... ]
```

**Details**

- You can import variables from earlier parts of the query into `CALL`. If omitted, all current variables are implicitly imported. 
- Each imported record is processed independently by the `<statement block>` inside the `CALL`.
- When used for subqueries, the `<statement block>` must end with a `RETURN` statement to output variables to the outer query:
  - Each returned variable becomes a new column in the intermediate result table.
  - If a subquery yields no records, the associated imported record is **discarded**. The `OPTIONAL` keyword can be used to handle this case - producing a `null` value instead of discarding the record.
  - If multiple records are returned, the imported row is **duplicated** accordingly.
- For data modification procedures, a `RETURN` statement is not required. In such cases, the number of records in the intermediate result table remains the same after the `CALL`.

### Example Graph

<div align=center drawio-diagram='16932' drawio-name="draw_8900c35205e1442fa1a12c929a716edf.jpg"><img src="https://img.ultipa.cn/draw/draw_8900c35205e1442fa1a12c929a716edf.jpg?v='1733216427377'"/></div>

<div tab="code">

<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph { 
  NODE User ({name string}),
  NODE Club (),
  EDGE Follows ()-[]->(),
  EDGE Joins ()-[{rates uint32}]->()
} PARTITION BY HASH(Crc32) SHARDS [1]
```

<p tit="Insert data to the graph"></p>

```gql
INSERT (rowlock:User {_id:'U01', name:'rowlock'}),
       (brainy:User {_id:'U02', name:'Brainy'}),
       (purplechalk:User {_id:'U03', name:'purplechalk'}),
       (mochaeach:User {_id:'U04', name:'mochaeach'}),
       (lionbower:User {_id:'U05', name:'lionbower'}),
       (c01:Club {_id:'C01'}),
       (c02:Club {_id:'C02'}),
       (rowlock)-[:Follows]->(brainy),
       (mochaeach)-[:Follows]->(brainy),
       (brainy)-[:Follows]->(purplechalk),
       (lionbower)-[:Follows]->(purplechalk),
       (brainy)-[:Joins]->(c01),
       (lionbower)-[:Joins]->(c01),
       (brainy)-[:Joins]->(c02),
       (mochaeach)-[:Joins]->(c02)
```

</div>

### Subqueries

To find members of each club:

```gql
MATCH (c:Club)
CALL {
    MATCH (c)<-[:Joins]-(u:User)
    RETURN collect_list(u.name) AS members
}
RETURN c._id, members
```

Result:

| c.\_id | members |
| -- | -- |
| C01 | ["Brainy","lionbower"] |
| C02 | ["Brainy","mochaeach"] |

### OPTIONAL CALL

To retrieve the followers of each member in club `C01`, ensure that members with no followers are still included in the results:

```gql
MATCH (c)<-[:Joins]-(u:User) WHERE c._id = "C01"
OPTIONAL CALL (u) {
  MATCH (u)<-(follower:User)
  RETURN collect_list(follower.name) AS followers
}
RETURN u.name, followers
```

Result:

| u.name | followers |
| -- | -- |
| Brainy | ["rowlock","mochaeach"] |
| lionbower | `null` |

### Execution Order of Subqueries

The order in which the subquery executed is not determined. If a specific execution order is desired, `ORDER BY` should be used to sort the records before `CALL` to enforce that sequence.

This query counts the number of followers for each user. The execution order of the subqueries is determined by the ascending order of the users' `name`:

```gql
MATCH (u:User)
ORDER BY u.name
CALL {
  MATCH (u)<-[:Follows]-(follower)
  RETURN COUNT(follower) AS followersNo
}
RETURN u.name, followersNo
```

Result:

| u.name | followersNo |
| -- | -- |
| Brainy | 2 |
| lionbower | 0 |
| mochaeach | 0 |
| purplechalk | 2 |
| rowlock | 0 |

### Data Modifications

To set values for the property `rates` of `Joins` edges:

```gql
FOR score IN [1,2,3,4]
CALL {
    MATCH ()-[e:Joins WHERE e.rates IS NULL]-() LIMIT 1  
    SET e.rates = score
    RETURN e
}
RETURN e
```

Result: `e`

| <div table-width="9">_uuid</div> | <div table-width="6">_from</div> | <div table-width="5">_to</div> | <div table-width="12">_from_uuid</div> | <div table-width="12">_to_uuid</div> | <div table-width="10">schema</div> | values |
| -- | -- | -- | -- | -- | -- | -- |
| <span style="color: #999;">Sys-gen</span> | U04 | C02 | <span style="color: #999;">UUID of U04</span> | <span style="color: #999;">UUID of C02</span> | Joins | {rates: 1} |
| <span style="color: #999;">Sys-gen</span> | U02 | C01 | <span style="color: #999;">UUID of U02</span> | <span style="color: #999;">UUID of C01</span> | Joins | {rates: 2} |
| <span style="color: #999;">Sys-gen</span> | U02 | C02 | <span style="color: #999;">UUID of U02</span> | <span style="color: #999;">UUID of C02</span> | Joins | {rates: 3} |
| <span style="color: #999;">Sys-gen</span> | U05 | C01 | <span style="color: #999;">UUID of U05</span> | <span style="color: #999;">UUID of C01</span> | Joins | {rates: 4} |

## Calling Named Procedures

A **named procedure** refers to a predefined procedure, such as an algorithm, that is registered in the system and can be invoked by its name using the `CALL` statement.

<p tit="Syntax"></p>

```gql
<call named procedure statement> ::=
  "CALL" <procedure reference> [ <yield clause> ]

<yield clause> ::= 
  "YIELD" <yield item> [ { "," <yield item> }... ]

<yield item> ::=
  <column name> [ "AS" <binding variable> ]
```

**Details**

- The `YIELD` clause can be used to output variables to the outer query.

### Running an Algorithm

The following query executes the <a target="_blank" href="https://www.ultipa.com/docs/graph-analytics-algorithms/degree-centrality">Degree Centrality</a> algorithm. Note that the algorithm is run on the HDC graph `my_hdc_graph` derived from the current graph.

```gql
CALL algo.degree.run("my_hdc_graph", {
  direction: "in",
  order: "desc"
}) YIELD r
RETURN r
```

To learn more about available algorithms, refer to the <a target="_blank" href="https://www.ultipa.com/docs/graph-analytics-algorithms">Graph Analytics & Algorithms</a> documentation.
