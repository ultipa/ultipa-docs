# Backup and Restore

Ultipa provides built-in statements and functions for backing up and restoring your graph data. You can back up individual graphs or an entire database, create incremental backups to save space, and verify backup integrity before relying on them.

## Graph-Level

### Backing Up a Graph

Use `BACKUP GRAPH` to create a backup of a single graph as a compressed archive.

<p tit="Syntax"></p>

```
<backup graph statement> ::=
  "BACKUP GRAPH" [ <graph name>]  "TO" <directory and prefix string>

<directory and prefix> ::=
  <directory> "/" <prefix>
```

**Details**

- `<graph name>` is optional. If omitted, backs up the current graph.
- `<directory>` is the absolute path where the backup file is created on the database host. The directory must already exist.
- The backup file will be named as `<prefix>.gqlbackup.tar.gz`.

Back up the current graph to `/data/backups/`, creating the file `default.gqlbackup.tar.gz`:

```gql
BACKUP GRAPH TO "/data/backups/default"
```

Back up a specific graph without switching to it:

```gql
BACKUP GRAPH myGraph TO "/data/backups/myGraph"
```

Returns a single row with the following columns:

| Field | Description |
| -- | -- |
| `status` | `success` on completion. |
| `type` | `full` or `incremental`. |
| `graph_name` | The graph that was backed up. |
| `path` | Full path to the backup file (with extension). |
| `node_count` | Number of nodes in the backup. |
| `edge_count` | Number of edges in the backup. |
| `size` | Backup file size in bytes. |
| `wal_sequence` | WAL sequence number at backup time. |
| `duration_ms` | Backup duration in milliseconds. |
| `timestamp` | When the backup was created. |

### Restoring a Graph

Use `RESTORE GRAPH` to restore a graph from a backup archive.

<p tit="Syntax"></p>

```
<restore graph statement> ::=
  "RESTORE GRAPH FROM" <filepath string> [ "OVERWRITE" ]
```

**Details**

- `<filepath string>` is the full path to the backup file, including the `.gqlbackup.tar.gz` extension.
- The keyword `OVERWRITE` is optional. If specified, replaces the existing graph data. Without it, the command fails if the target graph already exists.

Restore a graph from a backup:

```gql
RESTORE GRAPH FROM "data/backups/my_backup.gqlbackup.tar.gz"
```

Restore and overwrite an existing graph:

```gql
RESTORE GRAPH FROM "data/backups/my_backup.gqlbackup.tar.gz" OVERWRITE
```

Returns a single row with the following columns:

| Field | Description |
| -- | -- |
| `status` | `success` on completion. |
| `graph_name` | The graph that was restored. |
| `type` | `full` or `incremental`. |
| `node_count` | Number of nodes restored. |
| `edge_count` | Number of edges restored. |
| `duration_ms` | Restore duration in milliseconds. |
| `timestamp` | When the restore completed. |

### Incremental Backup

Incremental backups capture only the changes made since a base (full) backup. They are smaller and faster to create, but require the base backup to be available during restoration.

First, create a full backup, then reference it as the base:

```gql
-- Step 1: Create a full backup
BACKUP GRAPH TO "data/backups/full"

-- Step 2: Make data changes
INSERT (:Person {name: "NewUser"})

-- Step 3: Create an incremental backup referencing the full backup
BACKUP GRAPH TO 'data/backups/incr' INCREMENTAL BASE 'data/backups/full.gqlbackup.tar.gz'
```

Incremental backup files use the extension `.gqlbackup.inc.tar.gz`.

Restore the full backup first, then apply the incremental backup on top:

```gql
-- Step 1: Restore the full backup
RESTORE GRAPH FROM 'data/backups/full.gqlbackup.tar.gz' OVERWRITE

-- Step 2: Restore a incremental backup
RESTORE GRAPH FROM 'data/backups/incr.gqlbackup.inc.tar.gz' OVERWRITE
```

## Database-Level

### Backup

Use `BACKUP DATABASE` to back up all graphs in a database at once.

<p tit="Syntax"></p>

```
<backup database statement> ::=
  "BACKUP DATABASE TO" <directory string>
```

**Details**

- `<directory string>` specifies the absolute path on the database host. The directory is created automatically if it doesn't exist.

```gql
BACKUP DATABASE TO 'data/backups/db_snapshot'
```

This creates a directory at the specified path with the following structure:

<p tit="File Structure"></p>

```
data/backups/db_snapshot/
├── <graph1>.gqlbackup.tar.gz   -- backup archive for each graph
├── <graph2>.gqlbackup.tar.gz
├── meta.json                    -- global database metadata
└── db_backup_meta.json          -- database backup manifest
```

Returns a single row with the following columns:

| Field | Description |
| -- | -- |
| `status` | `success` on completion. |
| `graph_count` | Number of graphs included. |
| `total_size` | Combined size of all archives in bytes. |
| `duration_ms` | Backup duration in milliseconds. |
| `timestamp` | When the backup was created. |
| `path` | The target directory. |

### Restore

Use `RESTORE DATABASE` to restore all graphs in a database at once.

<p tit="Syntax"></p>

```
<restore database statement> ::=
  "RESTORE DATABASE FROM" <directory string> [ "OVERWRITE" ]
```

**Details**

- `<directory string>` specifies the absolute path of the database backup directory.
- The keyword `OVERWRITE` is optional. If specified, replaces the existing graph data. Without it, the command fails if any target graph already exists.

```gql
RESTORE DATABASE FROM 'data/backups/db_snapshot' OVERWRITE
```

Returns a single row with the following columns:

| Field | Description |
| -- | -- |
| `status` | `success` on completion. |
| `graph_count` | Number of graphs restored. |
| `duration_ms` | Restore duration in milliseconds. |
| `timestamp` | When the restore completed. |

## Managing Backups

### Showing Backups

Show all entries from the backup catalog:

```gql
SHOW BACKUPS
```

Filter by graph name:

```gql
SHOW BACKUPS FOR GRAPH myGraph
```

Catalog form returns the following columns:

| Field | Description |
| -- | -- |
| `id` | Unique backup ID. |
| `type` | Backup type: `full` or `incremental`. |
| `scope` | Backup scope: `graph` or `database`. |
| `graph_name` | The source graph name. |
| `path` | Backup file path. |
| `node_count` | Number of nodes in the backup. |
| `edge_count` | Number of edges in the backup. |
| `size` | Backup file size in bytes. |
| `wal_sequence` | WAL sequence number at backup time. |
| `duration_ms` | Backup duration in milliseconds. |
| `status` | Backup status: `completed` or `failed`. |
| `timestamp` | When the backup was created. |

Scan a directory for backup files:

```gql
SHOW BACKUPS FROM "/backups/directory"
```

Directory-scan form returns the following columns:

| Field | Description |
| -- | -- |
| `type` | Backup type: `full` or `incremental`. |
| `graph_name` | The source graph name. |
| `path` | Backup file path. |
| `node_count` | Number of nodes in the backup. |
| `edge_count` | Number of edges in the backup. |
| `size` | Backup file size in bytes. |
| `wal_sequence` | WAL sequence number at backup time. |
| `compressed` | Whether the backup is gzip-compressed. |
| `timestamp` | When the backup was created. |

### Viewing Backup Details

Retrieve metadata for a specific backup file:

```gql
SHOW BACKUP "data/backups/my_backup.gqlbackup.tar.gz"
```

Returns a table with the following columns:

| Field | Description |
| -- | -- |
| `type` | Backup type: `full` or `incremental`. |
| `graph_name` | The source graph name. |
| `path` | Backup file path. |
| `node_count` | Number of nodes in the backup. |
| `edge_count` | Number of edges in the backup. |
| `size` | Backup file size in bytes. |
| `wal_sequence` | WAL sequence number at backup time. |
| `compressed` | Whether the backup is compressed. |
| `timestamp` | When the backup was created. |

### Verifying a Backup

Check that a backup archive is structurally valid before relying on it:

```gql
VERIFY BACKUP '/backups/my_backup.gqlbackup.tar.gz'
```

Returns a table with the following columns:

| Field | Description |
| -- | -- |
| `valid` | Whether the backup is structurally valid (`true` or `false`). |
| `graph_name` | The source graph name. |
| `file_count` | Number of files in the backup archive. |
| `total_size` | Total uncompressed size in bytes. |
| `wal_sequence` | WAL sequence number at backup time. |
| `timestamp` | When the backup was created. |
| `errors` | Validation errors, if any (empty string if valid). |

## Backup Functions

As an alternative to the DDL statements above, you can use built-in functions that return backup metadata as map values. These are useful when you need to process backup information programmatically within a query.

### db.backup()

Creates a backup of the current graph.

```gql
-- Basic backup
RETURN db.backup("data/backups/myGraph")

-- With options
RETURN db.backup("data/backups/myGraph", {compress: true})

-- Incremental backup
RETURN db.backup("data/backups/myGraph", {incremental: true})
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `compress` | BOOL | `true` | Enable gzip compression |
| `incremental` | BOOL | `false` | Only capture changes since the last checkpoint |

Returns a map containing `status`, `path`, `type`, `graphName`, `nodeCount`, `edgeCount`, `size`, `walSequence`, `timestamp`, and `compressed`.

### db.restore()

Restores a graph from a backup file.

```gql
-- Restore (fails if graph exists)
RETURN db.restore("data/backups/myGraph.gqlbackup.tar.gz")

-- Restore with overwrite
RETURN db.restore("data/backups/myGraph.gqlbackup.tar.gz", {overwrite: true})
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `overwrite` | BOOL | `false` | Replace existing graph data |

Returns a map containing `status`, `graphName`, `nodeCount`, `edgeCount`, `type`, and `timestamp`.

### db.backups()

Lists graph backup files found in a directory.

```gql
RETURN db.backups("data/backups")
```

Returns a list of maps, each containing `path`, `type`, `graphName`, `nodeCount`, `edgeCount`, `size`, `walSequence`, `timestamp`, and `compressed`.

## What Gets Backed Up

A full backup archives the entire graph directory, so all on-disk state is preserved:

- Nodes, edges, labels, and their properties
- Property indexes, full-text indexes, vector indexes
- Stored procedures, constraints, triggers, projections, and ontology definitions (stored in graph metadata)

After restore, in-memory managers and caches are reinitialized from the restored on-disk files:

- The fulltext index manager is initialized in the background — searches wait until it finishes loading.
- The node ID cache (and the edge ID cache, when `EDGE_ID` is enabled) is rebuilt from the restored data.

The following are **not** in the backup:

- The computing engine topology cache. After restore, re-enable it with `ALTER GRAPH <name> SET COMPUTE ENABLED` if needed.
- The backup catalog (`backup_catalog.json`) itself. The catalog is per-database, not per-graph.

## File Extensions

| Type | Extension |
|------|-----------|
| Full graph backup | `.gqlbackup.tar.gz` |
| Incremental backup | `.gqlbackup.inc.tar.gz` |

> Do not include the extension when specifying the destination path in `BACKUP GRAPH` or `db.backup()`, it is added automatically.

## Important Notes

- You can keep reading from and writing to the database during a backup. The backup captures a consistent snapshot — any pending writes are saved to disk before the archive is created, so the result is never half-written.
- Backup files are self-contained and portable. The original database can be safely removed after a backup is created.
- Restored data, including all metadata (indexes, procedures, constraints), persists across database restarts.
- `OVERWRITE` replaces the entire graph with the backup contents. Without it, the restore fails if the target graph already exists.
- All paths used in backup and restore commands are absolute filesystem paths on the server. They are used as-is with no default directory. The parent directory must already exist.
- Incremental backups require the base full backup to be available during restoration.