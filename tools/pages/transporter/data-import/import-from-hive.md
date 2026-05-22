# Import from Hive

This page walks through importing data from Apache Hive into a graph using `gqldb-importer`. The importer connects to HiveServer2, runs one HiveQL query per node/edge type, and streams the result rows into the graph.

## Usage Guides

### Verify Connectivity

Make sure HiveServer2 is reachable from the host where `gqldb-importer` will run, and that the account you'll use has `SELECT` on the tables you plan to read. The default HiveServer2 port is `10000`.

### Generate Configuration File

```bash
./gqldb-importer -sample hive
```

A file named `import.sample.hive.yml` will be created in the current directory. Rename it before editing so a re-run of `-sample hive` doesn't clobber your changes:

```bash
mv import.sample.hive.yml import.hive.yml
```

### Modify Configuration File

Edit `import.hive.yml`. Hive-specific configuration lives under the top-level `hive:` block; see the <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for the rest of the file (`server`, `settings`).

<p tit="config snippet"></p>

```yml
hive:
  host: "localhost"
  port: 10000
  auth: "NONE"               # NONE, NOSASL, KERBEROS
  database: "default"
  username: ""
  password: ""

  nodes:
    - schema: "Person"
      query: "SELECT id AS _id, name, age FROM users"
      id_column: "_id"
      properties:
        age: int32

  edges:
    - schema: "FOLLOWS"
      query: "SELECT follower_id, following_id FROM follows"
      from_column: "follower_id"
      to_column: "following_id"
```

### Authentication Mode

The `auth` field selects how the HiveServer2 connection authenticates:

| Value | Description |
| --- | --- |
| `NONE` | Plain authentication. `username` and `password` are sent as-is. |
| `NOSASL` | No SASL framing. Typically used when HiveServer2 has SASL disabled. |
| `KERBEROS` | Kerberos / GSSAPI. The host must have a valid Kerberos ticket cache available to the importer process. |

### Execute Import

```bash
./gqldb-importer -c import.hive.yml
```

## Writing the Queries

The importer treats each query as a flat row source. Column names in the result are what `id_column`, `from_column`, `to_column`, and `properties` reference.

**Node query** — return one row per node with one column acting as the node `_id`:

```sql
-- Maps directly to id_column: "_id", schema: "Person"
SELECT id AS _id, name, age FROM users WHERE active = TRUE
```

**Edge query** — return one row per edge with source and destination `_id` columns:

```sql
-- Maps to from_column: "follower_id", to_column: "following_id", schema: "FOLLOWS"
SELECT follower_id, following_id, created_at FROM follows
```

A few practical tips:

- Filter and aggregate at the source — Hive scans can be expensive, and pre-filtering with `WHERE` is faster than discarding rows downstream.
- For partitioned tables, include the partition column in the `WHERE` clause to enable partition pruning.
- Hive's `MAP`, `ARRAY`, and `STRUCT` column types are not directly representable as graph properties — flatten or stringify them in the query before they reach the importer.
