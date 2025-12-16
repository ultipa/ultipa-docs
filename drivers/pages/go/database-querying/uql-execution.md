# UQL Execution

This section introduces the `uql()` and `uqlStream()` methods on a `Connection` object for querying the database using UQL.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

> UQL (Ultipa Query Language) is the language designed for fully interacting with Ultipa graph databases. For detailed information on UQL, refer to the <a href="https://www.ultipa.com/docs/uql/">documentation</a>.

## Uql()

Executes a UQL query on the current graphset or the database and returns the result.

**Parameters:**

- `string`: The UQL query to be executed.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request. 
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit= "Go" ></p> 
 
```go
// Retrieves 5 @movie nodes in graphset 'miniCircle' and prints their information

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

query, _ := conn.Uql("find().nodes({@movie}) as n return n{*} limit 5", requestConfig)
nodeList, schemaList, _ := query.Alias("n").AsNodes()
printers.PrintNodes(nodeList, schemaList)
```

<p tit= "Output" ></p> 

```java
+-----+------+--------+--------------------------+------------------------+------+--------+
| ID  | UUID | Schema |           name           |         genre          | year | rating |
+-----+------+--------+--------------------------+------------------------+------+--------+
| m_1 | 1001 | movie  | The Shawshank Redemption |      crime drama       | 1994 |  9.7   |
| m_2 | 1002 | movie  |  Farewell My Concubine   |   drama romance LGBT   | 1993 |  9.6   |
| m_3 | 1003 | movie  |       Forrest Gump       |     drama romance      | 1994 |  9.5   |
| m_4 | 1004 | movie  |          Léon           |   drama action crime   | 1994 |  9.4   |
| m_5 | 1005 | movie  |         Titanic          | drama romance disaster | 1997 |  9.4   |
+-----+------+--------+--------------------------+------------------------+------+--------+
```

For more examples, please refer to <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-go">Types Mapping Ultipa and Go</a>.

## UQLStream()

Executes a UQL query on the current graphset or the database and returns the result incrementally, allowing handling of large datasets without loading everything into memory at once.

**Parameters:**

- `string`: The UQL query to be executed.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `UQLResponseStream`: Result of the request. 
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit= "Go" ></p> 
 
```go
// Retrieves all 1-step paths in graphset 'miniCircle'

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

stream, err := conn.UQLStream("n().e().n() as paths return paths{*}", requestConfig)

if err != nil {
  println(err)
}

count := 0

for true {
  resp, err := stream.Recv(true)
  if err != nil {
    println("End")
  }
  if resp != nil {
    printers.PrintStatistics(resp.Statistic)
    paths, err := resp.Get(0).AsPaths()
    if err != nil {
      println(err)
    }
    count += len(paths)
    println("Count = ", count)
  } else {
    break
  }
}
stream.Close()
```

<p tit= "Output" ></p> 

```java
Total Cost : 0.029s | Engine Cost : 0.001s 
Count =  1250
Total Cost : 0.029s | Engine Cost : 0.001s 
Count =  1390
End
```

## Full Example

<p tit= "Go" ></p> 

```go
package main

import (
  "github.com/ultipa/ultipa-go-sdk/sdk"
  "github.com/ultipa/ultipa-go-sdk/sdk/configuration"
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
    GraphName: "miniCircle",
  }

  // Retrieves 10 nodes and prints the _id and name property value of the first returned one
  query, _ := conn.Uql("find().nodes({@movie}) as n return n{*} limit 10", requestConfig)
  nodeList, _, _ := query.Alias("n").AsNodes()
  println(utils.JSONString(nodeList[0].GetID()))
  println(utils.JSONString(nodeList[0].Values.Get("name")))  
}
```
