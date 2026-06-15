# Process Query Results

Methods like `gql()` and `uql()` return a `Response` containing the raw query results from the database and execution metadata. To use the query results in your application, you need to **extract** and **convert** them into a usable <a target="_blank" href="/docs/drivers/nodejs-data-structures">data structure</a>.

`Response` includes the following fields:

| <div table-width="16">Field</div> | <div table-width="16">Type</div> | Description |
| ---- | ---- | ---- |  
| `aliases` | `Alias`[] | The list of result aliases; each `Alias` includes fields `name` and `type`. |
| `items` | [key: string]: `DataItem` | An object where each key is an alias name, and each value is the corresponding query result data. |
| `explainPlan` | `ExplainPlan` | The execution plan. |
| `status` | `Status` | The status of the execution, including fields `code` and `message`. |
| `statistics` | `Statistics` | Statistics related to the execution, including fields `nodeAffected`, `edgeAffected`, `totalCost`, and `engineCost`. |

## Extract Query Results

To extract the query results, i.e., the `DataItem` from `Response.items`, use the `get()` or `alias()` method.

### get()

Extracts query results by the alias index.

**Parameters**

- `index: number`: Index of the alias.

**Returns**

- `DataItem`: The query results.

```ts
const response = await driver.gql("MATCH (n)-[e]->() RETURN n, e LIMIT 2");
console.log(response.get(0));
```

The GQL query returns two aliases (`n`, `e`), the `get()` method gets the `DataItem` of the alias `n` at index 0.

<p tit="Output"></p> 
 
```
DataItem {
  alias: 'n',
  type: 2,
  entities: [
    Node {
      uuid: '6557243256474697731',
      id: 'U4',
      schema: 'User',
      values: [Object]
    },
    Node {
      uuid: '7926337543195328514',
      id: 'U2',
      schema: 'User',
      values: [Object]
    }
  ]
}
```

### alias()

Extracts query results by the alias name.

**Parameters**

- `alias: string`: Name of the alias.

**Returns**

- `DataItem`: The query results.

```ts
const response = await driver.gql("MATCH (n)-[e]->() RETURN n, e LIMIT 2");
console.log(response.alias("e"));
```

The GQL query returns two aliases (`n`, `e`), the `alias()` method gets the `DataItem` of the alias `e`.

<p tit="Output"></p> 
 
```
DataItem {
  alias: 'e',
  type: 3,
  entities: [
    Edge {
      uuid: '2',
      fromUuid: '6557243256474697731',
      toUuid: '7926337543195328514',
      from: 'U4',
      to: 'U2',
      schema: 'Follows',
      values: [Object]
    },
    Edge {
      uuid: '3',
      fromUuid: '7926337543195328514',
      toUuid: '17870285520429383683',
      from: 'U2',
      to: 'U3',
      schema: 'Follows',
      values: [Object]
    }
  ]
}
```

## Convert Query Results

You should use a `as<DataStructure>()` method to convert the `DataItem.entities` into the corresponding <a target="_blank" href="/docs/drivers/nodejs-data-structures">data structure</a>.

### asNodes()

If a query returns nodes, you can use `asNodes()` to convert them into a list of `Node`s.

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

### asFirstNode()

If a query returns nodes, you can use `asFirstNode()` to convert the first returned node into a `Node`.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("MATCH (n:User) RETURN n", requestConfig);
const node = response.alias("n").asFirstNode();
console.log(node)
```

<p tit="Output"></p> 
 
```
Node {
  uuid: '6557243256474697731',
  id: 'U4',
  schema: 'User',
  values: { name: 'mochaeach' }
}
```

### asEdges()

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

### asFirstEdge()

If a query returns edges, you can use `asFirstEdge()` to convert the first returned edge into an `Edge`.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("MATCH ()-[e]->() RETURN e LIMIT 2", requestConfig);
const edge = response.alias("e").asFirstEdge();
console.log(edge)
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
```

### asGraph()

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

### asGraphSets()

If a query retrieves graphs (graphsets) in the database, you can use `asGraphSets()` to convert them into a list of `GraphSet`s.

```ts
const response = await driver.gql("SHOW GRAPH");
const graphsets = response.get(0).asGraphSets();
for (const graphset of graphsets) {
  console.log(graphset.name)
}
```

<p tit="Output"></p> 
 
```
g1
miniCircle
amz
```

### asSchemas()

If a query retrieves node or edge schemas defined in a graph, you can use `asSchemas()` to convert them into a list of `Schema`s.

```ts
const requestConfig: RequestConfig = { graph: "miniCircle" };
const response = await driver.gql("SHOW NODE SCHEMA", requestConfig);
const schemas = response.get(0).asSchemas();
for (const schema of schemas) {
  console.log(schema.name)
}
```

<p tit="Output"></p> 
 
```
default
account
celebrity
country
movie
```

### asProperties()

If a query retrieves node or edge properties defined in a graph, you can use `asProperties()` to convert them into a list of `Property`s.

```ts
const requestConfig: RequestConfig = { graph: "miniCircle" };
const response = await driver.gql("SHOW NODE account PROPERTY", requestConfig);
const properties = response.get(0).asProperties();
for (const property of properties) {
  console.log(property.name)
}
```

<p tit="Output"></p> 
 
```
_id
gender
year
industry
name
```

### asAttr()

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

### asTable()

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

### asHDCGraphs()

If a query retrieves HDC graphs of a graph, you can use `asHDCGraphs()` to convert them into a list of `HDCGraph`s.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("SHOW HDC GRAPH", requestConfig);
const hdcGraphs = response.get(0).asHDCGraphs();
for (const hdcGraph of hdcGraphs) {
  console.log(hdcGraph.name);
}
```

<p tit="Output"></p> 
 
```
g1_hdc_full
g1_hdc_nodes
```

### asAlgos()

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

<p tit="Output"></p> 
 
```
bipartite
fastRP
```

### asProjections()

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

### asIndexes()

If a query retrieves node or edge indexes of a graph, you can use `asIndexes()` to convert them into a list of `Index`s.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("SHOW NODE INDEX", requestConfig);
const indexes = response.get(0).asIndexes();
for (const index of indexes) {
  console.log(index)
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

### asPrivileges()

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

<p tit="Output"></p> 
 
```
Privilege { name: 'READ', level: 0 }
Privilege { name: 'INSERT', level: 0 }
...
Privilege { name: 'DELETE_VECTOR_SERVER', level: 1 }
```

### asPolicies()

If a query retrieves policies (roles) defined in the database, you can use `asPolicies()` to convert them into a list of `Policy`s.

```ts
const response = await driver.gql("SHOW ROLE");
const policies = response.get(0).asPolicies();
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

### asUsers()

If a query retrieves database users, you can use `asUsers()` to convert them into a list of `User`s.

```ts
const response = await driver.gql("SHOW USER");
const users = response.get(0).asUsers();
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

### asProcesses()

If a query retrieves processes running in the database, you can use `asProcesses()` to convert them into a list of `Process`s.

```ts
const response = await driver.gql("TOP");
const processes = response.get(0).asProcesses();
for (const process of processes) {
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

### asJobs()

If a query retrieves jobs of a graph, you can use `asJobs()` to convert them into a list of `Job`s.

```ts
const requestConfig: RequestConfig = { graph: "g1" };
const response = await driver.gql("SHOW JOB", requestConfig);
const jobs = response.get(0).asJobs();
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

## Full Example

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { RequestConfig } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);

  const requestConfig: RequestConfig = { graph: "g1" };
  const response = await driver.gql("MATCH (n:User) RETURN n LIMIT 2", requestConfig);
  const nodes = response.alias("n").asNodes();
  for (const node of nodes) {
    console.log(node)
  };
};

sdkUsage().catch(console.error);
```
