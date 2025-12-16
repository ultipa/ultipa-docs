# Query Acceleration

This section introduces methods on a `Connection` object for managing the LTE status for properties, and their indexes and full-text indexes. These mechanisms can be employed to <a href="https://www.ultipa.com/docs/uql/acceleration">accelerate queries</a>.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## LTE

### lte()

Loads one custom property of nodes or edges to the computing engine for query acceleration.

**Parameters:**

- `ULTIPA.DBType`: Type of the property (node or edge).
- `string`: Name of the schema, write `*` to specify all schemas.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 

```ts
// Loads the edge property @relatesTo.type to engine in graphset 'UltipaTeam' and prints error code

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp = await conn.lte(
  ULTIPA.DBType.DBEDGE,
  "relatesTo",
  "type",
  requestConfig
);
console.log(resp.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
```

### ufe()

Unloads one custom property of nodes or edges from the computing engine to save the memory.

**Parameters:**

- `ULTIPA.DBType`: Type of the property (node or edge).
- `string`: Name of the schema, write `*` to specify all schemas.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 

```ts
// Unloads the edge property @relatesTo.type from engine in graphset 'UltipaTeam' and prints error code

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp = await conn.ufe(
  ULTIPA.DBType.DBEDGE,
  "relatesTo",
  "type",
  requestConfig
);
console.log(resp.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
```

## Index

### showIndex()

Retrieves all indexes of node and edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Index[]`: The list of all indexes retrieved in the current graphset.

<p tit= "TypeScript" ></p> 

```ts
// Retrieves indexes in graphset 'Ad_Click' and prints their information

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "Ad_Click",
  useMaster: true,
};

let resp = await conn.showIndex(requestConfig);
console.log(resp.data);
```

<p tit= "Output" ></p> 
 
```java
{
  _nodeIndex: [
    {
      name: 'shopping_level',
      properties: 'shopping_level',
      schema: 'user',
      status: 'done',
      size: '4608315'
    },
    {
      name: 'price',
      properties: 'price',
      schema: 'ad',
      status: 'done',
      size: '7828488'
    }
  ],
  _edgeIndex: [
    {
      name: 'time',
      properties: 'time',
      schema: 'clicks',
      status: 'done',
      size: '12809771'
    }
  ]
}
```

### showNodeIndex()

Retrieves all indexes of node properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Index[]`: The list of all node indexes retrieved in the current graphset.

<p tit= "TypeScript" ></p> 

```ts
// Retrieves node indexes in graphset 'Ad_Click' and prints their information

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "Ad_Click",
  useMaster: true,
};

let resp = await conn.showNodeIndex(requestConfig);
console.log(resp.data);
```

<p tit= "Output" ></p> 
 
```java
[
  {
    name: 'shopping_level',
    properties: 'shopping_level',
    schema: 'user',
    status: 'done',
    size: '4608315'
  },
  {
    name: 'price',
    properties: 'price',
    schema: 'ad',
    status: 'done',
    size: '7828488'
  }
]
```

### showEdgeIndex()

Retrieves all indexes of edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Index[]`: The list of all edge indexes retrieved in the current graphset.

<p tit= "TypeScript" ></p> 

```ts
// Retrieves edge indexes in graphset 'Ad_Click' and prints their information

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "Ad_Click",
  useMaster: true,
};

let resp = await conn.showEdgeIndex(requestConfig);
console.log(resp.data);
```

<p tit= "Output" ></p> 
 
```java
[
  {
    name: 'time',
    properties: 'time',
    schema: 'clicks',
    status: 'done',
    size: '12809771'
  }
]
```

### createIndex()

Creates a new index in the current graphset.

**Parameters:**

- `ULTIPA.DBType`: Type of the property (node or edge).
- `string` (Optional): Name of the schema, write `*` to specify all schemas.
- `string` (Optional): Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 

```ts
// Creates indexes for all node properties 'name' in graphset 'Ad_Click' and prints the error code

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "Ad_Click",
  useMaster: true,
};

let resp = await conn.createIndex(
  ULTIPA.DBType.DBNODE,
  "*",
  "name",
  requestConfig
);
console.log(resp.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
```

### dropIndex()

Drops indexes in the current graphset.

**Parameters:**

- `ULTIPA.DBType`: Type of the property (node or edge).
- `string` (Optional): Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 

```ts
// Drops the index of the node property @ad.name in graphset 'Ad_Click' and prints the error code

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "Ad_Click",
  useMaster: true,
};

let resp = await conn.dropIndex(
  ULTIPA.DBType.DBNODE,
  "ad",
  "name",
  requestConfig
);
console.log(resp.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
```

## Full-text

### showFulltext()

Retrieves all full-text indexes of node and edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Index[]`: The list of all full-text indexes retrieved in the current graphset.

<p tit= "TypeScript" ></p> 

```ts
// Retrieves the first full-text index returned in graphset 'miniCircle' and prints its information

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "miniCircle",
  useMaster: true,
};

let resp = await conn.showFulltext(requestConfig);
let data = resp.data;
console.log(data["_nodeFulltext" || "_edgeFulltext"][0]);
```

<p tit= "Output" ></p> 
 
```java
{
  name: 'genreFull',
  properties: 'genre',
  schema: 'movie',
  status: 'done'
}
```

### showNodeFulltext()

Retrieves all full-text indexes of node properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Index[]`: The list of all full-text indexes of node properties retrieved in the current graphset.

<p tit= "TypeScript" ></p> 

```ts
// Retrieves the first node full-text index of node properties returned in graphset 'miniCircle' and prints its information

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "miniCircle",
  useMaster: true,
};

let resp = await conn.showNodeFulltext(requestConfig);
console.log(resp.data["_nodeFulltext"][0]);
```

<p tit= "Output" ></p> 
 
```java
{
  name: 'genreFull',
  properties: 'genre',
  schema: 'movie',
  status: 'done'
}
```

### showEdgeFulltext()

Retrieves all full-text indexes of edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Index[]`: The list of all edge full-text indexes of edge properties retrieved in the current graphset.

<p tit= "TypeScript" ></p> 

```ts
// Retrieves the first edge full-text index of edge properties returned in graphset 'miniCircle' and prints its information

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "miniCircle",
  useMaster: true,
};

let resp = await conn.showEdgeFulltext(requestConfig);
console.log(resp.data["_edgeFulltext"][0]);
```

<p tit= "Output" ></p> 
 
```java
{
  name: 'nameFull',
  properties: 'content',
  schema: 'review',
  status: 'done'
}
```

### createFulltext()

Creates a new full-text index in the current graphset.

**Parameters:**

- `ULTIPA.DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `string`: Name of the property.
- `string`: Name of the full-text index.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 

```ts
// Creates full-text index called 'movieName' for the property @movie.name in graphset 'miniCircle' and prints the error code

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "miniCircle",
  useMaster: true,
};

let resp = await conn.createFulltext(
  ULTIPA.DBType.DBNODE,
  "movie",
  "name",
  "movieName",
  requestConfig
);
console.log(resp.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
```

### dropFulltext()

Drops a full-text index in the current graphset.

**Parameters:**

- `string`: Name of the full-text index.
- `ULTIPA.DBType`: Type of the property (node or edge).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 

```ts
// Drops the node full-index 'movieName' in graphset 'miniCircle' and prints the error code

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "miniCircle",
  useMaster: true,
};

let resp = await conn.dropFulltext(
  "movieName",
  ULTIPA.DBType.DBNODE,
  requestConfig
);
console.log(resp.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
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
    graphSetName: "Ad_Click",
    useMaster: true,
  };

  // Retrieves all indexes in graphset 'Ad_Click' and prints their information

  let resp = await conn.showNodeIndex(requestConfig);
  console.log(resp.data);
};

sdkUsage().then(console.log).catch(console.log);
```




















