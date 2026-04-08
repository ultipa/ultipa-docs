# Error Handling

The GQLDB Node.js driver provides a comprehensive set of error classes for handling different failure scenarios. All errors extend the base `GqldbError` class.

## Base Error Class

```typescript
import { GqldbError } from '@ultipa-graph/ultipa-driver';

class GqldbError extends Error {
  readonly code: number;
  readonly cause?: Error;
}
```

All GQLDB errors include:
- `message`: Human-readable error description
- `name`: Error class name
- `code`: Numeric error code
- `cause`: Original error that caused this error (if applicable)

## Error Categories

### Configuration Errors

| Error | Description |
|-------|-------------|
| `NoHostsError` | No hosts configured in the client |
| `InvalidTimeoutError` | Invalid timeout value specified |

```typescript
import { NoHostsError, InvalidTimeoutError } from '@ultipa-graph/ultipa-driver';

try {
  const config = createConfig({ hosts: [] });
} catch (error) {
  if (error instanceof NoHostsError) {
    console.error('You must configure at least one host');
  }
}
```

### Connection Errors

| Error | Description |
|-------|-------------|
| `NoConnectionError` | No connection available |
| `ConnectionClosedError` | Connection has been closed |
| `ConnectionFailedError` | Failed to establish connection |
| `AllHostsFailedError` | All configured hosts are unreachable |
| `HealthCheckFailedError` | Health check operation failed |

```typescript
import {
  ConnectionFailedError,
  AllHostsFailedError,
  HealthCheckFailedError
} from '@ultipa-graph/ultipa-driver';

async function connectWithRetry(client: GqldbClient, maxRetries: number) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await client.login('user', 'pass');
      return true;
    } catch (error) {
      if (error instanceof ConnectionFailedError) {
        console.log(`Connection attempt ${i + 1} failed, retrying...`);
        await sleep(1000 * (i + 1));  // Exponential backoff
      } else if (error instanceof AllHostsFailedError) {
        console.error('All hosts unreachable');
        throw error;
      } else {
        throw error;
      }
    }
  }
  return false;
}
```

### Session Errors

| Error | Description |
|-------|-------------|
| `NotLoggedInError` | Operation requires authentication |
| `LoginFailedError` | Login failed (wrong credentials) |
| `LogoutFailedError` | Logout operation failed |
| `SessionExpiredError` | Session has expired |
| `InvalidSessionError` | Session is invalid |

```typescript
import {
  NotLoggedInError,
  LoginFailedError,
  SessionExpiredError
} from '@ultipa-graph/ultipa-driver';

async function ensureLoggedIn(client: GqldbClient) {
  try {
    await client.gql('MATCH (n) RETURN count(n)');
  } catch (error) {
    if (error instanceof NotLoggedInError || error instanceof SessionExpiredError) {
      console.log('Session expired, re-authenticating...');
      await client.login('user', 'pass');
    } else {
      throw error;
    }
  }
}
```

### Transaction Errors

| Error | Description |
|-------|-------------|
| `NoTransactionError` | No active transaction |
| `TransactionFailedError` | Transaction operation failed |
| `TransactionNotFoundError` | Transaction not found (may have timed out) |
| `TransactionAlreadyOpenError` | A transaction is already open |

```typescript
import {
  TransactionFailedError,
  TransactionNotFoundError
} from '@ultipa-graph/ultipa-driver';

async function safeTransaction(client: GqldbClient, fn: (txId: number) => Promise<void>) {
  try {
    await client.withTransaction('myGraph', fn);
  } catch (error) {
    if (error instanceof TransactionFailedError) {
      console.error('Transaction failed:', error.message);
    } else if (error instanceof TransactionNotFoundError) {
      console.error('Transaction timed out before completion');
    } else {
      throw error;
    }
  }
}
```

### Query Errors

| Error | Description |
|-------|-------------|
| `QueryFailedError` | Query execution failed |
| `QueryTimeoutError` | Query exceeded timeout |
| `InvalidQueryError` | Query syntax is invalid |
| `EmptyQueryError` | Query string is empty |

```typescript
import {
  QueryFailedError,
  QueryTimeoutError,
  InvalidQueryError,
  EmptyQueryError
} from '@ultipa-graph/ultipa-driver';

async function executeQuery(client: GqldbClient, query: string) {
  try {
    return await client.gql(query);
  } catch (error) {
    if (error instanceof EmptyQueryError) {
      console.error('Query cannot be empty');
    } else if (error instanceof InvalidQueryError) {
      console.error('Syntax error:', error.message);
    } else if (error instanceof QueryTimeoutError) {
      console.error('Query timed out - try adding LIMIT or optimizing');
    } else if (error instanceof QueryFailedError) {
      console.error('Query failed:', error.message);
    } else {
      throw error;
    }
    return null;
  }
}
```

### Graph Errors

| Error | Description |
|-------|-------------|
| `GraphNotFoundError` | Graph does not exist |
| `GraphExistsError` | Graph already exists |
| `CreateGraphFailedError` | Failed to create graph |
| `DropGraphFailedError` | Failed to drop graph |

```typescript
import {
  GraphNotFoundError,
  GraphExistsError,
  CreateGraphFailedError
} from '@ultipa-graph/ultipa-driver';

async function ensureGraph(client: GqldbClient, graphName: string) {
  try {
    await client.getGraphInfo(graphName);
    console.log(`Graph ${graphName} exists`);
  } catch (error) {
    if (error instanceof GraphNotFoundError) {
      try {
        await client.createGraph(graphName);
        console.log(`Created graph ${graphName}`);
      } catch (createError) {
        if (createError instanceof GraphExistsError) {
          // Race condition: another process created it
          console.log(`Graph ${graphName} was created by another process`);
        } else if (createError instanceof CreateGraphFailedError) {
          console.error('Failed to create graph:', createError.message);
          throw createError;
        }
      }
    } else {
      throw error;
    }
  }
}
```

### Data Errors

| Error | Description |
|-------|-------------|
| `InsertFailedError` | Insert operation failed |
| `DeleteFailedError` | Delete operation failed |
| `ExportFailedError` | Export operation failed |

```typescript
import { InsertFailedError, DeleteFailedError } from '@ultipa-graph/ultipa-driver';

async function safeInsert(client: GqldbClient, nodes: NodeData[]) {
  try {
    const result = await client.insertNodes('myGraph', nodes);
    return result;
  } catch (error) {
    if (error instanceof InsertFailedError) {
      console.error('Insert failed:', error.message);
      // Log the failed nodes for retry
      console.error('Failed nodes:', nodes.map(n => n.id));
    }
    throw error;
  }
}
```

### Type Errors

| Error | Description |
|-------|-------------|
| `InvalidTypeError` | Invalid type specified |
| `TypeConversionError` | Failed to convert type |
| `UnsupportedTypeError` | Type is not supported |

```typescript
import { TypeConversionError, UnsupportedTypeError } from '@ultipa-graph/ultipa-driver';

function processValue(row: Row, index: number) {
  try {
    return row.getNumber(index);
  } catch (error) {
    if (error instanceof TypeConversionError) {
      console.warn(`Value at ${index} is not a number, using string`);
      return row.getString(index);
    }
    throw error;
  }
}
```

## Error Handling Patterns

### Comprehensive Try-Catch

```typescript
import { GqldbError } from '@ultipa-graph/ultipa-driver';

async function handleAllErrors(client: GqldbClient) {
  try {
    await client.login('user', 'pass');
    await client.gql('MATCH (n) RETURN n');
  } catch (error) {
    if (error instanceof GqldbError) {
      // All driver errors
      console.error(`GQLDB Error [${error.name}]: ${error.message}`);
      if (error.cause) {
        console.error('Caused by:', error.cause);
      }
    } else if (error instanceof Error) {
      // Other JavaScript errors
      console.error('Unexpected error:', error.message);
    } else {
      console.error('Unknown error:', error);
    }
  }
}
```

### Error Recovery with Retry

```typescript
async function withRetry<T>(
  operation: () => Promise<T>,
  maxRetries: number = 3,
  retryableErrors: Array<new (...args: any[]) => GqldbError> = []
): Promise<T> {
  let lastError: Error | undefined;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      lastError = error as Error;

      const isRetryable = retryableErrors.some(
        ErrorClass => error instanceof ErrorClass
      );

      if (!isRetryable || attempt === maxRetries) {
        throw error;
      }

      console.log(`Attempt ${attempt} failed, retrying...`);
      await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
    }
  }

  throw lastError;
}

// Usage
import { ConnectionFailedError, QueryTimeoutError } from '@ultipa-graph/ultipa-driver';

const result = await withRetry(
  () => client.gql('MATCH (n) RETURN n LIMIT 100'),
  3,
  [ConnectionFailedError, QueryTimeoutError]
);
```

### Graceful Degradation

```typescript
async function getDataWithFallback(client: GqldbClient) {
  try {
    // Try the main query
    return await client.gql('MATCH (n:User) RETURN n');
  } catch (error) {
    if (error instanceof QueryTimeoutError) {
      // Fall back to a simpler query
      console.warn('Full query timed out, using limited query');
      return await client.gql('MATCH (n:User) RETURN n LIMIT 100');
    }
    throw error;
  }
}
```

### Cleanup on Error

```typescript
async function transactionWithCleanup(client: GqldbClient) {
  let tx: Transaction | undefined;

  try {
    tx = await client.beginTransaction('myGraph');

    await client.gql('INSERT ...', { transactionId: tx.id });
    await client.gql('INSERT ...', { transactionId: tx.id });

    await client.commit(tx.id);
    tx = undefined;  // Transaction completed

  } finally {
    if (tx) {
      // Transaction was started but not committed
      try {
        await client.rollback(tx.id);
      } catch (rollbackError) {
        console.error('Rollback failed:', rollbackError);
      }
    }
  }
}
```

## Complete Example

```typescript
import {
  GqldbClient,
  createConfig,
  GqldbError,
  LoginFailedError,
  QueryFailedError,
  QueryTimeoutError,
  GraphNotFoundError,
  TransactionFailedError
} from '@ultipa-graph/ultipa-driver';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['localhost:60061'],
    timeout: 30000
  }));

  try {
    // Login with error handling
    try {
      await client.login('admin', 'password');
      console.log('Logged in successfully');
    } catch (error) {
      if (error instanceof LoginFailedError) {
        console.error('Invalid credentials');
        process.exit(1);
      }
      throw error;
    }

    // Ensure graph exists
    const graphName = 'errorDemo';
    try {
      await client.getGraphInfo(graphName);
    } catch (error) {
      if (error instanceof GraphNotFoundError) {
        await client.createGraph(graphName);
        console.log('Created graph');
      } else {
        throw error;
      }
    }

    await client.useGraph(graphName);

    // Transaction with error handling
    try {
      await client.withTransaction(graphName, async (txId) => {
        await client.gql(
          'INSERT (n:User {_id: "u1", name: "Alice"})',
          { transactionId: txId }
        );
        // Simulate potential error
        if (Math.random() < 0.3) {
          throw new Error('Random failure for demo');
        }
      });
      console.log('Transaction succeeded');
    } catch (error) {
      if (error instanceof TransactionFailedError) {
        console.error('Transaction failed, changes rolled back');
      } else {
        console.error('Error during transaction:', (error as Error).message);
      }
    }

    // Query with timeout handling
    try {
      const response = await client.gql(
        'MATCH (n) RETURN n',
        { timeout: 5000 }
      );
      console.log(`Found ${response.rowCount} results`);
    } catch (error) {
      if (error instanceof QueryTimeoutError) {
        console.warn('Query timed out, trying with limit');
        const limited = await client.gql('MATCH (n) RETURN n LIMIT 10');
        console.log(`Found ${limited.rowCount} results (limited)`);
      } else if (error instanceof QueryFailedError) {
        console.error('Query error:', error.message);
      } else {
        throw error;
      }
    }

    // Cleanup
    await client.dropGraph(graphName, true);

  } catch (error) {
    // Catch-all for unexpected errors
    if (error instanceof GqldbError) {
      console.error(`GQLDB Error: [${error.name}] ${error.message}`);
      if (error.cause) {
        console.error('Root cause:', error.cause.message);
      }
    } else {
      console.error('Unexpected error:', error);
    }
    process.exit(1);

  } finally {
    await client.close();
    console.log('Client closed');
  }
}

main();
```
