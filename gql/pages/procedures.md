# Procedures

## Overview

Stored procedures allow you to encapsulate complex graph logic, control flow, and algorithms in reusable units. Procedures can be created, managed, and executed within the database.

## Procedures Management

### CREATE PROCEDURE

```gql
CREATE PROCEDURE name(param1: TYPE, param2: TYPE = default)
RETURNS (col1: TYPE, col2: TYPE)
AS {
    -- procedure body
}
```

**Example:**

```gql
CREATE PROCEDURE greet(name: STRING)
RETURNS (message: STRING)
AS {
    RETURN 'Hello, ' || $name AS message
}
```

### CREATE OR REPLACE

Overwrites existing procedure with the same name:

```gql
CREATE OR REPLACE PROCEDURE my_proc(x: INTEGER)
RETURNS (result: INTEGER)
AS {
    RETURN $x * 2 AS result
}
```

### DROP PROCEDURE

```gql
DROP PROCEDURE my_proc
DROP PROCEDURE IF EXISTS my_proc
```

### SHOW PROCEDURES

```gql
SHOW PROCEDURES
SHOW PROCEDURES LIKE 'find_%'
```

## CALL & YIELD

Execute procedures and capture their output:

```gql
CALL procedure_name(args)
YIELD column1, column2, ...
RETURN column1, column2
```

Procedures return tabular results. Use `YIELD` to specify which columns to capture, then process with `FILTER`, `RETURN`, etc.

**Examples:**

```gql
CALL greet('World') YIELD message
RETURN message
```

```gql
CALL algo.pagerank()
YIELD nodeId, score, rank
RETURN nodeId, score
ORDER BY score DESC
LIMIT 10
```

```gql
CALL algo.degree()
YIELD nodeId, degree, inDegree, outDegree
FILTER degree > 2
RETURN nodeId, degree
```

## Control Flow

### FOR Loop

```gql
FOR item IN collection {
    -- body
}
```

### PARALLEL FOR

Execute iterations in parallel for high performance:

```gql
PARALLEL FOR node IN SCAN(:Person) WORKERS 8 {
    node.processed = true
}
```

### IF / ELSE

```gql
IF condition {
    -- body
} ELSE IF other_condition {
    -- body
} ELSE {
    -- body
}
```

### WHILE Loop

```gql
WHILE condition {
    -- body
}
```

### TRY / CATCH

```gql
TRY {
    -- risky operation
} CATCH (e) {
    PRINT 'Error: ' || e.message
}
```

### ATOMIC Block

Execute statements as a single transaction:

```gql
ATOMIC {
    INSERT (:Account {id: 'a1', balance: 100})
    INSERT (:Account {id: 'a2', balance: 200})
}
```

**Example: Parallel processing**

```gql
CREATE PROCEDURE process_all()
RETURNS (processed: INTEGER)
AS {
    LET count = 0
    PARALLEL FOR node IN SCAN(:Person) WORKERS 8 {
        node.processed = true
        count = count + 1
    }
    RETURN count AS processed
}
```

**Example: Atomic transaction block**

```gql
CREATE PROCEDURE safe_transfer(from_id: STRING, to_id: STRING, amount: FLOAT)
RETURNS VOID
AS {
    ATOMIC {
        MATCH (from:Account {_id: $from_id})
        MATCH (to:Account {_id: $to_id})
        SET from.balance = from.balance - $amount
        SET to.balance = to.balance + $amount
    }
}
```

## Iterators

Built-in iterators for traversing graph elements.

### SCAN - Node Iterator

```gql
FOR node IN SCAN(:Label) { ... }
FOR node IN SCAN(:Label {prop: value}) { ... }
FOR node IN SCAN(:Label).batch(1000) { ... }
```

### EDGES - Edge Iterator

```gql
FOR edge IN EDGES() { ... }
FOR edge IN EDGES(:EdgeType) { ... }
```

### NEIGHBORS

```gql
FOR neighbor IN NEIGHBORS(node) { ... }           -- both directions
FOR neighbor IN NEIGHBORS(node, OUT) { ... }      -- outgoing only
FOR neighbor IN NEIGHBORS(node, IN) { ... }       -- incoming only
FOR neighbor IN NEIGHBORS(node, OUT, :KNOWS) { ... }  -- by edge type
```

### RANGE

```gql
FOR i IN RANGE(0, 10) { ... }  -- 0 to 9
```

**Example: Iterate nodes with SCAN**

```gql
CREATE PROCEDURE count_by_label(label: STRING)
RETURNS (total: INTEGER)
AS {
    LET count = 0
    FOR node IN SCAN(:$label) {
        count = count + 1
    }
    RETURN count AS total
}
```

**Example: Batch iteration for performance**

```gql
CREATE PROCEDURE batch_update()
RETURNS (updated: INTEGER)
AS {
    LET count = 0
    PARALLEL FOR node IN SCAN(:Person).batch(1000) WORKERS 4 {
        node.processed = true
        count = count + 1
    }
    RETURN count AS updated
}
```

## Graph Traversal

Procedures support powerful graph traversal patterns.

| Mode | Description |
| -- | -- |
| `MATCH` | Default DFS (depth-first search) |
| `MATCH BFS` | Breadth-first, level-by-level |
| `MATCH KHOP` | K-hop neighbors |
| `MATCH SHORTEST` | Find shortest path(s) |

### DFS Traversal (Default)

```gql
FOR (node, depth) IN MATCH (start)-[:EDGE]->{1,5}(node) {
    RETURN node._id, depth
}
```

### BFS Traversal

```gql
FOR (node, depth) IN MATCH BFS (start)-[:KNOWS]->{1,5}(node) {
    -- depth is guaranteed shortest hop count
}
```

### KHOP (K-Hop Neighbors)

```gql
FOR (fof, depth) IN MATCH KHOP (person)-[:KNOWS]-{2}(fof) {
    RETURN fof._id  -- friends of friends
}
```

### Shortest Path

```gql
LET path = MATCH SHORTEST (source)-[:ROAD]->{1,20}(target)
FOR path IN MATCH SHORTEST 5 (source)-[:ROAD]->{}(target) { ... }
```

**Example: BFS traversal to find friends**

```gql
CREATE PROCEDURE find_friends(person_id: STRING, max_depth: INT)
RETURNS (friend_id: STRING, depth: INT)
AS {
    MATCH (p {_id: $person_id})
    FOR (friend, depth) IN MATCH BFS (p)-[:KNOWS]->{1,$max_depth}(friend) {
        RETURN friend._id AS friend_id, depth
    }
}
```

**Example: K-hop query for friends of friends**

```gql
CREATE PROCEDURE friends_of_friends(person_id: STRING)
RETURNS (fof_id: STRING)
AS {
    MATCH (p {_id: $person_id})
    FOR (fof, depth) IN MATCH KHOP (p)-[:KNOWS]-{2}(fof) {
        IF fof._id != $person_id {
            RETURN fof._id AS fof_id
        }
    }
}
```

## Built-in Functions

Procedures have access to high-performance built-in functions.

### Topology Functions

| Function | Description |
| -- | -- |
| `OUT_DEGREE(node)` | O(1) out-degree lookup |
| `IN_DEGREE(node)` | O(1) in-degree lookup |
| `NODE_COUNT()` | Total nodes in graph |

### Slice Property Functions

High-performance per-node value storage for algorithms:

| Function | Description |
| -- | -- |
| `INIT_SLICE_PROP(name, value)` | Initialize all nodes with a value |
| `GET_SLICE_PROP(idx, name)` | Get value by internal node ID |
| `SET_SLICE_PROP(idx, name, value)` | Set value by internal node ID |

### Parallel Reduction Functions

| Function | Description |
| -- | -- |
| `SUM_SLICE_PROP(propName)` | Parallel sum of all values |
| `MAX_SLICE_PROP(propName)` | Parallel maximum |
| `MIN_SLICE_PROP(propName)` | Parallel minimum |

### Set Operations

| Function | Description |
| -- | -- |
| `INTERSECT(a, b)` | A ∩ B |
| `UNION(a, b)` | A ∪ B |
| `DIFFERENCE(a, b)` | A - B |
| `COMMON_NEIGHBORS(a, b)` | Common neighbors list |
| `COUNT_COMMON_NEIGHBORS(a, b)` | Count only (efficient) |
| `JACCARD_SIMILARITY(a, b)` | Jaccard index |

## Inline CALL Subqueries

Use `CALL { ... }` to execute a subquery inline:

```gql
CALL {
  MATCH (n:Label)
  RETURN n.prop
}
```

Use `OPTIONAL CALL` when the subquery may return no results.

**Examples:**

```gql
CALL {
  MATCH (p:Person)
  WHERE p.age > 30
  RETURN p.name AS name, p.age AS age
  ORDER BY p.age DESC
  LIMIT 5
}
```

```gql
OPTIONAL CALL {
  MATCH (n:RareLabel)
  RETURN n.name AS name
}
```

## Type Reference

### Parameter Types

| Type | Description |
| -- | -- |
| `STRING` | Text value |
| `INTEGER` | Whole number |
| `FLOAT` | Decimal number |
| `BOOLEAN` | true/false |
| `LIST<T>` | List of type T |
| `NODE` | Graph node |
| `EDGE` | Graph edge |

### Return Types

| Type | Description |
| -- | -- |
| `VOID` | No return value |
| Column specs | `(col1: TYPE, col2: TYPE)` |

**Example: Procedure with typed parameters**

```gql
CREATE PROCEDURE typed_example(
    name: STRING,
    age: INTEGER,
    score: FLOAT = 0.0,
    active: BOOLEAN = true
)
RETURNS (result: STRING, computed: FLOAT)
AS {
    LET computed = $age * $score
    RETURN $name || ' processed' AS result, computed
}
```

**Example: VOID return type**

```gql
CREATE PROCEDURE return_void(message: STRING)
RETURNS VOID
AS {
    PRINT $message
    -- No RETURN statement needed
}
```
