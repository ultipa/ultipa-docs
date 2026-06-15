# Process and Job

This section introduces methods for managing processes and jobs.

## Process

### Top()

Retrieves all running processes in the database.
 
**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Process`: A slice of pointers to the retrieved processes.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all running processes in the database

processes, _ := driver.Top(nil)
for _, process := range processes {
    fmt.Println(process.ProcessId, "-", process.ProcessQuery)
}
```

<p tit="Output"></p> 
 
```
1049215 - MATCH p = ()->{1,3}() RETURN p LIMIT 5000
```

### Kill()

Kills running processes in the database.
 
**Parameters**

- `processId: string`: ID of the process to kill.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all running processes in the database

processes, _ := driver.Top(nil)
for _, process := range processes {
    response, _ := driver.Kill(process.ProcessId, nil)
    fmt.Println(process.ProcessId, "-", process.ProcessQuery, "- Kill", response.Status.Code)
}
```

<p tit="Output"></p> 
 
```
1049303 - MATCH p = ()->{1,4}() RETURN p LIMIT 5000 - Kill SUCCESS
```

## Job

### ShowJob()

Retrieves jobs in the graph.
 
**Parameters**

- `id: string`: Job ID;  set to `""` to retrieve all.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Job`: A slice of pointers to the retrieved jobs.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all failed jobs in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

jobs, _ := driver.ShowJob("", requestConfig)
failedFound := false
for _, job := range jobs {
    if job.Status == "FAILED" {
      failedFound = true
      fmt.Println(job.Id, "-", job.Type, "-", job.ErrMsg)
    }
}

if !failedFound {
    fmt.Println("No failed jobs")
}
```

<p tit="Output"></p> 
 
```
64 - CREATE_FULLTEXT - Fulltext name already exists.
56 - CREATE_INDEX - @account.year does not exist.
55 - CREATE_INDEX - @transfer.year does not exist.
53 - CREATE_INDEX - String type must set index length.
40 - CREATE_HDC_GRAPH - The projection aa already existed!
27 - CREATE_HDC_GRAPH - Hdc server sss not found.
```

### StopTask()

Stops a running job in the graph.
 
**Parameters**

- `id: string`: ID of the job to stop.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all running jobs in the graph 'miniCircle' and stops them all

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

jobs, _ := driver.ShowJob("", requestConfig)
runningFound := false
for _, job := range jobs {
    if job.Status == "RUNNING" {
    	runningFound = true
    	response, _ := driver.StopJob(job.Id, requestConfig)
    	fmt.Println(job.Id, "-", job.Type, "- Stop", response.Status.Code)
  	}
}

if !runningFound {
  	fmt.Println("No running jobs")
}
```

<p tit="Output"></p> 
 
```
26 - CREATE_HDC_GRAPH - Stop SUCCESS
```

### ClearTask()

Clears a job that is not running from the graph.
 
**Parameters**

- `id: string`: ID of the job to clear.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all failed jobs in the graph 'miniCircle' and clears them all

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

jobs, _ := driver.ShowJob("", requestConfig)
failedFound := false
for _, job := range jobs {
    if job.Status == "FAILED" {
    	failedFound = true
    	response, _ := driver.ClearJob(job.Id, requestConfig)
    	fmt.Println("Clear", job.Id, response.Status.Code)
  	}
}

if !failedFound {
  	fmt.Println("No failed jobs")
}
```

<p tit="Output"></p> 
 
```
Clear 27 SUCCESS
Clear 27_1 SUCCESS
Clear 14 SUCCESS
Clear 13 SUCCESS
Clear 12 SUCCESS
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

	// Retrieves all failed jobs in the graph 'miniCircle'

	requestConfig := &configuration.RequestConfig{
		Graph: "miniCircle",
	}

	jobs, _ := driver.ShowJob("", requestConfig)
	failedFound := false
	for _, job := range jobs {
		if job.Status == "FAILED" {
			failedFound = true
			fmt.Println(job.Id, "-", job.Type, "-", job.ErrMsg)
		}
	}

	if !failedFound {
		fmt.Println("No failed jobs")
	}
}

```
