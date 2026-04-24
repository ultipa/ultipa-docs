# Quick Start

The GQLDB Node.js driver is a gRPC-based client library for interacting with GQLDB graph database. It requires **Node.js version 18.0.0 or later**.

## Install the Driver

Install the package using npm:

```bash
npm install @ultipa-graph/ultipa-driver
```

> Check <a href="https://www.npmjs.com/package/@ultipa-graph/ultipa-driver" target="_blank">npm</a> for the latest version. To install a specific version: `npm install @ultipa-graph/ultipa-driver@6.0.6`

## Connect to Database

You need a running GQLDB instance to use the driver. Create a client and authenticate:

```typescript
import { GqldbClient, createConfig } from '@ultipa-graph/ultipa-driver';

async function main() {
  // Create configuration
  const config = createConfig({
    hosts: ['localhost:9000'],
    defaultGraph: 'myGraph'
  });

  // Create client
  const client = new GqldbClient(config);

  try {
    // Authenticate
    const session = await client.login('username', 'password');
    console.log('Logged in successfully');

    // Test connection with ping
    const latency = await client.ping();
    console.log(`Ping latency: ${latency}ns`);

  } finally {
    // Always close the client when done
    await client.close();
  }
}

main().catch(console.error);
```

## Query the Database

Use the `gql()` method to execute GQL queries:

```typescript
import { GqldbClient, createConfig } from '@ultipa-graph/ultipa-driver';

async function main() {
  const config = createConfig({
    hosts: ['localhost:9000'],
    defaultGraph: 'myGraph'
  });

  const client = new GqldbClient(config);

  try {
    await client.login('username', 'password');

    // Execute a GQL query
    const response = await client.gql('MATCH (n) RETURN n LIMIT 10');

    // Process results
    console.log(`Columns: ${response.columns}`);
    console.log(`Row count: ${response.rowCount}`);

    for (const row of response.rows) {
      console.log(row.get(0));
    }

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```

## Create a Graph

Create a new graph in the database:

```typescript
import { GqldbClient, createConfig, GraphType } from '@ultipa-graph/ultipa-driver';

async function main() {
  const config = createConfig({
    hosts: ['localhost:9000']
  });

  const client = new GqldbClient(config);

  try {
    await client.login('username', 'password');

    // Create an open (schema-less) graph
    await client.createGraph('myNewGraph', GraphType.OPEN, 'My graph description');
    console.log('Graph created successfully');

    // Use the graph
    await client.useGraph('myNewGraph');

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```

## Insert Data

Insert nodes and edges into a graph:

```typescript
import { GqldbClient, createConfig } from '@ultipa-graph/ultipa-driver';

async function main() {
  const config = createConfig({
    hosts: ['localhost:9000'],
    defaultGraph: 'myGraph'
  });

  const client = new GqldbClient(config);

  try {
    await client.login('username', 'password');

    // Insert nodes
    const nodeResult = await client.insertNodes('myGraph', [
      { id: 'user1', labels: ['User'], properties: { name: 'Alice', age: 30 } },
      { id: 'user2', labels: ['User'], properties: { name: 'Bob', age: 25 } }
    ]);
    console.log(`Inserted ${nodeResult.nodeCount} nodes`);

    // Insert edges
    const edgeResult = await client.insertEdges('myGraph', [
      { label: 'Follows', fromNodeId: 'user1', toNodeId: 'user2', properties: {} }
    ]);
    console.log(`Inserted ${edgeResult.edgeCount} edges`);

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```

## Process Query Results

The `gql()` method returns a `Response` object with methods to extract different data types:

```typescript
import { GqldbClient, createConfig } from '@ultipa-graph/ultipa-driver';

async function main() {
  const config = createConfig({
    hosts: ['localhost:9000'],
    defaultGraph: 'myGraph'
  });

  const client = new GqldbClient(config);

  try {
    await client.login('username', 'password');

    // Query nodes
    const response = await client.gql('MATCH (u:User) RETURN u LIMIT 5');

    // Extract as Node objects
    const { nodes, schemas } = response.alias('u').asNodes();
    for (const node of nodes) {
      console.log(`Node: ${node.id}, Labels: ${node.labels}, Properties:`, node.properties);
    }

    // Or convert to plain objects
    const objects = response.toObjects();
    console.log(objects);

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```

## Use Transactions

Execute multiple operations atomically:

```typescript
import { GqldbClient, createConfig } from '@ultipa-graph/ultipa-driver';

async function main() {
  const config = createConfig({
    hosts: ['localhost:9000']
  });

  const client = new GqldbClient(config);

  try {
    await client.login('username', 'password');

    // Use withTransaction for automatic commit/rollback
    const result = await client.withTransaction('myGraph', async (txId) => {
      await client.gql('INSERT (n:User {_id: "u1", name: "Alice"})', { transactionId: txId });
      await client.gql('INSERT (n:User {_id: "u2", name: "Bob"})', { transactionId: txId });
      return 'Transaction completed';
    });

    console.log(result);

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```

## Next Steps

- <a href="/docs/drivers/nodejs-configuration">Configuration</a> - Learn about all configuration options
- <a href="/docs/drivers/nodejs-connection-and-session">Connection and Session</a> - Detailed connection management
- <a href="/docs/drivers/nodejs-executing-queries">Executing Queries</a> - Query methods and options
- <a href="/docs/drivers/nodejs-response-processing">Response Processing</a> - Working with query results
