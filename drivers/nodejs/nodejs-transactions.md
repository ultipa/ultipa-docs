# Transactions

The GQLDB Node.js driver supports ACID transactions, allowing you to execute multiple operations atomically with automatic rollback on failure.

## Transaction Methods

| Method | Description |
|--------|-------------|
| `beginTransaction()` | Start a new transaction |
| `commit()` | Commit a transaction |
| `rollback()` | Rollback a transaction |
| `listTransactions()` | List active transactions |
| `withTransaction()` | Execute a function within a transaction (auto commit/rollback) |

## Starting a Transaction

### beginTransaction()

Start a new transaction on a specific graph:

```typescript
import { GqldbClient, Transaction } from '@ultipa-graph/ultipa-driver';

async function startTransaction(client: GqldbClient) {
  // Start a read-write transaction
  const tx: Transaction = await client.beginTransaction('myGraph');
  console.log('Transaction ID:', tx.id);

  // Start a read-only transaction
  const readOnlyTx = await client.beginTransaction('myGraph', true);

  // Start with custom timeout (in milliseconds)
  const timedTx = await client.beginTransaction('myGraph', false, 60000);
}
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `graphName` | `string` | required | Target graph for the transaction |
| `readOnly` | `boolean` | `false` | If true, transaction is read-only |
| `timeout` | `number` | `0` | Transaction timeout in milliseconds (0 = default) |

## Committing a Transaction

### commit()

Commit a transaction to make changes permanent:

```typescript
async function commitExample(client: GqldbClient) {
  const tx = await client.beginTransaction('myGraph');

  try {
    // Execute queries within the transaction
    await client.gql(
      'INSERT (n:User {_id: "u1", name: "Alice"})',
      { transactionId: tx.id }
    );

    // Commit the transaction
    const success = await client.commit(tx.id);
    if (success) {
      console.log('Transaction committed successfully');
    }
  } catch (error) {
    await client.rollback(tx.id);
    throw error;
  }
}
```

## Rolling Back a Transaction

### rollback()

Rollback a transaction to undo all changes:

```typescript
async function rollbackExample(client: GqldbClient) {
  const tx = await client.beginTransaction('myGraph');

  try {
    await client.gql(
      'INSERT (n:User {_id: "u1", name: "Alice"})',
      { transactionId: tx.id }
    );

    // Something went wrong, rollback
    throw new Error('Simulated error');

  } catch (error) {
    const success = await client.rollback(tx.id);
    if (success) {
      console.log('Transaction rolled back');
    }
    throw error;
  }
}
```

## Automatic Transaction Management

### withTransaction()

The recommended way to use transactions. Automatically commits on success and rolls back on error:

```typescript
async function withTransactionExample(client: GqldbClient) {
  const result = await client.withTransaction('myGraph', async (txId) => {
    // All operations use the same transaction
    await client.gql(
      'INSERT (a:User {_id: "u1", name: "Alice"})',
      { transactionId: txId }
    );

    await client.gql(
      'INSERT (b:User {_id: "u2", name: "Bob"})',
      { transactionId: txId }
    );

    await client.gql(
      'INSERT (:User {_id: "u1"})-[:Knows]->(:User {_id: "u2"})',
      { transactionId: txId }
    );

    // Return a value from the transaction
    return 'Users and relationship created';
  });

  console.log(result); // "Users and relationship created"
}
```

### Read-Only Transactions

```typescript
async function readOnlyTransaction(client: GqldbClient) {
  const count = await client.withTransaction(
    'myGraph',
    async (txId) => {
      const response = await client.gql(
        'MATCH (n:User) RETURN count(n)',
        { transactionId: txId }
      );
      return response.singleNumber();
    },
    true  // read-only
  );

  console.log('User count:', count);
}
```

## Listing Active Transactions

### listTransactions()

Get information about active transactions:

```typescript
import { TransactionInfo } from '@ultipa-graph/ultipa-driver';

async function listActiveTransactions(client: GqldbClient) {
  const transactions: TransactionInfo[] = await client.listTransactions();

  console.log(`Active transactions: ${transactions.length}`);
  for (const tx of transactions) {
    console.log(`- ID: ${tx.transactionId}, Graph: ${tx.graphName}, ReadOnly: ${tx.readOnly}`);
  }
}
```

### TransactionInfo Interface

```typescript
interface TransactionInfo {
  transactionId: number;
  sessionId: number;
  graphName: string;
  readOnly: boolean;
  createdAt: number;
  durationMs: number;
  internalTxId: string;
}
```

## Transaction Isolation

Queries within a transaction see a consistent snapshot:

```typescript
async function isolationExample(client: GqldbClient) {
  await client.withTransaction('myGraph', async (txId) => {
    // Insert a node
    await client.gql(
      'INSERT (n:User {_id: "temp", name: "Temporary"})',
      { transactionId: txId }
    );

    // Query within the same transaction sees the new node
    const response = await client.gql(
      'MATCH (u:User {_id: "temp"}) RETURN u',
      { transactionId: txId }
    );
    console.log('Found in transaction:', response.rowCount); // 1

    // Rollback by throwing an error
    throw new Error('Rollback');
  }).catch(() => {});

  // After rollback, node doesn't exist
  const response = await client.gql(
    'MATCH (u:User {_id: "temp"}) RETURN u',
    { graphName: 'myGraph' }
  );
  console.log('Found after rollback:', response.rowCount); // 0
}
```

## Error Handling

```typescript
import {
  NoTransactionError,
  TransactionFailedError,
  TransactionNotFoundError,
  TransactionAlreadyOpenError
} from '@ultipa-graph/ultipa-driver';

async function safeTransaction(client: GqldbClient) {
  try {
    await client.withTransaction('myGraph', async (txId) => {
      // Transaction operations
    });
  } catch (error) {
    if (error instanceof TransactionFailedError) {
      console.error('Transaction failed:', error.message);
    } else if (error instanceof TransactionNotFoundError) {
      console.error('Transaction not found (may have timed out)');
    } else {
      throw error;
    }
  }
}
```

## Best Practices

### Keep Transactions Short

```typescript
// Good: Short transaction
await client.withTransaction('myGraph', async (txId) => {
  await client.gql('INSERT ...', { transactionId: txId });
  await client.gql('INSERT ...', { transactionId: txId });
});

// Avoid: Long-running transactions with external calls
await client.withTransaction('myGraph', async (txId) => {
  await client.gql('INSERT ...', { transactionId: txId });
  await fetchExternalData(); // Don't do this in a transaction
  await client.gql('INSERT ...', { transactionId: txId });
});
```

### Use Read-Only When Possible

```typescript
// Use read-only for queries that don't modify data
const data = await client.withTransaction(
  'myGraph',
  async (txId) => {
    return client.gql('MATCH (n) RETURN n', { transactionId: txId });
  },
  true  // read-only for better performance
);
```

### Handle Timeouts

```typescript
async function transactionWithTimeout(client: GqldbClient) {
  // Start transaction with 30-second timeout
  const tx = await client.beginTransaction('myGraph', false, 30000);

  try {
    // Complete operations within timeout
    await client.gql('...', { transactionId: tx.id });
    await client.commit(tx.id);
  } catch (error) {
    // Transaction may have timed out
    try {
      await client.rollback(tx.id);
    } catch (rollbackError) {
      // Transaction already expired
    }
    throw error;
  }
}
```

## Complete Example

```typescript
import { GqldbClient, createConfig } from '@ultipa-graph/ultipa-driver';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['localhost:9000']
  }));

  try {
    await client.login('admin', 'password');

    // Create a graph for testing
    await client.createGraph('txDemo');
    await client.useGraph('txDemo');

    // Use withTransaction for automatic management
    await client.withTransaction('txDemo', async (txId) => {
      // Insert users
      await client.gql(
        'INSERT (a:User {_id: "alice", name: "Alice", balance: 100})',
        { transactionId: txId }
      );
      await client.gql(
        'INSERT (b:User {_id: "bob", name: "Bob", balance: 50})',
        { transactionId: txId }
      );

      console.log('Users created');
    });

    // Transfer money between users (atomic operation)
    await client.withTransaction('txDemo', async (txId) => {
      // Debit Alice
      await client.gql(
        'MATCH (a:User {_id: "alice"}) SET a.balance = a.balance - 25',
        { transactionId: txId }
      );

      // Credit Bob
      await client.gql(
        'MATCH (b:User {_id: "bob"}) SET b.balance = b.balance + 25',
        { transactionId: txId }
      );

      console.log('Transfer completed');
    });

    // Verify balances
    const response = await client.gql(
      'MATCH (u:User) RETURN u._id AS id, u.balance AS balance'
    );
    console.log('Final balances:');
    for (const row of response) {
      console.log(`  ${row.get(0)}: ${row.get(1)}`);
    }

    // Clean up
    await client.dropGraph('txDemo');

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```
