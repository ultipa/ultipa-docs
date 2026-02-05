# Data Export

The GQLDB Go driver provides streaming export capabilities for efficiently extracting large amounts of data from the database.

## Export Method

| Method | Description |
|--------|-------------|
| `Export(ctx, config, callback)` | Export graph data with streaming |

## Unified Export

### Export()

Export nodes and/or edges in JSON Lines format with streaming:

```go
import (
    "context"
    "fmt"

    gqldb "github.com/gqldb/gqldb-go"
)

ctx := context.Background()

exportConfig := &gqldb.ExportConfig{
    GraphName:       "myGraph",
    BatchSize:       1000,
    ExportNodes:     true,
    ExportEdges:     true,
    IncludeMetadata: true,
}

err := client.Export(ctx, exportConfig, func(result *gqldb.ExportResult) error {
    // Process each chunk of data
    data := string(result.Data)
    lines := strings.Split(data, "\n")

    for _, line := range lines {
        if line != "" {
            fmt.Println(line)
        }
    }

    if result.IsFinal && result.Stats != nil {
        fmt.Printf("\nExport complete:\n")
        fmt.Printf("  Nodes: %d\n", result.Stats.NodesExported)
        fmt.Printf("  Edges: %d\n", result.Stats.EdgesExported)
        fmt.Printf("  Bytes: %d\n", result.Stats.BytesWritten)
        fmt.Printf("  Duration: %dms\n", result.Stats.DurationMs)
    }

    return nil
})

if err != nil {
    log.Fatal(err)
}
```

### ExportConfig Struct

```go
type ExportConfig struct {
    GraphName       string   // Required: target graph
    BatchSize       int32    // Records per chunk (default: 1000)
    ExportNodes     bool     // Include nodes (default: true)
    ExportEdges     bool     // Include edges (default: true)
    NodeLabels      []string // Filter by node labels (empty = all)
    EdgeLabels      []string // Filter by edge labels (empty = all)
    IncludeMetadata bool     // Include metadata in output
}
```

### ExportResult Struct

```go
type ExportResult struct {
    Data    []byte       // JSON Lines data
    IsFinal bool         // Is this the last chunk?
    Stats   *ExportStats // Statistics (on final chunk)
}
```

### ExportStats Struct

```go
type ExportStats struct {
    NodesExported int64
    EdgesExported int64
    BytesWritten  int64
    DurationMs    int64
}
```

## Filtering Exports

### Export Specific Labels

```go
// Export only User nodes and Follows edges
exportConfig := &gqldb.ExportConfig{
    GraphName:   "socialGraph",
    ExportNodes: true,
    ExportEdges: true,
    NodeLabels:  []string{"User", "Company"},
    EdgeLabels:  []string{"Follows", "WorksAt"},
}

client.Export(ctx, exportConfig, processChunk)
```

### Export Only Nodes

```go
exportConfig := &gqldb.ExportConfig{
    GraphName:   "myGraph",
    ExportNodes: true,
    ExportEdges: false,
}

client.Export(ctx, exportConfig, processChunk)
```

### Export Only Edges

```go
exportConfig := &gqldb.ExportConfig{
    GraphName:   "myGraph",
    ExportNodes: false,
    ExportEdges: true,
}

client.Export(ctx, exportConfig, processChunk)
```

## Writing to File

```go
import (
    "bufio"
    "os"
)

func exportToFile(ctx context.Context, client *gqldb.Client, graphName, outputPath string) error {
    file, err := os.Create(outputPath)
    if err != nil {
        return err
    }
    defer file.Close()

    writer := bufio.NewWriter(file)

    exportConfig := &gqldb.ExportConfig{
        GraphName:   graphName,
        BatchSize:   5000,
        ExportNodes: true,
        ExportEdges: true,
    }

    err = client.Export(ctx, exportConfig, func(result *gqldb.ExportResult) error {
        _, err := writer.Write(result.Data)
        if err != nil {
            return err
        }

        if result.IsFinal {
            writer.Flush()
            if result.Stats != nil {
                fmt.Printf("Export complete: %d nodes, %d edges\n",
                    result.Stats.NodesExported, result.Stats.EdgesExported)
            }
        }

        return nil
    })

    return err
}

// Usage
err := exportToFile(ctx, client, "myGraph", "export.jsonl")
```

## Collecting to Memory

```go
import (
    "encoding/json"
    "strings"
)

func exportToMemory(ctx context.Context, client *gqldb.Client, graphName string) (map[string][]map[string]interface{}, error) {
    nodes := make([]map[string]interface{}, 0)
    edges := make([]map[string]interface{}, 0)

    exportConfig := &gqldb.ExportConfig{
        GraphName:   graphName,
        BatchSize:   1000,
        ExportNodes: true,
        ExportEdges: true,
    }

    err := client.Export(ctx, exportConfig, func(result *gqldb.ExportResult) error {
        data := string(result.Data)
        lines := strings.Split(data, "\n")

        for _, line := range lines {
            if line == "" {
                continue
            }

            var record map[string]interface{}
            if err := json.Unmarshal([]byte(line), &record); err != nil {
                continue
            }

            recordType, _ := record["_type"].(string)
            if recordType == "node" {
                nodes = append(nodes, record)
            } else if recordType == "edge" {
                edges = append(edges, record)
            }
        }

        return nil
    })

    if err != nil {
        return nil, err
    }

    fmt.Printf("Collected %d nodes and %d edges\n", len(nodes), len(edges))

    return map[string][]map[string]interface{}{
        "nodes": nodes,
        "edges": edges,
    }, nil
}
```

## Complete Example

```go
package main

import (
    "bufio"
    "context"
    "encoding/json"
    "fmt"
    "log"
    "os"
    "strings"
    "time"

    gqldb "github.com/gqldb/gqldb-go"
)

func main() {
    config := gqldb.NewConfigBuilder().
        Hosts("192.168.1.100:9000").
        Timeout(60 * time.Second).
        Build()

    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Close()

    ctx := context.Background()
    client.Login(ctx, "admin", "password")

    // Create and populate test graph
    client.CreateGraph(ctx, "exportDemo", gqldb.GraphTypeOpen, "")
    client.UseGraph(ctx, "exportDemo")

    // Insert test data
    client.Gql(ctx, `
        INSERT (a:User {_id: 'u1', name: 'Alice', age: 30}),
               (b:User {_id: 'u2', name: 'Bob', age: 25}),
               (c:Company {_id: 'c1', name: 'Acme Inc'}),
               (a)-[:Follows {since: '2023-01-01'}]->(b),
               (a)-[:WorksAt {role: 'Engineer'}]->(c)
    `, nil)

    // Export to file
    fmt.Println("=== Export to File ===")
    outputPath := "graph-export.jsonl"
    totalRecords := int64(0)

    file, _ := os.Create(outputPath)
    defer file.Close()
    writer := bufio.NewWriter(file)

    exportConfig := &gqldb.ExportConfig{
        GraphName:       "exportDemo",
        BatchSize:       100,
        ExportNodes:     true,
        ExportEdges:     true,
        IncludeMetadata: true,
    }

    err = client.Export(ctx, exportConfig, func(result *gqldb.ExportResult) error {
        writer.Write(result.Data)

        // Count records
        data := string(result.Data)
        for _, line := range strings.Split(data, "\n") {
            if line != "" {
                totalRecords++
            }
        }

        if result.IsFinal {
            writer.Flush()
            fmt.Printf("  Records exported: %d\n", totalRecords)
            if result.Stats != nil {
                fmt.Printf("  Nodes: %d\n", result.Stats.NodesExported)
                fmt.Printf("  Edges: %d\n", result.Stats.EdgesExported)
                fmt.Printf("  Size: %d bytes\n", result.Stats.BytesWritten)
            }
        }

        return nil
    })

    if err != nil {
        log.Fatal(err)
    }

    // Read and display the file
    fmt.Println("\n=== Exported Data ===")
    file.Seek(0, 0)
    scanner := bufio.NewScanner(file)
    for scanner.Scan() {
        fmt.Println("  " + scanner.Text())
    }

    // Export filtered data
    fmt.Println("\n=== Export Only Users ===")
    filteredConfig := &gqldb.ExportConfig{
        GraphName:   "exportDemo",
        ExportNodes: true,
        ExportEdges: false,
        NodeLabels:  []string{"User"},
    }

    client.Export(ctx, filteredConfig, func(result *gqldb.ExportResult) error {
        for _, line := range strings.Split(string(result.Data), "\n") {
            if line == "" {
                continue
            }
            var record map[string]interface{}
            json.Unmarshal([]byte(line), &record)
            if props, ok := record["properties"].(map[string]interface{}); ok {
                fmt.Printf("  User: %v\n", props["name"])
            }
        }
        return nil
    })

    // Export to memory
    fmt.Println("\n=== Export to Memory ===")
    nodes := make([]map[string]interface{}, 0)
    edges := make([]map[string]interface{}, 0)

    memoryConfig := &gqldb.ExportConfig{
        GraphName:   "exportDemo",
        BatchSize:   1000,
        ExportNodes: true,
        ExportEdges: true,
    }

    client.Export(ctx, memoryConfig, func(result *gqldb.ExportResult) error {
        for _, line := range strings.Split(string(result.Data), "\n") {
            if line == "" {
                continue
            }
            var record map[string]interface{}
            json.Unmarshal([]byte(line), &record)

            recordType, _ := record["_type"].(string)
            if recordType == "node" {
                nodes = append(nodes, record)
            } else if recordType == "edge" {
                edges = append(edges, record)
            }
        }
        return nil
    })

    fmt.Printf("  Collected: %d nodes, %d edges\n", len(nodes), len(edges))

    // Cleanup
    os.Remove(outputPath)
    client.DropGraph(ctx, "exportDemo", true)
}
```
