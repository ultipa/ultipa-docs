# Memory Management

Understanding and managing computing engine memory usage is essential for optimal performance. This page covers memory budget allocation, estimation, partial caching strategies, and troubleshooting.

## Memory Budget Allocation

The computing engine divides its memory budget into three components:

| Component | Default share | What it holds |
| -- | -- | -- |
| Topology budget | 60% | The graph structure: outgoing- and incoming-edge indexes, per-label adjacency, node and edge ID mappings. |
| Property budget | 30% | Cached property values: per-label property arrays, string interning for text properties. |
| Working budget | 10% | Temporary memory used during query execution, algorithm runs, and cache build/rebuild operations. |

These percentages are defaults that work well for most workloads. The system automatically manages allocation within your configured limit.

## Memory Estimates

Use these estimates to plan your memory allocation:

**Topology Memory:**

Follow the formula `Memory = 2 * (N + 1) * 8 + 4 * E * 8 bytes`, where `N` = number of nodes, `E` = number of edges.

The two-times factor on both terms reflects the fact that the engine maintains two parallel indexes — one for outgoing edges and one for incoming edges — so traversal in either direction is equally fast. Roughly, plan for **~16 bytes per node** (one index slot in each direction) and **~32 bytes per edge** (each edge appears in both indexes).

> For graphs under 2³² nodes and edges, <a target='_blank' href='/docs/computing-engine/configuration#Low-Memory-Topology'>low-memory topology</a> uses 32-bit adjacency arrays instead of 64-bit, roughly **halving** these topology figures.

**Property Memory:**

- Integer/Float: 8 bytes per value
- Boolean: 1 byte per value
- String: 8 bytes pointer + string length (interned)
- Multiply by number of cached properties

**Reference Table:**

| Graph Size | Nodes | Edges | Topology | Properties (5)<sup>*</sup> | Total |
| -- | -- | -- | -- | -- | -- |
| Small | 1M | 10M | ~344 MB | ~80 MB | ~424 MB |
| Medium | 10M | 100M | ~3.4 GB | ~800 MB | ~4.2 GB |
| Large | 100M | 1B | ~34 GB | ~8 GB | ~42 GB |

<sup>*</sup> The Properties column assumes 5 integer/float properties per node.*

Calculate memory for a social network:

```gql
-- Example: Social network with 5M users, 50M follows
-- Topology: 2 * (5M + 1) * 8 + 4 * 50M * 8 = ~1.7 GB
-- Properties (name, age, verified): ~60 MB
-- Recommended limit: 2GB

ALTER GRAPH socialNetwork SET COMPUTE MEMORY_LIMIT 2GB
```

Calculate memory for a knowledge graph:

```gql
-- Example: Knowledge graph with 20M entities, 200M relations
-- Topology: 2 * (20M + 1) * 8 + 4 * 200M * 8 = ~6.7 GB
-- Properties (title, type): ~320 MB
-- Recommended limit: 8GB

ALTER GRAPH knowledgeGraph SET COMPUTE MEMORY_LIMIT 8GB
```

## Partial Caching Strategy

For graphs larger than available memory, the computing engine supports partial caching:

**How Partial Caching Works:**

1. Topology builds until memory limit reached
2. Most-connected nodes prioritized (hubs cached first)
3. Uncached nodes fall back to disk-based storage
4. Queries still work correctly, just slower for uncached portions

**Optimizing Partial Caching:**

- Set limit to cache your "hot" subgraph
- Frequently traversed nodes get cached first
- Monitor cache hit rates and adjust

**Best Practices:**

- Cache at least 50% of graph for meaningful speedup
- Profile your queries to identify hot nodes
- Consider separate graphs for hot/cold data

Partial caching for large graphs:

```gql
-- Large graph with limited memory
-- Cache only the most important portion

ALTER GRAPH massiveGraph SET COMPUTE ENABLED
ALTER GRAPH massiveGraph SET COMPUTE MEMORY_LIMIT 16GB

-- Queries will use cache when possible
-- Falls back to disk for uncached nodes
MATCH (popular:User WHERE popular.followers > 10000)-[:FOLLOWS]->{1,3}(audience)
RETURN popular.name, count(audience)
```

## Monitoring Memory Usage

Monitor computing engine memory to optimize your configuration. Use `SHOW COMPUTE STATUS` for the full row reference.

**Key Rows:**

- `topologyMemory`: bytes used by the cached graph structure
- `propertyMemory`: bytes used by cached properties
- `totalMemory`: sum of the two (the engine's own footprint)
- `nodeCount` / `edgeCount`: how much of the graph is currently cached; compare against the graph's totals to gauge coverage under a memory limit
- `memoryLimit`: the configured cap, when set
- `goMemLimit` / `memLimitUsedPct`: the process-wide soft memory limit (the `GOMEMLIMIT` ceiling) and how close the process is to it; `> ~90%` warns of an imminent garbage-collection stall (see [Configuration](/docs/computing-engine/configuration#memory-limits))

**Tuning Tips:**

- Caching too little of the graph? Increase `MEMORY_LIMIT` or cache fewer properties per label.
- High memory, low benefit? Reduce the limit, or disable compute for this graph.
- Frequent rebuilds slowing writes? Consider `ASYNC` mode during write-heavy periods.

View computing engine statistics:

```gql
-- Current graph
SHOW COMPUTE STATUS

-- A specific graph
SHOW COMPUTE STATUS ON GRAPH myGraph
```

## Troubleshooting

Common memory-related issues and solutions:

**Build Fails or Incomplete**

- Symptom: Topology build stops early
- Cause: Memory limit too low
- Solution: Increase memory limit or accept partial caching

**High Memory, No Speedup**

- Symptom: Memory used but queries not faster
- Cause: Queries don't traverse cached portions
- Solution: Profile queries, adjust what's cached

**Out of Memory Errors**

- Symptom: Process crashes during build
- Cause: Memory limit exceeds available RAM
- Solution: Reduce limit, leave headroom for OS/queries

**Slow After Writes**

- Symptom: Queries slow immediately after mutations
- Cause: SYNC mode blocking on cache updates
- Solution: Use ASYNC mode for write-heavy periods

> **Warning:** Always leave at least 20% of system RAM for the operating system and query execution. Setting memory limits too high can cause system instability.
