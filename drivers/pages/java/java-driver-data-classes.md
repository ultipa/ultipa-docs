# Driver Data Classes

The Ultipa Java driver provides a set of data classes designed to facilitate seamless interaction with the graph database. All data classes support **getter methods** to retrieve an attribute and **setter methods** to set the value of an attribute.

# Node

A `Node` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `uuid` | Long | / | Node `_uuid`. |
| `id` | String | / | Node `_id`. |
| `schema` | String | / | Name of the schema the node belongs to. |
| `values` | `Value` | / | Node property key-value pairs. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.gql("MATCH (n) RETURN n LIMIT 5", requestConfig);
List<Node> nodes = response.alias("n").asNodes();

System.out.println("ID of the first node: " + nodes.get(0).getID());
System.out.println("Name of the first node: " + nodes.get(0).get("name"));
```

<p tit="Output"></p> 
 
```
ID of the first node: ULTIPA800000000000004B
Name of the first node: Claire89
```

## Edge

An `Edge` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `uuid` | Long | / | Edge `_uuid`. |
| `fromUuid` | Long | / | Source node `_uuid` of the edge. |
| `toUuid` | Long | / | Destination node `_uuid` of the edge. |
| `from` | String | / | Source node `_id` of the edge. |
| `to` | String | / | Destination node `_id` of the edge. |
| `schema` | String | / | Name of the schema the edge belongs to. |
| `values` | `Value` | / | Edge property key-value pairs. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.gql("MATCH ()-[e]->() RETURN e LIMIT 3", requestConfig);
List<Edge> edges = response.alias("e").asEdges();

for (Edge edge : edges) {
    System.out.println(edge.getValues());
}
```

<p tit="Output"></p> 
 
```
{toUuid=108, uuid=1661, fromUuid=59, timestamp=Sun Oct 14 06:27:42 CST 2018}
{toUuid=15, uuid=31, fromUuid=59}
{toUuid=1012, uuid=1368, fromUuid=59, datetime=2019-03-23T17:09:12}
```

## Path

A `Path` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="18">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `nodeUUids` | List\<Long\> | / | The list of node `_uuid`s in the path. |
| `edgeUuids` | List\<Long\> | / | The list of edge `_uuid`s in the path |
| `nodes` | Map\<Long, `Node`> | `{}` | A map of nodes in the path, where the key is the node’s `_uuid`, and the value is the corresponding node. |
| `edges` | Map\<Long, `Edge`>  | `{}` | A map of edges in the path, where the key is the edge’s `_uuid`, and the value is the corresponding edge. |

Methods on a `Path` object:

| <div table-width="15">Method</div> | <div table-width="8">Return</div> | Description |
| ---- | ---- | ---- | 
| `length()` | int | Gets the length of the path, i.e., the number of edges in the path. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.gql("MATCH p = ()-[]-()-[]-() RETURN p LIMIT 3", requestConfig);
Graph graph = response.alias("p").asGraph();

System.out.println("Nodes in each returned path:");
List<Path> paths = graph.getPaths();
for (Path path : paths) {
    System.out.println(path.getNodeUUIDs());
}
```

<p tit="Output"></p> 
 
```
Nodes in each returned path:
[6196955286285058052, 7998395137233256457, 8214567919347040275]
[6196955286285058052, 7998395137233256457, 8214567919347040275]
[6196955286285058052, 7998395137233256457, 5764609722057490441]
```

## Graph

A `Graph` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="18">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `paths` | List<`Path`> | `[]` | The list of the returned paths. |
| `nodes` | Map\<Long, `Node`> | `{}` | A map of nodes in the graph, where the key is the node’s `_uuid`, and the value is the corresponding node. |
| `edges` | Map\<Long, `Edge`>  | `{}` | A map of edges in the graph, where the key is the edge’s `_uuid`, and the value is the corresponding edge. |

Methods on a `Graph` object:

| <div table-width="15">Method</div> | <div table-width="15">Parameter</div> | <div table-width="8">Return</div> | Description |
| ---- | ---- | ---- | ---- |
| `addNode()` | `node: Node` | / | Add a node to `nodes`. |
| `addEdge()` | `edge: Edge` | / | Add an edge to `edges`. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.gql("MATCH p = ()-[]-()-[]-() RETURN p LIMIT 3", requestConfig);
Graph graph = response.alias("p").asGraph();

System.out.println("Nodes in each returned path:");
List<Path> paths = graph.getPaths();
for (Path path : paths) {
    System.out.println(path.getNodeUUIDs());
}

System.out.println("----------");
System.out.println("Nodes in the graph formed by all returned paths:");
System.out.println(graph.getNodes().keySet());
```

<p tit="Output"></p> 
 
```
Nodes in each returned path:
[6196955286285058052, 7998395137233256457, 8214567919347040275]
[6196955286285058052, 7998395137233256457, 8214567919347040275]
[6196955286285058052, 7998395137233256457, 5764609722057490441]
----------
Nodes in the graph formed by all returned paths:
[8214567919347040275, 6196955286285058052, 7998395137233256457, 5764609722057490441]
```

## GraphSet

A `GraphSet` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="20">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |  
| `id` | String | / | Graph ID. |
| `name` | String | / | Graph name. |
| `totalNodes` | Long | / | Total number of nodes in the graph. |
| `totalEdges` | Long | / | Total number of edges in the graph. |
| `shards` | List\<String\> | `[]` | The list of IDs of shard servers where the graph is stored. |
| `partitionBy` | String | `Crc32` | The hash function used for graph sharding, which can be `Crc32`, `Crc64WE`, `Crc64XZ`, or `CityHash64`. |
| `status` | String | / | Graph status, which can be `NORMAL`, `LOADING_SNAPSHOT`, `CREATING`, `DROPPING`, or `SCALING`. |
| `description` | String | / | Graph description. |
| `slotNum` | int | 0 | The number of slots used for graph sharding. |

```java
Response response = driver.gql("SHOW GRAPH");
List<GraphSet> graphs = response.alias("_graph").asGraphSets();

for (GraphSet graph : graphs) {
    System.out.println(graph.getName());
}
```

<p tit="Output"></p> 
 
```
DFS_EG
cyber
netflow
```

## Schema

A `Schema` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `name` | String | / | Schema name |
| `dbType` | `DBType` | / | Schema type, which can be `DBNODE` or `DBEDGE`.  |
| `properties` | List<`Property`> | / | The list of properties associated with the schema. |
| `description` | String | / | Schema description |
| `total` | Long | 0 | Total number of nodes or edges belonging to the schema. |
| `id` | String | / | Schema ID. |
| `stats` | List<`SchemaStat`> | / | A list of `SchemaStat` objects; each `SchemaStat` includes attributes `name` (schema name), `dbType` (schema type), `fromSchema` (source node schema), `toSchema` (destination node schema), and `count` (count of nodes or edges). |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.gql("SHOW NODE SCHEMA", requestConfig);
List<Schema> schemas = response.alias("_nodeSchema").asSchemas();

for (Schema schema : schemas) {
    System.out.println(schema.getName());
}
```

<p tit="Output"></p> 
 
```
default
account
celebrity
country
movie
```

## Property

A `Property` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="20">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `name` | String | / | Property name. |
| `type` | `Ultipa.PropertyType` | / | Property value type, which can be `INT32`, `UINT32`, `INT64`, `UINT64`, `FLOAT`, `DOUBLE`, `DECIMAL`, `STRING`, `TEXT`, `LOCAL_DATETIME`, `ZONED_DATETIME`, `DATE`, `LOCAL_TIME`, `ZONED_TIME`, `DATETIME`, `TIMESTAMP`, `YEAR_TO_MONTH`, `DAY_TO_SECOND`, `BLOB`, `BOOL`, `POINT`, `LIST`, `SET`, `MAP`, `NULL`, `UUID`, `ID`, `FROM`, `FROM_UUID`, `TO`, `TO_UUID`, `IGNORE`, or `UNSET`. |
| `subType` | List<`Ultipa.PropertyType`> | / | If the `type` is `LIST` or `SET`, sets its element type; only one `UltipaPropertyType` is allowed in the list. |
| `schema` | String | / | The associated schema of the property. |
| `description` | String | / | Property description. |
| `lte` | Boolean | / | Whether the property is LTE-ed. |
| `read` | Boolean | / | Whether the property is readable. |
| `write` | Boolean | / | Whether the property can be written. |
| `encrypt` | String | / | Encryption method of the property, which can be `AES128`, `AES256`, `RSA`, or `ECC`. |
| `decimalExtra` | `DecimalExtra` | / | The precision (1–65) and scale (0–30) of the `DECIMAL` type. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.gql("SHOW NODE account PROPERTY", requestConfig);
List<Property> properties = response.alias("_nodeProperty").asProperties();

for (Property property : properties) {
    System.out.println(property.getName());
}
```

<p tit="Output"></p> 
 
```
title
profile
age
name
logo
```

## Attr

A `Attr` object includes the following attributes:

| <div table-width="20">Attribute</div> | <div table-width="20">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `name` | String | / | Name of the returned alias. |
| `values` | List\<Object\> | / | The returned values. |
| `propertyType` | `Ultipa.PropertyType` | / | Type of the results. |
| `resultType` | `Ultipa.ResultType` | / | Type of the results, which can be `RESULT_TYPE_NODE`, `RESULT_TYPE_EDGE`, `RESULT_TYPE_PATH`, `RESULT_TYPE_ATTR`, `RESULT_TYPE_TABLE`, or `RESULT_TYPE_UNSET`. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.gql("MATCH (n:account) RETURN n.name LIMIT 3", requestConfig);
Attr attr = response.alias("n.name").asAttr();

System.out.println("name: " + attr.getName());
System.out.println("values: " + attr.getValues());
System.out.println("type: " + attr.getPropertyType());
```

<p tit="Output"></p> 
 
```
name: n.name
values: ['Velox', 'K03', 'Lunatique']
type: STRING
```

## Table

A `Table` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="20">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |  
| `name` | String | / | Table name. |
| `headers` | List<`Header`> | / | Table headers. |
| `rows` | List\<List\<Object\>\> | / | Table rows. |

Methods on a `Table` object:

| <div table-width="15">Method</div> | <div table-width="20">Return</div> | Description |
| ---- | ---- | ---- | 
| `toKV()` | List<`Value`> | Convert all rows in the table to a list of dictionaries. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.gql("MATCH (n:account) RETURN table(n._id, n.name) LIMIT 3", requestConfig);
Table table = response.get(0).asTable();

System.out.println("Header:");
for (Header header : table.getHeaders()) {
    System.out.println(header.getPropertyName() + " - " + header.getPropertyType());
}

System.out.println("First Row:");
List<Value> rows = table.toKV();
if (!rows.isEmpty()) {
    System.out.println(rows.get(0));
}
```

<p tit="Output"></p> 
 
```
Header:
n._id - STRING
n.name - STRING
First Row:
{n._id=ULTIPA800000000000003B, n.name=Velox}
```

## HDCGraph

An `HDCGraph` object includes the following attributes:

| <div table-width="20">Attribute</div> | <div table-width="8">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `name` | String | / | HDC graph name. |
| `graphName` | String | / | The source graph from which the HDC graph is created. |
| `status` | String | / | HDC graph status. |
| `stats` | String | / | Statistics of the HDC graph. |
| `isDefault` | String | / | Whether it is the default HDC graph of the source graph. |
| `hdcServerName` | String | / | Name of the HDC server that hosts the HDC graph. |
| `hdcServerStatus` | String | / | Status of the HDC server that hosts the HDC graph. |
| `config` | String | / | Configurations of the HDC graph. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.uql("hdc.graph.show()", requestConfig);
List<HDCGraph> hdcGraphs = response.alias("_hdcGraphList").asHDCGraphs();

for (HDCGraph hdcGraph : hdcGraphs) {
    System.out.println(hdcGraph.getName() + " on " + hdcGraph.getHdcServerName());
}
```

<p tit="Output"></p> 
 
```
miniCircle_hdc_graph on hdc-server-1
miniCircle_hdc_graph2 on hdc-server-2
```

## Algo

An `Algo` object includes the following attributes:

| <div table-width="20">Attribute</div> | <div table-width="17">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |    
| `name` | String | / | Algorithm name. |
| `type` | String | / | Algorithm type. |
| `version` | String | / | Algorithm version. |
| `params` | List<`AlgoParam`> | / | Algorithm parameters, each `AlgoParam` has attributes `name` and `desc`. |
| `writeSupportType` | String | / | The writeback types supported by the algorithm. |
| `canRollback` | String | / | Whether the algorithm version supports rollback. |
| `configContext` | String | / | The configurations of the algorithm. |

```java
Response response = driver.uql("show().hdc('hdc-server-1')");
List<Algo> algos = response.alias("_algoList").asAlgos();

for (Algo algo : algos) {
  System.out.println(algo.getName() + " supports writeback types: " + algo.getWriteSupportType());
}
```

<p tit="Output"></p> 
 
```
fastRP supports writeback types: DB,FILE
struc2vec supports writeback types: DB,FILE
```

## Projection

A `Projection` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="8">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `name` | String | / | Projection name. |
| `graphName` | String | / | The source graph from which the projection is created. |
| `status` | String | / | Projection status. |
| `stats` | String | / | Statistics of the projection. |
| `config` | String | / | Configurations of the projection. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.uql("show().projection()", requestConfig);
List<Projection> projections = response.alias("_projectionList").asProjections();

for (Projection projection : projections) {
    System.out.println(projection.getName());
}
```

<p tit="Output"></p> 
 
```
miniCircle_projection_1
```

## Index

An `Index` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `id` | String | / | Index ID. |
| `name` | String | / | Index name. |
| `properties` | String | / | Properties associated with the index. |
| `schema` | String | / | The schema associated with the index |
| `status` | String | / | Index status. |
| `size` | String | / | Index size in bytes. |
| `dbType` | `DBType` | / | Index type, which can be `DBNODE` or `DBEDGE`. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.gql("SHOW NODE INDEX", requestConfig);
List<Index> indexList = response.alias("_nodeIndex").asIndexes();

for (Index index : indexList) {
    System.out.println(index.getSchema() + " - " + index.getProperties());
}
```

<p tit="Output"></p> 
 
```
account - gender(6),year
```

## Privilege

A `Privilege` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="17">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |  
| `name` | String | / | Privilege name. |
| `level` | `PrivilegeLevel` | / | Privilege level, which can be `SYSTEM_LEVEL` or `GRAPH_LEVEL`. |

```java
Response response = driver.uql("show().privilege()");
List<Privilege> privileges = response.alias("_privilege").asPrivileges();

String graphPrivilegeNames = privileges.stream()
		.filter(p -> p.getLevel() == PrivilegeLevel.GRAPH_LEVEL)
		.map(Privilege::getName)
		.collect(Collectors.joining(", "));
System.out.println("Graph privileges: " + graphPrivilegeNames);

String systemPrivilegeNames = privileges.stream()
		.filter(p -> p.getLevel() == PrivilegeLevel.SYSTEM_LEVEL)
		.map(Privilege::getName)
		.collect(Collectors.joining(", "));
System.out.println("System privileges: " + systemPrivilegeNames);
```

<p tit="Output"></p> 
 
```
Graph privileges: READ, INSERT, UPSERT, UPDATE, DELETE, CREATE_SCHEMA, DROP_SCHEMA, ALTER_SCHEMA, SHOW_SCHEMA, RELOAD_SCHEMA, CREATE_PROPERTY, DROP_PROPERTY, ALTER_PROPERTY, SHOW_PROPERTY, CREATE_FULLTEXT, DROP_FULLTEXT, SHOW_FULLTEXT, CREATE_INDEX, DROP_INDEX, SHOW_INDEX, LTE, UFE, CLEAR_JOB, STOP_JOB, SHOW_JOB, ALGO, CREATE_PROJECT, SHOW_PROJECT, DROP_PROJECT, CREATE_HDC_GRAPH, SHOW_HDC_GRAPH, DROP_HDC_GRAPH, COMPACT_HDC_GRAPH, SHOW_VECTOR_INDEX, CREATE_VECTOR_INDEX, DROP_VECTOR_INDEX, SHOW_CONSTRAINT, CREATE_CONSTRAINT, DROP_CONSTRAINT
System privileges: TRUNCATE, COMPACT, CREATE_GRAPH, SHOW_GRAPH, DROP_GRAPH, ALTER_GRAPH, TOP, KILL, STAT, SHOW_POLICY, CREATE_POLICY, DROP_POLICY, ALTER_POLICY, SHOW_USER, CREATE_USER, DROP_USER, ALTER_USER, SHOW_PRIVILEGE, SHOW_META, SHOW_SHARD, ADD_SHARD, DELETE_SHARD, REPLACE_SHARD, SHOW_HDC_SERVER, ADD_HDC_SERVER, DELETE_HDC_SERVER, LICENSE_UPDATE, LICENSE_DUMP, GRANT, REVOKE, SHOW_BACKUP, CREATE_BACKUP, SHOW_VECTOR_SERVER, ADD_VECTOR_SERVER, DELETE_VECTOR_SERVER
```

## Policy

A `Policy` object includes the following attributes:

| <div table-width="20">Attribute</div> | <div table-width="20">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `name` | String | / | Policy name. |
| `systemPrivileges` | List\<String\> | / | System privileges included in the policy. |
| `graphPrivileges` | Map\<String, List\<String\>\> | / | Graph privileges included in the policy; in the map, the key is the name of the graph, and the value is the corresponding graph privileges. |
| `propertyPrivileges` | `PropertyPrivilege` | / | Property privileges included in the policy; the `PropertyPrivilege` has attributes `node` and `edge`, both are `PropertyPrivilegeElement` objects. |
| `policies` | List\<String\> | / | Policies included in the policy. |

A `PropertyPrivilegeElement` object includes the following attributes:

| <div table-width="10">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `read` | List\<List\<String\>\> | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `write` | List\<List\<String\>\> | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `deny` | List\<List\<String\>\> | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |

```java
Response response = driver.uql("show().policy('Tester')");
List<Policy> policy = response.alias("_policy").asPolicies();
System.out.println("Graph privileges: " + policy.get(0).getGraphPrivileges());
System.out.println("System privileges: " + policy.get(0).getSystemPrivileges());
System.out.println("Property privileges:");
System.out.println("- Node (Read): " + policy.get(0).getPropertyPrivileges().getNode().getRead());
System.out.println("- Node (Write): " + policy.get(0).getPropertyPrivileges().getNode().getWrite());
System.out.println("- Node (Deny): " + policy.get(0).getPropertyPrivileges().getNode().getDeny());
System.out.println("- Edge (Read): " + policy.get(0).getPropertyPrivileges().getEdge().getRead());
System.out.println("- Edge (Write): " + policy.get(0).getPropertyPrivileges().getEdge().getWrite());
System.out.println("- Edge (Deny): " + policy.get(0).getPropertyPrivileges().getEdge().getDeny());
System.out.println("Policies: " + policy.get(0).getPolicies());
```

<p tit="Output"></p> 
 
```
Graph privileges: {amz=[ALGO, DROP_FULLTEXT, INSERT, DELETE, UPSERT], StoryGraph=[UPDATE, READ]}
System privileges: [TRUNCATE, KILL, TOP]
Property privileges:
- Node (Read): [[*, *, *]]
- Node (Write): []
- Node (Deny): []
- Edge (Read): []
- Edge (Write): [[amz, *, *], [alimama, *, *]]
- Edge (Deny): [[miniCircle, review, value, timestamp]]
Policies: [manager, sales]
```

## User

A `User` object includes the following attributes:

| <div table-width="20">Attribute</div> | <div table-width="20">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `username` | String | / | Username. |
| `password` | String | / | Password. |
| `createdTime` | Date | / | The time when the user was created. |
| `systemPrivileges` | List\<String\> | / | System privileges granted to the user. |
| `graphPrivileges` | Map\<String, List\<String\>\> | / | Graph privileges granted to the user; in the map, the key is the name of the graph, and the value is the corresponding graph privileges. |
| `propertyPrivileges` | `PropertyPrivilege` | / | Property privileges granted to the user; the `PropertyPrivilege` has attributes `node` and `edge`, both are `PropertyPrivilegeElement` objects. |
| `policies` | List\<String\> | / | Policies granted to the user. |

A `PropertyPrivilegeElement` object includes the following attributes:

| <div table-width="10">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `read` | List\<List\<String\>\> | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `write` | List\<List\<String\>\> | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `deny` | List\<List\<String\>\> | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |

```java
Response response = driver.uql("show().user('johndoe')");
List<User> user = response.alias("_user").asUsers();
System.out.println("Created Time: " + user.get(0).getCreatedTime());
System.out.println("Graph privileges: " + user.get(0).getGraphPrivileges());
System.out.println("System privileges: " + user.get(0).getSystemPrivileges());
System.out.println("Property privileges:");
System.out.println("- Node (Read): " + user.get(0).getPropertyPrivileges().getNode().getRead());
System.out.println("- Node (Write): " + user.get(0).getPropertyPrivileges().getNode().getWrite());
System.out.println("- Node (Deny): " + user.get(0).getPropertyPrivileges().getNode().getDeny());
System.out.println("- Edge (Read): " + user.get(0).getPropertyPrivileges().getEdge().getRead());
System.out.println("- Edge (Write): " + user.get(0).getPropertyPrivileges().getEdge().getWrite());
System.out.println("- Edge (Deny): " + user.get(0).getPropertyPrivileges().getEdge().getDeny());
System.out.println("Policies: " + user.get(0).getPolicies());
```

<p tit="Output"></p> 
 
```
Created Time: Wed Apr 02 11:08:38 CST 2025
Graph privileges: {amz=[ALGO, INSERT, DELETE, UPSERT], StoryGraph=[UPDATE, READ]}
System privileges: [TRUNCATE, KILL, TOP]
Property privileges:
- Node (Read): [[*, *, *]]
- Node (Write): []
- Node (Deny): []
- Edge (Read): []
- Edge (Write): [[amz, *, *], [alimama, *, *]]
- Edge (Deny): []
Policies: [sales, manager]
```

## Process

A `Process` object includes the following attributes:

| <div table-width="18">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `processId` | String | / | Process ID. |
| `processQuery` | String | / | The query that the process executes. |
| `status` | String | / | Process status. |
| `duration` | String | / | The duration (in seconds) the process has run. |

```java
Response response = driver.uql("top()");
List<Process> processes = response.alias("_top").asProcesses();

for (Process process : processes) {
    System.out.println(process.getProcessId());
}
```

<p tit="Output"></p> 
 
```
1049435
```

## Job

A `Job` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="8">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `id` | String | / | Job ID. |
| `graphName` | String | / | Name of the graph where the job executes on. |
| `query` | String | / | The query that the job executes. |
| `type` | String | / | Job type. |
| `errNsg` | String | / | Error message of the job. |
| `result` | Map | / | Result of the job. |
| `startTime` | String | / | The time when the job begins. |
| `endTime` | String | / | The times when the job ends. |
| `status` | String | / | Job status. |
| `progress` | String | / | Progress updates for the job, such as indications that the write operation has been started. |

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");
Response response = driver.gql("SHOW JOB", requestConfig);
List<Job> jobs = response.alias("_job").asJobs();

for (Job job : jobs) {
    if ("FAILED".equals(job.getStatus())) {
        System.out.println(job.getId() + " - " + job.getErrMsg() + " - " + job.getType());
    }
}
```

<p tit="Output"></p> 
 
```
51 - Fulltext name already exists. - CREATE_FULLTEXT
42 - Fulltext name already exists. - CREATE_FULLTEXT
26 - [engine] uuids should be unsigned integer - HDC_ALGO
26_1 -  - HDC_ALGO
17 - [engine] all failed, because some nodes do not exist in db - HDC_ALGO
17_1 -  - HDC_ALGO
```
