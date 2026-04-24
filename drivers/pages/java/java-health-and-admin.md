# Health and Administration

The GQLDB Java driver provides methods for monitoring server health, managing caches, and gathering statistics.

## Health Service Methods

| Method | Description |
|--------|-------------|
| `healthCheck()` | Check the health status of the server |
| `watch()` | Stream health status changes |

## Admin Service Methods

| Method | Description |
|--------|-------------|
| `warmupParser(count)` | Pre-allocate parser instances |
| `getCacheStats(cacheType)` | Get cache statistics |
| `clearCache(cacheType)` | Clear specified caches |
| `getStatistics(graphName)` | Get database statistics |
| `invalidatePermissionCache(username)` | Invalidate RBAC permission cache |
| `compact()` | Trigger storage compaction |
| `getSystemMetrics()` | Get system-level metrics (CPU, memory, disk) |
| `waitForComputeTopology(graphName, timeout)` | Wait until the compute topology is ready |

## Task and Process Methods

| Method | Description |
|--------|-------------|
| `showTasks()` | List running/completed algorithm tasks |
| `stopTask(taskId)` | Stop a running task |
| `deleteTask(taskId)` | Delete a task |
| `showAlgos()` | List available algorithms |
| `top()` | List running queries |
| `kill(queryId)` | Terminate a running query |
| `stats()` | Get graph statistics (node/edge counts by label) |
| `test()` | Connectivity test (ping) |

## Health Checks

### healthCheck()

Check the current health status of the server:

```java
import com.gqldb.*;
import com.gqldb.types.HealthStatus;

public void checkHealth(GqldbClient client) {
    // Check overall server health
    HealthStatus status = client.healthCheck();

    switch (status) {
        case SERVING:
            System.out.println("Server is healthy and serving requests");
            break;
        case NOT_SERVING:
            System.out.println("Server is not serving requests");
            break;
        case SERVICE_UNKNOWN:
            System.out.println("Service status is unknown");
            break;
        case UNKNOWN:
            System.out.println("Health status is unknown");
            break;
    }

    // Check specific service health
    HealthStatus queryServiceStatus = client.healthCheck("query");
    System.out.println("Query service: " + queryServiceStatus);
}
```

### HealthStatus Enum

```java
public enum HealthStatus {
    UNKNOWN,
    SERVING,
    NOT_SERVING,
    SERVICE_UNKNOWN
}
```

### watch()

Monitor health status changes with server-side streaming:

```java
import com.gqldb.*;
import com.gqldb.types.HealthStatus;

public void watchHealth(GqldbClient client) {
    GqldbClient.HealthWatcher watcher = client.watch(status -> {
        System.out.println("Health status changed: " + status);

        if (status != HealthStatus.SERVING) {
            System.out.println("WARNING: Server is not healthy!");
            // Trigger alerts, failover logic, etc.
        }
    });

    // Let it run for some time
    try {
        Thread.sleep(300000);  // 5 minutes
    } catch (InterruptedException e) {
        Thread.currentThread().interrupt();
    }

    // Stop watching
    watcher.stop();
    System.out.println("Stopped health monitoring");

    // Check for errors
    if (watcher.hasError()) {
        System.err.println("Watch error: " + watcher.getError().getMessage());
    }
}
```

### HealthWatcher Class

```java
public static class HealthWatcher {
    void stop();                    // Stop watching
    boolean isCompleted();          // Check if watch has completed
    Throwable getError();           // Get any error that occurred
    boolean hasError();             // Check if an error occurred
}
```

## Cache Management

### CacheType Enum

```java
public enum CacheType {
    ALL,    // All caches
    AST,    // Abstract Syntax Tree cache
    PLAN    // Query plan cache
}
```

### getCacheStats()

Get statistics about caches:

```java
import com.gqldb.*;
import com.gqldb.types.CacheType;
import com.gqldb.services.AdminService;

public void getCacheStatistics(GqldbClient client) {
    // Get all cache stats
    AdminService.CacheStats allStats = client.getCacheStats(CacheType.ALL);
    System.out.println("All cache stats: " + allStats);

    // Get AST cache stats
    AdminService.CacheStats astStats = client.getCacheStats(CacheType.AST);
    System.out.println("AST cache: " + astStats);

    // Get plan cache stats
    AdminService.CacheStats planStats = client.getCacheStats(CacheType.PLAN);
    System.out.println("Plan cache: " + planStats);
}
```

### clearCache()

Clear caches to free memory or force recompilation:

```java
public void clearCaches(GqldbClient client) {
    // Clear all caches
    client.clearCache(CacheType.ALL);
    System.out.println("All caches cleared");

    // Clear only AST cache
    client.clearCache(CacheType.AST);
    System.out.println("AST cache cleared");

    // Clear only plan cache
    client.clearCache(CacheType.PLAN);
    System.out.println("Plan cache cleared");

    // Clear all (using default)
    client.clearCache();
    System.out.println("All caches cleared (default)");
}
```

## Parser Warmup

### warmupParser()

Pre-allocate parser instances for better performance:

```java
public void warmupParsers(GqldbClient client) {
    // Pre-allocate 10 parser instances
    client.warmupParser(10);
    System.out.println("Parsers warmed up");
}
```

This is useful before high-load periods to reduce latency from parser initialization.

## Database Statistics

### getStatistics()

Get statistics about the database or a specific graph:

```java
import com.gqldb.services.AdminService;

public void getStats(GqldbClient client) {
    // Get overall database statistics
    AdminService.Statistics dbStats = client.getStatistics();
    System.out.println("Database statistics: " + dbStats);

    // Get statistics for a specific graph
    AdminService.Statistics graphStats = client.getStatistics("myGraph");
    System.out.println("Graph statistics: " + graphStats);
}
```

## Permission Cache

### invalidatePermissionCache()

Invalidate the RBAC (Role-Based Access Control) permission cache:

```java
public void invalidatePermissions(GqldbClient client) {
    // Invalidate all permission caches
    client.invalidatePermissionCache();
    System.out.println("All permission caches invalidated");

    // Invalidate cache for a specific user
    client.invalidatePermissionCache("johndoe");
    System.out.println("Permission cache invalidated for johndoe");
}
```

Use this after changing user permissions to ensure changes take effect immediately.

## Database Compaction

### compact()

Trigger database compaction:

```java
AdminService.CompactResult result = client.compact();
System.out.println("Compaction: " + (result.isSuccess() ? "succeeded" : "failed") +
    " - " + result.getMessage());
```

## System Metrics

### getSystemMetrics()

Get system-level metrics including CPU, memory, disk, and network:

```java
AdminService.SystemMetrics metrics = client.getSystemMetrics();

if (metrics.getCpu() != null) {
    System.out.println("CPU - Process: " + metrics.getCpu().getProcessPercent() +
        "%, System: " + metrics.getCpu().getSystemPercent() + "%");
}

if (metrics.getMemory() != null) {
    System.out.println("Memory - Used: " + metrics.getMemory().getSystemUsedPercent() + "%");
}

if (metrics.getStorage() != null) {
    System.out.println("Storage - DB size: " + metrics.getStorage().getDbSizeBytes() + " bytes");
}
```

## Compute Topology

### waitForComputeTopology()

Wait for the compute engine to be ready:

```java
AdminService.ComputeTopologyResult result = client.waitForComputeTopology(
    "myGraph", Duration.ofSeconds(60)
);
System.out.println("Compute topology: " + (result.isReady() ? "ready" : "not ready") +
    " - " + result.getMessage());
```

## Task Management

### showTasks()

List running and completed algorithm tasks:

```java
client.useGraph("myGraph");

List<TaskInfo> tasks = client.showTasks();
for (TaskInfo task : tasks) {
    System.out.println(task.getTaskId() + ": " + task.getStatus() +
        " (" + task.getProgress() + ")");
}

// With QueryConfig
List<TaskInfo> tasks2 = client.showTasks(new QueryConfig());
```

### stopTask() / deleteTask()

```java
client.stopTask("task-123");
System.out.println("Task stopped");

client.deleteTask("task-123");
System.out.println("Task deleted");
```

### showAlgos()

List available algorithms:

```java
List<AlgoInfo> algos = client.showAlgos();
for (AlgoInfo algo : algos) {
    System.out.println(algo.getName() + ": " + algo.getDescription());
}
```

## Process Monitoring

### top()

List currently running queries:

```java
List<ProcessInfo> processes = client.top();
for (ProcessInfo proc : processes) {
    System.out.println("Query " + proc.getQueryId() + ": " +
        proc.getQueryText() + " (" + proc.getDurationMs() + "ms)");
}
```

### kill()

Terminate a running query:

```java
client.kill("query-456");
System.out.println("Query terminated");
```

### stats()

Get graph statistics with node/edge counts by label:

```java
GraphStats graphStats = client.stats();
System.out.println("Nodes: " + graphStats.getNodeCount());
System.out.println("Edges: " + graphStats.getEdgeCount());
System.out.println("Label counts: " + graphStats.getLabelCounts());
```

### test()

Test connectivity (returns latency in nanoseconds):

```java
long latencyNs = client.test();
System.out.println("Latency: " + (latencyNs / 1_000_000.0) + "ms");
```

## Complete Example

```java
import com.gqldb.*;
import com.gqldb.types.CacheType;
import com.gqldb.types.HealthStatus;
import com.gqldb.services.AdminService;

public class HealthAdminExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:9000")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");

            // Health check
            System.out.println("=== Health Check ===");
            HealthStatus health = client.healthCheck();
            System.out.println("Server status: " + health);

            // Warmup parsers
            System.out.println("\n=== Parser Warmup ===");
            client.warmupParser(5);
            System.out.println("Warmed up 5 parser instances");

            // Execute some queries to populate cache
            System.out.println("\n=== Executing Queries ===");
            client.gql("MATCH (n) RETURN count(n)");
            client.gql("MATCH (n) RETURN count(n)");  // Should hit cache
            client.gql("MATCH (n)-[e]->(m) RETURN count(e)");

            // Check cache stats
            System.out.println("\n=== Cache Statistics ===");
            AdminService.CacheStats cacheStats = client.getCacheStats(CacheType.ALL);
            System.out.println("Cache stats: " + cacheStats);

            // Get database statistics
            System.out.println("\n=== Database Statistics ===");
            AdminService.Statistics dbStats = client.getStatistics();
            System.out.println("Database stats: " + dbStats);

            // Start health monitoring
            System.out.println("\n=== Health Monitoring ===");
            GqldbClient.HealthWatcher watcher = client.watch(status -> {
                System.out.println("Health update: " + status);
            });

            // Let it run for 5 seconds
            Thread.sleep(5000);
            watcher.stop();
            System.out.println("Health monitoring stopped");

            // Clear caches
            System.out.println("\n=== Clear Caches ===");
            client.clearCache(CacheType.ALL);
            System.out.println("All caches cleared");

            // Verify caches are cleared
            AdminService.CacheStats clearedStats = client.getCacheStats(CacheType.ALL);
            System.out.println("Cache stats after clear: " + clearedStats);

            // Invalidate permission cache
            System.out.println("\n=== Permission Cache ===");
            client.invalidatePermissionCache();
            System.out.println("Permission cache invalidated");

        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
```
