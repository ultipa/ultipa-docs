# Vector Index

## Overview

A vector index is designed to efficiently store and manage high-dimensional vectors, enabling fast retrieval of similar vectors based on a chosen similarity metric. Instead of performing an exhaustive search across all stored vectors, the vector index significantly reduces the search space, making nearest-neighbor retrieval more efficient.

GQLDB's vector index is built on **HNSW** (Hierarchical Navigable Small World), a graph-based algorithm for **approximate nearest neighbor (ANN)** search. It organizes vectors into a multi-layer graph so a query can hop toward its nearest neighbors in roughly logarithmic time instead of scanning every vector — returning almost the exact nearest neighbors, far faster. The `m`, `efConstruction`, and `efSearch` options tune this graph's quality and speed.

## Example Graph

Same with the <a target="_blank" href="/docs/ai-and-vectors/vectors#Quick-Start">Vectors → Quick Start</a> example: a graph contains 10 `Book` nodes with properties `title`, `author`, `summary`, and `summaryEmbedding`.
  
## Showing Vector Index

Retrieve all vector indexes in the current graph:

```gql
SHOW VECTOR INDEX
```

The result includes the following fields:

| Field | Description |
| -- | -- |
| `index_name` | Vector index name. |
| `label` | The label of the indexed nodes (`*` if applied to all labels). |
| `property` | The indexed property. |
| `dimensions` | The number of vector dimensions. |
| `node_count` | Number of vectors currently indexed. |
| `metric` | The similarity metric (`cosine`, `euclidean`, or `dot`). |
| `m` | HNSW connectivity parameter. |
| `ef_construction` | HNSW construction parameter. |
| `ef_search` | HNSW search parameter. |
| `quantized` | Whether the index stores quantized (compressed) vectors. |
| `quantization` | Quantization scheme: `sq8`, `pq`, or `none` (full precision). |
| `memory_bytes` | Memory usage of the index in bytes. |
| `status` | Index status: `READY` (serving queries), `BUILDING` (initial bulk build in progress), `REBUILDING` (`REBUILD VECTOR INDEX` is running; queries see an empty index until done), or `STALE` (loaded from disk but the on-disk manifest didn't match — usually caused by a crash mid-save; the index serves no results until rebuilt). |

## Creating Vector Index

You can create a vector index using the `CREATE VECTOR INDEX` statement for a `VECTOR`-type property. The index is built asynchronously; use `SHOW VECTOR INDEX` to check build progress.

```syntax
<create vector index statement> ::=
  "CREATE VECTOR INDEX" [ "IF NOT EXISTS" ] <index name> "ON" < "NODE" | "EDGE" >
  <label name> "(" <vector property name> ")" 
  "OPTIONS" "{" <option> { "," <option> }... "}"
```

**Details**

- The `<index name>` must be unique among vector indexes.
- Use `IF NOT EXISTS` to avoid errors when the index already exists.
- `<option>`s for a vector index:

| Option | Type | Default | Description |
| -- | -- | -- | -- |
| `dimensions` | `INT` | / | **Required.** The dimension of the vectors to be indexed. Vectors of a different length are skipped, see <a href="#Dimension-Validation">Dimension Validation</a>. |
| `metric` | `STRING` | `cosine` | The similarity metric. Supports `cosine`, `euclidean`, and `dot`. |
| `m` | `INT` | `16` | HNSW parameter: Maximum links each vector keeps. Higher values improve recall but increase memory and build time. |
| `efConstruction` | `INT` | `200` | HNSW parameter: Size of dynamic candidate list during index construction. Higher values improve quality but increase build time. |
| `quantization` | `STRING` | / | Vector compression scheme: `sq8` or `pq`; omit for full precision. See <a href="#Quantization">Quantization</a>. |

> `efSearch` is not a create-time option. It is set after the index is built, see <a href="#Adjusting-Search-Parameters">Adjusting Search Parameters</a>.

Create a vector index named `summary_embedding` for the `summaryEmbedding` of `Book` nodes:

```gql
CREATE VECTOR INDEX idx_summaryEmbedding ON NODE Book (summaryEmbedding) OPTIONS {
  dimensions: 1536,
  metric: "cosine"
}
```

### Quantization

By default a vector index stores full-precision `float32` vectors. For large indexes you can opt into **quantization** to cut memory use, via the `quantization` option:

```gql
CREATE VECTOR INDEX idx_summaryEmbedding ON NODE Book (summaryEmbedding) OPTIONS {
  dimensions: 1536,
  metric: "cosine",
  quantization: "sq8"
}
```

- **`sq8`**: 8-bit scalar quantization (per-dimension min/max), using about **4× less memory** than full precision.
- **`pq`**: product quantization.

The HNSW graph is searched over the compact codes, then the top candidates are **re-ranked against the exact vectors** (kept on disk), so recall stays close to full precision. Quantization is applied at build or rebuild time: the index is first populated at full precision, the codes are trained, and the in-memory full vectors are dropped. To add, remove, or change the scheme on an existing index, run `REBUILD VECTOR INDEX`; `SHOW VECTOR INDEX` reports the active scheme in its `quantization` column.

### Automatic Sync on Mutations

After the index is created, normal data mutations on indexed nodes are reflected in the index automatically, no manual rebuild is needed for incremental writes.

You only need to run `REBUILD VECTOR INDEX` (or `ai.rebuild_index()`) after a crash recovery (when the index status is `STALE`), or after changing `m`/`efConstruction`/`quantization`.

### Dimension Validation

On a **closed graph**, to create vector index on a typed `VECTOR(N)` property, set the index `dimensions` to the same `N`. If they differ, the index can never hold anything.

On an **open graph**, the property may hold vectors of differing lengths. Creating the index succeeds regardless, but the two stages behave differently:

- **Initial build**: pre-existing vectors whose length doesn't match `dimensions` are silently skipped. Compare `node_count` in `SHOW VECTOR INDEX` against your expected count to spot any that were dropped.
- **Subsequent writes**: an `INSERT`/`SET` of a wrong-length vector on an indexed label is rejected.

## Dropping Vector Index

Dropping a vector index does not affect the actual property values.

```gql
DROP VECTOR INDEX idx_summaryEmbedding
```

Use `IF EXISTS` to avoid errors when the index doesn't exist:

```gql
DROP VECTOR INDEX IF EXISTS idx_summaryEmbedding
```

## Using Vector Index

When a vector index exists, queries using `ai.distance()` or `ai.cosine()` with `ORDER BY … LIMIT` or `WHERE` threshold conditions are automatically optimized to use the index for fast approximate nearest neighbor (ANN) search, such as:

- k-NN: `ORDER BY ai.distance(n.prop, query) ASC LIMIT k`
- Range: `WHERE ai.cosine(n.prop, query) > threshold` 

The optimizer recognizes exactly these patterns. The query vector argument must evaluate to a **constant**: an inlined literal, an `ai.embed()` call, or a query parameter (e.g. `$queryVec`). A **per-row** value bound by `MATCH` is not supported, since the index needs a single fixed query vector for the search. The optimizer automatically uses the vector index.

> Only `ai.distance()` and `ai.cosine()` are index-accelerated. Other distance functions (`ai.euclidean()`, `ai.dot()`, etc.) still work but compute by scanning every vector (brute force), not via the index.

### k-NN Search

Find the k nearest neighbors using `ORDER BY … LIMIT`.

```gql
MATCH (b:Book)
RETURN b.title, ai.cosine(b.summaryEmbedding, ai.embed('romantic novel about social class')) AS similarity
ORDER BY similarity DESC LIMIT 3
```

> The query vector's dimension must match the index's `dimensions` setting. For example, if the index uses 384-dimensional embeddings, `ai.embed()` must use a provider that produces 384-dimensional vectors.

### Range Search

Find all vectors within a similarity threshold using a `WHERE` condition:

```gql
MATCH (b:Book)
WHERE ai.cosine(b.summaryEmbedding, ai.embed('dystopian society and surveillance')) > 0.5
RETURN b.title, ai.cosine(b.summaryEmbedding, ai.embed('dystopian society and surveillance')) AS similarity
ORDER BY similarity DESC
```

Range search is **approximate** (it uses the HNSW index), and the original `WHERE` condition is kept in the plan as a correctness safety net. The same constant query-vector rule as k-NN search applies.

### Hybrid Search

Combine vector similarity with property filters and graph traversal — the thing a graph database can do that a standalone vector store cannot. Here we rank books by semantic similarity while restricting the candidates with a property filter:

```gql
MATCH (b:Book)
WHERE b.author <> 'George Orwell'
RETURN b.title, b.author,
       ai.cosine(b.summaryEmbedding, ai.embed('societal control and surveillance')) AS similarity
ORDER BY similarity DESC LIMIT 3
```

Because it's a graph, you can also chain `MATCH` traversals into the same query when your data has relationships (e.g. `MATCH (b)-[:WRITTEN_BY]->(a:Author)`), mixing semantic search with graph structure.

> When the vector condition is combined with other predicates (e.g. a `WHERE` filter or a traversal), the index may not be engaged and the query can fall back to a scan.

## Managing Vector Index

### Adjusting Search Parameters

`efSearch` controls the size of the dynamic candidate list during search. Higher values explore more neighbors, improving recall at the cost of latency. The default is `100`. It is the only runtime-mutable index option, and it is not accepted at `CREATE VECTOR INDEX` time — set it after the index is built using either of the two equivalent forms below.

Function-call form:

```gql
RETURN ai.set_index_option('idx_summaryEmbedding', 'efSearch', 200)
```

Statement form:

```gql
ALTER VECTOR INDEX idx_summaryEmbedding SET efSearch = 200
```

To change `m`, `efConstruction`, or `quantization`, drop and recreate the index with the new options, or edit the index configuration and run `ai.rebuild_index()`.

### Rebuilding an Index

If an index is in `STALE` status (e.g., after a crash), rebuild it. Two equivalent forms:

Function-call form:

```gql
RETURN ai.rebuild_index('idx_summaryEmbedding')
```

Statement form:

```gql
REBUILD VECTOR INDEX idx_summaryEmbedding
```