# Graph Management

The GQLDB Go driver provides methods for creating, managing, and querying graph metadata.

## Graph Methods

| Method | Description |
|--------|-------------|
| `CreateGraph(ctx, name, graphType, description)` | Create a new graph |
| `DropGraph(ctx, name, ifExists)` | Delete a graph |
| `UseGraph(ctx, name)` | Set the current graph for the session |
| `ListGraphs(ctx)` | List all available graphs |
| `GetGraphInfo(ctx, name)` | Get information about a specific graph |

## Creating Graphs

### CreateGraph()

Create a new graph:

```go
import (
    "context"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

ctx := context.Background()

// Create a basic graph (schema-less)
err := client.CreateGraph(ctx, "myGraph", gqldb.GraphTypeOpen, "")
if err != nil {
    log.Fatal(err)
}

// Create with specific type
err = client.CreateGraph(ctx, "schemaGraph", gqldb.GraphTypeClosed, "")
if err != nil {
    log.Fatal(err)
}

// Create with description
err = client.CreateGraph(ctx, "socialNetwork", gqldb.GraphTypeOpen, "Social network for user connections")
if err != nil {
    log.Fatal(err)
}
```

### GraphType Constants

```go
const (
    GraphTypeOpen     // Schema-less graph (default)
    GraphTypeClosed   // Schema-enforced graph
    GraphTypeOntology // Ontology-enabled graph
)
```

## Dropping Graphs

### DropGraph()

Delete a graph:

```go
// Drop a graph (returns error if not found)
err := client.DropGraph(ctx, "myGraph", false)
if err != nil {
    log.Fatal(err)
}

// Drop with ifExists (no error if not found)
err = client.DropGraph(ctx, "myGraph", true)
if err != nil {
    log.Fatal(err)
}
```

## Setting Current Graph

### UseGraph()

Set the current graph for the session:

```go
err := client.UseGraph(ctx, "myGraph")
if err != nil {
    log.Fatal(err)
}

// Now queries use myGraph by default
response, err := client.Gql(ctx, "MATCH (n) RETURN count(n)", nil)
```

## Listing Graphs

### ListGraphs()

Get all available graphs:

```go
graphs, err := client.ListGraphs(ctx)
if err != nil {
    log.Fatal(err)
}

for _, graph := range graphs {
    fmt.Printf("Name: %s\n", graph.Name)
    fmt.Printf("  Type: %v\n", graph.GraphType)
    fmt.Printf("  Description: %s\n", graph.Description)
    fmt.Printf("  Node count: %d\n", graph.NodeCount)
    fmt.Printf("  Edge count: %d\n", graph.EdgeCount)
    fmt.Println()
}
```

### GraphInfo Struct

```go
type GraphInfo struct {
    Name        string
    GraphType   GraphType
    NodeCount   int64
    EdgeCount   int64
    Description string
}
```

## Getting Graph Information

### GetGraphInfo()

Get detailed information about a specific graph:

```go
import (
    "errors"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

info, err := client.GetGraphInfo(ctx, "myGraph")
if err != nil {
    if errors.Is(err, gqldb.ErrGraphNotFound) {
        fmt.Println("Graph not found")
        return
    }
    log.Fatal(err)
}

fmt.Printf("Graph: %s\n", info.Name)
fmt.Printf("Type: %v\n", info.GraphType)
fmt.Printf("Nodes: %d\n", info.NodeCount)
fmt.Printf("Edges: %d\n", info.EdgeCount)
fmt.Printf("Description: %s\n", info.Description)
```

## Error Handling

```go
import (
    "errors"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

// Handle graph already exists
err := client.CreateGraph(ctx, "existingGraph", gqldb.GraphTypeOpen, "")
if err != nil {
    if errors.Is(err, gqldb.ErrGraphExists) {
        fmt.Println("Graph already exists")
    } else {
        log.Fatal(err)
    }
}

// Handle graph not found
_, err = client.GetGraphInfo(ctx, "nonExistentGraph")
if err != nil {
    if errors.Is(err, gqldb.ErrGraphNotFound) {
        fmt.Println("Graph not found")
    } else {
        log.Fatal(err)
    }
}
```

## Ensure Graph Exists Pattern

```go
func ensureGraph(ctx context.Context, client *gqldb.Client, name string, graphType gqldb.GraphType, description string) (*gqldb.GraphInfo, error) {
    info, err := client.GetGraphInfo(ctx, name)
    if err == nil {
        fmt.Printf("Graph '%s' exists with %d nodes\n", name, info.NodeCount)
        return info, nil
    }

    if !errors.Is(err, gqldb.ErrGraphNotFound) {
        return nil, err
    }

    // Graph doesn't exist, create it
    err = client.CreateGraph(ctx, name, graphType, description)
    if err != nil {
        if errors.Is(err, gqldb.ErrGraphExists) {
            // Race condition: another process created it
            return client.GetGraphInfo(ctx, name)
        }
        return nil, err
    }

    fmt.Printf("Created graph '%s'\n", name)
    return client.GetGraphInfo(ctx, name)
}

// Usage
info, err := ensureGraph(ctx, client, "myGraph", gqldb.GraphTypeOpen, "My application graph")
if err != nil {
    log.Fatal(err)
}
client.UseGraph(ctx, "myGraph")
```

## Working with Multiple Graphs

```go
ctx := context.Background()

// Create multiple graphs
client.CreateGraph(ctx, "users", gqldb.GraphTypeOpen, "")
client.CreateGraph(ctx, "products", gqldb.GraphTypeOpen, "")
client.CreateGraph(ctx, "orders", gqldb.GraphTypeOpen, "")

// Query specific graph without switching
usersConfig := &gqldb.QueryConfig{GraphName: "users"}
productsConfig := &gqldb.QueryConfig{GraphName: "products"}

users, _ := client.Gql(ctx, "MATCH (u:User) RETURN u", usersConfig)
products, _ := client.Gql(ctx, "MATCH (p:Product) RETURN p", productsConfig)

// Or switch between graphs
client.UseGraph(ctx, "users")
// ... work with users

client.UseGraph(ctx, "orders")
// ... work with orders
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

    // List existing graphs
    fmt.Println("=== Existing Graphs ===")
    graphs, _ := client.ListGraphs(ctx)
    for _, graph := range graphs {
        fmt.Printf("  %s (%v)\n", graph.Name, graph.GraphType)
    }

    // Create graphs
    fmt.Println("\n=== Creating Graphs ===")
    graphsToCreate := []struct {
        name        string
        graphType   gqldb.GraphType
        description string
    }{
        {"socialNetwork", gqldb.GraphTypeOpen, "Social connections"},
        {"productCatalog", gqldb.GraphTypeClosed, "Product information"},
        {"knowledgeBase", gqldb.GraphTypeOntology, "Knowledge graph"},
    }

    for _, g := range graphsToCreate {
        err := client.CreateGraph(ctx, g.name, g.graphType, g.description)
        if err != nil {
            if errors.Is(err, gqldb.ErrGraphExists) {
                fmt.Printf("  Exists: %s\n", g.name)
            } else {
                log.Printf("  Failed: %s - %v\n", g.name, err)
            }
        } else {
            fmt.Printf("  Created: %s\n", g.name)
        }
    }

    // Get detailed info
    fmt.Println("\n=== Graph Details ===")
    for _, g := range graphsToCreate {
        info, err := client.GetGraphInfo(ctx, g.name)
        if err != nil {
            fmt.Printf("  %s: Error - %v\n", g.name, err)
            continue
        }
        fmt.Printf("  %s:\n", info.Name)
        fmt.Printf("    Type: %v\n", info.GraphType)
        fmt.Printf("    Description: %s\n", info.Description)
        fmt.Printf("    Nodes: %d\n", info.NodeCount)
        fmt.Printf("    Edges: %d\n", info.EdgeCount)
    }

    // Work with a graph
    fmt.Println("\n=== Working with socialNetwork ===")
    client.UseGraph(ctx, "socialNetwork")

    // Insert data
    client.Gql(ctx, `
        INSERT (a:User {_id: 'u1', name: 'Alice'}),
               (b:User {_id: 'u2', name: 'Bob'}),
               (a)-[:Follows]->(b)
    `, nil)

    // Check updated counts
    info, _ := client.GetGraphInfo(ctx, "socialNetwork")
    fmt.Printf("  After insert: %d nodes, %d edges\n", info.NodeCount, info.EdgeCount)

    // Clean up
    fmt.Println("\n=== Cleanup ===")
    for _, g := range graphsToCreate {
        err := client.DropGraph(ctx, g.name, true)
        if err != nil {
            fmt.Printf("  Failed to drop %s: %v\n", g.name, err)
        } else {
            fmt.Printf("  Dropped: %s\n", g.name)
        }
    }

    // Verify
    fmt.Println("\n=== Final Graph List ===")
    remaining, _ := client.ListGraphs(ctx)
    var names []string
    for _, g := range remaining {
        names = append(names, g.Name)
    }
    fmt.Printf("  Remaining graphs: %v\n", names)
}
```
