# Process and Task Management

This section introduces methods on a `Connection` object for managing processes in the instance and tasks in the current graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Process

All UQL queries, except for algorithms executed with the `write()` method, are run as processes. The results of these processes are returned to the client upon completion and are not stored.

### top()

Retrieves all running and stopping processes from the instance.
 
**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Process>`: The list of all processes in the instance.

```java
// Retrieves all running and stopping processes in the instance

List<Process> processList = client.top();
for (Process process : processList) {
    System.out.println(process.getProcessId() + " " + process.getProcessUql());
}
```

<p tit="Output"></p> 

```
a_0_539_2 n({_uuid > 300}).e()[:3].n() as p RETURN p{*} LIMIT 500
```

### kill()

Kills running processes in the instance.
 
**Parameters:**

- `String`: ID of the process to kill; set to `*` to kill all processes.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Retrieves all running and stopping processes in the instance and kill all

List<Process> processList = client.top();
for (Process process : processList) {
    System.out.println(process.getProcessId() + " " + process.getProcessUql());
}
Response response = client.kill("*"); 
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 

```
a_0_540_2 n({_uuid > 300}).e()[:3].n() as p RETURN p{*} LIMIT 500
SUCCESS
```

## Task

Algorithms executed with the `write()` method are run as tasks. These tasks are stored in the graphset againist which they are run until they are deleted.

### showTask()

Retrieves tasks from the current graphset.
 
**Parameters:**

- `ShowTask` (Optional): Configurations for the task to retrieve, including `id:String`, `name:String` and `status:TaskStatus` (`id` takes precedence when `id` and `name` are both set); if ignored, all tasks are retrieved.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Task>`: The list of all tasks in the graphset.

<p titl="Java"></p>

```js
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("miniCircle");

// Runs an algorithm as task in graphset 'miniCircle'

Response response = client.uql("algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})", requestConfig);
String taskID = (String) response.alias("_task").asTable().getRows().get(0).get(0);
Thread.sleep(3000);

// Retrieves the above task

ShowTask showTask = new ShowTask();
showTask.setId(taskID);
//showTask.setName("degree");
showTask.setStatus(TaskStatus.DONE);

List<Task> taskList = client.showTask(showTask, requestConfig);
for (Task task : taskList) {
    System.out.println("Task ID: " + task.getTaskInfo().getTaskId());
    System.out.println("Server ID: " + task.getTaskInfo().getServerId());
    System.out.println("Algo Name: " + task.getTaskInfo().getAlgoName());
    System.out.println("Task Params: " + task.getParam().toString());
    System.out.println("Task Result: " + task.getResult().toString());
}
```

<p tit="Output"></p>

```
Task ID: 54240
Server ID: 3
Algo Name: degree
Task Params: {order=desc}
Task Result: {total_degree=590.000000, avarage_degree=1.940789, result_files=degree_all}
```

### clearTask()

Clears (Deletes) tasks from the current graphset. Tasks with the status `COMPUTING` and `WRITING` cannot be cleared.
 
**Parameters:**

- `ClearTask` (Optional): Configurations for the task to clear, including `id:Integer`, `name:String` and `status:TaskStatus` (`id` takes precedence when `id` and `name` are both set); if ignored, all tasks are cleared.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p titl="Java"></p>

```js
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("miniCircle");

// Runs an algorithm as task in graphset 'miniCircle'

Response response = client.uql("algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})", requestConfig);
String id = (String) response.alias("_task").asTable().getRows().get(0).get(0);
Integer taskID = Integer.parseInt(id);
Thread.sleep(3000);

// Clears the above task

ClearTask clearTask = new ClearTask();
clearTask.setId(taskID);
//clearTask.setName("degree");
clearTask.setStatus(TaskStatus.DONE);

Response response1 = client.clearTask(clearTask, requestConfig);
System.out.println("Task " + taskID + " cleared: " + response1.getStatus().getErrorCode());
```

<p tit="Output"></p>

```
Task 54242 cleared: SUCCESS
```

### stopTask()

Stops tasks whose status is `COMPUTING` in the current graphset.
 
**Parameters:**

- `String`: ID of the task to stop; set to `*` to stop all tasks.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("Ad_Click");

// Runs an algorithm as task in graphset 'Ad_Click'

Response response = client.uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID'}})", requestConfig);
String taskId = (String) response.get(0).asTable().getRows().get(0).get(0);

// Stops the above task and prints error code

Response response1 = client.stopTask(taskId, requestConfig);
System.out.println("Task " + taskId + " stopped: " + response1.getStatus().getErrorCode());

// Retrieves the above stopped task
ShowTask showTask = new ShowTask();
showTask.setId(taskId);
showTask.setStatus(TaskStatus.STOP);

Thread.sleep(3000);

List<Task> taskList = client.showTask(showTask, requestConfig);
for (Task task : taskList) {
    System.out.println("Task ID: " + task.getTaskInfo().getTaskId());
    System.out.println("Server ID: " + task.getTaskInfo().getServerId());
    System.out.println("Algo Name: " + task.getTaskInfo().getAlgoName());
    System.out.println("Task Params: " + task.getParam().toString());
    System.out.println("Task Result: " + task.getResult().toString());
}
```

<p tit="Output"></p>

```
Task 54248 stopped: SUCCESS
Task ID: 54248
Server ID: 3
Algo Name: louvain
Task Params: {phase1_loop_num=20, min_modularity_increase=0.001}
Task Result: {community_count=1228589, modularity=0.647601}
```

## Full Example

<p tit="Main.java"></p>

```js
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;
import com.ultipa.sdk.connect.request.ShowTask;
import com.ultipa.sdk.operate.entity.*;
import com.ultipa.sdk.operate.enums.TaskStatus;
import com.ultipa.sdk.operate.response.Response;
import java.util.List;

public class Main {
    public static void main(String[] args) {
        // Connection configurations
        UltipaConfiguration myConfig = UltipaConfiguration.config()
            // URI example: .hosts("mqj4zouys.us-east-1.cloud.ultipa.com:60010")
            .hosts("192.168.1.85:60611,192.168.1.87:60611,192.168.1.88:60611")
            .username("<username>")
            .password("<password>");

        UltipaClientDriver driver = null;
        try {
            // Establishes connection to the database
            driver = new UltipaClientDriver(myConfig);
            Connection client = driver.getConnection();

            Thread.sleep(3000);
          
            RequestConfig requestConfig = new RequestConfig();
            requestConfig.setGraphName("miniCircle");

            // Runs an algorithm as task in graphset 'miniCircle'

            Response response = client.uql("algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})", requestConfig);
            String taskID = (String) response.alias("_task").asTable().getRows().get(0).get(0);
            Thread.sleep(3000);

            // Retrieves the above task

            ShowTask showTask = new ShowTask();
            showTask.setId(taskID);
            //showTask.setName("degree");
            showTask.setStatus(TaskStatus.DONE);

            List<Task> taskList = client.showTask(showTask, requestConfig);
            for (Task task : taskList) {
                System.out.println("Task ID: " + task.getTaskInfo().getTaskId());
                System.out.println("Server ID: " + task.getTaskInfo().getServerId());
                System.out.println("Algo Name: " + task.getTaskInfo().getAlgoName());
                System.out.println("Task Params: " + task.getParam().toString());
                System.out.println("Task Result: " + task.getResult().toString());
            }
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```
