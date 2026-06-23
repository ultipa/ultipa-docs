# REMOVE

## Overview

The `REMOVE` statement allows you to remove properties and labels from nodes and edges. These nodes or edges must first be retrieved using the `MATCH` statement.

**Note:** The unique identifier `_id` is immutable.

## Example Graph

<div align=center><img src="images/remove-example.drawio.svg"/></div>

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

## Removing Individual Properties

In a **closed graph**, removing a property sets its value to `null`. In an **open graph**, the property is deleted from the node or edge.

Remove specified properties from nodes and edges:

```gql
MATCH (n:User {name: 'rowlock'})-[e:Follows]->(:User {name: 'Brainy'})
REMOVE n.gender, e.createdOn
RETURN n, e
```

## Removing Labels

Remove one label from a node:

```gql
MATCH (n:User {name: 'rowlock'})
REMOVE n:Player

-- 'IS <Label>' is an ISO-standard synonym for ':<Label>'
MATCH (n:User {name: 'rowlock'})
REMOVE n IS Player
```

Remove multiple labels from a node:

```gql
MATCH (n:User {name: 'rowlock'})
REMOVE n:Player, n:Employee
```

Remove a label from an edge:

```gql
MATCH ()-[e:Follows]->()
REMOVE e:Follows
```