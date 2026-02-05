# Executing Queries

The GQLDB Node.js driver provides several methods for executing GQL queries and analyzing query execution.

## Query Methods

| Method | Description |
|--------|-------------|
| `gql()` | Execute a GQL query and return results |
| `gqlStream()` | Execute a query with streaming results |
| `explain()` | Return the execution plan for a query |
| `profile()` | Execute a query with profiling statistics |

## Basic Query Execution

### gql()

Execute a GQL query and get the complete result:

```typescript
import { GqldbClient, createConfig } from 'gqldb-nodejs';

async function queryExample(client: GqldbClient) {
  // Simple query
  const response = await client.gql('MATCH (n:User) RETURN n LIMIT 10');

  console.log('Columns:', response.columns);
  console.log('Row count:', response.rowCount);
  console.log('Has more:', response.hasMore);

  // Iterate over rows
  for (const row of response.rows) {
    console.log(row.get(0));
  }
}
```

## Query Configuration

The `QueryConfig` interface allows you to customize query execution:

```typescript
interface QueryConfig {
  graphName?: string;      // Target graph (overrides default)
  parameters?: Record<string, any>;  // Query parameters
  transactionId?: number;  // Transaction ID for transactional queries
  timeout?: number;        // Query timeout in milliseconds
  readOnly?: boolean;      // Mark query as read-only
}
```

### Specifying Graph

```typescript
// Query a specific graph
const response = await client.gql(
  'MATCH (n) RETURN n LIMIT 5',
  { graphName: 'myGraph' }
);
```

### Query Parameters

Use parameters to safely pass values into queries:

```typescript
// Using parameters
const response = await client.gql(
  'MATCH (u:User) WHERE u.age > $minAge RETURN u',
  {
    parameters: {
      minAge: 25
    }
  }
);
```

### Query Timeout

Set a custom timeout for long-running queries:

```typescript
// 5 minute timeout
const response = await client.gql(
  'MATCH p = (a)-[*1..10]->(b) RETURN p',
  { timeout: 300000 }
);
```

### Read-Only Queries

Mark queries as read-only for optimization:

```typescript
const response = await client.gql(
  'MATCH (n) RETURN count(n)',
  { readOnly: true }
);
```

## Streaming Results

### gqlStream()

For large result sets, use streaming to process results incrementally:

```typescript
async function streamExample(client: GqldbClient) {
  let totalRows = 0;

  await client.gqlStream(
    'MATCH (n) RETURN n',
    { graphName: 'largeGraph' },
    (response) => {
      // Called for each batch of results
      totalRows += response.rows.length;
      console.log(`Received ${response.rows.length} rows`);

      for (const row of response.rows) {
        // Process each row
        console.log(row.get(0));
      }
    }
  );

  console.log(`Total rows processed: ${totalRows}`);
}
```

## Query Analysis

### explain()

Get the execution plan without running the query:

```typescript
async function explainQuery(client: GqldbClient) {
  const plan = await client.explain(
    'MATCH (a:User)-[:Follows]->(b:User) RETURN a, b',
    { graphName: 'socialGraph' }
  );

  console.log('Execution Plan:');
  console.log(plan);
}
```

The execution plan helps understand how the query will be executed and identify potential optimizations.

### profile()

Execute a query and get detailed profiling statistics:

```typescript
async function profileQuery(client: GqldbClient) {
  const stats = await client.profile(
    'MATCH (a:User)-[:Follows]->(b:User) RETURN a, b LIMIT 100',
    { graphName: 'socialGraph' }
  );

  console.log('Profile Statistics:');
  console.log(stats);
}
```

Profiling provides metrics like:
- Execution time per operation
- Number of rows processed
- Memory usage
- Index usage

## Working with Results

The `gql()` method returns a `Response` object. See <a href="/docs/drivers/nodejs-response-processing">Response Processing</a> for details on extracting data.

### Quick Result Access

```typescript
// Get first row
const firstRow = response.first();

// Get last row
const lastRow = response.last();

// Check if empty
if (response.isEmpty()) {
  console.log('No results');
}

// Get single value from single-row, single-column result
const count = await client.gql('MATCH (n) RETURN count(n)');
console.log('Total:', count.singleNumber());
```

### Convert to Objects

```typescript
const response = await client.gql('MATCH (u:User) RETURN u.name AS name, u.age AS age');
const users = response.toObjects();
// [{ name: 'Alice', age: 30 }, { name: 'Bob', age: 25 }]
```

### Extract Graph Elements

```typescript
// Get nodes
const nodeResponse = await client.gql('MATCH (n:User) RETURN n');
const { nodes, schemas } = nodeResponse.asNodes();

// Get edges
const edgeResponse = await client.gql('MATCH ()-[e:Follows]->() RETURN e');
const { edges } = edgeResponse.asEdges();

// Get paths
const pathResponse = await client.gql('MATCH p = (a)-[*]->(b) RETURN p');
const paths = pathResponse.asPaths();
```

## Transactional Queries

Execute queries within a transaction:

```typescript
async function transactionalQuery(client: GqldbClient) {
  const tx = await client.beginTransaction('myGraph');

  try {
    // Execute queries in transaction
    await client.gql(
      'INSERT (n:User {_id: "u1", name: "Alice"})',
      { transactionId: tx.id }
    );

    await client.gql(
      'INSERT (n:User {_id: "u2", name: "Bob"})',
      { transactionId: tx.id }
    );

    // Read within transaction sees uncommitted changes
    const response = await client.gql(
      'MATCH (u:User) RETURN count(u)',
      { transactionId: tx.id }
    );

    await client.commit(tx.id);
    console.log('Transaction committed');

  } catch (error) {
    await client.rollback(tx.id);
    console.error('Transaction rolled back:', error.message);
  }
}
```

See <a href="/docs/drivers/nodejs-transactions">Transactions</a> for more details.

## Error Handling

```typescript
import {
  QueryFailedError,
  QueryTimeoutError,
  InvalidQueryError,
  EmptyQueryError,
  GraphNotFoundError
} from 'gqldb-nodejs';

async function safeQuery(client: GqldbClient, query: string) {
  try {
    return await client.gql(query);
  } catch (error) {
    if (error instanceof QueryTimeoutError) {
      console.error('Query timed out');
    } else if (error instanceof InvalidQueryError) {
      console.error('Invalid query syntax:', error.message);
    } else if (error instanceof EmptyQueryError) {
      console.error('Query string is empty');
    } else if (error instanceof GraphNotFoundError) {
      console.error('Graph does not exist');
    } else if (error instanceof QueryFailedError) {
      console.error('Query failed:', error.message);
    } else {
      throw error;
    }
    return null;
  }
}
```

## Complete Example

```typescript
import { GqldbClient, createConfig } from 'gqldb-nodejs';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['192.168.1.100:9000'],
    defaultGraph: 'socialNetwork'
  }));

  try {
    await client.login('admin', 'password');

    // Explain the query first
    const plan = await client.explain(
      'MATCH (a:User)-[:Follows]->(b:User) WHERE a.age > $minAge RETURN a, b'
    );
    console.log('Query Plan:', plan);

    // Execute with parameters
    const response = await client.gql(
      'MATCH (a:User)-[:Follows]->(b:User) WHERE a.age > $minAge RETURN a, b LIMIT 10',
      {
        parameters: { minAge: 25 },
        timeout: 30000,
        readOnly: true
      }
    );

    console.log(`Found ${response.rowCount} relationships`);

    // Process results
    for (const row of response) {
      const userA = row.get(0);
      const userB = row.get(1);
      console.log(`${userA.properties.name} follows ${userB.properties.name}`);
    }

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```
