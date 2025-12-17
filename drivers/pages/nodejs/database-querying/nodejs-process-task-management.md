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

- `Response`: The list of all processes in the instance.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves all running and stopping processes in the instance

let resp = await conn.top();
console.log(resp.data);
```

<p tit= "Output" ></p> 
 
```java
[
  {
    process_id: 'a_0_1519_2',
    status: 'RUNNING',
    process_uql: 'n().e().n().e().n().e().n() as p return count(p)',
    duration: '7'
  }
]
```

### kill()

Kills running processes in the instance.
 
**Parameters:**

- `string` (Optional): ID of the process to kill; set to `*` to kill all processes.
- `boolean` (Optional): Set to true to ignore process ID and kill all processes.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves all running and stopping processes in the instance and kill all

let resp1 = await conn.top();
let processList = resp1.data.map((item) => [
  item.process_id,
  item.process_uql,
]);
console.log(processList);

let resp = await conn.kill("*");
console.log(resp.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
[
  [ 'a_2_1542_2', 'n().e().n().e().n().e().n() as p return count(p)' ],
  [ 'a_6_1597_2', 'n().e().n().e().n()as p return count(p)' ]
]
SUCCESS
```

## Task

Algorithms executed with the `write()` method are run as tasks. These tasks are stored in the graphset againist which they are run until they are deleted.

### showTask()

Retrieves tasks from the current graphset.
 
**Parameters:**

- `string` (Optional): Name of the algorithm or the ID of the task to be retrieved.
- `RequestType.TASK_STATUS` (Optional): Status of the task.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Task[]`: The list of all tasks in the graphset.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
  graphSetName: "miniCircle",
};

// Runs an algorithm as task in graphset 'miniCircle'

let algoTest = await conn.uql(
  "algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})",
  requestConfig
);

// Retrieves the above task and shows task information

let taskInfo = algoTest.data?.get(0).asTable();
let taskId = taskInfo.getRows()[0][0];

await sleep(3000);

let resp = await conn.showTask(
  taskId,
  RequestType.TASK_STATUS.TASK_DONE,
  requestConfig
);
console.log("Task ID: ", taskId);
console.log(
  "Algo name: ",
  resp.data.map((item) => item.task_info.algo_name)
);
console.log(
  "Task result: ",
  resp.data.map((item) => item.result)
);
```

<p tit= "Output" ></p> 
 
```java
Task ID:  54252
Algo Name:  degree
Task Result:  {
  total_degree: '591.000000',
  avarage_degree: '1.944079',
  result_files: 'degree_all'
}
```

### clearTask()

Clears (Deletes) tasks from the current graphset. Tasks with the status `COMPUTING` and `WRITING` cannot be cleared.
 
**Parameters:**

- `string` (Optional): Name of the algorithm or the ID of the task to be retrieved.
- `RequestType.TASK_STATUS` (Optional): Status of the task.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
  graphSetName: "miniCircle",
};

// Runs an algorithm as task in graphset 'miniCircle'

let algoTest = await conn.uql(
  "algo(degree).params({order: 'desc'}).write({file:{filename: 'degree_all'}})",
  requestConfig
);

// Clears the above task and prints error code

let taskInfo = algoTest.data?.get(0).asTable();
let taskId = taskInfo.getRows()[0][0];

let resp = await conn.clearTask(
  taskId,
  RequestType.TASK_STATUS.TASK_DONE,
  requestConfig
);
console.log("Task ID: ", taskId);
console.log("Task cleared: ", resp.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
Task ID:  60451
Task cleared:  SUCCESS
```

### stopTask()

Stops tasks whose status is `COMPUTING` in the current graphset.
 
**Parameters:**

- `string` or `number`: ID of the task to stop; set to `*` to stop all tasks.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
  graphSetName: "miniCircle",
};

// Runs an algorithm as task in graphset 'miniCircle'

let algoTest = await conn.uql(
  "algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID'}})",
  requestConfig
);

// Stops the above task and prints error code

let taskInfo = algoTest.data?.get(0).asTable();
let taskId = taskInfo.getRows()[0][0];

let stopTask = await conn.stopTask(taskId, requestConfig);

console.log("Task ID: ", taskId);
console.log("Task stopped: ", resp.status.code_desc);

// Retrieves the above stopped task

let resp = await conn.showTask(
  taskId,
  RequestType.TASK_STATUS.TASK_STOPPED,
  requestConfig
);

console.log(
  "Algo name: ",
  resp.data.map((item) => item.task_info.algo_name)
);
console.log(
  "Task result: ",
  resp.data.map((item) => item.result)
);
```

<p tit= "Output" ></p> 
 
```java
Task ID:  60495
Task stopped:  SUCCESS
Algo name:  [ 'louvain' ]
Task result:  [ { community_count: '11', modularity: '0.533843' } ]
```

## Full Example

<p tit= "TypeScript" ></p> 

```ts
import { ConnectionPool, ULTIPA } from "@ultipa-graph/ultipa-node-sdk";
import { GraphExra } from "@ultipa-graph/ultipa-node-sdk/dist/connection/extra/graph.extra";
import { getEdgesPrintInfo } from "@ultipa-graph/ultipa-node-sdk/dist/printers/edge";
import { RequestType } from "@ultipa-graph/ultipa-node-sdk/dist/types";
import { ListFormat } from "typescript";

let sdkUsage = async () => {
  // Connection configurations
  //URI example: hosts="mqj4zouys.us-east-1.cloud.ultipa.com:60010"
  let hosts = [
    "192.168.1.85:60061",
    "192.168.1.86:60061",
    "192.168.1.87:60061",
  ];
  let username = "***";
  let password = "***";
  let connPool = new ConnectionPool(hosts, username, password);

  // Establishes connection to the database
  let conn = await connPool.getActive();
  let isSuccess = await conn.test();
  console.log(isSuccess);

  // Request configurations
  let requestConfig = <RequestType.RequestConfig>{
    graphSetName: "miniCircle",
    useMaster: true,
  };

  // Runs an algorithm as task in graphset 'miniCircle'
  
  let algoTest = await conn.uql(
  "algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID'}})",
  requestConfig
);
 // Retrieves the above task
  let taskInfo = algoTest.data?.get(0).asTable();
  let taskId = taskInfo.getRows()[0][0];
  
  let resp = await conn.showTask(
    taskId,
    RequestType.TASK_STATUS.TASK_DONE,
    requestConfig
  );

  console.log(
    "Algo name: ",
    resp.data.map((item) => item.task_info.algo_name)
  );
  console.log(
    "Task result: ",
    resp.data.map((item) => item.result)
  );    
};

sdkUsage().then(console.log).catch(console.log);
```
