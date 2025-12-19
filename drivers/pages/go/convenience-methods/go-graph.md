# Convenience Methods

# Graph

This section introduces methods for managing graphs in the database.

## ShowGraph()

Retrieves all graphsets from the database.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.GraphSet`: A slice of pointers to the retrieved graphs.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all graphs and prints the names of those with over 2000 edges

graphs, _ := driver.ShowGraph(nil)
for _, graph := range graphs {
  if graph.TotalEdges > 2000 {
    println(graph.Name)
  }
}
```
<p tit="Output"></p> 
 
```
Display_Ad_Click
ERP_DATA2
wikiKG
```

## GetGraph()

Retrieves a specified graph from the database.

**Parameters**

- `graphName: string`: Name of the graph.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `*structs.GraphSet`: A pointer to the retrieved graph.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves the graph named 'miniCircle'

graph, _ := driver.GetGraph("miniCircle", nil)
fmt.Println(graph)
```

<p tit="Output"></p> 
 
```
&{1438 miniCircle 307 1961  NORMAL [1 2 3] 256 CityHash64}
```

## HasGraph()

Checks the existence of a specified graph in the database.

**Parameters**

- `graphName: string`: Name of the graph.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `bool`: Check result.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Checks the existence of a graph named 'miniCircle'

response, _ := driver.HasGraph("miniCircle", nil)
println(response)
```

<p tit="Output"></p> 
 
```
True
```

## CreateGraph()

Creates a graph in the database.

**Parameters**

- `graphSet: *structs.GraphSet`: The graph to be created; the field `Name` is mandatory, `Shards`, `PartitionBy` and `Description` are optional.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Creates a graph

response, _ := driver.CreateGraph(&structs.GraphSet{Name: "testGoSDK", Shards: []string{"1"}, PartitionBy: "Crc32", Description: "testGoSDK desc"}, nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## CreateGraphIfNotExist()

Creates a graph in the database and returns whether a graph with the same name already exists.

**Parameters**

- `graphSet: *structs.GraphSet`: The graph to be created; the field `Name` is mandatory, `Shards`, `PartitionBy` and `Description` are optional.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `ResponseWithExistCheck`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
graph := &structs.GraphSet{Name: "testGoSDK", Shards: []string{"1"}, PartitionBy: "Crc32", Description: "testGoSDK desc"}

result, _ := driver.CreateGraphIfNotExist(graph, nil)
fmt.Println("Does the graph already exist?", result.Exist)
if result.Response == nil {
    fmt.Println("Graph creation status: No response")
} else {
    fmt.Println("Graph creation status:", result.Response.Status.Code)
}

time.Sleep(3 * time.Second)

fmt.Println("----- Creates the graph again -----")
result_1, _ := driver.CreateGraphIfNotExist(graph, nil)
fmt.Println("Does the graph already exist?", result_1.Exist)
if result_1.Response == nil {
    fmt.Println("Graph creation status: No response")
} else {
    fmt.Println("Graph creation status:", result_1.Response.Status.Code)
}
```

<p tit="Output"></p> 
 
```
Does the graph already exist? false
Graph creation status: SUCCESS
----- Creates the graph again -----
Does the graph already exist? true
Graph creation status: No response
```

## AlterGraph()

Alters the name and description of a graph in the database.

**Parameters**

- `graphName: string`: Name of the graph.
- `alterGraphset: *structs.GraphSet`: A pointer to the `GraphSet` struct used to set new `Name` and/or `Description` for the graph.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Alters the name and description of the graph 'testPythonSDK'

newGraphInfo := &structs.GraphSet{Name: "newGraph", Description: "a new graph"}
response, _ := driver.AlterGraph("testGoSDK", newGraphInfo, nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## DropGraph()

Deletes a specified graph from the database.

**Parameters**

- `graphName: string`: Name of the graph.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Drops the graph 'testGoSDK'

response, _ := driver.DropGraph("testGoSDK", nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 

```
SUCCESS
```

## Truncate()

Truncates (Deletes) the specified nodes or edges in a graph or truncates the entire graph. Note that truncating nodes will cause the deletion of edges attached to those affected nodes. The truncating operation retains the definition of schemas and properties in the graph.

**Parameters**

- `params: *structs.TruncateParams`: The truncate parameters; the field `GraphName` is mandatory, `SchemaName` and `DBType` are optional.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Truncates User nodes in 'myGraph'

NodeType := ultipa.DBType_DBNODE
response1, _ := driver.Truncate(&structs.TruncateParams{GraphName: "myGraph", SchemaName: "User", DBType: &NodeType}, nil)
fmt.Println(response1.Status.Code)

// Truncates all edges in the 'myGraph'

EdgeType := ultipa.DBType_DBEDGE
response2, _ := driver.Truncate(&structs.TruncateParams{GraphName: "myGraph", SchemaName: "*", DBType: &EdgeType}, nil)
fmt.Println(response2.Status.Code)

// Truncates 'myGraph'

response3, _ := driver.Truncate(&structs.TruncateParams{GraphName: "myGraph"}, nil)
fmt.Println(response3.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
SUCCESS
```

## Compact()

Clears invalid and redundant data for a graph. Valid data will not be affected.

**Parameters**

- `graphName: string`: Name of the graph.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Compacts the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.Compact("miniCircle", nil)
jobID := response.JobId

time.Sleep(3 * time.Second)
jobs, _ := driver.ShowJob(jobID, requestConfig)
for _, job := range jobs {
    fmt.Println(job.Id, "-", job.Status)
}
```

<p tit="Output"></p> 

```
138 - FINISHED
138_1 - FINISHED
138_2 - FINISHED
138_3 - FINISHED
```

## Full Example

```go
package main

import (
	"fmt"
	"log"

	"github.com/ultipa/ultipa-go-driver/v5/sdk"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/configuration"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/structs"
)

func main() {
	config := &configuration.UltipaConfig{
		// URI example:	Hosts: []string{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"},
		Hosts:    []string{"192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"},
		Username: "<usernmae>",
		Password: "<password>",
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Creates a graph

	response, _ := driver.CreateGraph(&structs.GraphSet{Name: "testGoSDK", Shards: []string{"1"}, PartitionBy: "Crc32", Description: "testGoSDK desc"}, nil)
	fmt.Println(response.Status.Code)
}
```
