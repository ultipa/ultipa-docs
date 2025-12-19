# Query the Database

## Querying Methods

After <a target="_blank" href="/docs/drivers/nodejs-connect">connecting to the database</a>, you can use the driver's `gql()` or `uql()` method to execute GQL or UQL queries to fully interact with your database.

> **GQL** (ISO-standard Graph Query Language) and **UQL** (Ultipa’s proprietary query language) can both operate the database. You don’t need to be an expert in GQL or UQL to use the driver, but having a basic understanding will make it easier. To learn more, see <a target="_blank" href="/docs/quick-start/what-is-gql">GQL Quick Start</a>, <a target="_blank" href="/docs/gql">GQL documentation</a>, or <a target="_blank" href="/docs/uql">UQL documentation</a>.

| <div table-width="10">Method</div> | Parameters | <div table-width="14">Returns</div> |
| -- | -- | -- |
| `gql()` | <ul><li><code>gql: string</code>: The GQL query to be executed.</li><li><code>config?: RequestConfig</code>: Request configuration.</li></ul> | `Response` |
| `uql()` | <ul><li><code>uql: string</code>: The UQL query to be executed.</li><li><code>config?: RequestConfig</code>: Request configuration.</li></ul> | `Response` |

### Request Configuration

`RequestConfig` includes the following fields:

| <div table-width="18">Field</div> | <div table-width="10">Type</div> | <div table-width="8">Default</div> | Description |
|  ----  | ----  | ----  | ---- |
| `graph` | string | / | Name of the graph to use. If not specified, the graph defined in `UltipaConfig.defaultGraph` will be used. |
| `timeout` | number | / | Request timeout threshold (in seconds); it overwrites the `UltipaConfig.timeout`. |
| `host` | string | / | Specifies a host in a database cluster to execute the request. |
| `thread` | number | / | Number of threads for the request. |
| `timezone` | string | / | Name of the timezone, e.g., `Europe/Paris`. Defaults to the local timezone if not specified. |
| `timezoneOffset` | string | / | The offset from UTC, specified in the format `±<hh>:<mm>` or `±<hh><mm>` (e.g., `+02:00`, `-0430`). If both `timezone` and `timezoneOffset` are provided, `timezoneOffset` takes precedence. |

### Graph Selection

Since each Ultipa database instance can host multiple graphs, **most queries—including CRUD operations—require specifying the target graph.**

There are two ways to specify the graph for a request:

1. **Default graph at connection:** When connecting to the database, you can optionally set a default graph using `UltipaConfig.defaultGraph`.
2. **Per-Request Graph:** For a specific query, set `RequestConfig.graph` to select the graph. This overrides any `UltipaConfig.defaultGraph`.

## Create a Graph

To create a new graph in the database:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);
  
  // Creates a new open graph named 'g1'
  let response = await driver.gql("CREATE GRAPH g1 ANY")
  console.log(response.status?.message)
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
SUCCESS
```

## Insert Nodes and Edges

To insert nodes and edges into a graph:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";

async function sdkUsage() {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>",
    defaultGraph: "g1" // Sets the default graph to 'g1'
  };

  const driver = new UltipaDriver(ultipaConfig);

  // Inserts nodes and edges into graph the 'g1'
  let response = await driver.gql(`INSERT 
    (u1:User {_id: 'U1', name: 'rowlock'}),
    (u2:User {_id: 'U2', name: 'Brainy'}),
    (u3:User {_id: 'U3', name: 'purplechalk'}),
    (u4:User {_id: 'U4', name: 'mochaeach'}),
    (u5:User {_id: 'U5', name: 'lionbower'}),
    (u1)-[:Follows {createdOn: DATE('2024-01-05')}]->(u2),
    (u4)-[:Follows {createdOn: DATE('2024-02-10')}]->(u2),
    (u2)-[:Follows {createdOn: DATE('2024-02-01')}]->(u3),
    (u3)-[:Follows {createdOn: DATE('2024-05-03')}]->(u5)`);
  console.log(response.status?.message);
}

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
SUCCESS
```

## Update Nodes and Edges

To update a node's property value in a graph:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { RequestConfig } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

async function sdkUsage() {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>",
  };

  const driver = new UltipaDriver(ultipaConfig);

  // Updates name of the user U1 in the graph 'g1'
  const requestConfig: RequestConfig = { graph: "g1" };

  let response = await driver.gql("MATCH (n:User {_id: 'U1'}) SET n.name = 'RowLock99' RETURN n", requestConfig);
  const nodes = response.alias("n").asNodes();
  for (const node of nodes) {
    console.log(node);
  }
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
Node {
  uuid: '15276212135063977986',
  id: 'U1',
  schema: 'User',
  values: { name: 'RowLock99' }
}
```

## Delete Nodes and Edges

To delete an edge from a graph:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { RequestConfig } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

async function sdkUsage() {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>",
  };

  const driver = new UltipaDriver(ultipaConfig);

  // Deletes the edge between users U3 and U5 in the graph 'g1'
  const requestConfig: RequestConfig = { graph: "g1" };
  let response = await driver.gql("MATCH ({_id: 'U1'})-[e]-({_id: 'U5'}) DELETE e", requestConfig);
  console.log(response.status?.message)
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
SUCCESS
```

## Retrieve Nodes

To retrieve nodes from a graph:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { RequestConfig } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);
  
  // Retrieves 3 User nodes from the graph 'g1'
  const requestConfig: RequestConfig = { graph: "g1" }; 
  let response = await driver.gql("MATCH (u:User) RETURN u LIMIT 3", requestConfig);
  const nodes = response.alias("u").asNodes();
  for (const node of nodes) {
    console.log(node)
  };
};

sdkUsage().catch(console.error);
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
Node {
  uuid: '14771808976798482436',
  id: 'U5',
  schema: 'User',
  values: { name: 'lionbower' }
}
```

## Retrieve Edges

To retrieve edges from a graph:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { RequestConfig } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);
  
  // Retrieves all incoming Follows edges of the user U2 from the graph 'g1'
  const requestConfig: RequestConfig = { graph: "g1" };
  let response = await driver.gql("MATCH (:User {_id: 'U2'})<-[e:Follows]-() RETURN e", requestConfig);
  const edges = response.alias("e").asEdges();
  for (const edge of edges) {
    console.log(edge)
  };
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
Edge {
  uuid: '1',
  fromUuid: '15276212135063977986',
  toUuid: '7926337543195328514',
  from: 'U1',
  to: 'U2',
  schema: 'Follows',
  values: { createdOn: '2024-01-05' }
}
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

## Retrieve Paths

To retrieve paths from a graph:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { RequestConfig } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);
  
  // Retrieves 1-step paths from user U1 in the graph 'g1'
  const requestConfig: RequestConfig = { graph: "g1" }; 
  let response = await driver.gql(`
    MATCH p = (u)-[]-()
    WHERE u._id = "U1"
    RETURN p`, requestConfig);
  const graph = response.alias("p").asGraph();
  for (const path of graph.paths ?? []) {
    console.log(path)
  };
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
Path {
  nodeUuids: [ '15276212135063977986', '7926337543195328514' ],
  edgeUuids: [ '1' ],
  nodes: Map(2) {
    '15276212135063977986' => Node {
      uuid: '15276212135063977986',
      id: 'U1',
      schema: 'User',
      values: [Object]
    },
    '7926337543195328514' => Node {
      uuid: '7926337543195328514',
      id: 'U2',
      schema: 'User',
      values: [Object]
    }
  },
  edges: Map(1) {
    '1' => Edge {
      uuid: '1',
      fromUuid: '15276212135063977986',
      toUuid: '7926337543195328514',
      from: 'U1',
      to: 'U2',
      schema: 'Follows',
      values: [Object]
    }
  }
}
```

## Streaming Return

To efficiently process large query results without loading them entirely into memory, use the streaming methods `gqlStream()` and `uqlStream()`, which deliver results incrementally.

| <div table-width="16">Method</div> | Parameters | <div table-width="12">Returns</div> |
| -- | -- | -- |
| `gqlStream()` | <ul><li><code>gql: string</code>: The GQL query to be executed.</li><li><code>cb: RequestType.QueryResponseListener</code>: Listener for the streaming process.</li><li><code>config?: RequestConfig</code>: Request configuration.</li></ul> | void |
| `uqlStream()` | <ul><li><code>uql: string</code>: The UQL query to be executed.</li><li><code>cb: RequestType.QueryResponseListener</code>: Listener for the streaming process.</li><li><code>config?: RequestConfig</code>: Request configuration.</li></ul> | void |

To stream nodes from a large graph:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { RequestConfig } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);
  
  // Retrieves all Account nodes from the graph 'amz'
  const requestConfig: RequestConfig = { graph: "amz" };
  let count = 0;
  driver.gqlStream(
    "MATCH (n:Account) RETURN n",
    {
      onStart: () => {
        console.log("Stream started.");
      },
      onData: async (res) => {
        const nodes = res.alias("n")?.asNodes();
        if (nodes) {
          for (const node of nodes) {
            console.log(node.id)
          }
        }
        count += nodes?.length || 0;
        console.log("Node count so far:", count);
      },
      onEnd: () => {
        console.log("Stream ended.");
      },
      onError: (err) => {
        console.error(err);
      },
    },
    requestConfig
  );
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
Stream started.
ULTIPA8000000000000426
ULTIPA8000000000000439
...
Node count so far: 1024
ULTIPA80000000000003FB
ULTIPA8000000000000431
...
Node count so far: 2048
ULTIPA800000000000041A
ULTIPA8000000000000417
...
...
...
ULTIPA8000000000000403
Node count so far: 96114145
Stream ended.
```
