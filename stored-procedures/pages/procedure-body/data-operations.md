# Data Operations

This page covers variable assignment, data manipulation, and output operations within stored procedures.

## LET

Declare and assign variables:

<p tit="Procedure Body Language"></p>

```gql
LET count = 0
LET name = 'Alice'
LET threshold = 0.85
LET active = true
LET nodes = []
LET data = {key: 'value', count: 42}
```

Reassign existing variables:

<p tit="Procedure Body Language"></p>

```gql
LET count = 0
FOR n IN SCAN(:Person) {
    LET count = count + 1  -- LET is required here too
}
PRINT 'Total: ' || TOSTRING(count)
```

Assign the result of a subquery to a variable:

<p tit="Procedure Body Language"></p>

```gql
LET friends = (MATCH (p {_id: 'alice'})-[:KNOWS]->(f) RETURN f)
```

## Temp Property (In-Memory Only)

Assign properties to nodes that exist only during procedure execution. These are NOT persisted to storage.

Use cases:
- Marking visited nodes during traversal.
- Storing intermediate computation results.
- Attaching temporary metadata.

<p tit="Procedure Body Language"></p>

```gql
FOR n IN SCAN(:Person) {
    n.processed = false
}

FOR (node, depth) IN MATCH BFS (start)-[:KNOWS]->{1,5}(node) {
    n.distance = depth
    n.processed = true
}
```

## MATCH

Query the graph within a procedure:

<p tit="Procedure Body Language"></p>

```gql
-- Find a specific node
MATCH (p:Person {_id: $person_id})

-- Pattern matching
MATCH (a:Person)-[:KNOWS]->(b:Person)

-- With inline WHERE
MATCH (n:Person WHERE n.age > 30)

-- With standalone WHERE
MATCH (a)-[:KNOWS]->(b)
WHERE a.city = b.city
```

Results from `MATCH` bind variables for subsequent statements:

<p tit="Procedure Body Language"></p>

```gql
MATCH (p {_id: $person_id})
LET degree = OUT_DEGREE(p)
PRINT 'Node ' || p._id || ' has degree ' || TOSTRING(degree)
```

## INSERT

Create nodes and edges:

<p tit="Procedure Body Language"></p>

```gql
-- Insert a node
INSERT (:Person {_id: 'bob', name: 'Bob', age: 30})

-- Insert an edge between matched nodes
MATCH (a {_id: 'alice'})
MATCH (b {_id: 'bob'})
INSERT (a)-[:KNOWS {since: 2024}]->(b)
```

## SET

Modify properties that are persisted to storage:

<p tit="Procedure Body Language"></p>

```gql
MATCH (n {_id: $node_id})
SET n.name = 'Updated Name'
SET n.score = 0.95
```

## DELETE

Remove nodes and edges:

<p tit="Procedure Body Language"></p>

```gql
-- Delete a node (must have no edges)
MATCH (n {_id: $node_id})
DELETE n

-- Delete a node and all connected edges
MATCH (n {_id: $node_id})
DETACH DELETE n
```

## RETURN

Return results from the procedure. Each `RETURN` statement adds a row to the output.

### Multiple Columns

<p tit="Procedure Body Language"></p>

```gql
RETURN name, age, score
```

### Named Columns

<p tit="Procedure Body Language"></p>

```gql
RETURN n._id AS node_id, score AS rank_score
```

### Streaming Returns (Inside Loops)

Each iteration's `RETURN` adds a row:

```gql
CREATE PROCEDURE list_people()
RETURNS (name: STRING, age: INTEGER)
AS {
    FOR n IN SCAN(:Person) {
        RETURN n.name AS name, n.age AS age
        -- Each iteration adds one row
    }
}
```

### Early Return

A bare `RETURN` (without values) exits the procedure immediately, skipping any remaining statements. This works in both VOID and non-VOID procedures:

```gql
CREATE PROCEDURE safe_delete(node_id: STRING)
RETURNS VOID
AS {
    MATCH (n {_id: $node_id})
    IF IN_DEGREE(n) + OUT_DEGREE(n) > 0 {
        RETURN  -- Exit early, node has connections
    }
    DELETE n
}
```

## PRINT

Write a diagnostic message to the **GQLDB server's log** (its standard error stream). `PRINT` output is **not** returned to the caller — drivers and CLI clients receive only the rows produced by `RETURN`. To see `PRINT` output, look at the server's terminal, log file, or `journalctl` / `docker logs` depending on how the server was started.

<p tit="Procedure Body Language"></p>

```gql
PRINT 'Starting computation...'
PRINT 'Count: ' || TOSTRING(count)
PRINT 'Node ' || n._id || ' score = ' || TOSTRING(score)
```

`PRINT` is useful for:
- Debugging procedure logic.
- Progress reporting in long-running procedures.
- Logging iteration counts in convergence loops.

If you need the procedure to return a message to the caller, use `RETURN msg AS something`, not `PRINT`.

## FLUSH

Force commit buffered writes to storage:

<p tit="Procedure Body Language"></p>

```gql
-- After inserting many nodes
FOR i IN RANGE(0, 10000) {
    INSERT (:DataPoint {_id: 'dp_' || TOSTRING(i), value: i})
    IF i % 1000 = 0 {
        FLUSH  -- commit every 1000 inserts
    }
}
FLUSH  -- final flush
```

`FLUSH` is important when:
- Inserting large amounts of data in a loop.
- You need subsequent reads to see earlier writes.
- Preventing excessive memory usage from buffered writes.

## Batch Insert

High-throughput batch insertion for loading data from procedures:

### BATCH_INSERT_NODES

Takes a single argument — a list of MAP values. Each map carries its own labels and properties:

- `labels: LIST<STRING>` — the label set for this node
- `_id: STRING` — optional; auto-generated if omitted
- Any other keys become properties

<p tit="Procedure Body Language"></p>

```gql
LET node_data = [
    {labels: ['Person'], _id: 'n1', name: 'Alice', age: 30},
    {labels: ['Person'], _id: 'n2', name: 'Bob', age: 25}
]
BATCH_INSERT_NODES(node_data)
```

Returns the number of nodes created as an `INTEGER`.

### BATCH_INSERT_EDGES

Takes a single argument — a list of MAP values. Each map describes one edge:

- `label: STRING` — the edge label
- `_from: STRING` — source node `_id`
- `_to: STRING` — target node `_id`
- Any other keys (apart from `label`, `_from`, `_to`) become properties

<p tit="Procedure Body Language"></p>

```gql
LET edge_data = [
    {label: 'KNOWS', _from: 'n1', _to: 'n2', weight: 0.8},
    {label: 'KNOWS', _from: 'n2', _to: 'n1', weight: 0.6}
]
BATCH_INSERT_EDGES(edge_data)
```

Returns the number of edges created as an `INTEGER`.

These batch operations are significantly faster than individual `INSERT` statements for large datasets.
