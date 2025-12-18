# Schema and Property Management

This section introduces methods on a `Connection` object for managing schemas and properties of nodes and edges in a graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Schema

### ShowSchema()

Retrieves all nodes and edge schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Schema`: The list of all schemas in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all schemas in graphset 'UltipaTeam' and prints their names and types

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

mySchema, _ := conn.ShowSchema(requestConfig)
for _, item := range mySchema {
    fmt.Print("Schema name:", item.Name, "  Schema type:", item.Type, "\n")
}
```

<p tit="Output"></p> 
 
```java
Schema name:default  Schema type:node
Schema name:member  Schema type:node
Schema name:organization  Schema type:node
Schema name:default  Schema type:edge
Schema name:reportsTo  Schema type:edge
Schema name:relatesTo  Schema type:edge{ Name: 'relatesTo', dbType: 'DBEDGE' }
]
```

### GetSchema()

Retrieves a node or edge schema from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `ultipa.DBType`: Type of the schema (node or edge).
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Schema`: The retrieved schema.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves node schema 'member' and edge schema 'connectsTo' in graphset 'UltipaTeam', and prints all their information

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

nodeSchema, _ := conn.GetSchema("member", ultipa.DBType_DBNODE, requestConfig)
if nodeSchema != nil {
    println("Name:", nodeSchema.Name, "Type:", nodeSchema.Type+" schema", " Number:", nodeSchema.Total)
} else {
    println("Not exists")
}

edgeSchema, _ := conn.GetSchema("connectsTo", ultipa.DBType_DBEDGE, requestConfig)
if edgeSchema != nil {
    println("Name:", edgeSchema.Name, "Type:", edgeSchema.Type+" schema", " Number:", edgeSchema.Total)
} else {
    println("Not exists")
}

```

<p tit="Output"></p> 
 
```java
Name: member Type: node schema  Number: 7
Not exists
```

### ShowNodeSchema()

Retrieves all node schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Schema`: The list of all node schemas in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all node schemas in graphset 'UltipaTeam' and prints their names

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

nodeSchema, _ := conn.ShowNodeSchema(requestConfig)
for _, item := range nodeSchema {
    println(item.Name)
}
```

<p tit="Output"></p> 
 
```java
default
member
organization
```

### ShowEdgeSchema()

Retrieves all edge schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Schema`: The list of all edge schemas in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all edge schemas in graphset 'UltipaTeam' and prints their names

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

edgeSchema, _ := conn.ShowEdgeSchema(requestConfig)
for _, item := range edgeSchema {
    println(item.Name)
}
```

<p tit="Output"></p> 
 
```java
default
reportsTo
relatesTo
```

### GetNodeSchema()

Retrieves a node schema from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Schema`: The retrieved node schema.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves node schema 'member' in graphset 'UltipaTeam' and prints its properties

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

mySchema, _ := conn.GetNodeSchema("member", requestConfig)
println(utils.ToJSONString(mySchema.Properties))
```

<p tit="Output"></p> 
 
```java
[{"Name":"title","Desc":"","Lte":false,"Read":false,"Write":false,"Schema":"member","Type":7,"SubTypes":null,"Extra":"{}","Encrypt":""},{"Name":"profile","Desc":"","Lte":false,"Read":false,"Write":false,"Schema":"member","Type":7,"SubTypes":null,"Extra":"{}","Encrypt":""},{"Name":"age","Desc":"","Lte":false,"Read":false,"Write":false,"Schema":"member","Type":1,"SubTypes":null,"Extra":"{}","Encrypt":""}]
```

### GetEdgeSchema()

Retrieves an edge schema from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Schema`: The retrieved edge schema.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves edge schema 'relatesTo' in graphset 'UltipaTeam' and prints its properties

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

mySchema, _ := conn.GetEdgeSchema("relatesTo", requestConfig)
println(utils.ToJSONString(mySchema.Properties))
```

<p tit="Output"></p> 
 
```java
[{"Name":"type","Desc":"","Lte":false,"Read":false,"Write":false,"Schema":"relatesTo","Type":7,"SubTypes":null,"Extra":"{}","Encrypt":""}]
```

### CreateSchema()

Creates a new schema in the current graphset.

**Parameters:**

- `Schema`: The schema to be created; the fields `Name` and `DBType` must be set, `Desc` (short for description) and `Properties` are optional.
- `bool`: Whether to create properties, the default is `false`.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

// Creates node schema 'utility' (with properties) in graphset 'UltipaTeam' and prints all its information

newNodeSchema, _ := conn.CreateSchema(&structs.Schema{Name: "utility", Properties: []*structs.Property{{Name: "name", Type: ultipa.PropertyType_STRING}, {Name: "purchaseDate", Type: ultipa.PropertyType_DATETIME}}, DBType: ultipa.DBType_DBNODE, Desc: "Office utilities"}, true, requestConfig)
println("Node Schema Creation Succeeds: ", newNodeSchema.Status.IsSuccess())
println(utils.JSONString(newNodeSchema))

// Creates edge schema 'managedBy' (without properties) in graphset 'UltipaTeam' and prints all its information

newEdgeSchema, _ := conn.CreateSchema(&structs.Schema{Name: "managedBy", DBType: ultipa.DBType_DBEDGE}, false, requestConfig)
println("Edge Schema Creation Succeeds: ", newEdgeSchema.Status.IsSuccess())
println(utils.JSONString(newEdgeSchema))

```

<p tit="Output"></p> 
 
```java
Node Schema Creation Succeeds:  true
{"DataItemMap":{},"Reply":{"status":{},"statistics":{"table_name":"statistics","headers":[{"property_name":"node_affected","property_type":7},{"property_name":"edge_affected","property_type":7},{"property_name":"total_time_cost","property_type":7},{"property_name":"engine_time_cost","property_type":7}],"table_rows":[{"values":["MA==","MA==","MA==","MA=="]}]},"explain_plan":{}},"Status":{"Message":"","Code":0},"Statistic":{"NodeAffected":0,"EdgeAffected":0,"TotalCost":0,"EngineCost":0},"ExplainPlan":{"Explain":[]},"AliasList":null,"Resp":{"ClientStream":{}}}
Edge Schema Creation Succeeds:  true
{"DataItemMap":{},"Reply":{"status":{},"statistics":{"table_name":"statistics","headers":[{"property_name":"node_affected","property_type":7},{"property_name":"edge_affected","property_type":7},{"property_name":"total_time_cost","property_type":7},{"property_name":"engine_time_cost","property_type":7}],"table_rows":[{"values":["MA==","MA==","MA==","MA=="]}]},"explain_plan":{}},"Status":{"Message":"","Code":0},"Statistic":{"NodeAffected":0,"EdgeAffected":0,"TotalCost":0,"EngineCost":0},"ExplainPlan":{"Explain":[]},"AliasList":null,"Resp":{"ClientStream":{}}}
```

### CreateSchemaIfNotExist()

Creates a new schema in the current graphset, handling cases where the given schema name already exists by ignoring the error.

**Parameters:**

- `Schema`: The schema to be created; the fields `Name` and `DBType` must be set, `Desc` and `Properties` are optional.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `bool`: Whether the schema exists.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

// Creates one schema in graphset 'UltipaTeam' and prints if the schema already exists

cre1, _ := conn.CreateSchemaIfNotExist(&structs.Schema{Name: "utility", DBType: ultipa.DBType_DBNODE, Desc: "Office utilities"}, requestConfig)
println("Schema already exists: ", cre1)

// Creates the same schema again and prints if the schema already exists

cre2, _ := conn.CreateSchemaIfNotExist(&structs.Schema{Name: "utility", DBType: ultipa.DBType_DBNODE, Desc: "Office utilities"}, requestConfig)
println("Schema already exists: ", cre2)

```

<p tit="Output"></p> 
 
```java
Schema already exists:  false
Schema already exists:  true
```

### AlterSchema()

Alters the name and description of one existing schema in the current graphset by its name.

**Parameters:**

- `Schema`: The existing schema to be altered; the fields `Name` and `DBType` must be set. 
- `Schema`: The new configuration for the existing schema; either or both of the fields `Name` and `Desc` (short for description) must be set.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Renames the node schema 'utility' to 'securityUtility' and removes its description in graphset 'UltipaTeam'

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

resp, _ := conn.AlterSchema(&structs.Schema{Name: "utility", DBType: ultipa.DBType_DBNODE}, &structs.Schema{Name: "securityUtility"}, requestConfig)
println("Operation succeeds:", resp.Status.IsSuccess())
```

<p tit="Output"></p> 
 
```java
Operation succeeds: true
```

### DropSchema()

Drops one schema from the current graphset by its name.

**Parameters:**

- `Schema`: The existing schema to be dropped; the fields `Name` and `DBType` must be set. 
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Drops the node schema 'utility' in graphset 'UltipaTeam'

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

resp, _ := conn.DropSchema(&structs.Schema{Name: "utility", DBType: ultipa.DBType_DBNODE}, requestConfig)
println("Operation succeeds:", resp.Status.IsSuccess())
```

<p tit="Output"></p> 
 
```java
Operation succeeds: true
```

## Property

### ShowProperty()

Retrieves custom properties of nodes or edges from the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Property`: The list of all properties retrieved in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all node properties in graphset 'UltipaTeam' and prints their names and associated schemas

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

resp, _ := conn.ShowNodeSchema(requestConfig)
for _, item := range resp {
    proList, _ := conn.ShowProperty(ultipa.DBType_DBNODE, item.Name, requestConfig)
    for _, pro := range proList {
        println(pro.Name, "is associated with schema named", item.Name)
    }
}
```

<p tit="Output"></p> 
 
```java
title is associated with schema named member
profile is associated with schema named member
age is associated with schema named member
name is associated with schema named organization
logo is associated with schema named organization
```

### ShowNodeProperty()

Retrieves custom properties of nodes from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Property`: The list of all properties retrieved in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all custom properties of node schema 'member' in graphset 'UltipaTeam' and prints the count

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

myCount, _ := conn.ShowNodeProperty("member", requestConfig)
println(len(myCount))
```

<p tit="Output"></p> 
 
```java
3
```

### ShowEdgeProperty()

Retrieves custom properties of edges from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Property`: The list of all properties retrieved in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all custom properties of edge schema 'relatesTo' in graphset 'UltipaTeam' and prints their names

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}
myEdge, _ := conn.ShowEdgeProperty("relatesTo", requestConfig)
if myEdge != nil {
    for _, item := range myEdge {
        println(item.Name)
    }
} else {
    println("No property")
}
```

<p tit="Output"></p> 
 
```java
type
```

### GetProperty()

Retrieves a custom property of nodes or edges from the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Property`: The retrieved property.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves node property @member.title in graphset 'UltipaTeam' and prints all its information

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

proInfo, _ := conn.GetProperty(ultipa.DBType_DBNODE, "member", "title", requestConfig)
println(utils.ToJSONString(proInfo))

```

<p tit="Output"></p> 
 
```java
{"Name":"title","Desc":"","Lte":false,"Read":false,"Write":false,"Schema":"member","Type":7,"SubTypes":null,"Extra":"{}","Encrypt":""}
```

### GetNodeProperty()

Retrieves a custom property of nodes from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Property`: The retrieved property.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves node property @member.title in graphset 'UltipaTeam' and prints all its information

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

proInfo, _ := conn.GetNodeProperty("member", "title", requestConfig)
println(utils.ToJSONString(proInfo))
```

<p tit="Output"></p> 
 
```java
{"Name":"title","Desc":"","Lte":false,"Read":false,"Write":false,"Schema":"member","Type":7,"SubTypes":null,"Extra":"{}","Encrypt":""}
```

### GetEdgeProperty()

Retrieves a custom property of edges from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Property`: The retrieved property.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves edge property @relatesTo.type in graphset 'UltipaTeam' and prints all its information

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

proInfo, _ := conn.GetEdgeProperty("relatesTo", "type", requestConfig)
println(utils.ToJSONString(proInfo))
```

<p tit="Output"></p> 
 
```java
{"Name":"type","Desc":"","Lte":false,"Read":false,"Write":false,"Schema":"relatesTo","Type":7,"SubTypes":null,"Extra":"{}","Encrypt":""}
```

### CreateProperty()

Creates a new property for a node or edge schema in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema, write `*` to specify all schemas.
- `Property`: The property to be created; the fields `Name` and `Type` must be set.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Creates two properties for node schema 'member' in graphset 'UltipaTeam' and prints error codes

requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

prop1 := &structs.Property{Name: "startDate", Type: ultipa.PropertyType_DATETIME}
new1, _ := conn.CreateProperty(ultipa.DBType_DBNODE, "member", prop1, requestConfig)
println("Operation succeeds:", new1.Status.IsSuccess())
prop2 := &structs.Property{Name: "age", Type: ultipa.PropertyType_INT32}
new2, _ := conn.CreateProperty(ultipa.DBType_DBNODE, "member", prop2, requestConfig)
println("Operation succeeds:", new2.Status.IsSuccess())
```

<p tit="Output"></p> 
 
```java
Operation succeeds: true
Operation succeeds: true
```

### CreatePropertyIfNotExist()

Creates a new property for a node or edge schema in the current graphset, handling cases where the given property name already exists by ignoring the error.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema, write `*` to specify all schemas.
- `Property`: The property to be created; the fields `Name` and `Type` must be set.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.


**Returns:**

- `bool`: Whether the property exists.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

// Creates a property for node schema 'member' in graphset 'UltipaTeam' and prints if the schema already exists

myProp := &structs.Property{Name: "startDate", Type: ultipa.PropertyType_DATETIME}
new1, _ := conn.CreatePropertyIfNotExist(ultipa.DBType_DBNODE, "member", myProp, requestConfig)
println("Property already exists:", new1)

// Creates the same property again in graphset 'UltipaTeam' and prints if the schema already exists

new2, _ := conn.CreatePropertyIfNotExist(ultipa.DBType_DBNODE, "member", myProp, requestConfig)
println("Property already exists:", new2)
```

<p tit="Output"></p> 
 
```java
Property already exists: false
Property already exists: true
```

### AlterProperty()

Alters the name and description of one existing custom property in the current graphset by its name.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `Property`: The existing property to be altered; the fields `Name` and `Schema` (write `*` to specify all schemas) must be set. 
- `Property`: The new configuration for the existing property; either or both of the fields `Name` and `Desc` must be set.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

// Rename properties 'name' associated with all node schemas to `Name` in graphset 'UltipaTeam'

myAlt, _ := conn.AlterProperty(ultipa.DBType_DBNODE, &structs.Property{Name: "name", Schema: "*"}, &structs.Property{Name: "Name"}, requestConfig)
println("Operation succeeds:", myAlt.Status.IsSuccess())
```

<p tit="Output"></p> 
 
```java
Operation succeeds: true
```

### DropProperty()

Drops one custom property from the current graphset by its name and the associated schema.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
requestConfig := &configuration.RequestConfig{
    UseMaster: true,
    GraphName: "UltipaTeam",
}

// Drops properties 'startDate' assocaited with all node schemas in graphset 'UltipaTeam' and prints error code

drop1, _ := conn.DropProperty(ultipa.DBType_DBNODE, "*", "startDate", requestConfig)
println("Operation succeeds:", drop1.Status.IsSuccess())

// Drops node property @member.name in graphset 'UltipaTeam' and prints error code

drop2, _ := conn.DropProperty(ultipa.DBType_DBNODE, "member", "name", requestConfig)
println("Operation succeeds:", drop2.Status.IsSuccess())
```


<p tit="Output"></p> 
 
```java
Operation succeeds: true
Operation succeeds: true
```

## Full Example

<p tit="Go"></p> 

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
  //URI example: Hosts:=[]string{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"}
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
    GraphName: "UltipaTeam",
  }

  // Creates node schema 'utility' (with properties) in graphset 'UltipaTeam' and prints error code
  newNodeSchema, _ := conn.CreateSchema(&structs.Schema{Name: "utility", Properties: []*structs.Property{{Name: "name", Type: ultipa.PropertyType_STRING}, {Name: "purchaseDate", Type: ultipa.PropertyType_DATETIME}}, DBType: ultipa.DBType_DBNODE, Desc: "Office utilities"}, true, requestConfig)
  println("Node Schema Creation Succeeds: ", newNodeSchema.Status.IsSuccess())
  println(utils.JSONString(newNodeSchema))

}
```
