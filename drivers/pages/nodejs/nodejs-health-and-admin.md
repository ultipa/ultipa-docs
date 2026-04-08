# Health and Administration

The GQLDB Node.js driver provides methods for monitoring server health, managing caches, and gathering statistics.

## Health Service Methods

| Method | Description |
|--------|-------------|
| `healthCheck()` | Check the health status of the server |
| `watch()` | Stream health status changes |

## Admin Service Methods

| Method | Description |
|--------|-------------|
| `warmupParser()` | Pre-allocate parser instances |
| `getCacheStats()` | Get cache statistics |
| `clearCache()` | Clear specified caches |
| `getStatistics()` | Get database statistics |
| `getSystemMetrics()` | Get system metrics (CPU, memory, disk, network) |
| `compact()` | Trigger storage compaction |
| `waitForComputeTopology()` | Wait for compute engine topology to be ready |
| `invalidatePermissionCache()` | Invalidate RBAC permission cache |

## Health Checks

### healthCheck()

Check the current health status of the server:

```typescript
import { GqldbClient, HealthStatus } from '@ultipa-graph/ultipa-driver';

async function checkHealth(client: GqldbClient) {
  // Check overall server health
  const status = await client.healthCheck();

  switch (status) {
    case HealthStatus.SERVING:
      console.log('Server is healthy and serving requests');
      break;
    case HealthStatus.NOT_SERVING:
      console.log('Server is not serving requests');
      break;
    case HealthStatus.SERVICE_UNKNOWN:
      console.log('Service status is unknown');
      break;
    case HealthStatus.UNKNOWN:
      console.log('Health status is unknown');
      break;
  }

  // Check specific service health
  const queryServiceStatus = await client.healthCheck('query');
  console.log('Query service:', HealthStatus[queryServiceStatus]);
}
```

### HealthStatus Enum

```typescript
enum HealthStatus {
  UNKNOWN = 0,
  SERVING = 1,
  NOT_SERVING = 2,
  SERVICE_UNKNOWN = 3
}
```

### watch()

Monitor health status changes with server-side streaming:

```typescript
import { GqldbClient, HealthStatus, HealthWatcher } from '@ultipa-graph/ultipa-driver';

function watchHealth(client: GqldbClient): HealthWatcher {
  const watcher = client.watch();

  watcher.on('status', (status: HealthStatus) => {
    console.log('Health status changed:', HealthStatus[status]);

    if (status !== HealthStatus.SERVING) {
      console.warn('Server is not healthy!');
      // Trigger alerts, failover logic, etc.
    }
  });

  watcher.on('error', (error) => {
    console.error('Watch error:', error.message);
  });

  watcher.on('end', () => {
    console.log('Health watch stream ended');
  });

  return watcher;
}

// Usage
async function monitorHealth(client: GqldbClient) {
  const watcher = watchHealth(client);

  // Stop watching after some time or condition
  setTimeout(() => {
    watcher.stop();
    console.log('Stopped health monitoring');
  }, 300000); // 5 minutes
}
```

## Cache Management

### CacheType Enum

```typescript
enum CacheType {
  ALL = 0,    // All caches
  AST = 1,    // Abstract Syntax Tree cache
  PLAN = 2    // Query plan cache
}
```

### getCacheStats()

Get statistics about caches:

```typescript
import { GqldbClient, CacheType, CacheStats } from '@ultipa-graph/ultipa-driver';

async function getCacheStatistics(client: GqldbClient) {
  // Get all cache stats
  const allStats: CacheStats = await client.getCacheStats(CacheType.ALL);
  console.log('All cache stats:', allStats);

  // Get AST cache stats
  const astStats = await client.getCacheStats(CacheType.AST);
  console.log('AST cache:', astStats.astCache);

  // Get plan cache stats
  const planStats = await client.getCacheStats(CacheType.PLAN);
  console.log('Plan cache:', planStats.planCache);
}
```

### CacheStats Interface

```typescript
interface CacheStats {
  astStats?: ASTCacheStats;
  planStats?: PlanCacheStats;
}

interface ASTCacheStats {
  hits: number;
  misses: number;
  evictions: number;
  entries: number;
  hitRate: number;
}

interface PlanCacheStats {
  size: number;
  capacity: number;
  hits: number;
  misses: number;
  hitRate: number;
}
```

### clearCache()

Clear caches to free memory or force recompilation:

```typescript
async function clearCaches(client: GqldbClient) {
  // Clear all caches
  await client.clearCache(CacheType.ALL);
  console.log('All caches cleared');

  // Clear only AST cache
  await client.clearCache(CacheType.AST);
  console.log('AST cache cleared');

  // Clear only plan cache
  await client.clearCache(CacheType.PLAN);
  console.log('Plan cache cleared');
}
```

## Parser Warmup

### warmupParser()

Pre-allocate parser instances for better performance:

```typescript
async function warmupParsers(client: GqldbClient) {
  // Pre-allocate 10 parser instances
  await client.warmupParser(10);
  console.log('Parsers warmed up');
}
```

This is useful before high-load periods to reduce latency from parser initialization.

## Database Statistics

### getStatistics()

Get statistics about the database or a specific graph:

```typescript
import { Statistics } from '@ultipa-graph/ultipa-driver';

async function getStats(client: GqldbClient) {
  // Get overall database statistics
  const dbStats: Statistics = await client.getStatistics();
  console.log('Database statistics:', dbStats);

  // Get statistics for a specific graph
  const graphStats = await client.getStatistics('myGraph');
  console.log('Graph statistics:', graphStats);
}
```

### Statistics Interface

```typescript
interface Statistics {
  nodeCount: number;
  edgeCount: number;
  labelCounts: Record<string, number>;
  edgeLabelCounts: Record<string, number>;
}
```

## Permission Cache

### invalidatePermissionCache()

Invalidate the RBAC (Role-Based Access Control) permission cache:

```typescript
async function invalidatePermissions(client: GqldbClient) {
  // Invalidate all permission caches
  await client.invalidatePermissionCache();
  console.log('All permission caches invalidated');

  // Invalidate cache for a specific user
  await client.invalidatePermissionCache('johndoe');
  console.log('Permission cache invalidated for johndoe');
}
```

Use this after changing user permissions to ensure changes take effect immediately.

## Error Handling

```typescript
import { HealthCheckFailedError } from '@ultipa-graph/ultipa-driver';

async function safeHealthCheck(client: GqldbClient) {
  try {
    const status = await client.healthCheck();
    return status === HealthStatus.SERVING;
  } catch (error) {
    if (error instanceof HealthCheckFailedError) {
      console.error('Health check failed:', error.message);
      return false;
    }
    throw error;
  }
}
```

## Complete Example

```typescript
import { GqldbClient, createConfig, HealthStatus, CacheType } from '@ultipa-graph/ultipa-driver';

async function main() {
  const client = new GqldbClient(createConfig({
    hosts: ['localhost:60061']
  }));

  try {
    await client.login('admin', 'password');

    // Health check
    console.log('=== Health Check ===');
    const health = await client.healthCheck();
    console.log('Server status:', HealthStatus[health]);

    // Warmup parsers
    console.log('\n=== Parser Warmup ===');
    await client.warmupParser(5);
    console.log('Warmed up 5 parser instances');

    // Execute some queries to populate cache
    console.log('\n=== Executing Queries ===');
    await client.gql('MATCH (n) RETURN count(n)');
    await client.gql('MATCH (n) RETURN count(n)');  // Should hit cache
    await client.gql('MATCH (n)-[e]->(m) RETURN count(e)');

    // Check cache stats
    console.log('\n=== Cache Statistics ===');
    const cacheStats = await client.getCacheStats(CacheType.ALL);
    console.log('Cache stats:', JSON.stringify(cacheStats, null, 2));

    // Get database statistics
    console.log('\n=== Database Statistics ===');
    const dbStats = await client.getStatistics();
    console.log('Database stats:', JSON.stringify(dbStats, null, 2));

    // Start health monitoring
    console.log('\n=== Health Monitoring ===');
    const watcher = client.watch();

    watcher.on('status', (status) => {
      console.log('Health update:', HealthStatus[status]);
    });

    // Let it run for 5 seconds
    await new Promise(resolve => setTimeout(resolve, 5000));
    watcher.stop();
    console.log('Health monitoring stopped');

    // Clear caches
    console.log('\n=== Clear Caches ===');
    await client.clearCache(CacheType.ALL);
    console.log('All caches cleared');

    // Verify caches are cleared
    const clearedStats = await client.getCacheStats(CacheType.ALL);
    console.log('Cache stats after clear:', JSON.stringify(clearedStats, null, 2));

    // Invalidate permission cache
    console.log('\n=== Permission Cache ===');
    await client.invalidatePermissionCache();
    console.log('Permission cache invalidated');

  } finally {
    await client.close();
  }
}

main().catch(console.error);
```
