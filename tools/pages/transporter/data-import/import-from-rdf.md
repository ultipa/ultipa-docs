# Import from RDF

This page walks through importing an RDF graph into a GQLDB graph using `gqldb-importer`. The importer reads a single RDF file, parses every triple, and writes the subjects/objects as nodes and the predicates as edges.

Supported RDF serializations:

| `format` value | Serialization |
| --- | --- |
| `ntriples` | N-Triples (`.nt`) |
| `turtle` | Turtle (`.ttl`) |
| `rdfxml` | RDF/XML (`.rdf`, `.xml`) |

## Usage Guides

### Prepare the RDF File

Place the RDF file in a directory accessible from where you will run `gqldb-importer`. A common layout is to keep the file in a `./data` subdirectory next to the importer binary.

<p tit="Directory layout"></p>

```
.
├── gqldb-importer
└── data/
    └── ontology.nt
```

### Generate Configuration File

```bash
./gqldb-importer -sample rdf
```

A file named `import.sample.rdf.yml` will be created in the current directory. Rename it before editing so a re-run of `-sample rdf` doesn't clobber your changes:

```bash
mv import.sample.rdf.yml import.rdf.yml
```

### Modify Configuration File

Edit `import.rdf.yml`. RDF-specific configuration lives under the top-level `rdf:` block; see the <a target="_blank" href="/docs/tools/import-configurations">Import Configurations</a> for the rest of the file (`server`, `settings`).

<p tit="config snippet"></p>

```yml
rdf:
  file: "./data/ontology.nt"
  format: ntriples            # ntriples, turtle, rdfxml
  defaultSchema: "RDFNode"
```

- `file` — path to the RDF file.
- `format` — the RDF serialization. Must match the file's actual format.
- `defaultSchema` — the label applied to every node created from an RDF subject or object.

Unlike the file/table-based sources, RDF imports do **not** declare `nodes` / `edges` entries — the importer derives them automatically from the triples: each subject and object becomes a node (labeled `defaultSchema`); each predicate becomes an edge whose label is the predicate IRI.

### Execute Import

```bash
./gqldb-importer -c import.rdf.yml
```

## How Triples Map to the Graph

Given a triple `<s> <p> <o>`:

| RDF element | Becomes |
| --- | --- |
| Subject `<s>` | A node with ID `<s>` and label `defaultSchema`. |
| Object `<o>` (IRI) | A node with ID `<o>` and label `defaultSchema`. |
| Object `<o>` (literal) | A property on the subject node, keyed by the predicate IRI. |
| Predicate `<p>` | When the object is an IRI: an edge from the subject node to the object node with label `<p>`. |

Blank nodes are assigned synthetic IDs derived from their position in the file.
