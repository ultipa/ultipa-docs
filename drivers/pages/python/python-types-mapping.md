# Types Mapping Ultipa and Python

## Mapping Methods

The `get()` or `alias()` method of the `UltipaResponse` class returns a `DataItem`, which embeds the query result. You should use the `as<Type>()` method of `DataItem` to cast the result to the appropriate driver type.

<p tit="Python"></p> 
 
```python
response = Conn.uql("find().nodes() as n return n{*} limit 5")
nodeList = response.alias("n").asNodes()
```

The result `n` coming from the database contains five nodes, each of the NODE type. The `asNodes()` method converts them as a list of `Node` objects.

Type mapping methods available on `DataItem`:

| UQL Type | UQL Alias | Method | Driver Type | <div table-width="35">Description</div> |
| -- | -- | -- | -- | -- |
| NODE | Any | `asNodes()` | List[Node] | Maps NODE-type `DataItem` to a list of `Node` objects. |
| NODE | Any | `asFirstNode()` | Node | Maps the first node in a NODE-type `DataItem` to a `Node` object. Equivalent to `asNodes().get(0)`. |
| EDGE | Any | `asEdges()` | List[Edge] | Maps EDGE-type `DataItem` to a list of `Edge` objects. |
| EDGE | Any | `asFirstEdge()` | Edge | Maps the first edge in an EDGE-type `DataItem` to an `Edge` object. Equivalent to `asEdges().get(0)`. |
| PATH | Any | `asPaths()` | List[Path] | Maps PATH-type `DataItem` to a list of `Path` objects. |
| GRAPH | Any | `asGraph()` | Graph | Maps GRAPH-type `DataItem` to a `Graph` object. |
| TABLE | `_graph` | `asGraphSets()` | List[GraphSet] | Maps `DataItem` with the alias `_graph` to a list of `GraphSet` objects. |
| TABLE | `_nodeSchema`, `_edgeSchema` | `asSchemas()` | List[Schema] | Maps `DataItem` with the alias `_nodeSchema` or `_edgeSchema` to a list of `Schema` objects. |
| TABLE | `_nodeProperty`, `_edgeProperty` | `asProperties()` | List[Property] | Maps `DataItem` with the alias `_nodeProperty` or `_edgeProperty` to a list of `Property` objects. |
| TABLE | `_algoList` | `asAlgos()` | List[Algo] | Maps `DataItem` with the alias `_algoList` to a list of `Algo` objects. |
| TABLE | `_extaList` | `asExtas()` | List[Exta] | Maps `DataItem` with the alias `_extaList` to a list of `Exta` objects. |
| TABLE | `_nodeIndex`, `_edgeIndex`, `_nodeFulltext`, `_edgeFulltext` | `asIndexes()` | List[Index] | Maps `DataItem` with the alias `_nodeIndex`, `_edgeIndex`, `_nodeFulltext` or `_edgeFulltext` to a list of `Index` objects. |
| TABLE | `_privilege` | `asPriviliege()` | Priviliege | Maps `DataItem` with the alias `_privilege` to a `Priviliege` object. |
| TABLE | `_policy` | `asPolicy()` | Policy/List[Policy] | Maps `DataItem` with the alias `_policy` to one or a list of `Policy` objects. |
| TABLE | `_user` | `asUsers()` | User/List[User] | Maps `DataItem` with the alias `_user` to one or a list of `User` objects. |
| TABLE | `_statistic` | `asStats()` | Stats | Maps `DataItem` with the alias `_statistic` to a `Stats` object. |
| TABLE | `_top` | `asProcesses()` | List[Process] | Maps `DataItem` with the alias `_top` to a list of `Process` objects. |
| TABLE | `_task` | `asTasks()` | List[Task] | Maps `DataItem` with the alias `_task` to a list of `Task` objects. |
| TABLE | Any | `asTable()` | Table | Maps TABLE-type `DataItem` to a `Table` object. |
| ATTR | Any | `asAttr()` | Attr | Maps ATTR-type `DataItem` to a `Attr` object. |

## Driver Types

> Objects of all driver types support **getter methods** to retrieve the value of a field and **setter methods** to set the value of a field, even if they are not explicitly listed below.

### Node

A `Node` object has the following fields:

| Field | Type | <div table-width="50">Description</div> |
| ---- | ---- | ---- |  
| `uuid` | int | Node UUID |
| `id` | str | Node ID |
| `schema` | str | Node Schema |
| `values` | dict | Node custom properties |

Methods on a `Node` object:

| <div table-width="27">Method</div> | <div table-width="10">Return</div> | Description |
| ---- | ---- | ---- |
| `get("<propertyName>")` | Any | Get value of the given custom property of the node. |
| `set("<propertyName>", <propertyValue>)` |  | Set value for the given custom property of the node; or add a key-value pair to the `values` of the node if the given `<propertyName>` does not exist. |

<p tit="Python" ></p> 

```python
response = Conn.uql("find().nodes() as n return n{*} limit 5")
nodes = response.alias("n").asNodes()

print("ID of the 1st node:", nodes[0].getID())
print("Store name of the 1st node", nodes[0].get("storeName"))
```

<p tit= "Output" ></p> 
 
```bash
ID of the 1st node: 47370-257954
Store name of the 1st node: Meritxell, 96
```

### Edge

An `Edge` object has the following fields:

| Field | Type | <div table-width="50">Description</div> |
| ---- | ---- | ---- |  
| `uuid` | int | Edge UUID |
| `from_uuid` | int | Start node UUID of the edge |
| `to_uuid` | int | End node UUID of the edge |
| `from_id` | str | Start node ID of the edge |
| `to_id` | str | End node ID of the edge |
| `schema` | dtr | Edge Schema |
| `values` | dict | Edge custom properties |

Methods on an `Edge` object:

| <div table-width="27">Method</div> | <div table-width="10">Return</div> | Description |
| ---- | ---- | ---- | 
| `get("<propertyName>")` | Any | Get value of the given custom property of the edge. |
| `set("<propertyName>", <propertyValue>` |  | Set value for the given custom property of the edge; or add a key-value pair to the values of the edge if the given `<propertyName>` does not exist. |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("find().edges() as e return e{*} limit 5")
edges = response.alias("e").asEdges()

print("Values of the 1st edge:", edges[0].getValues())
```

<p tit= "Output" ></p> 
 
```bash
Values of the 1st edge: {'distanceMeters': 20, 'duration': '21s', 'staticDuration': '25s', 'travelMode': 'Walk', 'transportationCost': 46}
```

### Path

A `Path` object has the following fields:

| Field | <div table-width="25">Type</div> | <div table-width="45">Description</div> |
| ---- | ---- | ---- |  
| `nodes` | List[Node] | Node list of the path |
| `edges` | List[Edge] | Edge list of the path |
| `nodeSchemas` | Dict[str, Schema] | Map of all node schemas of the path |
| `edgeSchemas` | Dict[str, Schema] | Map of all edge schemas of the path |

Methods on a `Path` object:

| <div table-width="15">Method</div> | <div table-width="15">Return</div> | Description |
| ---- | ---- | ---- | 
| `length()` | int | Get length of the path, i.e., the number of edges in the path. |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("n().e()[:2].n() as paths return paths{*} limit 5")
paths = response.alias("paths").asPaths()

print("Length of the 1st path:", paths[0].length())

print("Edges in the 1st path:")
edges = paths[0].getEdges()
for edge in edges:
    print(edge)

print("Information of the 2nd node in the 1st path:")
nodes = paths[0].getNodes()
print(nodes[1])
```

<p tit= "Output" ></p> 
 
```bash
Length of the 1st path: 2
Edges in the 1st path: 
{'schema': 'transport', 'from_id': '15219-158845', 'from_uuid': 20, 'to_id': '47370-257954', 'to_uuid': 1, 'values': {'distanceMeters': 10521283, 'duration': '527864s', 'staticDuration': '52606s', 'travelMode': 'Airplane', 'transportationCost': 21043}, 'uuid': 591}
{'schema': 'transport', 'from_id': '15474-156010', 'from_uuid': 21, 'to_id': '15219-158845', 'to_uuid': 20, 'values': {'distanceMeters': 233389, 'duration': '13469s', 'staticDuration': '1167s', 'travelMode': 'Airplane', 'transportationCost': 467}, 'uuid': 599}
Information of the 2nd node in the 1st path: 
{'id': '15219-158845', 'schema': 'warehouse', 'values': {'brand': 'Starbucks', 'storeName': 'Las Palmas', 'ownershipType': 'Licensed', 'city': 'Pilar', 'provinceState': 'B', 'timezone': 'GMT-03:00 America/Argentina/Bu', 'point': 'POINT(-33.390000 -60.220000)'}, 'uuid': 20}
```

### Graph

A `Graph` object has the following fields:

| Field | <div table-width="25">Type</div> | <div table-width="45">Description</div> |
| ---- | ---- | ---- |  
| `node_table` | List[Node] | Node list of the path |
| `edge_table` | List[Edge] | Edge list of the path |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("n(as n1).re(as e).n(as n2).limit(3) with toGraph(collect(n1), collect(n2), collect(e)) as graph return graph", requestConfig)
graph = response.alias("graph").asGraph()

print("Node IDs:")
nodes = graph.node_table
for node in nodes:
    print(node.getID())

print("Edge UUIDs:")
edges = graph.edge_table
for edge in edges:
    print(edge.getUUID())
```

<p tit= "Output" ></p> 
 
```bash
Node IDs:
24604-238367
34291-80114
47370-257954
29791-255373
23359-229184
Edge UUIDs:
344
320
346
```

### GraphSet

A `GraphSet` object has the following fields:

| <div table-width="15">Field</div> | Type | <div table-width="65">Description</div> |
| ---- | ---- | ---- |  
| `id` | int | Graphset ID |
| `name` | str | Graphset name |
| `description` | str | Graphset description |
| `totalNodes` | int | Total number of nodes in the graphset |
| `totalEdges` | int | Total number of edges in the graphset |
| `status` | str | Graphset status (MOUNTED, MOUNTING, or UNMOUNTED) |

<p tit= "Python" ></p> 
 
```python
response = Conn.uql("show().graph()")
graphs = response.alias("_graph").asGraphSets()
for graph in graphs:
    if graph.status == "UNMOUNTED":
        print(graph.name)
```

<p tit= "Output" ></p> 
 
```bash
DFS_EG
cyber
netflow
```

### Schema

A `Schema` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="18">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | str | Schema name |
| `description` | str | Schema description |
| `properties` | List[Property] | Property list of the schema |
| `DBType` | DBType | Schema type (0 for nodes, 1 for edge) |
| `total` | int | Total number of nodes or edges of the schema |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("show().node_schema()")
schemas = response.alias("_nodeSchema").asSchemas()
for schema in schemas:
    print(schema.name, "has", schema.total, "nodes")
```

<p tit="Output" ></p> 
 
```bash
default has 0 nodes
member has 7 nodes
organization has 19 nodes
```

### Property

A `Property` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="24">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | str | Property name |
| `description` | str | Property description |
| `schema` | str | Associated schema of the property |
| `type` | PropertyTypeStr | Property data type, defaults to `PropertyTypeStr.PROPERTY_STRING` |
| `subTypes` | List[PropertyTypeStr] | Property data sub type |
| `lte` | bool | Property LTE status (true or false) |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("show().property()")
properties = response.alias("_nodeProperty").asProperties()
for property in properties:
    print(property.name)
```

<p tit= "Output" ></p> 
 
```bash
title
profile
age
name
logo
```

### Algo

An `Algo` object has the following fields:

| <div table-width="30">Field</div> | <div table-width="10">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | str | Algorithm name |
| `description` | str | Algorithm description |
| `version` | str | Algorithm version |
| `parameters` | dict | Algorithm parameters |
| `write_to_file_parameters` | dict | Algorithm file writeback parameters |
| `write_to_db_parameters` | dict | Algorithm property writeback parameters |
| `result_opt` | str | The code defines the execution methods supported by the algorithm. |

<p tit="Python"></p> 
 
```python
response = Conn.uql("show().algo()")
algos = response.alias("_algoList").asAlgos()
print(algos[0])
```

<p tit= "Output" ></p> 
 
```bash
{'name': 'celf', 'description': 'celf', 'version': '1.0.0', 'result_opt': '25', 'parameters': {'seedSetSize': 'size_t,optional,1 as default', 'monteCarloSimulations': 'size_t,optional, 1000 as default', 'propagationProbability': 'float,optional, 0.1 as default'}, 'write_to_db_parameters': {}, 'write_to_file_parameters': {'filename': 'set file name'}}
```

### Exta

> An exta is a custom algorithm developed by users.

An `Exta` object has the following fields:

| <div table-width="10">Field</div> | <div table-width="28">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | str | Exta name |
| `author` | str | Exta author |
| `version` | str | Exta version |
| `detail` | str | Content of the YML configuration file of the Exta |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("show().exta()")
extas = response.alias("_extaList").asExtas()
print(extas[0].name)
```

<p tit= "Output" ></p> 
 
```bash
page_rank
```

### Index

An `Index` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | str | Index name |
| `properties` | str | Property name of the index |
| `schema` | str | Schema name of the index |
| `status` | str | Index status (done or creating) |
| `size` | str | Index size in bytes |
| `DBType` | DBType | Index type (DBNODE or DBEDGE) |

<p tit="Python" ></p> 

```python
response = Conn.uql("show().index()")
indexList = response.alias("_nodeIndex").asIndexes()

for index in indexList:
    print(index.schema, index.properties, index.size)
```

<p tit="Output" ></p> 
 
```bash
account name 0
movie name 2526
```

<p tit="Python" ></p> 

```python
response = Conn.uql("show().fulltext()")
indexList = response.alias("_edgeFulltext").asIndexes()

for index in indexList:
    print(index.schema, index.properties, index.schema)
```

<p tit="Output" ></p> 
 
```bash
contentFull content review
```

### Privilege

A `Privilege` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `systemPrivileges` | List[str] | System privileges |
| `graphPrivileges` | List[str] | Graph privileges |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("show().privilege()")
privilege = response.alias("_privilege").asPrivilege()
print(privilege.systemPrivileges)
```

<p tit= "Output" ></p> 
 
```bash
["TRUNCATE","COMPACT","CREATE_GRAPH","SHOW_GRAPH","DROP_GRAPH","ALTER_GRAPH","MOUNT_GRAPH","UNMOUNT_GRAPH","TOP","KILL","STAT","SHOW_POLICY","CREATE_POLICY","DROP_POLICY","ALTER_POLICY","SHOW_USER","CREATE_USER","DROP_USER","ALTER_USER","GRANT","REVOKE","SHOW_PRIVILEGE"]
```

### Policy

A `Policy` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | str | Policy name |
| `systemPrivileges` | List[str] | System privileges included in the policy |
| `graphPrivileges` | dict | Graph privileges and the corresponding graphsets included in the policy |
| `propertyPrivileges` | dict | Property privileges included in the policy |
| `policies` | List[str] | Policies included in the policy |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("show().policy()")
policyList = response.alias("_policy").asPolicies()

for policy in policyList:
    print(policy.name)
```

<p tit="Output" ></p> 
 
```bash
manager
operator
```

### User

A `User` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `username` | str | Username |
| `create` | str | When the user was created |
| `systemPrivileges` | List[str] | System privileges granted to the user |
| `graphPrivileges` | dict | Graph privileges and the corresponding graphsets granted to the user |
| `propertyPrivileges` | dict | Property privileges granted to the user |
| `policies` | List[str] | Policies granted to the user |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("show().user('Tester')")
user = response.alias("_user").asUsers()

print(user.toJSON())
```

<p tit="Output" ></p> 
 
```bash
{"create": 1721974206, "graphPrivileges": "{}", "policies": "[]", "propertyPrivileges": "{\"node\":{\"read\":[],\"write\":[[\"miniCircle\",\"account\",\"name\"]],\"deny\":[]},\"edge\":{\"read\":[],\"write\":[],\"deny\":[]}}", "systemPrivileges": "[]", "username": "Tester"}
```

### Stats

A `Stats` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `cpuUsage` | str | CPU usage in percentage |
| `memUsage` | str | Memory usage in megabytes |
| `expiredDate` | str | Expiration date of the license |
| `cpuCores` | str | Number of CPU cores |
| `company` | str | Company name |
| `serverType` | str | Server type |
| `version` | str | Version of the server | 

<p tit="Python" ></p> 
 
```python
response = Conn.uql("stats()")
stats = response.get(0).asStats()
print("CPU usage (%):", stats.cpuUsage)
print("Memory usage:", stats.memUsage)
```

<p tit="Output" ></p> 
 
```bash
CPU usage (%): 5.415697
Memory usage: 9292.265625
```

### Process

A `Process` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `processId` | String | Process ID |
| `processUql` | String | The UQL run with the process |
| `status` | String | Process status |
| `duration` | String | The duration in seconds the task has run so far |

<p tit="Python" ></p> 
 
```python
requestConfig = RequestConfig(graphName="amz")

response = Conn.uql("top()", requestConfig)
processList = response.alias("_top").asProcesses()
for process in processList:
    print(process.processId)
```

<p tit="Output" ></p> 
 
```bash
a_2_569_2
a_3_367_1
```

### Task

A `Task` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `Task_info` | Task_info | Task information including `task_id`, `algo_name`, `start_time`, `writing_start_time`, `end_time`, etc. |
| `param` | dict | Algorithm parameters and their corresponding values |
| `result` | dict | Algorithm result and statistics and their corresponding values |

<p tit="Python"></p> 
 
```python
requestConfig = RequestConfig(graphName="miniCircle")

response = Conn.uql("show().task()", requestConfig)
tasks = response.alias("_task").asTasks()
print(tasks[0].task_info)
print(tasks[0].param)
print(tasks[0].result)
```

<p tit= "Output" ></p> 
 
```bash
{'task_id': 77954, 'server_id': 2, 'algo_name': 'louvain', 'start_time': 1728543848, 'writing_start_time': 1728543848, 'end_time': 1728543848, 'time_cost': 0, 'TASK_STATUS': 3, 'return_type': <ultipa.types.types_response.Return_Type object at 0x0000025E53C0F940>}
{"phase1_loop_num":"20","min_modularity_increase":"0.001"}
{'community_count': '10', 'modularity': '0.535017', 'result_files': 'communityID,ids,num'}
```

### Table

A `Table` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | str | Table name |
| `headers` | List[dict] | Table headers |
| `rows` | List[List] | Table rows |

Methods on a `Table` object:

| <div table-width="15">Method</div> | <div table-width="20">Return</div> | Description |
| ---- | ---- | ---- | 
| `headerToDicts()` | List[Dict] | Convert all rows of the table to a key-value list. |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("find().nodes() as n return table(n._id, n._uuid) as myTable limit 5")
table = response.alias("myTable").asTable()
rows = table.headerToDicts()
print("2nd row in table:", rows[1])
```

<p tit= "Output" ></p> 
 
```bash
2nd row in table: {'n._id': 'u604510', 'n._uuid': 2}
```

### Attr

A `Attr` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | str | Attr name |
| `values` | any | Attr rows |
| `type` | `ResultType` | Attr type |

<p tit="Python" ></p> 
 
```python
response = Conn.uql("find().nodes({@ad}) as n return n.brand limit 5")
attr = response.alias("n.brand").asAttr()
print(attr.values)
```

<p tit="Output" ></p> 
 
```bash
[14655, 14655, 14655, 14655, 434760]
```