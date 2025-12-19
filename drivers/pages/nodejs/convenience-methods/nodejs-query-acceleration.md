# Query Acceleration

This section introduces methods for managing various indexes and LTE status for properties in graphs.

# Index

### showIndex()

Retrieves all indexes from the graph.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Index[]`: The list of retrieved indexes.

 ```ts
// Retrieves indexes in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const indexList = await driver.showIndex(requestConfig);
for (const index of indexList) {
  console.log(index);
}
```

<p tit="Output"></p> 
 
```
Index {
  id: '1',
  name: 'test_index',
  properties: 'year,float',
  schema: 'account',
  status: 'DONE',
  size: undefined,
  dbType: 0
}
Index {
  id: '2',
  name: 'year_index',
  properties: 'year',
  schema: 'account',
  status: 'DONE',
  size: undefined,
  dbType: 0
}
Index {
  id: '1',
  name: 'targetPostInd',
  properties: 'targetPost',
  schema: 'disagree',
  status: 'DONE',
  size: undefined,
  dbType: 1
}
```

### showNodeIndex()

Retrieves all node indexes from the graph.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Index[]`: The list of retrieved indexes.

 ```ts
// Retrieves node indexes in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const indexList = await driver.showNodeIndex(requestConfig);
for (const index of indexList) {
  console.log(index);
}
```

<p tit="Output"></p> 
 
```
Index {
  id: '1',
  name: 'test_index',
  properties: 'year,float',
  schema: 'account',
  status: 'DONE',
  size: undefined,
  dbType: 0
}
Index {
  id: '2',
  name: 'year_index',
  properties: 'year',
  schema: 'account',
  status: 'DONE',
  size: undefined,
  dbType: 0
}
```

### showEdgeIndex()

Retrieves all edge indexes from the graph.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Index[]`: The list of retrieved indexes.

 ```ts
// Retrieves edge indexes in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const indexList = await driver.showEdgeIndex(requestConfig);
for (const index of indexList) {
  console.log(index);
}
```

<p tit="Output"></p> 
 
```
Index {
  id: '1',
  name: 'targetPostInd',
  properties: 'targetPost',
  schema: 'disagree',
  status: 'DONE',
  size: undefined,
  dbType: 1
}
```

### dropIndex()

Drops a specified index from the graph.

**Parameters**

- `dbType: DBType`: Type of the index (node or edge).
- `indexName: string`: Name of the index.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Drops the node index 'test_index' from the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const response = await driver.dropIndex(DBType.DBNODE, "test_index", requestConfig);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropNodeIndex()

Drops a specified node index from the graph.

**Parameters**

- `indexName: string`: Name of the index.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Drops the node index 'test_index' from the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const response = await driver.dropNodeIndex("test_index", requestConfig);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropEdgeIndex()

Drops a specified edge index from the graph.

**Parameters**

- `indexName: string`: Name of the index.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Drops the edge index 'targetPostInd' from the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const response = await driver.dropEdgeIndex("targetPostInd", requestConfig);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full-text

### showFulltext()

Retrieves all full-text indexes from the graph.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Index[]`: The list of retrieved full-text indexes.

 ```ts
// Retrieves full-text indexes in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const fulltextList = await driver.showFulltext(requestConfig);
for (const fulltext of fulltextList) {
  console.log(fulltext);
}
```

<p tit="Output"></p> 
 
```
Index {
  id: undefined,
  name: 'name',
  properties: 'name',
  schema: 'account',
  status: 'DONE',
  size: undefined,
  dbType: 0
}
Index {
  id: undefined,
  name: 'Content',
  properties: 'content',
  schema: 'review',
  status: 'DONE',
  size: undefined,
  dbType: 1
}
```

### showNodeFulltext()

Retrieves all node full-text indexes from the graph.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Index[]`: The list of retrieved full-text indexes.

 ```ts
// Retrieves node full-text indexes in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const fulltextList = await driver.showNodeFulltext(requestConfig);
for (const fulltext of fulltextList) {
  console.log(fulltext);
};
```

<p tit="Output"></p> 
 
```
Index {
  id: undefined,
  name: 'name',
  properties: 'name',
  schema: 'account',
  status: 'DONE',
  size: undefined,
  dbType: 0
}
```

### showEdgeFulltext()

Retrieves all edge full-text indexes from the graph.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Index[]`: The list of retrieved full-text indexes.

 ```ts
// Retrieves edge full-text indexes in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const fulltextList = await driver.showEdgeFulltext(requestConfig);
for (const fulltext of fulltextList) {
  console.log(fulltext);
}
```

<p tit="Output"></p> 
 
```
Index {
  id: undefined,
  name: 'Content',
  properties: 'content',
  schema: 'review',
  status: 'DONE',
  size: undefined,
  dbType: 1
}
```

### createFulltext()

Creates a full-text index in the graph.

**Parameters**

- `dbType: DBType`: Type of the full-text index (node or edge).
- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `fulltextName: string`: Name of the full-text index.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `JobResponse`: Response of the request.

 ```ts
// Creates a full-text index 'moviePlot' for the property 'plot' of the 'movie' nodes

const requestConfig: RequestConfig = { graph: "miniCircle" };

const response = await driver.createFulltext(DBType.DBNODE, "movie", "plot", "moviePlot", requestConfig);
const jobID = response.jobId;

await new Promise(resolve => setTimeout(resolve, 3000));

const jobs = await driver.showJob(jobID, requestConfig);
for (const job of jobs) {
  console.log(`${job.id} - ${job.status}`);
}
```

<p tit="Output"></p> 
 
```
19 - FINISHED
19_1 - FINISHED
```

### createNodeFulltext()

Creates a node full-text index in the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `fulltextName: string`: Name of the full-text index.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `JobResponse`: Response of the request.

 ```ts
// Creates a full-text index 'moviePlot' for the property 'plot' of the 'movie' nodes

const requestConfig: RequestConfig = { graph: "miniCircle" };

const response = await driver.createNodeFulltext("movie", "plot", "moviePlot", requestConfig);
const jobID = response.jobId;

await new Promise(resolve => setTimeout(resolve, 3000));

const jobs = await driver.showJob(jobID, requestConfig);
for (const job of jobs) {
  console.log(`${job.id} - ${job.status}`);
}
```

<p tit="Output"></p> 
 
```
20 - FINISHED
20_1 - FINISHED
```

### createEdgeFulltext()

Creates an edge full-text index in the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `fulltextName: string`: Name of the full-text index.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `JobResponse`: Response of the request.

 ```ts
// Creates a full-text index 'agreeNotes' for the property 'notes' of the 'agree' edges

const requestConfig: RequestConfig = { graph: "miniCircle" };

const response = await driver.createEdgeFulltext("agree", "notes", "agreeNotes", requestConfig);
const jobID = response.jobId;

await new Promise(resolve => setTimeout(resolve, 3000));

const jobs = await driver.showJob(jobID, requestConfig);
for (const job of jobs) {
  console.log(`${job.id} - ${job.status}`);
}
```

<p tit="Output"></p> 
 
```
21 - FINISHED
21_1 - FINISHED
```

### dropFulltext()

Drops a full-text index from the graph.

**Parameters**

- `dyType: DBType`: Type of the full-text index (node or edge).
- `fulltextName: string`: Name of the full-text index.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Drops the node full-index 'moviePlot' from the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const response = await driver.dropFulltext(DBType.DBNODE, "moviePlot", requestConfig);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## LTE

### lte()

Loads a property to the computing engine.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `propertyName: string`: Name of the property.
- `schemaName: string`: Name of the schema.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `JobResponse`: Response of the request.

 ```ts
// Loads the property 'year' of 'account' nodes to the computing engine

const requestConfig: RequestConfig = { graph: "miniCircle" };

const response = await driver.lte(DBType.DBNODE, "year", "account", requestConfig);
const jobID = response.jobId;

await new Promise(resolve => setTimeout(resolve, 3000));

const jobs = await driver.showJob(jobID, requestConfig);
for (const job of jobs) {
  console.log(`${job.id} - ${job.status}`);
}
```

<p tit="Output"></p> 
 
```
24 - FINISHED
24_1 - FINISHED
```

### ufe()

Unloads a property from the computing engine.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `propertyName: string`: Name of the property.
- `schemaName: string`: Name of the schema.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Unloads the property 'year' of 'account' nodes from the computing engine
const requestConfig: RequestConfig = { graph: "miniCircle" };
const response = await driver.ufe(DBType.DBNODE, "year", "account", requestConfig);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
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

  // Retrieves indexes in the graph 'miniCircle'
  const requestConfig: RequestConfig = { graph: "miniCircle" };
  const indexList = await driver.showIndex(requestConfig);
  for (const index of indexList) {
    console.log(index);
  }
};

sdkUsage().catch(console.error);
```
