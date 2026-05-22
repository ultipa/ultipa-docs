# Export to CSV

This page walks through exporting a graph to CSV files using `gqldb-exporter`. The exporter writes nodes and edges to separate CSV files in a chosen output directory.

## Usage Guides

### Generate Configuration File

```bash
./gqldb-exporter -sample csv
```

A file named `export.sample.csv.yml` will be created in the current directory. Rename it before editing so a re-run of `-sample csv` doesn't clobber your changes:

```bash
mv export.sample.csv.yml export.csv.yml
```

### Modify Configuration File

Edit `export.csv.yml` to point at your source graph and choose an output directory. See the <a target="_blank" href="/docs/tools/export-configurations">Export Configurations</a> for every field; CSV-specific settings are below.

<p tit="config snippet"></p>

```yml
settings:
  format: csv
  output_path: "./exported"
  batch_size: 5000
  write_header: true        # CSV-only: include a header row in each output file
  export_nodes: true
  export_edges: true
  include_metadata: true
  nodes_file: "nodes"       # output filename prefix for node files
  edges_file: "edges"       # output filename prefix for edge files
  # node_labels: ["Person", "Company"]
  # edge_labels: ["KNOWS"]
  log_level: info
```

CSV-specific knobs:

- `write_header` — when `true`, every output file begins with a row of column names. The header uses the typed form `<colName>:<type>` (e.g., `_id:_id`, `age:int32`), so the resulting files can be re-imported with `head: true` without further configuration.
- `nodes_file` / `edges_file` — filename prefixes (without extension). One file is produced per label; see <a target="_blank" href="#Output-Layout">Output Layout</a> below.

### Execute Export

```bash
./gqldb-exporter -c export.csv.yml
```

## Output Layout

Within `output_path`, the exporter writes one CSV file per label:

<p tit="Directory layout"></p>

```
exported/
├── nodes.Person.csv
├── nodes.Company.csv
├── edges.KNOWS.csv
└── edges.WORKS_AT.csv
```

The pattern is `<nodes_file>.<Label>.csv` for nodes and `<edges_file>.<Label>.csv` for edges. If you set `nodes_file: "n"` and `edges_file: "e"`, the files become `n.Person.csv`, `e.KNOWS.csv`, etc.

## Header Format

When `write_header: true`, the first row of each file uses the `<colName>:<type>` form. For nodes:

<p tit="nodes.Person.csv"></p>

```csv
_id:_id,name:string,age:int32
P001,Alice,30
P002,Bob,25
```

For edges, the source and destination IDs are emitted as `_from:_from` and `_to:_to`:

<p tit="edges.KNOWS.csv"></p>

```csv
_from:_from,_to:_to,since:int32
P001,P002,2024
P002,P001,2025
```

This typed header is what the importer's <a target="_blank" href="/docs/tools/import-from-csv">CSV import</a> expects when `head: true`, so an exported CSV directory can be re-imported without writing a separate property configuration.
