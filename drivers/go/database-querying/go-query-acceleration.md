# Query Acceleration

This section introduces methods on a `Connection` object for managing the LTE status for properties, and their indexes and full-text indexes. These mechanisms can be employed to <a href="/docs/uql/acceleration">accelerate queries</a>.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## LTE

### Lte()

Loads one custom property of nodes or edges to the computing engine for query acceleration.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema, write `*` to specify all schemas.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. 
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Loads the edge property @relatesTo.type to engine in graphset 'UltipaTeam' and prints error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "UltipaTeam",
}

resp, _ := conn.Lte(ultipa.DBType_DBEDGE, "relatesTo", "type", requestConfig)
print("Operation succeeds:", resp.Status.IsSuccess())
```

<p tit="Output"></p> 
 
```
Operation succeeds:true
```

### Ufe()

Unloads one custom property of nodes or edges from the computing engine to save the memory.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema, write `*` to specify all schemas.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. 
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Unloads the edge property @relatesTo.type from engine in graphset 'UltipaTeam' and prints error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "UltipaTeam",
}

resp, _ := conn.Ufe(ultipa.DBType_DBEDGE, "relatesTo", "type", requestConfig)
print("Operation succeeds:", resp.Status.IsSuccess())
```

<p tit="Output"></p> 
 
```
Operation succeeds:true
```

## Index

### ShowIndex()

Retrieves all indexes of node and edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Index`: The list of all indexes retrieved in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Retrieves indexes in graphset 'Ad_Click' and prints their information

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "Ad_Click",
}

indexList, err := conn.ShowIndex(requestConfig)
if err != nil {
  println(err)
}
for i := 0; i < len(indexList); i++ {
  println(utils.JSONString(indexList[i]))
}
```

<p tit="Output"></p> 
 
```
{"Name":"shopping_level","Properties":"shopping_level","Schema":"user","Status":"done","Size":4608287,"Type":"node"}
{"Name":"price","Properties":"price","Schema":"ad","Status":"done","Size":7828760,"Type":"node"}
{"Name":"time","Properties":"time","Schema":"clicks","Status":"done","Size":12811267,"Type":"edge"}
```

### ShowNodeIndex()

Retrieves all indexes of node properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Index`: The list of all indexes retrieved in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.


```go
// Retrieves node indexes in graphset 'Ad_Click' and prints their information

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "Ad_Click",
}

indexList, err := conn.ShowNodeIndex(requestConfig)
if err != nil {
  println(err)
}
for i := 0; i < len(indexList); i++ {
  println(utils.JSONString(indexList[i]))
}
```

<p tit="Output"></p> 
 
```
{"Name":"shopping_level","Properties":"shopping_level","Schema":"user","Status":"done","Size":4608287,"Type":"node"}
{"Name":"price","Properties":"price","Schema":"ad","Status":"done","Size":7828760,"Type":"node"}
```

### ShowEdgeIndex()

Retrieves all indexes of edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Index`: The list of all indexes retrieved in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Retrieves edge indexes in graphset 'Ad_Click' and prints their information

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "Ad_Click",
}

indexList, err := conn.ShowEdgeIndex(requestConfig)
if err != nil {
  println(err)
}
for i := 0; i < len(indexList); i++ {
  println(utils.JSONString(indexList[i]))
}
```

<p tit="Output"></p> 
 
```
{"Name":"time","Properties":"time","Schema":"clicks","Status":"done","Size":12811267,"Type":"edge"}
```

### CreateIndex()

Creates a new index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema, write `*` to specify all schemas.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. 
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Creates indexes for all node properties 'name' in graphset 'Ad_Click' and prints the error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "Ad_Click",
}

indexList, err := conn.CreateIndex(ultipa.DBType_DBNODE, "*", "name", requestConfig)
if err != nil {
  println(err)
}
println("Operation succeeds:", indexList.Status.IsSuccess())
```

<p tit="Output"></p> 
 
```
Operation succeeds: true
```

### DropIndex()

Drops indexes in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. 
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Drops the index of the node property @ad.name in graphset 'Ad_Click' and prints the error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "Ad_Click",
}

indexList, err := conn.DropIndex(ultipa.DBType_DBNODE, "ad", "name", requestConfig)
if err != nil {
  println(err)
}
println("Operation succeeds:", indexList.Status.IsSuccess())
```

<p tit="Output"></p> 
 
```
Operation succeeds: true
```


## Full-text

### ShowFullText()

Retrieves all full-text indexes of node and edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Index`: The list of all indexes retrieved in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Retrieves the first full-text index returned in graphset 'miniCircle' and prints its information

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

indexList, err := conn.ShowFullText(requestConfig)
if err != nil {
  println(err)
}
println(utils.JSONString(indexList[0]))
```

<p tit="Output"></p> 
 
```
{"Name":"genreFull","Properties":"genre","Schema":"movie","Status":"done","Size":0,"Type":""}
```

### ShowNodeFullText()

Retrieves all full-text indexes of node properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Index`: The list of all indexes retrieved in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Retrieves the first node full-text index returned in graphset 'miniCircle' and prints its information

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

indexList, err := conn.ShowNodeFullText(requestConfig)
if err != nil {
  println(err)
}
println(utils.JSONString(indexList[0]))
```

<p tit="Output"></p> 
 
```
{"Name":"genreFull","Properties":"genre","Schema":"movie","Status":"done","Size":0,"Type":""}
```

### ShowEdgeFullText()

Retrieves all full-text indexes of edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Index`: The list of all indexes retrieved in the current graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Retrieves the first edge full-text index returned in graphset 'miniCircle' and prints its information

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

indexList, err := conn.ShowEdgeFullText(requestConfig)
if err != nil {
  println(err)
}
println(utils.JSONString(indexList[0]))
```

<p tit="Output"></p> 
 
```
{"Name":"nameFull","Properties":"content","Schema":"review","Status":"done","Size":0,"Type":""}
```

### CreateFullText()

Creates a new full-text index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `string`: Name of the property.
- `string`: Name of the full-text index.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. 
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Creates full-text index called 'movieName' for the property @movie.name in graphset 'miniCircle' and prints the error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

indexList, err := conn.CreateFullText(ultipa.DBType_DBNODE, "movie", "name", "movieName", requestConfig)
if err != nil {
  println(err)
}
println("Operation succeeds:", indexList.Status.IsSuccess())
```

<p tit="Output"></p> 
 
```
Operation succeeds: true
```

### DropFullText()

Drops a full-text index in the current graphset.

**Parameters:**

- `string`: Name of the full-text index.
- `DBType`: Type of the property (node or edge).
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. 
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

```go
// Drops the node full-index 'movieName' in graphset 'miniCircle' and prints the error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

indexList, err := conn.DropFullText("movieName", ultipa.DBType_DBNODE, requestConfig)
if err != nil {
  println(err)
}
println("Operation succeeds:", indexList.Status.IsSuccess())
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
    GraphName: "Ad_Click",
  }

  // Retrieves all indexes in graphset 'Ad_Click' and prints their information
  indexList, err := conn.ShowIndex(requestConfig)
  if err != nil {
    println(err)
  }
  for i := 0; i < len(indexList); i++ {
    println(utils.JSONString(indexList[i]))
  }

};
```




















