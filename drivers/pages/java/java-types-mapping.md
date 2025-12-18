# Types Mapping Ultipa and Java

## Mapping Methods

The `get()` or `alias()` method of the `Response` class returns a `DataItem`, which embeds the query result. You should use the `as<Type>()` method of `DataItem` to cast the result to the appropriate driver type.

<p tit="Java"></p> 
 
```java
Response response = client.uql("find().nodes() as n return n{*} limit 5");
List<Node> nodeList = response.alias("n").asNodes();
```

The result `n` coming from the database contains five nodes, each of the NODE type. The `asNodes()` method converts them as a list of `Node` objects.

Type mapping methods available on `DataItem`:

| UQL Type | UQL Alias | Method | Driver Type | <div table-width="35">Description</div> |
| -- | -- | -- | -- | -- |
| NODE | Any | `asNodes()` | List\<Node> | Maps NODE-type `DataItem` to a list of `Node` objects. |
| NODE | Any | `asFirstNode()` | Node | Maps the first node in a NODE-type `DataItem` to a `Node` object. Equivalent to `asNodes().get(0)`. |
| EDGE | Any | `asEdges()` | List\<Edge> | Maps EDGE-type `DataItem` to a list of `Edge` objects. |
| EDGE | Any | `asFirstEdge()` | Edge | Maps the first edge in an EDGE-type `DataItem` to an `Edge` object. Equivalent to `asEdges().get(0)`. |
| PATH | Any | `asPaths()` | List\<Path> | Maps PATH-type `DataItem` to a list of `Path` objects. |
| GRAPH | Any | `asGraph()` | Graph | Maps GRAPH-type `DataItem` to a `Graph` object. |
| TABLE | `_graph` | `asGraphSets()` | List\<GraphSet> | Maps `DataItem` with the alias `_graph` to a list of `GraphSet` objects. |
| TABLE | `_nodeSchema`, `_edgeSchema` | `asSchemas()` | List\<Schema> | Maps `DataItem` with the alias `_nodeSchema` or `_edgeSchema` to a list of `Schema` objects. |
| TABLE | `_nodeProperty`, `_edgeProperty` | `asProperties()` | List\<Property> | Maps `DataItem` with the alias `_nodeProperty` or `_edgeProperty` to a list of `Property` objects. |
| TABLE | `_algoList` | `asAlgos()` | List\<Algo> | Maps `DataItem` with the alias `_algoList` to a list of `Algo` objects. |
| TABLE | `_extaList` | `asExtas()` | List\<Exta> | Maps `DataItem` with the alias `_extaList` to a list of `Exta` objects. |
| TABLE | `_nodeIndex`, `_edgeIndex`, `_nodeFulltext`, `_edgeFulltext` | `asIndexes()` | List\<Index> | Maps `DataItem` with the alias `_nodeIndex`, `_edgeIndex`, `_nodeFulltext` or `_edgeFulltext` to a list of `Index` objects. |
| TABLE | `_privilege` | `asPriviliege()` | Priviliege | Maps `DataItem` with the alias `_privilege` to a `Priviliege` object. |
| TABLE | `_policy` | `asPolicy()` | List\<Policy> | Maps `DataItem` with the alias `_policy` to a list of `Policy` objects. |
| TABLE | `_user` | `asUsers()` | List\<User> | Maps `DataItem` with the alias `_user` to a list of `User` objects. |
| TABLE | `_statistic` | `asStats()` | Stats | Maps `DataItem` with the alias `_statistic` to a `Stats` object. |
| TABLE | `_top` | `asProcesses()` | List\<Process> | Maps `DataItem` with the alias `_top` to a list of `Process` objects. |
| TABLE | `_task` | `asTasks()` | List\<Task> | Maps `DataItem` with the alias `_task` to a list of `Task` objects. |
| TABLE | Any | `asTable()` | Table | Maps TABLE-type `DataItem` to a `Table` object. |
| ATTR | Any | `asAttr()` | Attr | Maps ATTR-type `DataItem` to a `Attr` object. |

## Driver Types

> Objects of all driver types support **getter methods** to retrieve the value of a field and **setter methods** to set the value of a field, even if they are not explicitly listed below.

### Node

A `Node` object has the following fields:

| Field | Type | <div table-width="50">Description</div> |
| ---- | ---- | ---- |  
| `uuid` | Long | Node UUID |
| `id` | String | Node ID |
| `schema` | String | Node Schema |
| `values` | Value | Node custom properties |

Methods on a `Node` object:

| <div table-width="27">Method</div> | <div table-width="10">Return</div> | Description |
| ---- | ---- | ---- |
| `get("<propertyName>")` | Object | Get value of the given custom property of the node. |
| `set("<propertyName>", <propertyValue>)` |  | Set value for the given custom property of the node; or add a key-value pair to the `values` of the node if the given `<propertyName>` does not exist. |

<p tit="Java"></p> 

```java
Response response = client.uql("find().nodes() as n return n{*} limit 5");
List<Node> nodeList = response.alias("n").asNodes();

System.out.println("ID of the 1st node: " + nodeList.get(0).getID());
System.out.println("Store name of the 1st node: " + nodeList.get(0).get("storeName"));
```

<p tit="Output"></p> 
 
```bash
ID of the 1st node: 47370-257954
Store name of the 1st node: Meritxell, 96
```

### Edge

An `Edge` object has the following fields:

| Field | Type | <div table-width="50">Description</div> |
| ---- | ---- | ---- |  
| `uuid` | Long | Edge UUID |
| `fromUuid` | Long | Start node UUID of the edge |
| `toUuid` | Long | End node UUID of the edge |
| `from` | String | Start node ID of the edge |
| `to` | String | End node ID of the edge |
| `schema` | String | Edge Schema |
| `values` | Value | Edge custom properties |

Methods on an `Edge` object:

| <div table-width="27">Method</div> | <div table-width="10">Return</div> | Description |
| ---- | ---- | ---- | 
| `get("<propertyName>")` | Object | Get value of the given custom property of the edge. |
| `set("<propertyName>", <propertyValue>` |  | Set value for the given custom property of the edge; or add a key-value pair to the values of the edge if the given `<propertyName>` does not exist. |

<p tit="Java"></p> 
 
```java
Response response = client.uql("find().edges() as e return e{*} limit 5");
Edge edge = response.alias("e").asFirstEdge();
System.out.println("Values of the 1st edge: " + edge.getValues());
```

<p tit="Output"></p> 
 
```bash
Values of the 1st edge: {distanceMeters=20, duration=21s, staticDuration=25s, travelMode=Walk, transportationCost=46}
```

### Path

A `Path` object has the following fields:

| Field | <div table-width="25">Type</div> | <div table-width="45">Description</div> |
| ---- | ---- | ---- |  
| `nodes` | List\<Node> | Node list of the path |
| `edges` | List\<Edge> | Edge list of the path |
| `nodeSchemas` | Map<String, Schema> | Map of all node schemas of the path |
| `edgeSchemas` | Map<String, Schema> | Map of all edge schemas of the path |

Methods on a `Path` object:

| <div table-width="15">Method</div> | <div table-width="15">Return</div> | Description |
| ---- | ---- | ---- | 
| `length()` | Integer | Get length of the path, i.e., the number of edges in the path. |

<p tit="Java"></p> 
 
```java
Response response = client.uql("n().e()[:2].n() as paths return paths{*} limit 5");
List<Path> pathList = response.alias("paths").asPaths();

System.out.println("Length of the 1st path: " + pathList.get(0).length());
System.out.println("Edge list of the 1st path: " + pathList.get(0).getEdges());
System.out.println("Information of the 2nd node in the 1st path: " + pathList.get(0).getNodes().get(1).toJson());
```

<p tit="Output"></p> 
 
```bash
Length of the 1st path: 2
Edge list of the 1st path: [Edge(uuid=591, fromUuid=20, toUuid=1, from=15219-158845, to=47370-257954, schema=transport, values={distanceMeters=10521283, duration=527864s, staticDuration=52606s, travelMode=Airplane, transportationCost=21043}), Edge(uuid=599, fromUuid=21, toUuid=20, from=15474-156010, to=15219-158845, schema=transport, values={distanceMeters=233389, duration=13469s, staticDuration=1167s, travelMode=Airplane, transportationCost=467})]
Information of the 2nd node in the 1st path: {"brand":"Starbucks","storeName":"Las Palmas","ownershipType":"Licensed","city":"Pilar","provinceState":"B","timezone":"GMT-03:00 America/Argentina/Bu","point":{"latitude":-33.39,"longitude":-60.22},"_uuid":20,"_id":"15219-158845","schema":"warehouse"}
```

### Graph

A `Graph` object has the following fields:

| Field | <div table-width="25">Type</div> | <div table-width="45">Description</div> |
| ---- | ---- | ---- |  
| `nodes` | List\<Node> | Node list of the path |
| `edges` | List\<Edge> | Edge list of the path |
| `nodeSchemas` | Map<String, Schema> | Map of all node schemas of the path |
| `edgeSchemas` | Map<String, Schema> | Map of all edge schemas of the path |

<p tit="Java"></p> 
 
```java
Response response = client.uql("n(as n1).re(as e).n(as n2).limit(3) with toGraph(collect(n1), collect(n2), collect(e)) as graph return graph");
Graph graph = response.alias("graph").asGraph();
List<Node> nodes = graph.getNodes();
List<Edge> edges = graph.getEdges();

System.out.println("Node IDs:");
for (Node node : nodes) {
    System.out.println(node.getID());
}
System.out.println("Edge UUIDs:");
for (Edge edge : edges) {
    System.out.println(edge.getUUID());
}
```

<p tit="Output"></p> 
 
```bash
Node IDs:
ad304833
u604131
ad534784
ad6880
Edge UUIDs:
363347
774098
527786
3
```

### GraphSet

A `GraphSet` object has the following fields:

| <div table-width="15">Field</div> | Type | <div table-width="65">Description</div> |
| ---- | ---- | ---- |  
| `id` | Integer | Graphset ID |
| `name` | String | Graphset name |
| `description` | String | Graphset description |
| `totalNodes` | Long | Total number of nodes in the graphset |
| `totalEdges` | Long | Total number of edges in the graphset |
| `status` | String | Graphset status (MOUNTED, MOUNTING, or UNMOUNTED) |

<p tit="Java"></p> 
 
```java
Response response = client.uql("show().graph()");
List<GraphSet> graphSetList = response.alias("_graph").asGraphSets();
for (GraphSet graphSet : graphSetList) {
    if (graphSet.getStatus().equals("UNMOUNTED")) {
        System.out.println(graphSet.getName());
    }
}
```

<p tit="Output"></p> 
 
```bash
DFS_EG
cyber
netflow
```

### Schema

A `Schema` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="18">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | String | Schema name |
| `description` | String | Schema description |
| `properties` | List\<Property> | Property list of the schema |
| `dbType` | Ultipa.DBType | Schema type (DBNODE or DBEDGE) |
| `total` | Integer | Total number of nodes or edges of the schema |

<p tit="Java"></p> 
 
```java
Response response = client.uql("show().node_schema()");
List<Schema> schemaList = response.alias("_nodeSchema").asSchemas();
for (Schema schema : schemaList) {
    System.out.println(schema.getName() + " has " + schema.getTotal() + " nodes");
}
```

<p tit="Output"></p> 
 
```bash
default has 0 nodes
user has 1092511 nodes
ad has 846811 nodes
```

### Property

A `Property` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="18">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | String | Property name |
| `description` | String | Property description |
| `schema` | String | Associated schema of the property |
| `type` | String | Property data type |
| `lte` | Boolean | Property LTE status (true or false) |

<p tit="Java"></p> 
 
```java
Response response = client.uql("show().node_property(@user)");
List<Property> propertyList = response.alias("_nodeProperty").asProperties();
for (Property property : propertyList) {
    if (property.getLte()) {
        System.out.println("LTE-ed property name: " + property.getName());
    }
}
```

<p tit="Output"></p> 
 
```bash
LTE-ed property name: cms_group_id
```

### Algo

An `Algo` object has the following fields:

| <div table-width="10">Field</div> | <div table-width="28">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | String | Algorithm name |
| `desc` | String | Algorithm description |
| `version` | String | Algorithm version |
| `detail` | String | Algorithm parameters |

<p tit="Java"></p> 
 
```java
Response res = client.uql("show().algo()");
List<Algo> algoList = res.alias("_algoList").asAlgos();
System.out.println(algoList.get(0).toString());
```

<p tit="Output"></p> 
 
```bash
Algo(name=fastRP, desc={"name":"fastRP","description":"Fast and Accurate Network Embeddings via Very Sparse Random Projection","version":"1.0.1","parameters":{"dimension":"int,required","normalizationStrength":"float,optional, 0 as default","iterationWeights":"float[],optional,[0.0,1.0,1.0] as default","edge_schema_property":"optional,for weighted random projection","node_schema_property":"optional","propertyDimension":"int,optional, maximum value is dimension","limit":"optional,-1 for all results, >=0 partial results"},"write_to_db_parameters":{"property":"set write back property name for each schema and nodes"},"write_to_file_parameters":{"filename":"set file name"},"result_opt":"27"}, version=null, params=null)
```

### Exta

> An exta is a custom algorithm developed by users.

An `Exta` object has the following fields:

| <div table-width="10">Field</div> | <div table-width="28">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | String | Exta name |
| `author` | String | Exta author |
| `version` | String | Exta version |
| `detail` | String | Content of the YML configuration file of the Exta |

<p tit="Java"></p> 
 
```java
Response response = client.uql("show().exta()");
List<Exta> extaList = response.alias("_extaList").asExtas();
System.out.println(extaList.get(0).getName());
```

<p tit="Output"></p> 
 
```bash
page_rank
```

### Index

An `Index` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | String | Index name |
| `properties` | String | Property name of the index |
| `schema` | String | Schema name of the index |
| `status` | String | Index status (done or creating) |
| `size` | String | Index size in bytes |
| `dbType` | Ultipa.DBType | Index type (DBNODE or DBEDGE) |

<p tit="Java"></p> 
 
```java
Response response = client.uql("show().index()");
List<Index> indexList = response.alias("_nodeIndex").asIndexes();

for (Index index : indexList) {
    System.out.println(index.getSchema() + " " + index.getProperties() + " " + index.getSize());
}
```

<p tit="Output"></p> 
 
```bash
account name 0
movie name 2526
```

<p tit="Java"></p> 
 
```java
Response response = client.uql("show().fulltext()");
List<Index> indexList = response.alias("_edgeFulltext").asIndexes();

for (Index index : indexList) {
    System.out.println(index.getName() + " " + index.getProperties() + " " + index.getSchema());
}
```

<p tit="Output"></p> 
 
```bash
contentFull content review
```

### Privilege

A `Privilege` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `systemPrivileges` | List\<String> | System privileges |
| `graphPrivileges` | List\<String> | Graph privileges |

<p tit="Java"></p> 
 
```java
Response response = client.uql("show().privilege()");
Privilege privilege = response.alias("_privilege").asPrivilege();
System.out.println(privilege.getSystemPrivileges());
```

<p tit="Output"></p> 
 
```bash
[TRUNCATE, COMPACT, CREATE_GRAPH, SHOW_GRAPH, DROP_GRAPH, ALTER_GRAPH, MOUNT_GRAPH, UNMOUNT_GRAPH, TOP, KILL, STAT, SHOW_POLICY, CREATE_POLICY, DROP_POLICY, ALTER_POLICY, SHOW_USER, CREATE_USER, DROP_USER, ALTER_USER, GRANT, REVOKE, SHOW_PRIVILEGE]
```

### Policy

A `Policy` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | String | Policy name |
| `systemPrivileges` | List\<String> | System privileges included in the policy |
| `graphPrivileges` | Map<String, List\<String>> | Graph privileges and the corresponding graphsets included in the policy |
| `propertyPrivileges` | PropertyPrivilege | Property privileges included in the policy |
| `policies` | List\<String> | Policies included in the policy |

<p tit="Java"></p> 
 
```java
Response response = client.uql("show().policy()");
List<Policy> policyList = response.alias("_policy").asPolicies();
for (Policy policy : policyList) {
    System.out.println(policy.getName());
}
```

<p tit="Output"></p> 
 
```bash
manager
operator
```

### User

A `User` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `username` | String | Username |
| `create` | String | When the user was created |
| `systemPrivileges` | List\<String> | System privileges granted to the user |
| `graphPrivileges` | Map<String, List\<String>> | Graph privileges and the corresponding graphsets granted to the user |
| `propertyPrivileges` | PropertyPrivilege | Property privileges granted to the user |
| `policies` | List\<String> | Policies granted to the user |

<p tit="Java"></p> 
 
```java
Response response = client.uql("show().user('Tester')");
List<User> user = response.alias("_user").asUsers();
System.out.println(user.get(0).toString());
```

<p tit="Output"></p> 
 
```bash
User(username=Tester, create=Fri Jul 26 14:10:06 CST 2024, systemPrivileges=[MOUNT_GRAPH, SHOW_GRAPH], graphPrivileges={Ad_Click=[FIND_EDGE, FIND_NODE], DFS_EG=[UPDATE, INSERT]}, propertyPrivileges=PropertyPrivilege(node=PropertyPrivilegeElement(read=[], write=[], deny=[]), edge=PropertyPrivilegeElement(read=[], write=[], deny=[])), policies=[operator])
```

### Stats

A `Stats` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `cpuUsage` | String | CPU usage in percentage |
| `memUsage` | String | Memory usage in megabytes |
| `expiredDate` | String | Expiration date of the license |
| `cpuCores` | String | Number of CPU cores |
| `company` | String | Company name |
| `serverType` | String | Server type |
| `version` | String | Version of the server | 

<p tit="Java"></p> 
 
```java
Response response = client.uql("stats()");
Stats stats = response.get(0).asStats();
System.out.println("CPU usage: " + stats.getCpuUsage() + "%");
System.out.println("Memory usage: " + stats.getMemUsage());
```

<p tit="Output"></p> 
 
```bash
CPU usage: 5.415697%
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

<p tit="Java"></p> 
 
```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("amz");

Response response = client.uql("top()", requestConfig);
List<Process> processList = response.alias("_top").asProcesses();
for (Process process : processList) {
    System.out.println(process.getProcessId());
}
```

<p tit="Output"></p> 
 
```bash
a_2_569_2
a_3_367_1
```

### Task

A `Task` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `taskInfo` | TaskInfo | Task information including `taskId`, `serverId`, `algoName`, `startTime`, etc. |
| `param` | Map\<String, Object> | Algorithm parameters and their corresponding values |
| `result` | Map\<String, Object> | Algorithm result and statistics and their corresponding values |
| `errorMsg` | String | Error message of the task |

<p tit="Java"></p> 
 
```java
Response response = client.uql("show().task()", requestConfig);
List<Task> tasks = response.alias("_task").asTasks();
System.out.println(tasks.get(0).getTaskInfo().getAlgoName());
System.out.println(tasks.get(0).getParam().toString());
System.out.println(tasks.get(0).getResult().toString());
```

<p tit="Output"></p> 
 
```bash
degree
{order=desc, limit=10}
{total_degree=590.000000, avarage_degree=1.940789, result_files=top10}
```

### Table

A `Table` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `tableName` | String | Table name |
| `headers` | List\<Header> | Table headers |
| `rows` | List\<List\<Object>> | Table rows |

Methods on a `Table` object:

| <div table-width="15">Method</div> | <div table-width="20">Return</div> | Description |
| ---- | ---- | ---- | 
| `toKV()` | List\<Value> | Convert all rows of the table to a key-value list. |

<p tit="Java"></p> 
 
```java
Response response = client.uql("find().nodes() as n return table(n._id, n._uuid) as myTable limit 5");
Table table = response.alias("myTable").asTable();
System.out.println("2nd row in table: " + table.toKV().get(1));
```

<p tit="Output"></p> 
 
```bash
2nd row in table: {n._id=u604510, n._uuid=2}
```

### Attr

A `Attr` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | String | Attr name |
| `values` | List\<Object> | Attr rows |
| `type` | Ultipa.PropertyType | Attr type |

<p tit="Java"></p> 
 
```java
Response response = client.uql("find().nodes({@ad}) as n return n.brand limit 5");
Attr attr = response.alias("n.brand").asAttr();
System.out.println(attr.getValues());
```

<p tit="Output"></p> 
 
```bash
[14655, 14655, 14655, 14655, 434760]
```