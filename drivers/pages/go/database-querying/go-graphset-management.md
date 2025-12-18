# Graphset Management

This section introduces methods on a `Connection` object for managing graphsets in the database.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## ShowGraph()

Retrieves all graphsets from the database.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `GraphSet`: The list of all graphsets in the database.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all graphsets and prints the names of the those who have over 2000 edges

myGraph, _ := conn.ShowGraph(nil)
for i := 0; i < len(myGraph); i++ {
    if myGraph[i].TotalEdges > 2000 {
        fmt.Println("GraphSet:", myGraph[i].Name)
    }
}
```
<p tit="Output"></p> 
 
```java
Display_Ad_Click
ERP_DATA2
wikiKG
```

## GetGraph()

Retrieves one graphset from the database by its name.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `GraphSet`: The retrieved graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves the graphsets named 'wikiKG' and prints all its information

myGraph, _ := conn.GetGraph("wikiKG", nil)
fmt.Println("ID", "Name", "TotalNodes", "TotalEdges", "Status")
fmt.Println(myGraph)
```

<p tit="Output"></p> 
 
```java
ID Name TotalNodes TotalEdges Status
&{13844 wikiKG  44449 167799 MOUNTED}
```

## CreateGraph()

Creates a new graphset in the database.

**Parameters:**

- `GraphSet`: The graphset to be created; the field `name` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `UQLResponse`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Creates one graphset and prints the error code

myGraph, _ := conn.CreateGraph(&structs.GraphSet{Name: "testGoSDK", Description: "Description for testGoSDK"}, nil)
fmt.Println("Creation succeeds:", myGraph.Status.IsSuccess())
```

A new graphset `testGoSDK` is created in the database, and the driver prints:

<p tit="Output"></p> 
 
```java
Creation succeeds: true
```

## CreateGraphIfNotExist()

Creates a new graphset in the database, handling cases where the given graphset name already exists by ignoring the error.

**Parameters:**

- `GraphSet`: The graphset to be created; the field `name` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `bool`: Whether the graphset already exists.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 

```go
// Creates one graphset and prints the error code

myGraph, status, err := conn.CreateGraphIfNotExist(&structs.GraphSet{Name: "testGoSDK", Description: "Description for testGoSDK"}, nil)
if err == nil {
    fmt.Println("Graph already exists:", status)
    fmt.Println("First creation succeeds:", myGraph.Status.IsSuccess())
}

// Attempts to create the same graphset again and prints the error code

_, result, _ := conn.CreateGraphIfNotExist(&structs.GraphSet{Name: "testGoSDK", Description: "Description for testGoSDK"}, nil)
fmt.Println("Graph already exists:", result)

```

A new graphset `testGoSDK` is created in the database, and the driver prints:

<p tit="Output"></p> 
 
```java
Graph already exists: false
First creation succeeds: true
Graph already exists: true
```

## DropGraph()

Drops one graphset from the database by its name.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 

```go
// Creates one graphset and then drops it, prints the result

myGraph, _ := conn.CreateGraph(&structs.GraphSet{Name: "testGoSDK", Description: "Description for testGoSDK"}, nil)
fmt.Println("Creation succeeds:", myGraph.Status.IsSuccess())

resp1, _ := conn.DropGraph("testGoSDK", nil)
fmt.Println(resp1)
```
<p tit="Output"></p> 

```java
Creation succeeds: true
&{map[] status:{} statistics:{table_name:"statistics" headers:{property_name:"node_affected" property_type:STRING} headers:{property_name:"edge_affected" property_type:STRING} headers:{property_name:"total_time_cost" property_type:STRING} headers:{property_name:"engine_time_cost" property_type:STRING} table_rows:{values:"0" values:"0" values:"6" values:"0"}} explain_plan:{} 0xc0002a0648 0xc0004a2040 0xc000484b40 [] 0xc0002814f0}
```

## AlterGraph()

Alters the name and description of one existing graphset in the database by its name.

**Parameters:**

- `oldGraph: GraphSet`: The existing graphset to be altered; the field `name` must be set.
- `newGraph: GraphSet`: The new configuration for the existing graphset; either or both of the fields `name` and `description` must be set.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 

```go
// Renames the graphset 'testGoSDK' to 'newGraph', sets a description for it, and prints the result

resp1, _ := conn.AlterGraph(&structs.GraphSet{Name: "testGoSDK"}, &structs.GraphSet{Name: "newGraph", Description: "The graph is altered."}, nil)
fmt.Println(resp1)
```

<p tit="Output"></p> 

```java
&{map[] status:{}  statistics:{table_name:"statistics"  headers:{property_name:"node_affected"  property_type:STRING}  headers:{property_name:"edge_affected"  property_type:STRING}  headers:{property_name:"total_time_cost"  property_type:STRING}  headers:{property_name:"engine_time_cost"  property_type:STRING}  table_rows:{values:"0"  values:"0"  values:"0"  values:"0"}}  explain_plan:{} 0xc0002327c8 0xc00001cba0 0xc000009248 [] 0xc000207820}
```

## Truncate()

Truncates (Deletes) the specified nodes or edges in the given graphset or truncates the entire graphset. Note that truncating nodes will cause the deletion of edges attached to those affected nodes. The truncating operation retains the definition of schemas and properties while deleting the data.

**Parameters:**

- `Truncate`: The object to truncate; the field `GraphName` must be set, `Schema` and `DbType` are optional, but if either `Schema` or `DbType` is set, the other must also be set.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 

```go
// Truncates @user nodes in the graphset 'myGraph_1' and prints the error code

db := ultipa.DBType_DBNODE
myGraph1, _ := conn.Truncate(&structs.Truncate{GraphName: "myGraph_1", DbType: &db, Schema: "user"}, nil)
fmt.Println(myGraph1.Status)

// Truncates all edges in the graphset 'myGraph_2' and prints the error code    

db := ultipa.DBType_DBEDGE
myGraph2, _ := conn.Truncate(&structs.Truncate{GraphName: "myGraph_2", DbType: &db, Schema: "*"}, nil)
fmt.Println(myGraph2.Status)

// Truncates the graphset 'myGraph_3' and prints the error code

myGraph3, _ := conn.Truncate(&structs.Truncate{GraphName: "myGraph_3"}, nil)
fmt.Println(myGraph3.Status)
```

<p tit="Output"></p> 

```java
&{ SUCCESS}
&{ SUCCESS}
&{ SUCCESS}
```

## Compact()

Compacts a graphset by clearing its invalid and redundant data on the server disk. Valid data will not be affected.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 

```go
// Compacts the graphset 'miniCircle' and prints the error code

resp, _ := conn.Compact("miniCircle", nil)
fmt.Println(resp.Status)
```

<p tit="Output"></p> 

```java
&{ SUCCESS}
```

## HasGraph()

Checks the existence of a graphset in the database by its name.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `bool`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 

```go
// Checks the existence of graphset 'miniCircle' and prints the result

resp, _ := conn.HasGraph("miniCircle", nil)
fmt.Println("Graph exists:", resp)
```

<p tit="Output"></p> 

```java
Graph exists: true
```

## UnmountGraph()

Unmounts a graphset to save database memory.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 

```go
// / Unmounts the graphsets 'miniCircle' and prints the result

resp, _ := conn.UnmountGraph("miniCircle", nil)
fmt.Println(resp.Status)
```

<p tit="Output"></p> 

```java
&{ SUCCESS}
```

## MountGraph()

Mounts a graphset to the database memory.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 

```go
// Mounts the graphsets 'miniCircle' and prints the result

resp, _ := conn.MountGraph("miniCircle", nil)
fmt.Println(resp.Status)
```

<p tit="Output"></p> 

```java
&{ SUCCESS}
```

## Full Example

<p tit="Go"></p> 

```go
package main

import (
  "fmt"

  "github.com/ultipa/ultipa-go-sdk/sdk"
  "github.com/ultipa/ultipa-go-sdk/sdk/configuration"
  "github.com/ultipa/ultipa-go-sdk/sdk/structs"
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
  }

  // Creates new graphset 'testGoSDK'  
  myGraph, _ := conn.CreateGraph(&structs.GraphSet{Name: "testGoSDK", Description: "Description for testGoSDK"}, nil)
  fmt.Println("Creation succeeds:", myGraph.Status.IsSuccess())

  // Drops the graphset 'testGoSDK' just created
  resp1, _ := conn.DropGraph("testGoSDK", nil)
  fmt.Println(resp1.Status)

}

