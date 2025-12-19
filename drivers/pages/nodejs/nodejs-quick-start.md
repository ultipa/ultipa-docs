# Node.js

## Quick Start

The Ultipa Node.js driver is a JavaScript library that allows you to interact with Ultipa from any Node.js environment. It requires **Node.js version 12.22.12 or later**.

## Install the Driver

You can install the latest package from <a target = "_blank" href="https://www.npmjs.com/package/@ultipa-graph/ultipa-driver">npm registry</a>:

```bash
npm install @ultipa-graph/ultipa-driver
```

## Connect to Database

You need a running Ultipa database to use the driver. The easiest way to get an instance is via <a target="_blank" href="http://cloud.ultipa.com/">Ultipa Cloud</a> (free trial available), or you can use an on-premises deployment if you already have one.

Creates a connection and tests the connection:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);
  
  // Tests the connection
  const isSuccess = await driver.test();
  console.log(`Connection succeeds: ${isSuccess}`);
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
Connection succeeds: true
```

<a target="_blank" href="/docs/drivers/nodejs-connect">More info on database connection →</a>

## Query the Database

**GQL** is the international standardized query language for graph databases. You can use the driver's `gql()` method to send GQL queries and fully operate the database. If you're new to GQL, check out the <a target="_blank" href="/docs/quick-start/what-is-gql">GQL Quick Start</a> or the <a target="_blank" href="/docs/gql">GQL documentation</a> for a detailed orientation.

<a target="_blank" href="/docs/drivers/nodejs-query">More info on querying the database →</a>

### Create a Graph

To create a new graph in the database:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
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

### Insert Nodes and Edges

To insert nodes and edges into a graph:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";

async function sdkUsage() {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
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

### Retrieve Nodes

To retrieve nodes from a graph:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { RequestConfig } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>",
    defaultGraph: "amz" // Optional; sets the default graph as 'amz'
  };

  const driver = new UltipaDriver(ultipaConfig);
  
  // Retrieves 3 User nodes from the graph 'g1'
  const requestConfig: RequestConfig = {
    graph: "g1" // Sets the graph for the specific request as 'g1'
  }; 
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
  values: { name: 'mochaeach', gender: "male" }
}
Node {
  uuid: '7926337543195328514',
  id: 'U2',
  schema: 'User',
  values: { name: 'Brainy', gender: "female"  }
}
Node {
  uuid: '14771808976798482436',
  id: 'U5',
  schema: 'User',
  values: { name: 'lionbower', gender: "male"  }
}
```

## Process Query Results

The driver's `gql()` method returns a `Response` containing the raw query results from the database and execution metadata. To use the query results in your application, you need to **extract** and **convert** them into a usable data structure.

The above node retrieval example demonstrates this by using the `alias()` method to extract the query results and the `asNodes()` method to convert them into a list of `Node`s:

```ts
// Retrieves 3 User nodes from the graph 'g1'
const requestConfig: RequestConfig = {
  graph: "g1" // Sets the graph for the specific request as 'g1'
}; 
let response = await driver.gql("MATCH (u:User) RETURN u LIMIT 3", requestConfig);
const nodes = response.alias("u").asNodes();
for (const node of nodes) {
  console.log(node)
};
```

The conversion method you choose depends on the type of query results you receive, such as nodes, edges, paths, property values, etc. For a complete list of available conversion methods and examples, refer to <a target="_blank" href="/docs/drivers/nodejs-query-results">here</a>.

## Convenience Methods

In addition to the `gql()` method for executing custom GQL queries, the driver provides a suite of **convenience methods** to simplify common database operations. These methods eliminate the need to write full queries for tasks in the following categories:

- <a target="_blank" href="/docs/drivers/nodejs-graph">Graph</a>: Show, create, alter, and delete graphs in a database instance.
- <a target="_blank" href="/docs/drivers/nodejs-schema-and-property">Schema and Property</a>: Define and modify node and edge schemas and their properties.
- <a target="_blank" href="/docs/drivers/nodejs-data-insertion">Data Insertion</a>: Insert nodes and edges into a graph efficiently.
- <a target="_blank" href="/docs/drivers/nodejs-query-acceleration">Query Acceleration</a>: Manage indexes and full-text indexes to optimize query performance.
- <a target="_blank" href="/docs/drivers/nodejs-hdc-graph-and-algorithm">HDC Graph and Algorithm</a>: Manage HDC graphs and run algorithms on them.
- <a target="_blank" href="/docs/drivers/nodejs-process-and-job">Process and Job</a>: Monitor running processes and manage backend jobs.
- <a target="_blank" href="/docs/drivers/nodejs-access-control">Access Control</a>: Configure user privileges and policies (roles).
- <a target="_blank" href="/docs/drivers/nodejs-data-export">Data Export</a>: Export nodes and edges from a graph.

For example, the `showGraph()` retrieves all graphs in the database, it returns a list of `GraphSet`s:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);
  
  // Retrieves all graphs in the database
  const graphs = await driver.showGraph();
  for (const graph of graphs) {
    console.log(graph.name)
  }
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
g1
miniCircle
amz
```

For example, the `insertNodes()` method allows you to insert nodes into a graph by providing the target schema and a list of `Node`s:

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import type { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { InsertRequestConfig } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);
  
  // Inserts two User nodes into the graph 'g1'

  const insertRequestConfig: InsertRequestConfig = { graph: "g1" };

  const node1 = {
    id: "U6",
    values: {
      name: "Alice",
      age: 28
    },
  };
  const node2 = {
    id: "U7",
    values: {
      name: "Quars"
    },
  };
  const nodes = [node1, node2]

  let response = await driver.insertNodes("User", nodes, insertRequestConfig);
  console.log(response.status?.message);
};

sdkUsage().catch(console.error);
```

<p tit="Output"></p> 

```
SUCCESS
```
