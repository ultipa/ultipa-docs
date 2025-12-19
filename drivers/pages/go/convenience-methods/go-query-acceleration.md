# Query Acceleration

This section introduces methods for managing various indexes and LTE status for properties in graphs.

# Index

### ShowIndex()

Retrieves all indexes of node and edge properties from the current graphset.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Index`: A slice of pointers to the retrieved indexes.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves indexes in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

indexList, _ := driver.ShowIndex(requestConfig)
for _, index := range indexList {
    fmt.Println(index)
}
```

<p tit="Output"></p> 
 
```
&{1 age_index year account DONE DBNODE}
&{2 test_index year,float account DONE DBNODE}
&{1 targetPostInd targetPost disagree DONE DBEDGE}
```

### ShowNodeIndex()

Retrieves all node indexes from the graph.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Index`: A slice of pointers to the retrieved indexes.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves node indexes in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

indexList, _ := driver.ShowNodeIndex(requestConfig)
for _, index := range indexList {
    fmt.Println(index)
}
```

<p tit="Output"></p> 
 
```
&{1 age_index year account DONE DBNODE}
&{2 test_index year,float account DONE DBNODE}
```

### ShowEdgeIndex()

Retrieves all edge indexes from the graph.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Index`: A slice of pointers to the retrieved indexes.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves edge indexes in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

indexList, _ := driver.ShowEdgeIndex(requestConfig)
for _, index := range indexList {
    fmt.Println(index)
}
```

<p tit="Output"></p> 
 
```
&{1 targetPostInd targetPost disagree DONE DBEDGE}
```

### DropIndex()

Drops a specified index from the graph.

**Parameters**

- `dbType: ultipa.DBType`: Type of the index (node or edge).
- `indexName: string`: Name of the index.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Drops the node index 'test_index' from the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.DropIndex(ultipa.DBType_DBNODE, "test_index", requestConfig)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### DropNodeIndex()

Drops a specified node index from the graph.

**Parameters**

- `indexName: string`: Name of the index.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Drops the node index 'test_index' from the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.DropNodeIndex("test_index", requestConfig)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### DropEdgeIndex()

Drops a specified edge index from the graph.

**Parameters**

- `indexName: string`: Name of the index.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Drops the edge index 'targetPostInd' from the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.DropEdgeIndex("targetPostInd", requestConfig)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full-text

### ShowFullText()

Retrieves all full-text indexes from the graph.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Index`: A slice of pointers to the retrieved full-text indexes.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves full-text indexes in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

fulltextList, _ := driver.ShowFullText(requestConfig)
for _, fulltext := range fulltextList {
    fmt.Println(fulltext)
}
```

<p tit="Output"></p> 
 
```
&{ name name account DONE DBNODE}
&{ Content content review DONE DBEDGE}
```

### ShowNodeFullText()

Retrieves all node full-text indexes from the graph.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Index`: A slice of pointers to the retrieved full-text indexes.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves node full-text indexes in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

fulltextList, _ := driver.ShowNodeFullText(requestConfig)
for _, fulltext := range fulltextList {
    fmt.Println(fulltext)
}
```

<p tit="Output"></p> 
 
```
&{ name name account DONE DBNODE}
```

### ShowEdgeFullText()

Retrieves all edge full-text indexes from the graph.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Index`: A slice of pointers to the retrieved full-text indexes.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves edge full-text indexes in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

fulltextList, _ := driver.ShowEdgeFullText(requestConfig)
for _, fulltext := range fulltextList {
    fmt.Println(fulltext)
}
```

<p tit="Output"></p> 
 
```
&{ Content content review DONE DBEDGE}
```

### CreateFullText()

Creates a full-text index in the graph.

**Parameters**

- `dbType: ultipa.DBType`: Type of the full-text index (node or edge).
- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `fulltextName: string`: Name of the full-text index.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Creates a full-text index 'moviePlot' for the property 'plot' of the 'movie' nodes

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.CreateFullText(ultipa.DBType_DBNODE, "movie", "plot", "moviePlot", requestConfig)
jobID := response.JobId

time.Sleep(3 * time.Second)
jobs, _ := driver.ShowJob(jobID, requestConfig)
for _, job := range jobs {
    fmt.Println(job.Id, "-", job.Status)
}
```

<p tit="Output"></p> 
 
```
22 - FINISHED
22_1 - FINISHED
22_2 - FINISHED
22_3 - FINISHED
```

### CreateNodeFullText()

Creates a node full-text index in the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `fulltextName: string`: Name of the full-text index.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Creates a full-text index 'moviePlot' for the property 'plot' of the 'movie' nodes

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.CreateNodeFullText("movie", "plot", "moviePlot", requestConfig)
jobID := response.JobId

time.Sleep(3 * time.Second)
jobs, _ := driver.ShowJob(jobID, requestConfig)
for _, job := range jobs {
    fmt.Println(job.Id, "-", job.Status)
}
```

<p tit="Output"></p> 
 
```
23 - FINISHED
23_1 - FINISHED
23_2 - FINISHED
23_3 - FINISHED
```

### CreateEdgeFullText()

Creates an edge full-text index in the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `fulltextName: string`: Name of the full-text index.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Creates a full-text index 'agreeNotes' for the property 'notes' of the 'agree' edges

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.CreateEdgeFullText("agree", "notes", "agreeNotes", requestConfig)
jobID := response.JobId

time.Sleep(3 * time.Second)
jobs, _ := driver.ShowJob(jobID, requestConfig)
for _, job := range jobs {
    fmt.Println(job.Id, "-", job.Status)
}
```

<p tit="Output"></p> 
 
```
24 - FINISHED
24_1 - FINISHED
24_2 - FINISHED
24_3 - FINISHED
```

### DropFullText()

Drops a full-text index from the graph.

**Parameters**

- `fulltextName: string`: Name of the full-text index.
- `dbType: ultipa.DBType`: Type of the full-text index (node or edge).
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Drops the node full-index 'moviePlot' from the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.DropFullText("moviePlot", ultipa.DBType_DBNODE, requestConfig)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## LTE

### Lte()

Loads a property to the computing engine.

**Parameters**

- `dbType: ultipa.DBType`: Type of the property (node or edge).
- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Loads the property 'year' of 'account' nodes to the computing engine

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.Lte(ultipa.DBType_DBNODE, "account", "year", requestConfig)
jobID := response.JobId

time.Sleep(3 * time.Second)
jobs, _ := driver.ShowJob(jobID, requestConfig)
for _, job := range jobs {
    fmt.Println(job.Id, "-", job.Status)
}
```

<p tit="Output"></p> 
 
```
25 - FINISHED
25_1 - FINISHED
25_2 - FINISHED
25_3 - FINISHED
```

### Ufe()

Unloads a property from the computing engine.

**Parameters**

- `dbType: ultipa.DBType`: Type of the property (node or edge).
- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Unloads the property 'year' of 'account' nodes from the computing engine

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.Ufe(ultipa.DBType_DBNODE, "account", "year", requestConfig)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full Example

```go
package main

import (
	"fmt"
	"log"

	"github.com/ultipa/ultipa-go-driver/v5/sdk"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/configuration"
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

	// Retrieves indexes in the graph 'miniCircle'

	requestConfig := &configuration.RequestConfig{
		Graph: "miniCircle",
	}

	indexList, _ := driver.ShowIndex(requestConfig)
	for _, index := range indexList {
		fmt.Println(index)
	}
}
```
