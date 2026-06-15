# Configuration Reference

This page is the single reference for the YAML configuration consumed by `gqldb-exporter`. The same top-level shape covers every supported output format; the format is selected by `settings.format`.

Generate a starter configuration with `./gqldb-exporter -sample <format>` (or `-sample all` for one of each).

## Top-Level Structure

```yaml
mode: export           # always "export"
server:                # GQLDB connection and source graph
settings:              # Output format, output path, batching, label filters, logging
```

Unlike importer configurations, there is no source-specific block — the exporter reads from GQLDB and the output shape is governed entirely by `settings`.

## mode

Always set to `export`. The output format is selected by `settings.format`, not by `mode`.

## server

Connection to the source GQLDB cluster and the graph to export from.

| Field | Type | Description |
|---|---|---|
| `host` | list of strings | One or more `host:port` entries. Multiple entries enable client-side failover. |
| `username` | string | GQLDB user. Supports env vars: `"${DB_USERNAME}"`. |
| `password` | string | GQLDB password. Supports env vars: `"${DB_PASSWORD}"`. |
| `graphset` | string | Source graph name. |
| `timeout` | integer | Per-RPC timeout in seconds. |
| `tls.enabled` | bool | Enable TLS to the GQLDB server. |
| `tls.cert_file` | string | Client certificate path. |
| `tls.key_file` | string | Client key path. |
| `tls.ca_file` | string | CA certificate path. |

## settings

| Field | Type | Default | Applies to | Description |
|---|---|---|---|---|
| `format` | string | — | All | Output format: `csv`, `json`, `jsonl`, `graphml`. |
| `output_path` | string | — | All | Directory where output files are written. Created if it does not exist. |
| `batch_size` | integer | `5000` | All | Records per fetched batch. |
| `export_nodes` | bool | `true` | All | Include nodes in the export. |
| `export_edges` | bool | `true` | All | Include edges in the export. |
| `include_metadata` | bool | `true` | All | Emit `_id` (and `_from` / `_to` for edges) alongside the user properties. |
| `node_labels` | list of strings | — | All | Restrict node export to these labels. Omit or leave empty to export all node labels. |
| `edge_labels` | list of strings | — | All | Restrict edge export to these labels. Omit or leave empty to export all edge labels. |
| `nodes_file` | string | `nodes` | CSV, JSON, JSONL | Filename prefix for node output files. One file per label: `<nodes_file>.<Label>.<ext>`. |
| `edges_file` | string | `edges` | CSV, JSON, JSONL | Filename prefix for edge output files. One file per label: `<edges_file>.<Label>.<ext>`. |
| `write_header` | bool | `true` | CSV | Include a typed header row (`<colName>:<type>`) at the top of every CSV file. |
| `log_level` | string | `info` | All | `debug`, `info`, `warn`, `error`. |
| `log_path` | string | — | All | Path to the main log file. |
| `error_log_path` | string | — | All | Path to the error-only log file. |
| `log_append` | bool | — | All | Append to log files instead of truncating. |

## Per-Format Reference

Common fields above are not repeated here; this section documents only what changes per format.

### csv

Produces one CSV file per label, named `<nodes_file>.<Label>.csv` and `<edges_file>.<Label>.csv`. When `write_header: true`, each file starts with a typed header (`<colName>:<type>`) compatible with the importer's `head: true` mode — exported CSVs can be re-imported without writing a property configuration. See <a target="_blank" href="/docs/tools/export-to-csv">Export to CSV</a>.

```yaml
settings:
  format: csv
  output_path: "./exported"
  write_header: true
  nodes_file: "nodes"
  edges_file: "edges"
```

### json

Produces one JSON file per label, each containing a single top-level array of objects. Each object carries the user properties plus `_id` (nodes) or `_from`/`_to` (edges) when `include_metadata: true`. See <a target="_blank" href="/docs/tools/export-to-json">Export to JSON / JSONL</a>.

```yaml
settings:
  format: json
  output_path: "./exported"
  nodes_file: "nodes"
  edges_file: "edges"
```

### jsonl

Identical shape to `json`, but each file is newline-delimited — one object per line, no enclosing array. The more memory-friendly choice for large exports.

```yaml
settings:
  format: jsonl
  output_path: "./exported"
  nodes_file: "nodes"
  edges_file: "edges"
```

### graphml

Produces a single combined `graph.graphml` file with all nodes and edges. `nodes_file` / `edges_file` are not used. See <a target="_blank" href="/docs/tools/export-to-graphml">Export to GraphML</a>.

```yaml
settings:
  format: graphml
  output_path: "./exported"
```

## CLI Overrides

A subset of `server` fields can be overridden at the command line, which is useful for credential injection in CI or quick environment swaps. See <a target="_blank" href="/docs/tools/exporter#Flags">Flags</a>.

| Flag | Overrides |
|---|---|
| `-host` | `server.host` |
| `-username` | `server.username` |
| `-password` | `server.password` |
| `-graph` | `server.graphset` |
| `-level` | `settings.log_level` |
