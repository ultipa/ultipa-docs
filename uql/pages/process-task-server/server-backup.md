# Server Backup

Server backups are stored as increment of same backup name under a particular backup path (could be modified via SDK). Valid backup status are:

| <div table-width=15>Code</div> | Description | Corresponding progress message |
| ---- | ---- | ---- |
| unknown	| Un-initialied, initialized or unknow error		| 	|
| creating 	| Creating		| The graphset being backed up	|
| failed 	| Failed		| Errors that lead to failure	|
| done 		| Done			| 'ok'	|

> Operations related to server backup will be sent to the leader of the server cluster.

## Naming Conventions

Server backups are named by developers. A same name cannot be shared between backups under the same backup path.

- 2 ~ 64 characters
- Must start with letters
- Allow to use letters, underscore and numbers ( _ , A-Z, a-z, 0-9)


## Show Server Backup

Returned table name: the backup name, one table for each backup
<br>
Returned table header: `backup_id` | `backup_uuid` | `backup_path` | `start_time` | `end_time` | `status` | `msg` (the id, uuid, path, start time, end time, status and prgress message of the backup increment)

Syntax:
<p tit="Syntax"></p>

```uql
// To show all backups in the current Ultipa instance
db.backup.show() 
            
// To show a certain backup in the current Ultipa instance
db.backup.show("<backup_name>") 
```

## Create Server Backup

When creating a backup whose name already exists in the current backup path, a backup increment will be created, with unique `backup_id` and `backup_uuid`.

Syntax:
<p tit="Syntax"></p>

```uql
// To create a backup in the current Ultipa instance
db.backup.create("<backup_name>") 
```

## Restore Server Backup

Backup name is required when restoring the Ultipa instance, while the `backup_id` of increment is optional.

Syntax:
<p tit="Syntax"></p>

```uql
// To restore current Ultipa instance to the latest increment of a certain backup
db.backup.restore("<backup_name>") 

// To restore current Ultipa instance to a certain increment of a certain backup
db.backup.restore("<backup_name>", backup_id) 
```