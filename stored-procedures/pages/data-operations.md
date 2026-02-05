# Data Operations

This page covers variable assignment, data manipulation, and output operations within stored procedures.

## LET — Variable Assignment

Declare and assign variables:

```gql
LET count = 0
LET name = 'Alice'
LET threshold = 0.85
LET active = true
LET nodes = []
LET data = {key: 'value', count: 42}
```

Reassign existing variables:

```gql
LET count = 0
FOR node IN SCAN(:Person) {
    count = count + 1  -- reassignment (without LET)
}
PRINT 'Total: ' || TOSTRING(count)
```

### Subquery Assignment

Assign the result of a subquery to a variable:

```gql
LET friends = (MATCH (p {_id: 'alice'})-[:KNOWS]->(f) RETURN f)
```

## Temp Property — In-Memory Only

Assign properties to nodes that exist only during procedure execution. These are NOT persisted to storage:

```gql
node.visited = true
node.tempScore = 0.5
node.level = depth
```

Use cases:
- Marking visited nodes during traversal
- Storing intermediate computation results
- Attaching temporary metadata

```gql
FOR node IN SCAN(:Person) {
    node.processed = false
}

FOR (node, depth) IN MATCH BFS (start)-[:KNOWS]->{1,5}(node) {
    node.distance = depth
    node.processed = true
}
```

## MATCH

Query the graph within a procedure:

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

Results from MATCH bind variables for subsequent statements:

```gql
MATCH (p {_id: $person_id})
LET degree = OUT_DEGREE(p)
PRINT 'Node ' || p._id || ' has degree ' || TOSTRING(degree)
```

## INSERT

Create nodes and edges:

```gql
-- Insert a node
INSERT (:Person {_id: 'bob', name: 'Bob', age: 30})

-- Insert an edge between matched nodes
MATCH (a {_id: 'alice'})
MATCH (b {_id: 'bob'})
INSERT (a)-[:KNOWS {since: 2024}]->(b)
```

## SET — Persistent Property Update

Modify properties that are persisted to storage:

```gql
MATCH (n {_id: $node_id})
SET n.name = 'Updated Name'
SET n.score = 0.95
```

## DELETE

Remove nodes and edges:

```gql
-- Delete a node (must have no edges)
MATCH (n {_id: $node_id})
DELETE n

-- Delete a node and all connected edges
MATCH (n {_id: $node_id})
DETACH DELETE n
```

## RETURN

Return results from the procedure. Each RETURN statement adds a row to the output:

### Named Columns

```gql
RETURN node._id AS node_id, score AS rank_score
```

### Multiple Columns

```gql
RETURN name, age, score
```

### Streaming Returns (Inside Loops)

Each iteration's RETURN adds a row:

```gql
CREATE PROCEDURE list_people()
RETURNS (name: STRING, age: INTEGER)
AS {
    FOR node IN SCAN(:Person) {
        RETURN node.name AS name, node.age AS age
        -- Each iteration adds one row
    }
}
```

### Empty Return (VOID Procedures)

```gql
CREATE PROCEDURE init_data()
RETURNS VOID
AS {
    -- do work...
    RETURN  -- explicit early exit (optional)
}
```

## PRINT

Output debug messages to stderr:

```gql
PRINT 'Starting computation...'
PRINT 'Count: ' || TOSTRING(count)
PRINT 'Node ' || node._id || ' score = ' || TOSTRING(score)
```

PRINT is useful for:
- Debugging procedure logic
- Progress reporting in long-running procedures
- Logging iteration counts in convergence loops

## FLUSH

Force commit buffered writes to storage:

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

FLUSH is important when:
- Inserting large amounts of data in a loop
- You need subsequent reads to see earlier writes
- Preventing excessive memory usage from buffered writes

## BATCH_INSERT_NODES / BATCH_INSERT_EDGES

High-throughput batch insertion for loading data from procedures:

### BATCH_INSERT_NODES

```gql
-- Insert nodes from a list of data
-- Arguments: label, list of property maps
LET node_data = [
    {_id: 'n1', name: 'Alice', age: 30},
    {_id: 'n2', name: 'Bob', age: 25}
]
BATCH_INSERT_NODES('Person', node_data)
```

### BATCH_INSERT_EDGES

```gql
-- Insert edges from a list
-- Arguments: edge type, list of edge specs
LET edge_data = [
    {_from: 'n1', _to: 'n2', weight: 0.8},
    {_from: 'n2', _to: 'n1', weight: 0.6}
]
BATCH_INSERT_EDGES('KNOWS', edge_data)
```

These batch operations are significantly faster than individual INSERT statements for large datasets.
