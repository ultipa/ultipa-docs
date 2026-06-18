# Diagnostics and Repair

## Overview

This page covers the statements and functions that audit a graph's health and repair drift between the data stores and their derived indexes. Use the validation surface first to learn what's wrong, then pick the targeted repair.

| Surface | What it does | Mutates? |
| -- | -- | -- |
| [`db.validate_graph()`](#db-validate_graph) | Whole-graph audit: orphan edges, stats drift, label/edge-index drift, `_id`-cache drift, fulltext & property index health. | Read-only |
| [`db.storage_health()`](#db-storage_health) | LSM-level health: unreadable / quarantined SSTables, compaction/flush failures. | Read-only |
| [`db.reload_stats()`](#db-reload_stats) / [`RELOAD STATS`](#reload-stats) | Full re-scan rebuild of the stats cache (label / edge counts, property stats). | Additive |
| [`db.repair_label_index()`](#db-repair_label_index) | Rebuild node label index + edge reverse-adjacency index. | Additive |
| [`ALTER INDEX … REBUILD`](#alter-index-rebuild) | Rebuild a property index. | Additive |
| [`REBUILD VECTOR INDEX`](#rebuild-vector-index) | Rebuild a vector index. | Additive |
| [`db.repair_storage()`](#db-repair_storage) | Quarantine unreadable SSTables so the graph can serve its remaining data. | **Destructive** |
| [`db.delete_orphans_edges()`](#db-delete_orphans_edges) | Delete every edge whose endpoint nodes don't resolve. | **Destructive** |

## Validation

### db.validate_graph()

Runs a whole-graph audit and returns a map with one entry per check. Use it as the starting point whenever query results or counts look wrong.

```gql
RETURN db.validate_graph()

-- Deep mode: adds O(N) per-index count cross-checks.
-- More expensive; surfaces drift the cheap pass would miss.
RETURN db.validate_graph({deep: true})
```

**Output shape**:

| Field | Description |
| -- | -- |
| `status` | `clean` if every check is fine; `degraded` if any check reports issues. |
| `deep` | Whether deep mode ran. |
| `scanned_at` | UTC timestamp of the scan. |
| `graph` | The audited graph (current graph). |
| `checks` | A map keyed by check name; one entry per validator below. |

**Checks**:

| Check | What it signals | Fix |
| -- | -- | -- |
| `orphan_edges` | Edges whose source or target node no longer resolves. | [`db.delete_orphans_edges()`](#db-delete_orphans_edges) |
| `stats_drift` | Per-label edge counter vs a real scan count differs. Misleads `RETURN count(r)` (which pushes down to the counter) and `SHOW EDGE TYPES`. | [`db.reload_stats()`](#db-reload_stats) |
| `label_index_drift` | Node label index is empty or partial — `MATCH (n:Label)` returns nothing while `MATCH (n)` works. | [`db.repair_label_index()`](#db-repair_label_index) |
| `edge_index_drift` | Edge reverse-adjacency (`edges_in`) drift — incoming traversal misses edges the outgoing direction still finds. | [`db.repair_label_index()`](#db-repair_label_index) |
| `id_cache_drift` | In-memory `_id` → uuid cache drift. `WHERE n._id = '…'` misses the accelerator (slow) or hits phantom entries. | Restart the graph engine; a full validate + reload typically resolves it. |
| `edge_id_cache_drift` | Same as above, for the `EDGE_ID` cache. Reports `not_applicable` when `EDGE_ID` is disabled. | Same. |
| `fulltext_drift` | A fulltext index failed to load (the "ready but query errors on reopen" class), or — in `deep` mode — its reported doc counts don't match live entities. | `DROP FULLTEXT INDEX …` + recreate. |
| `property_index_drift` | Per-graph drift counters (dangling pointers, propagation failures), failed-status indexes, or — in `deep` mode — live-entry-count mismatch. | [`ALTER INDEX … REBUILD`](#alter-index-rebuild) on the affected index. |

### db.storage_health()

GQLDB's storage engine is LSM-tree based. `db.storage_health()` returns a read-only report of that layer for the current graph: SSTable counts, compaction/flush failures, and any SSTables the engine couldn't read.

> **SSTables** (sorted-string tables) are the immutable, sorted on-disk files an LSM-tree storage engine writes data into. The engine keeps them in **levels** (L0, L1, …) and background **compaction** merges them to reclaim space. An "unreadable" SSTable is one the engine couldn't open (corruption or version mismatch); "blocked" means an environmental issue (file lock, permission); "quarantined" means [`db.repair_storage()`](#db-repair_storage) moved an unreadable one aside and its data is lost.

```gql
RETURN db.storage_health()
```

**Output shape**:

| Field | Description |
| -- | -- |
| `supported` | `false` if the underlying engine doesn't surface LSM internals. The other fields are absent in that case. |
| `graphName` | The audited graph. |
| `healthy` | `true` if no failures and no unreadable SSTables. |
| `degraded` | `true` if any unreadable / blocked / quarantined SSTable exists. |
| `stores` | One row per underlying store with `name`, `sstCount`, `compactionFailures`, `flushFailures`, and lists of `unreadable` / `blocked` / `quarantined` SSTables (each carries `path`, `level`, `entryCount`, `reason`). |

A `degraded=true` result with non-empty `unreadable` typically means a disk or filesystem issue; review the `reason` fields before running [`db.repair_storage()`](#db-repair_storage).

## Repair: Additive

The repairs in this section are idempotent. Re-running them is safe, no data is removed.

### db.reload_stats()

Full re-scan rebuild of the stats cache (edge-label counts, node-label counts, total counts, self-loop counts, property stats). Run it after `db.validate_graph()` reports a non-empty `stats_drift`, after a bulk import or restore, or whenever `db.stats()` reports `statsReady = false`.

```gql
RETURN db.reload_stats()
```

`db.rebuild_stats()` and `db.repair_stats()` are aliases of the same function.

> `O(N + E)` — not a hot-path operation. Schedule it as maintenance.

### RELOAD STATS

Top-level statement form of the same operation:

```gql
RELOAD STATS
```

### db.repair_label_index()

Rebuilds the **node label index** (from node records) and the **edge reverse-adjacency index** (from edges). Idempotent. Run after `db.validate_graph()` shows `label_index_drift` or `edge_index_drift`.

```gql
RETURN db.repair_label_index()
```

### ALTER INDEX … REBUILD

Rebuild a single property index from the live data. Use when `property_index_drift` flags a specific index, or after schema/data churn that left an index stale.

```gql
ALTER INDEX idx_user_email REBUILD
```

### REBUILD VECTOR INDEX

Rebuild a vector index from scratch. The index name is the vector index's identifier from `SHOW INDEXES`.

```gql
REBUILD VECTOR INDEX vec_user_embedding
```

## Repair: Destructive

The repairs in this section **remove data or quarantine files**. They are appropriate as a last resort after `db.validate_graph()` reports issues that the additive repairs cannot fix. Take a backup first.

### db.repair_storage()

Quarantines unreadable SSTables across the current graph's stores so the graph can serve its remaining data. Returns the post-repair `storage_health` report — `quarantined` lists what was moved aside (and is no longer queryable).

```gql
RETURN db.repair_storage()
```

If the engine determines an SSTable is **blocked** (environmental — file lock, permission, etc.) rather than corrupt, the call refuses with an error rather than quarantining healthy data. Resolve the environment issue and re-run.

### db.delete_orphans_edges()

Deletes every edge whose endpoint nodes don't resolve. Returns per-label deletion counts. Pair with the `orphan_edges` check in `db.validate_graph()`.

```gql
RETURN db.delete_orphans_edges()
```

## Typical Workflow

1. **Symptom**: counts disagree, `MATCH (n:Label)` misses rows, or a query fails on a restart.
2. `RETURN db.validate_graph()`: read which check(s) report drift.
3. Apply the matching additive repair from the table above; re-run `db.validate_graph()` to confirm `status = clean`.
4. If anomalies remain, run `RETURN db.storage_health()`. If `degraded`, take a backup, then decide whether `db.repair_storage()` is appropriate based on the `reason` fields.
5. Use the destructive repairs (`db.repair_storage()`, `db.delete_orphans_edges()`) only when the additive path cannot fix the issue and a backup is in hand.
