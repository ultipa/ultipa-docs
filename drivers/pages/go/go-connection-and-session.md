# Connection and Session

The GQLDB Go driver manages connections through a connection pool and provides session-based authentication. All operations require a `context.Context` for cancellation and timeout control.

## Session Methods

| Method | Description |
|--------|-------------|
| `Login(ctx, username, password)` | Authenticate and create a session |
| `Logout(ctx)` | Terminate the current session |
| `Ping(ctx)` | Check connection and return latency |
| `GetSession()` | Get the current session |
| `IsLoggedIn()` | Check if logged in |

## Creating a Client

```go
import (
    "context"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

config := &gqldb.Config{
    Hosts: []string{"localhost:9000"},
}

client, err := gqldb.NewClient(config)
if err != nil {
    log.Fatal(err)
}
defer client.Close()  // Always close when done

ctx := context.Background()

_, err = client.Login(ctx, "username", "password")
if err != nil {
    log.Fatal(err)
}
```

## Authentication

### Login()

Authenticate with the server and create a session:

```go
ctx := context.Background()

// Login returns a Session pointer
session, err := client.Login(ctx, "admin", "password")
if err != nil {
    log.Fatalf("Login failed: %v", err)
}

fmt.Printf("Session ID: %d\n", session.ID)
fmt.Printf("Server Version: %s\n", session.ServerVersion)
fmt.Printf("Logged in: %v\n", client.IsLoggedIn())
```

### Login with Default Graph

```go
config := &gqldb.Config{
    Hosts:        []string{"localhost:9000"},
    DefaultGraph: "myGraph",
}

client, err := gqldb.NewClient(config)
if err != nil {
    log.Fatal(err)
}
defer client.Close()

ctx := context.Background()

// Automatically uses myGraph after login
_, err = client.Login(ctx, "admin", "password")
if err != nil {
    log.Fatal(err)
}

// No need to call UseGraph()
response, err := client.Gql(ctx, "MATCH (n) RETURN count(n)", nil)
```

### Logout()

Terminate the current session:

```go
ctx := context.Background()

_, err := client.Login(ctx, "admin", "password")
if err != nil {
    log.Fatal(err)
}

// Do work...

// Explicit logout
err = client.Logout(ctx)
if err != nil {
    log.Printf("Logout failed: %v", err)
}

fmt.Printf("Logged in: %v\n", client.IsLoggedIn())  // false
```

## Connection Health

### Ping()

Check the connection and get latency:

```go
ctx := context.Background()

// Returns latency in nanoseconds
latencyNs, err := client.Ping(ctx)
if err != nil {
    log.Printf("Ping failed: %v", err)
    return
}

latencyMs := float64(latencyNs) / 1_000_000
fmt.Printf("Connection latency: %.2fms\n", latencyMs)
```

## Session Information

### GetSession()

Get the current session:

```go
session := client.GetSession()
if session != nil {
    fmt.Printf("Session ID: %d\n", session.ID)
    fmt.Printf("Server Version: %s\n", session.ServerVersion)
    fmt.Printf("Default Graph: %s\n", session.DefaultGraph)
}
```

### IsLoggedIn()

Check if there is an active session:

```go
fmt.Printf("Before login: %v\n", client.IsLoggedIn())  // false

_, err := client.Login(ctx, "admin", "password")
if err != nil {
    log.Fatal(err)
}
fmt.Printf("After login: %v\n", client.IsLoggedIn())   // true

client.Logout(ctx)
fmt.Printf("After logout: %v\n", client.IsLoggedIn())  // false
```

## Context Usage

The Go driver uses `context.Context` for all operations:

```go
// With timeout
ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
defer cancel()

_, err := client.Login(ctx, "admin", "password")
if err != nil {
    if ctx.Err() == context.DeadlineExceeded {
        log.Println("Login timed out")
    }
    log.Fatal(err)
}

// With cancellation
ctx, cancel := context.WithCancel(context.Background())
go func() {
    time.Sleep(5 * time.Second)
    cancel()  // Cancel after 5 seconds
}()

response, err := client.Gql(ctx, "MATCH (n) RETURN n", nil)
if err != nil {
    if ctx.Err() == context.Canceled {
        log.Println("Query was cancelled")
    }
}
```

## Error Handling

```go
import (
    "errors"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

ctx := context.Background()

_, err := client.Login(ctx, "admin", "wrong_password")
if err != nil {
    if errors.Is(err, gqldb.ErrLoginFailed) {
        log.Println("Invalid credentials")
    } else if errors.Is(err, gqldb.ErrConnectionFailed) {
        log.Println("Could not connect to server")
    } else if errors.Is(err, gqldb.ErrAllHostsFailed) {
        log.Println("All configured hosts are unreachable")
    } else {
        log.Printf("Login error: %v", err)
    }
}
```

## Reconnection Pattern

```go
func connectWithRetry(config *gqldb.Config, maxRetries int) (*gqldb.Client, error) {
    var lastErr error

    for i := 0; i < maxRetries; i++ {
        client, err := gqldb.NewClient(config)
        if err != nil {
            lastErr = err
            time.Sleep(time.Duration(i+1) * time.Second)
            continue
        }

        ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
        _, err = client.Login(ctx, "admin", "password")
        cancel()

        if err != nil {
            client.Close()
            lastErr = err
            time.Sleep(time.Duration(i+1) * time.Second)
            continue
        }

        return client, nil
    }

    return nil, fmt.Errorf("failed after %d retries: %w", maxRetries, lastErr)
}

func ensureConnected(client *gqldb.Client) error {
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    _, err := client.Ping(ctx)
    if err != nil {
        // Attempt to reconnect
        _, err = client.Login(ctx, "admin", "password")
        return err
    }
    return nil
}
```

## Complete Example

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

func main() {
    config := gqldb.NewConfigBuilder().
        Hosts("localhost:9000", "192.168.1.101:9000").
        Timeout(30 * time.Second).
        PoolSize(10).
        RetryCount(3).
        Build()

    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatalf("Failed to create client: %v", err)
    }
    defer client.Close()

    ctx := context.Background()

    // Login
    session, err := client.Login(ctx, "admin", "password")
    if err != nil {
        log.Fatalf("Login failed: %v", err)
    }
    fmt.Printf("Connected! Session ID: %d\n", session.ID)

    // Check connection
    latency, err := client.Ping(ctx)
    if err != nil {
        log.Printf("Ping failed: %v", err)
    } else {
        fmt.Printf("Latency: %.2fms\n", float64(latency)/1_000_000)
    }

    // Get session info
    currentSession := client.GetSession()
    if currentSession != nil {
        fmt.Printf("Server: %s\n", currentSession.ServerVersion)
    }

    // Check login status
    fmt.Printf("Logged in: %v\n", client.IsLoggedIn())

    // Do some work
    response, err := client.Gql(ctx, "RETURN 1 + 1 AS result", nil)
    if err != nil {
        log.Fatalf("Query failed: %v", err)
    }
    result, _ := response.SingleInt()
    fmt.Printf("Result: %d\n", result)

    // Logout
    err = client.Logout(ctx)
    if err != nil {
        log.Printf("Logout failed: %v", err)
    }
    fmt.Printf("Logged out. Still logged in: %v\n", client.IsLoggedIn())
}
```
