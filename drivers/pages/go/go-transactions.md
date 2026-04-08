# Transactions

The GQLDB Go driver supports ACID transactions for ensuring data consistency across multiple operations.

## Transaction Methods

| Method | Description |
|--------|-------------|
| `BeginTransaction(ctx, graphName, readOnly, timeout)` | Start a new transaction |
| `Commit(ctx, transactionID)` | Commit a transaction |
| `Rollback(ctx, transactionID)` | Rollback a transaction |
| `ListTransactions(ctx)` | List active transactions |
| `WithTransaction(ctx, graphName, readOnly, fn)` | Execute function in transaction |

## Basic Transaction Usage

### Manual Transaction Management

```go
import (
    "context"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

ctx := context.Background()

// Begin transaction
tx, err := client.BeginTransaction(ctx, "myGraph", false, 60)
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Transaction ID: %d\n", tx.ID)

// Execute queries within transaction
config := &gqldb.QueryConfig{TransactionID: tx.ID}

_, err = client.Gql(ctx, "INSERT (n:Person {_id: 'p1', name: 'Alice'})", config)
if err != nil {
    client.Rollback(ctx, tx.ID)
    log.Fatal(err)
}

_, err = client.Gql(ctx, "INSERT (n:Person {_id: 'p2', name: 'Bob'})", config)
if err != nil {
    client.Rollback(ctx, tx.ID)
    log.Fatal(err)
}

// Commit the transaction
success, err := client.Commit(ctx, tx.ID)
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Transaction committed: %v\n", success)
```

### Using WithTransaction()

The `WithTransaction()` method provides automatic commit/rollback:

```go
err := client.WithTransaction(ctx, "myGraph", false, func(txID uint64) error {
    config := &gqldb.QueryConfig{TransactionID: txID}

    // Debit from source
    _, err := client.Gql(ctx,
        "MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 100",
        config,
    )
    if err != nil {
        return err
    }

    // Credit to destination
    _, err = client.Gql(ctx,
        "MATCH (a:Account {_id: 'acc2'}) SET a.balance = a.balance + 100",
        config,
    )
    if err != nil {
        return err
    }

    return nil
})

if err != nil {
    log.Printf("Transaction failed: %v", err)
} else {
    fmt.Println("Transfer completed successfully")
}
```

## Transaction Struct

```go
type Transaction struct {
    ID        uint64
    SessionID uint64
    GraphName string
    ReadOnly  bool
    CreatedAt time.Time
    Timeout   time.Duration
}

// Methods
func (t *Transaction) IsCommitted() bool
func (t *Transaction) IsRolledBack() bool
func (t *Transaction) IsActive() bool
func (t *Transaction) Age() time.Duration
func (t *Transaction) IsExpired() bool
```

## Read-Only Transactions

For queries that only read data:

```go
// Begin read-only transaction
tx, err := client.BeginTransaction(ctx, "myGraph", true, 60)
if err != nil {
    log.Fatal(err)
}

config := &gqldb.QueryConfig{TransactionID: tx.ID}

// Execute read queries
response, err := client.Gql(ctx, "MATCH (n) RETURN count(n)", config)
if err != nil {
    client.Rollback(ctx, tx.ID)
    log.Fatal(err)
}

count, _ := response.SingleInt()
fmt.Printf("Count: %d\n", count)

// Commit (or rollback - same effect for read-only)
client.Commit(ctx, tx.ID)
```

## Transaction Timeout

Set a timeout for transactions:

```go
// 60 second timeout
tx, err := client.BeginTransaction(ctx, "myGraph", false, 60)
```

## Listing Transactions

```go
transactions, err := client.ListTransactions(ctx)
if err != nil {
    log.Fatal(err)
}

for _, txInfo := range transactions {
    fmt.Printf("Transaction %d:\n", txInfo.TransactionID)
    fmt.Printf("  Internal TX ID: %d\n", txInfo.InternalTxID)
    fmt.Printf("  Graph: %s\n", txInfo.GraphName)
    fmt.Printf("  Read-only: %v\n", txInfo.ReadOnly)
    fmt.Printf("  Created: %s\n", txInfo.CreatedAt)
    fmt.Printf("  Duration: %dms\n", txInfo.DurationMs)
}
```

### TransactionInfo Struct

```go
type TransactionInfo struct {
    TransactionID uint64
    InternalTxID  uint64
    GraphName     string
    ReadOnly      bool
    CreatedAt     string
    DurationMs    int64
}
```

## Transaction Patterns

### Defer Pattern

```go
func doTransaction(ctx context.Context, client *gqldb.Client) error {
    tx, err := client.BeginTransaction(ctx, "myGraph", false, 60)
    if err != nil {
        return err
    }

    committed := false
    defer func() {
        if !committed {
            client.Rollback(ctx, tx.ID)
        }
    }()

    config := &gqldb.QueryConfig{TransactionID: tx.ID}

    // Do work
    _, err = client.Gql(ctx, "INSERT (n:Test {_id: 't1'})", config)
    if err != nil {
        return err
    }

    // Commit
    _, err = client.Commit(ctx, tx.ID)
    if err != nil {
        return err
    }
    committed = true

    return nil
}
```

### Retry Pattern

```go
func executeWithRetry(ctx context.Context, client *gqldb.Client, graphName string,
    fn func(txID uint64) error, maxRetries int) error {

    var lastErr error

    for attempt := 0; attempt < maxRetries; attempt++ {
        err := client.WithTransaction(ctx, graphName, false, fn)
        if err == nil {
            return nil  // Success
        }

        lastErr = err

        if errors.Is(err, gqldb.ErrTransactionFailed) {
            // Retryable error
            waitTime := time.Duration(attempt+1) * 100 * time.Millisecond
            time.Sleep(waitTime)
            continue
        }

        // Non-retryable error
        return err
    }

    return fmt.Errorf("failed after %d retries: %w", maxRetries, lastErr)
}

// Usage
err := executeWithRetry(ctx, client, "myGraph", func(txID uint64) error {
    config := &gqldb.QueryConfig{TransactionID: txID}
    _, err := client.Gql(ctx, "INSERT (n:Test {_id: 't1'})", config)
    return err
}, 3)
```

## Error Handling

```go
import (
    "errors"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

tx, err := client.BeginTransaction(ctx, "myGraph", false, 60)
if err != nil {
    log.Fatal(err)
}

config := &gqldb.QueryConfig{TransactionID: tx.ID}

_, err = client.Gql(ctx, "INSERT (n:Test {_id: 't1'})", config)
if err != nil {
    client.Rollback(ctx, tx.ID)
    log.Fatal(err)
}

_, err = client.Commit(ctx, tx.ID)
if err != nil {
    if errors.Is(err, gqldb.ErrTransactionNotFound) {
        log.Println("Transaction not found (may have timed out)")
    } else if errors.Is(err, gqldb.ErrTransactionFailed) {
        log.Printf("Transaction failed: %v", err)
    } else {
        log.Printf("Commit error: %v", err)
    }
}
```

## Complete Example

```go
package main

import (
    "context"
    "errors"
    "fmt"
    "log"
    "time"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

func main() {
    config := gqldb.NewConfigBuilder().
        Hosts("localhost:60061").
        Timeout(30 * time.Second).
        Build()

    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Close()

    ctx := context.Background()
    client.Login(ctx, "admin", "password")
    client.CreateGraph(ctx, "txDemo", gqldb.GraphTypeOpen, "")
    client.UseGraph(ctx, "txDemo")

    // Setup: Create initial data
    client.Gql(ctx, `
        INSERT (acc1:Account {_id: 'acc1', name: 'Alice', balance: 1000}),
               (acc2:Account {_id: 'acc2', name: 'Bob', balance: 500})
    `, nil)

    fmt.Println("=== Initial Balances ===")
    response, _ := client.Gql(ctx, "MATCH (a:Account) RETURN a.name, a.balance ORDER BY a.name", nil)
    for _, row := range response.Rows {
        name, _ := row.GetString(0)
        balance, _ := row.GetInt(1)
        fmt.Printf("  %s: $%d\n", name, balance)
    }

    // Successful transaction
    fmt.Println("\n=== Transfer $200 from Alice to Bob ===")
    err = client.WithTransaction(ctx, "txDemo", false, func(txID uint64) error {
        cfg := &gqldb.QueryConfig{TransactionID: txID}

        _, err := client.Gql(ctx,
            "MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 200",
            cfg,
        )
        if err != nil {
            return err
        }

        _, err = client.Gql(ctx,
            "MATCH (a:Account {_id: 'acc2'}) SET a.balance = a.balance + 200",
            cfg,
        )
        return err
    })

    if err != nil {
        fmt.Printf("Transaction failed: %v\n", err)
    } else {
        fmt.Println("Transaction committed")
    }

    response, _ = client.Gql(ctx, "MATCH (a:Account) RETURN a.name, a.balance ORDER BY a.name", nil)
    for _, row := range response.Rows {
        name, _ := row.GetString(0)
        balance, _ := row.GetInt(1)
        fmt.Printf("  %s: $%d\n", name, balance)
    }

    // Failed transaction (rollback)
    fmt.Println("\n=== Attempted Transfer with Error ===")
    err = client.WithTransaction(ctx, "txDemo", false, func(txID uint64) error {
        cfg := &gqldb.QueryConfig{TransactionID: txID}

        _, err := client.Gql(ctx,
            "MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 100",
            cfg,
        )
        if err != nil {
            return err
        }

        // Simulate error
        return errors.New("simulated error - rollback!")
    })

    fmt.Printf("Error caught: %v\n", err)

    fmt.Println("After rollback:")
    response, _ = client.Gql(ctx, "MATCH (a:Account) RETURN a.name, a.balance ORDER BY a.name", nil)
    for _, row := range response.Rows {
        name, _ := row.GetString(0)
        balance, _ := row.GetInt(1)
        fmt.Printf("  %s: $%d\n", name, balance)
    }

    // Manual transaction management
    fmt.Println("\n=== Manual Transaction ===")
    tx, _ := client.BeginTransaction(ctx, "txDemo", false, 60)
    fmt.Printf("Started transaction %d\n", tx.ID)

    cfg := &gqldb.QueryConfig{TransactionID: tx.ID}
    _, err = client.Gql(ctx, "MATCH (a:Account {_id: 'acc1'}) SET a.balance = a.balance - 50", cfg)
    if err != nil {
        client.Rollback(ctx, tx.ID)
        fmt.Printf("  Rolled back: %v\n", err)
    } else {
        fmt.Printf("  Active: %v\n", tx.IsActive())
        fmt.Printf("  Age: %v\n", tx.Age())
        client.Commit(ctx, tx.ID)
        fmt.Println("  Committed")
    }

    // List transactions (should be empty now)
    fmt.Println("\n=== Active Transactions ===")
    activeTxs, _ := client.ListTransactions(ctx)
    fmt.Printf("  Count: %d\n", len(activeTxs))

    // Cleanup
    client.DropGraph(ctx, "txDemo", true)
}
```
