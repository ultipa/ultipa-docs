# Data Structures

This section introduces the core data structures provided by the driver.

# Node

`Node` includes the following fields:

| <div table-width="12">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |
| `UUID` | `types.UUID` (uint64) | Node `_uuid`. |
| `ID` | `types.ID` (string) | Node `_id`. |
| `Schema` | string | Name of the schema the node belongs to. |
| `Values` | `map[string]interface{}{}` | Node property key-value pairs. |

If a query returns nodes, you can use `AsNodes()` to convert them into a list of `Node`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH (n:User) RETURN n LIMIT 2", requestConfig)
nodes, _, _ := response.Alias("n").AsNodes()
for _, node := range nodes {
  jsonData, err := json.MarshalIndent(node, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

<p tit="Output"></p> 
 
```
{
  "ID": "U4",
  "UUID": 6557243256474697731,
  "Schema": "User",
  "Values": {
    "Data": {
      "name": "mochaeach"
    }
  }
}
{
  "ID": "U2",
  "UUID": 7926337543195328514,
  "Schema": "User",
  "Values": {
    "Data": {
      "name": "Brainy"
    }
  }
}
```

## Edge

`Edge` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |
| `UUID` | `tyeps.UUID` (uint64) | Edge `_uuid`. |
| `FromUUID` | `types.UUID` (uint64) | `_uuid` of the source node of the edge. |
| `ToUUID` | `types.UUID` (uint64) | `_uuid` of the destination node of the edge. |
| `From` | `types.ID` (string) | `_id` of the source node of the edge. |
| `To` | `types.ID` (string) | `_id` of the destination node of the edge. |
| `Schema` | string | Name of the schema the edge belongs to. |
| `Values` | `map[string]interface{}{}` | Edge property key-value pairs. |

If a query returns edges, you can use `AsEdges()` to convert them into a list of `Edge`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH ()-[e]->() RETURN e LIMIT 2", requestConfig)
edges, _, _ := response.Alias("e").AsEdges()
for _, edge := range edges {
  jsonData, err := json.MarshalIndent(edge, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

<p tit="Output"></p> 
 
```
{
  "UUID": 2,
  "FromUUID": 6557243256474697731,
  "ToUUID": 7926337543195328514,
  "From": "U4",
  "To": "U2",
  "Schema": "Follows",
  "Values": {
    "Data": {
      "createdOn": "2024-02-10"
    }
  }
}
{
  "UUID": 3,
  "FromUUID": 7926337543195328514,
  "ToUUID": 17870285520429383683,
  "From": "U2",
  "To": "U3",
  "Schema": "Follows",
  "Values": {
    "Data": {
      "createdOn": "2024-02-01"
    }
  }
}
```

## Path

`Path` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |
| `NodeUUIDs` | []`types.UUID` | The list of node `_uuids` in the path. |
| `EdgeUUIDs` | []`types.UUID` | The list of edge `_uuids` in the path. |
| `Nodes` | `map[types.UUID]*Node` | A map of nodes in the path, where the key is the node’s `_uuid`, and the value is the corresponding node. |
| `Edges` | `map[types.UUID]*Edge` | A map of edges in the path, where the key is the edge’s `_uuid`, and the value is the corresponding edge. |

Methods on `Path`:

| <div table-width="15">Method</div> | <div table-width="15">Parameters</div> | <div table-width="10">Returns</div> | Description |
| ---- | ---- | ---- | ---- |
| `Length()` | / | int | Returns the number of edges in the path. |

If a query returns paths, you can use `AsGraph()` to convert them into a `Graph`; `Graph` provides access to the returned paths.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH p = ()-[]->() RETURN p LIMIT 2", requestConfig)
graph, _ := response.Alias("p").AsGraph()
paths := graph.Paths
for _, path := range paths {
  fmt.Println("Node _uuids:", path.NodeUUIDs, "Length:", path.Length())
}
```

<p tit="Output"></p> 
 
```
Node _uuids: [6557243256474697731 7926337543195328514] Length: 1
Node _uuids: [7926337543195328514 17870285520429383683] Length: 1
```

## Graph

`Graph` includes the following fields:

| <div table-width="10">Field</div> | <div table-width="30">Type</div> | Description |
| ---- | ---- | ---- |
| `Paths` | []`*Path` | The list of returned paths. |
| `Nodes` | `map[types.UUID]*Node` | A map of **unique** nodes in the graph, where the key is the node’s `_uuid`, and the value is the corresponding node. |
| `Edges` | `map[types.UUID]*Edge` | A map of **unique** edges in the graph, where the key is the edge’s `_uuid`, and the value is the corresponding edge. |

Methods on `Graph`:

| <div table-width="15">Method</div> | <div table-width="20">Parameters</div> | <div table-width="10">Returns</div> | Description |
| ---- | ---- | ---- | ---- |
| `AddNode()` | `node: *Node` | / | Adds a `Node` to the graph. Duplicate nodes are not added; `Nodes` remains unique. |
| `AddEdge()` | `edge: *Edge` | / | Adds an `Edge` to the graph. Duplicate edges are not added; `Edges` remains unique. |

If a query returns paths, you can use `AsGraph()` to convert them into a `Graph`.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH p = ()-[]->() RETURN p LIMIT 2", requestConfig)
graph, _ := response.Alias("p").AsGraph()
fmt.Println("Unique nodes UUID:")
for _, node := range graph.Nodes {
  fmt.Println(node.UUID)
}
fmt.Println("Unique edges UUID:")
for _, edge := range graph.Edges {
  fmt.Println(edge.UUID)
}
fmt.Println("All paths:")
for i, path := range graph.Paths {
  fmt.Println("Path", i, "has nodes", path.NodeUUIDs, "and edges", path.EdgeUUIDs)
}
```

<p tit="Output"></p> 
 
```
Unique nodes UUID:
6557243256474697731
7926337543195328514
17870285520429383683
Unique edges UUID:
2
3
All paths:
Path 0 has nodes [6557243256474697731 7926337543195328514] and edges [2]
Path 1 has nodes [7926337543195328514 17870285520429383683] and edges [3]
```

## GraphSet

`GraphSet` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `ID` | `types.ID` (string) | Graph ID. |
| `Name` | string | Graph name. |
| `TotalNodes` | uint64 | Total number of nodes in the graph. |
| `TotalEdges` | uint64 | Total number of edges in the graph. |
| `Shards` | []string | The list of IDs of shard servers where the graph is stored. |
| `PartitionBy` | string | The hash function used for graph sharding, which can be `Crc32` (default), `Crc64WE`, `Crc64XZ`, or `CityHash64`. |
| `Status` | string | Graph status, which can be `NORMAL`, `LOADING_SNAPSHOT`, `CREATING`, `DROPPING`, or `SCALING`. |
| `Description` | string | Graph description. |
| `SlotNum` | int | The number of slots used for graph sharding. |

If a query retrieves graphs (graphsets) in the database, you can use `AsGraphSets()` to convert them into a list of `GraphSet`s.

```go
response, _ := driver.Gql("SHOW GRAPH", nil)
graphsets, _ := response.Get(0).AsGraphSets()
for _, graphset := range graphsets {
  fmt.Println(graphset.Name)
}
```

The `ShowGraph()` method also retrieves graphs (graphsets) in the database, it returns a list of `GraphSet`s directly.

```go
graphsets, _ := driver.ShowGraph(nil)
for _, graphset := range graphsets {
  fmt.Println(graphset.Name)
}
```

<p tit="Output"></p> 
 
```
g1
miniCircle
amz
```

## Schema

`Schema` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- | 
| `Name` | string | Schema name |
| `DBType` | `ultipa.DBType` | `DBNODE` | Schema type, which can be `DBNODE` or `DBEDGE`.  |
| `Properties` | []\*`Property` | The list of properties associated with the schema. |
| `Description` | string | Schema description |
| `Total` | uint64 | Total number of nodes or edges belonging to the schema. |
| `Id` | string | Schema ID. |
| `Stats` | []\*`SchemaStat` | A list of `SchemaStat` values; each `SchemaStat` includes fields `Schema` (schema name), `DBType` (schema type), `FromSchema` (source node schema), `ToSchema` (destination node schema), and `Count` (count of nodes or edges). |

If a query retrieves node or edge schemas defined in a graph, you can use `AsSchemas()` to convert them into a list of `Schema`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "miniCircle"}
response, _ := driver.Gql("SHOW NODE SCHEMA", requestConfig)
schemas, _ := response.Get(0).AsSchemas()
for _, schema := range schemas {
  fmt.Println(schema.Name)
}
```

The `ShowSchema()`, `ShowNodeSchema()` and `ShowEdgeSchema()` methods also retrieve node and edge schemas in a graph, it returns a list of `Schema`s directly.

```go
requestConfig := &configuration.RequestConfig{Graph: "miniCircle"}
schemas, _ := driver.ShowNodeSchema(requestConfig)
for _, schema := range schemas {
  fmt.Println(schema.Name)
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

`Property` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- | 
| `Name` | string | Property name. |
| `Type` | `ultipa.PropertyType` | `UNSET` | Property value type, which can be `INT32`, `UINT32`, `INT64`, `UINT64`, `FLOAT`, `DOUBLE`, `DECIMAL`, `STRING`, `TEXT`, `LOCAL_DATETIME`, `ZONED_DATETIME`, `DATE`, `LOCAL_TIME`, `ZONED_TIME`, `DATETIME`, `TIMESTAMP`, `YEAR_TO_MONTH`, `DAY_TO_SECOND`, `BLOB`, `BOOL`, `POINT`, `LIST`, `SET`, `MAP`, `NULL_`, or `UNSET`. |
| `SubTypes` | []`ultipa.PropertyType` | If the `Type` is `LIST` or `SET`, sets its element type; only one `ultipa.PropertyType` is allowed in the list. |
| `Schema` | string | The associated schema of the property. |
| `Description` | string | Property description. |
| `Lte` | bool | Whether the property is LTE-ed. |
| `Read` | bool | Whether the property is readable. |
| `Write` | bool | Whether the property can be written. |
| `Encrypt` | string | Encryption method of the property, which can be `AES128`, `AES256`, `RSA`, or `ECC`. |
| `DecimalExtra` | `*DecimalExtra` | The precision (1–65) and scale (0–30) of the `DECIMAL` type. |

If a query retrieves node or edge properties defined in a graph, you can use `AsProperties()` to convert them into a list of `Property`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "miniCircle"}
response, _ := driver.Gql("SHOW NODE account PROPERTY", requestConfig)
properties, _ := response.Get(0).AsProperties()
for _, property := range properties {
  fmt.Println(property.Name)
}
```

The `ShowProperty()`, `ShowNodeProperty()` and `ShowEdgeProperty()` methods also retrieve node and edge properties in a graph, it returns a list of `Property`s directly.

```go
requestConfig := &configuration.RequestConfig{Graph: "miniCircle"}
properties, _ := driver.ShowNodeProperty("account", requestConfig)
for _, property := range properties {
  fmt.Println(property.Name)
}
```

<p tit="Output"></p> 
 
```
_id
gender
year
industry
name
```

## Attr

`Attr` includes the following fields:

| <div table-width="20">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |
| `Name` | string | Name of the returned alias. |
| `Values` | `Value` | The returned values. |
| `PropertyType` | `ultipa.PropertyType` | Type of the property. |
| `ResultType` | `ultipa.ResultType` | Type of the results, which can be `RESULT_TYPE_NODE`, `RESULT_TYPE_EDGE`, `RESULT_TYPE_PATH`, `RESULT_TYPE_ATTR`, `RESULT_TYPE_TABLE`, or `RESULT_TYPE_UNSET`. |

If a query returns results like property values, expressions, or computed values, you can use `AsAttr()` to convert them into an `Attr`.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH (n:User) LIMIT 2 RETURN n.name", requestConfig)
attr, _ := response.Alias("n.name").AsAttr()
jsonData, err := json.MarshalIndent(attr, "", "  ")
if err != nil {
  fmt.Println("Error:", err)
}
fmt.Println(string(jsonData))
```

<p tit="Output"></p> 
 
```
{
  "Name": "n.name",
  "PropertyType": 7,
  "ResultType": 4,
  "Values": [
    "mochaeach",
    "Brainy"
  ]
}
```

## Table

`Table` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Table name. |
| `Headers` | []`*Header` | Table headers. |
| `Rows` | []`*Values` | Table rows. |

Methods on `Table`:

| <div table-width="15">Method</div> | <div table-width="15">Parameters</div> | <div table-width="15">Returns</div> | Description |
| ---- | ---- | ---- | ---- | 
| `ToKV()` | / | []`*Values` | Convert all rows in the table to a list of maps. |

If a query uses the `table()` function to return a set of rows and columns, you can use `AsTable()` to convert them into a `Table`.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("MATCH (n:User) LIMIT 2 RETURN table(n._id, n.name) AS result", requestConfig)
table, _ := response.Get(0).AsTable()
jsonData, err := json.MarshalIndent(table, "", "  ")
if err != nil {
  fmt.Println("Error:", err)
}
fmt.Println(string(jsonData))
```

<p tit="Output"></p> 
 
```
{
  "Name": "result",
  "Headers": [
    {
      "Name": "n._id",
      "PropertyType": 7
    },
    {
      "Name": "n.name",
      "PropertyType": 7
    }
  ],
  "Rows": [
    [
      "U4",
      "mochaeach"
    ],
    [
      "U2",
      "Brainy"
    ]
  ]
}
```

## HDCGraph

`HDCGraph` includes the following fields:

| <div table-width="20">Field</div> | <div table-width="8">Type</div> | Description |
| ---- | ---- | ---- | 
| `Name` | string | HDC graph name. |
| `GraphName` | string | The source graph from which the HDC graph is created. |
| `Status` | string | HDC graph status. |
| `Stats` | string | Statistics of the HDC graph. |
| `IsDefault` | string | Whether it is the default HDC graph of the source graph. |
| `HdcServerName` | string | Name of the HDC server that hosts the HDC graph. |
| `HdcServerStatus` | string | Status of the HDC server that hosts the HDC graph. |
| `Config` | string | Configurations of the HDC graph. |

If a query retrieves HDC graphs of a graph, you can use `AsHDCGraphs()` to convert them into a list of `HDCGraph`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("SHOW HDC GRAPH", requestConfig)
hdcGraphs, _ := response.Get(0).AsHDCGraphs()
for _, hdchdcGraph := range hdcGraphs {
  fmt.Println(hdchdcGraph.Name)
}
```

The `ShowHDCGraph()` method also retrieves HDC graphs of a graph, it returns a list of `HDCGraph`s directly.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
hdcGraphs, _ := driver.ShowHDCGraph(requestConfig)
for _, hdchdcGraph := range hdcGraphs {
  fmt.Println(hdchdcGraph.Name)
}
```

<p tit="Output"></p> 
 
```
g1_hdc_full
g1_hdc_nodes
```

## Algo

`Algo` includes the following fields:

| <div table-width="20">Field</div> | <div table-width="17">Type</div> | Description |
| ---- | ---- | ---- |    
| `Name` | string | Algorithm name. |
| `Type` | string | Algorithm type. |
| `Version` | string | Algorithm version. |
| `Params` | []`*AlgoParam` | Algorithm parameters, each `AlgoParam` has fields `Name` and `Desc`. |
| `WriteSupportType` | string | The writeback types supported by the algorithm. |
| `CanRollback` | string | Whether the algorithm version supports rollback. |
| `ConfigContext` | string | The configurations of the algorithm. |

If a query retrieves algorithms installed on an HDC server of the database, you can use `AsAlgos()` to convert them into a list of `Algo`s.

```go
response, _ := driver.Gql("SHOW HDC ALGO ON 'hdc-server-1'", nil)
algos, _ := response.Get(0).AsAlgos()
for _, algo := range algos {
  if algo.Type != "algo" {
    continue
  }
  fmt.Println(algo.Name)
}
```

The `ShowHDCAlgo()` method also retrieves algorithms installed on an HDC server of the database, it returns a list of `Algo`s directly.

```go
algos, _ := driver.ShowHDCAlgo("hdc-server-1", nil)
for _, algo := range algos {
  if algo.Type != "algo" {
    continue
  }
  fmt.Println(algo.Name)
}
```

<p tit="Output"></p> 
 
```
bipartite
fastRP
```

## Projection

`Projection` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="8">Type</div> | Description |
| ---- | ---- | ---- | 
| `Name` | string | Projection name. |
| `GraphName` | string | The source graph from which the projection is created. |
| `Status` | string | Projection status. |
| `Stats` | string | Statistics of the projection. |
| `Config` | string | Configurations of the projection. |

If a query retrieves projections of a graph, you can use `AsProjections()` to convert them into a list of `Projection`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("SHOW PROJECTION", requestConfig)
projections, _ := response.Get(0).AsProjections()
for _, projection := range projections {
  fmt.Println(projection.Name)
}
```

<p tit="Output"></p> 
 
```
distG1
distG1_nodes
```

## Index

`Index` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- | 
| `Id` | string | Index ID. |
| `Name` | string | Index name. |
| `Properties` | string | Properties associated with the index. |
| `Schema` | string | The schema associated with the index |
| `Status` | string | Index status. |
| `DBType` | `ultipa.DBType` | Index type, which can be `DBNODE` or `DBEDGE`. |

If a query retrieves node or edge indexes of a graph, you can use `AsIndexes()` to convert them into a list of `Index`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("SHOW NODE INDEX", requestConfig)
indexes, _ := response.Get(0).AsIndexes()
for _, index := range indexes {
  jsonData, err := json.MarshalIndent(index, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

The `ShowIndex()`, `ShowNodeIndex()`, and `ShowEdgeIndex()` methods also retrieve indexes of a graph, it returns a list of `Index`s directly.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
indexes, _ := driver.ShowIndex(requestConfig)
for _, index := range indexes {
  jsonData, err := json.MarshalIndent(index, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

<p tit="Output"></p> 
 
```
{
  "Id": "1",
  "Name": "User_name",
  "Properties": "name(1024)",
  "Schema": "User",
  "Status": "DONE",
  "DBType": 0
}
```

## Privilege

`Privilege` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="17">Type</div> | Description |
| ---- | ---- | ---- |  
| `Name` | string | Privilege name. |
| `Level` | `PrivilegeLevel` | Privilege level, which can be `SystemPrivilege` or `GraphPrivilege`. |

If a query retrieves privileges defined in Ultipa, you can use `AsPrivileges()` to convert them into a list of `Privilege`s.

```go
response, _ := driver.Uql("show().privilege()", nil)
privileges, _ := response.Get(0).AsPrivileges()

var graphPrivileges []string
var systemPrivileges []string

for _, privilege := range privileges {
  if privilege.Level == structs.GraphPrivilege {
    graphPrivileges = append(graphPrivileges, privilege.Name)
  } else {
    systemPrivileges = append(systemPrivileges, privilege.Name)
  }
}
```

The `ShowPrivilege()` method also retrieves privileges defined in Ultipa, it returns a list of `Privilege`s directly.

```go
privileges, _ := driver.ShowPrivilege(nil)

var graphPrivileges []string
var systemPrivileges []string

for _, privilege := range privileges {
  if privilege.Level == structs.GraphPrivilege {
    graphPrivileges = append(graphPrivileges, privilege.Name)
  } else {
    systemPrivileges = append(systemPrivileges, privilege.Name)
  }
}

fmt.Println("Graph Privileges:", graphPrivileges)
fmt.Println("System Privileges:", systemPrivileges)
```

<p tit="Output"></p> 
 
```
Graph Privileges: [READ INSERT UPSERT UPDATE DELETE CREATE_SCHEMA DROP_SCHEMA ALTER_SCHEMA SHOW_SCHEMA RELOAD_SCHEMA CREATE_PROPERTY DROP_PROPERTY ALTER_PROPERTY SHOW_PROPERTY CREATE_FULLTEXT DROP_FULLTEXT SHOW_FULLTEXT CREATE_INDEX DROP_INDEX SHOW_INDEX LTE UFE CLEAR_JOB STOP_JOB SHOW_JOB ALGO CREATE_PROJECT SHOW_PROJECT DROP_PROJECT CREATE_HDC_GRAPH SHOW_HDC_GRAPH DROP_HDC_GRAPH COMPACT_HDC_GRAPH SHOW_VECTOR_INDEX CREATE_VECTOR_INDEX DROP_VECTOR_INDEX SHOW_CONSTRAINT CREATE_CONSTRAINT DROP_CONSTRAINT]
System Privileges: [TRUNCATE COMPACT CREATE_GRAPH SHOW_GRAPH DROP_GRAPH ALTER_GRAPH CREATE_GRAPH_TYPE SHOW_GRAPH_TYPE DROP_GRAPH_TYPE TOP KILL STAT SHOW_POLICY CREATE_POLICY DROP_POLICY ALTER_POLICY SHOW_USER CREATE_USER DROP_USER ALTER_USER SHOW_PRIVILEGE SHOW_META SHOW_SHARD ADD_SHARD DELETE_SHARD REPLACE_SHARD SHOW_HDC_SERVER ADD_HDC_SERVER DELETE_HDC_SERVER LICENSE_UPDATE LICENSE_DUMP GRANT REVOKE SHOW_BACKUP CREATE_BACKUP SHOW_VECTOR_SERVER ADD_VECTOR_SERVER DELETE_VECTOR_SERVER]
```

## Policy

`Policy` includes the following fields:

| <div table-width="20">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |
| `Name` | string | Policy name. |
| `SystemPrivileges` | []string | System privileges included in the policy. |
| `GraphPrivileges` | `GraphPrivileges` | Graph privileges included in the policy; in the map, the key is the name of the graph, and the value is the corresponding graph privileges. |
| `PropertyPrivileges` | `PropertyPrivileges` | Property privileges included in the policy; the `PropertyPrivilege` has fields `Node` and `Edge`, both are `PropertyPrivilegeElement` values. |
| `policies` | []string | Policies included in the policy. |

`PropertyPrivilegeElement` includes the following fields:

| <div table-width="10">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |
| `Read` | [][]string | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `Write` | [][]string | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `Deny` | [][]string | A list of lists; each inner list contains three strings representing the graph, schema, and property. |

If a query retrieves policies (roles) defined in the database, you can use `AsPolicies()` to convert them into a list of `Policy`s.

```go
response, _ := driver.Gql("SHOW ROLE", nil)
policies, _ := response.Get(0).AsPolicies()
for _, policy := range policies {
  fmt.Println(policy.Name)
}
```

The `ShowPolicy()` method also retrieves policies (roles) defined in the database, it returns a list of `Policy`s directly.

```go
policies, _ := driver.ShowPolicy(nil)
for _, policy := range policies {
  fmt.Println(policy.Name)
}
```

<p tit="Output"></p> 
 
```
manager
Tester
operator
superADM
```

## User

`User` includes the following fields:

| <div table-width="20">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |
| `Username` | string | Username. |
| `Password` | string | Password. |
| `CreatedTime` | string | The time when the user was created. |
| `SystemPrivileges` | []string | System privileges granted to the user. |
| `GraphPrivileges` | `GraphPrivileges` | Graph privileges granted to the user; in the dictionary, the key is the name of the graph, and the value is the corresponding graph privileges. |
| `propertyPrivileges` | `PropertyPrivilege` | Property privileges granted to the user; the `PropertyPrivilege` has fields `Node` and `Edge`, both are `PropertyPrivilegeElement` values. |
| `policies` | []string | Policies granted to the user. |

`PropertyPrivilegeElement` includes the following fields:

| <div table-width="10">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |
| `Read` | [][]string | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `Write` | [][]string | A list of lists; each inner list contains three strings representing the graph, schema, and property. |
| `Deny` | [][]string | A list of lists; each inner list contains three strings representing the graph, schema, and property. |

If a query retrieves database users, you can use `AsUsers()` to convert them into a list of `User`s.

```go
response, _ := driver.Gql("SHOW USER", nil)
users, _ := response.Get(0).AsUsers()
for _, user := range users {
  fmt.Println(user.UserName)
}
```

The `ShowUser()` method also retrieves database users, it returns a list of `User`s directly.

```go
users, _ := driver.ShowUser(nil)
for _, user := range users {
  fmt.Println(user.UserName)
}
```

<p tit="Output"></p> 
 
```
user01
root
johndoe
```

## Process

`Process` includes the following fields:

| <div table-width="18">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- | 
| `ProcessId` | string | Process ID. |
| `ProcessQuery` | string | The query that the process executes. |
| `Status` | string | Process status. |
| `Duration` | string | The duration (in seconds) the process has run. |

If a query retrieves processes running in the database, you can use `AsProcesses()` to convert them into a list of `Process`s.

```go
response, _ := driver.Gql("TOP", nil)
processes, _ := response.Get(0).AsProcesses()
for _, process := range processes {
  jsonData, err := json.MarshalIndent(process, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

The `Top()` method also retrieves processes running in the database, it returns a list of `Process`s directly.

```go
processes, _ := driver.Top(nil)
for _, process := range processes {
  jsonData, err := json.MarshalIndent(process, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

<p tit="Output"></p> 
 
```
{
  "process_id": "3145773",
  "status": "RUNNING",
  "process_query": "MATCH p=()-{1,5}() RETURN p",
  "duration": "2"
}
```

## Job

`Job` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="8">Type</div> | Description |
| ---- | ---- | ---- | 
| `Id` | string | Job ID. |
| `GraphName` | string | Name of the graph where the job executes on. |
| `Query` | string | The query that the job executes. |
| `Type` | string | Job type. |
| `ErrNsg` | string | Error message of the job. |
| `Result` | map[string]string | Result of the job. |
| `StartTime` | string | The time when the job begins. |
| `EndTime` | string | The times when the job ends. |
| `Status` | string | Job status. |
| `Progress` | string | Progress updates for the job, such as indications that the write operation has been started. |

If a query retrieves jobs of a graph, you can use `asJobs()` to convert them into a list of `Job`s.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
response, _ := driver.Gql("SHOW JOB", requestConfig)
jobs, _ := response.Get(0).AsJobs()
for _, job := range jobs {
  jsonData, err := json.MarshalIndent(job, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

The `ShowJob()` method also retrieves processes running in the database, it returns a list of `Job`s directly.

```go
requestConfig := &configuration.RequestConfig{Graph: "g1"}
jobs, _ := driver.ShowJob("", requestConfig)
for _, job := range jobs {
  jsonData, err := json.MarshalIndent(job, "", "  ")
  if err != nil {
    fmt.Println("Error:", err)
    continue
  }
  fmt.Println(string(jsonData))
}
```

<p tit="Output"></p> 
 
```
{
  "job_id": "6",
  "graph_name": "g1",
  "type": "CREATE_INDEX",
  "query": "CREATE INDEX User_name ON NODE User (name)",
  "status": "FINISHED",
  "err_msg": "",
  "result": null,
  "start_time": "2025-09-30 18:23:48",
  "end_time": "2025-09-30 18:23:49",
  "progress": ""
}
{
  "job_id": "6_1",
  "graph_name": "g1",
  "type": "CREATE_INDEX",
  "query": "",
  "status": "FINISHED",
  "err_msg": "",
  "result": null,
  "start_time": "2025-09-30 18:23:49",
  "end_time": "2025-09-30 18:23:49",
  "progress": ""
}
{
  "job_id": "6_2",
  "graph_name": "g1",
  "type": "CREATE_INDEX",
  "query": "",
  "status": "FINISHED",
  "err_msg": "",
  "result": null,
  "start_time": "2025-09-30 18:23:49",
  "end_time": "2025-09-30 18:23:49",
  "progress": ""
}
```