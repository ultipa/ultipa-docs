# Parallel Execution

This page covers PARALLEL FOR, the slice property system, and parallel reduction functions — the key building blocks for high-performance graph algorithms.

## PARALLEL FOR

Execute loop iterations across multiple worker goroutines:

### Basic Syntax

```gql
-- Auto-detect worker count (uses all CPU cores)
PARALLEL FOR node IN SCAN(:Person) {
    node.processed = true
}
```

### Explicit Worker Count

```gql
PARALLEL FOR node IN SCAN(:Person) WORKERS 8 {
    LET score = OUT_DEGREE(node) * 0.1
    node.score = score
}
```

### With Batching

Use `.batch(N)` for better throughput — nodes are fetched in batches of N:

```gql
PARALLEL FOR node IN SCAN(:Person).batch(1000) WORKERS 4 {
    LET degree = OUT_DEGREE(node)
    SET_SLICE_PROP(node._internal_id, 'degree', degree)
}
```

### Thread Safety Notes

- **Slice properties** (`GET_SLICE_PROP`, `SET_SLICE_PROP`) are safe for parallel access — each node has its own slot indexed by `_internal_id`
- **Temp properties** (`node.prop = value`) are safe — assigned per-node
- **LET** variables inside the loop body are local to each iteration
- **Shared accumulators** (e.g., `LET count = count + 1`) may have race conditions. For reductions, use `SUM_SLICE_PROP` instead
- **RETURN** statements are thread-safe — results are collected atomically

## Slice Property System

Slice properties provide O(1) per-node value storage backed by contiguous arrays indexed by `_internal_id`. They are the primary data structure for implementing graph algorithms.

### _internal_id

Every node has an `_internal_id` — a system-assigned integer used as the array index for slice properties. Access it via `node._internal_id`:

```gql
PARALLEL FOR node IN SCAN() WORKERS 8 {
    -- node._internal_id is the array index
    SET_SLICE_PROP(node._internal_id, 'rank', 1.0)
}
```

### INIT_SLICE_PROP

Initialize a slice property with a uniform value for all nodes:

```gql
-- Initialize all nodes with rank = 1/N
LET n = NODE_COUNT()
INIT_SLICE_PROP('rank', 1.0 / n)

-- Initialize all nodes with component = 0
INIT_SLICE_PROP('component', 0.0)
```

Internally parallelized for large graphs (>10K nodes).

### GET_SLICE_PROP

Read a node's slice property value by internal ID:

```gql
LET rank = GET_SLICE_PROP(node._internal_id, 'rank')
```

Also accepts integer index directly:

```gql
LET val = GET_SLICE_PROP(42, 'score')
```

### SET_SLICE_PROP

Write a node's slice property value:

```gql
SET_SLICE_PROP(node._internal_id, 'rank', new_rank)
```

### COPY_SLICE_PROP

Copy all values from one slice to another (bulk operation):

```gql
-- Copy new_rank → rank (for iterative algorithms)
COPY_SLICE_PROP('new_rank', 'rank')
```

Internally parallelized for large slices. Useful between iterations of algorithms like PageRank.

### INIT_OUT_DEGREES

Initialize a slice with out-degree values from the topology accelerator:

```gql
INIT_OUT_DEGREES('out_degree')

-- Now GET_SLICE_PROP(node._internal_id, 'out_degree') returns the out-degree
```

This is much faster than computing degrees in a loop.

## Parallel Reduction Functions

High-performance aggregate operations over slice properties. Automatically parallelized.

### SUM_SLICE_PROP

Sum all values in a slice property:

```gql
LET total_rank = SUM_SLICE_PROP('rank')
```

### SUM_SLICE_PROP_SQ

Sum of squares — essential for L2 normalization:

```gql
LET norm_sq = SUM_SLICE_PROP_SQ('score')
LET norm = SQRT(norm_sq)
```

### MAX_SLICE_PROP / MIN_SLICE_PROP

Find extremes across all nodes:

```gql
LET max_rank = MAX_SLICE_PROP('rank')
LET min_rank = MIN_SLICE_PROP('rank')
LET range = max_rank - min_rank
```

## Batch Persistence

Persist slice property values to actual node properties in storage.

### BATCH_PERSIST_SLICE

Persist a single slice to storage:

```gql
-- After PageRank completes, save results
BATCH_PERSIST_SLICE('rank', 'pagerank_score')
```

This writes `slice['rank'][node._internal_id]` → `node.pagerank_score` for all nodes.

### BATCH_PERSIST_SLICES

Persist multiple slices in a single efficient pass:

```gql
-- HITS algorithm: persist both hub and authority scores
BATCH_PERSIST_SLICES('hub', 'hub_score', 'auth', 'authority_score')
```

`BATCH_PERSIST_SLICES` is more efficient than multiple `BATCH_PERSIST_SLICE` calls because it:
- Reads from property cache only once per node
- Copies property map only once per node
- Encodes and writes only once per node

### BATCH_SLICE_ADD

Add a constant value to all elements in a slice:

```gql
-- Add teleportation probability to all ranks
BATCH_SLICE_ADD('rank', (1.0 - damping) / n)
```

## Pattern: Iterative Algorithm

Most graph algorithms follow this pattern using the parallel execution primitives:

```gql
CREATE PROCEDURE algorithm(iterations: INT = 20)
RETURNS (node_id: STRING, score: FLOAT)
AS {
    -- 1. Initialize slice properties
    INIT_SLICE_PROP('score', initial_value)
    INIT_SLICE_PROP('new_score', 0.0)
    INIT_OUT_DEGREES('out_degree')

    -- 2. Iterate until convergence or max iterations
    FOR iter IN RANGE(0, $iterations) {
        -- 2a. Reset accumulator
        INIT_SLICE_PROP('new_score', 0.0)

        -- 2b. Parallel computation
        PARALLEL FOR node IN SCAN() WORKERS 8 {
            LET contrib = IN_NEIGHBOR_SUM(node, 'score', 'out_degree')
            SET_SLICE_PROP(node._internal_id, 'new_score', contrib)
        }

        -- 2c. Swap (or normalize then swap)
        COPY_SLICE_PROP('new_score', 'score')
    }

    -- 3. Persist results
    BATCH_PERSIST_SLICE('score', 'algorithm_score')

    -- 4. Return results
    FOR node IN SCAN() {
        LET score = GET_SLICE_PROP(node._internal_id, 'score')
        RETURN node._id AS node_id, score
    }
}
```

## Performance Tips

### Choose the Right Worker Count

- **CPU-bound** (arithmetic, slice ops): Use `WORKERS N` where N = number of CPU cores
- **I/O-bound** (property lookups from storage): Use more workers (2x-4x cores)
- **Default** (no WORKERS specified): Auto-detects CPU count

### Use .batch() for Large Scans

Batching reduces scheduling overhead:

```gql
-- Without batching: each node is dispatched individually
PARALLEL FOR node IN SCAN(:Person) WORKERS 8 { ... }

-- With batching: nodes dispatched in chunks of 1000
PARALLEL FOR node IN SCAN(:Person).batch(1000) WORKERS 8 { ... }
```

### Prefer Slice Properties Over Temp Properties

For algorithms that access properties in PARALLEL FOR:

```gql
-- FAST: O(1) array access
SET_SLICE_PROP(node._internal_id, 'rank', value)
LET rank = GET_SLICE_PROP(node._internal_id, 'rank')

-- SLOWER: Map-based property access
node.rank = value
LET rank = node.rank
```

### Use Fused Neighbor Operations

Instead of manually iterating neighbors:

```gql
-- SLOW: Per-neighbor interpreter overhead
LET sum = 0
FOR neighbor IN NEIGHBORS(node, IN) {
    sum = sum + GET_SLICE_PROP(neighbor._internal_id, 'rank')
}

-- FAST: Single fused operation, direct CSR/CSC access
LET sum = SUM_IN_NEIGHBOR_PROP(node, 'rank')
```
