# Quick Start

Ultipa GQLDB supports stored procedures for encapsulating complex graph logic, enabling reusable queries, and implementing high-performance graph algorithms.

## 1. Create a Procedure

```gql
CREATE PROCEDURE greet(name: STRING)
RETURNS (message: STRING)
AS {
    RETURN 'Hello ' || $name AS message
}
```

## 2. Call It

```gql
CALL greet('World') YIELD message
-- Returns: "Hello World"
```

## 3. Drop It

```gql
DROP PROCEDURE greet
```

## About Stored Procedures

Stored procedures in Ultipa GQLDB are an extension to the GQL standard (ISO/IEC 39075). The GQL standard does not yet define syntax for creating or dropping stored procedures - `CREATE PROCEDURE`, `DROP PROCEDURE`, `SHOW PROCEDURES`, and the procedure body language are all Ultipa-specific extensions.

The procedure body (`AS { ... }`) is written in a procedural language that builds on GQL syntax. It supports GQL statements like `MATCH`, `INSERT`, `SET`, `DELETE`, `RETURN`, and all standard GQL functions. On top of that, it adds:

- Control flow: `IF` / `ELSE IF` / `ELSE`, `FOR`, `WHILE`, `BREAK`, `CONTINUE`
- Error handling: `TRY` / `CATCH` / `THROW`
- Parallel execution: `PARALLEL FOR` with `WORKERS`
- Variables: `LET` for declaration and assignment
- Debugging: `PRINT` for output to stderr
- Temporary node properties (in-memory only, not persisted)
- High-performance data structures: slice properties, neighbor aggregation functions, topology functions

## Compute Engine (Optional)

Stored procedures work without the compute engine. Control flow (`IF`, `FOR`, `WHILE`, `TRY/CATCH`), data operations (`LET`, `MATCH`, `INSERT`, `SET`, `DELETE`), standard GQL functions, set/map operations, and type conversions are all available by default.

For graph algorithm workloads, enable the compute engine per graph:

```gql
ALTER GRAPH <graph_name> SET COMPUTE ENABLED
```

This is required for:
- **Topology functions**: `OUT_DEGREE`, `IN_DEGREE`, `NODE_COUNT`
- **Fused neighbor operations**: `SUM_OUT_NEIGHBOR_PROP`, `IN_NEIGHBOR_SUM`, `MIN_BOTH_NEIGHBOR_PROP`, etc.
- **Slice properties**: `INIT_SLICE_PROP`, `GET_SLICE_PROP`, `SET_SLICE_PROP`, `PARALLEL FOR` with `SCAN()`
- **Parallel reductions**: `SUM_SLICE_PROP`, `MAX_SLICE_PROP`, etc.
- **Common neighbor functions**: `COMMON_NEIGHBORS`, `JACCARD_SIMILARITY`, `ADAMIC_ADAR`
- **Batch operations**: `BATCH_MAP_TO_SLICE`, `BATCH_PERSIST_SLICE`, etc.

Without the compute engine, these functions return 0 or default values.