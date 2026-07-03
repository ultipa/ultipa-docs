# Transactions

The GQLDB Java driver supports ACID transactions, allowing you to execute multiple operations atomically with automatic rollback on failure.

## Transaction Methods

| Method | Description |
|--------|-------------|
| `beginTransaction()` | Start a new transaction |
| `commit()` | Commit a transaction |
| `rollback()` | Rollback a transaction |
| `listTransactions()` | List active transactions for current user |
| `listAllTransactions()` | List all active transactions (admin only) |
| `withTransaction()` | Execute a function within a transaction (auto commit/rollback) |
| `gqlInTransaction()` | Execute a query within a transaction |

## Starting a Transaction

### beginTransaction()

Start a new transaction on a specific graph:

```java
import com.gqldb.*;

public void startTransaction(GqldbClient client) {
    // Start a read-write transaction
    Transaction tx = client.beginTransaction("myGraph");
    System.out.println("Transaction ID: " + tx.getId());

    // Start a read-only transaction
    Transaction readOnlyTx = client.beginTransaction("myGraph", true, 30);

    // Start with custom timeout (in seconds)
    Transaction timedTx = client.beginTransaction("myGraph", false, 60);
}
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `graphName` | `String` | required | Target graph for the transaction |
| `readOnly` | `boolean` | `false` | If true, transaction is read-only |
| `timeout` | `int` | config timeout | Transaction timeout in seconds |

## Committing a Transaction

### commit()

Commit a transaction to make changes permanent:

```java
public void commitExample(GqldbClient client) {
    Transaction tx = client.beginTransaction("myGraph");

    try {
        // Execute queries within the transaction
        client.gqlInTransaction("INSERT (n:User {_id: \"u1\", name: \"Alice\"})", tx.getId());

        // Commit the transaction
        boolean success = client.commit(tx.getId());
        if (success) {
            System.out.println("Transaction committed successfully");
        }
    } catch (Exception e) {
        client.rollback(tx.getId());
        throw e;
    }
}
```

## Rolling Back a Transaction

### rollback()

Rollback a transaction to undo all changes:

```java
public void rollbackExample(GqldbClient client) {
    Transaction tx = client.beginTransaction("myGraph");

    try {
        client.gqlInTransaction("INSERT (n:User {_id: \"u1\", name: \"Alice\"})", tx.getId());

        // Something went wrong, rollback
        throw new RuntimeException("Simulated error");

    } catch (Exception e) {
        boolean success = client.rollback(tx.getId());
        if (success) {
            System.out.println("Transaction rolled back");
        }
        throw e;
    }
}
```

## Automatic Transaction Management

### withTransaction()

The recommended way to use transactions. Automatically commits on success and rolls back on error:

```java
public void withTransactionExample(GqldbClient client) {
    String result = client.withTransaction("myGraph", txId -> {
        // All operations use the same transaction
        client.gqlInTransaction("INSERT (a:User {_id: \"u1\", name: \"Alice\"})", txId);
        client.gqlInTransaction("INSERT (b:User {_id: \"u2\", name: \"Bob\"})", txId);
        client.gqlInTransaction(
            "INSERT (:User {_id: \"u1\"})-[:Knows]->(:User {_id: \"u2\"})",
            txId
        );

        // Return a value from the transaction
        return "Users and relationship created";
    });

    System.out.println(result);  // "Users and relationship created"
}
```

### Read-Only Transactions

```java
public void readOnlyTransaction(GqldbClient client) {
    long count = client.withTransaction("myGraph", txId -> {
        Response response = client.gqlInTransaction(
            "MATCH (n:User) RETURN count(n)",
            txId
        );
        return response.singleLong();
    }, true);  // read-only

    System.out.println("User count: " + count);
}
```

## Listing Active Transactions

### listTransactions()

Get information about your active transactions:

```java
import java.util.List;

public void listActiveTransactions(GqldbClient client) {
    List<TransactionInfo> transactions = client.listTransactions();

    System.out.println("Active transactions: " + transactions.size());
    for (TransactionInfo tx : transactions) {
        System.out.println("- ID: " + tx.getTransactionId() +
            ", Graph: " + tx.getGraphName() +
            ", ReadOnly: " + tx.isReadOnly());
    }
}
```

### listAllTransactions()

Admin-only method to get all active transactions:

```java
List<TransactionInfo> allTransactions = client.listAllTransactions();
```

### TransactionInfo Class

```java
public class TransactionInfo {
    long getTransactionId();
    long getSessionId();
    String getGraphName();
    boolean isReadOnly();
    long getCreatedAt();
    long getDurationMs();
    String getInternalTxId();
}
```

## Transaction Isolation

Queries within a transaction see a consistent snapshot:

```java
public void isolationExample(GqldbClient client) {
    try {
        client.withTransaction("myGraph", txId -> {
            // Insert a node
            client.gqlInTransaction(
                "INSERT (n:User {_id: \"temp\", name: \"Temporary\"})",
                txId
            );

            // Query within the same transaction sees the new node
            Response response = client.gqlInTransaction(
                "MATCH (u:User {_id: \"temp\"}) RETURN u",
                txId
            );
            System.out.println("Found in transaction: " + response.size());  // 1

            // Rollback by throwing an exception
            throw new RuntimeException("Rollback");
        });
    } catch (RuntimeException e) {
        // Expected
    }

    // After rollback, node doesn't exist
    QueryConfig config = new QueryConfig();
    config.setGraphName("myGraph");
    Response response = client.gql("MATCH (u:User {_id: \"temp\"}) RETURN u", config);
    System.out.println("Found after rollback: " + response.size());  // 0
}
```

## Exception Handling

```java
import com.gqldb.*;

public void safeTransaction(GqldbClient client) {
    try {
        client.withTransaction("myGraph", txId -> {
            // Transaction operations
            return null;
        });
    } catch (GqldbException e) {
        // All driver errors surface as GqldbException. Branch on the message
        // or error code to distinguish cases (e.g. a transaction that has
        // timed out or was not found).
        if (e.getMessage() != null && e.getMessage().contains("Transaction not found")) {
            System.err.println("Transaction not found (may have timed out)");
        } else {
            System.err.println("Transaction failed: " + e.getMessage());
        }
    }
}
```

## Best Practices

### Keep Transactions Short

```java
// Good: Short transaction
client.withTransaction("myGraph", txId -> {
    client.gqlInTransaction("INSERT ...", txId);
    client.gqlInTransaction("INSERT ...", txId);
    return null;
});

// Avoid: Long-running transactions with external calls
client.withTransaction("myGraph", txId -> {
    client.gqlInTransaction("INSERT ...", txId);
    fetchExternalData();  // Don't do this in a transaction
    client.gqlInTransaction("INSERT ...", txId);
    return null;
});
```

### Use Read-Only When Possible

```java
// Use read-only for queries that don't modify data
Object data = client.withTransaction("myGraph", txId -> {
    return client.gqlInTransaction("MATCH (n) RETURN n", txId);
}, true);  // read-only for better performance
```

## Complete Example

```java
import com.gqldb.*;

public class TransactionExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:9000")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");

            // Create a graph for testing
            client.createGraph("txDemo");
            client.useGraph("txDemo");

            // Use withTransaction for automatic management
            client.withTransaction("txDemo", txId -> {
                // Insert users
                client.gqlInTransaction(
                    "INSERT (a:User {_id: \"alice\", name: \"Alice\", balance: 100})",
                    txId
                );
                client.gqlInTransaction(
                    "INSERT (b:User {_id: \"bob\", name: \"Bob\", balance: 50})",
                    txId
                );
                System.out.println("Users created");
                return null;
            });

            // Transfer money between users (atomic operation)
            client.withTransaction("txDemo", txId -> {
                // Debit Alice
                client.gqlInTransaction(
                    "MATCH (a:User {_id: \"alice\"}) SET a.balance = a.balance - 25",
                    txId
                );

                // Credit Bob
                client.gqlInTransaction(
                    "MATCH (b:User {_id: \"bob\"}) SET b.balance = b.balance + 25",
                    txId
                );

                System.out.println("Transfer completed");
                return null;
            });

            // Verify balances
            Response response = client.gql(
                "MATCH (u:User) RETURN u._id AS id, u.balance AS balance"
            );
            System.out.println("Final balances:");
            for (Row row : response) {
                System.out.println("  " + row.get(0) + ": " + row.get(1));
            }

            // Clean up
            client.dropGraph("txDemo");

        } catch (GqldbException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```
