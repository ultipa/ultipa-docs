## Schema and Property

This section introduces methods for managing schemas and properties in a graph.

## Schema

### showSchema()

Retrieves all schemas from the graph.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Schema[]`: The list of retrieved schemas.

 ```ts
// Retrieves all schemas in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const schemas = await driver.showSchema(requestConfig);
schemas.forEach((schema: any) => {
  const typeName = DBType[schema.dbType];
  console.log(`${schema.name}, ${typeName}`);
});
```

<p tit="Output"></p> 
 
```
default, DBNODE  
account, DBNODE  
celebrity, DBNODE
country, DBNODE
movie, DBNODE
default, DBEDGE
direct, DBEDGE
disagree, DBEDGE
filmedIn, DBEDGE
follow, DBEDGE
rate, DBEDGE
wishlist, DBEDGE
response, DBEDGE
agree, DBEDGE
review, DBEDGE
```

### showNodeSchema()

Retrieves all node schemas from the graph.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Schema[]`: The list of retrieved schemas.

 ```ts
// Retrieves all node schemas in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const schemas = await driver.showNodeSchema(requestConfig);
schemas.forEach((schema: any) => {
  const typeName = DBType[schema.dbType];
  console.log(`${schema.name}, ${typeName}`);
});
```

<p tit="Output"></p> 
 
```
default, DBNODE
account, DBNODE
celebrity, DBNODE
country, DBNODE
movie, DBNODE
```

### showEdgeSchema()

Retrieves all edge schemas from the graph.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Schema[]`: The list of retrieved schemas.

 ```ts
// Retrieves all edge schemas in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const schemas = await driver.showEdgeSchema(requestConfig);
schemas.forEach((schema: any) => {
  const typeName = DBType[schema.dbType];
  console.log(`${schema.name}, ${typeName}`);
});
```

<p tit="Output"></p> 
 
```
default, DBEDGE
direct, DBEDGE
disagree, DBEDGE
filmedIn, DBEDGE
follow, DBEDGE
rate, DBEDGE
wishlist, DBEDGE
response, DBEDGE
agree, DBEDGE
review, DBEDGE
```

### getSchema()

Retrieves a specified schema from the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `dbType: DBType`: Type of the schema (node or edge).
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Schema`: The retrieved schema.

 ```ts
// Retrieves the node schema named 'account'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const schema = await driver.getSchema("account", DBType.DBNODE, requestConfig);
console.log(schema);
```

<p tit="Output"></p> 
 
```
Schema {
  name: 'account',
  description: '',
  properties: [
    Property {
      name: 'gender',
      type: 7,
      subType: undefined,
      lte: false,
      read: true,
      write: true,
      schema: 'account',
      description: '',
      encrypt: '',
      decimalExtra: undefined
    },
    Property {
      name: 'year',
      type: 1,
      subType: undefined,
      lte: false,
      read: true,
      write: true,
      schema: 'account',
      description: '',
      encrypt: '',
      decimalExtra: undefined
    },
    Property {
      name: 'industry',
      type: 7,
      subType: undefined,
      lte: false,
      read: true,
      write: true,
      schema: 'account',
      description: '',
      encrypt: '',
      decimalExtra: undefined
    },
    Property {
      name: 'name',
      type: 7,
      subType: undefined,
      lte: false,
      read: true,
      write: true,
      schema: 'account',
      description: '',
      encrypt: '',
      decimalExtra: undefined
    }
  ],
  dbType: 0,
  total: '37',
  id: '2',
  stats: [
    SchemaStat {
      dbType: 0,
      schema: 'account',
      fromSchema: undefined,
      toSchema: undefined,
      count: '37'
    }
  ]
}
```

### getNodeSchema()

Retrieves a specified node schema from the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Schema`: The retrieved schema.

 ```ts
// Retrieves the node schema named 'account'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const schema = await driver.getNodeSchema("account", requestConfig);
if (schema) {
  schema.properties?.forEach((property: any) => {
    console.log(property.name);
  });
} else {
  console.log("Not found");
};
```

<p tit="Output"></p> 
 
```
gender
year
industry
name
```

### getEdgeSchema()

Retrieves a specified edge schema from the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Schema`: The retrieved schema.

 ```ts
// Retrieves the edge schema named 'disagree'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const schema = await driver.getEdgeSchema("disagree", requestConfig);
if (schema) {
  schema.properties?.forEach((property: any) => {
    console.log(property.name);
  });
} else {
  console.log("Not found");
};
```

<p tit="Output"></p> 
 
```
datetime
timestamp
targetPost
```

### createSchema()

Creates a schema in the graph.

**Parameters**

- `schema: Schema`: The schema to be created; the fields `name` and `dbType` are mandatory, `properties` and `description` are optional.
- `isCreateProperties?: boolean`: Whether to create properties associated with the schema, the default is `false`.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
const requestConfig: RequestConfig = { graph: "miniCircle" };

// Creates node schema 'utility' (with properties)
const utility: Schema = {
  name: "utility",
  dbType: DBType.DBNODE,
  properties: [
    { name: "name", type: ULTIPA.UltipaPropertyType.STRING, schema: "utility" },
    { name: "type", type: ULTIPA.UltipaPropertyType.UINT32, schema: "utility" }
  ]
};
const response1 = await driver.createSchema(utility, true, requestConfig);
console.log(response1.status?.message);

// Creates edge schema 'vote' (without properties)
const vote: Schema = { name: "vote", dbType: DBType.DBEDGE };
const response2 = await driver.createSchema(vote, false, requestConfig);
console.log(response2.status?.message);
```

<p tit="Output"></p> 

```ts
SUCCESS
SUCCESS
```

### createSchemaIfNotExist()

Creates a schema in the graph and returns whether a node or edge schema with the same name already exists.

**Parameters**

- `schema: Schema`: The schema to be created; the fields `name` and `dbType` are mandatory, `properties` and `description` are optional.
- `isCreateProperties?: boolean`: Whether to create properties associated with the schema, the default is `false`.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `ResponseWithExistCheck`: Result of the request.

 ```ts
// Creates a schema with existence check
const requestConfig: RequestConfig = { graph: "miniCircle" };
const utility: Schema = {
  name: "utility",
  dbType: DBType.DBNODE,
  properties: [
    { name: "name", type: ULTIPA.UltipaPropertyType.STRING, schema: "utility" },
    { name: "type", type: ULTIPA.UltipaPropertyType.UINT32, schema: "utility" }
  ]
};
const result = await driver.createSchemaIfNotExist(utility, true, requestConfig);
console.log("Schema already exists:", result.exist);
if (result.response.status?.code !== 0) {
  console.log("Error message:", result.response.status?.message);
} else {
  if (result.response.statistics?.totalCost === 0) {
    console.log("New schema created: No");
  } else {
    console.log("New schema created: Yes");
  }
};
```

<p tit="Output"></p> 
 
```
Schema already exists: true
New schema created: No
```

### alterSchema()

Alters the name and description a schema in the graph.

**Parameters**

- `originalSchema: Schema`: The schema to be altered; the fields `name` and `dbType` are mandatory. 
- `newSchema: Schema`: A `Schema` object used to set new `name` and/or `description` for the schema.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Renames the node schema 'utility' to 'securityUtility' in the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const oldSchema: Schema = { name: "utility", dbType: DBType.DBNODE };
const newSchema = new ULTIPA.Schema();
newSchema.name = "securityUtility";
const response = await driver.alterSchema(oldSchema, newSchema, requestConfig);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropSchema()

Deletes a specified schema from the graph.

**Parameters**

- `schema: Schema`: The schema to be dropped; the fields `name` and `dbType` are mandatory. 
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Drops the edge schema 'vote' from the graph 'miniCircle'
const requestConfig: RequestConfig = { graph: "miniCircle" };
const schema: Schema = { name: "vote", dbType: DBType.DBEDGE };
const response = await driver.dropSchema(schema, requestConfig);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Property

### showProperty()

Retrieves properties from the graph.

**Parameters**

- `dbType?: DBType`: Type of the property (node or edge).
- `schemaName?: string`: Name of the schema.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `AllProperties`: An object that contains two lists: `nodeProperties` and `edgeProperties`, both of which are lists of `Property` objects.

 ```ts
// Retrieves all properties in the graph 'citation'
const requestConfig: RequestConfig = { graph: "citation" };
const properties = await driver.showProperty(undefined, undefined, requestConfig);
console.log("Node properties:")
properties.nodeProperties.forEach((item) => {
  console.log(`${item.name} is associated with schema ${item.schema}`)
});
console.log("Edge properties:")
properties.edgeProperties.forEach((item) => {
  console.log(`${item.name} is associated with schema ${item.schema}`)
});
```

<p tit="Output"></p> 
 
```
Node Properties:
_id is associated with schema default
_id is associated with schema Paper
title is associated with schema Paper
score is associated with schema Paper
author is associated with schema Paper
Edge Properties:
weight is associated with schema Cites
```

### showNodeProperty()

Retrieves node properties from the graph.

**Parameters**

- `schemaName?: string`: Name of the schema.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Property[]`: The list of retrieved properties.

 ```ts
// Retrieves properties associated with the node schema 'Paper' in the graph 'citation'
const requestConfig: RequestConfig = { graph: "citation" };
const properties = await driver.showNodeProperty("Paper", requestConfig);
for (const property of properties) {
  const typeName = UltipaPropertyType[property.type];
  console.log(`${property.name} - ${typeName}`);
};
```

<p tit="Output"></p> 
 
```
_id - STRING
author - STRING
title - STRING
score - UINT32
```

### showEdgeProperty()

Retrieves edge properties from the graph.

**Parameters**

- `schemaName?: string`: Name of the schema.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Property[]`: The list of retrieved properties.

 ```ts
// Retrieves properties associated with the edge schema 'Cites' in the graph 'citation'
const requestConfig: RequestConfig = { graph: "citation" };
const properties = await driver.showEdgeProperty("Cites", requestConfig);
for (const property of properties) {
  const typeName = UltipaPropertyType[property.type];
  console.log(`${property.name} - ${typeName}`);
};
```

<p tit="Output"></p> 
 
```
weight - INT32
```

### getProperty()

Retrieves a specified property from the graph.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Property`: The retrieved property.

 ```ts
// Retrieves node property 'title' associated with the node schema 'Paper' in the graph 'citation'
const requestConfig: RequestConfig = { graph: "citation" };
const property = await driver.getProperty(DBType.DBNODE, "Paper", "title", requestConfig)
console.log(property)
```

<p tit="Output"></p> 
 
```
Property {
  name: 'title',
  type: 7,
  subType: undefined,
  lte: false,
  read: true,
  write: true,
  schema: 'Paper',
  description: '',
  encrypt: '',
  decimalExtra: undefined
}
```

### getNodeProperty()

Retrieves a specified node property from the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Property`: The retrieved property.

 ```ts
// Retrieves node property 'title' associated with the node schema 'Paper' in the graph 'citation'
const requestConfig: RequestConfig = { graph: "citation" };
const property = await driver.getNodeProperty("Paper", "title", requestConfig)
console.log(property)
```

<p tit="Output"></p> 
 
```
Property {
  name: 'title',
  type: 7,
  subType: undefined,
  lte: false,
  read: true,
  write: true,
  schema: 'Paper',
  description: '',
  encrypt: '',
  decimalExtra: undefined
}
```

### getEdgeProperty()

Retrieves a specified edge property from the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Property`: The retrieved property.

 ```ts
// Retrieves edge property 'weight' associated with the edge schema 'Cites' in the graph 'citation'
const requestConfig: RequestConfig = { graph: "citation" };
const property = await driver.getEdgeProperty("Cites", "weight", requestConfig)
console.log(property)
```

<p tit="Output"></p> 
 
```
Property {
  name: 'weight',
  type: 1,
  subType: undefined,
  lte: false,
  read: true,
  write: true,
  schema: 'Cites',
  description: '',
  encrypt: '',
  decimalExtra: undefined
}
```

### createProperty()

Creates a property in the graph.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `property: Property`: The property to be created; the fields `name`, `type` (and `subType` if the `type` is `SET` or `LIST`), and `schema` (sets to `*` to specify all schemas) are mandatory, `encrypt` and `description` are optional.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Creates a property 'year' for all node schemas, creates a property 'tags' for the node schema 'Paper'

const requestConfig: RequestConfig = { graph: "citation" };
const property1: Property = { name: "year", type: UltipaPropertyType.UINT32, encrypt: "AES128", schema: "*" };
const property2: Property = { name: "tags", type: UltipaPropertyType.SET, subType: [UltipaPropertyType.STRING], schema: "Paper" };

const response1 = await driver.createProperty(DBType.DBNODE, property1, requestConfig);
console.log(response1.status?.message);

const response2 = await driver.createProperty(DBType.DBNODE, property2, requestConfig);
console.log(response2.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
```

### createPropertyIfNotExist()

Creates a property in the graph and returns whether a node or edge property with the same name already exists for the specified schema.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `property: Property`: The property to be created; the fields `name`, `type` (and `subType` if the `type` is `SET` or `LIST`), and `schema` (sets to `*` to specify all schemas) are mandatory, `encrypt` and `description` are optional.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `ResponseWithExistCheck`: Result of the request.

 ```ts
// Creates a property with existence check
const requestConfig: RequestConfig = { graph: "citation" };
const property: Property = { name: "tags", type: UltipaPropertyType.SET, subType: [UltipaPropertyType.STRING], schema: "Paper" };
const result = await driver.createPropertyIfNotExist(DBType.DBNODE, property, requestConfig);
console.log("Property already exists:", result.exist);
if (result.response.status?.code !== 0) {
  console.log("Error message:", result.response.status?.message);
} else {
  if (result.response.statistics?.totalCost === 0) {
    console.log("New property created: No");
  } else {
    console.log("New property created: Yes");
  }
};
```

<p tit="Output"></p> 
 
```
Property already exists: true
New property created: No
```

### alterProperty()

Alters the name and description of a property in the graph.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `originProp: Property`: The property to be altered; the fields `name` and `schema` (writes `*` to specify all schemas) are mandatory.
- `newProp: Property`: A `Property` object used to set new `name` and/or `description` for the `property`.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

```ts
// Renames the property 'tags' of the node schema 'Paper' to 'keywords' in the graph 'citation'

const requestConfig: RequestConfig = { graph: "citation" };

const oldProperty = new Property();
oldProperty.name = "tags";
oldProperty.schema = "Paper";
const newProperty = new Property();
newProperty.name = "keywords";

const response = await driver.alterProperty(DBType.DBNODE, oldProperty, newProperty, requestConfig);
console.log(response.status?.message)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropProperty()

Deletes specified properties from the graph.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `property: Property`: The property to be droppped; the fields `name` and `schema` (writes `*` to specify all schemas) are mandatory.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

 ```ts
// Drops the property 'tags' of the node schema in the graph 'citation'
const requestConfig: RequestConfig = { graph: "citation" };
const property = new Property();
property.name = "tags";
property.schema = "Paper";
const response = await driver.dropProperty(DBType.DBNODE, property, requestConfig);
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
import { DBType, GraphSet, RequestConfig, Schema, UltipaPropertyType } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);
          
  // Creates a new graph named 'social'

  const graph: GraphSet = {
    name: "social",
    shards: ["1"],
    partitionBy: "Crc32"
  };

  const response = await driver.createGraph(graph)
  console.log("Graph creation:", response.status?.message);

  // Creates schemas and properties in the graph 'social'

  const requestConfig: RequestConfig = { graph: "social" };

  const user: Schema = {
    name: "user",
    dbType: DBType.DBNODE,
    properties: [
      { name: "name", type: ULTIPA.UltipaPropertyType.STRING, schema: "user" },
      { name: "age", type: ULTIPA.UltipaPropertyType.INT32, schema: "user" },
      { name: "score", type: ULTIPA.UltipaPropertyType.DECIMAL, decimalExtra: { precision: 25, scale: 10 }, schema: "user" },
      { name: "birthday", type: ULTIPA.UltipaPropertyType.DATE, schema: "user" },
      { name: "active", type: ULTIPA.UltipaPropertyType.BOOL, schema: "user" },
      { name: "location", type: ULTIPA.UltipaPropertyType.POINT, schema: "user" },
      { name: "interests", type: ULTIPA.UltipaPropertyType.LIST, subType: [UltipaPropertyType.STRING], schema: "user" },
      { name: "permissionCodes", type: ULTIPA.UltipaPropertyType.SET, subType: [UltipaPropertyType.INT32], schema: "user" }
    ]
  };

  const product = {
    name: "product",
    dbType: DBType.DBNODE,
    properties: [
      { name: "name", type: ULTIPA.UltipaPropertyType.STRING, schema: "product" },
      { name: "price", type: ULTIPA.UltipaPropertyType.FLOAT, schema: "product" }
    ]
  };

  const follows = {
    name: "follows",
    dbType: DBType.DBEDGE,
    properties: [
      { name: "createdOn", type: ULTIPA.UltipaPropertyType.TIMESTAMP, schema: "follows" },
      { name: "weight", type: ULTIPA.UltipaPropertyType.FLOAT, schema: "follows" }
    ]
  };

  const purchased = {
    name: "purchased",
    dbType: DBType.DBEDGE
  };

  const schemas = [user, product, follows, purchased];
  for (const schema of schemas) {
    const response = await driver.createSchema(schema, true, requestConfig);
    console.log("Schema", schema.name, "creation:", response.status?.message);
  }
};

sdkUsage().catch(console.error);
```
