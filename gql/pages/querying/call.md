# CALL

## Overview

The `CALL` statement is used to invoke an **inline procedure** or a **named procedure**.

<p tit="Syntax"></p>

```
<call statement> ::= <call inline procedure> | <call named procedure>
```

## Calling Inline Procedures

An **inline procedure** is a user-defined procedure embedded within a query, commonly used to execute subqueries or perform data modifications. It enables complex logic such as looping and enhances efficiency by managing resources more effectively, especially when working with large graphs, thereby reducing memory overhead.

<p tit="Syntax"></p>

```
<call inline procedure> ::= 
  [ "OPTIONAL" ] "CALL" [ <variable reference list> ] <procedure specification>

<variable reference list> ：：=
  "(" <variable reference> [ { "," <variable reference> }... ] ")"

<procedure specification> ::=
  "{" <statement block> "}"
```

**Details**

- You can import variables from earlier parts of the query into `CALL`. If omitted, all current variables are implicitly imported. 
- The imported variables are processed row by row independently inside `CALL`.
- When used for subqueries, the `<statement block>` must end with a `RETURN` statement to output variables to the outer query:
  - Each returned variable becomes a new column in the intermediate result table.
  - If a subquery yields no records, the associated imported record is **discarded**. The `OPTIONAL` keyword can be used to handle this case - producing a `null` value instead of discarding the record.
  - If multiple records are returned, the imported row is **duplicated** accordingly.
- For data modification procedures, a `RETURN` statement is not required. In such cases, the number of records in the intermediate result table remains the same after `CALL`.

### Example Graph

<div align=center drawio-diagram='16932' drawio-name="draw_8900c35205e1442fa1a12c929a716edf.jpg"><img src="https://img.ultipa.cn/draw/draw_8900c35205e1442fa1a12c929a716edf.jpg?v='1733216427377'"/></div>

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

### Subqueries

Find members of each club:

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

Retrieve the followers of each member in club `C01`, ensure that members with no followers are still included in the results:

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
| lionbower | [] |

### Execution Order of Subqueries

The order in which the subquery executed is not determined. If a specific execution order is desired, `ORDER BY` should be used to sort the records before `CALL` to enforce that sequence.

This query counts the number of followers for each user. The execution order of the subqueries is determined by the ascending order of the users' `name`:

```gql
MATCH (u:User)
ORDER BY u.name
CALL {
  MATCH (u)<-[:Follows]-(follower)
  RETURN count(follower) AS followersNo
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

Set values for the property `rates` of `Joins` edges:

```gql
FOR score IN [1,2,3,4]
CALL {
    MATCH ()-[e:Joins WHERE e.rates IS NULL]-() LIMIT 1  
    SET e.rates = score
    RETURN e
}
RETURN e
```

Result:

```json
[
  {"id": "e:7", "label": "Joins", "fromNodeId": "U02", "toNodeId": "C02", "properties": {"rates": 1}},
  {"id": "e:8", "label": "Joins", "fromNodeId": "U04", "toNodeId": "C02", "properties": {"rates": 2}},
  {"id": "e:5", "label": "Joins", "fromNodeId": "U02", "toNodeId": "C01", "properties": {"rates": 3}},
  {"id": "e:6", "label": "Joins", "fromNodeId": "U05", "toNodeId": "C01", "properties": {"rates": 4}}
]
```

## Calling Named Procedures

A **named procedure** refers to a predefined procedure that is registered in the system and can be invoked by its name using the `CALL` statement. Two kinds of named procedures are supported:

- **Built-in graph algorithms** such as `algo.degree`, `algo.pagerank`. See <a target="_blank" href="/docs/graph-algorithms">Graph Algorithms</a>.
- **User-defined stored procedures** created with `CREATE PROCEDURE`. See <a target="_blank" href="/docs/stored-procedures">Stored Procedures</a>.

<p tit="Syntax"></p>

```
<call named procedure> ::= [ "OPTIONAL" ] "CALL" <procedure reference> [ <yield clause> ]

<yield clause> ::= "YIELD" <yield item> [ { "," <yield item> }... ]

<yield item> ::= <column name> [ "AS" <binding variable> ]
```

**Details**

- The `YIELD` clause outputs the procedure's columns to the outer query.
- The yielded columns **replace** the outer binding row — variables from earlier clauses (e.g., `n` from a preceding `MATCH (n)`) are not visible after a named `CALL ... YIELD`. To carry variables through, project them in the `RETURN` before the `CALL`, or use the inline `CALL { ... }` form with explicit variable import.
- Prefix with `OPTIONAL` to suppress the "procedure not found" error when the named procedure does not exist. Unlike the inline `OPTIONAL CALL { ... }` subquery form, named `OPTIONAL CALL` does **not** insert a NULL-padded row when a resolved procedure yields zero rows — the result is an empty table.

### Running Algorithms

Execute the <a target="_blank" href="/docs/graph-algorithms/degree-centrality">Degree Centrality</a> algorithm:

```gql
CALL algo.degree({
  order: "desc"
}) YIELD nodeId, degree
```

To learn more about available algorithms, refer to <a target="_blank" href="/docs/graph-algorithms">Graph Algorithms</a>.

### Running Stored Procedures

Given a stored procedure `greet` created with `CREATE PROCEDURE`, invoke it the same way:

```gql
CALL greet('World') YIELD greeting
```

For details on defining, listing, and managing user-defined procedures, refer to <a target="_blank" href="/docs/stored-procedures">Stored Procedures</a>.

### OPTIONAL CALL

For named procedures, `OPTIONAL CALL` only suppresses the "procedure not found" error when the procedure does not exist. It does **not** insert a NULL-padded row when a resolved procedure yields zero rows — the result is simply an empty table. The richer outer-row preservation with NULL columns documented above applies only to the inline `OPTIONAL CALL { ... }` form.

```gql
-- Errors if 'maybe_proc' is not defined
CALL maybe_proc() YIELD result

-- No error; returns an empty result with column 'result'
OPTIONAL CALL maybe_proc() YIELD result
```
