# Lakehouse Reference

## Overview

This page describes Parquet-backed lake graphs declared with `CREATE GRAPH ... WITH LAKE MAPPING`. For a runnable example, start with <a href="/docs/gql/lakehouse-graphs">Lakehouse Graphs</a>.

**Recommended version:** GQLDB **6.2.157 or later**. The examples and behavior in this reference were verified with 6.2.157. This is the verification baseline, not the version in which every feature first appeared.

Lake graphs read source files in place and are read-only. Their declarations, identifiers, and caches are maintained by GQLDB; the source files are never updated by GQL statements. Native writable graphs can coexist in the same database.

## Source Formats and Deployment

The standard lake mapping reads **Parquet files through the server filesystem**. Local disks and mounted filesystems must be readable by the account running GQLDB. A client-side file path, S3 URI, or browser upload is not a substitute for a server-visible filesystem path.

Do not point file globs at the raw data files of a Delta Lake or Apache Iceberg table. Those formats use transaction metadata to determine which files and deletes belong to the active snapshot. The Parquet backend refuses recognized managed-table layouts; use a separately exported Parquet snapshot for this interface. SQL-backed lake engines and optional DuckDB acceleration are separate build/deployment capabilities, not implied by a standard Parquet mapping.

## Operator Configuration

Lake declarations are disabled until an operator configures allowed roots:

```bash
ultipa-gqldb -db ./my.gdb -port 60061 -rbac -admin-pass myPassword -lake-allowed-roots /srv/lake,/mnt/warehouse
```

The equivalent YAML setting is:

```yaml
database:
  path: ./my.gdb
  lake_allowed_roots:
    - /srv/lake
    - /mnt/warehouse
```

Use the `database.lake_allowed_roots` YAML setting or the `-lake-allowed-roots` CLI flag. CLI roots are comma-separated. Allowed roots cover the mapping file, its data root, and the matched files. Symlinks are checked by their resolved paths.

Roots are host configuration and are not carried in database backups. If a recorded declaration cannot open under the current configuration, the database still opens and lists that graph as unavailable. See [Recovery](#Recovery).

## Permissions

With RBAC enabled:

| Operation | Required permission |
| -- | -- |
| Declare a lake graph | `CREATE_GRAPH` plus `DECLARE_LAKE_GRAPH` at database scope for the separate declaration right |
| Query rows | `READ` on the graph |
| Enable or manage compute | `MANAGE_COMPUTE` on the graph |
| Call `DB.REFRESH_LAKE_GRAPH` or its alias | `ALTER_GRAPH` at database scope |
| Drop the declaration | `DROP_GRAPH` on the graph |
| Back up or restore the database | `BACKUP` or `RESTORE` at database scope |

Example grants to an existing role:

```gql
GRANT CREATE_GRAPH ON DATABASE TO ROLE lake_author
GRANT DECLARE_LAKE_GRAPH ON DATABASE TO ROLE lake_author
GRANT READ ON GRAPH social TO ROLE lake_author
GRANT MANAGE_COMPUTE ON GRAPH social TO ROLE lake_author
GRANT ALTER_GRAPH ON DATABASE TO ROLE lake_author
```

`ALL_SCHEMA` does not include `DECLARE_LAKE_GRAPH`. An administrator or a holder of the declaration right must grant it. Declaration alone does not grant permission to query the graph.

Allowed roots are shared host policy, not a separate directory boundary for each user. Grant declaration and read rights only to accounts permitted to read the data under those roots. See <a href="/docs/rbac/grant-revoke-permissions">Grant & Revoke Permissions</a> for scope rules.

## Mapping File

The mapping is a JSON document on the server. Example:

```json
{
  "root": ".",
  "dangling": "error",
  "refresh_interval": "5m",
  "cached_rows": 1048576,
  "nodes": [
    {
      "files": "people/*.parquet",
      "id_column": "person_id",
      "label": "Person",
      "properties": ["name", "city"]
    }
  ],
  "edges": [
    {
      "files": "knows/*.parquet",
      "from_column": "src",
      "to_column": "dst",
      "label": "KNOWS",
      "properties": ["amount"]
    }
  ]
}
```

### Top-Level Fields

| Field | Required / default | Meaning |
| -- | -- | -- |
| `nodes` | Required; at least one source | Array of node sources. Ids must be unique across all sources. |
| `edges` | Optional | Array of edge sources; omit for a node-only graph. |
| `root` | Mapping file's directory | Base for relative file patterns. A relative value is resolved against the mapping file's directory, not the server's working directory. |
| `dangling` | `skip` | Policy for edges whose endpoints are absent: `skip`, `error`, or `retry`. |
| `refresh_interval` | Empty / omitted: manual refresh | Automatic refresh cadence, such as `30s`, `5m`, or `1h`; minimum `1s`. |
| `cached_rows` | `0` / omitted: automatic sizing | Bound for decoded node-row caching, measured in rows rather than bytes. |

Unknown JSON fields are rejected. Operator roots, access deadlines, and accelerator selection are not mapping-file fields; a mapping cannot widen its own access policy.

### Node Sources

| Field | Required | Meaning |
| -- | -- | -- |
| `files` | Yes | Filesystem glob for Parquet files, relative to `root` unless absolute. |
| `id_column` | Yes | External node identifier, exposed as `_id`. |
| `label` | At least one of `label` / `label_column` | Constant label for the source, or fallback when a row's label column is null or empty. |
| `label_column` | No | Column containing a label for each row. |
| `properties` | No | Columns exposed as properties. Omitted or empty means all non-structural columns. |

The node id and label columns are structural, so they are not exposed as ordinary properties, even if included in `properties`. Use `_id` to access the identifier.

### Edge Sources

| Field | Required | Meaning |
| -- | -- | -- |
| `files` | Yes | Filesystem glob for the edge Parquet files. |
| `from_column` | Yes | Source endpoint id, matched against node ids. |
| `to_column` | Yes | Destination endpoint id, matched against node ids. |
| `label` | At least one of `label` / `label_column` | Constant edge label or fallback label. |
| `label_column` | No | Column containing the edge label for each row. |
| `properties` | No | Columns exposed as edge properties; omitted or empty includes non-structural columns. |
| `id_column` | No | Optional source edge-id column accepted by the mapping reader. It does **not** enable GQL edge `_id` access in the 6.2.157 Parquet graph. |

Endpoint, label, and configured id columns are structural. Return edge properties or paths; `e._id` and `id(e)` are refused because user-facing `EDGE_ID` is not enabled for this graph kind.

### Multiple Sources and Per-Row Labels

A mapping can combine several node and edge sources. For example, add separate `Person` and `Company` node sources, then map an `EMPLOYED_BY` edge source between them. Node ids must remain globally unique: prefix ids by entity type if different tables reuse the same local keys, and export matching endpoint ids.

Use `label_column` for a table containing more than one entity type:

```json
{
  "nodes": [
    {
      "files": "entities/*.parquet",
      "id_column": "entity_id",
      "label_column": "entity_type",
      "label": "Entity",
      "properties": ["name"]
    }
  ]
}
```

Here a row with `entity_type = "Customer"` becomes a `Customer` node; a null or empty `entity_type` uses `Entity`. The same fallback rule applies to edge labels.

Avoid overlapping globs and repeated source rows. Each node id must identify one node across the entire mapping. Edge rows are distinct relationships; do not assume duplicate rows are deduplicated.

## Identifiers and Data Types

Node ids are keys, not row positions. Values are rendered as identifiers consistently with their source type. An integer `1` and a string `"001"` do not identify the same endpoint. Use stable, non-empty identifiers. Null ids and duplicate node ids are refused.

Use flat scalar columns for the documented mapping. Do not assume nested structs, repeated/list fields, arbitrary binary encodings, or every Parquet logical annotation becomes a corresponding GQL value.

| Parquet value | GQL value / behavior |
| -- | -- |
| Boolean | Boolean |
| Signed `INT32` / `INT64` | Integer |
| `FLOAT` / `DOUBLE` | Floating-point value |
| String / byte-array scalar without a recognized logical annotation | String conversion; do not treat this as a general binary-object interface |
| `DATE` | Date |
| `TIME` in milliseconds or microseconds | Time |
| `TIMESTAMP` in milliseconds, microseconds, or nanoseconds | Date-time, decoded in UTC; original display timezone is not retained |
| Legacy `INT96` timestamp | Date-time |
| `DECIMAL` | Decimal value preserving the scaled decimal representation |
| Unsigned integer | Non-negative integer when representable; unsigned 64-bit values above the signed range become exact decimal values |
| Null property | Absent property; accessing it yields null |

Maintain consistent column types and identifier representations across partitions. Property selection limits what queries expose and what caches need to read; choose only the columns used by the workload.

## Query Support

First select the graph with `USE GRAPH social`. Simple scans can run immediately. To enable the topology for neighborhood traversal and algorithms:

```gql
ALTER GRAPH social SET COMPUTE ENABLED
SHOW COMPUTE STATUS ON GRAPH social
```

Wait for `READY`; enablement starts a background build. A successful `ALTER GRAPH` response does not mean the topology is already ready.

| Query shape | Without compute | With ready compute |
| -- | -- | -- |
| Node scans, property reads, aggregates | Supported | Supported |
| Full edge scans with unbound endpoints; edge counts / properties | Supported | Supported |
| Simple path counting that can be answered by an edge scan | Supported | Supported |
| Neighborhood expansion from a bound node using a supported edge label | Refused | Supported |
| Labeled variable-length paths and quantified groups served by the topology | Refused | Supported |
| Edge and path variables, `nodes(p)`, `relationships(p)`, `length(p)` on supported traversal shapes | Refused when expansion is required | Supported |
| Ordinary edge-property filters on supported labeled traversal shapes | Refused when expansion is required | Supported, with source property reads |
| `SHORTEST`, `ALL SHORTEST`, `SHORTEST k GROUPS`, `ANY` on supported shapes | Refused | Supported |
| Single-segment shortest search whose edge pattern filters on edge properties | Refused | Refused |
| `CHEAPEST`, with or without `COST` | Refused | Refused |
| Expansion that the topology does not serve, such as certain edge-label alternations or mixed fixed/variable paths under restrictive path modes | Refused | Refused with a capability error |

`TRAIL` (default), `WALK`, `ACYCLIC`, and `SIMPLE` work for supported topology paths. Their availability does not make every combination of labels, segments, and filters supported. A lake graph has no per-node adjacency index to use as a fallback when a pattern cannot use the topology.

Examples using the beginner guide's dataset:

```gql
MATCH (n:Person) RETURN n.name ORDER BY n.name
```

```gql
MATCH (a:Person {_id: 'a'})-[e:KNOWS WHERE e.amount > 5]->(b:Person)
RETURN b.name, e.amount
```

```gql
MATCH p = ALL SHORTEST (a:Person {_id: 'a'})-[:KNOWS]->{1,3}(b:Person {_id: 'c'})
RETURN p, length(p)
```

Returning paths or nodes allows <a href="/docs/tools/manager">Manager</a> to render a graph view. Returning scalar properties or counts produces table values.

Aggregates use the same GQL result types whether scanned or accelerated. Optional source acceleration depends on the build and query shape; it is not a mapping setting and is not guaranteed by enabling compute.

## Algorithms

Read-only, unweighted algorithms that use the compute topology can run once it is ready. Verified examples include PageRank, Louvain, WCC, and `khop_fast`:

```gql
CALL algo.pagerank({}) YIELD nodeId, score
```

```gql
CALL algo.khop_fast({startNode: 'a', maxHops: 2}) YIELD count, hops
```

A `weight` parameter requires storage capabilities the Parquet graph does not provide and is refused. Algorithm `.write` modes are also refused because the graph is read-only. Do not assume every algorithm in the catalog supports lake graphs; algorithms needing a different storage capability can be refused even when compute is ready.

See <a href="/docs/graph-algorithms/introduction">Graph Algorithms</a> for individual parameter references.

## Manual Refresh

Publish complete new Parquet partitions under **new filenames**, then run:

```gql
RETURN DB.REFRESH_LAKE_GRAPH('social') AS r
```

`REFRESH_LAKE_GRAPH` is an unqualified alias. Project a field when convenient:

```gql
RETURN DB.REFRESH_LAKE_GRAPH('social').computeApplied
```

Refresh discovers new matches and applies their rows. It does not replace an already loaded partition in place. A successful refresh does not require a server restart.

| Result field | Meaning |
| -- | -- |
| `status` | `success`, `success_with_missing_files`, or `reopened`; failures can raise a query error instead of returning a map |
| `graphName` | Target graph |
| `warnings` | Conditions requiring attention, including missing sources |
| `inventory` | Observed source-pattern matches; see below |
| `newNodes`, `newEdges` | Source rows taken on in this refresh |
| `nodeFiles`, `edgeFiles` | Newly discovered files taken on |
| `resolved`, `dangling`, `retried` | Edge-resolution outcomes, including retained edges retried after endpoints arrive |
| `pendingEdges` | Remaining backlog under the retry policy |
| `missingFiles` | Previously loaded sources no longer present in the observed file set |
| `computeApplied` | Whether this refresh reached the compute topology |
| `nodesApplied`, `edgesApplied` | Rows applied to compute; distinct from source-row discovery |
| `rebuildRequired` | Whether a topology rebuild is needed before new rows can be traversed |
| `computeNote` | Additional compute explanation when supplied |

Each `inventory` entry contains `source` (such as `nodes[0]`), `pattern`, `matched`, `files` (up to the last 20 sorted names), and `omittedFiles`. Compare it with the partitions expected from your publishing job. Network mount caches can delay what a filesystem listing reveals.

A successful reopen has a smaller result containing `status: reopened`, `graphName`, and `warnings`; do not require ordinary refresh counters on that path. Check compute status again after recovery.

### Dangling Edges

| Policy | Behavior |
| -- | -- |
| `skip` | Skip edges whose endpoint ids cannot be resolved; no retry backlog is kept. |
| `error` | Fail endpoint loading, for example during a compute build, when an endpoint cannot be resolved. Declaration and ordinary scans do not necessarily validate every endpoint; inspect build status and errors. |
| `retry` | Retain unresolved edges and retry them on later refreshes when endpoint rows arrive. Watch `pendingEdges` and `retried`. |

For staggered node and edge delivery, `retry` avoids permanently discarding edges before their endpoints arrive. A growing backlog can also indicate an id-format mismatch. Check the source ids before treating every unresolved edge as a late partition.

**Verified limitation in 6.2.157:** scans of unresolved edges can queue the same retry more than once, including scans performed during a compute build without an explicit user scan. When the endpoint arrives, a later refresh can expose duplicate relationships. Do not rely on `retry` for exactly-once edge delivery in this release. For workloads requiring duplicate-free results, publish all referenced nodes before their edge partitions and use `error` or `skip` as appropriate; validate endpoint-resolved results as well as source counts.

**Counts and topology builds:** in 6.2.157, bare edge counts and catalog counts can use Parquet source-row metadata, including rows whose endpoints do not resolve. They are not a count of successfully traversable relationships. Check endpoint-resolved queries, refresh results, and compute status as well. If source edge rows exist but none resolve, the topology build can fail its empty-topology check. Inspect `buildError`, correct the missing or mismatched endpoints, refresh, and rebuild after valid edges are available.

### Source Changes and Missing Files

Loaded partitions are expected to be immutable. A refresh refuses detected changes to a loaded file, including changes in size or modification time. To replace a dataset, pause queries, publish a consistent replacement snapshot, and reopen or recreate its declaration under a controlled maintenance procedure; ordinary refresh is for new partitions. Afterward, rebuild compute and verify counts and representative paths.

Missing loaded files produce `success_with_missing_files`, a warning, and `missingFiles`. Already loaded rows are not automatically removed or renumbered. On filesystems retaining open handles, they can remain readable, so a returned count is not proof that all source files are still present.

Publish files atomically where the filesystem permits it: finish writing a file outside the matching glob, then move it into place. Do not let a refresh discover a half-written Parquet file.

## Automatic Refresh

Add a cadence to the mapping **before declaring or reopening the graph**:

```json
{
  "root": ".",
  "refresh_interval": "5m",
  "nodes": [{"files": "people/*.parquet", "id_column": "person_id", "label": "Person"}],
  "edges": [{"files": "knows/*.parquet", "from_column": "src", "to_column": "dst", "label": "KNOWS"}]
}
```

Accepted duration examples are `30s`, `5m`, and `1h`. The minimum is `1s`; invalid durations and sub-second intervals are refused. Empty or omitted means manual refresh only.

The scheduler uses the same refresh path, including updates to a ready compute topology. The mapping's cadence survives restart. Editing the JSON file is not a live configuration API: reopen the graph to load mapping changes. The interval is a cadence, not a promise that a refresh will finish within that time; I/O and data volume affect completion.

Scheduled failures, missing-source warnings, added rows, and recovery are reported in server logs. Repeated failures back off rather than retrying continuously. Use manual refresh when you need the full status and inventory map for diagnostics.

## Catalog and Restart Behavior

Declarations persist in the database directory. `SHOW GRAPHS` and `DESCRIBE GRAPH social` expose graph identity, creation time, counts, and availability; `SHOW NODE LABELS` / `SHOW EDGE LABELS` expose mapped labels.

Compute enablement also persists, but the ready topology does not. After reopening an enabled lake graph, rebuild and inspect its state:

```gql
ALTER GRAPH social SET COMPUTE REBUILD
SHOW COMPUTE STATUS ON GRAPH social
```

Wait for `READY` before traversal. **Verified limitation in 6.2.157:** `SET COMPUTE AUTOLOAD ON` builds the lake topology for the current process, but its autoload setting is not retained for this graph kind across restart. Do not rely on it to rebuild a lake graph automatically; include `REBUILD` and a readiness check in your startup procedure. This does not prevent the mapping's refresh schedule from being restored.

Identifier caches can reduce repeated startup work, but a restart can still read source metadata and rebuild compute state. Keep mapping and data paths stable, and provision memory for building the topology as well as steady-state queries.

## Recovery

An inaccessible recorded mapping or source does not stop other graphs from opening. `SHOW GRAPHS` lists the declaration with `status = UNAVAILABLE`, `status_reason`, and null counts. Null means unavailable, not empty. Selecting it is refused with the reason.

1. Restore the mapping or source, reconnect the mount, or correct allowed roots and restart with the corrected configuration.
2. Retry the declaration:

```gql
RETURN DB.REFRESH_LAKE_GRAPH('social') AS r
```

3. Check for `status: reopened`, select the graph, and inspect compute readiness.

To forget an unwanted declaration, select another graph and drop it:

```gql
USE GRAPH default
DROP GRAPH social
```

This removes the declaration, not the mapping or source Parquet files. Lake graph rename is refused; manage the declaration explicitly rather than renaming it onto another graph.

Permission, I/O, and timeout failures are reported as access failures rather than empty matches. Filesystem access deadlines are not a total deadline for a full graph open: a large id scan can take longer. Mount directory caches can hide newly added or deleted files until they expire.

During database restore, lake graph operations can be refused while declarations are being replaced. Wait for restore completion, then inspect availability before retrying.

## Backup and Restore

A database backup preserves lake declarations, **not the external mapping file contents or Parquet data**. Preserve both separately. The destination host must have the recorded paths and sufficient allowed roots.

`RESTORE DATABASE` reopens restored declarations immediately; no restart is required. Its `lake_graphs` result maps each restored name to `READY` or `UNAVAILABLE`. `graph_count` counts archived native graphs, including the system graph, rather than lake declarations. Check the returned map and `SHOW GRAPHS`.

Use database backup for declarations; do not treat a graph-level backup as a Parquet export. See <a href="/docs/operations/backup-restore">Backup & Restore</a> for command syntax.

## Read-Only Restrictions

| Operation | Lake graph behavior |
| -- | -- |
| `INSERT`, `SET`, `REMOVE`, `DELETE`, `DETACH DELETE`, `MERGE`, `TRUNCATE GRAPH` | Refused; change source partitions instead |
| Explicit transactions such as `START TRANSACTION` | Refused for the lake graph |
| Regular, full-text, and vector index creation; constraints and triggers | Refused; import into a native graph if these are required |
| Algorithm `.write` modes | Refused |
| Rename a lake graph | Refused |
| `DROP GRAPH` | Removes the declaration; never deletes source files |

## Memory and Performance

Memory depends on node identifiers, nodes and edges in the compute topology, loaded property columns, and caches. Large topology builds can peak above steady-state usage. Do not size only from Parquet file size or node count.

`cached_rows` controls decoded node-row caching; `0` selects automatic sizing that scales with graph size within implementation limits. It is not a total memory limit. Smaller caches can cause scattered reads to repeatedly decode Parquet blocks. Explicit `properties` lists reduce the columns read and cached.

Sequential scans and topology traversal have different costs from random property lookups. Edge-property filters can read source rows even when traversal uses compute. Measure against the intended disk or network mount; no latency guarantee follows from a small local example.

For broader compute sizing and status fields, see <a href="/docs/computing-engine/memory-management">Memory Management</a> and <a href="/docs/computing-engine/monitoring">Monitoring</a>.

## Licensing and Compatibility

Lake graphs take no license graph slot, and their rows do not count toward licensed node or edge limits. Native graphs in the same database remain subject to the normal limits. Resource usage and the edition's terms still apply; quota exclusion does not grant additional deployment rights.

**Do not roll a database containing lake declarations back below 6.2.143.** Those binaries do not recognize the declaration catalog and can silently omit lake graphs. Preserve database backups and external mapping/data files before changing versions. Use the recommended baseline for the documented permission, recovery, and refresh behavior.

## Troubleshooting

| Symptom | Check / action |
| -- | -- |
| Declaration is disabled | Configure allowed roots on the server and restart with that configuration. |
| Permission denied during declaration | Grant both `CREATE_GRAPH` and database-level `DECLARE_LAKE_GRAPH`; check separate `READ` access. |
| Mapping or pattern cannot be read | Check server-side paths, filesystem permissions, roots, and mount availability. |
| Duplicate id error | Make node ids unique across all sources; export consistently prefixed endpoint ids if needed. |
| No resolved edges / growing `pendingEdges` | Compare node ids and endpoint types and check for late node partitions. |
| Traversal refused immediately after enabling compute | Wait for `SHOW COMPUTE STATUS` to report `READY`. |
| Query refused despite ready compute | Compare the exact query shape with [Query Support](#Query-Support); some patterns have no lake execution path. |
| Compute says enabled but `buildState` is `NONE` after restart | Run `ALTER GRAPH social SET COMPUTE REBUILD` and wait for `READY`; see the 6.2.157 autoload limitation above. |
| Refresh says `success_with_missing_files` | Inspect warnings and inventory, then restore the expected immutable source files. |
| Source file changed | Stop in-place rewrites; reopen the graph to load rewritten data under maintenance. |
| Counts update but new paths do not | Inspect `computeApplied`, `rebuildRequired`, `computeNote`, and compute status. |
| Graph is unavailable after restart or restore | Inspect `status_reason`, correct access, then call `DB.REFRESH_LAKE_GRAPH`. |
| Automatic refresh does not see a new partition | Check the loaded cadence, server logs, the glob, mount caching, and whether the partition is fully published. |
