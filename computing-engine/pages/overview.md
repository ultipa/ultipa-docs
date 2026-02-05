# Computing Engine

## Overview

The **Computing Engine** is an optional in-memory acceleration layer that dramatically speeds up graph traversals (DFS, BFS, K-hop) and algorithms.

**Key Features:**

- **Transparent Acceleration** - Existing MATCH queries automatically benefit without modification
- **CSR/CSC Format** - Compressed sparse matrices enable O(1) neighbor lookups
- **Event-Driven Sync** - Updates propagate on commit, not via polling
- **Configurable Memory** - Per-graph budgets prevent out-of-memory issues
- **Automatic Fallback** - Queries fall back to disk-based storage when needed

The computing engine is ideal for workloads with frequent graph traversals, path queries, or algorithm execution on graphs that fit in available memory.

```gql
-- Enable computing engine for a graph
ALTER GRAPH myGraph SET COMPUTE ENABLED

-- Queries automatically use acceleration
MATCH (a:Person)-[:KNOWS]->{1,5}(b:Person)
WHERE a.name = 'Alice'
RETURN b.name
```

## Architecture

The computing engine consists of three main components:

**1. Topology Cache (CSR + CSC)**

- **CSR (Compressed Sparse Row)** - Optimized for outgoing edge lookups
- **CSC (Compressed Sparse Column)** - Optimized for incoming edge lookups
- Provides O(1) neighbor access instead of O(log n) disk-based lookups
- Label-indexed adjacency for efficient filtered traversals

**2. Property Cache**

- Columnar storage for frequently accessed node/edge properties
- User-configurable: choose which properties to cache per label
- Avoids disk I/O for hot properties

**3. Memory Budget Manager**

- Tracks memory usage across topology and property caches
- Enforces per-graph limits to prevent OOM
- Default allocation: 60% topology, 30% properties, 10% working memory

Multi-hop traversal automatically accelerated:

```gql
-- Query flow with computing engine:
-- 1. Pattern matching checks if accelerator available
-- 2. Falls back to storage if node not cached
-- 3. Results returned transparently

MATCH (user:User)-[:FOLLOWS]->(friend:User)
      -[:FOLLOWS]->(fof:User)
WHERE user.id = 'user-123'
RETURN DISTINCT fof.name
```

## Performance Benefits

The computing engine provides significant performance improvements for graph workloads:

**Neighbor Lookups**

- Without computing engine: O(log n) disk-based index lookup
- With computing engine: O(1) direct array access

**Path Traversals**

- 3-10x faster for BFS/DFS queries
- Variable-length path queries see the largest gains

**Label-Filtered Queries**

- Separate per-label indices enable O(1) filtering
- e.g., "all outgoing FOLLOWS edges" without scanning all edges

**Algorithm Execution**

- Graph algorithms benefit from cache locality
- Reduced I/O for iterative algorithms (PageRank, community detection)

**Automatic Fallback**

- Queries work correctly even when cache is partial
- Cold nodes transparently use disk-based storage

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
CALL algo.centrality.pagerank({iterations: 20})
YIELD nodeId, score
```
