# SET

## Overview

The `SET` statement allows you to set properties and labels on nodes and edges. These nodes or edges must first be retrieved using the `MATCH` statement.

**Note:** The unique identifier `_id` is immutable.

## Example Graph

<center><img src="images/set-example.jpg"/></center>

```gql
INSERT (rowlock:User {_id: "U01", name: "rowlock"}),
       (brainy:User {_id: "U02", name: "Brainy", gender: "male"}),
       (purplechalk:User {_id: "U03", name: "purplechalk", gender: "female"}),
       (mochaeach:User {_id: "U04", name: "mochaeach", gender: "female"}),
       (c:Club {_id: "C01"}),
       (rowlock)-[:Follows {createdOn: date("2024-01-05")}]->(brainy),
       (purplechalk)-[:Follows {createdOn: date("2024-02-01")}]->(brainy),
       (mochaeach)-[:Follows {createdOn: date("2024-02-10")}]->(brainy),
       (brainy)-[:Joins {memberNo: 1}]->(c)
```

## Updating Individual Properties

Update the value of each specified property:

```gql
MATCH (n:User {name: 'rowlock'})-[e:Follows]->(:User {name: 'Brainy'})
SET n.gender = 'male', e.createdOn = date('2024-01-07')
RETURN n.gender, e.createdOn
```

Remove the value of a property by setting it to `null`:

```gql
MATCH (n:User {name: 'mochaeach'})
SET n.gender = null
```

## Updating All Properties

You can replace all properties (except `_id`) of a node or edge using a record. Any property included in the record will be updated, while all other properties will be set to `null` (closed graph) or removed (open graph).

```gql
MATCH (n:User {name: 'purplechalk'})
SET n = {name: 'MasterSwift'}
RETURN n
```

Remove all property values by setting an empty record:

```gql
MATCH (n:User {name: 'rowlock'})
SET n = {}
RETURN n
```

## Adding Labels

Add one label to a node:

```gql
MATCH (n:User {name: 'rowlock'})
SET n:Player
```

Add multiple labels to a node:

```gql
MATCH (n:User {name: 'rowlock'})
SET n:Player, n:Employee
```

Update labels of `FOLLOWS` edges to `Links` (each edge has up to one label):

```gql
MATCH ()-[e:Follows]->()
SET e:Links
```

> To remove labels from nodes or edges, use the <a target="_blank" href="/docs/gql/remove">REMOVE</a> statement.
