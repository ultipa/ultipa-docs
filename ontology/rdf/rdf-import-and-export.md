# RDF Import & Export

## Overview

Move RDF in and out of an ontology graph:

- `LOAD ONTOLOGY` brings in external **schema (T-Box) triples**
- `LOAD DATA` brings in **instance (A-Box) triples**
- `EXPORT` serializes RDF back out, scoped to instance data (`EXPORT`), the schema (`EXPORT ONTOLOGY`), or both (`EXPORT ALL`)

To inspect or visualize an ontology once it's loaded, see <a href="/docs/ontology/inspecting" target="_blank">Inspecting & Visualizing Ontologies</a>.

## Loading External Ontologies

An **external ontology** is a vocabulary file authored outside of GQLDB (e.g. FOAF, Schema.org, SKOS) in a serialization like OWL, Turtle, RDF/XML, or JSON-LD. `LOAD ONTOLOGY` reads such a file and registers all its classes and properties in one shot. Each `LOAD ONTOLOGY` import is registered as its own ontology and shows up as a row in `SHOW ONTOLOGY`, named after its source IRI.

### Prefixes & Namespaces

The document's prefix declarations are registered as part of the import, so no separate `LOAD PREFIX` is needed for terms defined in the file. The standard-vocabulary prefixes it references (`owl:` / `rdfs:` / `rdf:` / `xsd:`) are auto-registered too, even when the file doesn't declare them.

How you address the document's **own** terms depends on how it declares that namespace:

- **Default (empty) prefix**: For example, `@prefix : <http://example.org/ontology#> .`. The IRI becomes the graph's default namespace, so you address terms without the prefix, such as `@:Person`.
- **Named prefix**: For example, `@prefix ex: <http://example.org/ontology#> .`. Just a regular prefix; no default namespace is set, and you address terms as `@ex:Person`.
- **No prefix at all**: the terms are written as full IRIs. GQLDB derives the default namespace from the class IRIs only, when they all share one common, non-standard namespace not already bound to a prefix (a file whose classes span two such namespaces gets none); you then address terms as `@:Person`.

> The default namespace appears in `SHOW PREFIX` as a row with an empty prefix name pointing at its IRI, and the first declaration wins.

### What Gets Imported

`LOAD ONTOLOGY` imports the **schema (T-Box) triples** only: `owl:Ontology`, `owl:Class` / `rdfs:Class`, `owl:DatatypeProperty`, `owl:ObjectProperty` (and the OWL characteristic subclasses), plus their `rdfs:subClassOf` / `rdfs:domain` / `rdfs:range` / `owl:inverseOf` / `owl:Restriction` axioms. Any **instance (A-Box) triples** in the same file are silently skipped. To bring instance data into the graph, use [`LOAD DATA`](#Loading-Instance-Data); running both statements over the same mixed file is safe because each ignores the triples the other handles.

### Loading from a Server File

Load from a file on the GQLDB server, format auto-detected from the `.ttl` extension:

```gql
LOAD ONTOLOGY FROM 'file:///path/on/server/foaf.ttl'

-- FROM is optional when the source is an angle-bracketed IRI literal (below is equivalent)
LOAD ONTOLOGY <file:///path/on/server/foaf.ttl>
```

The file path is resolved by the GQLDB server: the file must exist on the **server's** filesystem (and the GQLDB process must have read permission). Loading from a server-local file is the most reliable form as it avoids network and TLS variability.

#### Specifying Format

The loader auto-detects from the file extension (`.ttl` → TURTLE, `.owl`/`.rdf`/`.xml` → RDFXML, `.nt` → NTriples). Pass `FORMAT` explicitly only when auto-detection would guess wrong (e.g. a `.txt` file containing Turtle, or a server that returns a generic content type):

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/data.txt' FORMAT TURTLE
```

Supported `FORMAT` keywords: `OWL`, `RDFXML`, `TURTLE`, `NTRIPLES` (`OWL` and `RDFXML` both select the RDF/XML parser).

#### Surfacing Parser Warnings

`VERBOSE` surfaces parser warnings (unknown constructs, malformed triples) in the result message, useful when integrating a new ontology to surface silent compatibility issues:

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/foaf.ttl' VERBOSE
```

`FORMAT` and `VERBOSE` can be combined, but `FORMAT` must come first:

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/data.txt' FORMAT TURTLE VERBOSE
```

### Loading from a URL

Loading from a URL is also supported. For `https://` URLs the host's TLS certificate must be trusted by the system trust store; plain `http://` skips TLS entirely. When `FORMAT` is omitted, the loader checks the response `Content-Type` header first, then the URL's file extension, and falls back to `RDFXML` if neither gives a hint.

```gql
LOAD ONTOLOGY FROM 'https://schema.org/version/latest/schemaorg-current-https.rdf'

-- Load the real FOAF vocabulary (schema) from its published RDF/XML
LOAD ONTOLOGY FROM 'http://xmlns.com/foaf/spec/index.rdf'
```

A vocabulary's namespace IRI is usually not the loadable document. FOAF's namespace is `http://xmlns.com/foaf/0.1/`, but its schema file is published at `http://xmlns.com/foaf/spec/index.rdf` (RDF/XML). Loading it registers the `foaf` prefix and brings in FOAF's classes and hierarchy, so `@foaf:Person` resolves and subclass inference works with no `CREATE` needed.

## Loading Instance Data

`LOAD DATA` imports **instance (A-Box) triples** from RDF documents as graph nodes and edges. Supported formats: `TURTLE`, `NTRIPLES`, `NQUADS`, `TRIG`, `JSONLD`.

```gql
LOAD DATA FROM 'file:///path/on/server/instances.ttl' FORMAT TURTLE
```

The file path resolves on the **GQLDB server**'s filesystem, the same as `LOAD ONTOLOGY`. URL sources are also supported. Format is auto-detected from the file extension when `FORMAT` is omitted.

Triple-to-graph mapping:

| Triple shape | Becomes |
| -- | -- |
| `(s, rdf:type, C)` | node `s` gets the ontology label for class `C` |
| `(s, p, "literal")` | data property `p` on node `s` (xsd-coerced when typed) |
| `(s, p, "a"), (s, p, "b")` (repeated literal) | list-valued property `p = ['a','b']` |
| `(s, p, o)` where `o` is an IRI | edge `(s)-[:p]->(o)` |
| `rdfs:label` / `dc:title` / `foaf:name` | also copied to a readable `name` / `title` |

Every node is keyed by its subject IRI (stored in the property `_iri`), so repeated mentions of a subject merge onto one node and edges resolve regardless of triple order. Bare Turtle literals are typed (`30` → integer, `true` → boolean), and a predicate repeated on one subject (a multivalued slot) folds into a list rather than keeping only the last value. Classes named in `rdf:type` that aren't declared yet are auto-registered (under `WARNING` / `OFF` enforcement), and document `@prefix` declarations are registered automatcially.

> `LOAD DATA` preserves RDF 1.2 literal metadata (language tags, base direction, datatype IRIs), handles blank nodes, imports named graphs (N-Quads / TriG) and JSON-LD, and supports triple terms (RDF-star). See <a href="/docs/ontology/working-with-rdf" target="_blank">Working with RDF</a> for the full reference.

### Do You Need LOAD ONTOLOGY First

Not to load the data. `LOAD DATA` runs standalone and auto-registers any undeclared classes (under `WARNING` / `OFF` enforcement).

But the ontology's **inference and validation** come from the schema (T-Box) axioms, which `LOAD DATA` does not import. Without a loaded schema you get the individuals as a plain labeled graph, with no subclass inference, OWL characteristics, defined classes, or `DOMAIN` / `RANGE` checks.

For those, `LOAD ONTOLOGY` first, then `LOAD DATA`. Under `STRICT` enforcement the schema must be in place first, since undeclared classes are rejected rather than auto-registered.

## Exporting RDF

`EXPORT` serializes back to RDF, inverting the `LOAD` statements. For instance data, each node becomes a subject, each ontology label an `rdf:type` triple, each literal property a data-property triple, and each edge an object-property triple; `LIST` properties are written back as real RDF collections, so their order round-trips.

A scope keyword selects what is serialized. Omit it for instance data (A-Box), `ONTOLOGY` for the schema only (T-Box: class and property definitions, hierarchy, and axioms / restrictions, as OWL triples), or `ALL` for both in one document:

```gql
-- Instance data (A-Box), returned as a single result column named 'rdf'
EXPORT FORMAT NTRIPLES

-- Instance data, written to a file
EXPORT TO 'file:///tmp/example.ttl' FORMAT TURTLE

-- The ontology schema (T-Box) on its own
EXPORT ONTOLOGY FORMAT TURTLE

-- Both the T-Box and the A-Box in one document
EXPORT ALL TO 'file:///tmp/graph.ttl' FORMAT TURTLE
```

**Details**

- `FORMAT` is required in every form. Accepted formats:
  - `NTRIPLES`: flat one-triple-per-line N-Triples.
  - `TURTLE`: grouped and prefix-compacted (declares only the prefixes it actually uses; `rdf:type` is written as `a`).
  - `NQUADS` / `TRIG`: carry the named-graph dimension
- `TO <destination>` controls where the RDF file is written to; if omitted, the RDF is returned inline as a single result column named `rdf`.
- Output is deterministically ordered, so exporting the same graph twice produces byte-for-byte identical results.

## Notes & Limitations

- **Round-trip.** `LOAD DATA` → `EXPORT` → `LOAD DATA` reproduces the graph. A predicate's IRI is recorded from the document's prefixes at load time (stored on the edge / property label, not flattened to a bare name), so `EXPORT` reconstructs it exactly, no `LOAD ONTOLOGY` needed, even for an A-Box-only graph with no schema.
- **Predicate IRIs set outside RDF import.** A literal property created directly (e.g. by `INSERT` / `SET`, with no RDF predicate behind it) has no recorded IRI; its predicate is reconstructed from the ontology schema, then the default namespace, then a synthetic `urn:gqldb:property:` base. Load a schema with `LOAD ONTOLOGY` (or use a default namespace) for a meaningful IRI.
