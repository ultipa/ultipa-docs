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

## Autoloading at Startup

Restarting the database does not turn the computing engine off, but it does drop the in-memory cache. So after a restart, a graph still reports `ENABLED`, but acceleration is **inactive** until the cache is rebuilt. You have two ways to rebuild it:

- **Manually**: re-issue `ALTER GRAPH … SET COMPUTE ENABLED` to trigger a fresh background build.
- **Automatically on every startup**: by flagging the graph for autoload (below).

To have a graph's topology build **automatically** at database open, flag it for autoload:

```gql
-- Build this graph's topology automatically on every database open
ALTER GRAPH socialNetwork SET COMPUTE AUTOLOAD ON

-- Back to manual (re-issue SET COMPUTE ENABLED after a restart)
ALTER GRAPH socialNetwork SET COMPUTE AUTOLOAD OFF
```

`AUTOLOAD` is persisted per graph and takes effect only when compute is also `ENABLED`. Default is **OFF**. Setting it does not trigger a build immediately, it governs what happens at the next open, and that build runs in the background so the open stays fast.

**Process-wide override.** The `GQLDB_COMPUTE_AUTOLOAD` environment variable overrides the per-graph flags for the whole process:

| Value | Effect |
| -- | -- |
| unset | Per-graph `AUTOLOAD` flags govern (default: nothing autoloads). |
| `1` | Autoload every compute-enabled graph, ignoring per-graph flags. |
| `0` | Disable autoload entirely (operational kill-switch). |

When several graphs autoload at once, loading adapts to the storage device — serial on rotational disks (HDD) to avoid thrashing one spindle, bounded-parallel on flash (SSD/NVMe). The device class is detected automatically. Inside containers, where block-device introspection is unreliable, set `GQLDB_COMPUTE_STORAGE_CLASS` (`hdd` / `ssd` / `nvme` / `auto`) explicitly.

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

**`GOMEMLIMIT` is the real ceiling, not physical RAM.** The whole database process runs under a soft memory limit set by the `GOMEMLIMIT` environment variable, not by the machine's physical RAM. This is the absolute outer wall: the GQL limits above (`MEMORY_LIMIT`, `TOPOLOGY_LIMIT`, `PROPERTY_LIMIT`) only partition memory underneath it. A 512 GB host with `GOMEMLIMIT=96GiB` can only grow the process to ~96 GB, no matter how high you set the GQL limits.

**What goes wrong:** as a build nears `GOMEMLIMIT`, the runtime spends almost all CPU on garbage collection trying to stay under the limit, and a large build slows to a crawl. Rather than hang, a build that crosses **~90%** of `GOMEMLIMIT` **fails loudly** with `buildState=FAILED` and an actionable error.

**How to fix it:**
- Raise or unset `GOMEMLIMIT` if the host has spare RAM, **or**
- Shrink the cache's footprint with [property caching](#Property-Caching) (cache only the properties you query, or go topology-only) or a `PROPERTY_LIMIT`,
- then rebuild: `ALTER GRAPH <g> SET COMPUTE REBUILD`.

**Catch it early:** watch `goMemLimit` and `memLimitUsedPct` in `SHOW COMPUTE STATUS`, a `memLimitUsedPct` creeping toward 90% means you're heading for a failed build.

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

## Rebuilding and Compacting the Cache

As you `INSERT` / `SET` / `DELETE`, mutations accumulate in an in-memory **write-delta** layered over the base topology snapshot. Reads stay fast and correct while a delta is present, it is overlaid on the base, never a fallback to disk, and the delta merges into the base automatically once it grows past an internal threshold.

**Compact** folds the pending write-delta into the base snapshot on demand:

```gql
ALTER GRAPH socialNetwork SET COMPUTE COMPACT
```

This is a cheap **in-memory** merge bounded by the delta plus the current snapshot, not a from-disk rebuild. The graph stays readable throughout, and the command reports how many pending mutations were folded in; on an already-empty delta it is an instant no-op. Use it to restore peak read throughput after a burst of writes, or to drain the delta on a now-idle graph. The pending delta size is visible as `deltaSize` in `SHOW COMPUTE STATUS`.

**Rebuild** discards the cache and rebuilds the entire topology from storage:

```gql
ALTER GRAPH socialNetwork SET COMPUTE REBUILD
```

Unlike `COMPACT`, this re-reads the whole graph from disk and is orders of magnitude more expensive. Reserve it for two cases: recovering a topology stuck in the `FAILED` build state, or applying a setting that only takes effect on a from-scratch build, such as [low-memory topology](#Low-Memory-Topology). For routine delta merges, prefer `COMPACT`.

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

## Low-Memory Topology

By default, the topology cache stores its adjacency arrays as 64-bit (`uint64`) values. For graphs with fewer than 2³² (~4.29 billion) nodes and fewer than 2³² edges, you can switch to a 32-bit (`uint32`) topology, which **roughly halves topology memory** at no cost to query results.

Enable the low-memory topology:

```gql
ALTER GRAPH socialNetwork SET COMPUTE LOWMEM ON
```

Return to the default 64-bit topology:

```gql
ALTER GRAPH socialNetwork SET COMPUTE LOWMEM OFF
```

**Behavior:**

- **Opt-in.** `LOWMEM OFF` (the default) keeps the unchanged 64-bit topology.
- **Applied on the next build, not immediately.** Setting `LOWMEM` only records the preference; it does not trigger a rebuild. The new array width takes effect on the next from-scratch build — at database open, on `AUTOLOAD`, or when you force one with `ALTER GRAPH socialNetwork SET COMPUTE REBUILD`.
- **Persisted.** The preference is saved with the graph and survives restarts.
- **Fails loud, never truncates.** If a low-memory build's node or edge count reaches 2³², the build fails with an actionable error rather than silently wrapping around. Run `SET COMPUTE LOWMEM OFF` followed by `SET COMPUTE REBUILD` to fall back to the 64-bit topology.

Apply it immediately after enabling:

```gql
-- Turn on low-memory mode and rebuild now to apply it
ALTER GRAPH socialNetwork SET COMPUTE LOWMEM ON
ALTER GRAPH socialNetwork SET COMPUTE REBUILD
```

Check the active width with `SHOW COMPUTE STATUS`: the `lowMem` row reflects the preference, and `topologyArrayWidth` (`32` or `64`) reflects the live snapshot.

## Full Configuration Example

```gql
ALTER GRAPH socialNetwork SET COMPUTE ENABLED
ALTER GRAPH socialNetwork SET COMPUTE MEMORY_LIMIT 8GB
ALTER GRAPH socialNetwork SET COMPUTE SYNC_MODE SYNC
ALTER GRAPH socialNetwork SET COMPUTE PROPERTY :User(name, verified)
ALTER GRAPH socialNetwork SET COMPUTE PROPERTY :FOLLOWS(weight)
```
