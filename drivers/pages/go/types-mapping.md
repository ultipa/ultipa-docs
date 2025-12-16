# Types Mapping Ultipa and Go

## Mapping Methods

The `Get()` or `Alias()` method of the `Response` class returns a `DataItem`, which embeds the query result. You should use the `As<Type>()` method of `DataItem` to cast the result to the appropriate driver type.

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("find().nodes() as n return n{*} limit 5", requestConfig)
nodeList, schemaList, _ := myQuery.Alias("n").AsNodes()
printers.PrintNodes(nodeList, schemaList)
```

The result `n` coming from the database contains five nodes, each of the NODE type. The `AsNodes()` method converts them as a list of `Node` objects.

Type mapping methods available on `DataItem`:

| UQL Type | UQL Alias | Method | Driver Type | <div table-width="35">Description</div> |
| -- | -- | -- | -- | -- |
| NODE | Any | `AsNodes()` | []Node | Maps NODE-type `DataItem` to a list of `Node` objects. |
| NODE | Any | `AsFirstNode()` | Node | Maps the first node in a NODE-type `DataItem` to a `Node` object. |
| EDGE | Any | `AsEdges()` | []Edge | Maps EDGE-type `DataItem` to a list of `Edge` objects. |
| EDGE | Any | `AsFirstEdge()` | Edge | Maps the first edge in an EDGE-type `DataItem` to an `Edge` object. |
| PATH | Any | `AsPaths()` | Path[] | Maps PATH-type `DataItem` to a list of `Path` objects. |
| GRAPH | Any | `AsGraph()` | Graph | Maps GRAPH-type `DataItem` to a `Graph` object. |
| TABLE | `_graph` | `AsGraphSets()` | []GraphSet | Maps `DataItem` with the alias `_graph` to a list of `GraphSet` objects. |
| TABLE | `_nodeSchema`, `_edgeSchema` | `AsSchemas()` | []Schema | Maps `DataItem` with the alias `_nodeSchema` or `_edgeSchema` to a list of `Schema` objects. |
| TABLE | `_nodeProperty`, `_edgeProperty` | `AsProperties()` | []Property | Maps `DataItem` with the alias `_nodeProperty` or `_edgeProperty` to a list of `Property` objects. |
| TABLE | `_algoList` | `AsAlgos()` | []Algo | Maps `DataItem` with the alias `_algoList` to a list of `Algo` objects. |
| TABLE | `_extaList` | `AsExtas()` | []Exta | Maps `DataItem` with the alias `_extaList` to a list of `Exta` objects. |
| TABLE | `_nodeIndex`, `_edgeIndex` | `AsIndexes()` | []Index | Maps `DataItem` with the alias `_nodeIndex` or `_edgeIndex` to a list of `Index` objects. |
| TABLE | `_nodeFulltext`, `_edgeFulltext` | `AsFullTexts()` | []Index | Maps `DataItem` with the alias `_nodeFulltext` or `_edgeFulltext` to a list of `Index` objects. |
| TABLE | `_privilege` | `AsPriviliege()` | []Priviliege | Maps `DataItem` with the alias `_privilege` to a `Priviliege` object. |
| TABLE | `_policy` | `AsPolicies()` | []Policy | Maps `DataItem` with the alias `_policy` to a list of `Policy` objects. |
| TABLE | `_user` | `AsUsers()` | []User | Maps `DataItem` with the alias `_user` to a list of `User` objects. |
| TABLE | `_statistic` | `AsStats()` | Stat | Maps `DataItem` with the alias `_statistic` to a `Stat` object. |
| TABLE | `_top` | `AsTops()` | []Top | Maps `DataItem` with the alias `_top` to a list of `Process` objects. |
| TABLE | `_task` | `AsTasks()` | []Task | Maps `DataItem` with the alias `_task` to a list of `Task` objects. |
| TABLE | Any | `AsTable()` | Table | Maps TABLE-type `DataItem` to a `Table` object. |
| ATTR | Any | `AsAttr()` | Attr | Maps ATTR-type `DataItem` to an `Attr` object. |

## Driver Types

> Objects of all driver types support **getter methods** to retrieve the value of a field and **setter methods** to set the value of a field, even if they are not explicitly listed below.

### Node

A `Node` object has the following fields:

| Field | Type | <div table-width="50">Description</div> |
| ---- | ---- | ---- |  
| `Name` | string | Alias name |
| `ID` | string | Node ID |
| `UUID` | uint64 | Node UUID |
| `Schema` | string | Node Schema |
| `Values` | object | Node custom properties |

Methods on a `Node` object:

| <div table-width="27">Method</div> | <div table-width="10">Return</div> | Description |
| ---- | ---- | ---- |
| `get("<propertyName>")` | Object | Get value of the given custom property of the node. |
| `set("<propertyName>", <propertyValue>` |  | Set value for the given custom property of the node; or add a key-value pair to the `Values` of the node if the given `<propertyName>` does not exist. |

<p tit= "Go" ></p> 

```go
myQuery, _ := conn.Uql("find().nodes() as n return n{*} limit 5", requestConfig)
nodeList, _, _ := myQuery.Alias("n").AsNodes()

println("ID of the 1st node:", nodeList[0].GetID())
println("Name of the 1st node:", nodeList[0].GetSchema())
```

<p tit= "Output" ></p> 
 
```bash
ID of the 1st node: ULTIPA8000000000000001
Name of the 1st node: account
```

### Edge

An `Edge` object has the following fields:

| Field | Type | <div table-width="50">Description</div> |
| ---- | ---- | ---- |  
| `Name` | string | Alias name |
| `From` | string | Start node ID of the edge |
| `To` | string | End node ID of the edge |
| `FromUUID` | uint64 | Start node UUID of the edge |
| `ToUUID` | uint64 | End node UUID of the edge |
| `UUID` | uint64 | Edge UUID |
| `Schema` | string | Edge Schema |
| `values` | object | Edge custom properties |

Methods on an `Edge` object:

| <div table-width="27">Method</div> | <div table-width="10">Return</div> | Description |
| ---- | ---- | ---- | 
| `get("<propertyName>")` | Object | Get value of the given custom property of the edge. |
| `set("<propertyName>", <propertyValue>` |  | Set value for the given custom property of the edge; or add a key-value pair to the values of the edge if the given `<propertyName>` does not exist. |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("find().edges() as e return e{*} limit 5", requestConfig)
edgeList, _ := myQuery.Alias("e").AsFirstEdge()

println("Values of the 1st edge:", utils.JSONString(edgeList.GetValues()))
```

<p tit= "Output" ></p> 
 
```bash
Values of the 1st edge: {"Data":{"datetime":{"Datetime":1847052190913396736,"Year":2019,"Month":1,"Day":6,"Hour":2,"Minute":57,"Second":57,"Macrosec":0,"Time":"2019-01-06T02:57:57Z"},"targetPost":703,"timestamp":{"Datetime":1847052190913396736,"Year":2019,"Month":1,"Day":6,"Hour":2,"Minute":57,"Second":57,"Macrosec":0,"Time":"2019-01-06T02:57:57+08:00"}}}
```

### Path

A `Path` object has the following fields:

| Field | <div table-width="25">Type</div> | <div table-width="45">Description</div> |
| ---- | ---- | ---- |  
| `Name` | string | Alias name |
| `Nodes` | []Node | Node list of the path |
| `Edges` | []Edge | Edge list of the path |
| `NodeSchemas` | object | Infomation of node schema |
| `EdgeSchemas` | object | Infomation of edge schema |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("n().e()[:2].n() as paths return paths{*} limit 5", requestConfig)
pathList, _ := myQuery.Alias("paths").AsPaths()

println("Length of the 1st path:", pathList[0].GetLength())
println("Edge list of the 1st path:", "\n", utils.JSONString(pathList[0].GetEdges()))
println("Information of the 2nd node in the 1st path:", "\n", utils.JSONString(pathList[0].GetNodes()[1]))
```

<p tit= "Output" ></p> 
 
```bash
Length of the 1st path: 2
Edge list of the 1st path: 
 [{"Name":"paths","From":"u_10032","To":"u_105","FromUUID":27,"ToUUID":1,"UUID":2784,"Schema":"follow","Values":{"Data":{}}},{"Name":"paths","From":"u_10071","To":"u_10032","FromUUID":33,"ToUUID":27,"UUID":2876,"Schema":"follow","Values":{"Data":{}}}]
Information of the 2nd node in the 1st path: 
 {"Name":"paths","ID":"u_10032","UUID":27,"Schema":"account","Values":{"Data":{"birthYear":1988,"fRate":null,"gender":"male","industry":"Transportation","name":"floatingnote","new":null,"new1":null,"new2":null,"records":null,"tags":null}}}
```

### Graph

A `Graph` object has the following fields:

| Field | <div table-width="25">Type</div> | <div table-width="45">Description</div> |
| ---- | ---- | ---- |  
| `Name` | string | Alias name |
| `Nodes` | []Node | Node list of the path |
| `Edges` | []Edge | Edge list of the path |
| `NodeSchemas` | object | Map of all node schemas of the path |
| `EdgeSchemas` | object | Map of all edge schemas of the path |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("n(as n1).re(as e).n(as n2).limit(3) with toGraph(collect(n1), collect(n2), collect(e)) as graph return graph", requestConfig)
resp, _ := myQuery.Alias("graph").AsGraph()

println("Node IDs:")
for _, item := range resp.Nodes {
  println(item.ID)
}
println("Edge UUIDs:")
for _, item := range resp.Edges {
  println(item.UUID)
}
```

<p tit= "Output" ></p> 
 
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
| `ID` | string | Graphset ID |
| `Name` | string | Graphset name |
| `Description` | string | Graphset description |
| `TotalNodes` | string | Total number of nodes in the graphset |
| `TotalEdges` | string | Total number of edges in the graphset |
| `Status` | string | Graphset status (MOUNTED, MOUNTING, or UNMOUNTED) |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().graph()", nil)
resp, _ := myQuery.Alias("_graph").AsGraphSets()

for _, item := range resp {
  if item.Status == "UNMOUNTED" {
    println(item.Name)
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
| `Properties` | []Property | Property list of the schema |
| `Desc` | string | Schema description |
| `Type` | string | Type of the schema (node or edge) |
| `DBType` | DBType | Type of the schema (node or edge) |
| `Total` | int | Total number of nodes/edges of the schema |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().node_schema()", requestConfig)
resp, _ := myQuery.Alias("_nodeSchema").AsSchemas()

for _, item := range resp {
  println(item.Name, "has", item.Total, "nodes")
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
| `Schema` | string | Associated schema of the property |
| `Type` | PropertyType | Property data type |
| `SubTypes` | []PropertyType | List of property data type |
| `Extra` | string | Extra information of properties |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().node_property(@user)", requestConfig)
resp, _ := myQuery.Alias("_nodeProperty").AsProperties()

for _, item := range resp {
  if item.Lte {
    println("LTE-ed property name:", item.Name)
  }
}
```

<p tit= "Output" ></p> 
 
```bash
LTE-ed property name: occupation
```

### Algo

An `Algo` object has the following fields:

| <div table-width="10">Field</div> | <div table-width="28">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Algorithm name |
| `Desc` | string | Algorithm description |
| `Version` | string | Algorithm version |
| `Params` | object | Parameters of the algorithm |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().algo()", requestConfig)
resp, _ := myQuery.Alias("_algoList").AsAlgos()

println(utils.JSONString(resp[0]))
```

<p tit= "Output" ></p> 
 
```bash
{"Name":"bipartite","Desc":"bipartite check","Version":"1.0.1","Params":{}}
```

### Exta

> An exta is a custom algorithm developed by users.

An `Exta` object has the following fields:

| <div table-width="10">Field</div> | <div table-width="28">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Exta name |
| `Author` | string | Exta author |
| `Version` | string | Exta version |
| `Detail` | string | Content of the YML configuration file of the Exta |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().exta()")
resp, _ := myQuery.Alias("_extaList").AsExtas()

println("Exta name:", utils.JSONString(resp[0].Name))
```

<p tit= "Output" ></p> 
 
```bash
Exta name: "page_rank"
```

### Index

An `Index` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Index name |
| `Properties` | string | Property name of the index |
| `Schema` | string | Schema name of the index |
| `Status` | string | Index status (done or creating) |
| `Size` | string | Index size in bytes |
| `Type` | string | Index type (DBNODE or DBEDGE) |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().index()", requestConfig)
resp, _ := myQuery.Alias("_nodeIndex").AsIndexes()

for i := 0; i < len(resp); i++ {
  println("Schema name:", resp[i].Schema)
  println("Properties:", resp[i].Properties)
  println("Size:", resp[i].Size)
}
```

<p tit= "Output" ></p> 
 
```bash
Schema name: user
Properties: shopping_level
Size: 4608287
Schema name: ad
Properties: price
Size: 7828760
```

### Full-text

A `FullText` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Index name |
| `Properties` | string | Property name of the index |
| `Schema` | string | Schema name of the index |
| `Status` | string | Index status (done or creating) |
| `Size` | string | Index size in bytes |
| `Type` | string | Index type (DBNODE or DBEDGE) |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().fulltext()", requestConfig)
resp, _ := myQuery.Alias("_edgeFulltext").AsFullTexts()

for i := 0; i < len(resp); i++ {
  println("Fulltext name:", resp[i].Name)
  println("Schema name:", resp[i].Schema)
  println("Properties:", resp[i].Properties)
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
| `GraphPrivileges` | []string | Graph privileges |
| `SystemPrivileges` | []string | System privileges |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().privilege()", requestConfig)
resp, _ := myQuery.Alias("_privilege").AsPrivilege()

println(utils.JSONString(resp[0].SystemPrivileges))
```

<p tit= "Output" ></p> 
 
```bash
["TRUNCATE","COMPACT","CREATE_GRAPH","SHOW_GRAPH","DROP_GRAPH","ALTER_GRAPH","MOUNT_GRAPH","UNMOUNT_GRAPH","TOP","KILL","STAT","SHOW_POLICY","CREATE_POLICY","DROP_POLICY","ALTER_POLICY","SHOW_USER","CREATE_USER","DROP_USER","ALTER_USER","GRANT","REVOKE","SHOW_PRIVILEGE"]
```

### Policy

A `Policy` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Policy name |
| `GraphPrivileges` | GraphPrivileges | Graph privileges and the corresponding graphsets included in the policy |
| `SystemPrivileges` | []string | System privileges included in the policy |
| `PropertyPrivileges` | PropertyPrivileges | Property privileges included in the policy |
| `Policies` | []string | Policies included in the policy |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().policy()", requestConfig)
resp, _ := myQuery.Alias("_policy").AsPolicies()

for i := 0; i < len(resp); i++ {
  println(resp[i].Name)
}
```

<p tit= "Output" ></p> 
 
```bash
operator
manager
```

### User

A `User` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `Username` | string | Username |
| `Password` | string | Password |
| `Create` | string | When the user was created |
| `GraphPrivileges` | GraphPrivileges | Graph privileges and the corresponding graphsets granted to the user |
| `SystemPrivileges` | []string | System privileges granted to the user |
| `Policies` | []string | Policies granted to the user |
| `PropertyPrivileges` | PropertyPrivileges | Property privileges granted to the user |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().user('Tester')", requestConfig)
resp, _ := myQuery.Alias("_user").AsUsers()

println("Username:", resp[0].UserName)
println("Created at:", resp[0].Create)
println("Graph privileges:", utils.JSONString(resp[0].GraphPrivileges))
println("System privileges:", utils.JSONString(resp[0].SystemPrivileges))
println("Property privileges:", utils.JSONString(resp[0].PropertyPrivileges))
```

<p tit= "Output" ></p> 
 
```bash
Username: Tester
Created at: 1970-01-01 08:00:00
Graph privileges: {"Ad_Click":["FIND_EDGE","FIND_NODE"],"DFS_EG":["UPDATE","INSERT"]}
System privileges: ["MOUNT_GRAPH"]
Property privileges: {"edge":{"deny":[],"read":[],"write":[]},"node":{"deny":[],"read":[],"write":[["miniCircle","account","name"]]}}
```

### Stats

A `Stat` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `CPUUsage` | string | CPU usage in percentage |
| `MemUsage` | string | Memory usage in megabytes |
| `ExpiredDate` | string | Expiration date of the license |
| `CPUCores` | string | Number of CPU cores |
| `Company` | string | Company name |
| `ServerType` | string | Server type |
| `Version` | string | Version of the server | 

<p tit= "Go" ></p> 
 
```go  
myQuery, _ := conn.Uql("stats()", requestConfig)
resp, _ := myQuery.Alias("_statistic").AsStats()

println("CPU usage::", resp.CPUUsage, "%")
println("Memory usage:", resp.MemUsage, "%")
```

<p tit= "Output" ></p> 
 
```bash
CPU usage: 16.926739 %
Memory usage: 11558.082031 %
```

### Process

A `Process` (`Top`) object has the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `ProcessId` | string | Process ID |
| `Status` | string | Process status |
| `ProcessUql` | string | The UQL run with the process |
| `Duration` | string | The duration in seconds the task has run so far |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("top()", requestConfig)
resp, _ := myQuery.Alias("_top").AsTops()

println(resp[0].ProcessId)
```

<p tit= "Output" ></p> 
 
```bash
a_5_15518_2
```

### Task

A `Task` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `Param` | object | Algorithm parameters and their corresponding values |
| `TaskInfo` | TaskInfo | Task information including `TaskID`, `AlgoName`, `StartTime`, `TaskStatus`, etc. |
| `ErrorMsg` | string | Error message of the task |
| `Result` | object | Algorithm result and statistics and their corresponding values |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("show().task()", requestConfig)
resp, _ := myQuery.Alias("_task").AsTasks()

println("Algo name:", resp[0].TaskInfo.AlgoName)
println("Parameters:", utils.JSONString(resp[0].Param))
println("Result:", utils.JSONString(resp[0].Result))
```

<p tit= "Output" ></p> 
 
```bash
Algo name: louvain
Parameters: {"min_modularity_increase":"0.001","phase1_loop_num":"20"}
Result: {"community_count":"1228589","modularity":"0.635263","result_files":"communityID"}
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
| `ToKV()` | []Values | Convert all rows of the table to a key-value list. |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("find().nodes() as n return table(n._id, n._uuid) as myTable limit 5", requestConfig)
resp, _ := myQuery.Alias("myTable").AsTable()

println("2nd row in table:", utils.JSONString(resp.ToKV()[1]))
```

<p tit= "Output" ></p> 
 
```bash
2nd row in table: {"Data":{"n._id":"u604510","n._uuid":2}}
```

### Attr

An `Attr` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Alias name |
| `PropertyType` | PropertyType | Attr type |
| `ResultType` | ResultType | Attr type description |
| `Rows` | Row | Attr rows |

<p tit= "Go" ></p> 
 
```go
myQuery, _ := conn.Uql("find().nodes({@ad}) as n return n.brand limit 5", requestConfig)
resp, _ := myQuery.Alias("n.brand").AsAttr()
println(utils.JSONString(resp.Rows))
```

<p tit= "Output" ></p> 
 
```bash
[14655,14655,14655,14655,434760]
```
null
