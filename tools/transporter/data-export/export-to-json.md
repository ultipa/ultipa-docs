# Export to JSON / JSONL

This page walks through exporting a graph to JSON or JSONL files using `gqldb-exporter`. The two formats share the same configuration shape — only the `format` value and the resulting file layout differ.

| `format` value | File layout |
|---|---|
| `json` | A single top-level **array of objects** per output file. |
| `jsonl` | One **object per line** (newline-delimited) per output file. |

## Usage Guides

### Generate Configuration File

```bash
./gqldb-exporter -sample json
# or
./gqldb-exporter -sample jsonl
```

A file named `export.sample.json.yml` (or `export.sample.jsonl.yml`) will be created in the current directory. Rename it before editing so a re-run doesn't clobber your changes:

```bash
mv export.sample.json.yml export.json.yml
```

### Modify Configuration File

Edit the renamed file to point at your source graph and choose an output directory. See the <a target="_blank" href="/docs/tools/export-configurations">Export Configurations</a> for every field; the only format-specific knob is `format` itself (`json` or `jsonl`).

<p tit="config snippet"></p>

```yml
settings:
  format: json              # or jsonl
  output_path: "./exported"
  batch_size: 5000
  export_nodes: true
  export_edges: true
  include_metadata: true
  nodes_file: "nodes"
  edges_file: "edges"
  log_level: info
```

### Execute Export

```bash
./gqldb-exporter -c export.json.yml
```

## Output Layout

Within `output_path`, the exporter writes one file per label:

<p tit="Directory layout"></p>

```
exported/
├── nodes.Person.json
├── nodes.Company.json
├── edges.KNOWS.json
└── edges.WORKS_AT.json
```

The pattern is `<nodes_file>.<Label>.<format>` for nodes and `<edges_file>.<Label>.<format>` for edges. With `format: jsonl`, the extension becomes `.jsonl`.

## File Contents

### JSON

Each file holds one JSON array. Each element carries the node's or edge's properties, with `_id` (and `_from` / `_to` for edges) as additional fields:

<p tit="nodes.Person.json"></p>

```json
[
  { "_id": "P001", "name": "Alice", "age": 30 },
  { "_id": "P002", "name": "Bob",   "age": 25 }
]
```

<p tit="edges.KNOWS.json"></p>

```json
[
  { "_from": "P001", "_to": "P002", "since": 2024 },
  { "_from": "P002", "_to": "P001", "since": 2025 }
]
```

### JSONL

Same shape as JSON, but with one object per line and no enclosing array:

<p tit="nodes.Person.jsonl"></p>

```json
{ "_id": "P001", "name": "Alice", "age": 30 }
{ "_id": "P002", "name": "Bob",   "age": 25 }
```

JSONL is the more memory-friendly choice for very large exports: downstream tools can stream the file line by line without parsing the entire array into memory.
