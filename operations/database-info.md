# Database Info

Built-in functions for inspecting the running database: version, license, loaded plugins, graph stats, and schema. Call any of them inline with `RETURN`.

## Version & Build

```gql
RETURN db.version()
```

Returns a single string set at build time. Use it as the simplest "is the server up and responding?" check from any driver. Reading it does not require RBAC privileges beyond a successful login.

## License & Tier

```gql
RETURN db.license()
```

Returns a map describing the licensing state actually in effect at runtime — not what was passed at startup, what the enforcer is using.

| Field | Type | Meaning |
| -- | -- | -- |
| `edition` | String | `"Community Edition"` or `"Licensed"`. Reflects whether a real license file was loaded and accepted. |
| `type` | String | License tier: `free` or `paid`. |
| `licenseVersion` | Integer | Schema version of the signed license payload. Currently `1`. |
| `licenseId` | String | License identifier (a UUID for paid licenses). Empty on Community Edition / Free Tier. |
| `customerId`, `customerName` | String | Customer fields from the signed license payload. Empty on Free Tier. |
| `machineFingerprint` | String | The machine fingerprint the license is bound to. Empty on Free Tier. |
| `maxNodes`, `maxEdges` | Integer | Per-graph caps. `1_000_000` (1 million) each on Free Tier; `-1` means unlimited (paid). |
| `maxDatabases` | Integer | Graph count cap. `3` on Free Tier; `-1` means unlimited (paid). |
| `maxCores` | Integer | CPU core cap. `2` on Free Tier; `-1` means unlimited (paid). |
| `issuedAt`, `expiresAt` | Integer (epoch seconds) | License validity window. `expiresAt = -1` means no expiry (Free Tier default). |
| `issuedAtStr`, `expiresAtStr` | String | Human-readable (RFC 3339) mirrors of `issuedAt` / `expiresAt`. `expiresAtStr` is `"Never"` when there is no expiry; `issuedAtStr` is empty on Free Tier. |
| `daysRemaining` | Integer | Whole days until `expiresAt`. `-1` when the license never expires. |
| `expired` | Boolean | `true` if the wall-clock has passed `expiresAt` — the enforcer flips the database to read-only at that point. |
| `readOnly` | Boolean | Whether the enforcer is currently forcing read-only mode (expired license, or cap exceeded). |
| `violations` | Integer | Running count of attempts to exceed a cap since last restart. |

Cross-check the result against `-license-file` at startup: if you passed a path but `edition` still shows Community Edition, the file failed to parse — re-check the path and that the file is the signed `.lic` distributed by Ultipa, not a placeholder.

See <a href="/docs/operations/database-installation#license" target="_blank">Installation → License</a> for the full Free Tier vs Paid Tier comparison.

## Loaded Plugins

```gql
RETURN db.plugins()
```

Returns a list of maps, one per plugin currently loaded into the running process. Each entry includes:

| Field | Type | Meaning |
| -- | -- | -- |
| `name` | String | Plugin name (e.g., `"hanp"`). |
| `namespace` | String | Logical grouping (e.g., `"community"` for the bundled community algorithms). |
| `type` | String | Plugin category — algorithm, procedure, function. |
| `version` | String | Plugin-reported version. |
| `description` | String | Free-text summary. |
| `fullName` | String | Qualified name used in calls (`namespace.name`). |
| `params`, `returns` | List<Map> | Per-parameter and per-return metadata (`name`, `type`, `description`, plus `required` / `default` for params). |

This is the authoritative answer to "is plugin X actually loaded on this server?" Compare against the plugin's expected version before opening a bug — a stale build can look like a logic error.

Empty list means no plugins are loaded; this is normal for a vanilla Community install with no `-plugin-dir` and no built-in registrations enabled.

## Graph Overview

```gql
RETURN db.overview()
```

A two-key map summarizing the current graph's shape:

| Field | Type | Contents |
| -- | -- | -- |
| `labelCounts` | List<Map> | One row per label (`{label, count, type}` where `type` is `"node"` or `"edge"`). |
| `edgePatterns` | List<Map> | One row per distinct `(fromLabel)-[:edgeLabel]->(toLabel)` triple actually observed in the graph, with the matching `edgeCount`. |

`edgePatterns` is computed by scanning every edge and looking up endpoint labels — fast on small graphs, an O(E) hit on large ones. If you only need label counts, use `db.stats()` instead (served from the stats cache, no scan).

## Statistics

```gql
RETURN db.stats()
```

Returns a comprehensive map served from the in-memory statistics cache. No scan, O(1).

| Field | Type | Meaning |
| -- | -- | -- |
| `nodeCount`, `edgeCount` | Integer | Total counts in the current graph. |
| `labelCounts`, `edgeLabelCounts` | Map<String, Integer> | Per-label counts. Keys are label names. |
| `nodePropertyStats`, `edgePropertyStats` | Map<String, Map<String, Integer>> | Per-label property frequency (label → property → count). |
| `unlabeledNodeCount`, `unlabeledEdgeCount` | Integer | Entities with no label assigned. Surfaced separately so an all-unlabeled graph stays distinguishable from an empty one. |
| `unlabeledNodePropertyStats`, `unlabeledEdgePropertyStats` | Map<String, Integer> | Property frequency for the unlabeled bucket. |
| `graphName` | String | The graph this stats payload was computed for (matches `CURRENT_GRAPH`). |
| `statsReady` | Boolean | `false` indicates the cache is in a transient mismatch state — see `statsDiagnostic`. |
| `statsDiagnostic` | String | Present only when `statsReady = false`. Possible values include `stats_nil`, `label_mapping_missing`, `label_counts_empty_but_nodes_present`, `edge_label_counts_empty_but_edges_present`. |

Treat a `statsReady = false` result as a signal to run `db.reload_stats()` (next section), not as bad data — the count fields are still the best available answer, just possibly stale.

## Rebuilding Statistics

```gql
RETURN db.reload_stats()
```

Forces a full rebuild of the stats cache by re-scanning every node and edge in the current graph. Edge-label counts, node-label counts, total counts, self-loop counts, and per-label property stats are all recomputed and atomically swapped in — the next `db.stats()` / `RETURN COUNT(r)` returns the freshly computed values.

`db.rebuild_stats()` and `db.repair_stats()` are aliases for the same function — pick whichever reads best in the context where you call it. 

Cost is O(N + E) — proportional to graph size. Run it after a manual restore or any operation where the stats cache might have diverged from on-disk truth.

### Automatic Rebuild After an Unclean Shutdown

Running `db.reload_stats()` after a crash is no longer necessary. A clean close leaves a marker file, `STATS_EXACT`, in each graph's directory (`<database>/graphs/<id>/`); the next open trusts the saved statistics only if that file is present, and otherwise reads every node and edge once to rebuild them, logging `graph "<name>" was not closed cleanly …` followed by `Statistics rebuilt … in <time>`.

- **The first open after upgrading rebuilds every graph's statistics once**, because earlier versions do not write the marker. This also repairs statistics that an earlier crash left wrong.
- A rebuild costs about as much as reading the whole graph. In our measurements a graph of 1,000,000 nodes and 3,000,000 edges opened in 2.2 s instead of 0.95 s; allow roughly 15 s for 10 million nodes and 23 million edges. A clean restart rebuilds nothing.
- **Do not create, copy or delete `STATS_EXACT` by hand.** A copy of a database directory taken while the database was running carries no marker and is rebuilt when opened, which is what it needs. If an open fails because the file cannot be removed — an unwritable graph directory, for example — fix the permissions or delete the file, and the statistics are rebuilt.

> **After a rebuild, `db.stats()` can list a property that `ALTER NODE|EDGE … DROP PROPERTY` removed.** The drop leaves the values in storage and a rebuild counts them, as `db.reload_stats()` always has.

Returns a small map:

| Field | Type | Meaning |
| -- | -- | -- |
| `success` | Boolean | `true` on a successful rebuild. |
| `message` | String | Human-readable summary (`"Property statistics rebuilt successfully"`). |

## Schema Introspection

```gql
RETURN db.node_labels()
RETURN db.edge_labels()
RETURN db.label_property()
```

| Call | Returns | When to use |
| -- | -- | -- |
| `db.node_labels()` | List<String> | All distinct node labels currently present (served from stats cache). |
| `db.edge_labels()` | List<String> | All distinct edge labels currently present. |
| `db.label_property()` | Map<String, Map> | Per-label schema: `{labelName: {type: "node"\|"edge", properties: [propName, ...]}}`. |

`db.label_property()` returns properties **observed on at least one stored entity** (open graphs) or **declared in schema metadata** (closed / schema-enforced graphs). On a large open graph it has to scan every node and edge — prefer `db.stats()` if you only need counts.
