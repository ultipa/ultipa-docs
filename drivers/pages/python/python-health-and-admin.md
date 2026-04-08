# Health and Administration

The GQLDB Python driver provides methods for monitoring server health, managing caches, and gathering statistics.

## Health Service Methods

| Method | Description |
|--------|-------------|
| `health_check(service)` | Check the health status of the server |
| `watch(service, callback)` | Stream health status changes |
| `watch_iter(service)` | Iterate over health status changes |

## Admin Service Methods

| Method | Description |
|--------|-------------|
| `warmup_parser(count)` | Pre-allocate parser instances |
| `get_cache_stats(cache_type)` | Get cache statistics |
| `clear_cache(cache_type)` | Clear specified caches |
| `get_statistics(graph_name)` | Get database statistics |
| `invalidate_permission_cache(username)` | Invalidate RBAC permission cache |
| `compact(graph_name)` | Trigger compaction for a graph |
| `get_system_metrics()` | Get system-level metrics |

## Health Checks

### health_check()

Check the current health status of the server:

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.types import HealthStatus

config = GqldbConfig(hosts=["localhost:60061"])

with GqldbClient(config) as client:
    client.login("admin", "password")

    # Check overall server health
    status = client.health_check()

    if status == HealthStatus.SERVING:
        print("Server is healthy and serving requests")
    elif status == HealthStatus.NOT_SERVING:
        print("Server is not serving requests")
    elif status == HealthStatus.SERVICE_UNKNOWN:
        print("Service status is unknown")
    else:
        print("Health status is unknown")

    # Check specific service health
    query_status = client.health_check("query")
    print(f"Query service: {query_status.name}")
```

### HealthStatus Enum

```python
from gqldb.types import HealthStatus

HealthStatus.UNKNOWN         # Status unknown
HealthStatus.SERVING         # Healthy and serving
HealthStatus.NOT_SERVING     # Not serving requests
HealthStatus.SERVICE_UNKNOWN # Service status unknown
```

### watch()

Monitor health status changes with a callback:

```python
from gqldb.types import HealthStatus

def on_health_change(status: HealthStatus):
    print(f"Health status changed: {status.name}")

    if status != HealthStatus.SERVING:
        print("WARNING: Server is not healthy!")
        # Trigger alerts, failover logic, etc.

# Watch health status
client.watch(callback=on_health_change)
```

### watch_iter()

Iterate over health status changes:

```python
from gqldb.types import HealthStatus

# Using generator
for status in client.watch_iter():
    print(f"Health status: {status.name}")

    if status != HealthStatus.SERVING:
        print("Server unhealthy, breaking...")
        break
```

## Cache Management

### CacheType Enum

```python
from gqldb.types import CacheType

CacheType.ALL   # All caches
CacheType.AST   # Abstract Syntax Tree cache
CacheType.PLAN  # Query plan cache
```

### get_cache_stats()

Get statistics about caches:

```python
from gqldb.types import CacheType

# Get all cache stats
all_stats = client.get_cache_stats(CacheType.ALL)
print(f"All cache stats: {all_stats}")

# Get AST cache stats
ast_stats = client.get_cache_stats(CacheType.AST)
print(f"AST cache: {ast_stats}")

# Get plan cache stats
plan_stats = client.get_cache_stats(CacheType.PLAN)
print(f"Plan cache: {plan_stats}")
```

### CacheStats Class

```python
@dataclass
class CacheStats:
    ast_stats: ASTCacheStats
    plan_stats: PlanCacheStats

@dataclass
class ASTCacheStats:
    hits: int
    misses: int
    evictions: int
    entries: int
    hit_rate: float

@dataclass
class PlanCacheStats:
    hits: int
    misses: int
    size: int
    capacity: int
    hit_rate: float
```

### clear_cache()

Clear caches to free memory or force recompilation:

```python
from gqldb.types import CacheType

# Clear all caches
client.clear_cache(CacheType.ALL)
print("All caches cleared")

# Clear only AST cache
client.clear_cache(CacheType.AST)
print("AST cache cleared")

# Clear only plan cache
client.clear_cache(CacheType.PLAN)
print("Plan cache cleared")

# Clear all (default)
client.clear_cache()
print("All caches cleared (default)")
```

## Parser Warmup

### warmup_parser()

Pre-allocate parser instances for better performance:

```python
# Pre-allocate 10 parser instances
client.warmup_parser(10)
print("Parsers warmed up")
```

This is useful before high-load periods to reduce latency from parser initialization.

## Database Statistics

### get_statistics()

Get statistics about the database or a specific graph:

```python
# Get overall database statistics
db_stats = client.get_statistics()
print(f"Database statistics: {db_stats}")

# Get statistics for a specific graph
graph_stats = client.get_statistics("myGraph")
print(f"Graph statistics: {graph_stats}")
```

### Statistics Class

```python
@dataclass
class Statistics:
    node_count: int
    edge_count: int
    label_counts: Dict[str, int]
    edge_label_counts: Dict[str, int]
```

## Permission Cache

### invalidate_permission_cache()

Invalidate the RBAC (Role-Based Access Control) permission cache:

```python
# Invalidate all permission caches
client.invalidate_permission_cache()
print("All permission caches invalidated")

# Invalidate cache for a specific user
client.invalidate_permission_cache("johndoe")
print("Permission cache invalidated for johndoe")
```

Use this after changing user permissions to ensure changes take effect immediately.

## Complete Example

```python
from gqldb import GqldbClient, GqldbConfig
from gqldb.types import CacheType, HealthStatus
from gqldb.errors import GqldbError
import time

def main():
    config = GqldbConfig(
        hosts=["localhost:60061"],
        timeout=30
    )

    with GqldbClient(config) as client:
        client.login("admin", "password")

        # Health check
        print("=== Health Check ===")
        health = client.health_check()
        print(f"Server status: {health.name}")

        # Warmup parsers
        print("\n=== Parser Warmup ===")
        client.warmup_parser(5)
        print("Warmed up 5 parser instances")

        # Execute some queries to populate cache
        print("\n=== Executing Queries ===")
        client.create_graph("healthDemo")
        client.use_graph("healthDemo")
        client.gql("MATCH (n) RETURN count(n)")
        client.gql("MATCH (n) RETURN count(n)")  # Should hit cache
        client.gql("MATCH (n)-[e]->(m) RETURN count(e)")

        # Check cache stats
        print("\n=== Cache Statistics ===")
        cache_stats = client.get_cache_stats(CacheType.ALL)
        print(f"Cache stats: {cache_stats}")

        # Get database statistics
        print("\n=== Database Statistics ===")
        db_stats = client.get_statistics()
        print(f"Database stats: {db_stats}")

        # Start health monitoring (with timeout)
        print("\n=== Health Monitoring ===")
        print("Monitoring health for 5 seconds...")

        start_time = time.time()
        for status in client.watch_iter():
            print(f"  Health update: {status.name}")
            if time.time() - start_time > 5:
                break

        print("Health monitoring stopped")

        # Clear caches
        print("\n=== Clear Caches ===")
        client.clear_cache(CacheType.ALL)
        print("All caches cleared")

        # Verify caches are cleared
        cleared_stats = client.get_cache_stats(CacheType.ALL)
        print(f"Cache stats after clear: {cleared_stats}")

        # Invalidate permission cache
        print("\n=== Permission Cache ===")
        client.invalidate_permission_cache()
        print("Permission cache invalidated")

        # Cleanup
        client.drop_graph("healthDemo")

if __name__ == "__main__":
    main()
```
