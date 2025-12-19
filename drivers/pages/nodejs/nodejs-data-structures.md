## Data Structures

This section introduces the core data structures provided by the driver.

## Node

`Node` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="23">Type</div> | Description |
| ---- | ---- | ---- |
| `uuid` | string | Node `_uuid`. |
| `id` | string | Node `_id`. |
| `schema` | string | Name of the schema the node belongs to. |
| `values` | [key: string]: any | Node property key-value pairs. |

If a query returns nodes, you can use `asNodes()` to convert the results into a list of `Node`s.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("MATCH (n:User) RETURN n LIMIT 2", requestConfig);
const nodes = response.alias("n").asNodes();
for (const node of nodes) {
  console.log(node)
}
```

<p tit="Output"></p> 
 
```
Node {
  uuid: '6557243256474697731',
  id: 'U4',
  schema: 'User',
  values: { name: 'mochaeach' }
}
Node {
  uuid: '7926337543195328514',
  id: 'U2',
  schema: 'User',
  values: { name: 'Brainy' }
}
```

## Edge

`Edge` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="23">Type</div> | Description |
| ---- | ---- | ---- |
| `uuid` | string | Edge `_uuid`. |
| `fromUuid` | string | `_uuid` of the source node of the edge. |
| `toUuid` | string | `_uuid` of the destination node of the edge. |
| `from` | string | `_id` of the source node of the edge. |
| `to` | string | `_id` of the destination node of the edge. |
| `schema` | string | Name of the schema the edge belongs to. |
| `values` | [key: string]: any | Edge property key-value pairs. |

If a query returns edges, you can use `asEdges()` to convert them into a list of `Edge`s.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("MATCH ()-[e]->() RETURN e LIMIT 2", requestConfig);
const edges = response.alias("e").asEdges();
for (const edge of edges) {
  console.log(edge)
}
```

<p tit="Output"></p> 
 
```
Edge {
  uuid: '2',
  fromUuid: '6557243256474697731',
  toUuid: '7926337543195328514',
  from: 'U4',
  to: 'U2',
  schema: 'Follows',
  values: { createdOn: '2024-02-10' }
}
Edge {
  uuid: '3',
  fromUuid: '7926337543195328514',
  toUuid: '17870285520429383683',
  from: 'U2',
  to: 'U3',
  schema: 'Follows',
  values: { createdOn: '2024-02-01' }
}
```

## Path

`Path` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |
| `nodeUuids` | string[] | The list of node `_uuid`s in the path. |
| `edgeUuids` | string[] | The list of edge `_uuid`s in the path |
| `nodes` | Map<string, `Node`> | A map of nodes in the path, where the key is the node’s `_uuid`, and the value is the corresponding node. |
| `edges` | Map<string, `Edge`> | A map of edges in the path, where the key is the edge’s `_uuid`, and the value is the corresponding edge. |

Methods on `Path`:

| <div table-width="15">Method</div> | <div table-width="15">Parameters</div> | <div table-width="10">Returns</div> | Description |
| ---- | ---- | ---- |  ---- |
| `length()` | / | number | Returns the number of edges in the path. |

If a query returns paths, you can first use `asGraph()` to convert the results into a `Graph` object; `Graph` provides access to the returned paths.

 ```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("MATCH p = ()-[]-() RETURN p LIMIT 2", requestConfig);
const graph = response.alias("p").asGraph();
const paths = graph.getPaths();
for (const path of paths) {
  console.log("Node _uuids:", path.nodeUuids, "Length:", path.length())
};
```

<p tit="Output"></p> 
 
```
Node _uuids: [ '6557243256474697731', '7926337543195328514' ] Length: 1
Node _uuids: [ '7926337543195328514', '17870285520429383683' ] Length: 1
```

## Graph

`Graph` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |
| `paths` | `Path`[] | The list of the returned paths. |
| `nodes` | Map<string, `Node`> | A map of **unique** nodes in the graph, where the key is the node’s `_uuid`, and the value is the corresponding node. |
| `edges` | Map<string, `Edge`> | A map of **unique** edges in the graph, where the key is the edge’s `_uuid`, and the value is the corresponding edge. |

Methods on `Graph`:

| <div table-width="15">Method</div> | <div table-width="16">Parameters</div> | <div table-width="10">Returns</div> | Description |
| ---- | ---- | ---- | ---- |
| `getPaths()` | / | `Path`[] | Returns the list of `Path` objects in the graph. |
| `addNode()` | `node: Node` | void | Adds a `Node` to the graph. Duplicate nodes are not added; `nodes` remains unique. |
| `addEdge()` | `edge: Edge` | void | Adds an `Edge` to the graph. Duplicate edges are not added; `edges` remains unique. |

If a query returns paths, you can use `asGraph()` to convert them into a `Graph`.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("MATCH p = ()-[]->() RETURN p LIMIT 2", requestConfig);
const graph = response.alias("p").asGraph();
console.log("Unique nodes:", graph.nodes)
console.log("Unique edges:", graph.edges)
console.log("All paths:", graph.paths)
```

<p tit="Output"></p> 
 
```
Unique nodes: Map(3) {
  '6557243256474697731' => Node {
    uuid: '6557243256474697731',
    id: 'U4',
    schema: 'User',
    values: { name: 'mochaeach' }
  },
  '7926337543195328514' => Node {
    uuid: '7926337543195328514',
    id: 'U2',
    schema: 'User',
    values: { name: 'Brainy' }
  },
  '17870285520429383683' => Node {
    uuid: '17870285520429383683',
    id: 'U3',
    schema: 'User',
    values: { name: 'purplechalk' }
  }
}
Unique edges: Map(2) {
  '2' => Edge {
    uuid: '2',
    fromUuid: '6557243256474697731',
    toUuid: '7926337543195328514',
    from: 'U4',
    to: 'U2',
    schema: 'Follows',
    values: { createdOn: '2024-02-10' }
  },
  '3' => Edge {
    uuid: '3',
    fromUuid: '7926337543195328514',
    toUuid: '17870285520429383683',
    from: 'U2',
    to: 'U3',
    schema: 'Follows',
    values: { createdOn: '2024-02-01' }
  }
}
All paths: [
  Path {
    nodeUuids: [ '6557243256474697731', '7926337543195328514' ],
    edgeUuids: [ '2' ],
    nodes: Map(2) {
      '6557243256474697731' => [Node],
      '7926337543195328514' => [Node]
    },
    edges: Map(1) { '2' => [Edge] }
  },
  Path {
    nodeUuids: [ '7926337543195328514', '17870285520429383683' ],
    edgeUuids: [ '3' ],
    nodes: Map(2) {
      '7926337543195328514' => [Node],
      '17870285520429383683' => [Node]
    },
    edges: Map(1) { '3' => [Edge] }
  }
]
```

## GraphSet

`GraphSet` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |
| `id` | string | Graph ID. |
| `name` | string | Graph name. |
| `totalNodes` | string | Total number of nodes in the graph. |
| `totalEdges` | string | Total number of edges in the graph. |
| `shards` | string[] | The list of IDs of shard servers where the graph is stored. |
| `partitionBy` | string | The hash function used for graph sharding, which can be `Crc32` (default), `Crc64WE`, `Crc64XZ`, or `CityHash64`. |
| `status` | string | Graph status, which can be `NORMAL`, `LOADING_SNAPSHOT`, `CREATING`, `DROPPING`, or `SCALING`. |
| `description` | string | Graph description. |
| `slotNum` | number | The number of slots used for graph sharding. |

If a query retrieves graphs (graphsets) in the database, you can use `asGraphSets()` to convert them into a list of `GraphSet`s.

```ts
const response = await driver.gql("SHOW GRAPH");
const graphs = response.alias("_graph").asGraphSets();
for (const graph of graphs) {
  console.log(graph.name)
}
```

The `showGraph()` method also retrieves graphs (graphsets) in the database, it returns a list of `GraphSet`s directly.

```ts
const graphs = await driver.showGraph();
graphs.forEach((graph) => console.log(graph.name));
```

<p tit="Output"></p> 
 
```
g1
miniCircle
amz
```

## Schema

`Schema` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- | 
| `name` | string | Schema name |
| `dbType` | `DBType` | Schema type, which can be `DBNODE` or `DBEDGE`.  |
| `properties` | `Property`[] | The list of properties associated with the schema. |
| `description` | string | Schema description |
| `total` | string | Total number of nodes or edges belonging to the schema. |
| `id` | string | Schema ID. |
| `stats` | `SchemaStat`[] | a list of `SchemaStat`s. each `SchemaStat` includes fields `schema` (schema name), `dbType` (schema type), `fromSchema` (source node schema), `toSchema` (destination node schema), and `count` (count of nodes or edges). |

If a query retrieves node or edge schemas defined in a graph, you can use `asSchemas()` to convert them into a list of `Schema`s.

 ```ts
const requestConfig: RequestConfig = { graph: "miniCircle" };
const response = await driver.gql("SHOW NODE SCHEMA", requestConfig);
const schemas = response.get(0).asSchemas();
for (const schema of schemas) {
  console.log(schema.name)
}
```

The `showSchema()`, `showNodeSchema()` and `showEdgeSchema()` methods also retrieve node and edge schemas in a graph, it returns a list of `Schema`s directly.

```ts
const requestConfig: RequestConfig = { graph: "miniCircle" };
const schemas = await driver.showSchema(requestConfig);
schemas.forEach((schema: any) => {
  console.log(schema.name);
});
```

<p tit="Output"></p> 
 
```
default
account
celebrity
country
movie
```

## Property

`Property` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- | 
| `name` | string | Property name. |
| `type` | `UltipaPropertyType` | Property value type, which can be `INT32`, `UINT32`, `INT64`, `UINT64`, `FLOAT`, `DOUBLE`, `DECIMAL`, `STRING`, `TEXT`, `LOCAL_DATETIME`, `ZONED_DATETIME`, `DATE`, `LOCAL_TIME`, `ZONED_TIME`, `DATETIME`, `TIMESTAMP`, `YEAR_TO_MONTH`, `DAY_TO_SECOND`, `BLOB`, `BOOL`, `POINT`, `LIST`, `SET`, `MAP`, `NULL`, `UUID`, `ID`, `FROM`, `FROM_UUID`, `TO`, `TO_UUID`, `IGNORE`, or `UNSET`. |
| `subType` | `UltipaPropertyType`[] | If the `type` is `LIST` or `SET`, sets its element type; only one `UltipaPropertyType` is allowed in the list. |
| `schema` | string | The associated schema of the property. |
| `description` | string | Property description. |
| `lte` | boolean | Whether the property is LTE-ed. |
| `read` | boolean | Whether the property is readable. |
| `write` | boolean | Whether the property can be written. |
| `encrypt` | string | Encryption method of the property, which can be `AES128`, `AES256`, `RSA`, or `ECC`. |
| `decimalExtra` | `DecimalExtra` | The precision (1–65) and scale (0–30) of the `DECIMAL` type. |

If a query retrieves node or edge properties defined in a graph, you can use `asProperties()` to convert them into a list of `Property`s.

 ```ts
const requestConfig: RequestConfig = { graph: "miniCircle" };
const response = await driver.gql("SHOW NODE account PROPERTY", requestConfig);
const properties = response.get(0).asProperties();
for (const property of properties) {
  console.log(property.name)
}
```

The `showProperty()`, `showNodeProperty()` and `showEdgeProperty()` methods also retrieve node and edge properties in a graph, it returns a list of `Property`s directly.

```ts
const requestConfig: RequestConfig = { graph: "miniCircle" };
const properties = await driver.showProperty(DBType.DBNODE, "account", requestConfig);
properties.nodeProperties.forEach((property) => {
  console.log(property.name)
});
```

<p tit="Output"></p> 
 
```
_id
gender
year
industry
name
```

## Attr

`Attr` includes the following fields:

| <div table-width="20">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |
| `name` | string | Name of the returned alias. |
| `values` | object[] | The returned values. |
| `propertyType` | `UltipaPropertyType` | Type of the property. |
| `resultType` | `ResultType` | Type of the results, which can be `RESULT_TYPE_UNSET`, `RESULT_TYPE_PATH`, `RESULT_TYPE_NODE`, `RESULT_TYPE_EDGE`, `RESULT_TYPE_ATTR` or `RESULT_TYPE_TABLE`. |

If a query returns results like property values, expressions, or computed values, you can use `asAttr()` to convert them into an `Attr`.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("MATCH (n:User) LIMIT 2 RETURN n.name", requestConfig);
const attr = response.alias("n.name").asAttr();
console.log(attr)
```

<p tit="Output"></p> 
 
```
Attr {
  propertyType: 7,
  resultType: 4,
  values: [ 'mochaeach', 'Brainy' ],
  name: 'n.name'
}
```

## Table

`Table` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | string | Table name. |
| `headers` | `Header`[] | Table headers. |
| `rows` | any[][] | Table rows. |

Methods on `Table`:

| <div table-width="10">Method</div> | <div table-width="15">Parameters</div> | <div table-width="10">Returns</div> | Description |
| ---- | ---- | ---- | ---- | 
| `toKV()` | / | any[] | Convert all rows in the table to an array of key-value objects. |

If a query uses the `table()` function to return a set of rows and columns, you can use `asTable()` to convert them into a `Table`.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("MATCH (n:User) LIMIT 2 RETURN table(n._id, n.name) AS result", requestConfig);
const table = response.alias("result").asTable();
console.log(table)
```

<p tit="Output"></p> 
 
```
Table {
  name: 'result',
  headers: [
    Header { propertyName: 'n._id', propertyType: 7 },
    Header { propertyName: 'n.name', propertyType: 7 }
  ],
  rows: [ [ 'U4', 'mochaeach' ], [ 'U2', 'Brainy' ] ]
}
```

## HDCGraph

`HDCGraph` includes the following fields:

| <div table-width="20">Field</div> | <div table-width="8">Type</div> | Description |
| ---- | ---- | ---- |
| `name` | string | HDC graph name. |
| `graphName` | string | The source graph from which the HDC graph is created. |
| `status` | string | HDC graph status. |
| `stats` | string | Statistics of the HDC graph. |
| `isDefault` | string | Whether it is the default HDC graph of the source graph. |
| `hdcServerName` | string | Name of the HDC server that hosts the HDC graph. |
| `hdcServerStatus` | string | Status of the HDC server that hosts the HDC graph. |
| `config` | string | Configurations of the HDC graph. |

If a query retrieves HDC graphs of a garph, you can use `asHDCGraphs()` to convert them into a list of `HDCGraph`s.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("SHOW HDC GRAPH", requestConfig);
const hdcGraphs = response.get(0).asHDCGraphs();
for (const hdcGraph of hdcGraphs) {
  console.log(hdcGraph.name);
}
```

The `showHDCGraph()` method also retrieves HDC graphs of a graph, it returns a list of `HDCGraph`s directly.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const hdcGraphs = await driver.showHDCGraph(requestConfig);
for (const hdcGraph of hdcGraphs) {
  console.log(hdcGraph.name);
}
```

<p tit="Output"></p> 
 
```
g1_hdc_full
g1_hdc_nodes
```

## Algo

`Algo` includes the following fields:

| <div table-width="20">Field</div> | <div table-width="17">Type</div> | Description |
| ---- | ---- | ---- |    
| `name` | string | Algorithm name. |
| `type` | string | Algorithm type. |
| `version` | string | Algorithm version. |
| `params` | `AlgoParam`[] | Algorithm parameters, each `AlgoParam` has field `name` and `desc`. |
| `writeSupportType` | string | The writeback types supported by the algorithm. |
| `canRollback` | string | Whether the algorithm version supports rollback. |
| `configContext` | string | The configurations of the algorithm. |

If a query retrieves algorithms installed on an HDC server of the database, you can use `asAlgos()` to convert them into a list of `Algo`s.

```ts
const response = await driver.gql("SHOW HDC ALGO ON 'hdc-server-1'");
const algos = response.get(0).asAlgos();
for (const algo of algos) {
  if (algo.type === "algo") {
    console.log(algo.name);
  }
}
```

The `showHDCAlgo()` method also retrieves algorithms installed on an HDC server of the database, it returns a list of `Algo`s directly.

```ts
const algos = await driver.showHDCAlgo("hdc-server-1");
for (const algo of algos) {
  if (algo.type == "algo") {
    console.log(algo.name);
  }
}
```

<p tit="Output"></p> 
 
```
bipartite
fastRP
```

## Projection

`Projection` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="8">Type</div> | Description |
| ---- | ---- | ---- |
| `name` | string | Projection name. |
| `graphName` | string | The source graph from which the projection is created. |
| `status` | string | Projection status. |
| `stats` | string | Statistics of the projection. |
| `config` | string | Configurations of the projection. |

If a query retrieves projections of a graph, you can use `asProjections()` to convert them into a list of `Projection`s.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("SHOW PROJECTION", requestConfig);
const projections = response.get(0).asProjections();
for (const projection of projections) {
  console.log(projection.name);
}
```

<p tit="Output"></p> 
 
```
distG1
distG1_nodes
```

## Index

`Index` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |
| `id` | string | Index ID. |
| `name` | string | Index name. |
| `properties` | string | Properties associated with the index. |
| `schema` | string | The schema associated with the index |
| `status` | string  | Index status. |
| `size` | string | Index size in bytes. |
| `dbType` | `DBType` | Index type, which can be `DBNODE` or `DBEDGE`. |

If a query retrieves node or edge indexes of a graph, you can use `asIndexes()` to convert them into a list of `Index`s.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("SHOW NODE INDEX", requestConfig);
const indexes = response.get(0).asIndexes();
for (const index of indexes) {
  console.log(index)
}
```

The `showIndex()`, `showNodeIndex()`, and `showEdgeIndex()` methods also retrieve indexes of a graph, it returns a list of `Index`s directly.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const indexList = await driver.showIndex(requestConfig);
for (const index of indexList) {
  console.log(index);
}
```

<p tit="Output"></p> 
 
```
Index {
  id: '1',
  name: 'User_name',
  properties: 'name(1024)',
  schema: 'User',
  status: 'DONE',
  size: undefined,
  dbType: 0
}
```

## Privilege

`Privilege` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="17">Type</div> | Description |
| ---- | ---- | ---- |
| `name` | string | Privilege name. |
| `level` | `PrivilegeLevel` | Privilege level, which can be `GraphLevel` or `SystemLevel`. |

If a query retrieves privileges defined in Ultipa, you can use `asPrivileges()` to convert them into a list of `Privilege`s.

```ts
const response = await driver.uql("show().privilege()");
const privileges = response.get(0).asPrivileges();

const graphPriviledgeNames = privileges
  .filter((p) => p.level === PrivilegeLevel.GraphLevel)
  .map((p) => p.name)
  .join(", ");
console.log("Graph privileges:" + graphPriviledgeNames);

const systemPriviledgeNames = privileges
  .filter((p) => p.level === PrivilegeLevel.SystemLevel)
  .map((p) => p.name)
  .join(", ");
console.log("System privileges:" + systemPriviledgeNames);
```

The `showPrivilege()` method also retrieves privileges defined in Ultipa, it returns a list of `Privilege`s directly.

```ts
const privileges = await driver.showPrivilege();

const graphPriviledgeNames = privileges
  .filter((p) => p.level === PrivilegeLevel.GraphLevel)
  .map((p) => p.name)
  .join(", ");
console.log("Graph privileges:" + graphPriviledgeNames);

const systemPriviledgeNames = privileges
  .filter((p) => p.level === PrivilegeLevel.SystemLevel)
  .map((p) => p.name)
  .join(", ");
console.log("System privileges:" + systemPriviledgeNames);
```

<p tit="Output"></p> 
 
```
Graph privileges:READ, INSERT, UPSERT, UPDATE, DELETE, CREATE_SCHEMA, DROP_SCHEMA, ALTER_SCHEMA, SHOW_SCHEMA, RELOAD_SCHEMA, CREATE_PROPERTY, DROP_PROPERTY, ALTER_PROPERTY, SHOW_PROPERTY, CREATE_FULLTEXT, DROP_FULLTEXT, SHOW_FULLTEXT, CREATE_INDEX, DROP_INDEX, SHOW_INDEX, LTE, UFE, CLEAR_JOB, STOP_JOB, SHOW_JOB, ALGO, CREATE_PROJECT, SHOW_PROJECT, DROP_PROJECT, CREATE_HDC_GRAPH, SHOW_HDC_GRAPH, DROP_HDC_GRAPH, COMPACT_HDC_GRAPH, SHOW_VECTOR_INDEX, CREATE_VECTOR_INDEX, DROP_VECTOR_INDEX, SHOW_CONSTRAINT, CREATE_CONSTRAINT, DROP_CONSTRAINT
System privileges:TRUNCATE, COMPACT, CREATE_GRAPH, SHOW_GRAPH, DROP_GRAPH, ALTER_GRAPH, CREATE_GRAPH_TYPE, SHOW_GRAPH_TYPE, DROP_GRAPH_TYPE, TOP, KILL, STAT, SHOW_POLICY, CREATE_POLICY, DROP_POLICY, ALTER_POLICY, SHOW_USER, CREATE_USER, DROP_USER, ALTER_USER, SHOW_PRIVILEGE, SHOW_META, SHOW_SHARD, ADD_SHARD, DELETE_SHARD, REPLACE_SHARD, SHOW_HDC_SERVER, ADD_HDC_SERVER, DELETE_HDC_SERVER, LICENSE_UPDATE, LICENSE_DUMP, GRANT, REVOKE, SHOW_BACKUP, CREATE_BACKUP, SHOW_VECTOR_SERVER, ADD_VECTOR_SERVER, DELETE_VECTOR_SERVER
```

## Policy

`Policy` includes the following fields:

| <div table-width="20">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |
| `name` | string | Policy name. |
| `systemPrivileges` | string[] | System privileges included in the policy. |
| `graphPrivileges` | Map<string, string[]> | Graph privileges included in the policy; in the map, the key is the name of the graph, and the value is the corresponding graph privileges. |
| `propertyPrivileges` | `PropertyPrivilege` | Property privileges included in the policy; the `PropertyPrivilege` has fields `node` and `edge`, both are `PropertyPrivilegeElement` objects. |
| `policies` | string[] | Policies included in the policy. |

`PropertyPrivilegeElement` includes the following fields:

| <div table-width="10">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |
| `read` | string[][] | An array of arrays; each inner array contains three strings representing the graph, schema, and property. |
| `write` | string[][] | An array of arrays; each inner array contains three strings representing the graph, schema, and property. |
| `deny` | string[][] | An array of arrays; each inner array contains three strings representing the graph, schema, and property. |

If a query retrieves policies (roles) defined in the database, you can use `asPolicies()` to convert them into a list of `Policy`s.

```ts
const response = await driver.gql("SHOW ROLE");
const policies = response.get(0).asPolicies();
for (const policy of policies) {
  console.log(policy.name);
}
```

The `showPolicy()` method also retrieves policies (roles) defined in the database, it returns a list of `Policy`s directly.

```ts
const policies = await driver.showPolicy();
for (const policy of policies) {
  console.log(policy.name);
}
```

<p tit="Output"></p> 
 
```
manager
Tester
operator
superADM
```

## User

`User` includes the following fields:

| <div table-width="20">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |
| `username` | string | Username. |
| `password` | string | Password. |
| `createdTime` | `Date` | The time when the user was created. |
| `systemPrivileges` | string[] | System privileges granted to the user. |
| `graphPrivileges` | Map<string, string[]> | Graph privileges granted to the user; in the map, the key is the name of the graph, and the value is the corresponding graph privileges. |
| `propertyPrivileges` | `PropertyPrivilege` | Property privileges granted to the user; the `PropertyPrivilege` has fields `node` and `edge`, both are `PropertyPrivilegeElement` objects. |
| `policies` | string[] | Policies granted to the user. |

`PropertyPrivilegeElement` includes the following fields:

| <div table-width="10">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |
| `read` | string[][] | An array of arrays; each array list contains three strings representing the graph, schema, and property. |
| `write` | string[][] | An array of arrays; each array list contains three strings representing the graph, schema, and property. |
| `deny` | string[][] | An array of arrays; each array list contains three strings representing the graph, schema, and property. |

If a query retrieves database users, you can use `asUsers()` to convert them into a list of `User`s.

```ts
const response = await driver.gql("SHOW USER");
const users = response.get(0).asUsers();
for (const user of users) {
  console.log(user.username);
}
```

The `showUser()` method also retrieves database users, it returns a list of `User`s directly.

```ts
const users = await driver.showUser();
for (const user of users) {
  console.log(user.username);
}
```

<p tit="Output"></p> 
 
```
user01
root
johndoe
```

## Process

`Process` includes the following fields:

| <div table-width="18">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- | 
| `processId` | string | Process ID. |
| `processQuery` | string | The query that the process executes. |
| `status` | string | Process status. |
| `duration` | string | The duration (in seconds) the process has run. |

If a query retrieves processes running in the database, you can use `asProcesses()` to convert them into a list of `Process`s.

```ts
const response = await driver.gql("TOP");
const processes = response.get(0).asProcesses();
for (const process of processes) {
  console.log(process);
}
```

The `top()` method also retrieves processes running in the database, it returns a list of `Process`s directly.

```ts
const processes = await driver.top();
for (const process of processes){
  console.log(process);
}
```

<p tit="Output"></p> 
 
```
Process {
  processId: '1060719',
  processQuery: 'MATCH p = ()-{1,7}() RETURN p',
  duration: '1',
  status: 'RUNNING'
}
```

## Job

`Job` includes the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- | 
| `id` | string | Job ID. |
| `graphName` | string | Name of the graph where the job executes on. |
| `query` | string | The query that the job executes. |
| `type` | string | Job type. |
| `errNsg` | string | Error message of the job. |
| `result` | Map<any, any> | Result of the job. |
| `startTime` | string | The time when the job begins. |
| `endTime` | string | The times when the job ends. |
| `status` | string | Job status. |
| `progress` | string | Progress updates for the job, such as indications that the write operation has been started. |

If a query retrieves jobs of a graph, you can use `asJobs()` to convert them into a list of `Job`s.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("SHOW JOB", requestConfig);
const jobs = response.get(0).asJobs();
for (const job of jobs) {
  console.log(job);
}
```

The `showJob()` method also retrieves processes running in the database, it returns a list of `Job`s directly.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const jobs = await driver.showJob(undefined, requestConfig);
for (const job of jobs) {
  console.log(job);
}
```

<p tit="Output"></p> 
 
```
Job {
  id: '5',
  graphName: 'g1',
  query: 'CREATE INDEX User_name ON NODE User (name)',
  type: 'CREATE_INDEX',
  errMsg: '',
  result: null,
  startTime: '2025-09-23 17:43:54',
  endTime: '2025-09-23 17:43:55',
  status: 'FINISHED',
  progress: ''
}
Job {
  id: '5_1',
  graphName: 'g1',
  query: '',
  type: 'CREATE_INDEX',
  errMsg: '',
  result: null,
  startTime: '2025-09-23 17:43:55',
  endTime: '2025-09-23 17:43:55',
  status: 'FINISHED',
  progress: ''
}
Job {
  id: '5_2',
  graphName: 'g1',
  query: '',
  type: 'CREATE_INDEX',
  errMsg: '',
  result: null,
  startTime: '2025-09-23 17:43:55',
  endTime: '2025-09-23 17:43:55',
  status: 'FINISHED',
  progress: ''
}
Job {
  id: '5_3',
  graphName: 'g1',
  query: '',
  type: 'CREATE_INDEX',
  errMsg: '',
  result: null,
  startTime: '2025-09-23 17:43:55',
  endTime: '2025-09-23 17:43:55',
  status: 'FINISHED',
  progress: ''
}
Job {
  id: '1',
  graphName: 'g1',
  query: 'CREATE HDC GRAPH g1_hdc_full ON "hdc-server-1" OPTIONS {\n' +
    '  nodes: {"*": ["*"]},\n' +
    '  edges: {"*": ["*"]},\n' +
    '  direction: "undirected",\n' +
    '  load_id: true,\n' +
    '  update: "static"\n' +
    '}',
  type: 'CREATE_HDC_GRAPH',
  errMsg: '',
  result: Map(4) {
    'edge_count' => 4,
    'edge_schema' => { Follows: [Object], default: [Object] },
    'node_count' => 5,
    'node_schema' => { User: [Object], default: [Object] }
  },
  startTime: '2025-09-23 17:29:05',
  endTime: '2025-09-23 17:29:07',
  status: 'FINISHED',
  progress: ''
}
Job {
  id: '1_1',
  graphName: 'g1',
  query: '',
  type: 'CREATE_HDC_GRAPH',
  errMsg: '',
  result: null,
  startTime: '2025-09-23 17:29:05',
  endTime: '2025-09-23 17:29:07',
  status: 'FINISHED',
  progress: ''
}
```
