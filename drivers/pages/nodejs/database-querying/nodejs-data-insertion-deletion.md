# Data Insertion and Deletion

This section introduces methods on a `Connection` object for inserting nodes and edges to the graph or deleting nodes and edges from the graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Example Graph Data Model

The examples below demonstrate how to insert or delete nodes or edges from a graphset with the following schema and property definitions:

<div align=center drawio-diagram='16645' drawio-name="draw_eef958d9d27649c381cb1e470f4963cc.jpg"><img src="https://img.ultipa.cn/draw/draw_eef958d9d27649c381cb1e470f4963cc.jpg?v='1735107772346'"/></div>

## Property Type Mapping

When inserting nodes or edges, you may need to specify property values of different types. The mapping between Ultipa property types and Node.js/Driver data types is as follows:

| Ultipa Property Type | <div table-width="65">Node.js/Driver Type</div> |
| -- | -- |
| int32 | `number` |
| uint32 | `number` |
| int64 | `string` |
| uint64 | `string` |
| float | `string` |
| double | `string` |
| decimal | `string`|
| string | `string` |
| text | `string` |
| datetime | `string` |
| timestamp | `number` |
| point | `string` |
| blob | `Buffer` |
| list | `Array` |
| set | `Array` |

## Insertion

### insertNodes()

Inserts new nodes of a schema to the current graph.
 
**Parameters:**

- `string`: Name of the schema.
- `Node[]`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

-  `Response`: Result of the request. The `Response` object contains an alias `nodes` that holds all the inserted nodes when `InsertRequestConfig.slient` is set to false.

<p tit="TypeScript"></p> 
 
```ts
// Inserts two nodes into schema 'user' in graphset 'lcc', prints error code and information of the inserted nodes

let insertRequestConfig = <RequestType.InsertRequestConfig>{
  insertType: ULTIPA.InsertType.INSERT_TYPE_NORMAL,
  silent: false,
  graphSetName: "lcc",
  useMaster: true,
};

let resp = await conn.insertNodes(
  "user",
  [
    {
      _id: "U001",
      _uuid: 1,
      name: "Alice",
      age: 18,
      score: "65.32",
      birthday: "1993-5-4",
      location: `POINT(23.63 104)`,
      profile: "abc",
      interests: ["tennis", "violin"],
      permissionCodes: [2004, 3025, 1025],
    },
    { _id: "U002", _uuid: 2, name: "Bob" },
  ],
  insertRequestConfig
);
console.log(resp.status.code_desc);
console.log(resp.data);
```
<p tit="Output"></p> 
 
```java
SUCCESS
[
  Node { id: 'U001', uuid: '1', schema: 'user', values: {} },
  Node { id: 'U002', uuid: '2', schema: 'user', values: {} }
]
```

### insertEdges()

Inserts new edges of a schema to the current graph.
 
**Parameters:**

- `string`: Name of the schema.
- `Edge[]`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `edges` that holds all the inserted edges when `InsertRequestConfig.slient` is set to false.

<p tit="TypeScript"></p> 
 
```ts
// Inserts two edges into schema 'follows' in graphset 'lcc', prints error code and information of the inserted edges

let insertRequestConfig = <RequestType.InsertRequestConfig>{
  insertType: ULTIPA.InsertType.INSERT_TYPE_NORMAL,
  silent: true,
  graphSetName: "lcc",
  useMaster: true,
};

let resp = await conn.insertEdges(
  "follows",
  [
    {
      _uuid: 1,
      _from: "U001",
      _to: "U002",
      createdOn: "2024-5-6",
    },
    {
      _uuid: 2,
      _from: "U002",
      _to: "U001",
      createdOn: "2024-5-8",
    },
  ],
  insertRequestConfig
);
console.log(resp.status.code_desc);
console.log(resp.data);
```
<p tit="Output"></p> 
 
```java
SUCCESS
[
  Edge {
    from: 'U001',
    to: 'U002',
    uuid: '1',
    from_uuid: '1',
    to_uuid: '2',
    schema: 'follows',
    values: {}
  },
  Edge {
    from: 'U002',
    to: 'U001',
    uuid: '2',
    from_uuid: '2',
    to_uuid: '1',
    schema: 'follows',
    values: {}
  }
]
```

### insertNodesBatchBySchema()

Inserts new nodes of a schema into the current graph through gRPC. The properties within the node values must be consistent with those declared in the schema structure.

**Parameters:**

- `Schema`: The target schema.
- `Node[]`: The list of `Node` objects to be inserted.
- `InsertRequestConfig`: Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. `Response.InsertNodesReply` contains the insertion report when `InsertRequestConfig.slient` is set to false.

<p tit="TypeScript"></p> 
 
```ts
// Inserts two nodes into schema 'user' in graphset 'lcc' and prints error code 

let insertRequestConfig = <RequestType.InsertRequestConfig>{
  insertType: ULTIPA.InsertType.INSERT_TYPE_NORMAL,
  silent: false,
  graphSetName: "lcc",
  useMaster: true,
};

let proInfo: ULTIPA.Property[] = [];
let pro1: ULTIPA.Property = {
  name: "name",
  type: ULTIPA.PropertyType.string,
};
let pro2: ULTIPA.Property = {
  name: "age",
  type: ULTIPA.PropertyType.int32,
};
let pro3: ULTIPA.Property = {
  name: "score",
  type: ULTIPA.PropertyType.decimal,
};
let pro4: ULTIPA.Property = {
  name: "birthday",
  type: ULTIPA.PropertyType.datetime,
};
let pro5: ULTIPA.Property = {
  name: "location",
  type: ULTIPA.PropertyType.point,
};
let pro6: ULTIPA.Property = {
  name: "profile",
  type: ULTIPA.PropertyType.blob,
};
let pro7: ULTIPA.Property = {
  name: "interests",
  type: ULTIPA.PropertyType.list,
};
let pro8: ULTIPA.Property = {
  name: "permissionCodes",
  type: ULTIPA.PropertyType.set,
};

const pros = [pro1, pro2, pro3, pro4, pro5, pro6, pro7, pro8];
for (const item of pros) {
  proInfo.push(item);
}

let nodeInfo1 = new ULTIPA.Node();
nodeInfo1.id = "U001";
nodeInfo1.uuid = "1";
nodeInfo1.set("name", "Alice");
nodeInfo1.set("age", 18);
nodeInfo1.set("score", "65.32");
nodeInfo1.set("birthday", "1993-5-4");
nodeInfo1.set("location", `POINT(23.63 104)`);
nodeInfo1.set("profile", "abc");
nodeInfo1.set("interests", ["tennis", "violin"]);
nodeInfo1.set("permissionCodes", [2004, 3025, 1025]);
let node1: ULTIPA.Node[] = [];
node1.push(nodeInfo1);

let insert1 = await conn.insertNodesBatchBySchema(
  { dbType: ULTIPA.DBType.DBNODE, name: "user", properties: proInfo },
  node1,
  insertRequestConfig
);
console.log(insert1.status.code_desc);

let nodeInfo2 = new ULTIPA.Node();
nodeInfo2.id = "U002";
nodeInfo2.uuid = "2";
nodeInfo2.set("name", "Bob");
nodeInfo2.set("age", null);
nodeInfo2.set("score", null);
nodeInfo2.set("birthday", null);
nodeInfo2.set("location", null);
nodeInfo2.set("profile", null);
nodeInfo2.set("interests", null);
nodeInfo2.set("permissionCodes", null);
let node2: ULTIPA.Node[] = [];
node2.push(nodeInfo2);

let insert2 = await conn.insertNodesBatchBySchema(
  { dbType: ULTIPA.DBType.DBNODE, name: "user", properties: proInfo },
  node2,
  insertRequestConfig
);
console.log(insert2.status.code_desc);
```
<p tit="Output"></p> 
 
```java
SUCCESS
SUCCESS
```

### insertEdgesBatchBySchema()

Inserts new edges of a schema into the current graph through gRPC. The properties within the edge values must be consistent with those declared in the schema structure.

**Parameters:**

- `Schema`: The target schema.
- `Edge[]`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. `Response.InsertNodesReply` contains the insertion report when `InsertRequestConfig.slient` is set to false.

<p tit="TypeScript"></p> 
 
```ts
// Inserts two edges into schema 'follows' in graphset 'lcc' and prints error code

let insertRequestConfig = <RequestType.InsertRequestConfig>{
  insertType: ULTIPA.InsertType.INSERT_TYPE_NORMAL,
  silent: false,
  graphSetName: "lcc",
  useMaster: true,
};

let proInfo: ULTIPA.Property[] = [];
let pro: ULTIPA.Property = {
  name: "createdOn",
  type: ULTIPA.PropertyType.PROPERTY_TIMESTAMP,
};
proInfo.push(pro);

let edgeInfo1 = new ULTIPA.Edge();
edgeInfo1.uuid = "1";
edgeInfo1.from = "U001";
edgeInfo1.to = "U002";
edgeInfo1.set("createdOn", 1714953600);
let edge1: ULTIPA.Edge[] = [];
edge1.push(edgeInfo1);

let insert1 = await conn.insertEdgesBatchBySchema(
  { dbType: ULTIPA.DBType.DBEDGE, name: "follows", properties: proInfo },
  edge1,
  insertRequestConfig
);
console.log(insert1.status.code_desc);

let edgeInfo2 = new ULTIPA.Edge();
edgeInfo2.uuid = "2";
edgeInfo2.from = "U002";
edgeInfo2.to = "U001";
edgeInfo2.set("createdOn", 1715126400);
let edge2: ULTIPA.Edge[] = [];
edge2.push(edgeInfo2);

let insert2 = await conn.insertEdgesBatchBySchema(
  { dbType: ULTIPA.DBType.DBEDGE, name: "follows", properties: proInfo },
  edge2,
  insertRequestConfig
);
console.log(insert2.status.code_desc);
```
<p tit="Output"></p> 
 
```java
SUCCESS
SUCCESS
```

### insertNodesBatchAuto()

Inserts new nodes of one or multiple schemas to the current graph through gRPC. The properties within node values must be consistent with those defined in the corresponding schema structure.

**Parameters:**

- `Node[]`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. `Response.InsertNodesReply` contains the insertion report when `InsertRequestConfig.slient` is set to false.

<p tit="TypeScript"></p> 
 
```ts
// Inserts two nodes into schema 'user' and one node into schema `product` in graphset 'lcc' and prints error code

let insertRequestConfig = <RequestType.InsertRequestConfig>{
  insertType: ULTIPA.InsertType.INSERT_TYPE_NORMAL,
  silent: false,
  graphSetName: "lcc",
  useMaster: true,
};

let newNodes: ULTIPA.Node[] = [];
let nodeInfo1 = new ULTIPA.Node();
nodeInfo1.schema = "user";
nodeInfo1.id = "U001";
nodeInfo1.uuid = "1";
nodeInfo1.set("name", "Alice");
nodeInfo1.set("age", 18);
nodeInfo1.set("score", "65.32");
nodeInfo1.set("birthday", "1993-5-4");
nodeInfo1.set("location", `POINT(23.63 104)`);
nodeInfo1.set("profile", "abc");
nodeInfo1.set("interests", ["tennis", "violin"]);
nodeInfo1.set("permissionCodes", [2004, 3025, 1025]);

let nodeInfo2 = new ULTIPA.Node();
nodeInfo2.schema = "user";
nodeInfo2.id = "U002";
nodeInfo2.uuid = "2";
nodeInfo2.set("name", "Bob");
nodeInfo2.set("age", null);
nodeInfo2.set("score", null);
nodeInfo2.set("birthday", null);
nodeInfo2.set("location", null);
nodeInfo2.set("profile", null);
nodeInfo2.set("interests", null);
nodeInfo2.set("permissionCodes", null);

let nodeInfo3 = new ULTIPA.Node();
nodeInfo3.schema = "product";
nodeInfo3.id = "P001";
nodeInfo3.uuid = "3";
nodeInfo3.set("name", "Wireless Earbud");
nodeInfo3.set("price", 93.2);

newNodes.push(nodeInfo1, nodeInfo2, nodeInfo3);
let nodeInsert = await conn.insertNodesBatchAuto(
  newNodes,
  insertRequestConfig
);
console.log(nodeInsert.status.code_desc);
console.log("Node uuids: ", nodeInsert.data.uuids);
```
<p tit="Output"></p> 
 
```java
SUCCESS
Node uuids:  [ '1', '2', '3' ]
```

### insertEdgesBatchAuto()

Inserts new edges of one or multiple schemas to the current graph through gRPC. The properties within edge values must be consistent with those defined in the corresponding schema structure.

**Parameters:**

- `Edge[]`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. `Response.InsertEdgesReply` contains the insertion report when `InsertRequestConfig.slient` is set to false.

<p tit="TypeScript"></p> 
 
```ts
// Inserts two edges into schema 'follows' and one edge into schema 'purchased' in graphset 'lcc' and prints error code

let insertRequestConfig = <RequestType.InsertRequestConfig>{
  insertType: ULTIPA.InsertType.INSERT_TYPE_NORMAL,
  silent: false,
  graphSetName: "lcc",
  useMaster: true,
};

let newEdges: ULTIPA.Edge[] = [];
let edgeInfo1 = new ULTIPA.Edge();
edgeInfo1.schema = "follows";
edgeInfo1.uuid = "1";
edgeInfo1.from = "U001";
edgeInfo1.to = "U002";
edgeInfo1.set("createdOn", 1714953600);

let edgeInfo2 = new ULTIPA.Edge();
edgeInfo2.schema = "follows";
edgeInfo2.uuid = "2";
edgeInfo2.from = "U002";
edgeInfo2.to = "U001";
edgeInfo2.set("createdOn", 1715126400);

let edgeInfo3 = new ULTIPA.Edge();
edgeInfo3.schema = "purchased";
edgeInfo3.uuid = "3";
edgeInfo3.from = "U002";
edgeInfo3.to = "P001";
edgeInfo3.set("qty", 1);

newEdges.push(edgeInfo1, edgeInfo2, edgeInfo3);
let edgeInsert = await conn.insertEdgesBatchAuto(
  newEdges,
  insertRequestConfig
);
console.log(edgeInsert.status.code_desc);
console.log("Edge uuids: ", edgeInsert.data.uuids);
```
<p tit="Output"></p> 
 
```java
SUCCESS
Edge uuids:  [ '1', '2', '3' ]
```

## Deletion

### deleteNodes()

Deletes nodes that meet the given conditions from the current graph. It's important to note that deleting a node leads to the removal of all edges that are connected to it.

**Parameters:**

- `string`: The filtering condition to specify the nodes to delete.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `nodes` that holds all the deleted nodes when `InsertRequestConfig.slient` is set to false.

<p tit="TypeScript"></p> 
 
```ts
// Deletes one @user nodes whose name is 'Alice' from graphset 'lcc' and prints error code
// All edges attached to the deleted node are deleted as well

let insertRequestConfig = <RequestType.InsertRequestConfig>{
  insertType: ULTIPA.InsertType.INSERT_TYPE_NORMAL,
  silent: false,
  graphSetName: "lcc",
  useMaster: true,
};

let resp = await conn.deleteNodes(
  "{@user.name == 'Alice'}",
  insertRequestConfig
);
console.log(resp.status.code_desc);
```
<p tit="Output"></p> 
 
```java
SUCCESS
```

### deleteEdges()

Deletes edges that meet the given conditions from the current graph.

**Parameters:**

- `string`: The filtering condition to specify the edges to delete.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `edges` that holds all the deleted edges when `InsertRequestConfig.slient` is set to false.

<p tit="TypeScript"></p> 
 
```ts
// Deletes all @purchased edges from graphset 'lcc' and prints error code

let insertRequestConfig = <RequestType.InsertRequestConfig>{
  insertType: ULTIPA.InsertType.INSERT_TYPE_NORMAL,
  silent: false,
  graphSetName: "lcc",
  useMaster: true,
};

let resp = await conn.deleteEdges("{@purchased}", insertRequestConfig);
console.log(resp.status.code_desc);
```
<p tit="Output"></p> 
 
```java
SUCCESS
```

## Full Example

<p tit="TypeScript"></p> 

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

  // Insert Request configurations
  let insertRequestConfig = <RequestType.InsertRequestConfig>{
    insertType: ULTIPA.InsertType.INSERT_TYPE_NORMAL,
    silent: false,
    graphSetName: "lcc",
    useMaster: true,
  };

  // Inserts two nodes into schema 'user' and one node into schema `product` in graphset 'lcc', prints error code and the insert reply

  let newNodes: ULTIPA.Node[] = [];
  let nodeInfo1 = new ULTIPA.Node();
  nodeInfo1.schema = "user";
  nodeInfo1.id = "U001";
  nodeInfo1.uuid = "1";
  nodeInfo1.set("name", "Alice");
  nodeInfo1.set("age", 18);
  nodeInfo1.set("score", "65.32");
  nodeInfo1.set("birthday", "1993-5-4");
  nodeInfo1.set("location", `POINT(23.63 104)`);
  nodeInfo1.set("profile", "abc");
  nodeInfo1.set("interests", ["tennis", "violin"]);
  nodeInfo1.set("permissionCodes", [2004, 3025, 1025]);

  let nodeInfo2 = new ULTIPA.Node();
  nodeInfo2.schema = "user";
  nodeInfo2.id = "U002";
  nodeInfo2.uuid = "2";
  nodeInfo2.set("name", "Bob");
  nodeInfo2.set("age", null);
  nodeInfo2.set("score", null);
  nodeInfo2.set("birthday", null);
  nodeInfo2.set("location", null);
  nodeInfo2.set("profile", null);
  nodeInfo2.set("interests", null);
  nodeInfo2.set("permissionCodes", null);

  let nodeInfo3 = new ULTIPA.Node();
  nodeInfo3.schema = "product";
  nodeInfo3.id = "P001";
  nodeInfo3.uuid = "3";
  nodeInfo3.set("name", "Wireless Earbud");
  nodeInfo3.set("price", 93.2);

  newNodes.push(nodeInfo1, nodeInfo2, nodeInfo3);
  let nodeInsert = await conn.insertNodesBatchAuto(
    newNodes,
    insertRequestConfig
  );
  console.log(nodeInsert.status.code_desc);
  console.log("Node uuids: ", nodeInsert.data.uuids);
  
  // Inserts two edges into schema 'follows' and one edge into schema 'purchased' in graphset 'lcc', prints error code and the insert reply
  
  let newEdges: ULTIPA.Edge[] = [];
  let edgeInfo1 = new ULTIPA.Edge();
  edgeInfo1.schema = "follows";
  edgeInfo1.uuid = "1";
  edgeInfo1.from = "U001";
  edgeInfo1.to = "U002";
  edgeInfo1.set("createdOn", 1714953600);

  let edgeInfo2 = new ULTIPA.Edge();
  edgeInfo2.schema = "follows";
  edgeInfo2.uuid = "2";
  edgeInfo2.from = "U002";
  edgeInfo2.to = "U001";
  edgeInfo2.set("createdOn", 1715126400);

  let edgeInfo3 = new ULTIPA.Edge();
  edgeInfo3.schema = "purchased";
  edgeInfo3.uuid = "3";
  edgeInfo3.from = "U002";
  edgeInfo3.to = "P001";
  edgeInfo3.set("qty", 1);

  newEdges.push(edgeInfo1, edgeInfo2, edgeInfo3);
  let edgeInsert = await conn.insertEdgesBatchAuto(
    newEdges,
    insertRequestConfig
  );
  console.log(edgeInsert.status.code_desc);
  console.log("Edge uuids: ", edgeInsert.data.uuids);
};

sdkUsage().then(console.log).catch(console.log);  
```
