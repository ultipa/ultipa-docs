# Process and Job

This section introduces methods for managing processes and jobs.

# Process

### top()

Retrieves all running processes in the database.
 
**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Process[]`: The list of retrieved processes.

```ts
// Retrieves all running processes in the database
const processes = await driver.top();
for (const process of processes){
  console.log(`${process.processId} - ${process.processQuery}`);
}
```

<p tit="Output"></p> 

```
1049542 - MATCH p = ()->{1,3}() RETURN p LIMIT 5000
```

### kill()

Kills running processes in the database.

**Parameters**

- `processId: string`: ID of the process to kill.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

```ts
// Retrieves all running processes in the database and kills them all
const processes = await driver.top();
for (const process of processes) {
  console.log("Attempting to kill process", process.processId);
  const response = await driver.kill(process.processId);
}
```

<p tit="Output"></p> 

```
Attempting to kill process 1049141
Attempting to kill process 1049140
```

## Job

### showJob()

Retrieves jobs in the graph.
 
**Parameters**

- `id?: string`: Job ID.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Job[]`: The list of retrieved jobs.

```ts
// Retrieves all jobs in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const jobs = await driver.showJob(undefined, requestConfig);
if (jobs.length > 0) {
  for (const job of jobs) {
    console.log(`${job.id} - ${job.type} - ${job.status}`);
  }
} else {
  console.log("No jobs found");
}
```

<p tit="Output"></p>

```
22 - CREATE_FULLTEXT - FINISHED
22_1 - CREATE_FULLTEXT - FINISHED
21 - CREATE_FULLTEXT - FAILED
20 - CREATE_FULLTEXT - FINISHED
20_1 - CREATE_FULLTEXT - FINISHED
```

### stopJob()

Stops a running job in the graph.
 
**Parameters**

- `id: string`: ID of the job to stop.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

<p tit="TypeScript"></p>

```ts
// Retrieves all running jobs in the graph 'miniCircle' and stops them all
const requestConfig: RequestConfig = { graph: "miniCircle" };
const jobs = await driver.showJob(undefined, requestConfig);
const running_jobs = jobs.filter((job) => job.status === "RUNNING");
if (running_jobs.length > 0) {
  for (const running_job of running_jobs) {
    const response = await driver.stopJob(running_job.id, requestConfig);
    console.log(
      `Attempting to stop job ${running_job.id} - ${running_job.type}`
    );
  }
} else {
  console.log("No running jobs found");
}
```

<p tit="Output"></p>

```
Attempting to stop job 10 - CREATE_HDC_GRAPH
```

### clearJob()

Clears a job that is not running from the graph.
 
**Parameters**

- `id: string`: ID of the job to clear.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

```ts
// Retrieves all failed jobs in the graph 'miniCircle' and clears them all
const requestConfig: RequestConfig = { graph: "miniCircle" };
const jobs = await driver.showJob(undefined,requestConfig);
const failed_jobs = jobs.filter((job) => job.status === "FAILED");
if (failed_jobs.length > 0) {
  for (const job of failed_jobs) {
    const response = await driver.clearJob(job.id, requestConfig);
    console.log(`Clear job ${job.id} ${response.status?.message}`);
  }
} else {
  console.log("No failed jobs found");
}
```

<p tit="Output"></p>

```
Clear job 51 SUCCESS
Clear job 42 SUCCESS
Clear job 26 SUCCESS
Clear job 26_1 SUCCESS
```

## Full Example

<p tit="Example.ts"></p>

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { RequestConfig } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);

  // Retrieves all jobs in the graph 'miniCircle'
  const requestConfig: RequestConfig = { graph: "miniCircle" };
  const jobs = await driver.showJob(undefined, requestConfig);
  if (jobs.length > 0) {
    for (const job of jobs) {
      console.log(`${job.id} - ${job.type} - ${job.status}`);
    }
  } else {
    console.log("No jobs found");
  }

};

sdkUsage().catch(console.error);
```
