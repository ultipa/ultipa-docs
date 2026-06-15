# Iterators and Graph Traversal

This page covers all iterator sources and the `FOR...IN MATCH` traversal system in stored procedure bodies.

## Iterators

### SCAN: Node Iterator

<p tit="Procedure Body Language"></p>

```gql
-- Iterate over nodes by label
FOR n IN SCAN(:Person) {
    PRINT n.name
}

-- With property filter
FOR n IN SCAN(:Person {active: true}) {
    PRINT n.name || ' is active'
}

-- Scan all nodes (no label filter)
FOR n IN SCAN() {
    PRINT n._id
}

-- With batching for better throughput
FOR n IN SCAN(:Person).batch(1000) {
    -- Nodes are fetched in batches of 1000
    n.processed = true
}
```

### EDGES: Edge Iterator

<p tit="Procedure Body Language"></p>

```gql
-- Iterate over all edges
FOR e IN EDGES() {
    PRINT e._from || ' -> ' || e._to
}

-- By edge label
FOR e IN EDGES(:KNOWS) {
    PRINT e._from || ' knows ' || e._to
}

-- With batching for better throughput
FOR e IN EDGES(:FOLLOWS).batch(1000) {
    -- process edges in batches
}
```

### NEIGHBORS: Neighbor Iterator

<p tit="Procedure Body Language"></p>

```gql
-- Get neighbors of a node in both directions (default)
FOR neighbor IN NEIGHBORS(node) {
    PRINT neighbor._id
}

-- Direction keyword: OUT
FOR neighbor IN NEIGHBORS(n, OUT) {
    PRINT neighbor._id
}

-- Direction keyword: IN
FOR neighbor IN NEIGHBORS(n, IN) {
    PRINT neighbor._id
}

-- Direction keyword: BOTH
FOR neighbor IN NEIGHBORS(n, BOTH) {
    PRINT neighbor._id
}

-- Filter by edge label
FOR neighbor IN NEIGHBORS(n, OUT, :KNOWS) {
    PRINT neighbor.name
}
```

### RANGE: Numeric Iterator

`RANGE(start, end)` or `RANGE(start, end, step)`. `start` is inclusive, `end` is exclusive, `step` defaults to `1`.

<p tit="Procedure Body Language"></p>

```gql
-- Print 0 to 9
FOR i IN RANGE(0, 10) {
    PRINT i
}

-- With an explicit step argument: 0, 2, 4, 6, 8
FOR i IN RANGE(0, 10, 2) {
    PRINT i
}
```

## Graph Traversal

The procedure body language supports powerful graph traversal with multiple algorithms through the `FOR...IN MATCH` syntax.

The path pattern after `MATCH` is standard GQL syntax — node patterns, edge patterns, label filters, inline property maps, inline `WHERE` filters on nodes and edges, hop-range quantifiers, and direction arrows all behave the same as in a top-level `MATCH`. See <a target="_blank" href="/docs/gql/node-and-edge-patterns">Node and Edge Patterns</a>, <a target="_blank" href="/docs/gql/path-patterns">Path Patterns</a>, and <a target="_blank" href="/docs/gql/quantified-paths">Quantified Paths</a> for the full pattern reference. This page covers only the procedure-specific aspects: variable binding, traversal-mode keywords, and how the loop body interacts with the traversal.

### Variable Binding

<p tit="Procedure Body Language"></p>

```gql
-- Single variable: binds the destination node
FOR n IN MATCH (start)-[:EDGE]->{1,5}(n) {
    PRINT n._id
}

-- Tuple variables: binds both node and depth
FOR (n, depth) IN MATCH (start)-[:EDGE]->{1,5}(n) {
    PRINT n._id || ' at depth ' || TOSTRING(depth)
}

-- Path variable: binds the full path (for shortest path modes)
FOR p IN MATCH SHORTEST (a)-[:ROAD]->{1,50}(b) {
    PRINT LENGTH(p)
    FOR n IN NODES(p) {
        PRINT n._id
    }
}
```

### Traversal Modes

| Mode | Description |
|--------|-------------|
| `MATCH` | DFS (default) |
| `MATCH BFS` | BFS |
| `MATCH KHOP` | K-hop neighbors (alias for BFS) |
| `MATCH SHORTEST` | Single shortest path |
| `MATCH SHORTEST k` | Top-k shortest paths |
| `MATCH ALL SHORTEST` | All shortest paths |

#### DFS Traversal (Default)

Depth-first exploration:

<p tit="Procedure Body Language"></p>

```gql
FOR (n, depth) IN MATCH (start)-[:KNOWS]->{1,5}(n) {
    RETURN n._id AS found, depth
}
```

DFS visits deeper paths first. Useful for exploring tree-like structures or when you want to find any path quickly.

#### BFS Traversal

Level-by-level exploration. Guarantees shortest hop count:

<p tit="Procedure Body Language"></p>

```gql
FOR (n, depth) IN MATCH BFS (start)-[:KNOWS]->{1,5}(n) {
    -- depth is guaranteed to be the shortest hop count
    RETURN n._id AS found, depth
}
```

BFS is preferred when:
- You need the shortest hop count
- You want to process nodes level by level
- You need early termination at a specific depth

#### KHOP (K-Hop Neighbors)

Alias for BFS. Find all nodes within k hops:

<p tit="Procedure Body Language"></p>

```gql
-- Friends of friends (exactly 2 hops)
FOR (fof, depth) IN MATCH KHOP (person)-[:KNOWS]-{2}(fof) {
    RETURN fof._id AS friend_of_friend
}

-- Within 3 hops
FOR (n, depth) IN MATCH KHOP (start)-[:CONNECTS]-{1,3}(n) {
    RETURN n._id, depth
}
```

#### Shortest Paths

The start and end nodes must be bound first, typically by `MATCH` on `_id`.

<p tit="Procedure Body Language"></p>

```gql
-- Single shortest path
FOR path IN MATCH SHORTEST (source)-[:ROAD]->{1,20}(target) {
    PRINT 'Length: ' || TOSTRING(LENGTH(path))
    FOR n IN NODES(path) {
        PRINT n._id
    }
}

-- K shortest paths
FOR p IN MATCH SHORTEST 5 (source)-[:ROAD]->{1,20}(target) {
    RETURN LENGTH(p) AS hops, NODES(p) AS nodes
}

-- All shortest paths
FOR p IN MATCH ALL SHORTEST (source)-[:ROAD]->{1,20}(target) {
    RETURN NODES(p) AS nodes, LENGTH(p) AS hops
}
```

### Combining Traversal with BREAK

Early termination during traversal:

<p tit="Procedure Body Language"></p>

```gql
FOR (n, depth) IN MATCH BFS (start)-[:EDGE]->{1,10}(n) {
    IF depth > 5 {
        BREAK  -- stop exploring beyond depth 5
    }
    IF n.target = true {
        RETURN n._id AS target_found, depth
        BREAK  -- found what we need
    }
}
```

### Practical Example: Influence Spread

```gql
CREATE PROCEDURE influence_spread(seed_id: STRING, max_hops: INT = 3)
RETURNS (node_id: STRING, hop: INTEGER, influence: FLOAT)
AS {
    MATCH (seed {_id: $seed_id})

    FOR (n, depth) IN MATCH BFS (seed)-[:FOLLOWS]->{1,$max_hops}(n) {
        -- Influence decays with distance
        LET influence = 1.0 / (depth * depth)
        RETURN n._id AS node_id, depth AS hop, influence
    }
}
```