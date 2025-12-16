# Types Mapping Ultipa and Node.js

## Mapping Methods

The `get()` or `alias()` method of the `Response` class returns a `DataItem`, which embeds the query result. You should use the `as<Type>()` method of `DataItem` to cast the result to the appropriate driver type.

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
  graphSetName: "miniCircle",
};

let resp = await conn.uql(
  "find().nodes() as n return n{*} limit 5",
  requestConfig
);

console.log(resp.data?.get(0).asNodes());
```

The result `n` coming from the database contains five nodes, each of the NODE type. The `asNodes()` method converts them as a list of `Node` objects.

Type mapping methods available on `DataItem`:

| UQL Type | UQL Alias | Method | Driver Type | <div table-width="35">Description</div> |
| -- | -- | -- | -- | -- |
| NODE | Any | `asNodes()` | Node[] | Maps NODE-type `DataItem` to a list of `Node` objects. |
| EDGE | Any | `asEdges()` | Edge[] | Maps EDGE-type `DataItem` to a list of `Edge` objects. |
| PATH | Any | `asPaths()` | Path[] | Maps PATH-type `DataItem` to a list of `Path` objects. |
| GRAPH | Any | `asGraph()` | Graph | Maps GRAPH-type `DataItem` to a `Graph` object.
| TABLE | `_graph` | `asGraphInfos()` | GraphSet[] | Maps `DataItem` with the alias `_graph` to a list of `GraphSet` objects. |
| TABLE | `_nodeSchema`, `_edgeSchema` | `asSchemas()` | Schema[] | Maps `DataItem` with the alias `_nodeSchema` or `_edgeSchema` to a list of `Schema` objects. |
| TABLE | `_nodeProperty`, `_edgeProperty` | `asProperties()` | Property[] | Maps `DataItem` with the alias `_nodeProperty` or `_edgeProperty` to a list of `Property` objects. |
| TABLE | `_algoList` | `asAlgos()` | Algo[] | Maps `DataItem` with the alias `_algoList` to a list of `Algo` objects. |
| TABLE | `_extaList` | `asExtas()` | Exta[] | Maps `DataItem` with the alias `_extaList` to a list of `Exta` objects. |
| TABLE | `_nodeIndex`, `_edgeIndex`, `_nodeFulltext`, `_edgeFulltext` | `/` | Index[] | Maps `DataItem` with the alias `_nodeIndex`, `_edgeIndex`, `_nodeFulltext` or `_edgeFulltext` to a list of `Index` objects. |
| TABLE | `_privilege` | `/` | Priviliege | Maps `DataItem` with the alias `_privilege` to a `Priviliege` object. |
| TABLE | `_policy` | `/` | Policy[] | Maps `DataItem` with the alias `_policy` to a list of `Policy` objects. |
| TABLE | `_user` | `/` | User[] | Maps `DataItem` with the alias `_user` to a list of `User` objects. |
| TABLE | `_statistic` | `/` | Stats | Maps `DataItem` with the alias `_statistic` to a `Stats` object. |
| TABLE | `_top` | `/` | Process[] | Maps `DataItem` with the alias `_top` to a list of `Process` objects. |
| TABLE | `_task` | `asTasks()` | Task[] | Maps `DataItem` with the alias `_task` to a list of `Task` objects. |
| TABLE | Any | `asTable()` | Table | Maps TABLE-type `DataItem` to a `Table` object. |
| ATTR | Any | `asAttr()` | Attr | Maps ATTR-type `DataItem` to a `Attr` object. |

## Driver Types

> Objects of all driver types support **getter methods** to retrieve the value of a field and **setter methods** to set the value of a field, even if they are not explicitly listed below.

### Node

A `Node` object has the following fields:

| Field | Type | <div table-width="50">Description</div> |
| ---- | ---- | ---- |  
| `uuid` | string | Node UUID |
| `id` | string | Node ID |
| `schema` | string | Node Schema |
| `values` | object | Node custom properties |

Methods on a `Node` object:

| <div table-width="27">Method</div> | <div table-width="10">Return</div> | Description |
| ---- | ---- | ---- |
| `get("<propertyName>")` | Object | Get value of the given custom property of the node. |
| `set("<propertyName>", <propertyValue>` |  | Set value for the given custom property of the node; or add a key-value pair to the `values` of the node if the given `<propertyName>` does not exist. |

<p tit= "TypeScript" ></p> 

```ts
let resp = await conn.uql(
  "find().nodes() as n return n{*} limit 5",
  requestConfig
);
let nodeList = resp.data?.alias("n").asNodes();

console.log("ID of the 1st node:", nodeList[0].getID());
console.log("Name of the 1st node:", nodeList[0].get("name"));
```

<p tit= "Output" ></p> 
 
```bash
ID of the 1st node: ULTIPA8000000000000001
Name of the 1st node: Titanic
```

### Edge

An `Edge` object has the following fields:

| Field | Type | <div table-width="50">Description</div> |
| ---- | ---- | ---- |  
| `schema` | string | Edge Schema |
| `from` | string | Start node ID of the edge |
| `to` | string | End node ID of the edge |
| `uuid` | string | Edge UUID |
| `from_uuid` | string | Start node UUID of the edge |
| `to_uuid` | string | End node UUID of the edge |
| `values` | object | Edge custom properties |

Methods on an `Edge` object:

| <div table-width="27">Method</div> | <div table-width="10">Return</div> | Description |
| ---- | ---- | ---- | 
| `get("<propertyName>")` | Object | Get value of the given custom property of the edge. |
| `set("<propertyName>", <propertyValue>` |  | Set value for the given custom property of the edge; or add a key-value pair to the values of the edge if the given `<propertyName>` does not exist. |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql(
  "find().edges() as e return e{*} limit 5",
  requestConfig
);
let edgeList = resp.data?.alias("e").asEdges();

console.log("Values of the 1st edge", edgeList[0].getValues());
```

<p tit= "Output" ></p> 
 
```bash
Values of the 1st edge {
  datetime: '2019-01-06 02:57:57',
  timestamp: 1546714677,
  targetPost: '703'
}
```

### Path

A `Path` object has the following fields:

| Field | <div table-width="25">Type</div> | <div table-width="45">Description</div> |
| ---- | ---- | ---- |  
| `nodes` | Node[] | Node list of the path |
| `edges` | Edge[] | Edge list of the path |
| `length` | number | Length of the path, namely the number of edges in the path |


<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql(
  "n().e()[:2].n() as paths return paths{*} limit 5",
  requestConfig
);
let pathList = resp.data?.alias("paths").asPaths();

console.log("Length of the 1st path:", pathList[0].length);
console.log("Edge list of the 1st path:", pathList[0].getEdges());
console.log(
  "Information of the 2nd node in the 1st path:",
  pathList[0].getNodes()[1]
);
```

<p tit= "Output" ></p> 
 
```bash
Length of the 1st path: 2
Edge list of the 1st path: [
  Edge {
    from: 'ULTIPA800000000000001B',
    to: 'ULTIPA8000000000000001',
    uuid: '7',
    from_uuid: '27',
    to_uuid: '1',
    schema: 'follow',
    values: {}
  },
  Edge {
    from: 'ULTIPA8000000000000021',
    to: 'ULTIPA800000000000001B',
    uuid: '99',
    from_uuid: '33',
    to_uuid: '27',
    schema: 'follow',
    values: {}
  }
]
Information of the 2nd node in the 1st path: Node {
  id: 'ULTIPA800000000000001B',
  uuid: '27',
  schema: 'account',
  values: {
    year: 1988,
    industry: 'Transportation',
    double: '3.72'
  }
}
```

### Graph

A `Graph` object has the following fields:

| Field | <div table-width="25">Type</div> | <div table-width="45">Description</div> |
| ---- | ---- | ---- |  
| `nodes` | Node[] | Node list of the path |
| `edges` | Edge[] | Edge list of the path |
| `nodeSchemas` | map<string, schema> | Map of all node schemas of the path |
| `edgeSchemas` | map<string, schema> | Map of all edge schemas of the path |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql(
  "n(as n1).re(as e).n(as n2).limit(3) with toGraph(collect(n1), collect(n2), collect(e)) as graph return graph",
  requestConfig
);
let graphList = resp.data?.alias("graph").asGraph();

let nodeList = graphList.getNodes();
let edgeList = graphList.getEdges();
console.log(
  "Node IDs:",
  nodeList.map((node) => node.getID())
);
console.log(
  "Edge UUIDs:",
  edgeList.map((edge) => edge.getUUID())
);
```

<p tit= "Output" ></p> 
 
```bash
Node IDs: [
  'ULTIPA8000000000000017',
  'ULTIPA8000000000000001',
  'ULTIPA800000000000001B',
  'ULTIPA8000000000000061'
]
Edge UUIDs: [ '43', '1576', '29' ]
```

### GraphSet

A `GraphSet` object has the following fields:

| <div table-width="15">Field</div> | Type | <div table-width="65">Description</div> |
| ---- | ---- | ---- |  
| `id` | string | Graphset ID |
| `name` | string | Graphset name |
| `description` | string | Graphset description |
| `totalNodes` | string | Total number of nodes in the graphset |
| `totalEdges` | string | Total number of edges in the graphset |
| `status` | string | Graphset status (MOUNTED, MOUNTING, or UNMOUNTED) |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql("show().graph()");
let graphList = resp.data?.alias("_graph").asGraphInfos();

let unmountedGraph = graphList.filter((item) => item.status == "UNMOUNTED");
console.log(unmountedGraph.map((item) => item.name));
```

<p tit= "Output" ></p> 
 
```bash
[ 'DFS_EG', 'cyber', 'cyber2' ]
```

### Schema

A `Schema` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="18">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | string | Schema name |
| `description` | string | Schema description |
| `properties` | Property[] | Property list of the schema |
| `totalNodes` | string | Total number of nodes of the schema |
| `totalEdges` | string | Total number of edges of the schema |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql("show().node_schema()", requestConfig);
let schemaList = resp.data?.alias("_nodeSchema").asSchemas();

for (let schema of schemaList) {
  console.log(schema.name, "has", schema.totalNodes, "nodes");
}
```

<p tit= "Output" ></p> 
 
```bash
default has 0 nodes
account has 111 nodes
movie has 92 nodes
country has 23 nodes
celebrity has 78 nodes
```

### Property

A `Property` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="18">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | string | Property name |
| `description` | string | Property description |
| `schema` | string | Associated schema of the property |
| `type` | string | Property data type |
| `lte` | string | Property LTE status (true, false or creating) |
| `extra` | PropertyExtraInfo | Extra information of properties |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql("show().node_property(@user)", requestConfig);
let propertyList = resp.data?.alias("_nodeProperty").asProperties();

for (let property of propertyList) {
  if (property.lte == "true")
    console.log("LTE-ed property name:", property.name);
}
```

<p tit= "Output" ></p> 
 
```bash
LTE-ed property name: location
```

### Algo

An `Algo` object has the following fields:

| <div table-width="10">Field</div> | <div table-width="28">Type</div> | Description |
| ---- | ---- | ---- |  
| `clusterId` | string | ID of the cluster |
| `name` | string | Algorithm name |
| `param` | object | Parameters of the algorithm, including `name`, `description`, `parameters`, `result_opt` and `version`|
| `detail` | string | Algorithm detailed information |
| `result_opt` | object | Options for the algorithm result |


<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql("show().algo()");
let algoList = resp.data?.alias("_algoList").asAlgos();
console.log("Algo name:", algoList[0].param.name);
console.log("Algo version:", algoList[0].param.version);
console.log("Description:", algoList[0].param.description);
```

<p tit= "Output" ></p> 
 
```bash
Algo name: lpa
Algo version: 1.0.10
Description: label propagation algorithm
```

### Exta

> An exta is a custom algorithm developed by users.

An `Exta` object has the following fields:

| <div table-width="10">Field</div> | <div table-width="28">Type</div> | Description |
| ---- | ---- | ---- |  
| `author` | string | Exta author |
| `detail` | string | Content of the YML configuration file of the Exta |
| `name` | string | Exta name |
| `version` | string | Exta version |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql("show().exta()");
let extaList = resp.data?.alias("_extaList").asExtas();
console.log("Exta name:", extaList[0].name);
```

<p tit= "Output" ></p> 
 
```bash
Exta name: page_rank 1
```

### Index

An `Index` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | string | Index name |
| `properties` | string | Property name of the index |
| `schema` | string | Schema name of the index |
| `status` | string | Index status (done or creating) |
| `size` | string | Index size in bytes |
| `dbType` | Ultipa.DBType | Index type (DBNODE or DBEDGE) |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql("show().index()");
let indexList = resp.data?.alias("_nodeIndex");
console.log(indexList.data);
```

<p tit= "Output" ></p> 
 
```bash
Table {
  name: '_nodeIndex',
  alias: '_nodeIndex',
  headers: [ 'name', 'properties', 'schema', 'status', 'size' ],
  rows: []
}
```

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql("show().fulltext()");
let indexList = resp.data?.alias("_nodeFulltext");
console.log(indexList.data);
```

<p tit= "Output" ></p> 
 
```bash
Table {
  name: '_nodeFulltext',
  alias: '_nodeFulltext',
  headers: [ 'name', 'properties', 'schema', 'status' ],
  rows: []
}
```

### Privilege

A `Privilege` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `systemPrivileges` | string[] | System privileges |
| `graphPrivileges` | string[] | Graph privileges |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql("show().privilege()");
let privilegeList = resp.data?.alias("_privilege").asTable();

console.log("System privileges:", privilegeList.rows[0][1]);
```

<p tit= "Output" ></p> 
 
```bash
[TRUNCATE, COMPACT, CREATE_GRAPH, SHOW_GRAPH, DROP_GRAPH, ALTER_GRAPH, MOUNT_GRAPH, UNMOUNT_GRAPH, TOP, KILL, STAT, SHOW_POLICY, CREATE_POLICY, DROP_POLICY, ALTER_POLICY, SHOW_USER, CREATE_USER, DROP_USER, ALTER_USER, GRANT, REVOKE, SHOW_PRIVILEGE]
```

### Policy

A `Policy` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | string | Policy name |
| `graph_privileges` | GraphPrivilege | Graph privileges and the corresponding graphsets included in the policy |
| `system_privileges` | string[] | System privileges included in the policy |
| `policies` | string[] | Policies included in the policy |
| `property_privileges` | PropertyPrivilege | Property privileges included in the policy |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql("show().policy()");
let policyList = resp.data?.alias("_policy");
console.log(policyList.data.rows[4]);
```

<p tit= "Output" ></p> 
 
```bash
[
  'policy',
  '{"amz":["SHOW_ALGO","CREATE_PROPERTY","CLEAR_TASK","RESUME_TASK","CREATE_BACKUP","SHOW_PROPERTY","SHOW_FULLTEXT","SHOW_INDEX"]}',
  '["GRANT","DROP_GRAPH","CREATE_USER","COMPACT","UNMOUNT_GRAPH","STAT","DROP_POLICY"]',
  '{"node":{"read":[],"write":[],"deny":[]},"edge":{"read":[],"write":[],"deny":[]}}',
  '["subpolicy"]'
]
```

### User

A `User` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `username` | string | Username |
| `create` | string | When the user was created |
| `lastLogin` | string | When the user logged in last time |
| `system_privileges` | string[] | System privileges granted to the user |
| `graph_privileges` | GraphPrivilege | Graph privileges and the corresponding graphsets granted to the user |
| `policies` | string[] | Policies granted to the user |
| `property_privileges` | PropertyPrivilege | Property privileges granted to the user |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql("show().user('Tester')");
let userList = resp.data.alias("_user").asTable();

console.log(userList.headers[0], ":", userList.rows[0][0]);
console.log(userList.headers[1], ":", userList.rows[0][1]);
console.log(userList.headers[2], ":", userList.rows[0][2]);
console.log(userList.headers[3], ":", userList.rows[0][3]);
console.log(userList.headers[4], ":", userList.rows[0][4]);
```

<p tit= "Output" ></p> 
 
```bash
username : Tester
create : 1721974206
graphPrivileges : {"Ad_Click":["FIND_EDGE","FIND_NODE"],"DFS_EG":["UPDATE","INSERT"]}
systemPrivileges : ["MOUNT_GRAPH"]
propertyPrivileges : {"node":{"read":[],"write":[["miniCircle","account","name"]],"deny":[]},"edge":{"read":[],"write":[],"deny":[]}} 
```

### Stats

A `Stats` object has the following fields:

| <div table-width="22">Field</div> | <div table-width="19">Type</div> | Description |
| ---- | ---- | ---- |  
| `cpuUsage` | string | CPU usage in percentage |
| `memUsage` | string | Memory usage in megabytes |
| `expiredDate` | string | Expiration date of the license |
| `cpuCores` | string | Number of CPU cores |
| `company` | string | Company name |
| `serverType` | string | Server type |
| `version` | string | Version of the server | 

<p tit= "TypeScript" ></p> 
 
```ts  
let resp = await conn.stats();
console.log("CPU usage:", resp.data.cpuUsage, "%");
console.log("Memory usage:", resp.data.memUsage);
```

<p tit= "Output" ></p> 
 
```bash
CPU usage: 15.209929 %
Memory usage: 10418.183594
```

### Process

A `Process` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="15">Type</div> | Description |
| ---- | ---- | ---- |  
| `process_id` | string | Process ID |
| `process_uql` | string | The UQL run with the process |
| `status` | string | Process status |
| `duration` | string | The duration in seconds the task has run so far |

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
  graphSetName: "amz",
};

let resp = await conn.uql("top()", requestConfig);
let processList = resp.data?.alias("_top");
console.log(processList.data.rows[0][0]);
```

<p tit= "Output" ></p> 
 
```bash
a_1_3259_2
```

### Task

A `Task` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="25">Type</div> | Description |
| ---- | ---- | ---- |  
| `param` | object | Algorithm parameters and their corresponding values |
| `task_info` | object | Task information including `task_id`, `algo_name`, `start_time`, `TASK_STATUS`, etc. |
| `error_msg` | string | Error message of the task |
| `result` | object | Algorithm result and statistics and their corresponding values |
| `return_type` | object | Result return type |

<p tit= "TypeScript" ></p> 
 
```ts
let requestConfig = <RequestType.RequestConfig>{
  useMaster: true,
  graphSetName: "miniCircle",
};

let resp = await conn.uql("show().task()", requestConfig);
let taskList = resp.data.alias("_task").asTasks();
console.log("Algo name:", taskList[0].task_info["algo_name"]);
console.log("Algo parameters:", taskList[0].param);
console.log("Result:", taskList[0].result);
```

<p tit= "Output" ></p> 
 
```bash
Algo name: louvain
Algo parameters: { phase1_loop_num: '20', min_modularity_increase: '0.001' }
Result: {
  community_count: '11',
  modularity: '0.532784',
  result_files: 'communityID'
}
```

### Table

A `Table` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `name` | string | Table name |
| `headers` | object | Table headers |
| `rows` | object | Table rows |

Methods on a `Table` object:

| <div table-width="15">Method</div> | <div table-width="20">Return</div> | Description |
| ---- | ---- | ---- | 
| `toKV()` | List\<Value> | Convert all rows of the table to a key-value list. |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql(
  "find().nodes() as n return table(n._id, n._uuid) as myTable limit 5",
  requestConfig
);
let tableInfo = resp.data.alias("myTable").asTable();
console.log("2nd row in table:", tableInfo.toKV()[1]);
```

<p tit= "Output" ></p> 
 
```bash
2nd row in table: { 'n._id': 'ULTIPA8000000000000002', 'n._uuid': '2' }
```

### Attr

An `Attr` object has the following fields:

| <div table-width="15">Field</div> | <div table-width="20">Type</div> | Description |
| ---- | ---- | ---- |  
| `alias` | string | Attr name |
| `type` | number | Attr type |
| `type_desc` | string | Attr type description |
| `values` | object | Attr rows |

<p tit= "TypeScript" ></p> 
 
```ts
let resp = await conn.uql(
  "find().nodes({@account}) as n return n.year limit 5",
  requestConfig
);
let myAttr = resp.data.alias("n.year").asAttrs();
console.log(myAttr.values);
```

<p tit= "Output" ></p> 
 
```bash
[ 1978, 1989, 1982, 2007, 1973 ]
```
null
