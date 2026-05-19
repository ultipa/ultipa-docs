# Built-in Functions

Complete reference for all procedure-specific built-in functions.

## Topology Functions

O(1) lookups from the compute engine's topology.

| Function | Return | Description |
|----------|--------|-------------|
| `OUT_DEGREE(node)` | `INTEGER` | Out-degree of a node |
| `IN_DEGREE(node)` | `INTEGER` | In-degree of a node |
| `NODE_COUNT()` | `INTEGER` | Total number of nodes in the graph |

<p tit="Procedure Body Language"></p>

```gql
LET deg = OUT_DEGREE(node)      -- O(1) lookup
LET in_deg = IN_DEGREE(node)    -- O(1) lookup
LET n = NODE_COUNT()            -- Total nodes
```

**Requirement**: These functions require the compute engine (`ALTER GRAPH <graph_name> SET COMPUTE ENABLED`). Without it, they return 0.

## Neighbor Aggregation Functions

Direct neighbor operations that eliminate per-neighbor interpreter overhead. These are the key optimizations for iterative graph algorithms.

| Function | Return | Description |
|----------|--------|-------------|
| `SUM_OUT_NEIGHBOR_PROP(node, propName)` | `FLOAT` | Sum of outgoing neighbors' property |
| `SUM_IN_NEIGHBOR_PROP(node, propName)` | `FLOAT` | Sum of incoming neighbors' property |
| `OUT_NEIGHBOR_SUM(node, propName)` | `FLOAT` | For each out-neighbor, sums `property / out_degree` |
| `IN_NEIGHBOR_SUM(node, rankProp, degreeProp)` | `FLOAT` | For each in-neighbor, sums `rankProp / degreeProp` |
| `MIN_OUT_NEIGHBOR_PROP(node, propName, initVal)` | `FLOAT` | Minimum of outgoing neighbors' property |
| `MIN_IN_NEIGHBOR_PROP(node, propName, initVal)` | `FLOAT` | Minimum of incoming neighbors' property |
| `MIN_BOTH_NEIGHBOR_PROP(node, propName, initVal)` | `FLOAT` | Minimum across both directions |

**PageRank contribution** (sum of rank/degree from in-neighbors):

<p tit="Procedure Body Language"></p>

```gql
LET contrib = IN_NEIGHBOR_SUM(n, 'rank', 'out_degree')
```

**HITS authority update** (sum of hub scores from in-neighbors):

<p tit="Procedure Body Language"></p>

```gql
LET new_auth = SUM_IN_NEIGHBOR_PROP(n, 'hub')
```

**Connected components** (minimum component ID among all neighbors):

<p tit="Procedure Body Language"></p>

```gql
LET min_comp = MIN_BOTH_NEIGHBOR_PROP(n, 'component', current_comp)
```

**SSSP relaxation** (minimum distance from outgoing neighbors):

<p tit="Procedure Body Language"></p>

```gql
LET min_dist = MIN_OUT_NEIGHBOR_PROP(n, 'distance', current_dist)
```

## Slice Property Functions

High-performance per-node value storage backed by contiguous arrays.

| Function | Return | Description |
|----------|--------|-------------|
| `INIT_SLICE_PROP(name, value)` | - | Initialize all nodes with a value |
| `GET_SLICE_PROP(idx, name)` | `Value` | Get value by internal node ID |
| `SET_SLICE_PROP(idx, name, value)` | - | Set value by internal node ID |
| `COPY_SLICE_PROP(src, dst)` | - | Copy all values from source to destination |
| `INIT_OUT_DEGREES(name)` | - | Initialize slice with out-degrees |

See <a href="/docs/stored-procedures/parallel-execution">Parallel Execution</a> for detailed usage.

## Parallel Reduction Functions

Aggregate operations over slice properties with automatic parallelization.

| Function | Return | Description |
|----------|--------|-------------|
| `SUM_SLICE_PROP(propName)` | `FLOAT` | Parallel sum of all values |
| `SUM_SLICE_PROP_SQ(propName)` | `FLOAT` | Parallel sum of squares (for L2 norm) |
| `MAX_SLICE_PROP(propName)` | `FLOAT` | Parallel maximum |
| `MIN_SLICE_PROP(propName)` | `FLOAT` | Parallel minimum |

<p tit="Procedure Body Language"></p>

```gql
-- L2 normalization
LET norm = SQRT(SUM_SLICE_PROP_SQ('score'))
PARALLEL FOR n IN SCAN() WORKERS 8 {
    LET val = GET_SLICE_PROP(n._internal_id, 'score')
    SET_SLICE_PROP(n._internal_id, 'score', val / norm)
}

-- Get value range
LET max_val = MAX_SLICE_PROP('rank')
LET min_val = MIN_SLICE_PROP('rank')
```

## Set Operations

Hash-based O(n) set operations on lists.

| Function | Return | Description |
|----------|--------|-------------|
| `INTERSECT(listA, listB)` | `LIST` | A ∩ B |
| `UNION(listA, listB)` | `LIST` | A ∪ B |
| `DIFFERENCE(listA, listB)` | `LIST` | A - B |
| `SIZE(collection)` | `INTEGER` | Size of list, map, or string |

<p tit="Procedure Body Language"></p>

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

| Function | Return | Description |
|----------|--------|-------------|
| `COMMON_NEIGHBORS(nodeA, nodeB)` | `LIST` | List of common neighbors |
| `COUNT_COMMON_NEIGHBORS(nodeA, nodeB)` | `INTEGER` | Count of common neighbors |
| `JACCARD_SIMILARITY(nodeA, nodeB)` | `FLOAT` | \|A ∩ B\| / \|A ∪ B\| |
| `ADAMIC_ADAR(nodeA, nodeB)` | `FLOAT` | Σ 1/log(degree(c)) for common neighbors c |

<p tit="Procedure Body Language"></p>

```gql
LET common = COMMON_NEIGHBORS(node_a, node_b)
LET count = COUNT_COMMON_NEIGHBORS(node_a, node_b)
LET similarity = JACCARD_SIMILARITY(node_a, node_b)
LET aa_score = ADAMIC_ADAR(node_a, node_b)
```

## Map Operations

O(1) lookup map operations for external data integration.

| Function | Return | Description |
|----------|--------|-------------|
| `LIST_TO_MAP(list, keyIndex)` | `MAP` | Convert list of lists to map |
| `LIST_TO_GROUPED_MAP(list, keyIndex)` | `MAP` | Group entries by key |
| `MAP_GET(map, key [, default])` | `Value` | Get value from map |

Converts a list of lists to a map using the element at `keyIndex` as the key. Duplicate keys are overwritten (last wins).

<p tit="Procedure Body Language"></p>

```gql
-- Input: [[sku, name, price], ...]
LET productMap = LIST_TO_MAP($productData, 0)  -- key by sku (index 0)

LET record = MAP_GET(productMap, 'SKU123')
-- record is [sku, name, price] or NULL
```

`LIST_TO_GROUPED_MAP` is like `Like LIST_TO_MAP` but groups all entries with the same key into a list:

<p tit="Procedure Body Language"></p>

```gql
-- Input: [[rate_code, rate, date], ...]
LET rateMap = LIST_TO_GROUPED_MAP($rateData, 0)  -- group by rate_code

LET rates = MAP_GET(rateMap, 'PRIME')
-- rates is [[code, rate1, date1], [code, rate2, date2], ...]
```

<p tit="Procedure Body Language"></p>

```gql
LET value = MAP_GET(myMap, 'key')           -- returns NULL if not found
LET value = MAP_GET(myMap, 'key', 0.0)      -- returns 0.0 if not found
```

## Batch Operations

High-throughput batch operations for data enrichment.

| Function | Return | Description |
|----------|--------|-------------|
| `BATCH_MAP_TO_SLICE(map, nodePropName, slicePropName, valueIndex)` | - | Batch map lookups by node property |
| `BATCH_SLICE_MAP_TO_SLICE(map, srcSlice, dstSlice, valueIndex)` | - | Batch lookups from slice to slice |

<p tit="Procedure Body Language"></p>

```gql
-- Enrich all nodes: lookup each node's 'sku' in map, extract price (index 2)
LET productMap = LIST_TO_MAP($productData, 0)
BATCH_MAP_TO_SLICE(productMap, 'sku', 'price', 2)
```

## Batch Persistence

| Function | Return | Description |
|----------|--------|-------------|
| `BATCH_PERSIST_SLICE(sliceName, propName)` | `INTEGER` | Persist one slice to storage as a node property |
| `BATCH_PERSIST_SLICES(s1, p1, s2, p2, ...)` | `INTEGER` | Persist multiple slice→property pairs in one pass |
| `BATCH_SLICE_ADD_SCALAR(sliceName, constant)` | `INTEGER` | Add a constant to every element in a slice |
| `BATCH_SLICE_ADD(slice1, slice2, output)` | `INTEGER` | Element-wise: `output[i] = slice1[i] + slice2[i]` |

## Batch Insert

Each function takes a single argument — a list of maps. Labels and endpoints are carried inside each map.

| Function | Return | Description |
|----------|--------|-------------|
| `BATCH_INSERT_NODES(nodeList)` | `INTEGER` | Bulk insert nodes. Each map: `labels: LIST<STRING>`, optional `_id`, other keys as properties |
| `BATCH_INSERT_EDGES(edgeList)` | `INTEGER` | Bulk insert edges. Each map: `label: STRING`, `_from`, `_to`, other keys as properties |

See <a href="/docs/stored-procedures/data-operations#batch-insert">Data Operations — Batch Insert</a> for worked examples.

## List Operations

| Function | Return | Description |
|----------|--------|-------------|
| `APPEND(list, item)` | `LIST` | Append item to list (also `LIST_APPEND`) |

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

<p tit="Procedure Body Language"></p>

```gql
LET name = COALESCE(node.nickname, node.name, 'Unknown')
LET status = IF(score > 0.5, 'high', 'low')
LET now = TIMESTAMP_MS()
```

## Standard GQL Functions

In addition to the procedure-specific functions above, all standard GQL functions are also available inside procedure bodies. See <a target="_blank" href="/docs/gql/all-functions">All GQL Functions</a> for the full catalog. 

If a function is not recognized as a procedure-specific built-in, it is looked up in the standard GQL function registry. An error is returned if the function name is not found in either.