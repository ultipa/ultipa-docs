# Configuration

## Overview

Configure the computing engine to optimize performance for your workload. This includes enabling/disabling, setting synchronization modes, caching properties, and setting memory limits.

## Enabling the Computing Engine

The computing engine is disabled by default. Enable it per-graph using DDL commands.

| Command | Syntax | Description |
| -- | -- | -- |
| SET COMPUTE ENABLED | `ALTER GRAPH graphName SET COMPUTE ENABLED` | Enable the computing engine for a graph. Triggers async topology build. |
| SET COMPUTE DISABLED | `ALTER GRAPH graphName SET COMPUTE DISABLED` | Disable the computing engine and free cached memory. |

Enable computing engine for a graph:

```gql
-- Enable computing engine
ALTER GRAPH socialNetwork SET COMPUTE ENABLED

-- The topology cache builds asynchronously in the background
-- Queries start benefiting as the cache populates
```

Disable to free memory:

```gql
-- Disable to free memory
ALTER GRAPH socialNetwork SET COMPUTE DISABLED

-- All cached data is released
-- Queries continue working via disk-based storage
```

## Synchronization Modes

The computing engine supports two synchronization modes that control how changes propagate to the cache:

**SYNC Mode (Default)**

- Changes block until cache is updated
- Guarantees strong consistency
- Best for: Read-heavy workloads, queries requiring up-to-date results

**ASYNC Mode**

- Changes queued for background processing
- Provides eventual consistency
- Best for: Write-heavy workloads, batch imports, when slight staleness is acceptable

| Command | Syntax | Description |
| -- | -- | -- |
| SYNC_MODE SYNC | `ALTER GRAPH graphName SET COMPUTE SYNC_MODE SYNC` | Blocking updates - changes reflected immediately (strong consistency) |
| SYNC_MODE ASYNC | `ALTER GRAPH graphName SET COMPUTE SYNC_MODE ASYNC` | Queued updates - changes applied in background (eventual consistency) |

SYNC mode for strong consistency:

```gql
-- Use SYNC mode for real-time queries (default)
ALTER GRAPH socialNetwork SET COMPUTE SYNC_MODE SYNC

-- Writes block until cache updated
INSERT (:User {name: 'Alice'})-[:FOLLOWS]->(:User {name: 'Bob'})

-- Immediately visible in accelerated queries
MATCH (u:User {name: 'Alice'})-[:FOLLOWS]->(f)
RETURN f.name
```

ASYNC mode for batch operations:

```gql
-- Use ASYNC mode during batch imports
ALTER GRAPH socialNetwork SET COMPUTE SYNC_MODE ASYNC

-- Bulk import runs faster without blocking
LOAD CSV FROM 'users.csv' AS row
INSERT (:User {id: row.id, name: row.name})

-- Switch back to SYNC after import
ALTER GRAPH socialNetwork SET COMPUTE SYNC_MODE SYNC
```

> **Warning:** In ASYNC mode, recently inserted nodes/edges may not appear in accelerated queries until the background sync completes.

## Property Caching

By default, only topology (node/edge connections) is cached. For frequently accessed properties, you can enable property caching to avoid disk I/O.

**When to Cache Properties:**

- Properties used in WHERE clauses
- Properties returned in high-frequency queries
- Properties used in sorting/aggregation

**Considerations:**

- Each cached property increases memory usage
- Cache properties selectively, not all properties

| Command | Syntax | Description |
| -- | -- | -- |
| SET COMPUTE PROPERTY (nodes) | `ALTER GRAPH graphName SET COMPUTE PROPERTY :Label(prop1, prop2, ...)` | Cache specific node properties for a label |
| SET COMPUTE PROPERTY (edges) | `ALTER GRAPH graphName SET COMPUTE PROPERTY :EDGE_TYPE(prop1, prop2, ...)` | Cache specific edge properties for an edge type |

Configure property caching:

```gql
-- Cache frequently accessed node properties
ALTER GRAPH socialNetwork SET COMPUTE PROPERTY :User(name, age, verified)

-- Cache edge properties used in filtering
ALTER GRAPH socialNetwork SET COMPUTE PROPERTY :FOLLOWS(since, weight)
```

Multi-label property caching:

```gql
-- Cache properties for multiple labels
ALTER GRAPH knowledgeGraph SET COMPUTE PROPERTY :Article(title, publishedAt)
ALTER GRAPH knowledgeGraph SET COMPUTE PROPERTY :Author(name, affiliation)
ALTER GRAPH knowledgeGraph SET COMPUTE PROPERTY :CITES(context)
```

Queries using cached properties:

```gql
-- Without property cache: disk read for each p.name
-- With property cache: direct memory access

MATCH (u:User)-[:FOLLOWS]->(f:User)
WHERE u.name = 'Alice' AND f.verified = true
RETURN f.name, f.age
ORDER BY f.age DESC
```

## Memory Limits

Set memory limits to control how much RAM the computing engine can use per graph. This prevents out-of-memory issues and allows partial caching of large graphs.

**Behavior When Limit Reached:**

- Topology build stops at limit
- Most recently/frequently accessed nodes prioritized
- Uncached portions use disk-based fallback

**Recommended Settings:**

- Leave headroom for query execution and other processes
- Start conservative, increase if needed
- Monitor actual usage and adjust

| Command | Syntax | Description |
| -- | -- | -- |
| SET COMPUTE MEMORY_LIMIT | `ALTER GRAPH graphName SET COMPUTE MEMORY_LIMIT size` | Set maximum memory for computing engine. Supports KB, MB, GB units. |

Configure memory limits:

```gql
-- Set 4GB limit
ALTER GRAPH largeGraph SET COMPUTE MEMORY_LIMIT 4GB

-- Set 512MB limit for smaller graphs
ALTER GRAPH smallGraph SET COMPUTE MEMORY_LIMIT 512MB

-- Set limit in different units
ALTER GRAPH mediumGraph SET COMPUTE MEMORY_LIMIT 2048MB
```

Full configuration example:

```gql
ALTER GRAPH socialNetwork SET COMPUTE ENABLED
ALTER GRAPH socialNetwork SET COMPUTE MEMORY_LIMIT 8GB
ALTER GRAPH socialNetwork SET COMPUTE SYNC_MODE SYNC
ALTER GRAPH socialNetwork SET COMPUTE PROPERTY :User(name, verified)
ALTER GRAPH socialNetwork SET COMPUTE PROPERTY :FOLLOWS(weight)
```
