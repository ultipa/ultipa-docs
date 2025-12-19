# Backup and Restore

Backing up the database is essential to protect data integrity, prevent data loss, and ensure disaster recovery in case of hardware failure, accidental deletion, or corruption. It also enables database migration, replication, and rollback to a previous state if needed.

You can create a backup from a running database using either UQL or the `ultipa_backup_client` tool. The backup includes user-created graphs on Shard servers and system global graphs on both Shard and Meta servers. To restore a backup, you can only use the `ultipa_backup_client`.

## Using UQL

### Create a Backup

Create a backup named `backup-20250101`:

```uql
db.backup.create("backup_20250101")
```

The backup creation is executed as a global job, you may run `show().job().global()` afterward to verify the success of the creation.

If the specified backup name already exists, differential backup is performed; otherwise, a full backup is created.

### View Backups

Retrieves all backups created for the database:

```uql
db.backup.show()
```

Or retrieves a specific backup, such as the one named `backup_20250101`:

```uql
db.backup.show("backup_20250101")
```

It returns a table `_backupList` with the following fields:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `backup_name` | Backup name. |
| `backup_uuid` | Backup `_uuid` |
| `start_time` | The timestamp when the backup creation begins. |
| `end_time` | The timestamp when the backup creation ends. |
| `status` | Current status of the backup, which can be `DONE`, `RUNNING` or `FAILED`. |
| `msg` | Error message of the backup creation. |
| `backup_infos` | Backup information for each graph, including: <ul><li><code>address</code>: Address of the shard or meta server that stores the graph.</li><li><code>backup_path</code>: Path of the backup file. Defaults to <code>&lt;db_backup_path&gt;/&lt;backup_name&gt;/&lt;graph_id&gt;</code>. You can modify the <code>db_backup_path</code> setting in the configurations of the Meta and Shard servers.</li><li><code>graph_id</code>: The graph ID.</li><li><code>shard_id</code>: The ID of shard where the graph is stored.</li><li><code>type</code>: Either <code>SHARD</code> or <code>META</code>.</li></ul><br><i>Note: The default setting of the <code>db_backup_path</code> is <code>backup_data</code>. You can find this directory in the default working directory of the container.</i> |

## Using the Client

**Ultipa Backup Client** (`ultipa_backup_client`) is a cross-platform (Windows/Mac/Linux) command line interface designed for managing and restoring backups for Ultipa graph databases.

### Prerequisites

- A command line terminal.
    - **Linux or MacOS:** <a target="_blank" href="https://www.gnu.org/software/bash">Bash</a>, <a target="_blank" href="https://www.zsh.org">Zsh</a>, <a target="_blank" href="https://www.tcsh.org">TCSH</a>
    - **Windows:** <a target="_blank" href="https://learn.microsoft.com/en-us/powershell">PowerShell</a>
- Download Ultipa Backup Client from <a target="_blank" href="/download">here</a>. No installation is required.

> The following examples are demonstrated using a Bash shell on Linux.

Navigate to the directory containing the `ultipa_backup_client`. Ensure it has the appropriate execute permissions by running:

```bash
chmod +x ultipa_backup_client
```

### Generate Configuration File

Run the command to generate a sample configuration file:

<p tit="bash" ></p>

```bash
./ultipa_backup_client -sample
```

<center><img style="margin-top:0;" src="https://img.ultipa.cn/img/2025-05-14-10-36-57-sample.jpg" /></center>

A file named `example.backup.config` will be generated in the same directory as `ultipa_backup_client`. If the file already exists, it will be overwritten.

### Create a Backup

To create a backup, modify the `[server]` section in the `example.backup.config` file based on your environment.

Example:

<p tit="example.backup.config" ></p>

```bash
[server]
; database host (name server address)
host     = 192.168.189.129:61060
; database username
username = root
; database password
password = <password>
; backup name (supports only letters, numbers, and underscores)
name     = backup_1
```

Other settings in `example.backup.config` are not used when creating a backup.

Run the command to create a backup:

```bash
./ultipa_backup_client -mode backup -config example.backup.config
```

If the specified backup name already exists, differential backup is performed; otherwise, a full backup is created.

<center><img style="margin-top:0;" src="https://img.ultipa.cn/img/2025-05-14-11-16-04-backup.jpg" /></center>

### View Backups

Run the command to view the information of all backups:

```bash
./ultipa_backup_client -mode backup_info -config example.backup.config
```

<center><img style="margin-top:0;" src="https://img.ultipa.cn/img/2025-05-14-11-17-47-backup-info.jpg" /></center>

The `backup_info` column is omitted here. To view detailed backup information, run the UQL statement `db.backup.show()` in the database.

### Restore a Backup

A backup artifact can be restored within the same database.

To restore a backup, you need to further modify the `example.backup.config` file based on your environment.

**Notes:**

- The `name` in `[server]` section must match the `uuid` in `[restore]` section to correctly identify the backup.
- The `shard-data` in `[restore]` section must match the `dbpath` of your Shard servers (default: `shard_data`).
- The `meta-data` in `[restore]` section must match the `dbpath` of your Meta servers (default: `data`).
- For Shard, Meta, Name, or HDC clusters, the order of server addresses and daemon addresses must correspond exactly. All replicas in a shard must be included.
- **Daemon Address Configuration:**
  - Each server's daemon address is configured in `backup.config` file located in the container's `config` directory. This file is automatically generated during first startup with the default setting `listen = :50051`, and it uses the machine's primary IP address.
  - Modify `backup.config` to resolve port conflicts (format: `ip:port` or `:port`) if needed.
- Omit the `[hdc]` section entirely if no HDC servers are deployed.

Example:

<p tit="example.backup.config" ></p>

```bash
[server]
; database host (name server address)
host     = 192.168.189.129:61060
; database username
username = root
; database password
password = <password>
; backup name (supports only letters, numbers, and underscores)
name     = backup_1

[restore]
; backup uuid for restore (must match the specified backup name)
uuid       = T20250514031515_N1_158_6
; shard server dbpath
shard-data = shard_data
; meta server dbpath
meta-data  = data

; shard config for restore
[shard]
; all replica addresses for shard-1
shard1-address  = 192.168.189.131:41061,192.168.189.132:41063
; all daemon addresses for shard-1
daemon1-address = 192.168.189.131:50051,192.168.189.132:50051
; all replica addresses for shard-2
shard2-address  = 192.168.189.133:41065
; all daemon addresses for shard-2
daemon2-address = 192.168.189.133:50051

; meta config for restore
[meta]
; all meta addresses
meta-address   = 192.168.189.130:51060
; all daemon addresses for meta server
daemon-address = 192.168.189.130:50051

; name config for restore
[name]
; all name server addresses
name-address   = 192.168.189.129:61060
; all daemon addresses for name server
daemon-address = 192.168.189.129:50051

; hdc config for restore, if exists
[hdc]
; all hdc addresses
hdc-address    = 192.168.189.128:56555
; all daemon addresses for hdc sever
daemon-address = 192.168.189.128:50051
```

Run the command to restore the database to the specified backup:

```bash
./ultipa_backup_client -mode restore -config example.backup.config
```

> **Note:** All servers will be stopped and restarted as part of the restoration process.

<center><img style="margin-top:0;" src="https://img.ultipa.cn/img/2025-05-14-12-31-26-restore.jpg" /></center>

### All Flags

`ultipa_backup_client` supports the following flags:

| <div table-width="10">Flag</div> | Parameter |
| -- | -- |
| `-mode` | Specifies the operation mode: `backup`, `backup_info`, or `restore`. |
| `-config` | Specifies path to the configuration file (default: `backup.config`). |
| `-sample` | Generates a sample configuration file (`example.backup.config`). |
| `-version` | Displays the version of `ultipa_backup_client`. |
