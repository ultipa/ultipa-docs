# Error Handling

The GQLDB Java driver provides a comprehensive set of exception classes for handling different failure scenarios. All exceptions extend the base `GqldbException` class.

## Base Exception Class

```java
import com.gqldb.GqldbException;

public class GqldbException extends RuntimeException {
    private final int code;

    public int getCode();
    public String getMessage();
    public Throwable getCause();
}
```

All GQLDB exceptions include:
- `message`: Human-readable error description
- `code`: Numeric error code
- `cause`: Original exception that caused this error (if applicable)

## Exception Categories

### Configuration Exceptions

| Exception | Description |
|-----------|-------------|
| `NoHostsException` | No hosts configured in the client |
| `InvalidTimeoutException` | Invalid timeout value specified |

```java
import com.gqldb.*;

try {
    GqldbConfig config = GqldbConfig.builder()
        .hosts()  // Empty hosts
        .build();
} catch (IllegalArgumentException e) {
    System.err.println("You must configure at least one host");
}
```

### Connection Exceptions

| Exception | Description |
|-----------|-------------|
| `NoConnectionException` | No connection available |
| `ConnectionClosedException` | Connection has been closed |
| `ConnectionFailedException` | Failed to establish connection |
| `AllHostsFailedException` | All configured hosts are unreachable |

```java
public boolean connectWithRetry(GqldbClient client, int maxRetries) {
    for (int i = 0; i < maxRetries; i++) {
        try {
            client.login("user", "pass");
            return true;
        } catch (ConnectionFailedException e) {
            System.out.println("Connection attempt " + (i + 1) + " failed, retrying...");
            try {
                Thread.sleep(1000 * (i + 1));  // Exponential backoff
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                return false;
            }
        } catch (AllHostsFailedException e) {
            System.err.println("All hosts unreachable");
            throw e;
        }
    }
    return false;
}
```

### Session Exceptions

| Exception | Description |
|-----------|-------------|
| `NotLoggedInException` | Operation requires authentication |
| `LoginFailedException` | Login failed (wrong credentials) |
| `SessionExpiredException` | Session has expired |

```java
public void ensureLoggedIn(GqldbClient client) {
    try {
        client.gql("MATCH (n) RETURN count(n)");
    } catch (NotLoggedInException | SessionExpiredException e) {
        System.out.println("Session expired, re-authenticating...");
        client.login("user", "pass");
    }
}
```

### Transaction Exceptions

| Exception | Description |
|-----------|-------------|
| `TransactionNotFoundException` | Transaction not found (may have timed out) |
| `TransactionFailedException` | Transaction operation failed |

```java
public void safeTransaction(GqldbClient client, GqldbClient.TransactionFunction<?> fn) {
    try {
        client.withTransaction("myGraph", fn);
    } catch (TransactionFailedException e) {
        System.err.println("Transaction failed: " + e.getMessage());
    } catch (TransactionNotFoundException e) {
        System.err.println("Transaction timed out before completion");
    }
}
```

### Query Exceptions

| Exception | Description |
|-----------|-------------|
| `QueryFailedException` | Query execution failed |
| `EmptyQueryException` | Query string is empty |

```java
public Response executeQuery(GqldbClient client, String query) {
    try {
        return client.gql(query);
    } catch (EmptyQueryException e) {
        System.err.println("Query cannot be empty");
    } catch (QueryFailedException e) {
        System.err.println("Query failed: " + e.getMessage());
    }
    return null;
}
```

### Graph Exceptions

| Exception | Description |
|-----------|-------------|
| `GraphNotFoundException` | Graph does not exist |
| `GraphExistsException` | Graph already exists |

```java
public void ensureGraph(GqldbClient client, String graphName) {
    try {
        client.getGraphInfo(graphName);
        System.out.println("Graph " + graphName + " exists");
    } catch (GraphNotFoundException e) {
        try {
            client.createGraph(graphName);
            System.out.println("Created graph " + graphName);
        } catch (GraphExistsException e2) {
            // Race condition: another process created it
            System.out.println("Graph " + graphName + " was created by another process");
        }
    }
}
```

## Error Handling Patterns

### Comprehensive Try-Catch

```java
public void handleAllErrors(GqldbClient client) {
    try {
        client.login("user", "pass");
        client.gql("MATCH (n) RETURN n");
    } catch (GqldbException e) {
        // All driver exceptions
        System.err.println("GQLDB Error [" + e.getClass().getSimpleName() + "]: " + e.getMessage());
        if (e.getCause() != null) {
            System.err.println("Caused by: " + e.getCause());
        }
    } catch (Exception e) {
        // Other exceptions
        System.err.println("Unexpected error: " + e.getMessage());
    }
}
```

### Error Recovery with Retry

```java
public <T> T withRetry(Supplier<T> operation, int maxRetries,
                       Class<? extends GqldbException>... retryableExceptions) {
    Exception lastError = null;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            return operation.get();
        } catch (GqldbException e) {
            lastError = e;

            boolean isRetryable = false;
            for (Class<? extends GqldbException> retryable : retryableExceptions) {
                if (retryable.isInstance(e)) {
                    isRetryable = true;
                    break;
                }
            }

            if (!isRetryable || attempt == maxRetries) {
                throw e;
            }

            System.out.println("Attempt " + attempt + " failed, retrying...");
            try {
                Thread.sleep(1000 * attempt);
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                throw e;
            }
        }
    }

    throw new RuntimeException("Should not reach here", lastError);
}

// Usage
Response result = withRetry(
    () -> client.gql("MATCH (n) RETURN n LIMIT 100"),
    3,
    ConnectionFailedException.class
);
```

### Graceful Degradation

```java
public Response getDataWithFallback(GqldbClient client) {
    try {
        // Try the main query
        return client.gql("MATCH (n:User) RETURN n");
    } catch (QueryFailedException e) {
        if (e.getMessage().contains("timeout")) {
            // Fall back to a simpler query
            System.out.println("Full query timed out, using limited query");
            return client.gql("MATCH (n:User) RETURN n LIMIT 100");
        }
        throw e;
    }
}
```

### Cleanup on Error

```java
public void transactionWithCleanup(GqldbClient client) {
    Transaction tx = null;

    try {
        tx = client.beginTransaction("myGraph");

        client.gqlInTransaction("INSERT ...", tx.getId());
        client.gqlInTransaction("INSERT ...", tx.getId());

        client.commit(tx.getId());
        tx = null;  // Transaction completed

    } finally {
        if (tx != null) {
            // Transaction was started but not committed
            try {
                client.rollback(tx.getId());
            } catch (Exception rollbackError) {
                System.err.println("Rollback failed: " + rollbackError.getMessage());
            }
        }
    }
}
```

## Complete Example

```java
import com.gqldb.*;

public class ErrorHandlingExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("192.168.1.100:9000")
            .timeout(30)
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            // Login with error handling
            try {
                client.login("admin", "password");
                System.out.println("Logged in successfully");
            } catch (LoginFailedException e) {
                System.err.println("Invalid credentials");
                System.exit(1);
            }

            // Ensure graph exists
            String graphName = "errorDemo";
            try {
                client.getGraphInfo(graphName);
            } catch (GraphNotFoundException e) {
                client.createGraph(graphName);
                System.out.println("Created graph");
            }

            client.useGraph(graphName);

            // Transaction with error handling
            try {
                client.withTransaction(graphName, txId -> {
                    client.gqlInTransaction(
                        "INSERT (n:User {_id: \"u1\", name: \"Alice\"})",
                        txId
                    );
                    // Simulate potential error
                    if (Math.random() < 0.3) {
                        throw new RuntimeException("Random failure for demo");
                    }
                    return null;
                });
                System.out.println("Transaction succeeded");
            } catch (TransactionFailedException e) {
                System.err.println("Transaction failed, changes rolled back");
            } catch (RuntimeException e) {
                System.err.println("Error during transaction: " + e.getMessage());
            }

            // Query with timeout handling
            try {
                QueryConfig queryConfig = new QueryConfig();
                queryConfig.setTimeout(5);  // 5 seconds

                Response response = client.gql("MATCH (n) RETURN n", queryConfig);
                System.out.println("Found " + response.getRowCount() + " results");
            } catch (QueryFailedException e) {
                if (e.getMessage().contains("timeout")) {
                    System.out.println("Query timed out, trying with limit");
                    Response limited = client.gql("MATCH (n) RETURN n LIMIT 10");
                    System.out.println("Found " + limited.getRowCount() + " results (limited)");
                } else {
                    System.err.println("Query error: " + e.getMessage());
                }
            }

            // Cleanup
            client.dropGraph(graphName, true);

        } catch (GqldbException e) {
            // Catch-all for unexpected errors
            System.err.println("GQLDB Error: [" + e.getClass().getSimpleName() + "] " + e.getMessage());
            if (e.getCause() != null) {
                System.err.println("Root cause: " + e.getCause().getMessage());
            }
            System.exit(1);
        }

        System.out.println("Client closed");
    }
}
```
