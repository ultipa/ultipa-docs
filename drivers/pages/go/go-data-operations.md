# Data Operations

The GQLDB Go driver provides methods for inserting, updating, and deleting nodes and edges in the graph.

## Data Methods

| Method | Description |
|--------|-------------|
| `InsertNodes(ctx, nodes, config)` | Insert nodes via GQL INSERT statement |
| `InsertNodesBatchAuto(ctx, graphName, nodes, config)` | Insert nodes via gRPC (high-throughput) |
| `InsertEdges(ctx, edges, config)` | Insert edges via GQL INSERT statement |
| `InsertEdgesBatchAuto(ctx, graphName, edges, config)` | Insert edges via gRPC (high-throughput) |
| `DeleteNodes(ctx, graphName, nodeIDs, labels, where)` | Delete nodes |
| `DeleteEdges(ctx, graphName, edgeIDs, label, where)` | Delete edges |

### InsertNodes vs InsertNodesBatchAuto

| | `InsertNodes` | `InsertNodesBatchAuto` |
|---|---|---|
| Method | GQL `INSERT` statement | gRPC `InsertNodes` RPC |
| Bulk session | Not required | Required (`StartBulkImport`) |
| Performance | Good for small batches | High-throughput for large imports |
| Custom node ID | Not supported | Supported (`NodeData.ID`) |
| Use case | Simple inserts, scripts | ETL, data migration, bulk loading |

## Inserting Nodes (gRPC Batch)

### InsertNodesBatchAuto()

Insert multiple nodes into a graph:

```go
import (
    "context"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

ctx := context.Background()

// Create node data
nodes := []*gqldb.NodeData{
    {
        ID:     "u1",
        Labels: []string{"User"},
        Properties: map[string]interface{}{
            "name":  "Alice",
            "age":   30,
            "email": "alice@example.com",
        },
    },
    {
        ID:     "u2",
        Labels: []string{"User"},
        Properties: map[string]interface{}{
            "name":  "Bob",
            "age":   25,
            "email": "bob@example.com",
        },
    },
    {
        ID:     "u3",
        Labels: []string{"User", "Admin"},
        Properties: map[string]interface{}{
            "name": "Charlie",
            "age":  35,
        },
    },
}

// Insert nodes
result, err := client.InsertNodes(ctx, "myGraph", nodes, nil)
if err != nil {
    log.Fatal(err)
}

fmt.Printf("Success: %v\n", result.Success)
fmt.Printf("Inserted: %d nodes\n", result.NodeCount)
fmt.Printf("Node IDs: %v\n", result.NodeIDs)
```

### NodeData Struct

```go
type NodeData struct {
    ID         string
    Labels     []string
    Properties map[string]interface{}
}
```

### Insert Configuration

```go
config := &gqldb.InsertNodesConfig{
    Overwrite:           true,  // Update if exists, insert if not
    BulkImportSessionID: "",    // Bulk import session ID for auto-checkpoint
}

result, err := client.InsertNodes(ctx, "myGraph", nodes, config)
```

## Inserting Edges

### InsertEdges()

Insert multiple edges into a graph:

```go
edges := []*gqldb.EdgeData{
    {
        Label:      "Follows",
        FromNodeID: "u1",
        ToNodeID:   "u2",
        Properties: map[string]interface{}{
            "since": "2023-01-15",
        },
    },
    {
        Label:      "Follows",
        FromNodeID: "u2",
        ToNodeID:   "u3",
        Properties: map[string]interface{}{
            "since": "2023-06-20",
        },
    },
    {
        Label:      "Knows",
        FromNodeID: "u1",
        ToNodeID:   "u3",
        Properties: map[string]interface{}{
            "years": 5,
        },
    },
}

result, err := client.InsertEdges(ctx, "myGraph", edges, nil)
if err != nil {
    log.Fatal(err)
}

fmt.Printf("Success: %v\n", result.Success)
fmt.Printf("Inserted: %d edges\n", result.EdgeCount)
fmt.Printf("Skipped: %d\n", result.SkippedCount)
```

### EdgeData Struct

```go
type EdgeData struct {
    Label      string
    FromNodeID string
    ToNodeID   string
    Properties map[string]interface{}
}
```

### Edge Insert Configuration

```go
config := &gqldb.InsertEdgesConfig{
    SkipInvalidNodes:    true,  // Skip edges with missing endpoints
    BulkImportSessionID: "",    // Bulk import session ID
}

result, err := client.InsertEdges(ctx, "myGraph", edges, config)
```

## GQL-based Insert (Convenience)

### InsertNodes() / InsertEdges()

These convenience methods generate and execute GQL `INSERT` statements. They don't require a bulk import session and use the session's current graph:

```go
client.UseGraph(ctx, "myGraph")

nodes := []gqldb.NodeData{
    {Labels: []string{"Person"}, Properties: map[string]interface{}{"name": "Alice", "age": 30}},
    {Labels: []string{"Person"}, Properties: map[string]interface{}{"name": "Bob", "age": 25}},
}
_, err := client.InsertNodes(ctx, nodes, nil)

edges := []gqldb.EdgeData{
    {Label: "Knows", FromNodeID: "id1", ToNodeID: "id2", Properties: map[string]interface{}{"since": 2024}},
}
_, err = client.InsertEdges(ctx, edges, nil)
```

## Per-call Configuration (InsertConfig)

`InsertNodes()` and `InsertEdges()` accept an optional `InsertConfig` for per-call graph routing and insert mode:

```go
cfg := &gqldb.InsertConfig{
    GraphName:  "myGraph",
    InsertType: gqldb.InsertTypeOverwrite,  // InsertTypeNormal (default) or InsertTypeOverwrite
    Timeout:    60,                         // optional per-call timeout (seconds)
}
client.InsertNodes(ctx, nodes, cfg)
client.InsertEdges(ctx, edges, cfg)
```

All other convenience methods accept `*QueryConfig` the same way:

```go
qc := &gqldb.QueryConfig{GraphName: "graphA"}
client.ShowNodeLabels(ctx, qc)
client.CreateNodeLabel(ctx, "User", props, qc)
client.Gql(ctx, "MATCH (n) RETURN n", &gqldb.QueryConfig{GraphName: "graphC", Timeout: 10})
```

## Deleting Nodes

### DeleteNodes()

Delete nodes from the graph:

```go
// Delete by IDs
result, err := client.DeleteNodes(ctx, "myGraph", []string{"u1", "u2", "u3"}, nil, "")
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Deleted: %d nodes\n", result.DeletedCount)

// Delete by labels
result, err = client.DeleteNodes(ctx, "myGraph", nil, []string{"TempUser"}, "")

// Delete with WHERE clause
result, err = client.DeleteNodes(ctx, "myGraph", nil, []string{"User"}, "n.age < 18")

// Combine filters
result, err = client.DeleteNodes(ctx, "myGraph", []string{"u1", "u2"}, []string{"User"}, "n.status = 'inactive'")
```

## Deleting Edges

### DeleteEdges()

Delete edges from the graph:

```go
// Delete by IDs
result, err := client.DeleteEdges(ctx, "myGraph", []string{"e1", "e2"}, "", "")
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Deleted: %d edges\n", result.DeletedCount)

// Delete by label
result, err = client.DeleteEdges(ctx, "myGraph", nil, "TempConnection", "")

// Delete with WHERE clause
result, err = client.DeleteEdges(ctx, "myGraph", nil, "Follows", "e.since < '2020-01-01'")
```

## Using GQL for Data Operations

You can also use GQL queries for data operations:

```go
// Insert with GQL
_, err := client.Gql(ctx, `
    INSERT (a:User {_id: 'u1', name: 'Alice'}),
           (b:User {_id: 'u2', name: 'Bob'}),
           (a)-[:Follows {since: '2024-01-01'}]->(b)
`, nil)

// Update with GQL
_, err = client.Gql(ctx, "MATCH (u:User {_id: 'u1'}) SET u.age = 31", nil)

// Delete with GQL
_, err = client.Gql(ctx, "MATCH (u:User {_id: 'u1'}) DELETE u", nil)
```

## Result Structs

### InsertNodesResult

```go
type InsertNodesResult struct {
    Success   bool
    NodeIDs   []string
    NodeCount int64
    Message   string
}
```

### InsertEdgesResult

```go
type InsertEdgesResult struct {
    Success      bool
    EdgeIDs      []string
    EdgeCount    int64
    Message      string
    SkippedCount int64
}
```

### DeleteResult

```go
type DeleteResult struct {
    Success      bool
    DeletedCount int64
    Message      string
}
```

## Error Handling

```go
import (
    "errors"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

result, err := client.InsertNodes(ctx, "myGraph", nodes, nil)
if err != nil {
    if errors.Is(err, gqldb.ErrInsertFailed) {
        log.Printf("Insert failed: %v", err)
    } else if errors.Is(err, gqldb.ErrGraphNotFound) {
        log.Println("Graph not found")
    } else {
        log.Printf("Error: %v", err)
    }
    return
}

if !result.Success {
    log.Printf("Insert warning: %s", result.Message)
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
        Build()

    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Close()

    ctx := context.Background()
    client.Login(ctx, "admin", "password")
    client.CreateGraph(ctx, "dataOpsDemo", gqldb.GraphTypeOpen, "")
    client.UseGraph(ctx, "dataOpsDemo")

    // Insert nodes
    fmt.Println("=== Inserting Nodes ===")
    users := []*gqldb.NodeData{
        {ID: "u1", Labels: []string{"User"}, Properties: map[string]interface{}{"name": "Alice", "age": int64(30), "active": true}},
        {ID: "u2", Labels: []string{"User"}, Properties: map[string]interface{}{"name": "Bob", "age": int64(25), "active": true}},
        {ID: "u3", Labels: []string{"User"}, Properties: map[string]interface{}{"name": "Charlie", "age": int64(35), "active": false}},
        {ID: "u4", Labels: []string{"User", "Admin"}, Properties: map[string]interface{}{"name": "Diana", "age": int64(28), "active": true}},
    }

    insertConfig := &gqldb.InsertNodesConfig{Overwrite: true}
    result, err := client.InsertNodes(ctx, "dataOpsDemo", users, insertConfig)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("  Inserted %d users\n", result.NodeCount)

    // Insert edges
    fmt.Println("\n=== Inserting Edges ===")
    relationships := []*gqldb.EdgeData{
        {Label: "Follows", FromNodeID: "u1", ToNodeID: "u2", Properties: map[string]interface{}{"since": "2023-01"}},
        {Label: "Follows", FromNodeID: "u2", ToNodeID: "u3", Properties: map[string]interface{}{"since": "2023-03"}},
        {Label: "Follows", FromNodeID: "u1", ToNodeID: "u4", Properties: map[string]interface{}{"since": "2023-06"}},
        {Label: "Knows", FromNodeID: "u3", ToNodeID: "u4", Properties: map[string]interface{}{"years": int64(3)}},
    }

    edgeConfig := &gqldb.InsertEdgesConfig{SkipInvalidNodes: true}
    edgeResult, err := client.InsertEdges(ctx, "dataOpsDemo", relationships, edgeConfig)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("  Inserted %d relationships\n", edgeResult.EdgeCount)

    // Verify data
    fmt.Println("\n=== Current Data ===")
    response, _ := client.Gql(ctx, "MATCH (n:User) RETURN n.name, n.age, n.active ORDER BY n.name", nil)
    for _, row := range response.Rows {
        name, _ := row.GetString(0)
        age, _ := row.GetInt(1)
        active, _ := row.GetBool(2)
        fmt.Printf("  %s: age=%d, active=%v\n", name, age, active)
    }

    response, _ = client.Gql(ctx, "MATCH ()-[e]->() RETURN type(e), count(e)", nil)
    for _, row := range response.Rows {
        edgeType, _ := row.GetString(0)
        count, _ := row.GetInt(1)
        fmt.Printf("  %s: %d edges\n", edgeType, count)
    }

    // Update with upsert
    fmt.Println("\n=== Upsert (Update Existing) ===")
    updatedUsers := []*gqldb.NodeData{
        {ID: "u1", Labels: []string{"User"}, Properties: map[string]interface{}{"name": "Alice", "age": int64(31), "active": true}},
        {ID: "u5", Labels: []string{"User"}, Properties: map[string]interface{}{"name": "Eve", "age": int64(22), "active": true}},
    }

    result, _ = client.InsertNodes(ctx, "dataOpsDemo", updatedUsers, &gqldb.InsertNodesConfig{Overwrite: true})
    fmt.Printf("  Upserted %d users\n", result.NodeCount)

    // Delete inactive users
    fmt.Println("\n=== Delete Inactive Users ===")
    delResult, err := client.DeleteNodes(ctx, "dataOpsDemo", nil, []string{"User"}, "n.active = false")
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("  Deleted %d inactive users\n", delResult.DeletedCount)

    // Delete specific edges
    fmt.Println("\n=== Delete Old Relationships ===")
    delResult, err = client.DeleteEdges(ctx, "dataOpsDemo", nil, "Follows", "e.since < '2023-04'")
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("  Deleted %d old relationships\n", delResult.DeletedCount)

    // Final state
    fmt.Println("\n=== Final Data ===")
    response, _ = client.Gql(ctx, "MATCH (n:User) RETURN n.name ORDER BY n.name", nil)
    var names []string
    for _, row := range response.Rows {
        name, _ := row.GetString(0)
        names = append(names, name)
    }
    fmt.Printf("  Users: %v\n", names)

    response, _ = client.Gql(ctx, "MATCH ()-[e]->() RETURN count(e)", nil)
    count, _ := response.SingleInt()
    fmt.Printf("  Edges: %d\n", count)

    // Cleanup
    client.DropGraph(ctx, "dataOpsDemo", true)
}
```
