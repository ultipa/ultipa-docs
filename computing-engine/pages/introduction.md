# What is the Computing Engine

## Overview

The **Computing Engine** is an optional in-memory acceleration layer in GQLDB that dramatically speeds up graph traversals and algorithms. Once enabled for a graph, pattern matching and shortest-path queries use the in-memory cache instead of reading from disk — typically 10–100× faster for traversal-heavy workloads.

The computing engine is ideal for workloads with frequent graph traversals, path queries, or algorithm execution on graphs that fit in available memory.

Enable computing engine for a graph:

```gql
ALTER GRAPH myGraph SET COMPUTE ENABLED
```

## Architecture

The computing engine has three parts that work together:

**1. Topology cache**: keeps the graph structure in memory. It's organized so that finding a node's neighbors is a direct memory lookup rather than a disk read, which is what makes traversals fast. Both directions are cached, so following out-edges and in-edges are equally quick. Filtering by label is also fast — there's a separate index per label, so a query like "all `:FOLLOWS` edges" doesn't have to scan everything.

**2. Property cache**: stores the values of selected node and edge properties in memory. You choose which properties to cache per label, since caching everything is rarely worth the memory. Cache the properties your queries read often (in `WHERE`, `RETURN`, `ORDER BY`) and leave the rest to disk.

**3. Memory budget manager**: keeps the engine from using more memory than you've allotted. You set the limits (`MEMORY_LIMIT`, `TOPOLOGY_LIMIT`, `PROPERTY_LIMIT`); the manager tracks usage and stops growing the cache when a limit is hit. By default the engine reserves about 60% of its budget for topology and 30% for properties, leaving the rest as working room.

Together, these let queries automatically use the cache when data is available and fall back to disk when it isn't — your queries don't change either way:

```gql
MATCH (user:User)-[:FOLLOWS]->(friend:User)-[:FOLLOWS]->(fof:User)
WHERE user.id = 'user-123'
RETURN DISTINCT fof.name
```

The same query runs whether the cache is fully built, partially built, or disabled — only the speed changes.

## Performance Benefits

| Workload | Without computing engine | With computing engine |
| -- | -- | -- |
| Neighbor lookup | Disk index read for every hop | Direct in-memory access |
| Multi-hop traversal (BFS / DFS) | Disk read at every step | 3–10× faster |
| Variable-length path queries | Largest cost without caching | Largest gains |
| Label-filtered edges (e.g., outgoing `:FOLLOWS`) | Scans the broader edge set | Per-label index, filter is essentially free |
| Iterative algorithms (PageRank, community detection) | I/O on every iteration | Cache reused across iterations |

The engine also falls back automatically: when only part of the graph is cached, queries against uncached nodes transparently use disk storage. You never get an error because the cache isn't fully built, only slower results until it is.

## When to Enable

Enable the computing engine when:

**Good Candidates:**

- Frequent multi-hop traversals (friends-of-friends, recommendations)
- Path-finding queries (shortest path, all paths)
- Graph algorithm workloads (centrality, community detection)
- Read-heavy workloads with occasional writes
- Graph fits in available memory (or most-accessed portion does)

**Consider Carefully:**

- Write-heavy workloads (sync overhead on each commit)
- Very large graphs exceeding available memory
- Simple single-hop queries (less benefit, sync overhead)

**Memory Requirements:**

| Graph Size | Approximate Memory |
| -- | -- |
| 1M nodes, 10M edges | ~400 MB |
| 10M nodes, 100M edges | ~4 GB |
| 100M nodes, 1B edges | ~40 GB |

You can set memory limits to cache only the most frequently accessed portion of larger graphs.

Query patterns that benefit from computing engine:

```gql
-- Multi-hop traversal
MATCH (a)-[:KNOWS]->{2,4}(b)
RETURN a, b

-- Path finding
MATCH p = SHORTEST 3 (a)-[:LINKS]-{1,10}(b)
RETURN p

-- Graph algorithms
CALL algo.pagerank({damping: 0.8, maxIterations: 50}) 
YIELD nodeId, score
```
