# Bulk Import

The GQLDB Go driver provides bulk import functionality for high-throughput data ingestion with optimized write performance.

## Bulk Import Methods

| Method | Description |
|--------|-------------|
| `StartBulkImport(ctx, graphName, opts)` | Start a bulk import session |
| `EndBulkImport(ctx, sessionID)` | End session |
| `AbortBulkImport(ctx, sessionID)` | Cancel session without final sync |
| `GetBulkImportStatus(ctx, sessionID)` | Get session status |

## Basic Usage

```go
import (
    "context"

    gqldb "github.com/ultipa/ultipa-go-driver/v6"
)

ctx := context.Background()

// Start bulk import session
opts := &gqldb.BulkImportOptions{}

session, err := client.StartBulkImport(ctx, "myGraph", opts)
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Session ID: %s\n", session.SessionID)

// Insert nodes with bulk import session ID
nodeConfig := &gqldb.InsertNodesConfig{
    BulkImportSessionID: session.SessionID,
}

for _, batch := range nodeBatches {
    _, err := client.InsertNodes(ctx, "myGraph", batch, nodeConfig)
    if err != nil {
        client.AbortBulkImport(ctx, session.SessionID)
        log.Fatal(err)
    }
}

// Insert edges
edgeConfig := &gqldb.InsertEdgesConfig{
    BulkImportSessionID: session.SessionID,
}

for _, batch := range edgeBatches {
    _, err := client.InsertEdges(ctx, "myGraph", batch, edgeConfig)
    if err != nil {
        client.AbortBulkImport(ctx, session.SessionID)
        log.Fatal(err)
    }
}

// End session
result, err := client.EndBulkImport(ctx, session.SessionID)
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Import complete: %d total records\n", result.TotalRecords)
```

## Starting a Bulk Import Session

### StartBulkImport()

```go
opts := &gqldb.BulkImportOptions{
    EstimatedNodes:  1000000,     // Hint for pre-allocating node ID cache
    EstimatedEdges:  5000000,     // Hint for edge batch sizing
}

session, err := client.StartBulkImport(ctx, "myGraph", opts)
```

### BulkImportSession Struct

```go
type BulkImportSession struct {
    SessionID string
    Success   bool
    Message   string
}
```

## Ending a Bulk Import

### EndBulkImport()

Complete the bulk import session:

```go
result, err := client.EndBulkImport(ctx, session.SessionID)
if err != nil {
    log.Fatal(err)
}

fmt.Printf("Bulk import completed:\n")
fmt.Printf("  Success: %v\n", result.Success)
fmt.Printf("  Total records: %d\n", result.TotalRecords)
fmt.Printf("  Message: %s\n", result.Message)
```

### AbortBulkImport()

Cancel the bulk import session:

```go
result, err := client.AbortBulkImport(ctx, session.SessionID)
if err != nil {
    log.Printf("Abort failed: %v", err)
}
fmt.Printf("Bulk import aborted: %s\n", result.Message)
```

## Monitoring Status

### GetBulkImportStatus()

```go
status, err := client.GetBulkImportStatus(ctx, session.SessionID)
if err != nil {
    log.Fatal(err)
}

fmt.Printf("Session: %s\n", status.GraphName)
fmt.Printf("Active: %v\n", status.IsActive)
fmt.Printf("Records: %d\n", status.RecordCount)
fmt.Printf("Created: %d\n", status.CreatedAt)
fmt.Printf("Last activity: %d\n", status.LastActivity)
```

## Batch Processing Pattern

```go
func batchGenerator(items []*gqldb.NodeData, batchSize int) [][]*gqldb.NodeData {
    var batches [][]*gqldb.NodeData
    for i := 0; i < len(items); i += batchSize {
        end := i + batchSize
        if end > len(items) {
            end = len(items)
        }
        batches = append(batches, items[i:end])
    }
    return batches
}

func bulkImportData(ctx context.Context, client *gqldb.Client, graphName string,
    nodes []*gqldb.NodeData, edges []*gqldb.EdgeData, batchSize int) (*gqldb.EndBulkImportResult, error) {

    opts := &gqldb.BulkImportOptions{
        EstimatedNodes: int64(len(nodes)),
        EstimatedEdges: int64(len(edges)),
    }

    session, err := client.StartBulkImport(ctx, graphName, opts)
    if err != nil {
        return nil, err
    }

    // Import nodes
    nodeConfig := &gqldb.InsertNodesConfig{BulkImportSessionID: session.SessionID}
    totalNodes := int64(0)

    for _, batch := range batchGenerator(nodes, batchSize) {
        result, err := client.InsertNodes(ctx, graphName, batch, nodeConfig)
        if err != nil {
            client.AbortBulkImport(ctx, session.SessionID)
            return nil, err
        }
        totalNodes += result.NodeCount
        fmt.Printf("Imported %d nodes...\n", totalNodes)
    }

    // Import edges
    edgeConfig := &gqldb.InsertEdgesConfig{BulkImportSessionID: session.SessionID}
    totalEdges := int64(0)

    edgeBatches := batchEdges(edges, batchSize)
    for _, batch := range edgeBatches {
        result, err := client.InsertEdges(ctx, graphName, batch, edgeConfig)
        if err != nil {
            client.AbortBulkImport(ctx, session.SessionID)
            return nil, err
        }
        totalEdges += result.EdgeCount
        fmt.Printf("Imported %d edges...\n", totalEdges)
    }

    // Complete
    return client.EndBulkImport(ctx, session.SessionID)
}
```

## Result Structs

### EndBulkImportResult

```go
type EndBulkImportResult struct {
    Success      bool
    TotalRecords int64
    Message      string
}
```

### AbortBulkImportResult

```go
type AbortBulkImportResult struct {
    Success bool
    Message string
}
```

### BulkImportStatus

```go
type BulkImportStatus struct {
    IsActive     bool
    GraphName    string
    RecordCount  int64
    CreatedAt    int64
    LastActivity int64
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

func generateTestData(numNodes, numEdges int) ([]*gqldb.NodeData, []*gqldb.EdgeData) {
    nodes := make([]*gqldb.NodeData, numNodes)
    for i := 0; i < numNodes; i++ {
        nodes[i] = &gqldb.NodeData{
            ID:     fmt.Sprintf("n%d", i),
            Labels: []string{"TestNode"},
            Properties: map[string]interface{}{
                "index": int64(i),
                "value": fmt.Sprintf("value_%d", i),
            },
        }
    }

    edges := make([]*gqldb.EdgeData, numEdges)
    for i := 0; i < numEdges; i++ {
        edges[i] = &gqldb.EdgeData{
            Label:      "TestEdge",
            FromNodeID: fmt.Sprintf("n%d", i%numNodes),
            ToNodeID:   fmt.Sprintf("n%d", (i+1)%numNodes),
            Properties: map[string]interface{}{
                "weight": float64(i) * 0.1,
            },
        }
    }

    return nodes, edges
}

func main() {
    config := gqldb.NewConfigBuilder().
        Hosts("localhost:9000").
        Timeout(5 * time.Minute).
        Build()

    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Close()

    ctx := context.Background()
    client.Login(ctx, "admin", "password")
    client.CreateGraph(ctx, "bulkDemo", gqldb.GraphTypeOpen, "")
    client.UseGraph(ctx, "bulkDemo")

    // Generate test data
    fmt.Println("=== Generating Test Data ===")
    numNodes := 100000
    numEdges := 500000
    nodes, edges := generateTestData(numNodes, numEdges)
    fmt.Printf("  Generated %d nodes and %d edges\n", len(nodes), len(edges))

    // Start bulk import
    fmt.Println("\n=== Starting Bulk Import ===")
    startTime := time.Now()

    opts := &gqldb.BulkImportOptions{
        EstimatedNodes:  int64(numNodes),
        EstimatedEdges:  int64(numEdges),
    }

    session, err := client.StartBulkImport(ctx, "bulkDemo", opts)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("  Session ID: %s\n", session.SessionID)

    // Import nodes in batches
    fmt.Println("\n=== Importing Nodes ===")
    batchSize := 10000
    importedNodes := int64(0)
    nodeConfig := &gqldb.InsertNodesConfig{BulkImportSessionID: session.SessionID}

    for i := 0; i < len(nodes); i += batchSize {
        end := i + batchSize
        if end > len(nodes) {
            end = len(nodes)
        }
        batch := nodes[i:end]

        result, err := client.InsertNodes(ctx, "bulkDemo", batch, nodeConfig)
        if err != nil {
            client.AbortBulkImport(ctx, session.SessionID)
            log.Fatal(err)
        }
        importedNodes += result.NodeCount

        if importedNodes%50000 == 0 {
            status, _ := client.GetBulkImportStatus(ctx, session.SessionID)
            fmt.Printf("  Progress: %d nodes, pending: %d\n", importedNodes, status.RecordCount)
        }
    }
    fmt.Printf("  Total nodes imported: %d\n", importedNodes)

    // Import edges in batches
    fmt.Println("\n=== Importing Edges ===")
    importedEdges := int64(0)
    edgeConfig := &gqldb.InsertEdgesConfig{BulkImportSessionID: session.SessionID}

    for i := 0; i < len(edges); i += batchSize {
        end := i + batchSize
        if end > len(edges) {
            end = len(edges)
        }
        batch := edges[i:end]

        result, err := client.InsertEdges(ctx, "bulkDemo", batch, edgeConfig)
        if err != nil {
            client.AbortBulkImport(ctx, session.SessionID)
            log.Fatal(err)
        }
        importedEdges += result.EdgeCount

        if importedEdges%100000 == 0 {
            fmt.Printf("  Progress: %d edges\n", importedEdges)
        }
    }
    fmt.Printf("  Total edges imported: %d\n", importedEdges)

    // End bulk import
    fmt.Println("\n=== Completing Bulk Import ===")
    endResult, err := client.EndBulkImport(ctx, session.SessionID)
    if err != nil {
        log.Fatal(err)
    }

    elapsed := time.Since(startTime)
    fmt.Printf("  Completed in %.2f seconds\n", elapsed.Seconds())
    fmt.Printf("  Total records: %d\n", endResult.TotalRecords)

    // Verify
    fmt.Println("\n=== Verification ===")
    response, _ := client.Gql(ctx, "MATCH (n:TestNode) RETURN count(n)", nil)
    nodeCount, _ := response.SingleInt()
    fmt.Printf("  Node count: %d\n", nodeCount)

    response, _ = client.Gql(ctx, "MATCH ()-[e:TestEdge]->() RETURN count(e)", nil)
    edgeCount, _ := response.SingleInt()
    fmt.Printf("  Edge count: %d\n", edgeCount)

    // Cleanup
    client.DropGraph(ctx, "bulkDemo", true)
}
```
