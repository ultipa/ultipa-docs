# Export to GraphML

This page walks through exporting a graph to a GraphML file using `gqldb-exporter`. Unlike the CSV / JSON exports, GraphML produces a single file that contains both nodes and edges.

## Usage Guides

### Generate Configuration File

```bash
./gqldb-exporter -sample graphml
```

A file named `export.sample.graphml.yml` will be created in the current directory. Rename it before editing so a re-run of `-sample graphml` doesn't clobber your changes:

```bash
mv export.sample.graphml.yml export.graphml.yml
```

### Modify Configuration File

Edit `export.graphml.yml` to point at your source graph and choose an output directory. See the <a target="_blank" href="/docs/tools/export-configurations">Export Configurations</a> for every field.

<p tit="config snippet"></p>

```yml
settings:
  format: graphml
  output_path: "./exported"
  batch_size: 5000
  export_nodes: true
  export_edges: true
  include_metadata: true
  log_level: info
```

The `nodes_file` / `edges_file` fields don't apply — GraphML always produces a single combined file.

### Execute Export

```bash
./gqldb-exporter -c export.graphml.yml
```

## Output Layout

The exporter writes a single `graph.graphml` file in `output_path`:

<p tit="Directory layout"></p>

```
exported/
└── graph.graphml
```

## File Structure

The output is standard <a target="_blank" href="http://graphml.graphdrawing.org/">GraphML</a>:

- Each node label becomes a `<data>` attribute on `<node>` elements, with a configurable key name.
- Each edge label becomes a `<data>` attribute on `<edge>` elements.
- Every property becomes its own `<data>` element, declared via `<key>` headers at the top of the file.

The exported file round-trips through the <a target="_blank" href="/docs/tools/import-from-graphml">GraphML import</a> — set the importer's `schemaAttr` to the same key name to recover the original labels.
