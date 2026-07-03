# Error Handling

The GQLDB Java driver reports all failures through a single base exception, `GqldbException`. Rather than a wide hierarchy of catchable subclasses, the driver exposes just **two** public exception types and distinguishes failure modes through an error **code** and **message**.

> **Note:** Only `GqldbException` and `EmptyQueryException` are part of the public API. The driver defines finer-grained types internally (e.g. for connection, login, transaction, or graph failures), but they are **package-private** and cannot be caught from user code — and most are never thrown. Always catch `GqldbException` and branch on `getCode()` / `getMessage()` when you need to tell cases apart.

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

Every `GqldbException` carries:
- `message`: Human-readable error description
- `code`: Numeric error code (`0` when unset)
- `cause`: Original exception that caused this error (if applicable)

`EmptyQueryException extends GqldbException` and is thrown when a query string is empty. Because it is a public subclass, you may catch it directly before the base type.

## Error Conditions

The driver surfaces the following conditions as a `GqldbException`. Inspect `getMessage()` (or `getCode()`) to react to a specific one.

### Configuration

| Condition | Description |
|-----------|-------------|
| No hosts configured | The client was built without any hosts |
| Invalid timeout | An invalid timeout value was specified |

```java
import com.gqldb.*;

try {
    GqldbConfig config = GqldbConfig.builder()
        .hosts()  // Empty hosts
        .build();
} catch (GqldbException e) {
    System.err.println("You must configure at least one host: " + e.getMessage());
}
```

### Connection

| Condition | Description |
|-----------|-------------|
| No connection | No connection available |
| Connection closed | Connection has been closed |
| Connection failed | Failed to establish a connection |
| All hosts failed | All configured hosts are unreachable |

```java
public boolean connectWithRetry(GqldbClient client, int maxRetries) {
    for (int i = 0; i < maxRetries; i++) {
        try {
            client.login("user", "pass");
            return true;
        } catch (GqldbException e) {
            System.out.println("Connection attempt " + (i + 1) + " failed: " + e.getMessage());
            try {
                Thread.sleep(1000 * (i + 1));  // Exponential backoff
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                return false;
            }
        }
    }
    return false;
}
```

### Session

| Condition | Description |
|-----------|-------------|
| Not logged in | Operation requires authentication |
| Login failed | Login failed (wrong credentials) |
| Session expired | Session has expired |

```java
public void ensureLoggedIn(GqldbClient client) {
    try {
        client.gql("MATCH (n) RETURN count(n)");
    } catch (GqldbException e) {
        System.out.println("Session issue, re-authenticating: " + e.getMessage());
        client.login("user", "pass");
    }
}
```

### Transactions

| Condition | Description |
|-----------|-------------|
| Transaction not found | Transaction not found (may have timed out) |
| Transaction failed | Transaction operation failed |

```java
public void safeTransaction(GqldbClient client, GqldbClient.TransactionFunction<?> fn) {
    try {
        client.withTransaction("myGraph", fn);
    } catch (GqldbException e) {
        if (e.getMessage() != null && e.getMessage().contains("Transaction not found")) {
            System.err.println("Transaction timed out before completion");
        } else {
            System.err.println("Transaction failed: " + e.getMessage());
        }
    }
}
```

### Queries

| Condition | Description |
|-----------|-------------|
| Query failed | Query execution failed |
| Empty query | Query string is empty (`EmptyQueryException`) |

```java
public Response executeQuery(GqldbClient client, String query) {
    try {
        return client.gql(query);
    } catch (EmptyQueryException e) {
        // EmptyQueryException is a public subclass — catch it before the base type.
        System.err.println("Query cannot be empty");
    } catch (GqldbException e) {
        System.err.println("Query failed: " + e.getMessage());
    }
    return null;
}
```

### Graphs

| Condition | Description |
|-----------|-------------|
| Graph not found | Graph does not exist |
| Graph exists | Graph already exists |

```java
public void ensureGraph(GqldbClient client, String graphName) {
    try {
        client.getGraphInfo(graphName);
        System.out.println("Graph " + graphName + " exists");
    } catch (GqldbException e) {
        // Graph not found — try to create it.
        try {
            client.createGraph(graphName);
            System.out.println("Created graph " + graphName);
        } catch (GqldbException e2) {
            // Race condition: another process created it first.
            System.out.println("Graph " + graphName + " already exists: " + e2.getMessage());
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
        // All driver failures
        System.err.println("GQLDB Error [code " + e.getCode() + "]: " + e.getMessage());
        if (e.getCause() != null) {
            System.err.println("Caused by: " + e.getCause());
        }
    } catch (Exception e) {
        // Other (non-driver) exceptions
        System.err.println("Unexpected error: " + e.getMessage());
    }
}
```

### Error Recovery with Retry

Because failure modes are distinguished by code/message rather than by type, drive retry decisions with a predicate over `GqldbException`:

```java
public <T> T withRetry(Supplier<T> operation, int maxRetries,
                       Predicate<GqldbException> isRetryable) {
    GqldbException lastError = null;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
            return operation.get();
        } catch (GqldbException e) {
            lastError = e;

            if (!isRetryable.test(e) || attempt == maxRetries) {
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

// Usage: retry on transient connection errors
Response result = withRetry(
    () -> client.gql("MATCH (n) RETURN n LIMIT 100"),
    3,
    e -> e.getMessage() != null && e.getMessage().contains("connection")
);
```

### Graceful Degradation

```java
public Response getDataWithFallback(GqldbClient client) {
    try {
        // Try the main query
        return client.gql("MATCH (n:User) RETURN n");
    } catch (GqldbException e) {
        if (e.getMessage() != null && e.getMessage().contains("timeout")) {
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
            .hosts("localhost:9000")
            .timeout(30)
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            // Login with error handling
            try {
                client.login("admin", "password");
                System.out.println("Logged in successfully");
            } catch (GqldbException e) {
                System.err.println("Login failed: " + e.getMessage());
                System.exit(1);
            }

            // Ensure graph exists
            String graphName = "errorDemo";
            try {
                client.getGraphInfo(graphName);
            } catch (GqldbException e) {
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
            } catch (GqldbException e) {
                System.err.println("Transaction failed, changes rolled back: " + e.getMessage());
            } catch (RuntimeException e) {
                System.err.println("Error during transaction: " + e.getMessage());
            }

            // Query with timeout handling
            try {
                QueryConfig queryConfig = new QueryConfig();
                queryConfig.setTimeout(5);  // 5 seconds

                Response response = client.gql("MATCH (n) RETURN n", queryConfig);
                System.out.println("Found " + response.getRowCount() + " results");
            } catch (GqldbException e) {
                if (e.getMessage() != null && e.getMessage().contains("timeout")) {
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
            System.err.println("GQLDB Error [code " + e.getCode() + "]: " + e.getMessage());
            if (e.getCause() != null) {
                System.err.println("Root cause: " + e.getCause().getMessage());
            }
            System.exit(1);
        }

        System.out.println("Client closed");
    }
}
```
</content>
</invoke>
