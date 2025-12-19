## Convenience Methods

## Graph

This section introduces methods for managing graphs in the database.

## showGraph()

Retrieves all graphs from the database.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `GraphSet[]`: The list of retrieved graphs.

 ```ts
// Retrieves all graphs
const graphs = await driver.showGraph();
graphs.forEach((graph) => console.log(graph.name));
```

<p tit="Output"></p> 
 
```
Display_Ad_Click
ERP_DATA2
wikiKG
```

## getGraph()

Retrieves a specified graph from the database.

**Parameters**

- `graphName: string`: Name of the graph.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `GraphSet`: The retrieved graph.

 ```ts
// Retrieves the graph named 'miniCircle'
const graph = await driver.getGraph("miniCircle");
console.log(graph);
```

<p tit="Output"></p> 
 
```
GraphSet {
  id: '9',
  name: 'miniCircle',
  totalNodes: '97',
  totalEdges: '632',
  shards: [ '1' ],
  partitionBy: 'CityHash64',
  status: 'NORMAL',
  description: '',
  slotNum: 256
}
```

## hasGraph()

Checks the existence of a specified graph in the database.

**Parameters**

- `graphName: string`: Name of the graph.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `boolean`: Check result.

 ```ts
// Checks the existence of a graph named 'miniCircle'
const graphName = "miniCircle";
const response = await driver.hasGraph(graphName);
console.log("Graph", graphName, "exists:", response);
```

<p tit="Output"></p> 
 
```
Graph miniCircle exists: true
```

## createGraph()

Creates a graph in the database.

**Parameters**

- `graphSet: GraphSet`: The graph to be created; the filed `name` is mandatory, `shards`, `partitionBy` and `description` are optional.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

```ts
// Creates a graph
const graph: GraphSet = {
  name: "myGraph",
  shards: ["1"],
  partitionBy: "Crc32",
  description: "My first graph"
};
const response = await driver.createGraph(graph)
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## createGraphIfNotExist()

Creates a graph in the database and returns whether a graph with the same name already exists.

**Parameters**

- `graphSet: GraphSet`: The graph to be created; the filed `name` is mandatory, `shards`, `partitionBy` and `description` are optional.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `ResponseWithExistCheck`: Response of the request.

```ts
// Creates a graph with existence check
const graph: GraphSet = {
  name: "myGraph",
  shards: ["1"],
  partitionBy: "Crc32",
  description: "My first graph"
};
const result = await driver.createGraphIfNotExist(graph);
console.log("Graph already exists:", result.exist);
if (result.response.status?.code !== 0) {
  console.log("Error message:", result.response.status?.message);
} else {
  if (result.response.statistics?.totalCost === 0) {
    console.log("New graph created: No");
  } else {
    console.log("New graph created: Yes");
  }
};
```

<p tit="Output"></p> 
 
```
Graph already exists: true
New graph created: No
```

## alterGraph()

Alters the name and description of a graph in the database.

**Parameters**

- `graphName: string`: Name of the graph.
- `alterGraphset: GraphSet`: A `GraphSet` object used to set new `name` and/or `description` for the graph.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Alters the name and description of the graph 'myGraph'
const newGraphInfo: GraphSet = {
  name: "newGraph",
  description: "a new graph"
};
const response = await driver.alterGraph("myGraph", newGraphInfo);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## dropGraph()

Deletes a specified graph from the database.

**Parameters**

- `graphName: string`: Name of the graph.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Drops a graph
const response = await driver.dropGraph("myGraph");
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## truncate()

Truncates (Deletes) the specified nodes or edges in a graph or truncates the entire graph. Note that truncating nodes will cause the deletion of edges attached to those affected nodes. The truncating operation retains the definition of schemas and properties in the graph.

**Parameters**

- `params: TruncateParams`: The truncate parameters; the filed `graphName` is mandatory, `schemaName` and `dbType` are optional.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Truncates User nodes in 'myGraph'
const param1: TruncateParams = { graphName: "myGraph", schemaName: "User", dbType: DBType.DBNODE }
const response1 = await driver.truncate(param1);
console.log(response1.status?.message);

// Truncates all edges in the 'myGraph'
const param2: TruncateParams = { graphName: "myGraph", schemaName: "*", dbType: DBType.DBEDGE }
const response2 = await driver.truncate(param2);
console.log(response2.status?.message);

// Truncates 'myGraph'
const param3: TruncateParams = { graphName: "myGraph" }
const response3 = await driver.truncate(param3);
console.log(response3.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
SUCCESS
```

## compact()

Clears invalid and redundant data for a graph. Valid data will not be affected.

**Parameters**

- `graphName: string`: Name of the graph.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `JobResponse`: Response of the request.

 ```ts
// Compacts the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const jobResponse = await driver.compact("miniCircle", requestConfig);
console.log("Start compacting:", jobResponse.status?.message)
const jobID = jobResponse.jobId;

await new Promise(resolve => setTimeout(resolve, 3000))

const jobs = await driver.showJob(jobID, requestConfig);
for (const job of jobs) {
  console.log("Compact graph job:", `${job.id} - ${job.status}`);
}
```

<p tit="Output"></p> 
 
```
Start compacting: SUCCESS
Compact graph job: 4 - FINISHED
Compact graph job: 4_1 - FINISHED
```

## Full Example

<p tit="Example.ts"></p> 

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { GraphSet } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);

  // Creates a graph
  const graph: GraphSet = {
    name: "myGraph1",
    shards: ["1"],
    partitionBy: "Crc32",
    description: "My first graph"
  };
  const response = await driver.createGraph(graph)
  console.log(response.status?.message);
};

sdkUsage().catch(console.error);
```
