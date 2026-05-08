# Configuration

Configure the computing engine to optimize performance for your workload. This includes enabling/disabling, setting synchronization modes, caching properties, and setting memory limits.

## Enabling the Computing Engine

The computing engine is disabled by default. Enable it per-graph using DDL commands.

Enable computing engine for a graph:

```gql
ALTER GRAPH socialNetwork SET COMPUTE ENABLED
```

It immediately starts building the topology cache asynchronously in the background. Queries and algorithms start benefiting as the cache populates. Use `SHOW COMPUTE STATUS` and watch the `available` row to know when the cache is ready (see [Monitoring](/docs/computing-engine/monitoring)).

Disable to free memory:

```gql
ALTER GRAPH socialNetwork SET COMPUTE DISABLED
```

It tears the cache down and releases its memory; queries continue to work against disk-backed storage.

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

| Limit | Description |
| -- | -- |
| `MEMORY_LIMIT` | Cap total memory the computing engine may use for this graph (topology + property caches combined). Supports KB, MB, GB units. |
| `TOPOLOGY_LIMIT` | Cap memory dedicated to the topology cache only. |
| `PROPERTY_LIMIT` | Cap memory dedicated to property caches only. |

Configure memory limits:

```gql
-- Cap total computing-engine memory at 4GB
ALTER GRAPH largeGraph SET COMPUTE MEMORY_LIMIT 4GB

-- Subdivide: 2GB for topology, 1GB for properties
ALTER GRAPH largeGraph SET COMPUTE TOPOLOGY_LIMIT 2GB
ALTER GRAPH largeGraph SET COMPUTE PROPERTY_LIMIT 1GB

-- Set 512MB total for smaller graphs
ALTER GRAPH smallGraph SET COMPUTE MEMORY_LIMIT 512MB
```

The two sub-limits (`TOPOLOGY_LIMIT`, `PROPERTY_LIMIT`) let you reserve memory for one cache without letting the other crowd it out. If only `MEMORY_LIMIT` is set, the engine partitions it internally. Setting `PROPERTY_LIMIT` to `0` disables property caching entirely (topology-only mode).

## Synchronization Modes

The computing engine supports two synchronization modes that control how changes propagate to the cache:

| Mode | Latency on write	| Read consistency | Best for |
| -- | -- | -- | -- |
| `SYNC` (default) | Higher: commit blocks until the cache reflects the change | Immediate: the next query sees the change | Read-heavy workloads, queries requiring up-to-date results |
| `ASYNC` |	Lower: commit returns once the change is queued | Eventual: a query issued right after commit may see the old cache state for a brief window | Write-heavy workloads, batchy imports, when slight staleness is acceptable |

`SYNC` mode for strong consistency:

```gql
-- Use SYNC mode for real-time queries
ALTER GRAPH socialNetwork SET COMPUTE SYNC_MODE SYNC

-- The INSERT finishes only after both disk and cache are updated
INSERT (:User {name: 'Alice'})-[:FOLLOWS]->(:User {name: 'Bob'})

-- The next query sees the new data immediately
MATCH (u:User {name: 'Alice'})-[:FOLLOWS]->(f)
RETURN f.name
```

`ASYNC` mode for batch operations:

```gql
-- Switch to ASYNC mode before a large batch of writes
ALTER GRAPH socialNetwork SET COMPUTE SYNC_MODE ASYNC

-- Bulk inserts run faster, each commit returns as soon as disk is updated and the cache catches up in the background
INSERT (:User {name: 'Alice'}), (:User {name: 'Bob'}), (:User {name: 'Carol'}), ...

-- Switch back to SYNC after the import is done
ALTER GRAPH socialNetwork SET COMPUTE SYNC_MODE SYNC
```

> **Warning:** In `ASYNC` mode, recently inserted nodes/edges may not appear in accelerated queries until the background sync completes.

## Property Caching

By default, only topology (node/edge connections) is cached. For frequently accessed properties, you can enable property caching to avoid disk I/O.

**When to Cache Properties:**

- Properties used in `WHERE` clauses or property specs in patterns
- Properties returned in high-frequency queries
- Properties used in sorting or aggregation

**Considerations:**

- Each cached property increases memory usage
- Cache properties selectively, not all properties

Two forms are available — a per-label form for configuring one label at a time, and a bulk form for configuring multiple labels in a single statement. Both write to the same property-cache configuration.

### Per-Label Form

Cache the listed properties for a single label:

```gql
ALTER GRAPH socialNetwork SET COMPUTE PROPERTY :User(name, age, verified)
```

The same syntax works for node and edge labels. The system decides node vs edge by looking at how the label is actually used in the data: if at least one edge with that label exists, it's treated as an edge property cache; otherwise it's treated as a node property cache.

Repeated statements for the same label **replace** the previous setting, not merge with it. For example, `:User(name)` followed by `:User(age)` ends up caching only `age`. To cache multiple properties on a label, list them all in one statement: `:User(name, age)`.

Clear the property cache for a label by passing an empty list — the label is then in topology-only mode:

```gql
ALTER GRAPH socialNetwork SET COMPUTE PROPERTY :User()
```

### Bulk Form

Configure several labels in one statement with explicit `NODE` / `EDGE` keywords:

```gql
ALTER GRAPH socialNetwork SET COMPUTE
  NODE :User.{name, age}, :Company.{*}
  EDGE :FOLLOWS.{since}
```

Per label, four spec forms are accepted:

- `:Label`: topology only, no properties
- `:Label.{*}`: all properties
- `:Label.{p1, p2}`: only the listed properties
- `*`: wildcard, every label (topology only)

The `EDGE` clause is optional, omitting it configures node caching only.

The bulk form has the same merge-with-overwrite behavior as the per-label form: labels listed here have their property lists overwritten, and labels **not** listed are left untouched. It's a convenience for configuring multiple labels in one statement, not a way to wipe and reset the configuration.

### Example Query

Queries automatically use cached properties when available:

```gql
-- Without property cache: disk read for u.name, f.verified, f.age
-- With property cache: direct memory access

MATCH (u:User)-[:FOLLOWS]->(f:User)
WHERE u.name = 'Alice' AND f.verified = true
RETURN f.name, f.age
ORDER BY f.age DESC
```

## Engine Selection

Two topology engines are available:

| Engine | Pause behavior on large graphs | Build requirement | Best for |
| -- | -- | -- | -- |
| `GO` (default) | The runtime periodically pauses to manage memory; pauses grow longer as the cached graph grows. | None, always available. | Small to medium graphs. |
| `RUST` | No runtime memory-management pauses — the topology lives in memory the Go runtime never inspects. | Binary built with `-tags rust_compute`. | Large graphs (10M+ nodes) where the `GO` engine's pauses start showing up in query latency. |

Engine selection is independent of enable/disable and property caching configuration. It just chooses where the topology lives in memory.

Pick `GO`:

```gql
ALTER GRAPH socialNetwork SET COMPUTE ENGINE GO
```

Pick `RUST`:

```gql
ALTER GRAPH socialNetwork SET COMPUTE ENGINE RUST
```

## Full Configuration Example

```gql
ALTER GRAPH socialNetwork SET COMPUTE ENABLED
ALTER GRAPH socialNetwork SET COMPUTE MEMORY_LIMIT 8GB
ALTER GRAPH socialNetwork SET COMPUTE SYNC_MODE SYNC
ALTER GRAPH socialNetwork SET COMPUTE PROPERTY :User(name, verified)
ALTER GRAPH socialNetwork SET COMPUTE PROPERTY :FOLLOWS(weight)
```
