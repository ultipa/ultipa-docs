# Control Flow

This page covers all control flow statements available in stored procedures.

## IF / ELSE IF / ELSE

Conditional branching:

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

```gql
FOR item IN [1, 2, 3, 4, 5] {
    PRINT item
}
```

### Over a RANGE

```gql
FOR i IN RANGE(0, 10) {
    PRINT i  -- prints 0 to 9
}

FOR i IN RANGE(1, 100) {
    -- process items 1 to 99
}
```

### Over Nodes (SCAN)

```gql
FOR node IN SCAN(:Person) {
    PRINT node.name
}
```

### Over Edges (EDGES)

```gql
FOR edge IN EDGES(:KNOWS) {
    PRINT edge._from || ' -> ' || edge._to
}
```

### Over Neighbors

```gql
FOR neighbor IN NEIGHBORS(node, OUT, :KNOWS) {
    PRINT neighbor.name
}
```

See <a href="/docs/stored-procedures/iterators-and-traversal">Iterators and Traversal</a> for full details on iterator sources.

## PARALLEL FOR

Executes loop iterations across multiple worker goroutines:

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

```gql
LET i = 0
WHILE i < 10 {
    PRINT i
    i = i + 1
}
```

Common pattern — iterate until convergence:

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

```gql
FOR i IN RANGE(1, 1000) {
    IF i > 50 {
        BREAK
    }
    PRINT i
}
```

Works with FOR, PARALLEL FOR, WHILE, and FOR...IN MATCH:

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

```gql
FOR i IN RANGE(1, 100) {
    IF i % 2 = 0 {
        CONTINUE  -- skip even numbers
    }
    PRINT i  -- only prints odd numbers
}
```

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

Error handling with optional error variable:

### Basic TRY/CATCH

```gql
TRY {
    LET result = risky_operation()
    PRINT result
} CATCH {
    PRINT 'Operation failed'
}
```

### With Error Variable

```gql
TRY {
    MATCH (n {_id: 'nonexistent'})
    PRINT n.name
} CATCH (e) {
    PRINT 'Error: ' || e.message
}
```

### Re-throwing Errors

```gql
TRY {
    dangerous_action()
} CATCH (e) {
    PRINT 'Logging error: ' || e.message
    THROW  -- re-throw the original error
}
```

## THROW

Raise an error explicitly:

```gql
IF $iterations < 1 {
    THROW 'Iterations must be at least 1'
}

IF node IS NULL {
    THROW 'Node not found: ' || $node_id
}
```

Re-throw inside a CATCH block (no argument):

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

```gql
ATOMIC {
    INSERT (:Account {_id: 'a1', balance: 100})
    INSERT (:Account {_id: 'a2', balance: 200})
    INSERT (a1)-[:TRANSFER {amount: 50}]->(a2)
}
```

Use cases:
- Multi-statement data mutations that must succeed or fail together
- Ensuring consistency when creating related nodes and edges
- Bank transfers, inventory updates, and other transactional operations

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
