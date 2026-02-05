# Quick Start

Ultipa GQLDB supports stored procedures for encapsulating complex graph logic, enabling reusable queries, and implementing high-performance graph algorithms.

## 1. Create a Procedure

```gql
CREATE PROCEDURE greet(name: STRING)
RETURNS (message: STRING)
AS {
    RETURN 'Hello, ' || $name AS message
}
```

## 2. Call It

```gql
CALL greet('World') YIELD message
-- Returns: "Hello, World"
```

## 3. Drop It

```gql
DROP PROCEDURE greet
```

## Requirements

Stored procedures require the compute engine to be enabled for topology-accelerated functions:

```gql
ALTER COMPUTE ENABLE
```

This enables O(1) degree lookups, CSR/CSC neighbor access, and slice property operations. Without the compute engine, basic control flow and data operations still work, but topology functions (OUT_DEGREE, IN_DEGREE, etc.) and slice properties will return default values.