# REMOVE

## Overview

The `REMOVE` statement allows you to remove properties and labels on nodes and edges. These nodes or edges must first be retrieved using the `MATCH` statement.

The `REMOVE` statement only supports **open graphs**.

## Example Graph

<div align=center drawio-diagram='29507' drawio-name='draw_0c6b39b01a314cd0bd3c493509c4e9ff.jpg'><img src="https://img.ultipa.cn/draw/draw_0c6b39b01a314cd0bd3c493509c4e9ff.jpg?v='1760090769245'"/></div>

<div tab="code">

<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph ANY
```

<p tit="Insert data to the graph"></p>

```gql
INSERT (rowlock:User&Person&Player&Employee {_id: "U01", name: "rowlock"}),
       (brainy:User {_id: "U02", name: "Brainy", gender: "male"}),
       (purplechalk:User {_id: "U03", name: "purplechalk", gender: "female"}),
       (mochaeach:User {_id: "U04", name: "mochaeach", gender: "female"}),
       (c:Club {_id: "C01"}),
       (rowlock)-[:Follows {createdOn: date("2024-01-05")}]->(brainy),
       (purplechalk)-[:Follows {createdOn: date("2024-02-01")}]->(brainy),
       (mochaeach)-[:Follows {createdOn: date("2024-02-10")}]->(brainy),
       (brainy)-[:Joins {memberNo: 1}]->(c)
```

</div>

## Removing Labels

To remove a label from a node:

```gql
MATCH (n:User {name: 'rowlock'})
REMOVE n:Person
```

To remove two labels from a node:

```gql
MATCH (n:User {name: 'rowlock'})
REMOVE n:Player, n:Employee
```

## Removing Properties

To remove the specified properties:

```gql
MATCH (n:User {name: 'rowlock'})-[e:Follows]->(:User {name: 'Brainy'})
REMOVE n.gender, e.createdOn
```
