# Iterators and Graph Traversal

This page covers all iterator sources and the FOR...IN MATCH traversal system.

## Iterators

### SCAN - Node Iterator

Iterate over nodes by label:

<p tit="Procedure Body Language"></p>

```gql
FOR node IN SCAN(:Person) {
    PRINT node.name
}
```

With property filter:

<p tit="Procedure Body Language"></p>

```gql
FOR node IN SCAN(:Person {active: true}) {
    PRINT node.name || ' is active'
}
```

Scan all nodes (no label filter):

<p tit="Procedure Body Language"></p>

```gql
FOR node IN SCAN() {
    PRINT node._id
}
```

With batching for better throughput:

<p tit="Procedure Body Language"></p>

```gql
FOR node IN SCAN(:Person).batch(1000) {
    -- Nodes are fetched in batches of 1000
    node.processed = true
}
```

### EDGES - Edge Iterator

Iterate over all edges:

<p tit="Procedure Body Language"></p>

```gql
FOR edge IN EDGES() {
    PRINT edge._from || ' -> ' || edge._to
}
```

By edge label:

<p tit="Procedure Body Language"></p>

```gql
FOR edge IN EDGES(:KNOWS) {
    PRINT edge._from || ' knows ' || edge._to
}
```

With batching:

<p tit="Procedure Body Language"></p>

```gql
FOR edge IN EDGES(:FOLLOWS).batch(1000) {
    -- process edges in batches
}
```

### NEIGHBORS - Neighbor Iterator

Get neighbors of a node:

<p tit="Procedure Body Language"></p>

```gql
-- Both directions (default)
FOR neighbor IN NEIGHBORS(node) {
    PRINT neighbor._id
}

-- Outgoing only
FOR neighbor IN NEIGHBORS(node, OUT) {
    PRINT neighbor._id
}

-- Incoming only
FOR neighbor IN NEIGHBORS(node, IN) {
    PRINT neighbor._id
}

-- Filter by edge label
FOR neighbor IN NEIGHBORS(node, OUT, :KNOWS) {
    PRINT neighbor.name
}
```

Direction options: `OUT`, `IN`, `BOTH`

### RANGE - Numeric Iterator

Generate a sequence of numbers:

<p tit="Procedure Body Language"></p>

```gql
FOR i IN RANGE(0, 10) {
    PRINT i  -- prints 0 to 9
}

FOR i IN RANGE(1, 100) {
    -- iterate 1 to 99
}
```

`RANGE(start, end)` generates values from `start` (inclusive) to `end` (exclusive).

## FOR...IN MATCH - Graph Traversal

The procedure language supports powerful graph traversal with multiple algorithms through the `FOR...IN MATCH` syntax.

### Variable Binding

**Single variable** - binds the destination node:

<p tit="Procedure Body Language"></p>

```gql
FOR node IN MATCH (start)-[:EDGE]->{1,5}(node) {
    PRINT node._id
}
```

**Tuple** - binds both node and depth:

<p tit="Procedure Body Language"></p>

```gql
FOR (node, depth) IN MATCH (start)-[:EDGE]->{1,5}(node) {
    PRINT node._id || ' at depth ' || TOSTRING(depth)
}
```

**Path variable** - binds the full path (for shortest path modes):

<p tit="Procedure Body Language"></p>

```gql
FOR path IN MATCH SHORTEST (a)-[:ROAD]->{1,50}(b) {
    PRINT path.length
    FOR node IN path.nodes {
        PRINT node._id
    }
}
```

### Traversal Modes

| Mode | Syntax | Description |
|------|--------|-------------|
| DFS | `MATCH` | Depth-first search (default) |
| BFS | `MATCH BFS` | Breadth-first, level-by-level |
| KHOP | `MATCH KHOP` | K-hop neighbors (alias for BFS) |
| Shortest | `MATCH SHORTEST` | Single shortest path |
| K Shortest | `MATCH SHORTEST k` | Top-k shortest paths |
| All Shortest | `MATCH ALL SHORTEST` | All shortest paths |

#### DFS Traversal (Default)

Depth-first exploration:

<p tit="Procedure Body Language"></p>

```gql
FOR (node, depth) IN MATCH (start)-[:KNOWS]->{1,5}(node) {
    RETURN node._id AS found, depth
}
```

DFS visits deeper paths first. Useful for exploring tree-like structures or when you want to find any path quickly.

#### BFS Traversal

Level-by-level exploration. Guarantees shortest hop count:

<p tit="Procedure Body Language"></p>

```gql
FOR (node, depth) IN MATCH BFS (start)-[:KNOWS]->{1,5}(node) {
    -- depth is guaranteed to be the shortest hop count
    RETURN node._id AS found, depth
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
FOR (node, depth) IN MATCH KHOP (start)-[:CONNECTS]-{1,3}(node) {
    RETURN node._id, depth
}
```

#### Shortest Path

**Single shortest path:**

<p tit="Procedure Body Language"></p>

```gql
LET path = MATCH SHORTEST (source)-[:ROAD]->{1,20}(target)

IF path IS NOT NULL {
    PRINT 'Length: ' || TOSTRING(path.length)
    FOR node IN path.nodes {
        PRINT node._id
    }
}
```

**K shortest paths:**

<p tit="Procedure Body Language"></p>

```gql
FOR path IN MATCH SHORTEST 5 (source)-[:ROAD]->{}(target) {
    RETURN path.length, path.nodes
}
```

**All shortest paths:**

<p tit="Procedure Body Language"></p>

```gql
FOR path IN MATCH ALL SHORTEST (source)-[:ROAD]->{}(target) {
    RETURN path.nodes, path.length
}
```

### Direction Patterns

<p tit="Procedure Body Language"></p>

```gql
-- Outgoing edges only
FOR (n, d) IN MATCH BFS (start)-[:FOLLOWS]->{1,5}(n) { ... }

-- Incoming edges only
FOR (n, d) IN MATCH BFS (start)<-[:FOLLOWS]-{1,5}(n) { ... }

-- Both directions (undirected)
FOR (n, d) IN MATCH BFS (start)-[:KNOWS]-{1,5}(n) { ... }
```

### Edge Filters

Filter edges during traversal using `WHERE` on the edge pattern:

<p tit="Procedure Body Language"></p>

```gql
-- Only traverse edges with weight > 0.5
FOR (node, depth) IN MATCH (start)-[:KNOWS WHERE weight > 0.5]->{1,5}(node) {
    RETURN node._id, depth
}

-- Multiple conditions
FOR (node, depth) IN MATCH (start)-[:ROAD WHERE distance < 100 AND active = true]->{1,10}(node) {
    RETURN node._id, depth
}
```

### Hop Range

The `{min,max}` quantifier controls traversal depth:

<p tit="Procedure Body Language"></p>

```gql
-- Exactly 2 hops
(start)-[:KNOWS]-{2}(end)

-- 1 to 5 hops
(start)-[:KNOWS]-{1,5}(end)

-- Any number of hops (unbounded)
(start)-[:KNOWS]->{}(end)

-- At least 3 hops
(start)-[:KNOWS]-{3,}(end)
```

### Combining Traversal with BREAK

Early termination during traversal:

<p tit="Procedure Body Language"></p>

```gql
FOR (node, depth) IN MATCH BFS (start)-[:EDGE]->{1,10}(node) {
    IF depth > 5 {
        BREAK  -- stop exploring beyond depth 5
    }
    IF node.target = true {
        RETURN node._id AS target_found, depth
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

    FOR (node, depth) IN MATCH BFS (seed)-[:FOLLOWS]->{1,$max_hops}(node) {
        -- Influence decays with distance
        LET influence = 1.0 / (depth * depth)
        RETURN node._id AS node_id, depth AS hop, influence
    }
}
```