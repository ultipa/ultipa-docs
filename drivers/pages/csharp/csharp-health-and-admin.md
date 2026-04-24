# Health and Administration

The GQLDB C# driver provides methods for monitoring server health, managing caches, and gathering statistics.

## Health Service Methods

| Method | Description |
|--------|-------------|
| `HealthCheckAsync(service)` | Check the health status of the server |
| `WatchAsync(service, callback)` | Stream health status changes |

## Admin Service Methods

| Method | Description |
|--------|-------------|
| `WarmupParserAsync(count)` | Pre-allocate parser instances |
| `GetCacheStatsAsync(cacheType)` | Get cache statistics |
| `ClearCacheAsync(cacheType)` | Clear specified caches |
| `GetStatisticsAsync(graphName)` | Get database statistics |
| `InvalidatePermissionCacheAsync(username)` | Invalidate RBAC permission cache |
| `CompactAsync()` | Trigger database compaction |
| `GetSystemMetricsAsync()` | Get system-level metrics |
| `WaitForComputeTopologyAsync(graphName, timeout)` | Wait for compute engine ready |

## Health Checks

### HealthCheckAsync()

Check the current health status of the server:

```csharp
using Gqldb;
using Gqldb.Types;

var config = new GqldbConfig { Hosts = { "localhost:60061" } };

using var client = new GqldbClient(config);
await client.LoginAsync("admin", "password");

// Check overall server health
var status = await client.HealthCheckAsync();

if (status == HealthStatus.Serving)
    Console.WriteLine("Server is healthy and serving requests");
else if (status == HealthStatus.NotServing)
    Console.WriteLine("Server is not serving requests");
else if (status == HealthStatus.ServiceUnknown)
    Console.WriteLine("Service status is unknown");
else
    Console.WriteLine("Health status is unknown");

// Check specific service health
var queryStatus = await client.HealthCheckAsync("query");
Console.WriteLine($"Query service: {queryStatus}");
```

### HealthStatus Enum

```csharp
using Gqldb.Types;

HealthStatus.Unknown         // Status unknown
HealthStatus.Serving         // Healthy and serving
HealthStatus.NotServing      // Not serving requests
HealthStatus.ServiceUnknown  // Service status unknown
```

### WatchAsync()

Monitor health status changes with a callback:

```csharp
using Gqldb.Types;

await client.WatchAsync("", async status =>
{
    Console.WriteLine($"Health status changed: {status}");

    if (status != HealthStatus.Serving)
    {
        Console.WriteLine("WARNING: Server is not healthy!");
    }
});
```

## Cache Management

### CacheType Enum

```csharp
using Gqldb.Types;

CacheType.All   // All caches
CacheType.Ast   // Abstract Syntax Tree cache
CacheType.Plan  // Query plan cache
```

### GetCacheStatsAsync()

Get statistics about caches:

```csharp
using Gqldb.Types;

// Get all cache stats
var allStats = await client.GetCacheStatsAsync(CacheType.All);
Console.WriteLine($"All cache stats: {allStats}");

// Get AST cache stats
var astStats = await client.GetCacheStatsAsync(CacheType.Ast);
if (astStats.AstStats != null)
{
    Console.WriteLine($"AST cache hits: {astStats.AstStats.Hits}");
    Console.WriteLine($"AST cache misses: {astStats.AstStats.Misses}");
    Console.WriteLine($"AST cache hit rate: {astStats.AstStats.HitRate:P2}");
}

// Get plan cache stats
var planStats = await client.GetCacheStatsAsync(CacheType.Plan);
if (planStats.PlanStats != null)
{
    Console.WriteLine($"Plan cache size: {planStats.PlanStats.Size}");
    Console.WriteLine($"Plan cache capacity: {planStats.PlanStats.Capacity}");
    Console.WriteLine($"Plan cache hit rate: {planStats.PlanStats.HitRate:P2}");
}
```

### CacheStats Classes

```csharp
public class CacheStats
{
    public ASTCacheStats? AstStats { get; set; }
    public PlanCacheStats? PlanStats { get; set; }
}

public class ASTCacheStats
{
    public int Entries { get; set; }
    public ulong Hits { get; set; }
    public ulong Misses { get; set; }
    public ulong Evictions { get; set; }
    public double HitRate { get; set; }
}

public class PlanCacheStats
{
    public int Size { get; set; }
    public int Capacity { get; set; }
    public ulong Hits { get; set; }
    public ulong Misses { get; set; }
    public double HitRate { get; set; }
}
```

### ClearCacheAsync()

Clear caches to free memory or force recompilation:

```csharp
using Gqldb.Types;

// Clear all caches
await client.ClearCacheAsync(CacheType.All);
Console.WriteLine("All caches cleared");

// Clear only AST cache
await client.ClearCacheAsync(CacheType.Ast);
Console.WriteLine("AST cache cleared");

// Clear only plan cache
await client.ClearCacheAsync(CacheType.Plan);
Console.WriteLine("Plan cache cleared");
```

## Parser Warmup

### WarmupParserAsync()

Pre-allocate parser instances for better performance:

```csharp
// Pre-allocate 10 parser instances
await client.WarmupParserAsync(10);
Console.WriteLine("Parsers warmed up");
```

This is useful before high-load periods to reduce latency from parser initialization.

## Database Statistics

### GetStatisticsAsync()

Get statistics about the database or a specific graph:

```csharp
// Get overall database statistics
var dbStats = await client.GetStatisticsAsync();
Console.WriteLine($"Total nodes: {dbStats.NodeCount}");
Console.WriteLine($"Total edges: {dbStats.EdgeCount}");

// Get statistics for a specific graph
var graphStats = await client.GetStatisticsAsync("myGraph");
Console.WriteLine($"Graph nodes: {graphStats.NodeCount}");
Console.WriteLine($"Graph edges: {graphStats.EdgeCount}");
```

### Statistics Class

```csharp
public class Statistics
{
    public ulong NodeCount { get; set; }
    public ulong EdgeCount { get; set; }
    public Dictionary<string, ulong> LabelCounts { get; set; }
    public Dictionary<string, ulong> EdgeLabelCounts { get; set; }
}
```

## System Metrics

### GetSystemMetricsAsync()

Get system-level metrics:

```csharp
var metrics = await client.GetSystemMetricsAsync();

if (metrics.Cpu != null)
{
    Console.WriteLine($"CPU - Process: {metrics.Cpu.ProcessPercent:F1}%, System: {metrics.Cpu.SystemPercent:F1}%");
}

if (metrics.Memory != null)
{
    Console.WriteLine($"Memory - Used: {metrics.Memory.SystemUsedPercent:F1}%");
}

if (metrics.Storage != null)
{
    Console.WriteLine($"Storage - DB size: {metrics.Storage.DbSizeBytes} bytes");
}
```

### SystemMetrics Classes

```csharp
public class SystemMetrics
{
    public CpuMetrics? Cpu { get; set; }
    public MemoryMetrics? Memory { get; set; }
    public DiskIOMetrics? DiskIO { get; set; }
    public StorageMetrics? Storage { get; set; }
    public NetworkMetrics? Network { get; set; }
}
```

## Permission Cache

### InvalidatePermissionCacheAsync()

Invalidate the RBAC permission cache:

```csharp
// Invalidate all permission caches
await client.InvalidatePermissionCacheAsync();
Console.WriteLine("All permission caches invalidated");

// Invalidate cache for a specific user
await client.InvalidatePermissionCacheAsync("johndoe");
Console.WriteLine("Permission cache invalidated for johndoe");
```

Use this after changing user permissions to ensure changes take effect immediately.

## Database Compaction

### CompactAsync()

Trigger database compaction:

```csharp
var (success, message) = await client.CompactAsync();
Console.WriteLine($"Compaction: {(success ? "succeeded" : "failed")} - {message}");
```

## Compute Topology

### WaitForComputeTopologyAsync()

Wait for the compute engine to be ready:

```csharp
var (ready, message) = await client.WaitForComputeTopologyAsync(
    "myGraph",
    TimeSpan.FromSeconds(60)
);
Console.WriteLine($"Compute topology: {(ready ? "ready" : "not ready")} - {message}");
```

## Complete Example

```csharp
using Gqldb;
using Gqldb.Types;

async Task Main()
{
    var config = new GqldbConfig
    {
        Hosts = { "localhost:60061" },
        TimeoutSeconds = 30
    };

    using var client = new GqldbClient(config);
    await client.LoginAsync("admin", "password");

    // Health check
    Console.WriteLine("=== Health Check ===");
    var health = await client.HealthCheckAsync();
    Console.WriteLine($"Server status: {health}");

    // Warmup parsers
    Console.WriteLine("\n=== Parser Warmup ===");
    await client.WarmupParserAsync(5);
    Console.WriteLine("Warmed up 5 parser instances");

    // Execute some queries to populate cache
    Console.WriteLine("\n=== Executing Queries ===");
    await client.CreateGraphAsync("healthDemo");
    await client.UseGraphAsync("healthDemo");
    await client.GqlAsync("MATCH (n) RETURN count(n)");
    await client.GqlAsync("MATCH (n) RETURN count(n)");  // Should hit cache
    await client.GqlAsync("MATCH (n)-[e]->(m) RETURN count(e)");

    // Check cache stats
    Console.WriteLine("\n=== Cache Statistics ===");
    var cacheStats = await client.GetCacheStatsAsync(CacheType.All);
    if (cacheStats.AstStats != null)
    {
        Console.WriteLine($"  AST hits: {cacheStats.AstStats.Hits}, misses: {cacheStats.AstStats.Misses}");
    }
    if (cacheStats.PlanStats != null)
    {
        Console.WriteLine($"  Plan hits: {cacheStats.PlanStats.Hits}, misses: {cacheStats.PlanStats.Misses}");
    }

    // Get database statistics
    Console.WriteLine("\n=== Database Statistics ===");
    var dbStats = await client.GetStatisticsAsync();
    Console.WriteLine($"  Nodes: {dbStats.NodeCount}, Edges: {dbStats.EdgeCount}");

    // Get system metrics
    Console.WriteLine("\n=== System Metrics ===");
    var metrics = await client.GetSystemMetricsAsync();
    if (metrics.Cpu != null)
    {
        Console.WriteLine($"  CPU: {metrics.Cpu.ProcessPercent:F1}%");
    }

    // Clear caches
    Console.WriteLine("\n=== Clear Caches ===");
    await client.ClearCacheAsync(CacheType.All);
    Console.WriteLine("All caches cleared");

    // Invalidate permission cache
    Console.WriteLine("\n=== Permission Cache ===");
    await client.InvalidatePermissionCacheAsync();
    Console.WriteLine("Permission cache invalidated");

    // Cleanup
    await client.DropGraphAsync("healthDemo");
}
```
