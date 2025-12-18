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

- `List[Top]`: The list of all processes in the instance.

<p tit="Python"></p> 

```Python
# Retrieves all running and stopping processes in the instance

processList = Conn.top()
for process in processList:
    print("process_id: " + process.process_id)
    print("process_uql: " + process.process_uql)
```

<p tit="Output"></p> 

```python
process_id: a_7_11229_2
process_uql: n({_uuid > 300}).e()[:3].n() as p RETURN p{*} LIMIT 500
```

### kill()

Kills running processes in the instance.
 
**Parameters:**

- `str`: ID of the process to kill; set to `*` to kill all processes.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 

```Python
# Retrieves all running and stopping processes in the instance and kill all

processList = Conn.top()
for process in processList:
    print("process_id:" + process.process_id)
    print("process_uql:" + process.process_uql)
    print("duration:" + process.duration)
    print("status:" + process.status)

response = Conn.kill(processId = "*")
print(response.status.code)
```

<p tit="Output"></p> 

```Python
process_id:a_4_11461_2
process_uql:n({_uuid > 300}).e()[:3].n() as p RETURN p{*} LIMIT 500
duration:2
status:RUNNING
0
```

## Task

Algorithms executed with the `write()` method are run as tasks. These tasks are stored in the graphset against which they are run until they are deleted.

### showTask()

Retrieves tasks from the current graphset.
 
**Parameters:**

- `Union[int, str]` (Optional): Task ID (`int`) or task name (`str`).
- `TaskStatus` (Optional): Task status. If both this parameter and the first parameters are set, the first parameter takes precedence.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Task]`: The list of all tasks in the graphset.

<p tit="Python"></p> 

```Python
requestConfig = RequestConfig(graphName="miniCircle")

# Runs an algorithm as task in graphset 'miniCircle'

response = Conn.uql("algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})", requestConfig)
taskID = response.alias("_task").asTable().rows[0][0]

time.sleep(3)

# Retrieves the above task

tasksList = Conn.showTask(algoNameOrId=int(taskID), config=requestConfig)
#tasksList = Conn.showTask(algoNameOrId=str("degree"), status=TaskStatus.Done, config=requestConfig)

for task in tasksList:
    print("Task ID:", task.task_info.task_id)
    print("Server ID:", task.task_info.server_id)
    print("Algo Name:", task.task_info.algo_name)
    print("Task Status:", task.task_info.TASK_STATUS)
    print("Task Params:", task.param)
    print("Task Result:", task.result)
```

<p tit="Output"></p>

```Python
Task ID: 79686
Server ID: 1
Algo Name: degree
Task Status: 3
Task Params: {'order': 'desc'}
Task Result: {'total_degree': '1392.000000', 'avarage_degree': '4.578947', 'result_files': 'degree_all'}
```

### clearTask()

Clears (Deletes) tasks from the current graphset. Tasks with the status `COMPUTING` and `WRITING` cannot be cleared.
 
**Parameters:**

- `Union[int, str]` (Optional): Task ID (`int`) or task name (`str`).
- `TaskStatus` (Optional): Task status. If both this parameter and the first parameters are set, the first parameter takes precedence.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 

```Python
requestConfig = RequestConfig(graphName="miniCircle")

# Runs an algorithm as task in graphset 'miniCircle'

response = Conn.uql("algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})", requestConfig=requestConfig)
taskID = response.alias("_task").asTable().rows[0][0]
time.sleep(3)

# Clears the above task

response1 = Conn.clearTask(algoNameOrId=int(taskID), config=requestConfig)
print(f"Task {taskID} cleared: {response1.status.code}")
```

<p tit="Output"></p>

```Python
Task 79687 cleared: 0
```

### stopTask()

Stops tasks whose status is `COMPUTING` in the current graphset.
 
**Parameters:**

- `str`: ID of the task to stop; set to `*` to stop all tasks.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p>

```Python
requestConfig = RequestConfig(graphName="miniCircle")

# Runs an algorithm as task in graphset 'miniCircle'

response = Conn.uql("algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001})."
                    "write({file:{filename_community_id: 'communityID'}})", requestConfig)
taskID = response.alias("_task").asTable().rows[0][0]
time.sleep(3)

# Stops the above task and prints error code

response1 = Conn.stopTask(taskID, requestConfig)
print(f"Task {taskID} stopped: {response1.status.code}")

# Retrieves the above stopped task
task = Conn.showTask(algoNameOrId=int(taskID), config=requestConfig)

print("Task ID:", task[0].task_info.task_id)
print("Server ID:", task[0].task_info.server_id)
print("Algo Name:", task[0].task_info.algo_name)
print("Task Params:", task[0].param)
print("Task Result:", task[0].result)
```

<p tit="Output"></p>

```python
Task 79689 stopped: 0
Task ID: 79689
Server ID: 2
Algo Name: louvain
Task Params: {'phase1_loop_num': '20', 'min_modularity_increase': '0.001'}
Task Result: {}
```

## Full Example

<p tit="Example.py"></p>

```Python
from ultipa import Connection, UltipaConfig, TaskStatus
from ultipa.configuration.RequestConfig import RequestConfig
import time

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061","192.168.1.87:60061","192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)

# Request configurations
requestConfig = RequestConfig(graphName="miniCircle")

# Runs an algorithm as task in graphset 'miniCircle'
response = Conn.uql("algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})", requestConfig)
taskID = response.alias("_task").asTable().rows[0][0]
time.sleep(3)

# Retrieves the above task
task = Conn.showTask(algoNameOrId=int(taskID), config=requestConfig)

print("Task ID:", task[0].task_info.task_id)
print("Server ID:", task[0].task_info.server_id)
print("Algo Name:", task[0].task_info.algo_name)
print("Task Params:", task[0].param)
print("Task Result:", task[0].result)
```
