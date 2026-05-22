# Import from GraphML

This page walks through importing a graph from a GraphML file into GQLDB using `gqldb-importer`. The importer reads the file, applies node and edge labels from a configurable attribute, and writes everything into the target graph.

## Usage Guides

### Prepare the GraphML File

Place the `.graphml` file in a directory accessible from where you will run `gqldb-importer`. A common layout is to keep the file in a `./data` subdirectory next to the importer binary.

<p tit="Directory layout"></p>

```
.
├── gqldb-importer
└── data/
    └── graph.graphml
```

### Generate Configuration File

```bash
./gqldb-importer -sample graphml
```

A file named `import.sample.graphml.yml` will be created in the current directory. Rename it before editing so a re-run of `-sample graphml` doesn't clobber your changes:

```bash
mv import.sample.graphml.yml import.graphml.yml
```

### Modify Configuration File

Edit `import.graphml.yml`. GraphML-specific configuration lives under the top-level `graphml:` block; see the <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for the rest of the file (`server`, `settings`).

<p tit="config snippet"></p>

```yml
graphml:
  file: "./data/graph.graphml"
  schemaAttr: "type"          # Attribute name used for node/edge labels
  defaultSchema: "Node"       # Default label when attribute is missing
```

- `file` — path to the GraphML file.
- `schemaAttr` — name of the data attribute (declared with `<key id="..." attr.name="..."/>` in the GraphML file) whose value is used as the node or edge label.
- `defaultSchema` — fallback label applied when a node or edge has no value for `schemaAttr`.

Unlike the file/table-based sources, GraphML imports do **not** declare `nodes` / `edges` entries — the importer reads `<node>` and `<edge>` elements directly from the file. Every other attribute on a node or edge becomes a property of that record.

### Execute Import

```bash
./gqldb-importer -c import.graphml.yml
```

## How GraphML Maps to the Graph

| GraphML element | Becomes |
| --- | --- |
| `<node id="...">` | A node with ID equal to the `id` attribute. |
| `<edge source="..." target="...">` | An edge from `source` to `target`. |
| `<data key="schemaAttr">value</data>` on a node or edge | The node/edge label. |
| Other `<data key="...">` elements | Properties on the node or edge. |

If a node or edge does not have a value for `schemaAttr`, it falls back to `defaultSchema`. Pick an attribute that's consistently populated to avoid ending up with many records under the fallback label.
