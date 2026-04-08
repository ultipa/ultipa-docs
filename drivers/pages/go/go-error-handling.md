# Error Handling

The GQLDB Go driver provides a comprehensive set of error variables and a custom error type for handling different failure scenarios.

## Error Variables

All common errors are defined as package-level variables that can be checked using `errors.Is()`:

```go
import (
    "errors"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)
```

### Configuration Errors

| Error | Description |
|-------|-------------|
| `ErrNoHosts` | No hosts configured in the client |
| `ErrInvalidTimeout` | Invalid timeout value specified |

```go
config := &gqldb.Config{Hosts: []string{}}

client, err := gqldb.NewClient(config)
if err != nil {
    if errors.Is(err, gqldb.ErrNoHosts) {
        log.Println("You must configure at least one host")
    }
}
```

### Connection Errors

| Error | Description |
|-------|-------------|
| `ErrNoConnection` | No connection available |
| `ErrConnectionClosed` | Connection has been closed |
| `ErrConnectionFailed` | Failed to establish connection |
| `ErrAllHostsFailed` | All configured hosts are unreachable |
| `ErrHealthCheckFailed` | Health check failed |

```go
func connectWithRetry(config *gqldb.Config, maxRetries int) (*gqldb.Client, error) {
    for i := 0; i < maxRetries; i++ {
        client, err := gqldb.NewClient(config)
        if err == nil {
            ctx := context.Background()
            _, err = client.Login(ctx, "user", "pass")
            if err == nil {
                return client, nil
            }
            client.Close()
        }

        if errors.Is(err, gqldb.ErrConnectionFailed) {
            log.Printf("Connection attempt %d failed, retrying...", i+1)
            time.Sleep(time.Duration(i+1) * time.Second)
            continue
        }

        if errors.Is(err, gqldb.ErrAllHostsFailed) {
            return nil, fmt.Errorf("all hosts unreachable: %w", err)
        }

        return nil, err
    }
    return nil, gqldb.ErrConnectionFailed
}
```

### Session Errors

| Error | Description |
|-------|-------------|
| `ErrNotLoggedIn` | Operation requires authentication |
| `ErrLoginFailed` | Login failed (wrong credentials) |
| `ErrLogoutFailed` | Logout operation failed |
| `ErrSessionExpired` | Session has expired |
| `ErrInvalidSession` | Invalid session |

```go
func ensureLoggedIn(ctx context.Context, client *gqldb.Client) error {
    _, err := client.Gql(ctx, "MATCH (n) RETURN count(n)", nil)
    if err != nil {
        if errors.Is(err, gqldb.ErrNotLoggedIn) || errors.Is(err, gqldb.ErrSessionExpired) {
            log.Println("Session expired, re-authenticating...")
            _, err = client.Login(ctx, "user", "pass")
            return err
        }
        return err
    }
    return nil
}
```

### Transaction Errors

| Error | Description |
|-------|-------------|
| `ErrNoTransaction` | No active transaction |
| `ErrTransactionFailed` | Transaction operation failed |
| `ErrTransactionNotFound` | Transaction not found (may have timed out) |
| `ErrTransactionAlreadyOpen` | Transaction already open |

```go
func safeTransaction(ctx context.Context, client *gqldb.Client, graphName string, fn func(uint64) error) error {
    err := client.WithTransaction(ctx, graphName, false, fn)
    if err != nil {
        if errors.Is(err, gqldb.ErrTransactionFailed) {
            log.Printf("Transaction failed: %v", err)
        } else if errors.Is(err, gqldb.ErrTransactionNotFound) {
            log.Println("Transaction timed out before completion")
        }
        return err
    }
    return nil
}
```

### Query Errors

| Error | Description |
|-------|-------------|
| `ErrQueryFailed` | Query execution failed |
| `ErrQueryTimeout` | Query timed out |
| `ErrInvalidQuery` | Invalid query syntax |
| `ErrEmptyQuery` | Query string is empty |

```go
func executeQuery(ctx context.Context, client *gqldb.Client, query string) (*gqldb.Response, error) {
    response, err := client.Gql(ctx, query, nil)
    if err != nil {
        if errors.Is(err, gqldb.ErrEmptyQuery) {
            return nil, fmt.Errorf("query cannot be empty")
        }
        if errors.Is(err, gqldb.ErrQueryTimeout) {
            return nil, fmt.Errorf("query timed out")
        }
        if errors.Is(err, gqldb.ErrQueryFailed) {
            return nil, fmt.Errorf("query failed: %w", err)
        }
        return nil, err
    }
    return response, nil
}
```

### Graph Errors

| Error | Description |
|-------|-------------|
| `ErrGraphNotFound` | Graph does not exist |
| `ErrGraphExists` | Graph already exists |
| `ErrCreateGraphFailed` | Failed to create graph |
| `ErrDropGraphFailed` | Failed to drop graph |

```go
func ensureGraph(ctx context.Context, client *gqldb.Client, graphName string) error {
    _, err := client.GetGraphInfo(ctx, graphName)
    if err == nil {
        log.Printf("Graph %s exists", graphName)
        return nil
    }

    if !errors.Is(err, gqldb.ErrGraphNotFound) {
        return err
    }

    err = client.CreateGraph(ctx, graphName, gqldb.GraphTypeOpen, "")
    if err != nil {
        if errors.Is(err, gqldb.ErrGraphExists) {
            // Race condition: another process created it
            log.Printf("Graph %s was created by another process", graphName)
            return nil
        }
        return err
    }

    log.Printf("Created graph %s", graphName)
    return nil
}
```

### Data Errors

| Error | Description |
|-------|-------------|
| `ErrInsertFailed` | Insert operation failed |
| `ErrDeleteFailed` | Delete operation failed |
| `ErrExportFailed` | Export operation failed |

### Type Errors

| Error | Description |
|-------|-------------|
| `ErrInvalidType` | Invalid type |
| `ErrTypeConversion` | Type conversion failed |
| `ErrUnsupportedType` | Unsupported type |

## GqldbError Type

For more detailed error information, the driver provides the `GqldbError` type:

```go
type GqldbError struct {
    Code    int
    Message string
    Cause   error
}

func (e *GqldbError) Error() string
func (e *GqldbError) Unwrap() error
```

### Creating Custom Errors

```go
err := gqldb.NewError(1001, "custom error message", originalError)
```

### Unwrapping Errors

```go
var gqldbErr *gqldb.GqldbError
if errors.As(err, &gqldbErr) {
    log.Printf("GQLDB Error [%d]: %s", gqldbErr.Code, gqldbErr.Message)
    if gqldbErr.Cause != nil {
        log.Printf("Caused by: %v", gqldbErr.Cause)
    }
}
```

## Error Handling Patterns

### Comprehensive Error Handling

```go
func handleAllErrors(ctx context.Context, client *gqldb.Client) {
    _, err := client.Login(ctx, "user", "pass")
    if err != nil {
        var gqldbErr *gqldb.GqldbError
        if errors.As(err, &gqldbErr) {
            log.Printf("GQLDB Error [%s]: %s", reflect.TypeOf(err).String(), gqldbErr.Message)
            if gqldbErr.Cause != nil {
                log.Printf("Caused by: %v", gqldbErr.Cause)
            }
        } else {
            log.Printf("Unexpected error: %v", err)
        }
        return
    }

    _, err = client.Gql(ctx, "MATCH (n) RETURN n", nil)
    if err != nil {
        log.Printf("Query error: %v", err)
    }
}
```

### Error Recovery with Retry

```go
func withRetry[T any](operation func() (T, error), maxRetries int, retryableErrors ...error) (T, error) {
    var lastErr error
    var zero T

    for attempt := 1; attempt <= maxRetries; attempt++ {
        result, err := operation()
        if err == nil {
            return result, nil
        }

        lastErr = err

        isRetryable := false
        for _, retryable := range retryableErrors {
            if errors.Is(err, retryable) {
                isRetryable = true
                break
            }
        }

        if !isRetryable || attempt == maxRetries {
            return zero, err
        }

        log.Printf("Attempt %d failed, retrying...", attempt)
        time.Sleep(time.Duration(attempt) * time.Second)
    }

    return zero, lastErr
}

// Usage
response, err := withRetry(
    func() (*gqldb.Response, error) {
        return client.Gql(ctx, "MATCH (n) RETURN n LIMIT 100", nil)
    },
    3,
    gqldb.ErrConnectionFailed,
)
```

### Graceful Degradation

```go
func getDataWithFallback(ctx context.Context, client *gqldb.Client) (*gqldb.Response, error) {
    response, err := client.Gql(ctx, "MATCH (n:User) RETURN n", nil)
    if err != nil {
        var gqldbErr *gqldb.GqldbError
        if errors.As(err, &gqldbErr) && strings.Contains(gqldbErr.Message, "timeout") {
            // Fall back to a simpler query
            log.Println("Full query timed out, using limited query")
            return client.Gql(ctx, "MATCH (n:User) RETURN n LIMIT 100", nil)
        }
        return nil, err
    }
    return response, nil
}
```

### Cleanup on Error

```go
func transactionWithCleanup(ctx context.Context, client *gqldb.Client, graphName string) error {
    tx, err := client.BeginTransaction(ctx, graphName, false, 60)
    if err != nil {
        return err
    }

    // Ensure rollback on panic or error
    committed := false
    defer func() {
        if !committed {
            if _, rollbackErr := client.Rollback(ctx, tx.ID); rollbackErr != nil {
                log.Printf("Rollback failed: %v", rollbackErr)
            }
        }
    }()

    config := &gqldb.QueryConfig{TransactionID: tx.ID}

    _, err = client.Gql(ctx, "INSERT (n:Test {_id: 't1'})", config)
    if err != nil {
        return err
    }

    _, err = client.Gql(ctx, "INSERT (n:Test {_id: 't2'})", config)
    if err != nil {
        return err
    }

    _, err = client.Commit(ctx, tx.ID)
    if err != nil {
        return err
    }
    committed = true

    return nil
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
        if errors.Is(err, gqldb.ErrNoHosts) {
            log.Fatal("No hosts configured")
        }
        log.Fatalf("Failed to create client: %v", err)
    }
    defer client.Close()

    ctx := context.Background()

    // Login with error handling
    _, err = client.Login(ctx, "admin", "password")
    if err != nil {
        if errors.Is(err, gqldb.ErrLoginFailed) {
            log.Fatal("Invalid credentials")
        }
        log.Fatalf("Login failed: %v", err)
    }
    fmt.Println("Logged in successfully")

    // Ensure graph exists
    graphName := "errorDemo"
    _, err = client.GetGraphInfo(ctx, graphName)
    if err != nil {
        if errors.Is(err, gqldb.ErrGraphNotFound) {
            err = client.CreateGraph(ctx, graphName, gqldb.GraphTypeOpen, "")
            if err != nil && !errors.Is(err, gqldb.ErrGraphExists) {
                log.Fatalf("Failed to create graph: %v", err)
            }
            fmt.Println("Created graph")
        } else {
            log.Fatalf("Failed to get graph info: %v", err)
        }
    }

    client.UseGraph(ctx, graphName)

    // Transaction with error handling
    err = client.WithTransaction(ctx, graphName, false, func(txID uint64) error {
        cfg := &gqldb.QueryConfig{TransactionID: txID}

        _, err := client.Gql(ctx,
            `INSERT (n:User {_id: 'u1', name: 'Alice'})`,
            cfg,
        )
        if err != nil {
            return err
        }

        // Simulate potential error
        if time.Now().UnixNano()%10 < 3 {
            return fmt.Errorf("random failure for demo")
        }

        return nil
    })

    if err != nil {
        if errors.Is(err, gqldb.ErrTransactionFailed) {
            fmt.Println("Transaction failed, changes rolled back")
        } else {
            fmt.Printf("Error during transaction: %v\n", err)
        }
    } else {
        fmt.Println("Transaction succeeded")
    }

    // Query with timeout handling
    queryConfig := &gqldb.QueryConfig{Timeout: 5}
    response, err := client.Gql(ctx, "MATCH (n) RETURN n", queryConfig)
    if err != nil {
        var gqldbErr *gqldb.GqldbError
        if errors.As(err, &gqldbErr) {
            if errors.Is(err, gqldb.ErrQueryTimeout) {
                fmt.Println("Query timed out, trying with limit")
                response, err = client.Gql(ctx, "MATCH (n) RETURN n LIMIT 10", nil)
                if err == nil {
                    fmt.Printf("Found %d results (limited)\n", response.RowCount)
                }
            } else {
                fmt.Printf("Query error: %s\n", gqldbErr.Message)
            }
        }
    } else {
        fmt.Printf("Found %d results\n", response.RowCount)
    }

    // Cleanup
    client.DropGraph(ctx, graphName, true)
    fmt.Println("Done")
}
```
