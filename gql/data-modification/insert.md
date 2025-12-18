## INSERT

## Overview

The `INSERT` statement allows you to add new nodes and edges into the graph using node and edge patterns.

Different from <a target="_blank" href="https://www.ultipa.com/docs/gql/graph-pattern-matching">graph pattern matching</a>, `INSERT` supports variable declarations, label/schema expressions, and property specifications in node and edge patterns; while `WHERE` clauses are not allowed. Only basic concatenations of node and edge patterns are permitted, and the indication of edge direction is necessary.

Ultipa supports both typed graphs and open graphs. Their data insertion syntax is similar, but with important differences in requirements.

### Typed Graph

For a **typed graph**, any node or edge inserted must conform to its defined graph type. Nodes or edges with undefined schemas or properties cannot be added. 

You must assign exactly one schema to a node or edge in a typed graph. Any given property value will be checked against the defined value type; any property not explicitly provided defaults to `null`. 

To create a typed graph:

```gql
CREATE GRAPH g1 { 
  NODE User ({name STRING, gender STRING}),
  NODE Club (),
  EDGE Follows ()-[{since DATE}]->(),
  EDGE Joins ()-[{fee UINT32}]->()
}
```

<a target="_blank" href="https://www.ultipa.com/docs/gql/typed-graph">Learn more about typed graphs →</a>

### Open Graph

For an **open graph**, you can directly insert nodes and edges, and the labels and properties are created on the fly.

You may assign zero, one, or multiple labels to a node or edge in an open graph. Each node or edge has its own set of properties.

To create an open graph:

```gql
CREATE GRAPH g2 ANY
```

<a target="_blank" href="https://www.ultipa.com/docs/gql/open-graph">Learn more about open graphs →</a>

## Inserting Nodes

Nodes are inserted using **node patterns**.
  
To insert a single `User` node:

```gql
INSERT (:User {name: "claire", gender: "female"})
```

To insert multiple nodes and return them:

```gql
INSERT (n1:User {_id: "U2", name: "Quasar92"}),
       (n2:Club {_id: "C1"}),
       (n3:Club)
RETURN n1, n2, n3
```

In an open graph, you may assign multiple labels to a node:

```gql
INSERT (n:Person&Employee {name: "Bob"})
RETURN n
```

## Inserting Edges

Edges are inserted using **edge patterns**, which connect nodes on both ends and include a direction to indicate source and destination.

To insert two `User` nodes and a `Follows` edge between them:

```gql
INSERT (:User {name: 'rowlock'})-[:Follows {since: date('2024-01-05')}]->(:User {name: 'Brainy', gender: 'male'})
```

To insert an edge between existing nodes, first retrieve the nodes using `MATCH`:

```gql
MATCH (n1:User {name: 'claire'}), (n2:Club {_id: 'C1'})
INSERT (n1)-[e:Joins {fee: 1200}]->(n2)
RETURN e
```

To insert a `Joins` edge from an existing `User` node to a new `Club` node:

```gql
MATCH (user:User {name: 'Quasar92'})
INSERT (user)-[:Joins]->(:Club {_id: "C2"})
```

## Inserting Graph

<div align=center drawio-diagram='20305' drawio-name="draw_b9ada0dd44584302ac547599f89112b3.jpg"><img src="https://img.ultipa.cn/draw/draw_b9ada0dd44584302ac547599f89112b3.jpg?v='1762334095051'"/></div>

To insert the nodes and edges shown above, consider it as two paths intersecting at the `Club` node:

```gql
INSERT (:User {name: 'waveBliss'})-[:Joins]->(c:Club {_id: 'C3'}),
       (:User {name: 'bella'})-[:Joins]->(c)<-[:Joins]-(:User {name: 'Roose'})
```

Alternatively, you can insert each node and edge individually:

```gql
INSERT (waveBliss:User {name: 'waveBliss'}),
       (bella:User {name: 'bella'}),
       (Roose:User {name: 'Roose'}),
       (C3:Club {_id: 'C3'}),
       (waveBliss)-[:Joins]->(C3),
       (bella)-[:Joins]->(C3),
       (Roose)-[:Joins]->(C3)
```

## Property Value Examples

Ultipa supports a wide range of property types. You can view the complete list at <a target="_blank" href="https://www.ultipa.com/docs/gql/values-and-types#Property-Value-Types">here</a>.

Below are examples of property values for different types. These examples assume a typed graph, where properties are explicitly defined with specific types. In open graphs, property value types are open too, but the examples can still serve as a useful reference for assigning values.

### Numeric Properties

Numeric property value types include `INT` (`INT32`), `UINT` (`UINT32`), `INT64`, `UINT64`, `FLOAT`, `DOUBLE`, and `DECIMAL(<precision>, <scale>)`. 

```gql
// age is UINT32, weight is DECIMAL(10,2)
INSERT (:Person {age: 34, weight: 60.3})
```

### Textual Properties

Textual property value types include `STRING` and `TEXT`. 

```gql
// name is STRING
INSERT (:Person {name: "John Doe"})
```

### Temporal Instant Properties

Temporal instant property value types include `DATE`, `LOCAL DATETIME`, `LOCAL TIME`, `ZONED DATETIME`, `ZONED TIME`, `TIMESTAMP`, and `DATETIME`. 

```gql
// register is ZONED DATETIME, lastLogin is timestamp
INSERT (:Person {
    register: zoned_datetime("2025-01-01 12:20:02+0200"), 
    lastLogin: 1762338059
})
```

### Temporal Duration Properties

Temporal duration property value types include `DURATION(YEAR TO MONTH)` and `DURATION(DAY TO SECOND)`. 

```gql
// ativeDuration is DURATION(DAY TO SECOND)
INSERT (:Person {ativeDuration: "P526DT23H14M8S"})
```

### Boolean Properties

Boolean property value type is `BOOL`. 

```gql
// isBlocked is BOOL
INSERT (:Person {isBlocked: FALSE})
```

### Spatial Properties

Spatial property value types include `POINT` and `POINT3D`. 

```gql
// location is POINT, PoI is POINT3D
INSERT (:Person {
  location: POINT({latitude: 22.3, longitude: 125.6}),
  PoI: POINT3D({x: 10, y: 3.4, z: 6.2})
})
```

### Record Properties

Record property value types is `RECORD`. 

```gql
// bodyInfo is RECORD
INSERT (:Person {
  bodyInfo: {height: 175, weight: 68, bmi: 22.2, hairColor: "brown", bloodTyle: "O"}
})
```

### Binary Properties

Binary property value types is `BLOB`. 

```gql
// avatar is BLOB
INSERT (:Person {
    avatar: "data:image/png;base64,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"
})
```

### List Properties

List property value type is `LIST<subType>`. 

```gql
// tags is LIST<STRING>
INSERT (:Person {tags: ["IT", "happy", "geek"]})
```
