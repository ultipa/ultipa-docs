# Lakehouse Graphs

## Overview

This guide describes the Lakehouse behavior verified with GQLDB **6.2.157**. Use that release or a newer supported version for the recovery, permission, and refresh behavior described here.

A **lakehouse graph** is a graph you query without loading it. Instead of copying data into the database, you point GQLDB at files that already exist — Parquet files in a data lake — and declare which columns are nodes, which are edges, and how they join. The database reads those files where they are.

The usual path into GQLDB is ETL: the data is copied out of wherever it lives, written into storage, and the compute engine is built on that copy. For a lakehouse workload that is three costs — double storage, ingest time, and a second copy to keep in sync. The third is the one that decides usability, because industrial lakes are appended to daily, and a graph that needs a full re-ingest every morning is competing with running Spark over the same files.

A lakehouse graph removes the data copy and supports GQL node and path queries, subject to the read-only and compute requirements below.

Source properties remain in Parquet files and are read as needed. The database keeps identifiers, caches, and the compute topology in memory. Memory depends on both nodes and edges, enabled compute features, and cached properties; allow headroom for building the topology.

This guide covers Parquet files accessible through the server filesystem. It does not describe native Delta Lake or Apache Iceberg transaction-log integration.

> **A lake graph is read-only, and nothing is ever written into the lake.** Caches and catalogs live in the database's own directory. Writing statements are refused on a lake graph.

A single database can hold both kinds of graph at once, on the same connection:

```gql
CREATE GRAPH native                -- ordinary, writable
USE GRAPH lakegraph                -- Parquet-backed, read-only
```

## Allowed Roots Are Operator Configuration

`CREATE GRAPH … WITH LAKE MAPPING` is **refused until an operator allows it**, and the refusal says so. The statement has the *server* open a path chosen by whoever wrote the query, and then read whatever file patterns the mapping at that path names. On a shared deployment those are not the same person, so an unbounded version of this would be a file-read primitive.

An operator names the directories a mapping may read, with the `lake_allowed_roots` configuration key or `-lake-allowed-roots` on the command line (comma-separated). **It is empty by default, which refuses every declaration** — that is the deliberate default, not a misconfiguration.

The bound applies to three things: the mapping file itself, the mapping's `root`, and every file pattern it names. Paths are judged by where they **resolve**, so a symlink planted inside an allowed directory is not a way out of it.

> **Who may declare one.** With RBAC enabled, declaration needs `CREATE_GRAPH` and the separate **database-level `DECLARE_LAKE_GRAPH`** right. Querying the graph also requires `READ`. `ALL_SCHEMA` does not include `DECLARE_LAKE_GRAPH`. Grant declaration privileges only to users permitted to read data throughout the configured allowed roots; roots are shared host policy, not per-user isolation.

An administrator can grant the separate right to an existing role:

```gql
GRANT DECLARE_LAKE_GRAPH ON DATABASE TO ROLE lake_author
```

The same role must also have `CREATE_GRAPH`, and the querying user needs `READ` on the graph. Enabling compute requires `MANAGE_COMPUTE`; refreshing requires `ALTER_GRAPH` at database scope.

Start a server with an allowed directory, for example:

```bash
ultipa-gqldb -db ./my.gdb -port 60061 -rbac -admin-pass myPassword -lake-allowed-roots /srv/lake
```

In a YAML config file, the equivalent setting is `database.lake_allowed_roots`:

```yaml
database:
  path: ./my.gdb
  lake_allowed_roots:
    - /srv/lake
```

This is host policy and is not stored with the database. If a declaration cannot be opened under the current roots, **the database still opens and lists the affected graph as `UNAVAILABLE`**, with a reason. Other graphs remain usable. Keep allowed roots consistent across hosts, or restore access and retry the affected graph as described under [Recovery](#Recovery).

## Declaring a Lake Graph

```gql
CREATE GRAPH social WITH LAKE MAPPING '/srv/lake/social.json'
USE GRAPH social
ALTER GRAPH social SET COMPUTE ENABLED
SHOW COMPUTE STATUS ON GRAPH social
-- Wait until the topology reports READY before running traversal.
MATCH (a:Person)-[:KNOWS]->(b:Person) RETURN a._id, b._id
```

The mapping and Parquet paths are on the **server**, not the client running the query. In the example below, save the mapping as `/srv/lake/social.json`, put node files under `/srv/lake/people/` and edge files under `/srv/lake/knows/`, and allow `/srv/lake` before declaring the graph. `root: "."` resolves relative to the mapping file's directory.

## The Mapping File

```json
{
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
      "label": "KNOWS"
    }
  ],
  "dangling": "skip",
  "root": "."
}
```

| Field | Meaning |
| -- | -- |
| `nodes[].files` | Glob of the files holding the node rows, relative to `root`. |
| `nodes[].id_column` | The column holding the node's external id, which becomes `_id`. |
| `nodes[].label` | The label given to every node from these files. |
| `nodes[].properties` | The columns exposed as properties. |
| `edges[].files` | Glob of the files holding the edge rows. |
| `edges[].from_column` / `to_column` | The columns holding the endpoint ids, matched against node `id_column` values. |
| `edges[].label` | The label given to every edge from these files. |
| `dangling` | What to do with an edge whose endpoint matches no node — `skip` drops it. |
| `root` | The base directory the `files` globs are relative to. |

> **An id is a key whatever its column type is.** An integer surrogate key becomes its decimal rendering, on both sides of an edge. A zero-padded string endpoint column matched against an integer node key produces a graph with **no edges**, all reported as dangling — a common and silent way to end up with an empty graph. Check that both sides render identically before assuming the mapping is wrong elsewhere.

## Traversal Requires the Compute Engine

```gql
ALTER GRAPH social SET COMPUTE ENABLED
```

This is **required before traversal**, and it is design rather than a workaround. A lake graph deliberately keeps no per-node adjacency index in storage: building one would hold the graph's adjacency twice, and answering each hop by scanning would cost O(edges) per question. The compute engine builds that adjacency once, from the same source files.

A traversal issued without it is **refused with the remedy**, not answered with an empty result.

Enabling compute schedules a background build. Check `SHOW COMPUTE STATUS ON GRAPH social` and wait for `READY` before traversal or algorithms. Successful acceptance of `ALTER GRAPH` does not mean that the topology is ready yet.

### Edge Ids

A lake graph has no user-facing edge id: both `e._id` and `id(e)` are refused with an `EDGE_ID` error. Return the edge or a path for query results rather than asking for an edge `_id`.

## Aggregates and Scans

Node and edge scans and counts can be queried without enabling compute. Traversal requires compute. Aggregate acceleration depends on the server build and query shape; do not assume that every filter or aggregate is delegated to a source engine.

## Refreshing After New Data

A lake is appended to. `DB.REFRESH_LAKE_GRAPH` takes on whatever the mapping's patterns match now and did not match when the graph was loaded — **no restart, and the graph stays queryable throughout**:

```gql
RETURN DB.REFRESH_LAKE_GRAPH('social') AS r
```

With two new Parquet files dropped into the lake, on a graph that held 5 nodes and 5 edges:

```
{status: success, graphName: social,
 warnings: [], inventory: [...],
 newNodes: 2, newEdges: 2, nodesApplied: 2, edgesApplied: 2,
 resolved: 2, dangling: 0, retried: 0, pendingEdges: 0,
 nodeFiles: [/tmp/lake/people/p2.parquet], edgeFiles: [/tmp/lake/knows/k2.parquet],
 missingFiles: [], computeApplied: true, rebuildRequired: false}
```

This is an illustrative result; file paths, counts, and inventory depend on your dataset. The graph then answers 7 and 7. `REFRESH_LAKE_GRAPH` is accepted as an unqualified alias, and a single field can be projected directly — `RETURN DB.REFRESH_LAKE_GRAPH('social').computeApplied`.

| Field | Meaning |
| -- | -- |
| `status` | `success` for an ordinary refresh; `success_with_missing_files` if previously loaded sources are missing; `reopened` when an unavailable graph is opened again. Failures can raise a query error rather than return a status map. |
| `warnings` | Refresh warnings, including missing source files. Check these even when new rows were applied. |
| `inventory` | For each source pattern: `source`, `pattern`, `matched`, `files` (up to the last 20 sorted names), and `omittedFiles`. Compare with the partitions you expected to arrive. |
| `newNodes`, `newEdges` | Rows taken on, before dangling filtering. |
| `nodesApplied`, `edgesApplied` | Rows that reached the graph. |
| `resolved`, `dangling`, `retried` | Edges whose endpoints were found; whose endpoints have not arrived; and ones held back by an earlier refresh whose endpoints turned up this time. |
| `pendingEdges` | The backlog still waiting for endpoints. |
| `nodeFiles`, `edgeFiles` | The sources taken on by this refresh. |
| `missingFiles` | Sources loaded once that no longer match the mapping — deleted, moved, or renamed out of the glob. |
| `computeApplied` | Whether the new rows reached the compute topology. |
| `rebuildRequired` | Whether the topology has to be rebuilt before the new rows are traversable. |

Three of those repay attention:

- **A `dangling` count that never falls is usually an id-type mismatch** between the node and edge sources, not missing data. See the note under [The Mapping File](#The-Mapping-File).
- **A growing `pendingEdges` backlog needs investigation.** Check whether endpoint partitions are late and whether node and edge ids match.
- **`missingFiles` names sources that have gone.** Their rows are still served — the internal ids are already handed out and an open descriptor keeps the bytes readable — and the refresh reports `success_with_missing_files` plus a warning. Treat this as a source-data consistency condition, rather than an ordinary success.

Internal ids are append-only: a node that exists keeps its id across a refresh, and a partition discovered later is numbered after everything already loaded, even if its name sorts earlier.

## Recovery

If a mapping is missing, a source cannot be opened, or the configured allowed roots no longer admit the paths, `SHOW GRAPHS` lists the declaration with `status = UNAVAILABLE`, `status_reason`, and null counts. Null means unavailable, not an empty graph. Selecting or querying it is refused with the reason; other graphs stay usable.

After correcting the path, mount, or operator configuration, retry without recreating the declaration:

```gql
RETURN DB.REFRESH_LAKE_GRAPH('social') AS r
```

A successful retry returns `status: reopened`. Enable compute again before traversal if it is not enabled. To remove an unwanted declaration, select another graph and run `DROP GRAPH social`; this removes the declaration without deleting the source Parquet files.

An I/O or permission failure is reported as an access failure, rather than as an empty match. Filesystem operations have time limits, but this is not an overall deadline for opening a large lake graph: reading its data can take longer. Network and object-storage mounts can cache directory listings; `inventory` describes what the server actually saw, not what the remote store may contain now. Refresh again after the mount exposes new partitions.

## Backup and Restore

A database backup carries lake **declarations**, not the source Parquet data or mapping file contents. Preserve the mapping files and source data separately.

In 6.2.157, `RESTORE DATABASE` reopens restored lake declarations immediately. A restart is not required. Its `lake_graphs` result maps each restored lake graph name to `READY` or `UNAVAILABLE`; `graph_count` counts archived native graphs, not lake declarations. Check both the result and `SHOW GRAPHS` before querying restored data.

On the destination host, the mapping and data must be present at the recorded paths and allowed by that host's roots. An inaccessible restored declaration remains listed as unavailable and can be retried after access is corrected.

See <a href="/docs/operations/backup-restore" target="_blank">Backup & Restore</a> for database backup and restore commands.

## Licensing and Version Compatibility

In 6.2.157, lake graphs take **no license graph slot**, and their rows do not count toward licensed node or edge limits. Native graphs in the same database remain subject to their normal limits. Lake graphs still consume server memory, CPU, file handles, and storage for caches and catalogs.

This page uses 6.2.157 as its verified release baseline; it does not assert that every behavior first appeared in that version. **Do not roll a database containing lake declarations back to a version below 6.2.143.** Those older binaries do not recognize the declaration catalog and can silently omit lake graphs. Preserve a backup and the external mapping and data files before changing versions.

## Limits

**A lake graph is read-only.** Statements that modify data are refused on it. Nothing is ever written back into the lake — caches and catalogs live in the database's own directory.

**Property reads depend on the source and cache.** Scattered lookups can require Parquet block reads; measure your workload on its intended filesystem. Large topology builds can use more memory than steady-state queries.

**Path and algorithm variants can need more than the topology.** Weighted and edge-property-filtered workloads may require source property reads or a storage capability the lake graph does not provide. Check the query's error and supported execution path rather than interpreting a refusal as an empty graph.
