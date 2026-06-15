# Running Algorithms

All built-in graph algorithms are invoked via the `CALL algo.<name>()` syntax and support up to four execution modes: **run**, **stream**, **stats**, and **write**.

## Computing Engine

Most algorithms can run with or without the computing engine enabled. For large graphs, it is strongly recommended to enable the compute engine first for significantly better performance:

```gql
ALTER GRAPH myGraph SET COMPUTE ENABLED
```

With the compute engine enabled, algorithms use an in-memory topology for O(1) neighbor lookups. Without it, algorithms fall back to a storage-based path which is much slower on large graphs.

<a target="_blank" href="/docs/computing-engine">Learn more about computing engine →</a>

## Running on a Projection

Algorithms can be scoped to a projection — a named, materialized subset of the graph — by appending `ON <projectionName>` to the `CALL`. The algorithm runs against the projection's cached topology instead of the full graph.

```gql
-- Define the subgraph once
CREATE PROJECTION social_graph WITH NODE :User EDGE :Follows

-- Run an algorithm on it
CALL algo.pagerank() ON social_graph YIELD node, score
RETURN node, score ORDER BY score DESC LIMIT 10
```

The same `ON <projectionName>` clause works with the `.stream`, `.stats`, and `.write` execution modes shown below.

<a target="_blank" href="/docs/gql/projections">Learn more about projections →</a>

## Execution Modes

### Run Mode

Returns the full result set after computation completes.

<p tit="Syntax"></p>
```
CALL algo.<name>({
  <param>: <value>,
  ...
}) YIELD <column1>, <column2>, ...
```

### Stream Mode

Streams results progressively as they are generated, optimizing memory usage. Returns the same columns as run mode.

<p tit="Syntax"></p>
```
CALL algo.<name>.stream({
  <param>: <value>,
  ...
}) YIELD <column1>, <column2>, ...
RETURN <column1>, <column2>, ...
```

### Stats Mode

Returns aggregate statistics (e.g., node count, min/max/avg scores) instead of per-node results.

<p tit="Syntax"></p>
```
CALL algo.<name>.stats({
  <param>: <value>,
  ...
}) YIELD <statsColumn1>, <statsColumn2>, ...
```

### Write Mode

Computes results and writes them back to node properties asynchronously. Returns a `task_id` and `status` immediately. Use `SHOW TASKS` with the `task_id` to check progress and results.

<p tit="Syntax"></p>
```
CALL algo.<name>.write({
  <param>: <value>,
  ...
}, {
  db: {
    property: "<propertyName>"
  }
}) YIELD task_id, status
```

The `db.property` supports two formats:

- **String**: Writes the primary score column to a single property. E.g., `property: "score_prop"`
- **Map**: Explicit column-to-property mapping. E.g., `property: {score: "score_prop", rank: "rank_prop"}`

## Combining with Other Queries

Algorithm results can be combined with other GQL clauses for further processing:

```gql
-- Filter results
CALL algo.pagerank({order: "desc"}) YIELD nodeId, score
FILTER score > 0.1
RETURN nodeId, score

-- Join with graph data
CALL algo.degree({direction: "out", limit: 5}) YIELD nodeId, degree
MATCH (n WHERE n._id = nodeId)
RETURN n._id, n.name, degree

-- Chain with other operations
CALL algo.closeness.stream({order: "desc", limit: 10}) YIELD nodeId, score
MATCH (n WHERE n._id = nodeId)-[:knows]->(friend)
RETURN n._id, score, COLLECT(friend._id) AS friends
```
