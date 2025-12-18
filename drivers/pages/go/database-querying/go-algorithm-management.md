# Algorithm Management

This section introduces methods on a `Connection` object for managing <a href="/docs/graph-analytics-algorithms">Ultipa graph algorithms</a> and custom algorithms (EXTA) in the instance.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Ultipa Graph Algorithms

### ShowAlgo()

Retrieves all Ultipa graph algorithms installed in the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Algo`: The list of all algorithms retrieved.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all Ultipa graph algorithms installed and prints the information of the first returned one

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
}

graphList, err := conn.ShowAlgo(requestConfig)
if err != nil {
  println(err)
}
println("First algorithm retrieved:")
println(utils.JSONString(graphList[0]))
```
<p tit="Output"></p> 
 
```java
First algorithm retrieved:
{"Name":"lpa","Desc":"label propagation algorithm","Version":"1.0.10","Params":{"edge_weight_property":{"Name":"edge_weight_property","Desc":"optional"},"ids":{"Name":"ids","Desc":"labeled nodes, optional, all nodes(with non-NULL value) as labeled nodes if empty"},"k":{"Name":"k","Desc":"no more than k labels will be kept for each node"},"loop_num":{"Name":"loop_num","Desc":"size_t,required"},"node_label_property":{"Name":"node_label_property","Desc":"optional"},"node_weight_property":{"Name":"node_weight_property","Desc":"optional"}}}
```

### InstallAlgo()

Installs an Ultipa graph algorithm in the instance.

**Parameters:**

- `string`: File path of the algo installation package (*.so*).
- `string`: File path of the configuration file (*.yml*).
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `InstallAlgoReply`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 
 
```go
// Installs the algorithm LPA and uses the leader node to guarantee consistency, and prints the error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
}

graph, err := conn.InstallAlgo("E:/Go/Algo/libplugin_lpa.so", "E:/Go/Algo/lpa.yml", requestConfig)
if err != nil {
  println(err)
}
if graph.Status.ErrorCode == 0 {
  println("Installation succeeds")
} else {
  println("Installation failed")
}
```
<p tit="Output"></p> 
 
```java
Installation succeeds
```

### UninstallAlgo()

Uninstalls an Ultipa graph algorithm in the instance.

**Parameters:**

- `string`: Name of the algorithm.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `UninstallAlgoReply`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 
 
```go
// Uninstalls the algorithm LPA and prints the error code

  requestConfig := &configuration.RequestConfig{
    UseMaster: true,
  }

  graph, err := conn.UninstallAlgo("lpa", requestConfig)
  if err != nil {
    println(err)
  }
  if graph.Status.ErrorCode == 0 {
    println("Algorithm is uninstalled")
  } else {
    println("Operation failed")
  }
```
<p tit="Output"></p> 
 
```java
Algorithm is uninstalled
```

## EXTA

### ShowExta()

Retrieves all extas installed in the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Exta`: The list of all extas retrieved.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 
 
```go
// Retrieves all extas installed and prints the information of the first returned one

extaList, err := conn.ShowExta(nil)
if err != nil {
  println(err)
}
println(utils.JSONString(extaList[0]))
```
<p tit="Output"></p> 
 
```java
{"Name":"page_rank 1","Author":"wuchuang","Version":"beta.4.4.41-b4.4.0-tv-ui","Detail":"base:\n  category: ExtaExample\n  cn:\n    name: page_rank\n    desc: null\n  en:\n    name: page_rank\n    desc: null\n\nother_param:\n\n    \nparam_form:\n\nwrite:\n\nreturn:\n\nmedia:\n"}
```

### InstallExta()

Installs an exta in the instance.

**Parameters:**

- `string`: File path of the exta installation package (*.so*).
- `string`: File path of the configuration file (*.yml*).
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 
 
```go
// Installs the exta page_rank and uses the leader node to guarantee consistency, and prints the error code

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
}

exta, err := conn.InstallExta("E:/Go/Exta/libexta_page_rank.so", "E:/Go/Exta/page_rank.yml", requestConfig)
if err != nil {
  println(err)
}
if exta.Status.ErrorCode == 0 {
  println("Installation succeeds")
} else {
  println("Installation failed")
}
```
<p tit="Output"></p> 
 
```java
Installation succeeds
```

### UninstallExta()

Uninstalls an exta in the instance.

**Parameters:**

- `string`: Name of the exta.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `UninstallExtaReply`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.`

<p tit="Go"></p> 
 
```go
// Uninstalls the exta page_rank and prints the error code

exta, err := conn.UninstallExta("page_rank", nil)
if err != nil {
  println(err)
}
if exta.Status.ErrorCode == 0 {
  println("Exta is uninstalled")
} else {
  println("Operation failed")
}
```
<p tit="Output"></p> 
 
```java
Exta is uninstalled
```

## Full Example

<p tit="Go"></p> 

```go
package main

import (
  "github.com/ultipa/ultipa-go-sdk/sdk"
  "github.com/ultipa/ultipa-go-sdk/sdk/configuration"
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

  // Installs the algorithm LPA
  graph, err := conn.InstallAlgo("E:/Go/Algo/libplugin_lpa.so", "E:/Go/Algo/lpa.yml", requestConfig)
  if err != nil {
    println(err)
  }
  if graph.Status.ErrorCode == 0 {
    println("Installation succeeds")
  } else {
    println("Installation failed")

};
```
