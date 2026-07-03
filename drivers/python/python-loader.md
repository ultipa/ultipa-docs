# Loading Files

The GQLDB Python driver can trigger **server-side loading** of ontology schemas, RDF instance data, CSV files, and prefixes — the SDK wrappers around the GQL `LOAD ONTOLOGY` / `LOAD DATA` / `LOAD CSV` / `LOAD PREFIX` statements. See <a href="/docs/ontology/rdf-import-and-export" target="_blank">RDF Import & Export</a> for the underlying statements and RDF details.

Each loader comes in three forms:

- **`load_*(payload, ...)`** — load from in-memory `bytes` or a binary stream.
- **`load_*_file(path, ...)`** — upload a **client-local file** to the server (chunked); the format is auto-detected from the extension.
- **`load_*_from_source(source, ...)`** — load a **server-reachable path or URL** (no upload) — the SDK equivalent of GQL `LOAD ... FROM '<server-path|url>'`.

This is distinct from [Bulk Import](/docs/drivers/python-bulk-import), which streams node/edge objects you build in code; here you point the server at a **file**.

## Methods

| Method | Description |
|--------|-------------|
| `load_ontology` / `load_ontology_file` / `load_ontology_from_source` | Load an ontology **schema** (T-Box) |
| `load_data` / `load_data_file` / `load_data_from_source` | Load RDF **instance data** (A-Box) as nodes and edges |
| `load_csv` / `load_csv_file` | Load nodes or edges from a CSV file |
| `load_prefix` | Register a single prefix, the standard set, or all prefixes from a source |
| `get_loader_capabilities` | Query supported formats and limits |

## Basic Usage

```python
from gqldb import GqldbClient, GqldbConfig

config = GqldbConfig(hosts=["localhost:9000"])

with GqldbClient(config) as client:
    client.login("admin", "password")
    client.use_graph("myGraph")

    # 1. Load an ontology schema (client-local file; format auto-detected from .ttl)
    onto = client.load_ontology_file("schema.ttl")
    print(f"{onto.classes} classes, {onto.object_properties} object properties")

    # 2. Load RDF instance data
    data = client.load_data_file("instances.ttl")
    print(f"{data.nodes_created} nodes, {data.edges_created} edges")
```

## Loading Ontologies

```python
# From a client-local file (format auto-detected from the extension)
result = client.load_ontology_file("schema.ttl", graph_name="myGraph")

# From bytes / a stream (pass an explicit format)
with open("schema.ttl", "rb") as f:
    result = client.load_ontology(f, format="TURTLE")

# From a server-reachable path or URL (no upload)
result = client.load_ontology_from_source("https://xmlns.com/foaf/spec/index.rdf")
```

Common keyword options: `graph_name`, `format`, `base_iri`, plus the fault-tolerance options below.

**`LoadOntologyResult`** fields: `iri`, `classes`, `object_properties`, `data_properties`, `prefixes_registered`, `prefixes` (dict), `warnings`, plus the fault-tolerance and cost fields described below.

## Loading Instance Data

```python
result = client.load_data_file("instances.ttl")
print(f"created {result.nodes_created} nodes, {result.edges_created} edges")
```

Same three forms and options as `load_ontology`.

**`LoadDataResult`** fields: `nodes_created`, `edges_created`, `prefixes_registered`, `prefixes`, `warnings`, plus fault-tolerance and cost fields.

## Loading CSV

```python
from gqldb.types import CsvColumnMapping

# Nodes
result = client.load_csv_file(
    "people.csv",
    label="Person",
    with_header=True,
    delimiter=",",
)

# Edges
result = client.load_csv_file(
    "knows.csv",
    label="knows",
    edge=True,
    edge_from_col="from_id",
    edge_to_col="to_id",
)
print(f"imported {result.imported}, skipped {result.skipped}")
```

CSV options: `label` (required), `graph_name`, `edge`, `edge_from_col`, `edge_to_col`, `with_header`, `delimiter`, `quote`, `skip`, and `mapping` (a list of `CsvColumnMapping(property, column, type)`).

`CsvColumnMapping.type` ∈ `STRING` / `INT` / `FLOAT` / `BOOL` / `DATE` / `DATETIME` / `TIMESTAMP` / `ZONED_DATETIME` / `DURATION` / `DECIMAL` / `BYTES` / `POINT` / `POINT3D` / `TIME`.

**`LoadCsvResult`** fields: `imported`, `skipped`, `is_edge`, plus cost fields.

## Loading Prefixes

```python
# A single prefix
client.load_prefix(name="foaf", iri="http://xmlns.com/foaf/0.1/")

# All standard prefixes (rdf, rdfs, owl, xsd, ...)
client.load_prefix(all_standard=True)

# All prefixes declared in a server-reachable document
client.load_prefix(source="https://xmlns.com/foaf/spec/index.rdf")
```

**`LoadPrefixResult`** fields: `registered`, `updated`, `prefixes`, `time_cost_ns`.

## Fault Tolerance

`load_ontology*` and `load_data*` accept fault-tolerance options:

| Option | Meaning |
|--------|---------|
| `validate_only=True` | Parse and report, but write nothing |
| `continue_on_error=True` | Skip malformed triples instead of failing; collect them in `errors` |
| `parser_version="..."` | Pin a specific parser version |

The result then reports `parsed`, `failed`, `skipped`, `parser_version_used`, and `errors` (a list of `ParseError(line, snippet, reason)`):

```python
result = client.load_data_file("messy.ttl", continue_on_error=True)
print(f"parsed {result.parsed}, failed {result.failed}, skipped {result.skipped}")
for e in result.errors:
    print(f"line {e.line}: {e.reason} — {e.snippet}")
```

## Format Auto-Detection

The `*_file` methods detect the format from the file extension:

| Extension | Format |
|-----------|--------|
| `.ttl` | TURTLE |
| `.nt` | NTRIPLES |
| `.owl` / `.rdf` / `.xml` | RDFXML |
| `.nq` | NQUADS |
| `.trig` | TRIG |
| `.jsonld` | JSONLD |

Pass `format=` explicitly for other extensions or for stream payloads. `LOAD ONTOLOGY` accepts OWL / RDFXML / TURTLE / NTRIPLES; `LOAD DATA` additionally accepts NQUADS / TRIG / JSONLD.

## Capabilities

```python
caps = client.get_loader_capabilities()
print(caps.ontology_formats, caps.data_formats, caps.max_upload_bytes, caps.remote_source_enabled)
```

All load results also carry `time_cost_ns`, `disk_cost_ns`, and `compute_cost_ns`.
