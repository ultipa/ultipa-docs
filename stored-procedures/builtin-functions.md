# Built-in Functions

Complete reference for all procedure-specific built-in functions. These are in addition to the 100+ standard GQL functions available from the general function registry.

## Topology Functions

O(1) lookups from the compute engine's CSR/CSC topology.

| Function | Signature | Description |
|----------|-----------|-------------|
| `OUT_DEGREE` | `OUT_DEGREE(node) → INTEGER` | Out-degree of a node |
| `IN_DEGREE` | `IN_DEGREE(node) → INTEGER` | In-degree of a node |
| `NODE_COUNT` | `NODE_COUNT() → INTEGER` | Total number of nodes in the graph |

```gql
LET deg = OUT_DEGREE(node)      -- O(1) from CSR
LET in_deg = IN_DEGREE(node)    -- O(1) from CSC
LET n = NODE_COUNT()            -- Total nodes
```

**Requirement**: These functions require the compute engine (`ALTER COMPUTE ENABLE`). Without it, they return 0.

## Fused Neighbor Operations

Direct CSR/CSC neighbor operations that eliminate per-neighbor interpreter overhead. These are the key optimizations for iterative graph algorithms.

| Function | Signature | Description |
|----------|-----------|-------------|
| `SUM_OUT_NEIGHBOR_PROP` | `SUM_OUT_NEIGHBOR_PROP(node, propName) → FLOAT` | Sum of outgoing neighbors' slice property |
| `SUM_IN_NEIGHBOR_PROP` | `SUM_IN_NEIGHBOR_PROP(node, propName) → FLOAT` | Sum of incoming neighbors' slice property |
| `OUT_NEIGHBOR_SUM` | `OUT_NEIGHBOR_SUM(node, propName) → FLOAT` | Sum of (prop / out_degree) for outgoing neighbors |
| `IN_NEIGHBOR_SUM` | `IN_NEIGHBOR_SUM(node, rankProp, degreeProp) → FLOAT` | Sum of (rank / degree) for incoming neighbors |
| `MIN_OUT_NEIGHBOR_PROP` | `MIN_OUT_NEIGHBOR_PROP(node, propName, initVal) → FLOAT` | Minimum of outgoing neighbors' property |
| `MIN_IN_NEIGHBOR_PROP` | `MIN_IN_NEIGHBOR_PROP(node, propName, initVal) → FLOAT` | Minimum of incoming neighbors' property |
| `MIN_BOTH_NEIGHBOR_PROP` | `MIN_BOTH_NEIGHBOR_PROP(node, propName, initVal) → FLOAT` | Minimum across both directions |

### Usage Examples

**PageRank contribution** (sum of rank/degree from in-neighbors):

```gql
LET contrib = IN_NEIGHBOR_SUM(node, 'rank', 'out_degree')
```

**HITS authority update** (sum of hub scores from in-neighbors):

```gql
LET new_auth = SUM_IN_NEIGHBOR_PROP(node, 'hub')
```

**Connected components** (minimum component ID among all neighbors):

```gql
LET min_comp = MIN_BOTH_NEIGHBOR_PROP(node, 'component', current_comp)
```

**SSSP relaxation** (minimum distance from outgoing neighbors):

```gql
LET min_dist = MIN_OUT_NEIGHBOR_PROP(node, 'distance', current_dist)
```

## Slice Property Functions

High-performance per-node value storage backed by contiguous arrays.

| Function | Signature | Description |
|----------|-----------|-------------|
| `INIT_SLICE_PROP` | `INIT_SLICE_PROP(name, value)` | Initialize all nodes with a value |
| `GET_SLICE_PROP` | `GET_SLICE_PROP(idx, name) → Value` | Get value by internal node ID |
| `SET_SLICE_PROP` | `SET_SLICE_PROP(idx, name, value)` | Set value by internal node ID |
| `COPY_SLICE_PROP` | `COPY_SLICE_PROP(src, dst)` | Copy all values from source to destination |
| `INIT_OUT_DEGREES` | `INIT_OUT_DEGREES(name)` | Initialize slice with out-degrees |

See <a href="/docs/stored-procedures/parallel-execution">Parallel Execution</a> for detailed usage.

## Parallel Reduction Functions

Aggregate operations over slice properties with automatic parallelization.

| Function | Signature | Description |
|----------|-----------|-------------|
| `SUM_SLICE_PROP` | `SUM_SLICE_PROP(propName) → FLOAT` | Parallel sum of all values |
| `SUM_SLICE_PROP_SQ` | `SUM_SLICE_PROP_SQ(propName) → FLOAT` | Parallel sum of squares (for L2 norm) |
| `MAX_SLICE_PROP` | `MAX_SLICE_PROP(propName) → FLOAT` | Parallel maximum |
| `MIN_SLICE_PROP` | `MIN_SLICE_PROP(propName) → FLOAT` | Parallel minimum |

```gql
-- L2 normalization
LET norm = SQRT(SUM_SLICE_PROP_SQ('score'))
PARALLEL FOR node IN SCAN() WORKERS 8 {
    LET val = GET_SLICE_PROP(node._internal_id, 'score')
    SET_SLICE_PROP(node._internal_id, 'score', val / norm)
}

-- Get value range
LET max_val = MAX_SLICE_PROP('rank')
LET min_val = MIN_SLICE_PROP('rank')
```

## Set Operations

Hash-based O(n) set operations on lists.

| Function | Signature | Description |
|----------|-----------|-------------|
| `INTERSECT` | `INTERSECT(listA, listB) → LIST` | A ∩ B |
| `UNION` | `UNION(listA, listB) → LIST` | A ∪ B |
| `DIFFERENCE` | `DIFFERENCE(listA, listB) → LIST` | A - B |
| `SIZE` | `SIZE(collection) → INTEGER` | Size of list, map, or string |

```gql
LET friends_a = NEIGHBORS(a, OUT, :KNOWS)
LET friends_b = NEIGHBORS(b, OUT, :KNOWS)

LET common = INTERSECT(friends_a, friends_b)
LET all_friends = UNION(friends_a, friends_b)
LET only_a = DIFFERENCE(friends_a, friends_b)
LET count = SIZE(common)
```

## Common Neighbor Functions

Optimized functions using the topology accelerator.

| Function | Signature | Description |
|----------|-----------|-------------|
| `COMMON_NEIGHBORS` | `COMMON_NEIGHBORS(nodeA, nodeB) → LIST` | List of common neighbors |
| `COUNT_COMMON_NEIGHBORS` | `COUNT_COMMON_NEIGHBORS(nodeA, nodeB) → INTEGER` | Count of common neighbors |
| `JACCARD_SIMILARITY` | `JACCARD_SIMILARITY(nodeA, nodeB) → FLOAT` | \|A ∩ B\| / \|A ∪ B\| |
| `ADAMIC_ADAR` | `ADAMIC_ADAR(nodeA, nodeB) → FLOAT` | Σ 1/log(degree(c)) for common neighbors c |

```gql
LET common = COMMON_NEIGHBORS(node_a, node_b)
LET count = COUNT_COMMON_NEIGHBORS(node_a, node_b)
LET similarity = JACCARD_SIMILARITY(node_a, node_b)
LET aa_score = ADAMIC_ADAR(node_a, node_b)
```

## Map Operations

O(1) lookup map operations for external data integration.

| Function | Signature | Description |
|----------|-----------|-------------|
| `LIST_TO_MAP` | `LIST_TO_MAP(list, keyIndex) → MAP` | Convert list of lists to map |
| `LIST_TO_GROUPED_MAP` | `LIST_TO_GROUPED_MAP(list, keyIndex) → MAP` | Group entries by key |
| `MAP_GET` | `MAP_GET(map, key [, default]) → Value` | Get value from map |

### LIST_TO_MAP

Converts a list of lists to a map using the element at `keyIndex` as the key. Duplicate keys are overwritten (last wins).

```gql
-- Input: [[sku, name, price], ...]
LET productMap = LIST_TO_MAP($productData, 0)  -- key by sku (index 0)

LET record = MAP_GET(productMap, 'SKU123')
-- record is [sku, name, price] or NULL
```

### LIST_TO_GROUPED_MAP

Like LIST_TO_MAP but groups all entries with the same key into a list:

```gql
-- Input: [[rate_code, rate, date], ...]
LET rateMap = LIST_TO_GROUPED_MAP($rateData, 0)  -- group by rate_code

LET rates = MAP_GET(rateMap, 'PRIME')
-- rates is [[code, rate1, date1], [code, rate2, date2], ...]
```

### MAP_GET

```gql
LET value = MAP_GET(myMap, 'key')           -- returns NULL if not found
LET value = MAP_GET(myMap, 'key', 0.0)      -- returns 0.0 if not found
```

## Batch Operations

High-throughput batch operations for data enrichment.

| Function | Signature | Description |
|----------|-----------|-------------|
| `BATCH_MAP_TO_SLICE` | `BATCH_MAP_TO_SLICE(map, nodePropName, slicePropName, valueIndex)` | Batch map lookups by node property |
| `BATCH_SLICE_MAP_TO_SLICE` | `BATCH_SLICE_MAP_TO_SLICE(map, srcSlice, dstSlice, valueIndex)` | Batch lookups from slice to slice |

```gql
-- Enrich all nodes: lookup each node's 'sku' in map, extract price (index 2)
LET productMap = LIST_TO_MAP($productData, 0)
BATCH_MAP_TO_SLICE(productMap, 'sku', 'price', 2)
```

## Batch Persistence

| Function | Signature | Description |
|----------|-----------|-------------|
| `BATCH_PERSIST_SLICE` | `BATCH_PERSIST_SLICE(sliceName, propName)` | Persist one slice to storage |
| `BATCH_PERSIST_SLICES` | `BATCH_PERSIST_SLICES(s1, p1, s2, p2, ...)` | Persist multiple in one pass |
| `BATCH_SLICE_ADD` | `BATCH_SLICE_ADD(sliceName, value)` | Add constant to all slice values |

## Batch Insert

| Function | Signature | Description |
|----------|-----------|-------------|
| `BATCH_INSERT_NODES` | `BATCH_INSERT_NODES(label, dataList)` | Bulk insert nodes |
| `BATCH_INSERT_EDGES` | `BATCH_INSERT_EDGES(edgeType, dataList)` | Bulk insert edges |

## List Operations

| Function | Signature | Description |
|----------|-----------|-------------|
| `APPEND` | `APPEND(list, item) → LIST` | Append item to list (also `LIST_APPEND`) |

## Type Conversion

| Function | Aliases | Description |
|----------|---------|-------------|
| `TOSTRING(value)` | `TOSTR` | Convert to string |
| `TOINTEGER(value)` | `TOINT` | Convert to integer |
| `TOFLOAT(value)` | `TODOUBLE` | Convert to float |

## Math Functions

| Function | Aliases | Description |
|----------|---------|-------------|
| `ABS(x)` | — | Absolute value |
| `CEIL(x)` | `CEILING` | Round up |
| `FLOOR(x)` | — | Round down |
| `ROUND(x)` | — | Round to nearest |
| `SQRT(x)` | — | Square root |
| `POW(x, y)` | `POWER` | x raised to power y |
| `MIN(a, b)` | — | Minimum of two values |
| `MAX(a, b)` | — | Maximum of two values |

## String Functions

| Function | Aliases | Description |
|----------|---------|-------------|
| `SUBSTRING(str, start, len)` | `SUBSTR` | Extract substring |
| `LENGTH(str)` | `LEN` | String length |

## Utility Functions

| Function | Description |
|----------|-------------|
| `COALESCE(a, b, ...)` | Return first non-NULL value |
| `IF(condition, then, else)` | Inline conditional |
| `TIMESTAMP_MS()` | Current time in milliseconds |
| `DATE_DIFF(date1, date2)` | Difference between dates (also `DATEDIFF`) |

```gql
LET name = COALESCE(node.nickname, node.name, 'Unknown')
LET status = IF(score > 0.5, 'high', 'low')
LET now = TIMESTAMP_MS()
```

## Standard Function Registry

In addition to the procedure-specific functions above, all 100+ standard GQL functions are available:

- **String**: `UPPER`, `LOWER`, `TRIM`, `SPLIT`, `STARTSWITH`, `ENDSWITH`, `CONTAINS`
- **Math**: `LOG`, `SIN`, `COS`, `TAN`, `RAND`
- **Aggregate**: `COUNT`, `SUM`, `AVG`
- **Type**: `TYPEOF`, `LABELS`
- **List**: `HEAD`, `TAIL`, `REVERSE`, `RANGE`
- **Date/Time**: `DATE`, `TIME`, `DATETIME`, `DURATION`

These are looked up via the cached function registry and work identically to their usage in regular GQL queries.
