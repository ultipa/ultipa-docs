## SET

## Overview

The `SET` statement allows you to set properties and labels on nodes and edges. These nodes or edges must first be retrieved using the `MATCH` statement. 

**Note:** 

- In typed graphs, the schema of a node or edge is immutable. 
- The unique identifiers `_id` and `_uuid` are immutable.

## Typed Graph

### Example Graph

<div align=center drawio-diagram='16681' drawio-name="draw_0b980745308b4ae8884fdf7404df9aa1.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_0b980745308b4ae8884fdf7404df9aa1.jpg?v='1751439955839'"/></div>

<div tab="code">

<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph {
  NODE User ({name STRING, gender STRING}),
  NODE Club (),
  EDGE Follows ()-[{createdOn DATE}]->(),
  EDGE Joins ()-[{memberNo INT32}]->()
}
```

<p tit="Insert data to the graph"></p>

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

</div>

### Updating a Property

To update the value of each specified property:

```gql
MATCH (n:User {name: 'rowlock'})-[e:Follows]->(:User {name: 'Brainy'})
SET n.gender = 'male', e.createdOn = '2024-01-07'
RETURN n.gender, e.createdOn
```

### Removing a Property

To remove the values of specified properties by setting them to `null`:

```gql
MATCH (n:User {name: 'mochaeach'})
SET n.gender = null
```

### Overwriting All Properties

You can overwrite all property values of a node or edge using a record. Any property included in the record will be updated, while all other properties will be set to `null`.

```gql
MATCH (n:User {name: 'purplechalk'})
SET n = {name: 'MasterSwift'}
RETURN n
```

To remove all property values by setting an empty record:

```gql
MATCH (n:User {name: 'rowlock'})
SET n = {}
RETURN n
```

### Mismatched Value Type

If the provided value does not match the property's value type and cannot be converted, the property will be assigned its default value based on the property value type.

For example, if you update `memberNo` (`UINT64` type) with a string value, `memberNo` will be automatically set to 0:

```gql
MATCH ()-[e:Joins]->()
SET e.memberNo = 'm2'
```

## Open Graph

### Example Graph

<div align=center drawio-diagram='29506' drawio-name='draw_e28b5f5f92544d18b8853f2c8420d2c1.jpg'><img src="https://img.ultipa.cn/draw/draw_e28b5f5f92544d18b8853f2c8420d2c1.jpg?v='1760089184785'"/></div>

<div tab="code">

<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph ANY
```

<p tit="Insert data to the graph"></p>

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

</div>

### Adding Labels

To add a label to a node:

```gql
MATCH (n:User {name: 'rowlock'})
SET n:Person
```

To add two labels to a node:

```gql
MATCH (n:User {name: 'rowlock'})
SET n:Player, n:Employee
```

> To remove labels from nodes or edges, use the <a target="_blank" href="https://www.ultipa.com/docs/gql/remove">REMOVE</a> statement.

### Updating a Property

To update the value of each specified property:

```gql
MATCH (n:User {name: 'rowlock'})-[e:Follows]->(:User {name: 'Brainy'})
SET n.gender = 'male', e.createdOn = date('2024-01-07')
RETURN n.gender, e.createdOn
```

### Replace All Properties

You can replace all properties of a node or edge using a record.

To replace all property values:

```gql
MATCH (n:User {name: 'purplechalk'})
SET n = {username: 'MasterSwift', age: 36}
RETURN n
```
