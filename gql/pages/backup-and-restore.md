# Backup and Restore

Ultipa GQL provides built-in commands and functions for backing up and restoring your graph data. You can back up individual graphs or an entire database, create incremental backups to save space, and verify backup integrity before relying on them.

## Quick Start

```gql
-- Back up the current graph
BACKUP GRAPH TO '/backups/my_backup'

-- List available backups
SHOW BACKUPS

-- Restore from a backup (replaces existing graph data)
RESTORE GRAPH FROM '/backups/my_backup.gqlbackup.tar.gz' OVERWRITE

-- Verify a backup file is valid
VERIFY BACKUP '/backups/my_backup.gqlbackup.tar.gz'
```

## Backing Up a Graph

Use `BACKUP GRAPH` to create a backup of a single graph as a compressed archive.

### Syntax

```gql
BACKUP GRAPH [<graphName>] TO '<path>'
```

| Argument | Description |
|----------|-------------|
| `<graphName>` | Optional. The name of the graph to back up. If omitted, backs up the current (active) graph |
| `<path>` | The destination file path for the backup. This is an absolute filesystem path (e.g., `/backups/my_backup`); the `.gqlbackup.tar.gz` extension is added automatically. The parent directory must already exist |

### Examples

Back up the current graph:

```gql
BACKUP GRAPH TO '/backups/my_backup'
```

Back up a specific graph without switching to it:

```gql
BACKUP GRAPH analytics TO '/backups/analytics_backup'
```

> The database remains available for reads and writes while a backup is in progress.

## Restoring a Graph

Use `RESTORE GRAPH` to restore a graph from a backup archive.

### Syntax

```gql
RESTORE GRAPH FROM '<path>' [OVERWRITE]
```

| Argument | Description |
|----------|-------------|
| `<path>` | The full path to the backup file, including the `.gqlbackup.tar.gz` extension |
| `OVERWRITE` | Optional. If specified, replaces the existing graph data. Without it, the command fails if the target graph already exists |

### Examples

Restore a graph from a backup:

```gql
RESTORE GRAPH FROM '/backups/my_backup.gqlbackup.tar.gz'
```

Restore and overwrite an existing graph:

```gql
RESTORE GRAPH FROM '/backups/my_backup.gqlbackup.tar.gz' OVERWRITE
```

> **After an overwrite restore**, the graph reflects exactly the state captured in the backup. Any data added after the backup was taken is lost.

## Incremental Backup

Incremental backups capture only the changes made since a base (full) backup. They are smaller and faster to create, but require the base backup to be available during restoration.

### Creating an Incremental Backup

First, create a full backup, then reference it as the base:

```gql
-- Step 1: Create a full backup
BACKUP GRAPH TO '/backups/full'

-- Step 2: Make data changes
INSERT (:Person {name: 'NewUser'})

-- Step 3: Create an incremental backup referencing the full backup
BACKUP GRAPH TO '/backups/incr' INCREMENTAL BASE '/backups/full.gqlbackup.tar.gz'
```

Incremental backup files use the extension `.gqlbackup.inc.tar.gz`.

### Restoring from an Incremental Backup

Restore the full backup first, then apply the incremental backup on top:

```gql
RESTORE GRAPH FROM '/backups/full.gqlbackup.tar.gz' OVERWRITE
RESTORE GRAPH FROM '/backups/incr.gqlbackup.inc.tar.gz' OVERWRITE
```

## Database-Level Backup

Use `BACKUP DATABASE` and `RESTORE DATABASE` to back up and restore all graphs in a database at once.

### Backup

```gql
BACKUP DATABASE TO '/backups/db_snapshot'
```

This creates a directory containing a separate backup file for each graph along with a metadata manifest.

### Restore

```gql
RESTORE DATABASE FROM '/backups/db_snapshot' OVERWRITE
```

### Example

```gql
-- Set up two graphs with data
INSERT (:Person {name: 'Alice'})

CREATE GRAPH analytics
USE GRAPH analytics
INSERT (:Metric {name: 'clicks', value: 1000})
USE GRAPH default

-- Back up the entire database
BACKUP DATABASE TO '/backups/full_db'

-- Later, restore all graphs
RESTORE DATABASE FROM '/backups/full_db' OVERWRITE

-- Verify data in both graphs
USE GRAPH default
MATCH (p:Person) RETURN p.name
-- Result: Alice

USE GRAPH analytics
MATCH (m:Metric) RETURN m.name, m.value
-- Result: clicks, 1000
```

## Managing Backups

### Listing Backups

Use `SHOW BACKUPS` to view recorded backups from the catalog or scan a directory:

```gql
-- Show all entries from the backup catalog
SHOW BACKUPS

-- Filter by graph name
SHOW BACKUPS FOR GRAPH analytics

-- Scan a directory for backup files
SHOW BACKUPS FROM '/backups/directory'
```

### Viewing Backup Details

Use `SHOW BACKUP` with a file path to retrieve metadata for a specific backup:

```gql
SHOW BACKUP '/backups/my_backup.gqlbackup.tar.gz'
```

### Verifying a Backup

Use `VERIFY BACKUP` to check that a backup archive is structurally valid before relying on it:

```gql
VERIFY BACKUP '/backups/my_backup.gqlbackup.tar.gz'
```

The result includes a `valid` field (`true` or `false`) and an `errors` field listing any issues found.

> Always verify backups before using them for disaster recovery.

## Backup Functions

As an alternative to the DDL statements above, you can use built-in functions that return backup metadata as map values. These are useful when you need to process backup information programmatically within a query.

### DB.BACKUP()

Creates a backup of the current graph.

```gql
-- Basic backup
RETURN DB.BACKUP('/path/to/backup')

-- With options
RETURN DB.BACKUP('/path/to/backup', {compress: true})

-- Incremental backup
RETURN DB.BACKUP('/path/to/backup', {incremental: true})
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `compress` | BOOL | `true` | Enable gzip compression |
| `incremental` | BOOL | `false` | Only capture changes since the last checkpoint |

Returns a map containing `status`, `path`, `type`, `graphName`, `nodeCount`, `edgeCount`, `size`, `walSequence`, `timestamp`, and `compressed`.

### DB.RESTORE()

Restores a graph from a backup file.

```gql
-- Restore (fails if graph exists)
RETURN DB.RESTORE('/path/to/backup.gqlbackup.tar.gz')

-- Restore with overwrite
RETURN DB.RESTORE('/path/to/backup.gqlbackup.tar.gz', {overwrite: true})
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `overwrite` | BOOL | `false` | Replace existing graph data |

Returns a map containing `status`, `graphName`, `nodeCount`, `edgeCount`, `type`, and `timestamp`.

### DB.BACKUPS()

Lists backup files found in a directory.

```gql
RETURN DB.BACKUPS('/backups/directory')
```

Returns a list of maps, each containing `path`, `type`, `graphName`, `nodeCount`, `edgeCount`, `size`, `walSequence`, `timestamp`, and `compressed`.

## What Gets Backed Up

A backup captures the complete state of a graph, including:

- All nodes, edges, labels, and their properties
- Property indexes
- Stored procedures
- Constraints (NOT NULL, UNIQUE)
- Ontology definitions
- Triggers
- Projections

The following are **not** included in the backup but are rebuilt automatically on restore:

- Fulltext indexes
- Node ID cache
- Computing engine topology cache

## File Extensions

| Type | Extension |
|------|-----------|
| Full graph backup | `.gqlbackup.tar.gz` |
| Incremental backup | `.gqlbackup.inc.tar.gz` |

> Do not include the extension when specifying the destination path in `BACKUP GRAPH` -- it is added automatically.

## Important Notes

- The database remains available for reads and writes during backup.
- Backup files are self-contained and portable. The original database can be safely removed after a backup is created.
- Restored data, including all metadata (indexes, procedures, constraints), persists across database restarts.
- `OVERWRITE` replaces the entire graph with the backup contents. Without it, the restore fails if the target graph already exists.
- All paths used in backup and restore commands are absolute filesystem paths on the server. They are used as-is with no default directory. The parent directory must already exist.
- Incremental backups require the base full backup to be available during restoration.