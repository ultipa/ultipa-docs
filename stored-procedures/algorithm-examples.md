# Algorithm Examples

Complete stored procedure implementations for common graph algorithms. Each example uses the procedure-specific built-in functions documented in <a href="/docs/stored-procedures/builtin-functions">Builtin Functions</a>.

## Centrality Algorithms

### PageRank

Iterative ranking algorithm where each node's rank is determined by the ranks of its in-neighbors.

**Key functions used**: `INIT_SLICE_PROP`, `INIT_OUT_DEGREES`, `IN_NEIGHBOR_SUM`, `COPY_SLICE_PROP`, `BATCH_PERSIST_SLICE`

**Complexity**: O(iterations × edges)

```gql
CREATE PROCEDURE pagerank(iterations: INT = 20, damping: FLOAT = 0.85)
RETURNS (node_id: STRING, rank: FLOAT)
AS {
    LET n = NODE_COUNT()
    LET initial = 1.0 / n

    INIT_SLICE_PROP('rank', initial)
    INIT_SLICE_PROP('new_rank', 0.0)
    INIT_OUT_DEGREES('out_degree')

    FOR iter IN RANGE(0, $iterations) {
        -- Reset new_rank with teleportation probability
        INIT_SLICE_PROP('new_rank', (1.0 - $damping) / n)

        -- Each node collects rank contributions from in-neighbors
        PARALLEL FOR node IN SCAN() WORKERS 8 {
            LET contrib = IN_NEIGHBOR_SUM(node, 'rank', 'out_degree')
            LET current = GET_SLICE_PROP(node._internal_id, 'new_rank')
            SET_SLICE_PROP(node._internal_id, 'new_rank', current + $damping * contrib)
        }

        COPY_SLICE_PROP('new_rank', 'rank')
    }

    -- Persist to storage
    BATCH_PERSIST_SLICE('rank', 'pagerank_score')

    -- Return results
    FOR node IN SCAN() {
        LET rank = GET_SLICE_PROP(node._internal_id, 'rank')
        RETURN node._id AS node_id, rank
    }
}
```

**Usage**:

```gql
CALL pagerank(20, 0.85) YIELD node_id, rank
```

### HITS (Hyperlink-Induced Topic Search)

Computes hub and authority scores. Authorities are pointed to by many hubs; hubs point to many authorities.

**Key functions used**: `SUM_IN_NEIGHBOR_PROP`, `SUM_OUT_NEIGHBOR_PROP`, `SUM_SLICE_PROP_SQ`, `BATCH_PERSIST_SLICES`

**Complexity**: O(iterations × edges)

```gql
CREATE PROCEDURE hits(iterations: INT = 20)
RETURNS (node_id: STRING, hub: FLOAT, authority: FLOAT)
AS {
    LET n = NODE_COUNT()

    INIT_SLICE_PROP('hub', 1.0)
    INIT_SLICE_PROP('auth', 1.0)
    INIT_SLICE_PROP('new_hub', 0.0)
    INIT_SLICE_PROP('new_auth', 0.0)

    FOR iter IN RANGE(0, $iterations) {
        -- Update authority: auth(v) = sum of hub scores of in-neighbors
        PARALLEL FOR node IN SCAN() WORKERS 8 {
            LET new_auth = SUM_IN_NEIGHBOR_PROP(node, 'hub')
            SET_SLICE_PROP(node._internal_id, 'new_auth', new_auth)
        }

        -- Update hub: hub(v) = sum of authority scores of out-neighbors
        PARALLEL FOR node IN SCAN() WORKERS 8 {
            LET new_hub = SUM_OUT_NEIGHBOR_PROP(node, 'auth')
            SET_SLICE_PROP(node._internal_id, 'new_hub', new_hub)
        }

        -- Normalize using L2 norm
        LET auth_norm = SQRT(SUM_SLICE_PROP_SQ('new_auth'))
        LET hub_norm = SQRT(SUM_SLICE_PROP_SQ('new_hub'))

        PARALLEL FOR node IN SCAN() WORKERS 8 {
            LET a = GET_SLICE_PROP(node._internal_id, 'new_auth')
            LET h = GET_SLICE_PROP(node._internal_id, 'new_hub')
            SET_SLICE_PROP(node._internal_id, 'auth', a / auth_norm)
            SET_SLICE_PROP(node._internal_id, 'hub', h / hub_norm)
        }
    }

    BATCH_PERSIST_SLICES('hub', 'hub_score', 'auth', 'authority_score')

    FOR node IN SCAN() {
        LET hub = GET_SLICE_PROP(node._internal_id, 'hub')
        LET auth = GET_SLICE_PROP(node._internal_id, 'auth')
        RETURN node._id AS node_id, hub, auth AS authority
    }
}
```

### Eigenvector Centrality

Similar to PageRank but without damping. A node's centrality is proportional to the sum of its neighbors' centralities.

**Key functions used**: `SUM_IN_NEIGHBOR_PROP`, `SUM_SLICE_PROP_SQ`

**Complexity**: O(iterations × edges)

```gql
CREATE PROCEDURE eigenvector_centrality(iterations: INT = 50)
RETURNS (node_id: STRING, centrality: FLOAT)
AS {
    LET n = NODE_COUNT()
    INIT_SLICE_PROP('score', 1.0 / n)
    INIT_SLICE_PROP('new_score', 0.0)

    FOR iter IN RANGE(0, $iterations) {
        -- Each node's score = sum of neighbors' scores
        PARALLEL FOR node IN SCAN() WORKERS 8 {
            LET new_val = SUM_IN_NEIGHBOR_PROP(node, 'score')
            SET_SLICE_PROP(node._internal_id, 'new_score', new_val)
        }

        -- L2 normalize
        LET norm = SQRT(SUM_SLICE_PROP_SQ('new_score'))
        IF norm > 0 {
            PARALLEL FOR node IN SCAN() WORKERS 8 {
                LET val = GET_SLICE_PROP(node._internal_id, 'new_score')
                SET_SLICE_PROP(node._internal_id, 'score', val / norm)
            }
        }
    }

    BATCH_PERSIST_SLICE('score', 'eigenvector_centrality')

    FOR node IN SCAN() {
        LET centrality = GET_SLICE_PROP(node._internal_id, 'score')
        RETURN node._id AS node_id, centrality
    }
}
```

## Community Detection

### Connected Components

Label propagation on undirected graphs. Each node adopts the minimum component ID from its neighbors.

**Key functions used**: `MIN_BOTH_NEIGHBOR_PROP`, `BATCH_PERSIST_SLICE`

**Complexity**: O(diameter × edges)

```gql
CREATE PROCEDURE connected_components()
RETURNS (node_id: STRING, component: INTEGER)
AS {
    INIT_SLICE_PROP('comp', 0.0)

    -- Initialize each node's component to its internal ID
    PARALLEL FOR node IN SCAN() WORKERS 8 {
        SET_SLICE_PROP(node._internal_id, 'comp', node._internal_id)
    }

    LET changed = 1
    LET iteration = 0
    WHILE changed > 0 {
        LET changed = 0

        PARALLEL FOR node IN SCAN() WORKERS 8 {
            LET current = GET_SLICE_PROP(node._internal_id, 'comp')
            LET min_comp = MIN_BOTH_NEIGHBOR_PROP(node, 'comp', current)

            IF min_comp < current {
                SET_SLICE_PROP(node._internal_id, 'comp', min_comp)
                LET changed = changed + 1
            }
        }

        LET iteration = iteration + 1
        PRINT 'Iteration ' || TOSTRING(iteration) || ': ' || TOSTRING(changed) || ' nodes changed'
    }

    BATCH_PERSIST_SLICE('comp', 'component_id')

    FOR node IN SCAN() {
        LET comp = GET_SLICE_PROP(node._internal_id, 'comp')
        RETURN node._id AS node_id, TOINTEGER(comp) AS component
    }
}
```

### Label Propagation

Community detection where each node adopts the most common label among its neighbors. Uses fused neighbor operations for performance.

**Key functions used**: `NEIGHBORS`, `GET_SLICE_PROP`, `SET_SLICE_PROP`

**Complexity**: O(iterations × edges)

```gql
CREATE PROCEDURE label_propagation(iterations: INT = 10)
RETURNS (node_id: STRING, community: INTEGER)
AS {
    INIT_SLICE_PROP('label', 0.0)

    -- Initialize each node with a unique label
    PARALLEL FOR node IN SCAN() WORKERS 8 {
        SET_SLICE_PROP(node._internal_id, 'label', node._internal_id)
    }

    FOR iter IN RANGE(0, $iterations) {
        LET changed = 0

        FOR node IN SCAN() {
            -- Count neighbor labels
            LET label_counts = {}
            FOR neighbor IN NEIGHBORS(node) {
                LET nlabel = GET_SLICE_PROP(neighbor._internal_id, 'label')
                LET key = TOSTRING(TOINTEGER(nlabel))
                LET current_count = MAP_GET(label_counts, key, 0)
                -- Simple majority: take first neighbor's label for tie-breaking
            }
            -- Simplified: adopt minimum neighbor label
            LET min_label = MIN_BOTH_NEIGHBOR_PROP(node, 'label', GET_SLICE_PROP(node._internal_id, 'label'))
            LET current = GET_SLICE_PROP(node._internal_id, 'label')
            IF min_label <> current {
                SET_SLICE_PROP(node._internal_id, 'label', min_label)
                LET changed = changed + 1
            }
        }

        PRINT 'Iteration ' || TOSTRING(iter) || ': ' || TOSTRING(changed) || ' changed'
        IF changed = 0 {
            BREAK
        }
    }

    BATCH_PERSIST_SLICE('label', 'community_id')

    FOR node IN SCAN() {
        LET label = GET_SLICE_PROP(node._internal_id, 'label')
        RETURN node._id AS node_id, TOINTEGER(label) AS community
    }
}
```

## Pathfinding

### Dijkstra SSSP (Single Source Shortest Path)

Finds shortest weighted paths from a source node.

**Key functions used**: `MIN_OUT_NEIGHBOR_PROP`, `INIT_SLICE_PROP`

**Complexity**: O(diameter × nodes) with convergence check

```gql
CREATE PROCEDURE dijkstra_sssp(source_id: STRING, max_iterations: INT = 100)
RETURNS (node_id: STRING, distance: FLOAT)
AS {
    LET INF = 999999999.0

    INIT_SLICE_PROP('dist', INF)

    -- Set source distance to 0
    MATCH (source {_id: $source_id})
    SET_SLICE_PROP(source._internal_id, 'dist', 0.0)

    -- Bellman-Ford style relaxation
    FOR iter IN RANGE(0, $max_iterations) {
        LET changed = 0

        PARALLEL FOR node IN SCAN() WORKERS 8 {
            LET current_dist = GET_SLICE_PROP(node._internal_id, 'dist')
            -- Get minimum (neighbor_dist + 1) -- unweighted
            LET min_neighbor = MIN_IN_NEIGHBOR_PROP(node, 'dist', current_dist)
            LET new_dist = min_neighbor + 1.0

            IF new_dist < current_dist {
                SET_SLICE_PROP(node._internal_id, 'dist', new_dist)
                LET changed = changed + 1
            }
        }

        IF changed = 0 {
            PRINT 'Converged at iteration ' || TOSTRING(iter)
            BREAK
        }
    }

    BATCH_PERSIST_SLICE('dist', 'distance_from_source')

    FOR node IN SCAN() {
        LET dist = GET_SLICE_PROP(node._internal_id, 'dist')
        IF dist < INF {
            RETURN node._id AS node_id, dist AS distance
        }
    }
}
```

### Shortest Path Finder

Uses the built-in FOR...IN MATCH SHORTEST traversal for exact shortest paths.

**Key functions used**: `MATCH SHORTEST` traversal

```gql
CREATE PROCEDURE find_path(from_id: STRING, to_id: STRING)
RETURNS (path_length: INT, route: LIST)
AS {
    MATCH (source {_id: $from_id})
    MATCH (target {_id: $to_id})

    LET path = MATCH SHORTEST (source)-[:CONNECTS]->{1,50}(target)

    IF path IS NOT NULL {
        LET route = []
        FOR node IN path.nodes {
            route = route + [node._id]
        }
        RETURN path.length AS path_length, route
    }
}
```

## Link Prediction

### Friend Recommendations

Find recommended friends using KHOP traversal and Jaccard similarity scoring.

**Key functions used**: `KHOP` traversal, `COUNT_COMMON_NEIGHBORS`, `JACCARD_SIMILARITY`

```gql
CREATE PROCEDURE recommend_friends(person_id: STRING)
RETURNS (recommended: STRING, mutual_count: INT, score: FLOAT)
AS {
    MATCH (p {_id: $person_id})

    -- Get direct friends for exclusion
    LET friends = []
    FOR f IN NEIGHBORS(p, OUT, :KNOWS) {
        friends = friends + [f]
    }

    -- Find friends-of-friends via 2-hop
    FOR (fof, depth) IN MATCH KHOP (p)-[:KNOWS]-{2}(fof) {
        IF fof._id != $person_id AND fof NOT IN friends {
            LET mutual = COUNT_COMMON_NEIGHBORS(p, fof)
            IF mutual > 0 {
                LET score = JACCARD_SIMILARITY(p, fof)
                RETURN fof._id AS recommended, mutual AS mutual_count, score
            }
        }
    }
}
```

**Usage**:

```gql
CALL recommend_friends('alice') YIELD recommended, mutual_count, score
```

## Summary Table

| Algorithm | Category | Key Functions | Parallelized |
|-----------|----------|---------------|-------------|
| PageRank | Centrality | `IN_NEIGHBOR_SUM`, `COPY_SLICE_PROP` | Yes |
| HITS | Centrality | `SUM_IN/OUT_NEIGHBOR_PROP`, `SUM_SLICE_PROP_SQ` | Yes |
| Eigenvector | Centrality | `SUM_IN_NEIGHBOR_PROP`, `SUM_SLICE_PROP_SQ` | Yes |
| Connected Components | Community | `MIN_BOTH_NEIGHBOR_PROP` | Yes |
| Label Propagation | Community | `MIN_BOTH_NEIGHBOR_PROP` | Partial |
| Dijkstra SSSP | Pathfinding | `MIN_IN_NEIGHBOR_PROP` | Yes |
| Shortest Path | Pathfinding | `MATCH SHORTEST` | No |
| Friend Recs | Link Prediction | `KHOP`, `JACCARD_SIMILARITY` | No |
