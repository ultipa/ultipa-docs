# Process and Task Management

This section introduces methods on a `Connection` object for managing processes in the instance and tasks in the current graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Process

All UQL queries, except for algorithms executed with the `write()` method, are run as processes. The results of these processes are returned to the client upon completion and are not stored.

### Top()

Retrieves all running and stopping processes from the instance.
 
**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Process>`: The list of all processes in the instance.

<p tit= "C#" ></p> 
 
```c#
// Retrieves all running and stopping processes in the instance

RequestConfig requestConfig = new RequestConfig() { UseMaster = true };
var processList = await ultipa.Top(requestConfig);

Console.WriteLine(JsonConvert.SerializeObject(processList));
```

<p tit= "Output" ></p> 
 
```java
[{"Id":"a_7_33_2","Uql":"n().e().n().e().n().e().n() as p return count(p)","Duration":73,"Status":"RUNNING"}]
```

### Kill()

Kills running processes in the instance.
 
**Parameters:**

- `string`: ID of the process to kill; set to `*` to kill all processes.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
// Retrieves all running and stopping processes in the instance and kill all

RequestConfig requestConfig = new RequestConfig() { UseMaster = true };
var processList = await ultipa.Top(requestConfig);
foreach (var process in processList)
{
    Console.WriteLine("Process ID: " + process.Id);
    Console.WriteLine("UQL: " + process.Uql);
}
Thread.Sleep(1000);
var res = await ultipa.Kill("*", requestConfig);

if (res.Status.ErrorCode == 0)
{
    Console.WriteLine("Operation succeeds");
}
```

<p tit= "Output" ></p> 
 
```java
Process ID: a_6_41_2
UQL: n().e().n().e().n().e().n() as p return count(p)
Operation succeeds
```

## Task

Algorithms executed with the `write()` method are run as tasks. These tasks are stored in the graphset against which they are run until they are deleted.

### ShowTask()

Retrieves tasks from the current graphset.
 
**Parameters:**

- `string` or `int` : Name of the algorithm (`string`) or the ID of the task (`int`) to be retrieved.
- `TaskStatus` (Optional): Status of the task.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Task>`: The list of all tasks in the graphset.

<p tit= "C#" ></p> 
 
```c#
RequestConfig requestConfig = new RequestConfig()
{
    UseMaster = true,
    Graph = "miniCircle",
};

// Runs an algorithm as task in graphset 'miniCircle'

var res = await ultipa.Uql(
    "algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})",
    requestConfig
);
var taskID = Convert.ToInt32(res?.Alias("_task")?.AsTable()?.Rows[0][0]);
Thread.Sleep(5000);

// Retrieves the above task and shows task information

var showT = await ultipa.ShowTask(taskID, requestConfig);
Console.WriteLine("Task ID: " + JsonConvert.SerializeObject(showT[0].Info.TaskId));
Console.WriteLine("Algo name: " + JsonConvert.SerializeObject(showT[0].Info.AlgoName));
Console.WriteLine("Task result: " + JsonConvert.SerializeObject(showT[0].result));
```

<p tit= "Output" ></p> 
 
```java
Task ID: "72122"
Algo name: "degree"
Task result: {"total_degree":"1390.000000","avarage_degree":"4.572368","result_files":"degree_all"}
```

### ClearTask()

Clears (Deletes) tasks from the current graphset. Tasks with the status `TaskStatusComputing` and `TaskStatusWriting` cannot be cleared.
 
**Parameters:**

- `string` or `int` : Name of the algorithm (`string`) or the ID of the task (`int`) to be retrieved.
- `TaskStatus`: Status of the task.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
RequestConfig requestConfig = new RequestConfig()
{
    UseMaster = true,
    Graph = "miniCircle",
};

// Runs an algorithm as task in graphset 'miniCircle'

var res = await ultipa.Uql(
    "algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})",
    requestConfig
);
var taskID = Convert.ToInt32(res?.Alias("_task")?.AsTable()?.Rows[0][0]);

Thread.Sleep(5000);

// Clears the above task and prints error code

var clearT = await ultipa.ClearTask(taskID, requestConfig);
Console.WriteLine("Task ID: " + taskID);
if (clearT.Status.ErrorCode == 0)
{
    Console.WriteLine("Task cleared");
}
else
{
    Console.WriteLine("Task not cleared");
}
```

<p tit= "Output" ></p> 
 
```java
Task ID: 72124
Task cleared
```

### StopTask()

Stops tasks whose status is `COMPUTING` in the current graphset.
 
**Parameters:**

- `string`: ID of the task to stop; set to `*` to stop all tasks.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
RequestConfig requestConfig = new RequestConfig()
{
    UseMaster = true,
    Graph = "miniCircle",
};

// Runs an algorithm as task in graphset 'miniCircle'

var res = await ultipa.Uql(
    "algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})",
    requestConfig
);
var taskID = Convert.ToString(res?.Alias("_task")?.AsTable()?.Rows[0][0]);

// Stops the above task and prints error code

var stopT = await ultipa.StopTask(taskID, requestConfig);
Console.WriteLine("Task ID: " + taskID);
Console.WriteLine("Task is stopped: " + stopT.Status.ErrorCode);
```

<p tit= "Output" ></p> 
 
```java
Task ID: 72126
Task is stopped: Success
```

## Full Example

<p tit= "C#" ></p> 

```c#
using System.Data;
using System.Security.Cryptography.X509Certificates;
using System.Xml.Linq;
using Google.Protobuf.WellKnownTypes;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using UltipaService;
using UltipaSharp;
using UltipaSharp.api;
using UltipaSharp.configuration;
using UltipaSharp.connection;
using UltipaSharp.exceptions;
using UltipaSharp.structs;
using UltipaSharp.utils;
using Logger = UltipaSharp.utils.Logger;
using Property = UltipaSharp.structs.Property;
using Schema = UltipaSharp.structs.Schema;

class Program
{
    static async Task Main(string[] args)
    {
        // Connection configurations
        //URI example: Hosts=new[]{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"}
        var myconfig = new UltipaConfig()
        {
            Hosts = new[] { "192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061" },
            Username = "***",
            Password = "***",
        };

        // Establishes connection to the database
        var ultipa = new Ultipa(myconfig);
        var isSuccess = ultipa.Test();
        Console.WriteLine(isSuccess);

        // Request configurations
        RequestConfig requestConfig = new RequestConfig()
        {
            UseMaster = true,
            Graph = "miniCircle",
        };

        // Runs an algorithm as task in graphset 'miniCircle'
        
        var res = await ultipa.Uql(
            "algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})",
            requestConfig
        );
        var taskID = Convert.ToInt32(res?.Alias("_task")?.AsTable()?.Rows[0][0]);
        Thread.Sleep(5000);

        // Retrieves the above task and shows task information

        var showT = await ultipa.ShowTask(taskID, requestConfig);
        Console.WriteLine("Task ID: " + JsonConvert.SerializeObject(showT[0].Info.TaskId));
        Console.WriteLine("Server ID: " + JsonConvert.SerializeObject(showT[0].Info.ServerId));
        Console.WriteLine("Algo name: " + JsonConvert.SerializeObject(showT[0].Info.AlgoName));
        Console.WriteLine("Task result: " + JsonConvert.SerializeObject(showT[0].result));
    }
}
```
