# Import from a Relational Database

This page walks through importing from a relational database (RDBMS) end to end. The importer connects to the source database, runs one `SELECT` per node/edge type, and streams the result rows into the graph.

| Driver | `driver` value |
|---|---|
| MySQL | `mysql` |
| PostgreSQL | `postgres` |
| SQL Server | `sqlserver` |
| Oracle | `oracle` |
| Snowflake | `snowflake` |

## Usage Guides

### Verify Connectivity

Make sure the database is reachable from the host where `gqldb-importer` will run, and that the account you'll use has `SELECT` on the tables you plan to read.

### Generate Configuration File

```bash
./gqldb-importer -sample sql
```

A file named `import.sample.sql.yml` will be created in the current directory. If the file already exists, it will be overwritten — rename it before editing so a re-run of `-sample sql` doesn't clobber your changes:

```bash
mv import.sample.sql.yml import.sql.yml
```

### Modify Configuration File

Edit `import.sql.yml`. SQL-specific configuration lives under the top-level `sql:` block; see the <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for the rest of the file (`server`, `settings`).

```yaml
sql:
  driver: mysql              # mysql, postgres, sqlserver, oracle, snowflake
  host: "localhost"
  port: 3306
  database: "my_database"
  username: "db_user"
  password: "db_password"
  # dsn: ""                  # Alternative: full driver-specific connection string

  nodes:
    - schema: "Person"
      query: "SELECT id AS _id, name, age FROM users"
      id_column: "_id"
      properties:
        age: int32

  edges:
    - schema: "FOLLOWS"
      query: "SELECT follower_id, following_id, created_at FROM follows"
      from_column: "follower_id"
      to_column: "following_id"
      properties:
        created_at: timestamp
```

Connection options:

- **Discrete fields** (`host`, `port`, `database`, `username`, `password`) — preferred, more readable.
- **`dsn`** — a single connection string in the format expected by the chosen driver. Useful when you need driver-specific options the discrete fields don't expose (e.g., charset, sslmode). When `dsn` is set, the discrete fields are ignored.

### Execute Import

```bash
./gqldb-importer -c import.sql.yml
```

## Writing the Queries

The importer treats each query as a flat row source. The column names returned by the query are what `id_column`, `from_column`, `to_column`, and `properties` reference.

**Node query** — return one row per node, with one column as the node `_id`:

```sql
-- Maps directly to id_column: "_id", labels: ["Person"]
SELECT id AS _id, name, age FROM users WHERE active = 1
```

**Edge query** — return one row per edge, with columns for the source `_id` and target `_id`:

```sql
-- Maps directly to from_column: "follower_id", to_column: "following_id", label: "FOLLOWS"
SELECT follower_id, following_id, created_at FROM follows
```

A few practical tips:

- Use `AS` to rename columns so the query result matches the column names you reference in the YAML (`_id`, `follower_id`, etc.).
- Add `WHERE` filters in the SQL itself — pre-filtering at the source is faster than letting `gqldb-importer` discard rows after the fact.
- For very large tables, split a single logical type across multiple entries (e.g., one entry per shard / date range) to parallelize at the source.
- Column types from the database are mapped automatically; declare a `properties` override only when you need a narrower GQLDB type (e.g., `int32` instead of the default `int64`).
