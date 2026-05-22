# Import from BigQuery

This page walks through importing data from Google BigQuery into a graph using `gqldb-importer`. The importer authenticates with a service-account key, runs one SQL query per node/edge type against your BigQuery datasets, and streams the result rows into the graph.

## Usage Guides

### Prepare Google Cloud Credentials

Create (or reuse) a Google Cloud service account with `BigQuery Data Viewer` and `BigQuery Job User` roles on the project containing your datasets, then download its key as a JSON file. The path to that file is what you'll set as `certFile` in the configuration.

### Generate Configuration File

```bash
./gqldb-importer -sample bigQuery
```

A file named `import.sample.bigQuery.yml` will be created in the current directory. Rename it before editing so a re-run of `-sample bigQuery` doesn't clobber your changes:

```bash
mv import.sample.bigQuery.yml import.bigQuery.yml
```

### Modify Configuration File

Edit `import.bigQuery.yml`. BigQuery-specific configuration lives under the top-level `bigQuery:` block; see the <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for the rest of the file (`server`, `settings`).

<p tit="config snippet"></p>

```yml
bigQuery:
  projectId: "my-gcp-project"
  certFile: "./service-account.json"

  nodes:
    - schema: "Person"
      query: "SELECT id AS _id, name, age FROM my_dataset.users"
      id_column: "_id"
      properties:
        age: int32

  edges:
    - schema: "FOLLOWS"
      query: "SELECT follower_id, following_id FROM my_dataset.follows"
      from_column: "follower_id"
      to_column: "following_id"
```

- `projectId` — the GCP project that holds the datasets to read from.
- `certFile` — relative or absolute path to the downloaded service-account JSON key.

### Execute Import

```bash
./gqldb-importer -c import.bigQuery.yml
```

## Writing the Queries

Use standard BigQuery SQL (GoogleSQL). Reference tables with their fully-qualified `dataset.table` (or `project.dataset.table` if reading across projects). The aliases returned by the query are what `id_column`, `from_column`, `to_column`, and `properties` reference.

**Node query** — return one row per node, with one column as the node `_id`:

```sql
-- Maps directly to id_column: "_id", schema: "Person"
SELECT id AS _id, name, age
FROM my_dataset.users
WHERE active = TRUE
```

**Edge query** — return one row per edge, with columns for the source and destination `_id`s:

```sql
-- Maps to from_column: "follower_id", to_column: "following_id", schema: "FOLLOWS"
SELECT follower_id, following_id, created_at
FROM my_dataset.follows
```

A few practical tips:

- Filter at the source with `WHERE` rather than pulling every row and discarding downstream. BigQuery bills on bytes scanned.
- For very large tables, consider partition-aware queries (`_PARTITIONTIME` filters) or split a single logical type across multiple entries to parallelize the extraction.
- Use `SAFE_CAST` when the source column type may not match the target GQLDB type cleanly.
