# Types Mapping Ultipa and C#

## Mapping Methods

The `Alias()` method of the `Response` class returns a `DataItem`, which embeds the query result. You should use the `As<Type>()` method of `DataItem` to cast the result to the appropriate driver type.

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("find().nodes() as n return n{*} limit 5");
var nodeList = res.Alias("n").AsNodes();
Console.WriteLine(JsonConvert.SerializeObject(nodeList));
```

The result `n` coming from the database contains five nodes, each of the NODE type. The `AsNodes()` method converts them as a list of `Node` objects.

Type mapping methods available on `DataItem`:

| UQL Type | UQL Alias | Method | Driver Type | <div table-width="35">Description</div> |
| -- | -- | -- | -- | -- |
| NODE | Any | `AsNodes()` | List\<Node>? | Maps NODE-type `DataItem` to a list of `Node` objects. |
| EDGE | Any | `AsEdges()` | List\<Edge>? | Maps EDGE-type `DataItem` to a list of `Edge` objects. |
| PATH | Any | `AsPaths()` | List\<Path>? | Maps PATH-type `DataItem` to a list of `Path` objects. |
| TABLE | Any | `AsGraph()` | Graph | Maps GRAPH-type `DataItem` to a list of `Graph` objects. | 
| TABLE | `_graph` | `AsGraphSets()` | List\<GraphSet>? | Maps `DataItem` with the alias `_graph` to a list of `GraphSet` objects. |
| TABLE | `_nodeSchema`, `_edgeSchema` | `AsSchemas()` | List\<Schema> | Maps `DataItem` with the alias `_nodeSchema` or `_edgeSchema` to a list of `Schema` objects. |
| TABLE | `_nodeProperty`, `_edgeProperty` | `AsProperties()` | List\<Property> | Maps `DataItem` with the alias `_nodeProperty` or `_edgeProperty` to a list of `Property` objects. |
| TABLE | `_algoList` | `AsAlgos()` | List\<Algo> | Maps `DataItem` with the alias `_algoList` to a list of `Algo` objects. |
| TABLE | `_extaList` | `AsExtas()` | List\<Exta> | Maps `DataItem` with the alias `_extaList` to a list of `Exta` objects. |
| TABLE | `_nodeIndex`, `_edgeIndex`, `_nodeFulltext`, `_edgeFulltext` | `AsIndexes()` | List\<Index> | Maps `DataItem` with the alias `_nodeIndex`, `_edgeIndex`, `_nodeFulltext` or `_edgeFulltext` to a list of `Index` objects. |
| TABLE | `_privilege` | `AsPrivileges()` | List\<Privilege> | Maps `DataItem` with the alias `_privilege` to a list of `Privilege` objects. |
| TABLE | `_policy` | `AsPolicies()` | List\<Policy> | Maps `DataItem` with the alias `_policy` to a list of `Policy` objects. |
| TABLE | `_user` | `AsUsers()` | List\<User> | Maps `DataItem` with the alias `_user` to a list of `User` objects. |
| TABLE | `_statistic` | `AsStats()` | DatabaseStats | Maps `DataItem` with the alias `_statistic` to a `DatabaseStats` object. |
| TABLE | `_top` | `AsProcesses()` | List\<Process> | Maps `DataItem` with the alias `_top` to a list of `Process` objects. |
| TABLE | `_task` | `AsTasks()` | List\<UltipaTask> | Maps `DataItem` with the alias `_task` to a list of `UltipaTask` objects. |
| TABLE | Any | `AsTable()` | Table | Maps TABLE-type `DataItem` to a `Table` object. |
| ATTR | Any | `AsAttr()` | Attr | Maps ATTR-type `DataItem` to an `Attr` object. |
| ATTR | Any | `AsAttrOriginal()` | AttrList | Maps ATTR-type `DataItem` to an `AttrList` object. |

## Driver Types

### Node

A `Node` object has the following fields:

| Field | Type | <div table-width="50">Description</div> |
| ---- | ---- | ---- |  
| `Uuid` | uint64 | Node UUID |
| `Id` | string | Node ID |
| `Schema` | string | Node Schema |
| `Values` |  Dictionary<string, object?> | Node custom properties |

<p tit= "C#" ></p> 

```c#
var res = await ultipa.Uql("find().nodes() as n return n{*} limit 5", requestConfig);
var nodeList = res.Alias("n")?.AsNodes();
Console.WriteLine("ID of the 1st node: " + JsonConvert.SerializeObject(nodeList[0].Id));
Console.WriteLine(
    "Name of the 1st node: "
        + JsonConvert.SerializeObject(nodeList[0].Values.GetValueOrDefault("name"))
);
```

<p tit= "Output" ></p> 
 
```bash
ID of the 1st node: ULTIPA8000000000000001
Name of the 1st node: Titanic
```

### Edge

An `Edge` object has the following fields:

| Field | Type | <div table-width="50">Description</div> |
| ---- | ---- | ---- |  
| `Uuid` | uint64 | Edge UUID |
| `FromUuid` | uint64 | Start node UUID of the edge |
| `ToUuid` | uint64 | End node UUID of the edge |
| `FromId` | string | Start node ID of the edge |
| `ToId` | string | End node ID of the edge |
| `Schema` | string | Edge Schema |
| `Values` | Dictionary<string, object?> | Edge custom properties |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("find().edges() as e return e{*} limit 5", requestConfig);
var edgeList = res.Alias("e")?.AsEdges();
Console.WriteLine(
    "Value of the 1st edge: " + JsonConvert.SerializeObject(edgeList[0].Values)
);
```

<p tit= "Output" ></p> 
 
```bash
Value of the 1st edge: {"datetime":"2019-01-06T02:56:00Z","timestamp":"2019-01-05T18:57:57Z","targetPost":0}
```

### Path

A `Path` object has the following fields:

| Field | <div table-width="25">Type</div> | <div table-width="45">Description</div> |
| ---- | ---- | ---- |  
| `Nodes` | List\<Node> | Node list of the path |
| `Edges` | List\<Edge> | Edge list of the path |
| `NodeSchemas` | object | Infomation of node schema |
| `EdgeSchemas` | object | Infomation of edge schema |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql(
    "n().e()[:2].n() as paths return paths{*} limit 5",
    requestConfig
);
var pathList = res.Alias("paths")?.AsPaths();
Console.WriteLine(
    "Length of the 1st path: " + JsonConvert.SerializeObject(pathList[0].Edges.Count)
);
Console.WriteLine(
    "Edge list of the 1st path: " + JsonConvert.SerializeObject(pathList[0].Edges)
);
Console.WriteLine(
    "Information of the 2nd node in the 1st path: "
        + JsonConvert.SerializeObject(pathList[0].Nodes[1])
);
```

<p tit= "Output" ></p> 
 
```bash
Length of the 1st path: 2
Edge list of the 1st path: [{"Uuid":7,"FromUuid":27,"ToUuid":1,"Id":"","FromId":"ULTIPA800000000000001B","ToId":"ULTIPA8000000000000001","Schema":"follow","Values":{}},{"Uuid":99,"FromUuid":33,"ToUuid":27,"Id":"","FromId":"ULTIPA8000000000000021","ToId":"ULTIPA800000000000001B","Schema":"follow","Values":{}}]
Information of the 2nd node in the 1st path: {"Uuid":27,"Id":"ULTIPA800000000000001B","Schema":"account","Values":{"year":1988,"industry":"Transportation","name":"Sam123","stringList":[null],"int32List":[null],"float":3.72,"double":3.719999313354492}}
```

### Graph

A `Graph` object has the following fields:

| <div table-width="15">Field</div> | Type | <div table-width="65">Description</div> |
| ---- | ---- | ---- |  
| `Nodes` | List\<Node> | Node list of the path |
| `Edges` | List\<Edge> | Edge list of the path |
| `NodeSchemas` | Dictionary<string, Schema> | Map of all node schemas of the path |
| `EdgeSchemas` | Dictionary<string, Schema>  | Map of all edge schemas of the path |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql(
    "n(as n1).re(as e).n(as n2).limit(3) with toGraph(collect(n1), collect(n2), collect(e)) as graph return graph",
    requestConfig
);
var graphList = res.Alias("graph")?.AsGraph();
var nodeList = graphList.Nodes;
var edgeList = graphList.Edges;
Console.WriteLine("Node IDs: ");
foreach (var node in nodeList)
{
    Console.WriteLine(node.Id);
}
Console.WriteLine("Edge UUIDs: ");
foreach (var edge in edgeList)
{
    Console.WriteLine(edge.Uuid);
}
```

<p tit= "Output" ></p> 
 
```bash
Node IDs:
ULTIPA8000000000000017
ULTIPA8000000000000001
ULTIPA8000000000000061
ULTIPA800000000000001B
Edge UUIDs:
1576
43
29
```

### GraphSet

A `GraphSet` object has the following fields:

| <div table-width="15">Field</div> | Type | <div table-width="65">Description</div> |
| ---- | ---- | ---- |  
| `Id` | string | Graphset ID |
| `Name` | string | Graphset name |
| `Desc` | string | Graphset description |
| `TotalNodes` | ulong | Total number of nodes in the graphset |
| `TotalEdges` | ulong | Total number of edges in the graphset |
| `Status` | string | Graphset status (MOUNTED, MOUNTING, or UNMOUNTED) |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().graph()");
var graphSetList = res.Alias("_graph")?.AsGraphSets();
foreach (var graph in graphSetList)
{
    if (graph.Status.Equals("UNMOUNTED"))
    {
        Console.WriteLine(graph.Name);
    }
}
```

<p tit= "Output" ></p> 
 
```bash
DFS_EG
cyber
cyber2
```

### Schema

A `Schema` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="18">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Schema name |
| `Desc` | string | Schema description |
| `DbType` | DBType | Type of the schema (node or edge) |
| `Total` | int | Total number of nodes/edges of the schema |
| `Properties` | List\<Property> | Property list of the schema |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().node_schema()", requestConfig);
var schemaList = res.Alias("_nodeSchema")?.AsSchemas();
foreach (var schema in schemaList)
{
    Console.WriteLine(schema.Name + " has " + schema.Total + " nodes");
}
```

<p tit= "Output" ></p> 
 
```bash
default has 0 nodes
user has 1092511 nodes
ad has 846811 nodes
```

### Property

A `Property` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="18">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Property name |
| `Desc` | string | Property description |
| `Lte` | bool | Property LTE status |
| `Read` | bool | Property read status |
| `Write` | bool | Property write status |
| `Schema` | string | Associated schema of the property |
| `Type` | PropertyType | Property data type |
| `SubTypes` | PropertyType[] | List of property data type |
| `Extra` | string | Extra information of properties |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().node_property(@account)", requestConfig);
var propertyList = res.Alias("_nodeProperty")?.AsProperties();
foreach (var property in propertyList)
{
    if (property.Lte.Equals(true))
    {
        Console.WriteLine("LTE-ed property name: " + property.Name);
    }
}
```

<p tit= "Output" ></p> 
 
```bash
LTE-ed property name: year
```

### Algo

An `Algo` object has the following fields:

| <div table-width="10">Field</div> | <div table-width="28">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Algorithm name |
| `Param` | string | Parameters of the algorithm |
| `Detail` | string | Algorithm details |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().algo()", requestConfig);
var algoList = res.Alias("_algoList")?.AsAlgos();
Console.WriteLine(JsonConvert.SerializeObject(algoList[0]));
```

<p tit= "Output" ></p> 
 
```bash
{"Name":"bipartite","Param":"{\"name\":\"bipartite\",\"description\":\"bipartite check\",\"version\":\"1.0.1\",\"parameters\":{},\"result_opt\":\"56\"}","Detail":"base:\r\n  category: Connectivity & Compactness\r\n   name: Bipartite\r\n    desc: Judge if the current graph is bipartite.\r\n}
```

### Exta

> An exta is a custom algorithm developed by users.

An `Exta` object has the following fields:

| <div table-width="10">Field</div> | <div table-width="28">Type</div> | Description |
| ---- | ---- | ---- |  
| `Author` | string | Exta author |
| `Name` | string | Exta name |
| `Version` | string | Exta version |
| `Detail` | string | Content of the YML configuration file of the Exta |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().exta()");
var extaList = res.Alias("_extaList")?.AsExtas();
Console.WriteLine(JsonConvert.SerializeObject("Exta name: " + extaList[0].Name));
```

<p tit= "Output" ></p> 
 
```bash
"Exta name: page_rank"
```

### Index

An `Index` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `Schema` | string | Schema name of the index |
| `Name` | string | Index name |
| `Properties` | string | Property name of the index |
| `Status` | string | Index status (done or creating) |
| `Size` | string | Index size in bytes |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().index()", requestConfig);
var indexList = res.Alias("_nodeIndex")?.AsIndexes();
foreach (var index in indexList)
{
    Console.WriteLine("Schema name: " + index.Schema);
    Console.WriteLine("Properties: " + index.Properties);
    Console.WriteLine("Size: " + index.size);
}
```

<p tit= "Output" ></p> 
 
```bash
Schema name: account
Properties: name
Size: 0
Schema name: movie
Properties: name
Size: 2526
```

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().fulltext()", requestConfig);
var fulltextList = res.Alias("_edgeFulltext")?.AsIndexes();
foreach (var item in fulltextList)
{
    Console.WriteLine("Fulltext name: " + item.Name);
    Console.WriteLine("Schema name: " + item.Schema);
    Console.WriteLine("Properties: " + item.Properties);
}
```

<p tit= "Output" ></p> 
 
```bash
Fulltext name: nameFull
Schema name: review
Properties: content
```

### Privilege

A `Privilege` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Privilege name |
| `Level` | PrivilegeType | Privilege type, including GraphLevel and SystemLevel |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().privilege()");
var privilegeList = res.Alias("_privilege")?.AsPrivileges();

var systemPrivilegeList = new List\<string>();
foreach (var item in privilegeList)
{
    if (item.Level == PrivilegeType.SystemLevel)
    {
        systemPrivilegeList.Add(item.Name);
    }
}
Console.WriteLine("System privileges include: ");
Console.WriteLine(JsonConvert.SerializeObject(systemPrivilegeList));
```

<p tit= "Output" ></p> 
 
```bash
System privileges include:
["TRUNCATE","COMPACT","CREATE_GRAPH","SHOW_GRAPH","DROP_GRAPH","ALTER_GRAPH","MOUNT_GRAPH","UNMOUNT_GRAPH","TOP","KILL","STAT","SHOW_POLICY","CREATE_POLICY","DROP_POLICY","ALTER_POLICY","SHOW_USER","CREATE_USER","DROP_USER","ALTER_USER","GRANT","REVOKE","SHOW_PRIVILEGE"]
```

### Policy

A `Policy` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Policy name |
| `GraphPrivileges` | Dictionary<string, List\<string>> | Graph privileges and the corresponding graphsets included in the policy |
| `SystemPrivileges` | List\<string> | System privileges included in the policy |
| `SubPolicies` | List\<string> | Policies included in the policy |
| `PropertyPrivileges` | PropertyPrivilegeMap? | Property privileges included in the policy |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().policy()");
var policyList = res.Alias("_policy")?.AsPolicies();
foreach (var item in policyList)
{
    Console.WriteLine("Policy name: " + item.Name);
}
```

<p tit= "Output" ></p> 
 
```bash
Policy name: operator
Policy name: manager
```

### User

A `User` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `Username` | string | Username |
| `Password` | string | Password |
| `CreatedTime` | string | When the user was created |
| `GraphPrivileges` | Dictionary<string, List\<string>>? | Graph privileges and the corresponding graphsets granted to the user |
| `SystemPrivileges` | List\<string> | System privileges granted to the user |
| `PropertyPrivileges` | PropertyPrivileges | Property privileges granted to the user |
| `Policies` | List\<string> | Policies granted to the user |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().user('Tester')");
var userList = res.Alias("_user")?.AsUsers();
Console.WriteLine("Username: " + userList[0].Username);
Console.WriteLine("Created at: " + userList[0].CreatedTime);
Console.WriteLine(
    "Graph privileges: " + JsonConvert.SerializeObject(userList[0].GraphPrivileges)
);
Console.WriteLine(
    "System privileges: " + JsonConvert.SerializeObject(userList[0].SystemPrivileges)
);
Console.WriteLine(
    "Property privileges: " + JsonConvert.SerializeObject(userList[0].PropertyPrivileges)
);
```

<p tit= "Output" ></p> 
 
```bash
Username: Tester
Created at: 7/26/2024 6:10:06 AM
Graph privileges: {"Ad_Click":["FIND_EDGE","FIND_NODE"],"DFS_EG":["UPDATE","INSERT"]}
System privileges: ["MOUNT_GRAPH"]
Property privileges: {"node":{"read":[["*","*","*"]],"write":[["*","*","*"],["miniCircle","account","name"]],"deny":[]},"edge":{"read":[["*","*","*"]],"write":[["*","*","*"]],"deny":[]}}
```

### Stats

A `DatabaseStats` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `CpuUsage` | string | CPU usage in percentage |
| `MemUsage` | string | Memory usage in megabytes |
| `ExpiredDate` | string | Expiration date of the license |
| `CpuCores` | string | Number of CPU cores |
| `Company` | string | Company name |
| `ServerType` | string | Server type |
| `Version` | string | Version of the server | 

<p tit= "C#" ></p> 
 
```c#  
var res = await ultipa.Uql("stats()");
var statsList = res.Alias("_statistic")?.AsStats();
Console.WriteLine("CPU usage: " + statsList.CpuUsage);
Console.WriteLine("Memory usage: " + statsList.MemUsage);
```

<p tit= "Output" ></p> 
 
```bash
CPU usage: 12.204036
Memory usage: 11348.136719
```

### Process

A `Process` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `Id` | string | Process ID |
| `Uql` | string | The UQL run with the process |
| `Duration` | int | The duration in seconds the task has run so far |
| `Status` | string | Process status |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("top()");
var processList = res.Alias("_top")?.AsProcesses();
Console.WriteLine("Process ID: " + processList[0].Id);
```

<p tit= "Output" ></p> 
 
```bash
Process ID: a_7_14568_1
```

### Task

A `UltipaTask` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `Param` | object | Algorithm parameters and their corresponding values |
| `Info` | TaskInfo | Task information including `TaskID`, `AlgoName`, `StartTime`, `TaskStatus`, etc. |
| `result` | object | Algorithm result and statistics and their corresponding values |
| `ErrorMsg` | string | Error message of the task |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql("show().task()", requestConfig);
var taskList = res.Alias("_task")?.AsTasks();
Console.WriteLine("Algo Name: " + taskList[0].Info.AlgoName);
Console.WriteLine("Parameters: " + taskList[0].Param);
Console.WriteLine("Result: " + taskList[0].result);
```

<p tit= "Output" ></p> 
 
```bash
Algo Name: louvain
Parameters: {"phase1_loop_num":"20","min_modularity_increase":"0.001"}
Result: {
  "community_count": "10",
  "modularity": "0.535017",
  "result_files": "communityID,ids,num"
}
```

### Table

A `Table` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Table name |
| `Headers` | []Property | Table headers |
| `Rows` | []Row | Table rows |

Methods on a `Table` object:

| <div table-width="15">Method</div> | <div table-width="20">Return</div> | Description |
| ---- | ---- | ---- | 
| `ToKv()` | List\<Dictionary<string, object?>>  | Convert all rows of the table to a key-value list. |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql(
    "find().nodes() as n return table(n._id, n._uuid) as myTable limit 5"
);
var myTab = res.Alias("myTable")?.AsTable();
Console.WriteLine("2nd row in table: " + JsonConvert.SerializeObject(myTab.ToKv()[1]));
```

<p tit= "Output" ></p> 
 
```bash
2nd row in table: {"n._id":"ULTIPA8000000000000002","n._uuid":0}
```

### Attr

An `Attr` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `ResultType` | ResultType | Attr type description |
| `PropertyType` | PropertyType | Attr type |
| `Nodes` | List\<Node> | List of `Node` objects |
| `Edges` | List\<Edge> | List of `Edge` objects |
| `Paths` | List\<Path> | List of `Path` objects |
| `Attrs` | AttrList | List of `Attr` objects|
| `Value` | object | Value of the data |

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Uql(
    "find().nodes({@ad}) as n return n.brand limit 5",
    requestConfig
);
var myAttr = res.Alias("n.brand")?.AsAttr();
Console.WriteLine(JsonConvert.SerializeObject(myAttr));
```

<p tit= "Output" ></p> 
 
```bash
[14655,14655,14655,14655,434760]
```
