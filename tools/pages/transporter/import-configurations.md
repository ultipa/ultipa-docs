# Configuration Reference

This page is the single reference for the YAML configuration consumed by `gqldb-importer`. Every supported source uses the same top-level shape; source-specific fields live under a block named after the source.

Generate a starter configuration with `./gqldb-importer -sample <type>` (or `-sample all` for one of each).

## Top-Level Structure

```yaml
mode: <source-type>    # csv, json, jsonl, sql, neo4j, bigQuery, kafka, hive, salesforce, rdf, graphml
server:                # GQLDB connection and target graph
settings:              # Batching, threading, parsing, logging
<source-type>:         # Optional: source-specific block (sql, neo4j, kafka, ...); omitted for file sources
nodes:                 # Where to read nodes from (file sources put this at top level)
edges:                 # Where to read edges from (file sources put this at top level)
```

For **file sources** (`csv`, `json`, `jsonl`), `nodes` / `edges` sit at the top level. For **single-file graph sources** (`rdf`, `graphml`), there is no `nodes` / `edges`, the entire file is imported via the source-specific block. For **database / query / streaming sources** (`sql`, `neo4j`, `bigQuery`, `hive`, `salesforce`, `kafka`), `nodes` / `edges` are nested inside the source-specific block.

## mode

Must match the source the configuration is for. The importer rejects a mismatch between `mode` and the source-specific block name.

| Value | Source |
|---|---|
| `csv` | CSV files |
| `json` | JSON files (array of objects) |
| `jsonl` | JSON-Lines files |
| `sql` | Relational databases (MySQL, PostgreSQL, SQL Server, Oracle, Snowflake) |
| `neo4j` | Neo4j |
| `bigQuery` | Google BigQuery |
| `kafka` | Kafka topics |
| `hive` | Apache Hive |
| `salesforce` | Salesforce (SOQL) |
| `rdf` | RDF (N-Triples / Turtle / RDF/XML) |
| `graphml` | GraphML |

## server

Connection to the target GQLDB cluster and the destination graph.

| Field | Type | Description |
|---|---|---|
| `host` | list of strings | One or more `host:port` entries. Multiple entries enable client-side failover. |
| `username` | string | GQLDB user. Supports env vars: `"${DB_USERNAME}"`. |
| `password` | string | GQLDB password. Supports env vars: `"${DB_PASSWORD}"`. |
| `graph` | string | Target graph name. |
| `graph_type` | string | `open` or `closed`. Used when the importer auto-creates the graph. |
| `edge_id` | bool | If the importer auto-creates the graph, controls the `EDGE_ID` feature on it. `true` (default) creates the graph with `EDGE_ID` enabled; `false` creates it with `WITH EDGE_ID DISABLED`. Matches the GQLDB default of EDGE_ID-enabled for new graphs. See <a target="_blank" href="/docs/gql/node-and-edge-ids">Node and Edge IDs</a>. |
| `timeout` | integer | Per-RPC timeout in seconds. |
| `tls.enabled` | bool | Enable TLS to the GQLDB server. |
| `tls.cert_file` | string | Client certificate path. |
| `tls.key_file` | string | Client key path. |
| `tls.ca_file` | string | CA certificate path. |

## settings

Common runtime knobs. Source-specific parsing options (e.g., CSV `separator`) also live here and are marked accordingly.

| Field | Type | Default | Applies to | Description |
|---|---|---|---|---|
| `batch_size` | integer | `1000` | All | Records per batched RPC. |
| `threads` | integer | `4` | All | Worker thread count. |
| `import_mode` | string | `overwrite` | All | <a target="_blank" href="/docs/gql/insert">`insert`</a> (fail on dup `_id`), <a target="_blank" href="/docs/gql/insert-overwrite">`overwrite`</a> (replace), <a target="_blank" href="/docs/gql/upsert">`upsert`</a> (update or insert). |
| `skip_invalid_nodes` | bool | — | All | Skip nodes that fail validation; do not abort. |
| `stop_on_error` | bool | — | All | Abort the import on the first error. |
| `create_node_if_not_exist` | bool | — | All | When inserting an edge, auto-create missing endpoints. |
| `estimated_nodes` | integer | — | All | Hint for the bulk-import pipeline. |
| `estimated_edges` | integer | — | All | Hint for the bulk-import pipeline. |
| `timezone` | string | — | All | Timezone for parsing temporal values. Accepts UTC offsets (`"+0800"`, `"-0500"`, `"+08:00"`) or IANA names (`"Asia/Shanghai"`). |
| `timestamp_unit` | string | auto | All | `s` (seconds) or `ms` (milliseconds). |
| `log_level` | string | `info` | All | `debug`, `info`, `warn`, `error`. |
| `log_path` | string | — | All | Path to the main log file. |
| `error_log_path` | string | — | All | Path to the error-only log file. |
| `log_append` | bool | — | All | Append to log files instead of truncating. |
| `separator` | string | `,` | CSV | Field separator. |
| `quote` | string | `"` | CSV | Quote character. |
| `comment` | string | — | CSV | Comment line prefix. |
| `fit_to_header` | bool | `false` | CSV | When `true`, ignore extra columns past the header. |
| `lazy_quotes` | bool | `true` | CSV | Allow lazy / unescaped quotes inside fields. |
| `trim_space` | bool | `true` | CSV | Trim leading / trailing whitespace from each field. |

## nodes and edges

The structure depends on the source category.

### Per-entry fields (all sources)

| Field | Required | Description |
|---|---|---|
| `labels` (nodes) / `label` (edges) | yes | Target label(s). Nodes accept multiple. |
| `id_column` | optional | Column / field carrying the entity's `_id`. Default: `_id`. Valid on nodes always; valid on edges **only when the target graph has `EDGE_ID` enabled** (i.e., `server.edge_id: true` or an already-enabled existing graph). Supplying `id_column` on an edge entry against an `EDGE_ID`-disabled graph is rejected. |
| `from_column` | (edges) | Column / field carrying the source node's `_id`. |
| `to_column` | (edges) | Column / field carrying the target node's `_id`. |
| `properties` | optional | Either the **short form** (a map of `name: type`) or the **list form** (a list of objects with `name`, `type`, and optionally `prefix`, `new_name`). See <a href="#property-mapping">Property Mapping</a>. |

File sources add `file:` (path) and optionally `head:` (header present?). Database / streaming sources add `query:`, `topic:`, `schema:` (logical type name) as documented per source.

Example of assigning custom edge `_id`s from the source — `edge_id` must be enabled on the target graph:

```yaml
server:
  graph: "my_graph"
  edge_id: true             # required for id_column on edges

edges:
  - file: "./data/knows.csv"
    label: "KNOWS"
    id_column: "txn_id"     # source column carrying the edge _id
    from_column: "from_id"
    to_column: "to_id"
```

### Property Mapping

**Short form** — name to type:

```yaml
properties:
  age: int32
  salary: double
  active: bool
```

**List form** — full control, supports renaming, ID prefixing, and explicit `_id` marker:

```yaml
properties:
  - name: cust_no       # source column / field name
    type: _id           # mark this property as the node's _id
    prefix: "CUST_"     # prepend a prefix to the value (e.g., "123" -> "CUST_123")
  - name: full_name
    type: string
    new_name: name      # rename in target graph
  - name: age
    type: int32
```

**Type values:** `string`, `bool`, `int32`, `int64`, `uint32`, `uint64`, `float`, `double`, `timestamp`, plus `_id` (special — marks the ID column when using the list form).

## Per-Source Reference

Common fields above are not repeated below; this section documents only what changes per source.

### csv

Top-level `nodes` / `edges` entries; each carries a `file:` path.

```yaml
nodes:
  - file: "./data/people.csv"
    labels: ["Person"]
    head: true           # default true; file has header row
    properties:
      age: int32

edges:
  - file: "./data/knows.csv"
    label: "KNOWS"
    from_column: "from_id"
    to_column: "to_id"
```

CSV parsing options (`separator`, `quote`, `comment`, `fit_to_header`, `lazy_quotes`, `trim_space`) live under `settings`.

### json

Top-level `nodes` / `edges`, one `file:` per entry. The JSON file is an array of objects keyed by column names.

```yaml
nodes:
  - file: "./data/people.json"
    labels: ["Person"]
    properties:
      age: int32

edges:
  - file: "./data/knows.json"
    label: "KNOWS"
    from_column: "from_id"
    to_column: "to_id"
```

### jsonl

Identical shape to `json`. Each line of the input file is one JSON object.

### sql

Connects to a relational source and runs one query per node/edge entry.

```yaml
sql:
  driver: mysql          # mysql, postgres, sqlserver, oracle, snowflake
  host: "localhost"
  port: 3306
  database: "my_database"
  username: "db_user"
  password: "db_password"
  # dsn: ""              # alternative: full connection string

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

`schema` is the target label. Either supply `host/port/database/username/password` or `dsn` (a complete driver-specific connection string).

### neo4j

Queries the Neo4j source with Cypher.

```yaml
neo4j:
  uri: "neo4j://localhost:7687"
  username: "neo4j"
  password: "password"
  database: "neo4j"

  nodes:
    - schema: "Person"
      query: "MATCH (n:Person) RETURN n.id AS _id, n.name AS name, n.age AS age"
      id_column: "_id"
      properties:
        age: int32

  edges:
    - schema: "KNOWS"
      query: "MATCH (a:Person)-[r:KNOWS]->(b:Person) RETURN a.id AS from_id, b.id AS to_id, r.since AS since"
      from_column: "from_id"
      to_column: "to_id"
      properties:
        since: int32
```

### bigQuery

Uses a GCP service-account JSON for authentication.

```yaml
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

### kafka

Reads one Kafka topic per node/edge entry; each message is a JSON object.

```yaml
kafka:
  brokers:
    - "localhost:9092"

  nodes:
    - schema: "Person"
      topic: "users"
      offset: oldest         # oldest, newest
      id_column: "_id"
      properties:
        age: int32

  edges:
    - schema: "FOLLOWS"
      topic: "follows"
      offset: oldest
      from_column: "follower_id"
      to_column: "following_id"
```

### hive

Connects via HiveServer2.

```yaml
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

### salesforce

Authenticates with username + password + security token. Queries are SOQL.

```yaml
salesforce:
  url: "https://your-instance.salesforce.com"
  username: "sf_user@example.com"
  password: "sf_password"
  token: "security_token"

  nodes:
    - schema: "Account"
      query: "SELECT Id, Name, Industry FROM Account LIMIT 1000"
      id_column: "Id"

  edges:
    - schema: "CONTACT_OF"
      query: "SELECT Id, AccountId, Name FROM Contact LIMIT 1000"
      from_column: "Id"
      to_column: "AccountId"
```

### rdf

Single file; no `nodes` / `edges` blocks. Triples become nodes and edges based on the RDF graph.

```yaml
rdf:
  file: "./data/ontology.nt"
  format: ntriples           # ntriples, turtle, rdfxml
  defaultSchema: "RDFNode"   # label for unlabeled subjects
```

### graphml

Single file; no `nodes` / `edges` blocks. Labels come from the configured attribute.

```yaml
graphml:
  file: "./data/graph.graphml"
  schemaAttr: "type"         # GraphML attribute name carrying the label
  defaultSchema: "Node"      # label when the attribute is missing
```

## CLI Overrides

A subset of `server` fields can be overridden at the command line, which is useful for credential injection in CI or quick environment swaps. See <a target="_blank" href="/docs/tools/importer#Flags">Flags</a>.

| Flag | Overrides |
|---|---|
| `-host` | `server.host` |
| `-username` | `server.username` |
| `-password` | `server.password` |
| `-graph` | `server.graph` |
| `-level` | `settings.log_level` |
