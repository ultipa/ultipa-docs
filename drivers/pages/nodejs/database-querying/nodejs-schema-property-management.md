# Schema and Property Management

This section introduces methods on a `Connection` object for managing schemas and properties of nodes and edges in a graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Schema

### showSchema()

Retrieves all nodes and edge schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema[]`: The list of all schemas in the current graphset.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves all schemas in graphset 'UltipaTeam' and prints their names and types

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp = await conn.showSchema(requestConfig);
const dataList = resp.data?.map((item) => ({
  Name: item.name,
  dbType: Number(item.totalNodes) >= 0 ? "DBNODE" : "DBEDGE",
}));
console.log(dataList);
```
<p tit= "Output" ></p> 
 
```java
[
  { Name: 'default', dbType: 'DBNODE' },
  { Name: 'member', dbType: 'DBNODE' },
  { Name: 'organization', dbType: 'DBNODE' },
  { Name: 'default', dbType: 'DBEDGE' },
  { Name: 'reportsTo', dbType: 'DBEDGE' },
  { Name: 'relatesTo', dbType: 'DBEDGE' }
]
```

### getSchema()

Retrieves a node or edge schema from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `ULTIPA.DBType`: Type of the schema (node or edge).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved schema.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves node schema 'member' and edge schema 'connectsTo' in graphset 'UltipaTeam', and prints all their information

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let nodeInfo = await conn.getSchema(
  "member",
  ULTIPA.DBType.DBNODE,
  requestConfig
);
console.log("NodeSchema: ", nodeInfo.data);

let edgeInfo = await conn.getSchema(
  "connectsTo",
  ULTIPA.DBType.DBEDGE,
  requestConfig
);

console.log("EdgeSchema: ", edgeInfo.data);
```

<p tit= "Output" ></p> 
 
```java
{
 NodeSchema:  {
  name: 'member',
  description: '',
  properties: [
    {
      name: 'name',
      type: 'string',
      description: '',
      lte: 'false',
      extra: '{}'
    },
    {
      name: 'title',
      type: 'string',
      description: '',
      lte: 'false',
      extra: '{}'
    },
    {
      name: 'profile',
      type: 'string',
      description: '',
      lte: 'false',
      extra: '{}'
    },
    {
      name: 'age',
      type: 'int32',
      description: '',
      lte: 'false',
      extra: '{}'
    }
  ],
  totalNodes: '7'
}
EdgeSchema:  {}
```

### showNodeSchema()

Retrieves all node schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema[]`: The list of all node schemas in the current graphset.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves all node schemas in graphset 'UltipaTeam' and prints their names

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let dataOri = await conn.showNodeSchema(requestConfig);
const schemaInfo = dataOri.data?.map((item) => item.name);
console.log("SchemaName: ", schemaInfo);
```

<p tit= "Output" ></p> 
 
```java
SchemaName:  [ 'default', 'member', 'organization' ]
```

### showEdgeSchema()

Retrieves all edge schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema[]`: The list of all edge schemas in the current graphset.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves all edge schemas in graphset 'UltipaTeam' and prints their names

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let dataOri = await conn.showNodeSchema(requestConfig);
const schemaInfo = dataOri.data?.map((item) => item.name);
console.log("SchemaName: ", schemaInfo);
```

<p tit= "Output" ></p> 
 
```java
SchemaName:  [ 'default', 'reportsTo', 'relatesTo']
```

### getNodeSchema()

Retrieves a node schema from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved node schema.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves node schema 'member' in graphset 'UltipaTeam' and prints its properties

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp = await conn.getNodeSchema("member", requestConfig);
console.log("Property: ", resp.data?.properties);
```

<p tit= "Output" ></p> 
 
```java
Property:  [
  {
    name: 'name',
    type: 'string',
    description: '',
    lte: 'false',
    extra: '{}'
  },
  {
    name: 'title',
    type: 'string',
    description: '',
    lte: 'false',
    extra: '{}'
  },
  {
    name: 'profile',
    type: 'string',
    description: '',
    lte: 'false',
    extra: '{}'
  },
  {
    name: 'age',
    type: 'int32',
    description: '',
    lte: 'false',
    extra: '{}'
  }
]
```

### getEdgeSchema()

Retrieves an edge schema from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved edge schema.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves edge schema 'relatesTo' in graphset 'UltipaTeam' and prints its properties

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp = await conn.getEdgeSchema("relatesTo", requestConfig);
console.log("Property: ", resp.data?.properties);
```

<p tit= "Output" ></p> 
 
```java
Property:  [
  {
    name: 'type',
    type: 'string',
    description: '',
    lte: 'false',
    extra: '{}'
  }
]
```

### createSchema()

Creates a new schema in the current graphset.

**Parameters:**

- `Schema`: The schema to be created; the fields `name` and `dbType` must be set, `desc` (short for description) and `properties` are optional.
- `boolean`: Whether to create properties, the default is `false`.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

// Creates node schema 'utility' (with properties) in graphset 'UltipaTeam' and prints all its information

const property1: ULTIPA.Header = {
  name: "name",
  type: ULTIPA.PropertyType.string,
};
const property2: ULTIPA.Header = {
  name: "purchaseDate",
  type: ULTIPA.PropertyType.datetime,
};

let nodePro = await conn.createSchema(
  {
    dbType: ULTIPA.DBType.DBNODE,
    name: "utility",
    properties: [property1, property2],
    desc: "Office utilities",
  },
  true,
  requestConfig
);
console.log("Node Schema Creation: ", nodePro.status.code_desc);
console.log((await conn.getNodeSchema("utility", requestConfig)).data);

// Creates edge schema 'managedBy' (without properties) in graphset 'UltipaTeam' and prints all its information

let edgePro = await conn.createSchema(
  {
    dbType: ULTIPA.DBType.DBEDGE,
    name: "managedBy",
  },
  false,
  requestConfig
);
console.log("Edge Schema Creation: ", edgePro.status.code_desc);
console.log((await conn.getEdgeSchema("managedBy", requestConfig)).data);
```

<p tit= "Output" ></p> 
 
```java
Node Schema Creation:  SUCCESS
{
  name: 'utility',
  description: 'Office utilities',
  properties: [
    {
      name: 'name',
      type: 'string',
      description: '',
      lte: 'false',
      extra: '{}'
    },
    {
      name: 'purchaseDate',
      type: 'datetime',
      description: '',
      lte: 'false',
      extra: '{}'
    }
  ],
  totalNodes: '0'
}
Edge Schema Creation:  SUCCESS
{ name: 'managedBy', description: '', properties: [], totalEdges: '0' }
```

### createSchemaIfNotExist()

Creates a new schema in the current graphset, handling cases where the given schema name already exists by ignoring the error.

**Parameters:**

- `Schema`: The schema to be created; the fields `name` and `dbType` must be set, `description` and `properties` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Boolean`: Whether the creation happens.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

// Creates one schema in graphset 'UltipaTeam' and prints if repeated creation is ignored

let creation1 = await conn.createSchemaIfNotExist(
  {
    dbType: ULTIPA.DBType.DBNODE,
    name: "utility",
    desc: "Office utilities",
  },
  requestConfig
);
console.log("Ignore repeated creation: ", creation1.data);

// Creates the same schema again and prints if repeated creation is ignored

let creation2 = await conn.createSchemaIfNotExist(
  {
    dbType: ULTIPA.DBType.DBNODE,
    name: "utility",
    desc: "Office utilities",
  },
  requestConfig
);
console.log("Ignore repeated creation: ", creation2.data);
```

<p tit= "Output" ></p> 
 
```java
Ignore repeated creation:  false
Ignore repeated creation:  true
```

### alterSchema()

Alters the name and description of one existing schema in the current graphset by its name.

**Parameters:**

- `Schema`: The existing schema to be altered; the fields `name` and `dbType` must be set. 
- `Schema`: The new configuration for the existing schema; either or both of the fields `name` and `desc` (short for description) must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
// Renames the node schema 'utility' to 'securityUtility' and removes its description in graphset 'UltipaTeam'

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp = await conn.alterSchema(
  {
    dbType: ULTIPA.DBType.DBNODE,
    name: "utility",
    desc: "Office utilities",
  },
  {
    dbType: ULTIPA.DBType.DBNODE,
    name: "securityUtility",
    desc: "",
  },
  requestConfig
);
console.log(resp.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
```

### dropSchema()

Drops one schema from the current graphset by its name.

**Parameters:**

- `Schema`: The existing schema to be dropped; the fields `name` and `dbType` must be set. 
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
// Drops the node schema 'utility' in graphset 'UltipaTeam'

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp = await conn.dropSchema(
  {
    dbType: ULTIPA.DBType.DBNODE,
    name: "utility",
  },
  requestConfig
);
console.log(resp);
```

<p tit= "Output" ></p> 
 
```java
{
  status: { code: 0, message: '', code_desc: 'SUCCESS' },
  statistics: { totalCost: 1, engineCost: 0, nodeAffected: 0, edgeAffected: 0 },
  req: undefined
}
```

## Property

### showProperty()

Retrieves custom properties of nodes or edges from the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property[]`: The list of all properties retrieved in the current graphset.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves all node properties in graphset 'UltipaTeam' and prints their names and associated schemas

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

const nameList = (await conn.showNodeSchema(requestConfig)).data?.map(
  (item) => item.name
)!;

for (let i = 0; i < nameList.length; i++) {
  let resp = await conn.showProperty(
    ULTIPA.DBType.DBNODE,
    nameList[i],
    requestConfig
  );
  console.log(
    "Schema",
    nameList[i],
    "contains properties",
    resp.data?.map((item) => item.name)
  );
}
```

<p tit= "Output" ></p> 
 
```java
Schema default contains properties []
Schema member contains properties [ 'name', 'title', 'profile' ]
Schema organization contains properties [ 'name', 'logo' ]
```

### showNodeProperty()

Retrieves custom properties of nodes from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property[]`: The list of all properties retrieved in the current graphset.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves all custom properties of node schema 'member' in graphset 'UltipaTeam' and prints the count

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let NodePro = await conn.showNodeProperty("member", requestConfig);
console.log(NodePro.data?.length);
```

<p tit= "Output" ></p> 
 
```java
3
```

### showEdgeProperty()

Retrieves custom properties of edges from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property[]`: The list of all properties retrieved in the current graphset.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves all custom properties of edge schema 'relatesTo' in graphset 'UltipaTeam' and prints their names

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let edgePro = await conn.showEdgeProperty("relatesTo", requestConfig);
console.log(edgePro.data?.map((item) => item.name));
```

<p tit= "Output" ></p> 
 
```java
[ 'type' ]
```

### getProperty()

Retrieves a custom property of nodes or edges from the current graphset.

**Parameters:**

- `ULTIPA.DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves node property @member.title in graphset 'UltipaTeam' and prints all its information

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp = await conn.getProperty(
  ULTIPA.DBType.DBNODE,
  "member",
  "title",
  requestConfig
);
console.log(resp.data);
```

<p tit= "Output" ></p> 
 
```java
{
  name: 'title',
  type: 'string',
  lte: 'false',
  read: '1',
  write: '1',
  schema: 'member',
  description: '',
  extra: '{}',
  encrypt: ''
}
```

### getNodeProperty()

Retrieves a custom property of nodes from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves node property @member.title in graphset 'UltipaTeam' and prints all its information

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp = await conn.getNodeProperty(
  "member",
  "title",
  requestConfig
);
console.log(resp.data);
```

<p tit= "Output" ></p> 
 
```java
{
  name: 'title',
  type: 'string',
  lte: 'false',
  read: '1',
  write: '1',
  schema: 'member',
  description: '',
  extra: '{}',
  encrypt: ''
}
```

### getEdgeProperty()

Retrieves a custom property of edges from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

<p tit= "TypeScript" ></p> 
 
```ts
// Retrieves edge property @relatesTo.type in graphset 'UltipaTeam' and prints all its information

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp = await conn.getEdgeProperty("relatesTo", "type", requestConfig);
console.log(resp.data);
```

<p tit= "Output" ></p> 
 
```java
{
  name: 'type',
  type: 'string',
  lte: 'false',
  read: '1',
  write: '1',
  schema: 'relatesTo',
  description: '',
  extra: '{}',
  encrypt: ''
}
```

### createProperty()

Creates a new property for a node or edge schema in the current graphset.

**Parameters:**

- `ULTIPA.DBType`: Type of the property (node or edge).
- `string`: Name of the schema, write `*` to specify all schemas.
- `Property`: The property to be created; the fields `name` and `type` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
// Creates two properties for node schema 'member' in graphset 'UltipaTeam' and prints error codes

let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

let resp1 = await conn.createProperty(
  ULTIPA.DBType.DBNODE,
  "member",
  { name: "startDate", schema: "member", type: ULTIPA.PropertyType.datetime },
  requestConfig
);
console.log(resp1.status.code_desc);

let resp2 = await conn.createProperty(
  ULTIPA.DBType.DBNODE,
  "member",
  { name: "age", schema: "member", type: ULTIPA.PropertyType.int32 },
  requestConfig
);
console.log(resp2.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
SUCCESS
```

### createPropertyIfNotExist()

Creates a new property for a node or edge schema in the current graphset, handling cases where the given property name already exists by ignoring the error.

**Parameters:**

- `ULTIPA.DBType`: Type of the property (node or edge).
- `string`: Name of the schema, write `*` to specify all schemas.
- `Property`: The property to be created; the fields `name` and `type` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Boolean`: Whether the creation happens.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

// Creates a property for node schema 'member' in graphset 'UltipaTeam' and prints if repeated creation is ignored

let resp1 = await conn.createPropertyIfNotExist(
  ULTIPA.DBType.DBNODE,
  "member",
  { name: "startDate", schema: "member", type: ULTIPA.PropertyType.datetime },
  requestConfig
);
console.log("Ignore repeated creation: ", resp1.data);

// Creates the same property again in graphset 'UltipaTeam' and prints if repeated creation is ignored

let resp2 = await conn.createPropertyIfNotExist(
  ULTIPA.DBType.DBNODE,
  "member",
  { name: "startDate", schema: "member", type: ULTIPA.PropertyType.datetime },
  requestConfig
);
console.log("Ignore repeated creation: ", resp2.data);
```

<p tit= "Output" ></p> 
 
```java
Ignore repeated creation:  false
Ignore repeated creation:  true
```


### alterProperty()

Alters the name and description of one existing custom property in the current graphset by its name.

**Parameters:**

- `ULTIPA.DBType`: Type of the property (node or edge).
- `Property`: The existing property to be altered; the fields `name` and `schema` (write `*` to specify all schemas) must be set. 
- `Property`: The new configuration for the existing property; either or both of the fields `name` and `description` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

// Rename properties 'name' associated with all node schemas to `Name` in graphset 'UltipaTeam'

let resp = await conn.alterProperty(
  ULTIPA.DBType.DBNODE,
  { name: "name", schema: "*" },
  { name: "Name", schema: "*" },
  requestConfig
);
console.log(resp.status.code_desc);
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
```

### dropProperty()

Drops one custom property from the current graphset by its name and the associated schema.

**Parameters:**

- `ULTIPA.DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  graphSetName: "UltipaTeam",
  useMaster: true,
};

// Drops properties 'startDate' associated with all node schemas in graphset 'UltipaTeam' and prints error code

let resp1 = await conn.dropProperty(
  ULTIPA.DBType.DBNODE,
  "*",
  "startDate",
  requestConfig
);
console.log(resp1.status.code_desc);

// Drops node property @member.name in graphset 'UltipaTeam' and prints error code

let resp2 = await conn.dropProperty(
  ULTIPA.DBType.DBNODE,
  "member",
  "name",
  requestConfig
);
console.log(resp1.status.code_desc);
```


<p tit= "Output" ></p> 
 
```java
SUCCESS
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
    graphSetName: "UltipaTeam",
    useMaster: true,
  };

  // Creates node schema 'utility' (with properties) in graphset 'UltipaTeam' and prints error code
  
    const property1: ULTIPA.Header = {
      name: "name",
      type: ULTIPA.PropertyType.string,
    };
    const property2: ULTIPA.Header = {
      name: "purchaseDate",
      type: ULTIPA.PropertyType.datetime,
    };

    let nodePro = await conn.createSchema(
      {
        dbType: ULTIPA.DBType.DBNODE,
        name: "utility",
        properties: [property1, property2],
        desc: "Office utilities",
      },
      true,
      requestConfig
    );
    console.log("Node Schema Creation: ", nodePro.status.code_desc);
    console.log((await conn.getNodeSchema("utility", requestConfig)).data);
};

sdkUsage().then(console.log).catch(console.log);
```
