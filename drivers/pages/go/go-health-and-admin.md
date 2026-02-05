# Health and Administration

The GQLDB Go driver provides methods for monitoring server health, managing caches, and gathering statistics.

## Health Service Methods

| Method | Description |
|--------|-------------|
| `HealthCheck(ctx, service)` | Check the health status of the server |
| `Watch(ctx, service)` | Return a HealthWatcher for streaming status |
| `WatchWithCallback(ctx, service, callback)` | Stream health status with callback |

## Admin Service Methods

| Method | Description |
|--------|-------------|
| `WarmupParser(ctx, count)` | Pre-allocate parser instances |
| `GetCacheStats(ctx, cacheType)` | Get cache statistics |
| `ClearCache(ctx, cacheType)` | Clear specified caches |
| `GetStatistics(ctx, graphName)` | Get database statistics |
| `InvalidatePermissionCache(ctx, username)` | Invalidate RBAC permission cache |
| `WaitForComputeTopology(ctx, graphName, timeout)` | Wait for compute engine readiness |

## Health Checks

### HealthCheck()

Check the current health status of the server:

```go
import (
    "context"

    gqldb "github.com/gqldb/gqldb-go"
)

ctx := context.Background()

// Check overall server health
status, err := client.HealthCheck(ctx, "")
if err != nil {
    log.Fatal(err)
}

switch status {
case gqldb.HealthStatusServing:
    fmt.Println("Server is healthy and serving requests")
case gqldb.HealthStatusNotServing:
    fmt.Println("Server is not serving requests")
case gqldb.HealthStatusServiceUnknown:
    fmt.Println("Service status is unknown")
default:
    fmt.Println("Health status is unknown")
}

// Check specific service health
queryStatus, err := client.HealthCheck(ctx, "query")
fmt.Printf("Query service: %v\n", queryStatus)
```

### HealthStatus Constants

```go
const (
    HealthStatusUnknown        // Status unknown
    HealthStatusServing        // Healthy and serving
    HealthStatusNotServing     // Not serving requests
    HealthStatusServiceUnknown // Service status unknown
)
```

### Watch()

Get a `HealthWatcher` for monitoring health status changes:

```go
ctx, cancel := context.WithCancel(context.Background())
defer cancel()

watcher, err := client.Watch(ctx, "")
if err != nil {
    log.Fatal(err)
}

// Read status updates from channel
go func() {
    for status := range watcher.Status {
        fmt.Printf("Health status changed: %v\n", status)

        if status != gqldb.HealthStatusServing {
            fmt.Println("WARNING: Server is not healthy!")
        }
    }
}()

// Wait for done signal or error
select {
case err := <-watcher.Done:
    if err != nil {
        fmt.Printf("Watch error: %v\n", err)
    }
case <-time.After(5 * time.Minute):
    cancel()  // Stop watching after 5 minutes
}
```

### HealthWatcher Struct

```go
type HealthWatcher struct {
    Status chan HealthStatus  // Channel receiving status updates
    Done   chan error         // Channel signaling completion
}
```

### WatchWithCallback()

Monitor health with a callback function:

```go
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
defer cancel()

err := client.WatchWithCallback(ctx, "", func(status gqldb.HealthStatus) error {
    fmt.Printf("Health status: %v\n", status)

    if status != gqldb.HealthStatusServing {
        return fmt.Errorf("server unhealthy: %v", status)
    }
    return nil
})

if err != nil {
    log.Printf("Watch ended: %v", err)
}
```

## Cache Management

### CacheType Constants

```go
const (
    CacheTypeAll  // All caches
    CacheTypeAST  // Abstract Syntax Tree cache
    CacheTypePlan // Query plan cache
)
```

### GetCacheStats()

Get statistics about caches:

```go
// Get all cache stats
allStats, err := client.GetCacheStats(ctx, gqldb.CacheTypeAll)
if err != nil {
    log.Fatal(err)
}

if allStats.ASTStats != nil {
    fmt.Printf("AST Cache:\n")
    fmt.Printf("  Entries: %d\n", allStats.ASTStats.Entries)
    fmt.Printf("  Hits: %d\n", allStats.ASTStats.Hits)
    fmt.Printf("  Misses: %d\n", allStats.ASTStats.Misses)
    fmt.Printf("  Hit Rate: %.2f%%\n", allStats.ASTStats.HitRate*100)
}

if allStats.PlanStats != nil {
    fmt.Printf("Plan Cache:\n")
    fmt.Printf("  Size: %d\n", allStats.PlanStats.Size)
    fmt.Printf("  Hits: %d\n", allStats.PlanStats.Hits)
    fmt.Printf("  Misses: %d\n", allStats.PlanStats.Misses)
    fmt.Printf("  Hit Rate: %.2f%%\n", allStats.PlanStats.HitRate*100)
}
```

### CacheStats Struct

```go
type CacheStats struct {
    ASTStats  *ASTCacheStats
    PlanStats *PlanCacheStats
}

type ASTCacheStats struct {
    Entries   int32
    Hits      uint64
    Misses    uint64
    Evictions uint64
    HitRate   float64
}

type PlanCacheStats struct {
    Size     int32
    Capacity int32
    Hits     uint64
    Misses   uint64
    HitRate  float64
}
```

### ClearCache()

Clear caches to free memory or force recompilation:

```go
// Clear all caches
err := client.ClearCache(ctx, gqldb.CacheTypeAll)
if err != nil {
    log.Fatal(err)
}
fmt.Println("All caches cleared")

// Clear only AST cache
client.ClearCache(ctx, gqldb.CacheTypeAST)

// Clear only plan cache
client.ClearCache(ctx, gqldb.CacheTypePlan)
```

## Parser Warmup

### WarmupParser()

Pre-allocate parser instances for better performance:

```go
// Pre-allocate 10 parser instances
err := client.WarmupParser(ctx, 10)
if err != nil {
    log.Fatal(err)
}
fmt.Println("Parsers warmed up")
```

This is useful before high-load periods to reduce latency from parser initialization.

## Database Statistics

### GetStatistics()

Get statistics about the database or a specific graph:

```go
// Get overall database statistics
dbStats, err := client.GetStatistics(ctx, "")
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Database statistics:\n")
fmt.Printf("  Nodes: %d\n", dbStats.NodeCount)
fmt.Printf("  Edges: %d\n", dbStats.EdgeCount)

// Get statistics for a specific graph
graphStats, err := client.GetStatistics(ctx, "myGraph")
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Graph statistics:\n")
fmt.Printf("  Nodes: %d\n", graphStats.NodeCount)
fmt.Printf("  Edges: %d\n", graphStats.EdgeCount)
```

### Statistics Struct

```go
type Statistics struct {
    NodeCount       uint64
    EdgeCount       uint64
    LabelCounts     map[string]uint64
    EdgeLabelCounts map[string]uint64
}
```

## Permission Cache

### InvalidatePermissionCache()

Invalidate the RBAC (Role-Based Access Control) permission cache:

```go
// Invalidate all permission caches
err := client.InvalidatePermissionCache(ctx, "")
if err != nil {
    log.Fatal(err)
}
fmt.Println("All permission caches invalidated")

// Invalidate cache for a specific user
err = client.InvalidatePermissionCache(ctx, "johndoe")
if err != nil {
    log.Fatal(err)
}
fmt.Println("Permission cache invalidated for johndoe")
```

## Compute Topology

### WaitForComputeTopology()

Wait for the computing engine topology to be ready:

```go
result, err := client.WaitForComputeTopology(ctx, "myGraph", 30*time.Second)
if err != nil {
    log.Fatal(err)
}

if result.Ready {
    fmt.Println("Compute topology is ready")
} else {
    fmt.Printf("Not ready: %s\n", result.Message)
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

    gqldb "github.com/gqldb/gqldb-go"
)

func main() {
    config := gqldb.NewConfigBuilder().
        Hosts("192.168.1.100:9000").
        Timeout(30 * time.Second).
        Build()

    client, err := gqldb.NewClient(config)
    if err != nil {
        log.Fatal(err)
    }
    defer client.Close()

    ctx := context.Background()
    client.Login(ctx, "admin", "password")

    // Health check
    fmt.Println("=== Health Check ===")
    health, err := client.HealthCheck(ctx, "")
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Server status: %v\n", health)

    // Warmup parsers
    fmt.Println("\n=== Parser Warmup ===")
    client.WarmupParser(ctx, 5)
    fmt.Println("Warmed up 5 parser instances")

    // Execute some queries to populate cache
    fmt.Println("\n=== Executing Queries ===")
    client.CreateGraph(ctx, "healthDemo", gqldb.GraphTypeOpen, "")
    client.UseGraph(ctx, "healthDemo")
    client.Gql(ctx, "MATCH (n) RETURN count(n)", nil)
    client.Gql(ctx, "MATCH (n) RETURN count(n)", nil)  // Should hit cache
    client.Gql(ctx, "MATCH (n)-[e]->(m) RETURN count(e)", nil)

    // Check cache stats
    fmt.Println("\n=== Cache Statistics ===")
    cacheStats, _ := client.GetCacheStats(ctx, gqldb.CacheTypeAll)
    if cacheStats.ASTStats != nil {
        fmt.Printf("AST: entries=%d, hits=%d, misses=%d\n",
            cacheStats.ASTStats.Entries,
            cacheStats.ASTStats.Hits,
            cacheStats.ASTStats.Misses)
    }
    if cacheStats.PlanStats != nil {
        fmt.Printf("Plan: size=%d, hits=%d, misses=%d\n",
            cacheStats.PlanStats.Size,
            cacheStats.PlanStats.Hits,
            cacheStats.PlanStats.Misses)
    }

    // Get database statistics
    fmt.Println("\n=== Database Statistics ===")
    dbStats, _ := client.GetStatistics(ctx, "")
    fmt.Printf("Database: nodes=%d, edges=%d\n", dbStats.NodeCount, dbStats.EdgeCount)

    // Start health monitoring
    fmt.Println("\n=== Health Monitoring ===")
    fmt.Println("Monitoring health for 5 seconds...")

    watchCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    watcher, _ := client.Watch(watchCtx, "")
    go func() {
        for status := range watcher.Status {
            fmt.Printf("  Health update: %v\n", status)
        }
    }()

    <-watcher.Done
    fmt.Println("Health monitoring stopped")

    // Clear caches
    fmt.Println("\n=== Clear Caches ===")
    client.ClearCache(ctx, gqldb.CacheTypeAll)
    fmt.Println("All caches cleared")

    // Verify caches are cleared
    clearedStats, _ := client.GetCacheStats(ctx, gqldb.CacheTypeAll)
    fmt.Printf("Cache stats after clear: AST entries=%d\n",
        clearedStats.ASTStats.Entries)

    // Invalidate permission cache
    fmt.Println("\n=== Permission Cache ===")
    client.InvalidatePermissionCache(ctx, "")
    fmt.Println("Permission cache invalidated")

    // Cleanup
    client.DropGraph(ctx, "healthDemo", true)
}
```
