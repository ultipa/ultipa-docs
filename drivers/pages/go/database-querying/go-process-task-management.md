# Process and Task Management

This section introduces methods on a `Connection` object for managing processes in the instance and tasks in the current graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Process

All UQL queries, except for algorithms executed with the `write()` method, are run as processes. The results of these processes are returned to the client upon completion and are not stored.

### Top()

Retrieves all running and stopping processes from the instance.
 
**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Top`: The list of all processes in the instance.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all running and stopping processes in the instance

requestConfig := &configuration.RequestConfig{
  UseMaster: true,
}

myProcess, err := conn.Top(requestConfig)
if err != nil {
  println(err)
}

println(utils.JSONString(myProcess))
```

<p tit="Output"></p> 
 
```java
[{"process_id":"a_4_12573_2","status":"RUNNING","process_uql":"n().e().n().e().n().e().n() as p return count(p)","duration":"48"}]
```

### Kill()

Kills running processes in the instance.
 
**Parameters:**

- `string`: ID of the process to kill; set to `*` to kill all processes.
- `bool`: Set to true to ignore process ID and kill all processes.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all running and stopping processes in the instance and kill all

myProcess, err := conn.Kill("*", true, nil)
if err != nil {
  println(err)
}

println("Operation succeeds:", myProcess.IsSuccess())
```

<p tit="Output"></p> 
 
```java
Operation succeeds: true
```

## Task

Algorithms executed with the `write()` method are run as tasks. These tasks are stored in the graphset againist which they are run until they are deleted.

### ShowTask()

Retrieves tasks from the current graphset.
 
**Parameters:**

- `string`: Name of the algorithm or the ID of the task to be retrieved.
- `TaskStatus`: Status of the task.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Task`: The list of all tasks in the graphset.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

// Runs an algorithm as task in graphset 'miniCircle'

_, err1 := conn.Uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})",
  requestConfig)
if err1 != nil {
  println(err1)
}
time.Sleep(5 * time.Second)

// Retrieves the above task and shows task information

myTask, _ := conn.ShowTask("louvain", structs.TaskStatusDone, requestConfig)
println("TaskID:", myTask[0].TaskInfo.TaskID)
println("Algo name:", myTask[0].TaskInfo.AlgoName)
println("Task result:", utils.JSONString(myTask[0].Result))
```

<p tit="Output"></p> 
 
```java
TaskID: 65843
Algo name: louvain
Task result: {"community_count":"10","modularity":"0.528182","result_files":"communityID,ids,num"}
```

### ClearTask()

Clears (Deletes) tasks from the current graphset. Tasks with the status `TaskStatusComputing` and `TaskStatusWriting` cannot be cleared.
 
**Parameters:**

- `string`: Name of the algorithm or the ID of the task to be retrieved.
- `TaskStatus`: Status of the task.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

// Runs an algorithm as task in graphset 'miniCircle'

_, err := conn.Uql("algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})",
  requestConfig)
if err != nil {
  println(err)
}

time.Sleep(1 * time.Second)

// Clears the above task and prints error code

myTask, _ := conn.ShowTask("degree", structs.TaskstatusAll, requestConfig)
myTaskID := myTask[0].TaskInfo.TaskID
println("TaskID is:", myTaskID)

tClear, _ := conn.ClearTask(utils.JSONString(myTaskID), structs.TaskStatusDone, requestConfig)
println("Task cleared:", tClear.IsSuccess())
```

<p tit="Output"></p> 
 
```java
TaskID is: 65874
Task cleared: true
```

### StopTask()

Stops tasks whose status is `COMPUTING` in the current graphset.
 
**Parameters:**

- `string`: ID of the task to stop; set to `*` to stop all tasks.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
requestConfig := &configuration.RequestConfig{
  UseMaster: true,
  GraphName: "miniCircle",
}

// Runs an algorithm as task in graphset 'miniCircle'

_, err := conn.Uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID'}})",
  requestConfig)
if err != nil {
  println(err)
}

// Stops the above task and prints error code

myTask, _ := conn.ShowTask("louvain", structs.TaskstatusAll, requestConfig)
myTaskID := myTask[0].TaskInfo.TaskID
println("TaskID is:", myTaskID)

// Retrieves the above stopped task

tStop, _ := conn.StopTask(utils.JSONString(myTaskID), requestConfig)
println("Task is stopped:", tStop.IsSuccess())
```

<p tit="Output"></p> 
 
```java
TaskID is: 65886
Task is stopped: true
```

## Full Example

<p tit="Go"></p> 

```go
package main

import (
  "time"

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
    GraphName: "miniCircle",
  }

  // Runs an algorithm as task in graphset 'miniCircle'
  
  _, err1 := conn.Uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})",
    requestConfig)
  if err1 != nil {
    println(err1)
  }
  time.Sleep(5 * time.Second)

  // Retrieves the above task
  myTask, _ := conn.ShowTask("louvain", structs.TaskStatusDone, requestConfig)
  println("TaskID:", myTask[0].TaskInfo.TaskID)
  println("Algo name:", myTask[0].TaskInfo.AlgoName)
  println("Task result:", utils.JSONString(myTask[0].Result))  
};
```
