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

## Weight, Capacity and Cost Properties

Many algorithms read a number from an edge property named by a parameter — `weight` (spelled `edge_weight_property` or `weightProperty` in some algorithms), `capacityProperty`, or `costProperty`.

The property is validated **before the algorithm runs**, and a call that cannot use it is refused rather than falling back to a default:

```gql
CALL algo.spfa({source: 'A', weight: 'cost_x'}) YIELD nodeId, distance
--   algo.spfa: weight property 'cost_x' does not exist on any edge in graph 'g'.
--   Check the spelling, or leave out 'weight' to run unweighted.

CALL algo.spfa({source: 'A', weight: 'cost'}) YIELD nodeId, distance
--   algo.spfa: weight property 'cost' holds text on ROAD edges in graph 'g'; weights must be
--   numbers. Store the values as numbers, or choose a property that holds numbers.
```

The check applies wherever an algorithm runs: a direct `CALL` in any execution mode — `.write` returns the error instead of starting a task — a `CALL` inside a <a target="_blank" href="/docs/stored-procedures/calling-procedures">stored procedure</a> (the procedure fails when it is called; creating it still succeeds), an algorithm feature in an <a target="_blank" href="/docs/machine-learning">ML pipeline</a> (the training call fails), and `CALL … ON <projection>`.

- To run **unweighted**, leave the parameter out. Naming a property that does not exist is an error, not a request to run unweighted.
- A property holding **numbers stored as text** — the usual result of importing a CSV without a cast — must be converted to numbers before it can be used as a weight, capacity or cost.
- **Unsigned-integer and decimal** columns are read as their value.

### Weights on a Projection

The path and flow algorithms — `algo.apsp`, `algo.astar`, `algo.deltastepping`, `algo.kspanningtree`, `algo.maxflow`, `algo.mincostflow`, `algo.mst`, `algo.pcst`, `algo.shortestpath`, `algo.spfa`, `algo.steiner`, `algo.yens` — read a weight, capacity or cost **only from the projection's own edges**: edges of its edge types whose two ends are both its nodes.

The other weighted algorithms — `algo.betweenness`, `algo.closeness`, `algo.degree`, `algo.eccentricity`, `algo.eigenvector`, `algo.harmonic`, `algo.katz`, `algo.leiden`, `algo.louvain`, `algo.pagerank`, `algo.similarity`, `algo.textrank` — **refuse a weight property on a projection**. With a weight they read the whole graph, so the answer would ignore the projection. Either run the call on a graph that holds only the nodes and edges you want, or leave out the weight to run unweighted on the projection.

### Weights and Direction

With `direction: 'in'` or `direction: 'both'`, `algo.spfa`, `algo.shortestpath`, `algo.astar`, `algo.apsp` and `algo.yens` weigh each step by the edge actually walked. On a graph where the two directions between a pair of nodes carry different weights, this decides the distances, paths and costs.

`algo.mst` weighs a pair of nodes by the lower of its two directions, and expects every edge to be stored in both directions; a pair joined in one direction only can be left out of the tree.

`algo.maxflow` and `algo.mincostflow` give each parallel edge between two nodes its own capacity and cost.

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
