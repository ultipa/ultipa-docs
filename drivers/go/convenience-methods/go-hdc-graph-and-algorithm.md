# HDC Graph and Algorithm

This section introduces methods for managing HDC graph and HDC algorithms. Note that these methods require the deployment of HDC servers for the database.

## HDC Graph

### ShowHDCGraph()

Retrieves all HDC graphs created from the graph.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.HDCGraph`: A slice of pointers to the retrieved HDC graphs.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all HDC graphs of the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

hdcGraphs, _ := driver.ShowHDCGraph(requestConfig)
for _, hdcGraph := range hdcGraphs {
    fmt.Println(hdcGraph.Name, "on", hdcGraph.HDCServerName)
}
```

<p tit="Output"></p> 
 
```
miniCircle_hdc_graph on hdc-server-1
miniCircle_hdc_graph2 on hdc-server-2
```

### CreateHDCGraphBySchema()

Creates an HDC graph for the graph.

**Parameters**

- `builder: HDCBuilder`: The HDC graph to be created; the fields `HdcGraphName` and `HdcServerName` are mandatory, `NodeSchema`, `EdgeSchema`, `SyncType`, `Direction`, `LoadId`, and `IsDefault` are optional.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Creates an HDC graph named 'test_hdc_graph' for the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.CreateHDCGraphBySchema(api.HDCBuilder{
    HDCGraphName:  "test_hdc_graph",
    HDCServerName: "hdc-server-1",
    NodeSchema:    map[string][]string{"*": {"*"}},
    EdgeSchema:    map[string][]string{"direct": {"*"}, "review": {"value", "content"}},
    SyncType:      api.STATIC,
}, requestConfig)
jobID := response.JobId

time.Sleep(3 * time.Second)
jobs, _ := driver.ShowJob(jobID, requestConfig)
for _, job := range jobs {
    fmt.Println(job.Id, "-", job.Status)
}
```

<p tit="Output"></p> 
 
```
28 - FINISHED
28_1 - FINISHED
```

### DropHDCGraph()

Deletes a specified HDC graph of the graph.

**Parameters**

- `hdcGraphName: string`: Name of the HDC graph.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Drops the HDC graph 'miniCircle_hdc_graph2' of the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.DropHDCGraph("miniCircle_hdc_graph2", requestConfig)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## HDC Algorithms

### ShowHDCAlgo()

Retrieves all HDC algorithms installed on an HDC server.

**Parameters**

- `hdcServerName: string`: Name of the HDC server.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Algo`: A slice of pointers to the retrieved HDC algorithms.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all HDC algorithms installed on the HDC server 'hdc-server-1'

algos, _ := driver.ShowHDCAlgo("hdc-server-1", nil)

for _, algo := range algos {
    fmt.Print(algo.Name, " supports writeback type(s): ")
    if algo.WriteSupportType != "" {
        fmt.Print(algo.WriteSupportType)
    } else {
        fmt.Print("None")
    }
    fmt.Println()
}
```

<p tit="Output"></p> 
 
```
fastRP supports writeback type(s): DB,FILE
schema_overview supports writeback type(s): None
```

### InstallHDCAlgo()

Installs an HDC algorithm on an HDC server.

**Parameters**

- `files: []string`: List of the paths of the installation files, the package file (.so) is necessary while the configuration file (.yml) is optional.
- `hdcServerName: string`: Name of the HDC server.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Installs the HDC algorithm LPA on the HDC server 'hdc-server-1'
// The files 'libplugin_lpa.so' and 'lpa.yml' are located in the 'algo' folder that is placed in the same directory as the file you executed

response, _ := driver.InstallHDCAlgo([]string{"algo/libplugin_lpa.so", "algo/lpa.yml"}, "hdc-server-1", nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### UninstallHDCAlgo()

Uninstalls an HDC algorithm from an HDC server.

**Parameters**

- `algoName: string`: Name of the algorithm.
- `hdcServerName: string`: Name of the HDC server.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Uninstalls the HDC algorithm LPA from the HDC server 'hdc-server-1'

response, _ := driver.UninstallHDCAlgo("lpa", "hdc-server-1", nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### RollbackHDCAlgo()

Rolls back a specified HDC algorithm on an HDC server.

**Parameters**

- `algoName: string`: Name of the algorithm.
- `hdcServerName: string`: Name of the HDC server.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Rolls back the HDC algorithms LPA on the HDC server 'hdc-server-1'

response, _ := driver.RollbackHDCAlgo("lpa", "hdc-server-1", nil)
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

	// Installs the HDC algorithm LPA on the HDC server 'hdc-server-1'
	// The files 'libplugin_lpa.so' and 'lpa.yml' are located in the 'algo' folder that is placed in the same directory as the file you executed

	response, _ := driver.InstallHDCAlgo([]string{"algo/libplugin_lpa.so", "algo/lpa.yml"}, "hdc-server-1", nil)
	fmt.Println(response.Status.Code)
}
```
