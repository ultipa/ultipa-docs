# Control Flow

This page covers all control flow statements available in stored procedure bodies.

## IF / ELSE IF / ELSE

Conditional branching:

<p tit="Procedure Body Language"></p>

```gql
IF age > 18 {
    PRINT 'Adult'
} ELSE IF age > 12 {
    PRINT 'Teenager'
} ELSE {
    PRINT 'Child'
}
```

Conditions can use any expression that evaluates to a boolean:

<p tit="Procedure Body Language"></p>

```gql
IF node.active = true AND OUT_DEGREE(node) > 5 {
    PRINT 'Active high-degree node'
}

IF score IS NOT NULL {
    RETURN score
}

IF SIZE(friends) > 0 {
    -- process friends
}
```

## FOR Loop

### Over a List

<p tit="Procedure Body Language"></p>

```gql
FOR item IN [1, 2, 3, 4, 5] {
    PRINT item
}
```

### Over a RANGE

<p tit="Procedure Body Language"></p>

```gql
FOR i IN RANGE(0, 10) {
    PRINT i  -- prints 0 to 9
}

FOR i IN RANGE(1, 100) {
    -- process items 1 to 99
}
```

### Over Nodes (SCAN)

<p tit="Procedure Body Language"></p>

```gql
FOR node IN SCAN(:Person) {
    PRINT node.name
}
```

### Over Edges (EDGES)

<p tit="Procedure Body Language"></p>

```gql
FOR edge IN EDGES(:KNOWS) {
    PRINT edge._from || ' -> ' || edge._to
}
```

### Over Neighbors

<p tit="Procedure Body Language"></p>

```gql
FOR neighbor IN NEIGHBORS(node, OUT, :KNOWS) {
    PRINT neighbor.name
}
```

See <a href="/docs/stored-procedures/iterators-and-traversal">Iterators and Traversal</a> for full details on iterator sources.

## PARALLEL FOR

Executes loop iterations across multiple worker goroutines:

<p tit="Procedure Body Language"></p>

```gql
-- Auto-detect worker count
PARALLEL FOR node IN SCAN(:Person) {
    node.processed = true
}

-- Explicit worker count
PARALLEL FOR node IN SCAN(:Person) WORKERS 8 {
    LET score = OUT_DEGREE(node) * 0.1
    node.score = score
}
```

See <a href="/docs/stored-procedures/parallel-execution">Parallel Execution</a> for complete parallel execution guide.

## WHILE Loop

<p tit="Procedure Body Language"></p>

```gql
LET i = 0
WHILE i < 10 {
    PRINT i
    i = i + 1
}
```

Iterates until convergence:

<p tit="Procedure Body Language"></p>

```gql
LET changed = 1
LET iteration = 0
WHILE changed > 0 {
    LET changed = 0

    PARALLEL FOR node IN SCAN() WORKERS 8 {
        LET current = GET_SLICE_PROP(node._internal_id, 'rank')
        LET new_val = compute_new_rank(node)
        IF new_val <> current {
            SET_SLICE_PROP(node._internal_id, 'rank', new_val)
            LET changed = changed + 1
        }
    }

    LET iteration = iteration + 1
    PRINT 'Iteration ' || TOSTRING(iteration) || ': ' || TOSTRING(changed) || ' changed'
}
```

## BREAK

Exit the innermost loop immediately:

<p tit="Procedure Body Language"></p>

```gql
FOR i IN RANGE(1, 1000) {
    IF i > 50 {
        BREAK
    }
    PRINT i
}
```

Works with `FOR`, `PARALLEL FOR`, `WHILE`, and `FOR...IN MATCH`:

<p tit="Procedure Body Language"></p>

```gql
FOR (node, depth) IN MATCH BFS (start)-[:KNOWS]->{1,10}(node) {
    IF depth > 5 {
        BREAK  -- stop traversal early
    }
    RETURN node._id, depth
}
```

## CONTINUE

Skip the rest of the current iteration and move to the next:

<p tit="Procedure Body Language"></p>

```gql
FOR i IN RANGE(1, 100) {
    IF i % 2 = 0 {
        CONTINUE  -- skip even numbers
    }
    PRINT i  -- only prints odd numbers
}
```

<p tit="Procedure Body Language"></p>

```gql
FOR node IN SCAN(:Person) {
    IF node.active = false {
        CONTINUE  -- skip inactive nodes
    }
    -- process only active nodes
    RETURN node._id AS person_id
}
```

## TRY / CATCH

Catches runtime errors and prevents them from terminating the procedure. If any statement in the `TRY` block fails, execution jumps to the `CATCH` block. If no error occurs, the `CATCH` block is skipped.

### Basic TRY/CATCH

<p tit="Procedure Body Language"></p>

```gql
TRY {
    LET result = risky_operation()
    PRINT result
} CATCH {
    PRINT 'Operation failed'
}
```

### With Error Variable

Use `CATCH (e)` to capture the error. The error variable has two properties:

| Property | Description |
|----------|-------------|
| `e.message` | Error message string |
| `e.code` | Error code (e.g., `EXECUTION_ERROR`, `USER_ERROR`) |

<p tit="Procedure Body Language"></p>

```gql
TRY {
    LET val = 1 / 0
} CATCH (e) {
    PRINT 'Error: ' || e.message
    PRINT 'Code: ' || e.code
}
```

### Execution Flow

When an error occurs in the `TRY` block:
1. Remaining `TRY` statements are skipped
2. The error is captured in the error variable (if provided)
3. The `CATCH` block executes
4. Execution continues normally after the `TRY/CATCH` block

<p tit="Procedure Body Language"></p>

```gql
TRY {
    PRINT 'Step 1'       -- runs
    LET x = bad_call()   -- error here
    PRINT 'Step 2'       -- skipped
} CATCH (e) {
    PRINT 'Caught: ' || e.message  -- runs
}
PRINT 'Continues'        -- runs
```

### Re-throwing Errors

Use bare `THROW` inside a `CATCH` block to re-throw the caught error. This is useful for logging or cleanup before propagating the error:

<p tit="Procedure Body Language"></p>

```gql
TRY {
    dangerous_action()
} CATCH (e) {
    PRINT 'Logging error: ' || e.message
    THROW  -- re-throw the original error
}
```

### Nested TRY/CATCH

`TRY/CATCH` blocks can be nested. Each block handles its own errors independently:

<p tit="Procedure Body Language"></p>

```gql
TRY {
    TRY {
        LET x = risky_step_1()
    } CATCH (e1) {
        PRINT 'Step 1 failed: ' || e1.message
    }
    -- continues even if step 1 failed
    LET y = risky_step_2()
} CATCH (e2) {
    PRINT 'Step 2 failed: ' || e2.message
}
```

## THROW

Raise an error explicitly:

<p tit="Procedure Body Language"></p>

```gql
IF $iterations < 1 {
    THROW 'Iterations must be at least 1'
}

IF node IS NULL {
    THROW 'Node not found: ' || $node_id
}
```

Re-throw inside a CATCH block (no argument):

<p tit="Procedure Body Language"></p>

```gql
TRY {
    process()
} CATCH (e) {
    -- cleanup...
    THROW  -- re-throw original error
}
```

## ATOMIC Block

All statements inside execute as a single transaction. If any statement fails, all changes are rolled back:

<p tit="Procedure Body Language"></p>

```gql
ATOMIC {
    INSERT (:Account {_id: 'a1', balance: 100})
    INSERT (:Account {_id: 'a2', balance: 200})
    INSERT (a1)-[:TRANSFER {amount: 50}]->(a2)
}
```

Use cases:
- Multi-statement data mutations that must succeed or fail together.
- Ensuring consistency when creating related nodes and edges.
- Bank transfers, inventory updates, and other transactional operations.

<p tit="Procedure Body Language"></p>

```gql
ATOMIC {
    MATCH (from:Account {_id: $from_id})
    MATCH (to:Account {_id: $to_id})
    SET from.balance = from.balance - $amount
    SET to.balance = to.balance + $amount
    INSERT (from)-[:TRANSFER {amount: $amount, timestamp: TIMESTAMP_MS()}]->(to)
}
```

## Nesting

Control flow statements can be nested arbitrarily:

<p tit="Procedure Body Language"></p>

```gql
FOR node IN SCAN(:Person) {
    IF OUT_DEGREE(node) > 10 {
        FOR neighbor IN NEIGHBORS(node, OUT, :KNOWS) {
            IF neighbor.active = true {
                TRY {
                    LET score = JACCARD_SIMILARITY(node, neighbor)
                    IF score > 0.5 {
                        RETURN node._id AS source, neighbor._id AS target, score
                    }
                } CATCH {
                    CONTINUE
                }
            }
        }
    }
}
```
