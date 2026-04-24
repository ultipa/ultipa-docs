# Quick Start

This guide helps you get started with the GQLDB Go driver. It requires **Go 1.24 or higher**.

## Installation

Install the GQLDB Go driver using `go get`:

```bash
go get github.com/ultipa/ultipa-go-driver/v6
```

> Check <a href="https://github.com/ultipa/ultipa-go-driver" target="_blank">GitHub</a> for the latest version. To install a specific version: `go get github.com/ultipa/ultipa-go-driver/v6@v6.0.6`

## Basic Usage

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
    // Create configuration
    config := &gqldb.Config{
        Hosts:   []string{"localhost:9000"},
        Timeout: 30 * time.Second,
    }

    // Create client
    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Close()

    ctx := context.Background()

    // Authenticate
    _, err = client.Login(ctx, "username", "password")
    if err != nil {
        log.Fatal(err)
    }

    // Create a graph
    err = client.CreateGraph(ctx, "myGraph", gqldb.GraphTypeOpen, "")
    if err != nil {
        log.Fatal(err)
    }

    err = client.UseGraph(ctx, "myGraph")
    if err != nil {
        log.Fatal(err)
    }

    // Insert data
    _, err = client.Gql(ctx, `
        INSERT (a:Person {_id: "p1", name: "Alice", age: 30}),
               (b:Person {_id: "p2", name: "Bob", age: 25}),
               (a)-[:Knows {since: 2020}]->(b)
    `, nil)
    if err != nil {
        log.Fatal(err)
    }

    // Query data
    response, err := client.Gql(ctx, "MATCH (n:Person) RETURN n.name, n.age", nil)
    if err != nil {
        log.Fatal(err)
    }

    for _, row := range response.Rows {
        name, _ := row.GetString(0)
        age, _ := row.GetInt(1)
        fmt.Printf("%s: %d\n", name, age)
    }

    // Clean up
    client.DropGraph(ctx, "myGraph", true)
}
```

## Connection with TLS

```go
package main

import (
    "crypto/tls"
    "crypto/x509"
    "os"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

func main() {
    // Load CA certificate
    caCert, err := os.ReadFile("/path/to/ca.crt")
    if err != nil {
        panic(err)
    }

    caCertPool := x509.NewCertPool()
    caCertPool.AppendCertsFromPEM(caCert)

    // Load client certificate
    cert, err := tls.LoadX509KeyPair("/path/to/client.crt", "/path/to/client.key")
    if err != nil {
        panic(err)
    }

    tlsConfig := &tls.Config{
        Certificates: []tls.Certificate{cert},
        RootCAs:      caCertPool,
    }

    config := &gqldb.Config{
        Hosts:     []string{"localhost:9000"},
        TLSConfig: tlsConfig,
    }

    client, err := gqldb.NewClient(config)
    if err != nil {
        panic(err)
    }
    defer client.Close()

    // ... use the client
}
```

## Using the Config Builder

```go
package main

import (
    "time"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

func main() {
    config := gqldb.NewConfigBuilder().
        Hosts("localhost:9000", "192.168.1.101:9000").
        Timeout(60 * time.Second).
        DefaultGraph("myGraph").
        PoolSize(20).
        RetryCount(5).
        Build()

    client, err := gqldb.NewClient(config)
    if err != nil {
        panic(err)
    }
    defer client.Close()

    // ... use the client
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
        Hosts("localhost:9000").
        Timeout(30 * time.Second).
        DefaultGraph("socialNetwork").
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
    fmt.Printf("Logged in with session ID: %d\n", session.ID)

    // Check if graph exists, create if not
    _, err = client.GetGraphInfo(ctx, "socialNetwork")
    if err != nil {
        err = client.CreateGraph(ctx, "socialNetwork", gqldb.GraphTypeOpen, "")
        if err != nil {
            log.Fatalf("Failed to create graph: %v", err)
        }
        fmt.Println("Created graph")
    }

    err = client.UseGraph(ctx, "socialNetwork")
    if err != nil {
        log.Fatalf("Failed to use graph: %v", err)
    }

    // Insert data
    _, err = client.Gql(ctx, `
        INSERT (alice:User {_id: "u1", name: "Alice", email: "alice@example.com"}),
               (bob:User {_id: "u2", name: "Bob", email: "bob@example.com"}),
               (charlie:User {_id: "u3", name: "Charlie", email: "charlie@example.com"}),
               (alice)-[:Follows]->(bob),
               (bob)-[:Follows]->(charlie),
               (charlie)-[:Follows]->(alice)
    `, nil)
    if err != nil {
        log.Fatalf("Insert failed: %v", err)
    }

    // Query users
    response, err := client.Gql(ctx, "MATCH (u:User) RETURN u.name, u.email ORDER BY u.name", nil)
    if err != nil {
        log.Fatalf("Query failed: %v", err)
    }

    fmt.Println("\nUsers:")
    for _, row := range response.Rows {
        name, _ := row.GetString(0)
        email, _ := row.GetString(1)
        fmt.Printf("  %s - %s\n", name, email)
    }

    // Count relationships
    countResp, err := client.Gql(ctx, "MATCH ()-[r:Follows]->() RETURN count(r)", nil)
    if err != nil {
        log.Fatalf("Count query failed: %v", err)
    }
    count, _ := countResp.SingleInt()
    fmt.Printf("\nTotal follows: %d\n", count)

    // Find paths
    pathResp, err := client.Gql(ctx, `
        MATCH p = (a:User)-[:Follows]->{1,2}(b:User)
        WHERE a._id = "u1"
        RETURN p
        LIMIT 5
    `, nil)
    if err != nil {
        log.Fatalf("Path query failed: %v", err)
    }
    pAlias, _ := pathResp.Alias("p")
    paths, _ := pAlias.AsPaths()
    fmt.Printf("\nPaths from Alice: %d\n", len(paths))

    // Clean up
    client.DropGraph(ctx, "socialNetwork", true)
    fmt.Println("\nGraph dropped")
}
```

## Next Steps

- <a href="/docs/drivers/go-configuration">Configuration</a> - Learn about all configuration options
- <a href="/docs/drivers/go-connection-and-session">Connection and Session</a> - Detailed connection management
- <a href="/docs/drivers/go-executing-queries">Executing Queries</a> - Query methods and options
- <a href="/docs/drivers/go-response-processing">Response Processing</a> - Working with query results
