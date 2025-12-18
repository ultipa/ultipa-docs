# Graphset Management

This section introduces methods on a `Connection` object for managing graphsets in the database.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## showGraph()

Retrieves all graphsets from the database.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `GraphSet[]`: The list of all graphsets in the database.

```ts
// Retrieves all graphsets and prints the names of those who have over 2000 edges

let resp = await conn.showGraph();
let graphs = resp.data?.filter((graph) => {
  return Number(graph.totalEdges) > 2000;
});
console.log(graphs);
```
<p tit="Output"></p> 
 
```
Display_Ad_Click
ERP_DATA2
wikiKG
```

## getGraph()

Retrieves one graphset from the database by its name.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `GraphSet`: The retrieved graphset.

```ts
// Retrieves the graphsets named 'wikiKG' and prints all its information

let resp = await conn.getGraph("wikiKG");
console.log(resp.data);
```

<p tit="Output"></p> 
 
```
{"id":615,"name":"wikiKG","totalNodes":3546,"totalEdges":2179,"status":"MOUNTED","description":""}
```

## createGraph()

Creates a new graphset in the database.

**Parameters:**

- `GraphSet`: The graphset to be created; the field `name` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Creates one graphset and prints the error code

let resp = await conn.createGraph({
  name: "testNodeJS_SDK",
  description: "A test graph for NodeJS_SDK",
});
console.log(resp.status.code_desc);
```

A new graphset `testNodeJS_SDK` is created in the database, and the driver prints:

<p tit="Output"></p> 
 
```
SUCCESS
```

## createGraphIfNotExist()

Creates a new graphset in the database, handling cases where the given graphset name already exists by ignoring the error.

**Parameters:**

- `GraphSet`: The graphset to be created; the field `name` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Creates one graphset and prints the error code

let graph1 = await conn.createGraphIfNotExit({
  name: "testNodeJS_SDK",
  description: "A test graph for NodeJS_SDK",
});
console.log("First Creation: ", graph1.status.code_desc);

// Attempts to create the same graphset again and prints the error code
let graph2 = await conn.createGraphIfNotExit({
  name: "testNodeJS_SDK",
  description: "A test graph for NodeJS_SDK",
});
console.log("Second Creation: ", graph2.status.code_desc);
```

A new graphset `testNodeJS_SDK` is created in the database, and the driver prints:

<p tit="Output"></p> 
 
```
First Creation: SUCCESS
Second Creation: SUCCESS
```

## dropGraph()

Drops one graphset from the database by its name.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Creates one graphset and then drops it, prints the result

let resp = await conn.createGraph({
  name: "testNodeJS_SDK",
  description: "A test graph for NodeJS_SDK",
});
console.log(resp.status.code_desc);

let resp2 = await conn.dropGraph("testNodeJS_SDK");
console.log(resp2);
```
<p tit="Output"></p> 

```
SUCCESS
{
  status: { code: 0, message: '' , code_desc: 'SUCCESS' },
  statistics: { totalCost: 16, engineCost: 0, nodeAffected: 0, edgeAffected: 0 },
  req: undefined
}
```

## alterGraph()

Alters the name and description of one existing graphset in the database by its name.

**Parameters:**

- `oldGraph: GraphSet`: The existing graphset to be altered; the field `name` must be set.
- `newGraph: GraphSet`: The new configuration for the existing graphset; either or both of the fields `name` and `description` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Renames the graphset 'testNodeJS_SDK' to 'newGraph', sets a description for it, and prints the result

let resp = await conn.alterGraph(
  { name: "testNodeJS_SDK" },
  { name: "newGraph", description: "The graphset is altered" }
);
console.log(resp);
```

<p tit="Output"></p> 

```
{
  status: { code: 0, message: '', code_desc: 'SUCCESS' },
  statistics: { totalCost: 1, engineCost: 0, nodeAffected: 0, edgeAffected: 0 },
  req: undefined
}
```

## truncate()

Truncates (Deletes) the specified nodes or edges in the given graphset or truncates the entire graphset. Note that truncating nodes will cause the deletion of edges attached to those affected nodes. The truncating operation retains the definition of schemas and properties while deleting the data.

**Parameters:**

- `Truncate`: The object to truncate; the field `graphName` must be set, `schema` and `dbType` are optional, but `schema` cannot be set without the setting of `dbType`.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Truncates @user nodes in the graphset 'myGraph_1' and prints the error code

let trunc1 = await conn.truncate({
  graphName: "myGraph_1",
  schema: "user",
  dbType: ULTIPA.DBType.DBNODE,
});
console.log(trunc1.status.code_desc);

// Truncates all edges in the graphset 'myGraph_2' and prints the error code    

let trunc2 = await conn.truncate({
  graphName: "myGraph_2",
  dbType: ULTIPA.DBType.DBEDGE,
});
console.log(trunc2.status.code_desc);

// Truncates the graphset 'myGraph_3' and prints the error code

let trunc3 = await conn.truncate({
  graphName: "myGraph_3",
});
console.log(trunc3.status.code_desc);
```

<p tit="Output"></p> 

```
SUCCESS
SUCCESS
SUCCESS
```

## compact()

Compacts a graphset by clearing its invalid and redundant data on the server disk. Valid data will not be affected.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Compacts the graphset 'miniCircle' and prints the error code

let trunc1 = await conn.compact("miniCircle");
console.log(trunc1.status.code_desc);
```

<p tit="Output"></p> 

```
SUCCESS
```

## hasGraph()

Checks the existence of a graphset in the database by its name.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Boolean`: Result of the request.

```ts
// Checks the existence of graphset 'miniCircle' and prints the result

let has = await conn.hasGraph("miniCircle");
console.log("has = ", has.data);
```

<p tit="Output"></p> 

```
has = true
```

## unmountGraph()

Unmounts a graphset to save database memory.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// / Unmounts the graphsets 'miniCircle' and prints the result

let resp = await conn.unmountGraph("miniCircle");
console.log(resp.status.code_desc);
```

<p tit="Output"></p> 

```
SUCCESS
```

## mountGraph()

Mounts a graphset to the database memory.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Mounts the graphsets 'miniCircle' and prints the result

let resp = await conn.mountGraph("miniCircle");
console.log(resp.status.code_desc);
```

<p tit="Output"></p> 

```
SUCCESS
```

## Full Example

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
    useMaster: true,
  };

  // Creates new graphset 'newGraph'
  let graph = await conn.createGraph({ name: "newGraph" }, requestConfig);
  console.log(graph.status.code_desc);

  // Drops the graphset 'newGraph' just created

  let resp = await conn.dropGraph("newGraph");
  console.log(resp.status.code_desc);
};

sdkUsage().then(console.log).catch(console.log);
```
