# Quick Reference

Compact syntax summaries and reference tables for stored procedures.

## Statement Syntax Summary

### Procedure Lifecycle

```
CREATE PROCEDURE name(param: TYPE [= default], ...)
RETURNS (col: TYPE, ...) | VOID
AS { body }

CREATE OR REPLACE PROCEDURE name(...) RETURNS ... AS { body }

DROP PROCEDURE name
DROP PROCEDURE IF EXISTS name

SHOW PROCEDURES
SHOW PROCEDURES LIKE 'pattern'

CALL name(args) [YIELD col1, col2]
CALL name(args) ON projection [YIELD col1, col2]
CALL namespace.name(args) [YIELD col1, col2]
CALL { subquery }
OPTIONAL CALL { subquery }
CALL (vars) { subquery }
```

### Control Flow

```
IF condition { ... }
IF condition { ... } ELSE { ... }
IF condition { ... } ELSE IF condition { ... } ELSE { ... }

FOR var IN source { ... }
PARALLEL FOR var IN source [WORKERS N] { ... }
FOR (node, depth) IN MATCH [BFS|KHOP|SHORTEST] pattern { ... }
FOR path IN MATCH [SHORTEST [k] | ALL SHORTEST] pattern { ... }

WHILE condition { ... }
BREAK
CONTINUE

TRY { ... } CATCH { ... }
TRY { ... } CATCH (e) { ... }
THROW expression
THROW

ATOMIC { ... }
```

### Data Operations

```
LET var = expression
var = expression                    -- reassignment
node.prop = value                   -- temp property (in-memory)

MATCH pattern [WHERE condition]
INSERT pattern
SET node.prop = value               -- persistent
DELETE node
DETACH DELETE node

RETURN expr [AS alias], ...
RETURN                              -- empty (VOID)
PRINT expression
FLUSH
```

## Type Reference

| Type | Aliases | Default Value |
|------|---------|---------------|
| `STRING` | — | `''` |
| `INTEGER` | `INT` | `0` |
| `FLOAT` | — | `0.0` |
| `BOOLEAN` | — | `false` |
| `NODE` | — | `NULL` |
| `EDGE` | — | `NULL` |
| `PATH` | — | `NULL` |
| `LIST<T>` | — | `[]` |

## Iterator Sources

| Source | Syntax | Returns |
|--------|--------|---------|
| Scan all | `SCAN()` | All nodes |
| Scan by label | `SCAN(:Label)` | Nodes with label |
| Scan with filter | `SCAN(:Label {prop: val})` | Filtered nodes |
| Scan with batch | `SCAN(:Label).batch(N)` | Batched nodes |
| All edges | `EDGES()` | All edges |
| Edges by type | `EDGES(:Type)` | Typed edges |
| Edges with batch | `EDGES(:Type).batch(N)` | Batched edges |
| Neighbors | `NEIGHBORS(node)` | Both-direction neighbors |
| Directed neighbors | `NEIGHBORS(node, OUT\|IN)` | Directed neighbors |
| Typed neighbors | `NEIGHBORS(node, dir, :Type)` | Typed neighbors |
| Range | `RANGE(start, end)` | Integers [start, end) |
| List | `[1, 2, 3]` | List elements |

## Traversal Modes

| Mode | Syntax | Variables | Use Case |
|------|--------|-----------|----------|
| DFS | `MATCH` | `(node, depth)` | Deep exploration |
| BFS | `MATCH BFS` | `(node, depth)` | Shortest hops, level-order |
| KHOP | `MATCH KHOP` | `(node, depth)` | K-hop neighbors |
| Shortest | `MATCH SHORTEST` | `path` | Single shortest path |
| K Shortest | `MATCH SHORTEST k` | `path` | Top-k shortest |
| All Shortest | `MATCH ALL SHORTEST` | `path` | All shortest paths |

## Direction Patterns

| Pattern | Direction |
|---------|-----------|
| `(a)-[:E]->(b)` | Outgoing |
| `(a)<-[:E]-(b)` | Incoming |
| `(a)-[:E]-(b)` | Both (undirected) |

## Function Quick Reference

### Topology (O(1))

| Function | Returns |
|----------|---------|
| `OUT_DEGREE(node)` | `INTEGER` |
| `IN_DEGREE(node)` | `INTEGER` |
| `NODE_COUNT()` | `INTEGER` |

### Slice Properties

| Function | Description |
|----------|-------------|
| `INIT_SLICE_PROP(name, val)` | Init all nodes |
| `GET_SLICE_PROP(idx, name)` | Read value |
| `SET_SLICE_PROP(idx, name, val)` | Write value |
| `COPY_SLICE_PROP(src, dst)` | Bulk copy |
| `INIT_OUT_DEGREES(name)` | Init with degrees |

### Reductions

| Function | Returns |
|----------|---------|
| `SUM_SLICE_PROP(name)` | `FLOAT` |
| `SUM_SLICE_PROP_SQ(name)` | `FLOAT` |
| `MAX_SLICE_PROP(name)` | `FLOAT` |
| `MIN_SLICE_PROP(name)` | `FLOAT` |

### Fused Neighbor Ops

| Function | Description |
|----------|-------------|
| `SUM_OUT_NEIGHBOR_PROP(node, prop)` | Sum outgoing neighbors |
| `SUM_IN_NEIGHBOR_PROP(node, prop)` | Sum incoming neighbors |
| `OUT_NEIGHBOR_SUM(node, prop)` | Sum(prop/degree) outgoing |
| `IN_NEIGHBOR_SUM(node, rank, deg)` | Sum(rank/deg) incoming |
| `MIN_OUT_NEIGHBOR_PROP(node, prop, init)` | Min outgoing |
| `MIN_IN_NEIGHBOR_PROP(node, prop, init)` | Min incoming |
| `MIN_BOTH_NEIGHBOR_PROP(node, prop, init)` | Min both |

### Set Operations

| Function | Description |
|----------|-------------|
| `INTERSECT(a, b)` | A ∩ B |
| `UNION(a, b)` | A ∪ B |
| `DIFFERENCE(a, b)` | A - B |
| `SIZE(collection)` | Count |

### Common Neighbors

| Function | Returns |
|----------|---------|
| `COMMON_NEIGHBORS(a, b)` | `LIST` |
| `COUNT_COMMON_NEIGHBORS(a, b)` | `INTEGER` |
| `JACCARD_SIMILARITY(a, b)` | `FLOAT` |
| `ADAMIC_ADAR(a, b)` | `FLOAT` |

### Map Operations

| Function | Description |
|----------|-------------|
| `LIST_TO_MAP(list, keyIdx)` | List → Map |
| `LIST_TO_GROUPED_MAP(list, keyIdx)` | List → Grouped Map |
| `MAP_GET(map, key [, default])` | Lookup |

### Batch Operations

| Function | Description |
|----------|-------------|
| `BATCH_MAP_TO_SLICE(map, nodeProp, slice, idx)` | Batch map → slice |
| `BATCH_SLICE_MAP_TO_SLICE(map, src, dst, idx)` | Slice → map → slice |
| `BATCH_PERSIST_SLICE(slice, prop)` | Persist to storage |
| `BATCH_PERSIST_SLICES(s1, p1, s2, p2, ...)` | Multi-persist |
| `BATCH_SLICE_ADD(slice, value)` | Add constant |
| `BATCH_INSERT_NODES(label, data)` | Bulk insert nodes |
| `BATCH_INSERT_EDGES(type, data)` | Bulk insert edges |

### Type Conversion

| Function | Aliases |
|----------|---------|
| `TOSTRING(val)` | `TOSTR` |
| `TOINTEGER(val)` | `TOINT` |
| `TOFLOAT(val)` | `TODOUBLE` |

### Math

| Function | Aliases |
|----------|---------|
| `ABS(x)` | — |
| `CEIL(x)` | `CEILING` |
| `FLOOR(x)` | — |
| `ROUND(x)` | — |
| `SQRT(x)` | — |
| `POW(x, y)` | `POWER` |
| `MIN(a, b)` | — |
| `MAX(a, b)` | — |

### String

| Function | Aliases |
|----------|---------|
| `SUBSTRING(s, start, len)` | `SUBSTR` |
| `LENGTH(s)` | `LEN` |

### Utility

| Function | Description |
|----------|-------------|
| `COALESCE(a, b, ...)` | First non-NULL |
| `IF(cond, then, else)` | Inline conditional |
| `TIMESTAMP_MS()` | Current time (ms) |
| `DATE_DIFF(d1, d2)` | Date difference |
| `APPEND(list, item)` | Append to list |

## Operator Precedence

| Precedence | Operators |
|------------|-----------|
| 1 (highest) | `.`, `[]` |
| 2 | `^` |
| 3 | Unary `-`, `NOT` |
| 4 | `*`, `/`, `%` |
| 5 | `+`, `-` |
| 6 | `\|\|` |
| 7 | `=`, `<>`, `!=`, `<`, `>`, `<=`, `>=` |
| 8 | `IS NULL`, `IS NOT NULL`, `IN`, `NOT IN` |
| 9 | `AND` |
| 10 | `XOR` |
| 11 (lowest) | `OR` |

## Performance Tips

1. **Enable compute engine**: `ALTER COMPUTE ENABLE` — required for topology functions
2. **Use slice properties** instead of temp properties for parallel algorithms
3. **Use `.batch(N)`** with PARALLEL FOR for throughput (typically 1000-5000)
4. **Use fused neighbor ops** (`SUM_IN_NEIGHBOR_PROP`, etc.) instead of manual neighbor loops
5. **Use `BATCH_PERSIST_SLICES`** (plural) to persist multiple slices in one pass
6. **Use `COUNT_COMMON_NEIGHBORS`** instead of `SIZE(COMMON_NEIGHBORS(...))` when you only need the count
7. **Use `INTERSECT`/`UNION`/`DIFFERENCE`** instead of nested FOR loops for set operations
8. **Break early** from BFS/DFS when you've found what you need
9. **Use `LIST_TO_MAP`** for O(1) lookups instead of scanning lists
10. **Use `INIT_OUT_DEGREES`** instead of computing degrees in a loop
