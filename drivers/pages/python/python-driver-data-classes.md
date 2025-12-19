# Driver Data Classes

The Ultipa Python driver provides a set of data classes designed to facilitate seamless interaction with the graph database. All data classes support **getter methods** to retrieve an attribute and **setter methods** to set the value of an attribute.

# Node

A `Node` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `uuid` | int | / | Node `_uuid`. |
| `id` | str | / | Node `_id`. |
| `schema` | str | / | Name of the schema the node belongs to. |
| `values` | Dict[str,any] | / | Node property key-value pairs. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("MATCH (n) RETURN n LIMIT 5", requestConfig)
nodes = response.alias("n").asNodes()

print("ID of the first node:", nodes[0].getID())
print("Name of the first node:", nodes[0].get("name"))
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
| `uuid` | int | / | Edge `_uuid`. |
| `fromUuid` | int | / | Source node `_uuid` of the edge. |
| `toUuid` | int | / | Destination node `_uuid` of the edge. |
| `fromId` | str | / | Source node `_id` of the edge. |
| `toId` | str | / | Destination node `_id` of the edge. |
| `schema` | str | / | Name of the schema the edge belongs to. |
| `values` | Dict[str,any] | / | Edge property key-value pairs. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("MATCH ()-[e]->() RETURN e LIMIT 3", requestConfig)
edges = response.alias("e").asEdges()

for edge in edges:
    print(edge.getValues())
```

<p tit="Output"></p> 
 
```
{'toUuid': 13, 'uuid': 110, 'fromUuid': 7}
{'toUuid': 1032, 'uuid': 1391, 'fromUuid': 7, 'timestamp': 1537331913, 'datetime': '2018-09-19 12:38:33'}
{'toUuid': 1005, 'uuid': 1390, 'fromUuid': 7, 'timestamp': 1544118960, 'datetime': '2018-12-07 01:56:00'}
```

## Path

A `Path` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="18">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `nodeUuids` | List[int] | / | The list of node `_uuid`s in the path. |
| `edgeUuids` | List[int] | / | The list of edge `_uuid`s in the path |
| `nodes` | Dict[int, `Node`] | `{}` | A dictionary of nodes in the path, where the key is the node’s `_uuid`, and the value is the corresponding node. |
| `edges` | Dict[int, `Edge`] | `{}` | A dictionary of edges in the path, where the key is the edge’s `_uuid`, and the value is the corresponding edge. |

Methods on a `Path` object:

| <div table-width="15">Method</div> | <div table-width="8">Return</div> | Description |
| ---- | ---- | ---- | 
| `length()` | int | Gets the length of the path, i.e., the number of edges in the path. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("MATCH p = ()-[]-()-[]-() RETURN p LIMIT 3", requestConfig)
graph = response.alias("p").asGraph()

print("Nodes in each returned path:")
paths = graph.paths
for path in paths:
  print(path.nodeUuids)
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
| `paths` | List[`Path`] | `[]` | The list of the returned paths. |
| `nodes` | Dict[int, `Node`] | `{}` | A dictionary of nodes in the graph, where the key is the node’s `_uuid`, and the value is the corresponding node. |
| `edges` | Dict[int, `Edge`] | `{}` | A dictionary of edges in the graph, where the key is the edge’s `_uuid`, and the value is the corresponding edge. |

Methods on a `Graph` object:

| <div table-width="15">Method</div> | <div table-width="15">Parameter</div> | <div table-width="8">Return</div> | Description |
| ---- | ---- | ---- | ---- |
| `addNode()` | `node: Node` | / | Add a node to `nodes`. |
| `addEdge()` | `edge: Edge` | / | Add an edge to `edges`. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("MATCH p = ()-[]-()-[]-() RETURN p LIMIT 3", requestConfig)
graph = response.alias("p").asGraph()

print("Nodes in each returned path:")
paths = graph.paths
for path in paths:
  print(path.nodeUuids)

print("----------")
print("Nodes in the graph formed by all returned paths:")
print(graph.nodes.keys())
```

<p tit="Output"></p> 
 
```
Nodes in each returned path:
[6196955286285058052, 7998395137233256457, 8214567919347040275]
[6196955286285058052, 7998395137233256457, 8214567919347040275]
[6196955286285058052, 7998395137233256457, 5764609722057490441]
----------
Nodes in the graph formed by all returned paths:
dict_keys([6196955286285058052, 7998395137233256457, 8214567919347040275, 5764609722057490441])
```

## GraphSet

A `GraphSet` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="20">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |  
| `id` | str | / | Graph ID. |
| `name` | str | / | Graph name. |
| `totalNodes` | int | / | Total number of nodes in the graph. |
| `totalEdges` | int | / | Total number of edges in the graph. |
| `shards` | List[str] | `[]` | The list of IDs of shard servers where the graph is stored. |
| `partitionBy` | str | `Crc32` | The hash function used for graph sharding, which can be `Crc32`, `Crc64WE`, `Crc64XZ`, or `CityHash64`. |
| `status` | str | / | Graph status, which can be `NORMAL`, `LOADING_SNAPSHOT`, `CREATING`, `DROPPING`, or `SCALING`. |
| `description` | str | / | Graph description. |
| `slotNum` | int | 0 | The number of slots used for graph sharding. |

```python
response = Conn.gql("SHOW GRAPH")
graphs = response.alias("_graph").asGraphSets()
for graph in graphs:
    print(graph.name)
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
| `name` | str | / | Schema name |
| `dbType` | `DBType` | / | Schema type, which can be `DBNODE` or `DBEDGE`.  |
| `properties` | List[`Property`] | / | The list of properties associated with the schema. |
| `description` | str | / | Schema description |
| `total` | int | 0 | Total number of nodes or edges belonging to the schema. |
| `id` | str | / | Schema ID. |
| `stats` | List[`SchemaStat`] | / | A list of `SchemaStat` objects; each `SchemaStat` includes attributes `name` (schema name), `dbType` (schema type), `fromSchema` (source node schema), `toSchema` (destination node schema), and `count` (count of nodes or edges). |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("SHOW NODE SCHEMA", requestConfig)
schemas = response.alias("_nodeSchema").asSchemas()
for schema in schemas:
    print(schema.name)
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
| `name` | str | / | Property name. |
| `type` | `UltipaPropertyType` | / | Property value type, which can be `INT32`, `UINT32`, `INT64`, `UINT64`, `FLOAT`, `DOUBLE`, `DECIMAL`, `STRING`, `TEXT`, `LOCAL_DATETIME`, `ZONED_DATETIME`, `DATE`, `LOCAL_TIME`, `ZONED_TIME`, `DATETIME`, `TIMESTAMP`, `YEAR_TO_MONTH`, `DAY_TO_SECOND`, `BLOB`, `BOOL`, `POINT`, `LIST`, `SET`, `MAP`, `NULL`, `UUID`, `ID`, `FROM`, `FROM_UUID`, `TO`, `TO_UUID`, `IGNORE`, or `UNSET`. |
| `subType` | List[`UltipaPropertyType`] | / | If the `type` is `LIST` or `SET`, sets its element type; only one `UltipaPropertyType` is allowed in the list. |
| `schema` | str | / | The associated schema of the property. |
| `description` | str | / | Property description. |
| `lte` | bool | / | Whether the property is LTE-ed. |
| `read` | bool | / | Whether the property is readable. |
| `write` | bool | / | Whether the property can be written. |
| `encrypt` | str | / | Encryption method of the property, which can be `AES128`, `AES256`, `RSA`, or `ECC`. |
| `decimalExtra` | `DecimalExtra` | / | The precision (1–65) and scale (0–30) of the `DECIMAL` type. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("SHOW NODE account PROPERTY", requestConfig)
properties = response.alias("_nodeProperty").asProperties()
for property in properties:
    print(property.name)
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
| `name` | str | / | Name of the returned alias. |
| `values` | List[any] | / | The returned values. |
| `propertyType` | `UltipaPropertyType` | / | Type of the results. |
| `resultType` | `ResultType` | / | Type of the results, which can be `RESULT_TYPE_NODE`, `RESULT_TYPE_EDGE`, `RESULT_TYPE_PATH`, `RESULT_TYPE_ATTR`, `RESULT_TYPE_TABLE`, or `RESULT_TYPE_UNSET`. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("MATCH (n:account) RETURN n.name LIMIT 3", requestConfig)
attr = response.alias("n.name").asAttr()
print("name:", attr.name)
print("values:", attr.values)
print("type:", attr.propertyType.name)
```

<p tit="Output"></p> 
 
```
name: n.name
values: ['Velox', 'K03', 'Lunatique']
type: STRING
```

## Table

A `Table` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |  
| `name` | str | / | Table name. |
| `headers` | List[Dict] | / | Table headers. |
| `rows` | List[any] | / | Table rows. |

Methods on a `Table` object:

| <div table-width="15">Method</div> | <div table-width="20">Return</div> | Description |
| ---- | ---- | ---- | 
| `toKV()` | List[Dict] | Convert all rows in the table to a list of dictionaries. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("MATCH (n:account) RETURN table(n._id, n.name) LIMIT 3")
table = response.get(0).asTable()
print("Header:")
print(table.headers)
print("First Row:")
print(table.toKV()[0])
```

<p tit="Output"></p> 
 
```
Header:
[{'property_name': 'n._id', 'property_type': 'string'}, {'property_name': 'n.name', 'property_type': 'string'}]
First Row:
{'n._id': 'ULTIPA800000000000003B', 'n.name': 'Velox'}
```

## HDCGraph

An `HDCGraph` object includes the following attributes:

| <div table-width="20">Attribute</div> | <div table-width="8">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `name` | str | / | HDC graph name. |
| `graphName` | str | / | The source graph from which the HDC graph is created. |
| `status` | str | / | HDC graph status. |
| `stats` | str | / | Statistics of the HDC graph. |
| `isDefault` | str | / | Whether it is the default HDC graph of the source graph. |
| `hdcServerName` | str | / | Name of the HDC server that hosts the HDC graph. |
| `hdcServerStatus` | str | / | Status of the HDC server that hosts the HDC graph. |
| `config` | str | / | Configurations of the HDC graph. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.uql("hdc.graph.show()", requestConfig)
hdcGraphs = response.alias("_hdcGraphList").asHDCGraphs()
for hdcGraph in hdcGraphs:
    print(hdcGraph.name, "on", hdcGraph.hdcServerName)
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
| `name` | str | / | Algorithm name. |
| `type` | str | / | Algorithm type. |
| `version` | str | / | Algorithm version. |
| `params` | List[`AlgoParam`] | / | Algorithm parameters, each `AlgoParam` has attributes `name` and `desc`. |
| `writeSupportType` | str | / | The writeback types supported by the algorithm. |
| `canRollback` | str | / | Whether the algorithm version supports rollback. |
| `configContext` | str | / | The configurations of the algorithm. |

```python
response = Conn.uql("show().hdc('hdc-server-1')")
algos = response.alias("_algoList").asAlgos()
data = [[algo.name, algo.writeSupportType] for algo in algos if algo.type == "algo"]
headers = ["Name", "writeSupportType"]
print(tabulate.tabulate(data, headers=headers, tablefmt="grid"))
```

<p tit="Output"></p> 
 
```
+-----------+--------------------+
| Name      | writeSupportType   |
+===========+====================+
| fastRP    | DB,FILE            |
+-----------+--------------------+
| struc2vec | DB,FILE            |
+-----------+--------------------+
```

## Projection

A `Projection` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="8">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `name` | str | / | Projection name. |
| `graphName` | str | / | The source graph from which the projection is created. |
| `status` | str | / | Projection status. |
| `stats` | str | / | Statistics of the projection. |
| `config` | str | / | Configurations of the projection. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.uql("show().projection()", requestConfig)
projections = response.alias("_projectionList").asProjections()
for projection in projections:
    print(projection.name)
```

<p tit="Output"></p> 
 
```
miniCircle_projection_1
```

## Index

An `Index` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `id` | str | / | Index ID. |
| `name` | str | / | Index name. |
| `properties` | str | / | Properties associated with the index. |
| `schema` | str | / | The schema associated with the index |
| `status` | str | / | Index status. |
| `size` | str | / | Index size in bytes. |
| `dbType` | `DBType` | / | Index type, which can be `DBNODE` or `DBEDGE`. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("SHOW NODE INDEX", requestConfig)
indexList = response.alias("_nodeIndex").asIndexes()
for index in indexList:
    print(index.schema, "-", index.properties)
```

<p tit="Output"></p> 
 
```
account - gender(6),year
```

## Privilege

A `Privilege` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="17">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |  
| `name` | str | / | Privilege name. |
| `level` | `PrivilegeLevel` | / | Privilege level, which can be `SYSTEM` or `GRAPH`. |

```python
response = Conn.uql("show().privilege()")
privileges = response.alias("_privilege").asPrivileges()

graphPrivileges = [privilege.name for privilege in privileges if privilege.level == PrivilegeLevel.GRAPH]
print("Graph Privileges:", graphPrivileges)

systemPrivileges = [privilege.name for privilege in privileges if privilege.level == PrivilegeLevel.SYSTEM]
print("System Privileges:", systemPrivileges)
```

<p tit="Output"></p> 
 
```
Graph Privileges: ['READ', 'INSERT', 'UPSERT', 'UPDATE', 'DELETE', 'CREATE_SCHEMA', 'DROP_SCHEMA', 'ALTER_SCHEMA', 'SHOW_SCHEMA', 'RELOAD_SCHEMA', 'CREATE_PROPERTY', 'DROP_PROPERTY', 'ALTER_PROPERTY', 'SHOW_PROPERTY', 'CREATE_FULLTEXT', 'DROP_FULLTEXT', 'SHOW_FULLTEXT', 'CREATE_INDEX', 'DROP_INDEX', 'SHOW_INDEX', 'LTE', 'UFE', 'CLEAR_JOB', 'STOP_JOB', 'SHOW_JOB', 'ALGO', 'CREATE_PROJECT', 'SHOW_PROJECT', 'DROP_PROJECT', 'CREATE_HDC_GRAPH', 'SHOW_HDC_GRAPH', 'DROP_HDC_GRAPH', 'COMPACT_HDC_GRAPH', 'SHOW_VECTOR_INDEX', 'CREATE_VECTOR_INDEX', 'DROP_VECTOR_INDEX', 'SHOW_CONSTRAINT', 'CREATE_CONSTRAINT', 'DROP_CONSTRAINT']
System Privileges: ['TRUNCATE', 'COMPACT', 'CREATE_GRAPH', 'SHOW_GRAPH', 'DROP_GRAPH', 'ALTER_GRAPH', 'TOP', 'KILL', 'STAT', 'SHOW_POLICY', 'CREATE_POLICY', 'DROP_POLICY', 'ALTER_POLICY', 'SHOW_USER', 'CREATE_USER', 'DROP_USER', 'ALTER_USER', 'SHOW_PRIVILEGE', 'SHOW_META', 'SHOW_SHARD', 'ADD_SHARD', 'DELETE_SHARD', 'REPLACE_SHARD', 'SHOW_HDC_SERVER', 'ADD_HDC_SERVER', 'DELETE_HDC_SERVER', 'LICENSE_UPDATE', 'LICENSE_DUMP', 'GRANT', 'REVOKE', 'SHOW_BACKUP', 'CREATE_BACKUP', 'SHOW_VECTOR_SERVER', 'ADD_VECTOR_SERVER', 'DELETE_VECTOR_SERVER']
```

## Policy

A `Policy` object includes the following attributes:

| <div table-width="20">Attribute</div> | <div table-width="20">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `name` | str | / | Policy name. |
| `systemPrivileges` | List[str] | / | System privileges included in the policy. |
| `graphPrivileges` | Dict[str,List[str]] | / | Graph privileges included in the policy; in the dictionary, the key is the name of the graph, and the value is the corresponding graph privileges. |
| `propertyPrivileges` | `PropertyPrivilege` | / | Property privileges included in the policy; the `PropertyPrivilege` has attributes `node` and `edge`, both are `PropertyPrivilegeElement` objects. |
| `policies` | List[str] | / | Policies included in the policy. |

A `PropertyPrivilegeElement` object includes the following attributes:

| <div table-width="10">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `read` | List[List[str]] | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `write` | List[List[str]] | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `deny` | List[List[str]] | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |

```python
response = Conn.uql("show().policy('Tester')")
policy = response.alias("_policy").asPolicies()
print("Graph Privileges:", policy.graphPrivileges)
print("System Privileges:", policy.systemPrivileges)
print("Property Privileges:")
print("- Node (Read):", policy.propertyPrivileges.node.read)
print("- Node (Write):", policy.propertyPrivileges.node.write)
print("- Node (Deny):", policy.propertyPrivileges.node.deny)
print("- Edge (Read):", policy.propertyPrivileges.edge.read)
print("- Edge (Write):", policy.propertyPrivileges.edge.write)
print("- Edge (Deny):", policy.propertyPrivileges.edge.deny)
print("Policies:", policy.policies)
```

<p tit="Output"></p> 
 
```
Graph Privileges: {'amz': ['ALGO', 'INSERT', 'DELETE', 'UPSERT'], 'StoryGraph': ['UPDATE', 'READ']}
System Privileges: ['TRUNCATE', 'KILL', 'TOP']
Property Privileges:
- Node (Read): [['*', '*', '*']]
- Node (Write): []
- Node (Deny): []
- Edge (Read): []
- Edge (Write): [['amz', '*', '*'], ['alimama', '*', '*']]
- Edge (Deny): [['miniCircle', 'review', 'value, timestamp']]
Policies: ['sales', 'manager']
```

## User

A `User` object includes the following attributes:

| <div table-width="20">Attribute</div> | <div table-width="20">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `username` | str | / | Username. |
| `password` | str | / | Password. |
| `createdTime` | datetime | / | The time when the user was created. |
| `systemPrivileges` | List[str] | / | System privileges granted to the user. |
| `graphPrivileges` | Dict[str,List[str]] | / | Graph privileges granted to the user; in the dictionary, the key is the name of the graph, and the value is the corresponding graph privileges. |
| `propertyPrivileges` | `PropertyPrivilege` | / | Property privileges granted to the user; the `PropertyPrivilege` has attributes `node` and `edge`, both are `PropertyPrivilegeElement` objects. |
| `policies` | List[str] | / | Policies granted to the user. |

A `PropertyPrivilegeElement` object includes the following attributes:

| <div table-width="10">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- |
| `read` | List[List[str]] | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `write` | List[List[str]] | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `deny` | List[List[str]] | / | A list of lists; each inner list contains three strings representing the graph, schema, and property. |

```python
response = Conn.uql("show().user('johndoe')")
user = response.alias("_user").asUsers()
print("Created Time:", user.createdTime)
print("Graph Privileges:", user.graphPrivileges)
print("System Privileges:", user.systemPrivileges)
print("Property Privileges:")
print("- Node (Read):", user.propertyPrivileges.node.read)
print("- Node (Write):", user.propertyPrivileges.node.write)
print("- Node (Deny):", user.propertyPrivileges.node.deny)
print("- Edge (Read):", user.propertyPrivileges.edge.read)
print("- Edge (Write):", user.propertyPrivileges.edge.write)
print("- Edge (Deny):", user.propertyPrivileges.edge.deny)
print("Policies:", user.policies)
```

<p tit="Output"></p> 
 
```
Created Time: 2025-04-02 11:08:38
Graph Privileges: {'amz': ['ALGO', 'INSERT', 'DELETE', 'UPSERT'], 'StoryGraph': ['UPDATE', 'READ']}
System Privileges: ['TRUNCATE', 'KILL', 'TOP']
Property Privileges:
- Node (Read): [['*', '*', '*']]
- Node (Write): []
- Node (Deny): []
- Edge (Read): []
- Edge (Write): [['amz', '*', '*'], ['alimama', '*', '*']]
- Edge (Deny): [['miniCircle', 'review', 'value, timestamp']]
Policies: ['sales', 'manager']
```

## Process

A `Process` object includes the following attributes:

| <div table-width="18">Attribute</div> | <div table-width="15">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `processId` | str | / | Process ID. |
| `processQuery` | str | / | The query that the process executes. |
| `status` | str | / | Process status. |
| `duration` | str | / | The duration (in seconds) the process has run. |

```python
response = Conn.uql("top()")
processes = response.alias("_top").asProcesses()
for process in processes:
    print(process.processId)
```

<p tit="Output"></p> 
 
```
1049435
```

## Job

A `Job` object includes the following attributes:

| <div table-width="15">Attribute</div> | <div table-width="8">Type</div> | <div table-width="8">Default</div> | Description |
| ---- | ---- | ---- | ---- | 
| `id` | str | / | Job ID. |
| `graphName` | str | / | Name of the graph where the job executes on. |
| `query` | str | / | The query that the job executes. |
| `type` | str | / | Job type. |
| `errNsg` | str | / | Error message of the job. |
| `result` | Dict | / | Result of the job. |
| `startTime` | str | / | The time when the job begins. |
| `endTime` | str | / | The times when the job ends. |
| `status` | str | / | Job status. |
| `progress` | str | / | Progress updates for the job, such as indications that the write operation has been started. |

```python
requestConfig = RequestConfig(graph="miniCircle")
response = Conn.gql("SHOW JOB", requestConfig)
jobs = response.alias("_job").asJobs()
for job in jobs:
    if job.status == "FAILED":
        print(job.id, "-", job.errMsg, "-", job.type)
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