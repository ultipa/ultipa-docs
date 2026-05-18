# Data Operations

The GQLDB Go driver provides methods for inserting, updating, and deleting nodes and edges in the graph.

## Data Methods

Go does not support method overloading, so the gRPC bulk path and the GQL emitter live under **separate function names**:

| Function | Backed by | Returns |
|---|---|---|
| `InsertNodes(ctx, graphName, nodes, config?)` | gRPC `InsertNodes` RPC (high-throughput) | `*InsertNodesResult, error` |
| `InsertNodesGql(ctx, nodes, config?)` | GQL `INSERT` statement (convenience) | `*Response, error` |

`InsertNodesBatchAuto` / `InsertEdgesBatchAuto` are **deprecated** aliases for `InsertNodes` / `InsertEdges` (the gRPC path) — kept for short-lived callers that adopted the post-6.0.0 rename. New code should call `InsertNodes` / `InsertEdges` directly.

| Method | Description |
|--------|-------------|
| `InsertNodes(ctx, graphName, nodes, config?)` | Insert nodes via gRPC (high-throughput) |
| `InsertNodesGql(ctx, nodes, config?)` | Insert nodes via GQL INSERT statement |
| `InsertNodesBatchAuto(ctx, graphName, nodes, config?)` | Deprecated alias for `InsertNodes` |
| `InsertEdges(ctx, graphName, edges, config?)` | Insert edges via gRPC (high-throughput) |
| `InsertEdgesGql(ctx, edges, config?)` | Insert edges via GQL INSERT statement |
| `InsertEdgesBatchAuto(ctx, graphName, edges, config?)` | Deprecated alias for `InsertEdges` |
| `DeleteNodes(ctx, graphName, nodeIDs, labels, where)` | Delete nodes |
| `DeleteEdges(ctx, graphName, edgeIDs, label, where)` | Delete edges |

### Choosing a path

| | gRPC path (`InsertNodes`) | GQL path (`InsertNodesGql`) |
|---|---|---|
| Backed by | gRPC `InsertNodes` RPC | GQL `INSERT` statement |
| Bulk session | Required for high throughput (`StartBulkImport`) | Not required |
| Performance | High-throughput for large imports | Good for small batches |
| Custom node `_id` | Supported (`NodeData.ID`) | Supported (`NodeData.ID` → `_id`) |
| Custom edge `_id` | Supported (`EdgeData.ID`) | Supported (`EdgeData.ID` → `_id`) |
| Insert modes | Normal, Overwrite, Upsert (via `Mode`) | Normal, Overwrite, Upsert (via `InsertConfig.InsertType`) |
| Use case | ETL, data migration, bulk loading | Scripts, small batches, Upsert |

> **Custom edge `_id` requires `WITH EDGE_ID` on the target graph.** This is a server-side prerequisite — the graph must have been created with `CREATE GRAPH <name> WITH EDGE_ID` for user-supplied edge `_id`s to be honored on either path. Without it, the server auto-generates edge `_id`s and any value passed via `EdgeData.ID` is ignored.

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
    ID         string                  // Optional custom node _id (auto-generated when empty)
    Labels     []string
    Properties map[string]interface{}
}
```

A non-empty `ID` is written as `_id` on the inserted node (both gRPC and GQL paths).

### Insert Configuration

```go
config := &gqldb.InsertNodesConfig{
    Mode:                gqldb.InsertTypeOverwrite,  // Normal / Overwrite / Upsert
    BulkImportSessionID: "",                          // Bulk import session ID for auto-checkpoint
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
    ID         string                  // Optional custom edge _id; requires WITH EDGE_ID graph
    Label      string
    FromNodeID string
    ToNodeID   string
    Properties map[string]interface{}
}
```

A non-empty `ID` is written as `_id` on the inserted edge (both gRPC and GQL paths). The target graph must have been created with `WITH EDGE_ID` for the server to honor user-supplied edge `_id`s.

### Edge Insert Configuration

```go
config := &gqldb.InsertEdgesConfig{
    SkipInvalidNodes:    true,                        // Skip edges with missing endpoints
    Mode:                gqldb.InsertTypeOverwrite,   // Normal / Overwrite / Upsert
    BulkImportSessionID: "",                          // Bulk import session ID
}

result, err := client.InsertEdges(ctx, "myGraph", edges, config)
```

> Edge `InsertTypeOverwrite` and `InsertTypeUpsert` require `WITH EDGE_ID` enabled on the target graph.

## GQL-based Insert (Convenience)

### InsertNodesGql() / InsertEdgesGql()

These convenience methods generate and execute GQL `INSERT` statements and return the raw `*Response`. They don't require a bulk import session and use the session's current graph (override via `InsertConfig.GraphName`):

```go
client.UseGraph(ctx, "myGraph")

nodes := []gqldb.NodeData{
    {Labels: []string{"Person"}, Properties: map[string]interface{}{"name": "Alice", "age": 30}},
    {Labels: []string{"Person"}, Properties: map[string]interface{}{"name": "Bob", "age": 25}},
    // Custom _id via the ID field
    {ID: "p3", Labels: []string{"Person"}, Properties: map[string]interface{}{"name": "Charlie"}},
}
_, err := client.InsertNodesGql(ctx, nodes, nil)

edges := []gqldb.EdgeData{
    {Label: "Knows", FromNodeID: "id1", ToNodeID: "id2", Properties: map[string]interface{}{"since": 2024}},
    // Custom _id (requires graph created WITH EDGE_ID)
    {ID: "tx-001", Label: "Knows", FromNodeID: "id1", ToNodeID: "id3", Properties: map[string]interface{}{"since": 2025}},
}
_, err = client.InsertEdgesGql(ctx, edges, nil)
```

> GQL `INSERT` only supports a single label per node; if `NodeData.Labels` has multiple entries, only the first is used in the GQL path. Use the gRPC path (`InsertNodes`) for multi-label nodes.

## Per-call Configuration (InsertConfig)

`InsertNodesGql()` and `InsertEdgesGql()` accept an optional `*InsertConfig` for per-call graph routing and insert mode:

```go
cfg := &gqldb.InsertConfig{
    QueryConfig: gqldb.QueryConfig{
        GraphName: "myGraph",
        Timeout:   60,                            // optional per-call timeout (seconds)
    },
    InsertType: gqldb.InsertTypeOverwrite,        // Normal (default), Overwrite, or Upsert
}
client.InsertNodesGql(ctx, nodes, cfg)
client.InsertEdgesGql(ctx, edges, cfg)
```

`InsertConfig` embeds `QueryConfig`, so query-level fields (`GraphName`, `Timeout`, `TransactionID`, etc.) live on the embedded struct.

### InsertType semantics

| Value | Emitted GQL | On duplicate `_id` |
|---|---|---|
| `InsertTypeNormal` (default) | `INSERT` | Error |
| `InsertTypeOverwrite` | `INSERT OVERWRITE` | Replaces the entity wholesale — properties not in the write are **lost** |
| `InsertTypeUpsert` | `UPSERT` | Merges properties — properties not in the write are **preserved** |

`InsertTypeOverwrite` and `InsertTypeUpsert` are different semantics on existing rows; they are not interchangeable.

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

    insertConfig := &gqldb.InsertNodesConfig{Mode: gqldb.InsertTypeOverwrite}
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

    result, _ = client.InsertNodes(ctx, "dataOpsDemo", updatedUsers, &gqldb.InsertNodesConfig{Mode: gqldb.InsertTypeOverwrite})
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
