# Data Insertion and Deletion

This section introduces methods on a `Connection` object for inserting nodes and edges to the graph or deleting nodes and edges from the graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Example Graph Data Model

The examples below demonstrate how to insert or delete nodes or edges from a graphset with the following schema and property definitions:

<div align=center drawio-diagram='16645' drawio-name="draw_eef958d9d27649c381cb1e470f4963cc.jpg"><img src="https://img.ultipa.cn/draw/draw_eef958d9d27649c381cb1e470f4963cc.jpg?v='1735097470588'"/></div>

## Property Type Mapping

When inserting nodes or edges, you may need to specify property values of different types. The mapping between Ultipa property types and Go/Driver data types is as follows:

| Ultipa Property Type | <div table-width="65">Go/Driver Type</div> |
| -- | -- |
| int32 | `int32` |
| uint32 | `uint32` |
| int64 | `int64` |
| uint64 | `uint64` |
| float | `float32` |
| double | `float64` |
| decimal | Supports various numeric types (`int32`, `int64`, `float32`, `float64`, `uint32`, `uint64`) and `string`|
| string | `string` |
| text | `string` |
| datetime | `string` |
| timestamp | `string` |
| point | `string`, `type` |
| blob | `[]byte{}`, supports various numeric types (`int32`, `int64`, `float32`, `float64`, `uint32`, `uint64`) and `string` |
| list | `slice` |
| set | `slice` |

## Insertion

### InsertNodes()

Inserts new nodes of a schema to the current graph.
 
**Parameters:**

- `string`: Name of the schema.
- `[]Node`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `nodes` that holds all the inserted nodes when `InsertRequestConfig.Slient` is set to true.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Inserts two nodes into schema 'user' in graphset 'lcc', prints error code and information of the inserted nodes

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "lcc",
}

// There is no alias in Response if InsertRequestConfig.Slient is false
insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
  InsertType:    ultipa.InsertType_NORMAL,
  Silent:        true,
}

var nodes []*structs.Node
node1 := structs.NewNode()
node1.UUID = 1
node1.ID = "U001"
node1.Set("name", "Alice")
node1.Set("age", 18)
node1.Set("score", 65.32)
node1.Set("birthday", "1993-5-4")
node1.Set("location", "point(23.63 104.25)")
node1.Set("profile", "abc")
node1.Set("interests", []string{"tennis", "violin"})
node1.Set("permissionCodes", []int32{2004, 3025, 1025})
node2 := structs.NewNode()
node2.UUID = 2
node2.ID = "U002"
node2.Set("name", "Bob")
nodes = append(nodes, node1, node2)
myInsert, _ := conn.InsertNodes("user", nodes, insertRequestConfig)

println("Operation succeeds:", myInsert.Status.IsSuccess())
nodeList, schemaList, _ := myInsert.Alias("nodes").AsNodes()
printers.PrintNodes(nodeList, schemaList)
```
<p tit="Output"></p> 
 
```
Operation succeeds: true
+------+------+--------+-------+-------+---------------+--------------------------+-----------------------------+------------+-----------------+------------------+
|  ID  | UUID | Schema | name  |  age  |     score     |         birthday         |          location           |  profile   |    interests    | permissionCodes  |
+------+------+--------+-------+-------+---------------+--------------------------+-----------------------------+------------+-----------------+------------------+
| U001 |  1   |  user  | Alice |  18   | 65.3200000000 | 1993-05-04T00:00:00.000Z | POINT(23.630000 104.250000) | [97 98 99] | [tennis violin] | [2004 3025 1025] |
| U002 |  2   |  user  |  Bob  | <nil> |     <nil>     |          <nil>           |            <nil>            |   <nil>    |      <nil>      |      <nil>       |
+------+------+--------+-------+-------+---------------+--------------------------+-----------------------------+------------+-----------------+------------------+
```

### InsertEdges()

Inserts new edges of a schema to the current graph.
 
**Parameters:**

- `string`: Name of the schema.
- `[]Edge`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `edges` that holds all the inserted edges when `InsertRequestConfig.Slient` is set to true.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.


```go
// Inserts two edges into schema 'follows' in graphset 'lcc', prints error code and information of the inserted edges
requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "lcc",
}

// There is no alias in Response if InsertRequestConfig.Slient is false
insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
  InsertType:    ultipa.InsertType_NORMAL,
  Silent:        true,
}

var edges []*structs.Edge
edge1 := structs.NewEdge()
edge1.UUID = 1
edge1.From = "U001"
edge1.To = "U002"
edge1.Set("createdOn", "2024-5-6")
edge2 := structs.NewEdge()
edge2.UUID = 2
edge2.From = "U002"
edge2.To = "U001"
edge2.Set("createdOn", "2024-5-8")
edges = append(edges, edge1, edge2)

myInsert, err := conn.InsertEdges("follows", edges, insertRequestConfig)
if err != nil {
  println(err)
}
println("Operation succeeds:", myInsert.Status.IsSuccess())
edgeList, schemaList, _ := myInsert.Alias("edges").AsEdges()
printers.PrintEdges(edgeList, schemaList)
```
<p tit="Output"></p> 
 
```
Operation succeeds: true
+------+-----------+------+---------+------+---------+-------------------------------+
| UUID | FROM_UUID | FROM | TO_UUID |  TO  | SCHEMA  |           createdOn           |
+------+-----------+------+---------+------+---------+-------------------------------+
|  1   |     1     | U001 |    2    | U002 | follows | 2024-05-06T00:00:00.000+08:00 |
|  2   |     2     | U002 |    1    | U001 | follows | 2024-05-08T00:00:00.000+08:00 |
+------+-----------+------+---------+------+---------+-------------------------------+
```

### InsertNodesBatchBySchema()

Inserts new nodes of a schema into the current graph through gRPC. The properties within the node values must be consistent with those declared in the schema structure.

**Parameters:**

- `Schema`: The target schema.
- `[]Node`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `InsertResponse`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Inserts two nodes into schema 'user' in graphset 'lcc' and prints error code 
requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "lcc",
}

insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
  InsertType:    ultipa.InsertType_OVERWRITE,
}

schema := structs.NewSchema("user")
schema.Properties = append(schema.Properties, &structs.Property{
  Name: "name",
  Type: ultipa.PropertyType_STRING,
}, &structs.Property{
  Name: "age",
  Type: ultipa.PropertyType_INT32,
}, &structs.Property{
  Name: "score",
  Type: ultipa.PropertyType_DECIMAL,
}, &structs.Property{
  Name: "birthday",
  Type: ultipa.PropertyType_DATETIME,
}, &structs.Property{
  Name: "location",
  Type: ultipa.PropertyType_POINT,
}, &structs.Property{
  Name: "profile",
  Type: ultipa.PropertyType_BLOB,
}, &structs.Property{
  Name:     "interests",
  Type:     ultipa.PropertyType_LIST,
  SubTypes: []ultipa.PropertyType{ultipa.PropertyType_STRING},
}, &structs.Property{
  Name:     "permissionCodes",
  Type:     ultipa.PropertyType_SET,
  SubTypes: []ultipa.PropertyType{ultipa.PropertyType_INT32},
})

var nodes []*structs.Node
node1 := structs.NewNode()
node1.UUID = 1
node1.ID = "U001"
node1.Set("name", "Alice")
node1.Set("age", 18)
node1.Set("score", 65.32)
node1.Set("birthday", "1993-5-4")
node1.Set("location", "point(23.63 104.25)")
node1.Set("profile", "abc")
node1.Set("interests", []string{"tennis", "violin"})
node1.Set("permissionCodes", []int32{2004, 3025, 1025})

node2 := structs.NewNode()
node2.UUID = 2
node2.ID = "U002"
node2.Set("name", "Bob")
node2.Set("age", nil)
node2.Set("score", nil)
node2.Set("birthday", nil)
node2.Set("location", nil)
node2.Set("profile", nil)
node2.Set("interests", nil)
node2.Set("permissionCodes", nil)
nodes = append(nodes, node1, node2)

myInsert, err := conn.InsertNodesBatchBySchema(schema, nodes, insertRequestConfig)
if err != nil {
  println(err)
}
println("Operation succeeds:", myInsert.Status.IsSuccess())
```
<p tit="Output"></p> 
 
```
Operation succeeds: true
```

### InsertEdgesBatchBySchema()

Inserts new edges of a schema into the current graph through gRPC. The properties within the edge values must be consistent with those declared in the schema structure.

**Parameters:**

- `Schema`: The target schema.
- `[]Edge`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `InsertResponse`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.


```go
// Inserts two edges into schema 'follows' in graphset 'lcc' and prints error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "lcc",
}

insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
  InsertType:    ultipa.InsertType_OVERWRITE,
}

schema := structs.NewSchema("follows")
schema.Properties = append(schema.Properties, &structs.Property{
  Name: "createdOn",
  Type: ultipa.PropertyType_TIMESTAMP,
})

var edges []*structs.Edge
edge1 := structs.NewEdge()
edge1.UUID = 1
edge1.From = "U001"
edge1.To = "U002"
edge1.Set("createdOn", "2024-5-6")
edge2 := structs.NewEdge()
edge2.UUID = 2
edge2.From = "U002"
edge2.To = "U001"
edge2.Set("createdOn", "2024-5-8")
edges = append(edges, edge1, edge2)

myInsert, err := conn.InsertEdgesBatchBySchema(schema, edges, insertRequestConfig)
if err != nil {
  println(err)
}
println("Operation succeeds:", myInsert.Status.IsSuccess())
```
<p tit="Output"></p> 
 
```
Operation succeeds: true
```

### InsertNodesBatchAuto()

Inserts new nodes of one or multiple schemas to the current graph through gRPC. The properties within node values must be consistent with those defined in the corresponding schema structure.

**Parameters:**

- `[]Node`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `InsertBatchAutoResponse`: Result of the request. 
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Inserts two nodes into schema 'user' and one node into schema `product` in graphset 'lcc' and prints error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "lcc",
}

insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
  InsertType:    ultipa.InsertType_NORMAL,
}

var N1 []*structs.Node
node1 := structs.NewNode()
node1.Schema = "user"
node1.UUID = 1
node1.ID = "U001"
node1.Set("name", "Alice")
node1.Set("age", 18)
node1.Set("score", 65.32)
node1.Set("birthday", "1993-5-4")
node1.Set("location", "point(23.63 104.25)")
node1.Set("profile", "abc")
node1.Set("interests", []string{"tennis", "violin"})
node1.Set("permissionCodes", []int32{2004, 3025, 1025})
N1 = append(N1, node1)
insert1, err := conn.InsertNodesBatchAuto(N1, insertRequestConfig)
if err != nil {
  println(err)
}
for _, item := range insert1.Resps {
  println("Operation succeeds:", item.Status.IsSuccess())
}

var N2 []*structs.Node
node2 := structs.NewNode()
node2.Schema = "user"
node2.UUID = 2
node2.ID = "U002"
node2.Set("name", "Bob")
node2.Set("age", nil)
node2.Set("score", nil)
node2.Set("birthday", nil)
node2.Set("location", nil)
node2.Set("profile", nil)
node2.Set("interests", nil)
node2.Set("permissionCodes", nil)
N2 = append(N2, node2)
insert2, err := conn.InsertNodesBatchAuto(N2, insertRequestConfig)
if err != nil {
  println(err)
}
println(insert1.ErrorCode)
for _, item := range insert2.Resps {
  println("Operation succeeds:", item.Status.IsSuccess())
}

var N3 []*structs.Node
node3 := structs.NewNode()
node3.Schema = "product"
node3.UUID = 3
node3.ID = "P001"
node3.Set("name", "Wireless Earbud")
node3.Set("price", float32(93.2))
N3 = append(N3, node3)
insert3, err := conn.InsertNodesBatchAuto(N3, insertRequestConfig)
if err != nil {
  println(err)
}
for _, item := range insert3.Resps {
  println("Operation succeeds:", item.Status.IsSuccess())
}
```
<p tit="Output"></p> 
 
```
Operation succeeds: true
Operation succeeds: true
Operation succeeds: true
```

### InsertEdgesBatchAuto()

Inserts new edges of one or multiple schemas to the current graph through gRPC. The properties within edge values must be consistent with those defined in the corresponding schema structure.

**Parameters:**

- `[]Edge`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `InsertBatchAutoResponse`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Inserts two edges into schema 'follows' and one edge into schema 'purchased' in graphset 'lcc' and prints error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "lcc",
}

insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
  InsertType:    ultipa.InsertType_NORMAL,
}

var E1 []*structs.Edge
edge1 := structs.NewEdge()
edge1.Schema = "follows"
edge1.UUID = 1
edge1.From = "U001"
edge1.To = "U002"
edge1.Set("createdOn", "2024-5-6")
E1 = append(E1, edge1)

insert1, err := conn.InsertEdgesBatchAuto(E1, insertRequestConfig)
if err != nil {
  println(err)
}
for _, item := range insert1.Resps {
  println("Operation succeeds:", item.Status.IsSuccess())
}

var E2 []*structs.Edge
edge2 := structs.NewEdge()
edge2.Schema = "follows"
edge2.UUID = 2
edge2.From = "U002"
edge2.To = "U001"
edge2.Set("createdOn", "2024-5-8")
E2 = append(E2, edge2)

insert2, err := conn.InsertEdgesBatchAuto(E2, insertRequestConfig)
if err != nil {
  println(err)
}
println(insert1.ErrorCode)
for _, item := range insert2.Resps {
  println("Operation succeeds:", item.Status.IsSuccess())
}

var E3 []*structs.Edge
edge3 := structs.NewEdge()
edge3.Schema = "purchased"
edge3.UUID = 3
edge3.From = "U002"
edge3.To = "P001"
edge3.Set("qty", 1)
E3 = append(E3, edge3)
insert3, err := conn.InsertEdgesBatchAuto(E3, insertRequestConfig)
if err != nil {
  println(err)
}
for _, item := range insert3.Resps {
  println("Operation succeeds:", item.Status.IsSuccess())
}
```
<p tit="Output"></p> 
 
```
Operation succeeds: true
Operation succeeds: true
Operation succeeds: true
```

## Deletion

### DeleteNodes()

Deletes nodes that meet the given conditions from the current graph. It's important to note that deleting a node leads to the removal of all edges that are connected to it.

**Parameters:**

- `string`: The filtering condition to specify the nodes to delete.
- `InsertRequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `nodes` that holds all the deleted nodes when `InsertRequestConfig.Slient` is set to false.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Deletes one @user nodes whose name is 'Alice' from graphset 'lcc' and prints error code
// All edges attached to the deleted node are deleted as well

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "lcc",
}

insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
  InsertType:    ultipa.InsertType_NORMAL,
}

myDeletion, _ := conn.DeleteNodes("{@user.name == 'Alice'}", insertRequestConfig)
println("Operation succeeds:", myDeletion.Status.IsSuccess())
```
<p tit="Output"></p> 
 
```
Operation succeeds: true
```

### DeleteEdges()

Deletes edges that meet the given conditions from the current graph.

**Parameters:**

- `string`: The filtering condition to specify the edges to delete.
- `InsertRequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `edges` that holds all the deleted edges when `InsertRequestConfig.Slient` is set to true.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Deletes all @purchased edges from graphset 'lcc' and prints error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "lcc",
}

insertRequestConfig := &configuration.InsertRequestConfig{
  RequestConfig: requestConfig,
  InsertType:    ultipa.InsertType_NORMAL,
}

deleteEdge, _ := conn.DeleteEdges("{@purchased}", insertRequestConfig)
println("Operation succeeds:", deleteEdge.Status.IsSuccess()
```
<p tit="Output"></p> 
 
```
Operation succeeds: true
```

## Full Example

```go
package main

import (
  ultipa "github.com/ultipa/ultipa-go-sdk/rpc"
  "github.com/ultipa/ultipa-go-sdk/sdk"
  "github.com/ultipa/ultipa-go-sdk/sdk/configuration"
  "github.com/ultipa/ultipa-go-sdk/sdk/structs"
  "github.com/ultipa/ultipa-go-sdk/utils"
)

func main() {

  // Connection configurations
  //URI example: hosts="mqj4zouys.us-east-1.cloud.ultipa.com:60010"
  config, _ := configuration.NewUltipaConfig(&configuration.UltipaConfig{
    Hosts:    []string{"192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061"},
    Username: "***",
    Password: "***",
  })

  // Establishes connection to the database
  conn, _ := sdk.NewUltipa(config)

  // Request configurations
  requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "lcc",
  }

  // Insert Request configurations
  insertRequestConfig := &configuration.InsertRequestConfig{
    RequestConfig: requestConfig,
    InsertType:    ultipa.InsertType_NORMAL,
  }

  // Inserts two nodes into schema 'user' and one node into schema `product` in graphset 'lcc' and prints error code
  var newNodes []*structs.Node
  node1 := structs.NewNode()
  node1.Schema = "user"
  node1.UUID = 1
  node1.ID = "U001"
  node1.Set("name", "Alice")
  node1.Set("age", 18)
  node1.Set("score", 65.32)
  node1.Set("birthday", "1993-5-4")
  node1.Set("location", "point(23.63 104.25)")
  node1.Set("profile", "abc")
  node1.Set("interests", []string{"tennis", "violin"})
  node1.Set("permissionCodes", []int32{2004, 3025, 1025})

  node2 := structs.NewNode()
  node2.Schema = "user"
  node2.UUID = 2
  node2.ID = "U002"
  node2.Set("name", "Bob")
  node2.Set("age", nil)
  node2.Set("score", nil)
  node2.Set("birthday", nil)
  node2.Set("location", nil)
  node2.Set("profile", nil)
  node2.Set("interests", nil)
  node2.Set("permissionCodes", nil)

  node3 := structs.NewNode()
  node3.Schema = "product"
  node3.UUID = 3
  node3.ID = "P001"
  node3.Set("name", "Wireless Earbud")
  node3.Set("price", float32(93.2))

  newNodes = append(newNodes, node1, node2, node3)
  nodeInsert, err := conn.InsertNodesBatchAuto(newNodes, insertRequestConfig)
  if err != nil {
    println(err)
  }

  for _, item := range nodeInsert.Resps {
    println("Node insertion succeeds:", item.Status.IsSuccess())
  }

  // Inserts two edges into schema 'follows' and one edge into schema 'purchased' in graphset 'lcc' and prints error code
  var newEdges []*structs.Edge
  edge1 := structs.NewEdge()
  edge1.Schema = "follows"
  edge1.UUID = 1
  edge1.From = "U001"
  edge1.To = "U002"
  edge1.Set("createdOn", "2024-5-6")

  edge2 := structs.NewEdge()
  edge2.Schema = "follows"
  edge2.UUID = 2
  edge2.From = "U002"
  edge2.To = "U001"
  edge2.Set("createdOn", "2024-5-8")

  edge3 := structs.NewEdge()
  edge3.Schema = "purchased"
  edge3.UUID = 3
  edge3.From = "U002"
  edge3.To = "P001"
  edge3.Set("qty", 1)

  newEdges = append(newEdges, edge1, edge2, edge3)
  edgeInsert, err := conn.InsertEdgesBatchAuto(newEdges, insertRequestConfig)
  if err != nil {
    println(err)
  }
  for _, item := range edgeInsert.Resps {
    println("Edge insertion succeeds:", item.Status.IsSuccess())
  }
};
```
