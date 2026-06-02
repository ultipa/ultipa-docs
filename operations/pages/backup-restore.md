# Backup & Restore

GQLDB takes hot backups — the database keeps serving reads and writes throughout. A backup is a single compressed tar archive containing every SST file for the target scope plus a `backup_meta.json` header (WAL sequence, graph name, node/edge counts, timestamp). Both per-graph and whole-database backups are supported.

Two API surfaces are available; pick whichever fits your workflow:

| Surface | When to use |
| -- | -- |
| **Statement form** (`BACKUP …`, `RESTORE …`) | Ad-hoc operator commands, schema-style scripting, anywhere you'd otherwise type GQL. Has the full option surface (incremental, scope, overwrite, verify). |
| **Function form** (`db.backup()`, `db.restore()`, `db.backups()`) | Driver code, automation, composition with `RETURN` pipelines. Subset of the statement form. |

Both write the same on-disk format and use the same internal code path — interchangeable for a basic full backup.

## Graph-Level

### Backing Up a Graph

Use `BACKUP GRAPH` to create a backup of a single graph as a compressed archive.

<p tit="Syntax"></p>

```
<backup graph statement> ::=
  "BACKUP GRAPH" [ <graph name>] "TO" <directory and prefix string>

<directory and prefix> ::=
  <directory> "/" <prefix>
```

**Details**

- `<graph name>` is optional. If omitted, backs up the current graph.
- `<directory>` is the absolute path where the backup file is created on the database host. The directory must already exist.
- The backup file will be named `<prefix>.gqlbackup.tar.gz`.

Back up the current graph to `/data/backups/`, creating the file `default.gqlbackup.tar.gz`:

```gql
BACKUP GRAPH TO "/data/backups/default"
```

Back up a specific graph without switching to it:

```gql
BACKUP GRAPH myGraph TO "/data/backups/myGraph"
```

Returns a single row:

| Field | Description |
| -- | -- |
| `status` | `success` on completion. |
| `type` | `full` or `incremental`. |
| `graph_name` | The graph that was backed up. |
| `path` | Full path to the backup file (with extension). |
| `node_count` | Number of nodes in the backup. |
| `edge_count` | Number of edges in the backup. |
| `size` | Backup file size in bytes. |
| `wal_sequence` | WAL sequence number at backup time. Used by `RESTORE` to know where to resume. |
| `duration_ms` | Backup duration in milliseconds. |
| `timestamp` | When the backup was created. |

The backup is **hot**. The server flushes outstanding writes to disk first (so the archive contains a consistent SST set), then copies SSTs to the archive. New writes that arrive during the copy land in the next WAL window — they are **not** in this backup file. The `wal_sequence` field tells you the exact cutoff.

### Restoring a Graph

Use `RESTORE GRAPH` to restore a graph from a backup archive.

<p tit="Syntax"></p>

```
<restore graph statement> ::=
  "RESTORE GRAPH FROM" <filepath string> [ "OVERWRITE" ]
```

**Details**

- `<filepath string>` is the full path to the backup file, including the `.gqlbackup.tar.gz` extension.
- `OVERWRITE` is optional. With it, the existing graph is dropped atomically and rebuilt from the archive. Without it, the command fails if the target graph already exists.

Restore a graph from a backup:

```gql
RESTORE GRAPH FROM "data/backups/my_backup.gqlbackup.tar.gz"
```

Restore and overwrite an existing graph:

```gql
RESTORE GRAPH FROM "data/backups/my_backup.gqlbackup.tar.gz" OVERWRITE
```

Returns a single row:

| Field | Description |
| -- | -- |
| `status` | `success` on completion. |
| `graph_name` | The graph that was restored. |
| `type` | `full` or `incremental`. |
| `node_count` | Number of nodes restored. |
| `edge_count` | Number of edges restored. |
| `duration_ms` | Restore duration in milliseconds. |
| `timestamp` | When the restore completed. |

Any sessions bound to the graph via `USE GRAPH` see the cutover on their next statement.

### Incremental Backup

Incremental backups capture only the SST files changed since a base (full) backup. They are smaller and faster to create but require the base backup to be available during restoration.

First, create a full backup, then reference it as the base:

```gql
-- Step 1: full backup
BACKUP GRAPH TO "data/backups/full"

-- Step 2: data changes
INSERT (:Person {name: "NewUser"})

-- Step 3: incremental backup referencing the full
BACKUP GRAPH TO "data/backups/incr" INCREMENTAL BASE "data/backups/full.gqlbackup.tar.gz"
```

Incremental backup files use the extension `.gqlbackup.inc.tar.gz`.

Restore the full backup first, then apply the incremental on top:

```gql
-- Step 1: restore the full
RESTORE GRAPH FROM "data/backups/full.gqlbackup.tar.gz" OVERWRITE

-- Step 2: restore the incremental
RESTORE GRAPH FROM "data/backups/incr.gqlbackup.inc.tar.gz" OVERWRITE
```

Missing an incremental in the chain is a fatal error at restore time. A weekly full + daily incremental pattern is the common scheduling shape — small nightly footprint, recovery never further than one full away.

## Database-Level

### Backing Up a Database

Use `BACKUP DATABASE` to back up all graphs at once. The system graph (`__system__`, holding RBAC users / roles) is included.

<p tit="Syntax"></p>

```
<backup database statement> ::=
  "BACKUP DATABASE TO" <directory string>
```

**Details**

- `<directory string>` is the absolute path on the database host. The directory is created automatically if it doesn't exist.

```gql
BACKUP DATABASE TO "data/backups/db_snapshot"
```

This creates a directory with one archive per graph plus database-level metadata:

<p tit="File Structure"></p>

```
data/backups/db_snapshot/
├── <graph1>.gqlbackup.tar.gz   -- per-graph archive
├── <graph2>.gqlbackup.tar.gz
├── meta.json                    -- global database metadata
└── db_backup_meta.json          -- database backup manifest
```

Returns a single row:

| Field | Description |
| -- | -- |
| `status` | `success` on completion. |
| `graph_count` | Number of graphs included. |
| `total_size` | Combined size of all archives in bytes. |
| `duration_ms` | Backup duration in milliseconds. |
| `timestamp` | When the backup was created. |
| `path` | The target directory. |

A whole-database backup is the standard before a major-version upgrade or before a destructive operation like `TRUNCATE GRAPH`.

### Restoring a Database

```
<restore database statement> ::=
  "RESTORE DATABASE FROM" <directory string> [ "OVERWRITE" ]
```

**Details**

- `<directory string>` is the absolute path of the database backup directory.
- `OVERWRITE` replaces all graphs in the running database with the backup's contents. Without it, only graphs not currently present are restored — useful for partial recovery.

```gql
RESTORE DATABASE FROM "data/backups/db_snapshot" OVERWRITE
```

Returns a single row:

| Field | Description |
| -- | -- |
| `status` | `success` on completion. |
| `graph_count` | Number of graphs restored. |
| `duration_ms` | Restore duration in milliseconds. |
| `timestamp` | When the restore completed. |

The system graph is restored atomically with the user graphs, so RBAC state (users, roles, grants) returns to its snapshot moment.

## Managing Backups

### Showing Backups

```gql
SHOW BACKUPS
```

With no arguments, reads from the **internal backup catalog** — the database's own record of every successful and failed backup operation. Each row carries an `id` you can pass to `DROP BACKUP`.

| Field | Description |
| -- | -- |
| `id` | Unique backup ID. |
| `type` | `full` or `incremental`. |
| `scope` | `graph` or `database`. |
| `graph_name` | The source graph name. |
| `path` | Backup file path. |
| `node_count`, `edge_count` | Counts in the backup. |
| `size` | Backup file size in bytes. |
| `wal_sequence` | WAL sequence number at backup time. |
| `duration_ms` | Backup duration in milliseconds. |
| `status` | `completed` or `failed`. |
| `available` | Live check that the file at `path` still exists. Useful for detecting tarballs moved or deleted out of band. |
| `timestamp` | When the backup was created. |

Filter by graph name:

```gql
SHOW BACKUPS FOR GRAPH myGraph
```

Scan a directory on disk instead of the catalog — re-reads each archive's `backup_meta.json` header:

```gql
SHOW BACKUPS FROM "/backups/directory"
SHOW BACKUPS FROM "/backups/directory" FOR GRAPH myGraph
```

Directory-scan form returns a slightly different set (no `id` / `scope` / `status`, plus `compressed`):

| Field | Description |
| -- | -- |
| `type`, `graph_name`, `path` | As above. |
| `node_count`, `edge_count`, `size`, `wal_sequence` | As above. |
| `compressed` | Whether the backup is gzip-compressed. |
| `timestamp` | When the backup was created. |

Directory scan is slower than the catalog but is the truth-source if the catalog and disk have diverged.

### Viewing Backup Details

Retrieve metadata for a specific backup file:

```gql
SHOW BACKUP "data/backups/my_backup.gqlbackup.tar.gz"
```

Returns the same columns as the directory-scan form above, for one file.

### Verifying a Backup

Check that a backup archive is structurally valid before relying on it:

```gql
VERIFY BACKUP "/backups/my_backup.gqlbackup.tar.gz"
```

Returns:

| Field | Description |
| -- | -- |
| `valid` | Whether the backup is structurally valid (`true` or `false`). |
| `graph_name` | The source graph name. |
| `file_count` | Number of files in the backup archive. |
| `total_size` | Total uncompressed size in bytes. |
| `wal_sequence` | WAL sequence number at backup time. |
| `timestamp` | When the backup was created. |
| `errors` | Validation errors, if any (empty when `valid = true`). |

`VERIFY BACKUP` only checks structure (tar headers parse, `backup_meta.json` is present and well-formed, SST headers look sane). It does **not** restore-and-replay — pair it with periodic test restores into a throwaway `-db` directory for body-integrity confidence.

### Removing a Catalog Entry

```gql
DROP BACKUP "<id>"
DROP BACKUP "<id>" IF EXISTS
```

Removes the row from the catalog and best-effort deletes the underlying tar.gz. If another catalog row references the same `path` (e.g., a renamed copy), the file is kept and `file_deleted = false` is returned. `IF EXISTS` turns "id not found" from an error into an empty result.

## Function Form

For driver code and automation where you'd rather not parse statement results:

```gql
RETURN db.backup("data/backups/myGraph")
RETURN db.backup("data/backups/myGraph", {compress: true})
RETURN db.backup("data/backups/myGraph", {incremental: true})

RETURN db.restore("data/backups/myGraph.gqlbackup.tar.gz")
RETURN db.restore("data/backups/myGraph.gqlbackup.tar.gz", {overwrite: true})

RETURN db.backups("data/backups")
```

| Function | Returns | Notes |
| -- | -- | -- |
| `db.backup(path, opts?)` | Map | Backs up the **current** graph. `opts.compress` (Bool, default `true`), `opts.incremental` (Bool, default `false`). No `BASE` argument for incremental in the function form — use the statement. |
| `db.restore(path, opts?)` | Map | `opts.overwrite` (Bool, default `false`). |
| `db.backups(dirPath)` | List<Map> | Directory scan, equivalent to `SHOW BACKUPS FROM "<dir>"`. |

Return maps for `db.backup()` and `db.restore()`:

- `db.backup()` → `status`, `path`, `type`, `graphName`, `nodeCount`, `edgeCount`, `size`, `walSequence`, `timestamp`, `compressed`.
- `db.restore()` → `status`, `graphName`, `nodeCount`, `edgeCount`, `type`, `timestamp`.
- `db.backups()` → list of maps with `path`, `type`, `graphName`, `nodeCount`, `edgeCount`, `size`, `walSequence`, `timestamp`, `compressed`.

The function form skips per-graph / whole-database scope distinctions and `INCREMENTAL BASE` available in the statement form. Reach for it when you're already in a fluent `RETURN`-style API and don't need the extras.

## What Gets Backed Up

A full backup archives the entire graph directory, so all on-disk state is preserved:

- Nodes, edges, labels, and their properties.
- Property indexes, full-text indexes, vector indexes.
- Stored procedures, constraints, triggers, projections, and ontology definitions (stored in graph metadata).

After restore, in-memory managers and caches are reinitialized from the restored on-disk files:

- The full-text index manager is initialized in the background — searches wait until it finishes loading.
- The node ID cache (and the edge ID cache, when `EDGE_ID` is enabled) is rebuilt from the restored data.

The following are **not** in the backup:

- The computing engine topology cache. After restore, re-enable it with `ALTER GRAPH <name> SET COMPUTE ENABLED` if needed.
- The backup catalog (`backup_catalog.json`) itself. The catalog is per-database, not per-graph.

## Permissions

| Statement / function | Required RBAC operation |
| -- | -- |
| `BACKUP GRAPH`, `BACKUP DATABASE`, `db.backup()`, `DROP BACKUP` | `OpBackup` |
| `RESTORE GRAPH`, `RESTORE DATABASE`, `db.restore()` | `OpRestore` |
| `SHOW BACKUPS`, `SHOW BACKUP`, `VERIFY BACKUP`, `db.backups()` | `OpShowSchema` |

Grant via RBAC; see <a href="/docs/rbac" target="_blank">Access Control</a> for role wiring.

## File Extensions & Format

| Type | Extension |
| -- | -- |
| Full graph backup | `.gqlbackup.tar.gz` |
| Incremental backup | `.gqlbackup.inc.tar.gz` |

> Do not include the extension when specifying the destination path in `BACKUP GRAPH` or `db.backup()` — it is added automatically.

Internal format details:

| Aspect | Detail |
| -- | -- |
| **Container** | `tar.gz` (gzip by default; `opts.compress = false` produces a plain tar). |
| **First entry** | `backup_meta.json` — backup format version, GQLDB version, type (`full`/`incremental`), scope (`graph`/`database`), graph name, WAL sequence, node/edge counts, optional `base_backup` path for incrementals. |
| **Body** | The SST files and metadata sidecars for the source graph. |

The format is forward-compatible across patch releases. Across minor versions, a backup taken on `1.x` restores cleanly on `1.y`; the engine may run a one-shot migration on first read of older SSTs (transparent to callers — see <a href="/docs/operations/database-installation#updating" target="_blank">Installation → Updating</a>).

## Operational Patterns

- **Pre-upgrade snapshot.** Take a `BACKUP DATABASE` immediately before a server upgrade. Restoring is the cleanest rollback path if the new version misbehaves.
- **Nightly full + hourly incremental.** Schedule the cron equivalent in your runner of choice. Keep at least 7 days of fulls so an incremental chain corruption is recoverable from yesterday's full.
- **Off-host copy.** The tar.gz is portable — copy it to S3 / object storage / another host immediately after creation. The backup doesn't protect against the host going away.
- **Verify what you keep.** `VERIFY BACKUP` confirms each archive's header parses. Pair it with periodic test restores into a throwaway `-db` directory to confirm the body is intact, not just the header.
- **`SHOW BACKUPS` and `available`.** Catalog-form `SHOW BACKUPS` carries an `available` column that re-checks whether the file at `path` still exists. Treat it as the periodic reality check that your retention script isn't deleting files out from under the catalog.

## Important Notes

- The backup is hot — you can keep reading and writing while it runs. Pending writes are flushed before the archive is created, so the result is never half-written.
- Backup files are self-contained and portable. The original database can be safely removed after a backup is created.
- Restored data, including all metadata (indexes, procedures, constraints), persists across database restarts.
- `OVERWRITE` replaces the entire graph with the backup contents. Without it, the restore fails if the target graph already exists.
- All paths used in backup and restore commands are **absolute** filesystem paths on the **server**. They are used as-is with no default directory. The parent directory must already exist.
- Incremental backups require the base full backup to be available during restoration.

## What's Not Here

- **Point-in-time recovery (PITR).** GQLDB does not yet support replay from arbitrary timestamps; the recovery unit is a backup file's WAL cutoff. For tighter RPO, increase backup frequency.
- **HA failover as a backup substitute.** HA protects against host failure within the quorum; it does **not** protect against logical corruption, an accidental `TRUNCATE`, or operator error. Always keep offline backups even in a 3-node cluster. See <a href="/docs/operations/clustering" target="_blank">Clustering</a>.
- **WAL archiving.** The WAL is internal; there is no public consumer-side WAL archive API at this time.
