# Loading Ontologies & Data

## Overview

Populate an ontology graph from RDF documents using the `LOAD` family of statements: 

- `LOAD ONTOLOGY` brings in an external **schema**
- `LOAD ONTOLOGY GRAPH` projects that schema as queryable nodes and edges
- `LOAD DATA` brings in **instance data**

## Loading External Ontologies

An **external ontology** is a vocabulary file authored outside of GQLDB — class hierarchies, property definitions, prefix declarations, and constraints in a serialization like OWL, Turtle, RDF/XML, or JSON-LD. Common examples are FOAF, Schema.org, SKOS, Dublin Core, and PROV-O. `LOAD ONTOLOGY` reads such a file and registers everything inside in one shot, saving you from defining classes and properties for each term by hand. 

The document's `@prefix` declarations are registered as part of the import, so `@prefix:Class` labels resolve in `MATCH` immediately after, no separate `LOAD PREFIX` is needed for terms defined in the loaded file. Note:

- **A convenience prefix is also derived from the ontology itself.** Beyond the document's `@prefix` lines, `LOAD ONTOLOGY` registers one extra prefix named after the loaded ontology, pointing at its base IRI. For example, an `owl:Ontology` whose IRI is `http://example.org/ontology` yields a prefix `ontology` → `http://example.org/`. So a prefix can appear in `SHOW PREFIX` even when your file has no matching `@prefix` line. (It is skipped if a prefix already maps to that base IRI.)
- **The default (empty) prefix becomes the graph's default namespace.** When the document declares a default prefix, such as `@prefix : <http://example.org/ontology#> .`, its IRI is recorded as the graph's default namespace, addressable with the `@:Name` shorthand (e.g. `MATCH (n@:Person)`), **not** as a row in `SHOW PREFIX`. Loading a file is the only way to set it: `LOAD PREFIX` always requires a name, so the default namespace can arrive only through `LOAD ONTOLOGY` or `LOAD DATA`. The **first** declaration wins; a later file with a different default namespace is ignored. See <a href="/docs/ontology/rdf-1.2#Default-Prefix-Queries-Name" target="_blank">RDF 1.2 → Default-prefix queries</a>.

`LOAD ONTOLOGY` imports the **schema triples** only: `owl:Ontology`, `owl:Class` / `rdfs:Class`, `owl:DatatypeProperty`, `owl:ObjectProperty` (and the OWL characteristic subclasses), plus their `rdfs:subClassOf` / `rdfs:domain` / `rdfs:range` / `owl:inverseOf` / `owl:Restriction` axioms. Any **instance triples** in the same file (subjects whose `rdf:type` is a user class like `foaf:Person`, e.g. `:alice a foaf:Person`) are silently skipped. To bring instance data into the graph, use [`LOAD DATA`](#Loading-Instance-Data); running both statements over the same mixed file is safe because each ignores the triples the other handles.

Load from a file on the GQLDB server, format auto-detected from the `.ttl` extension:

```gql
LOAD ONTOLOGY FROM 'file:///path/on/server/foaf.ttl'

-- FROM is optional when the source is an angle-bracketed IRI literal (below is equivalent)
LOAD ONTOLOGY <file:///path/on/server/foaf.ttl>
```

The file path is resolved by the GQLDB server: the file must exist on the **server's** filesystem (and the GQLDB process must have read permission). Loading from a server-local file is the most reliable form as it avoids network and TLS variability.

The loader auto-detects from the file extension (`.ttl` → TURTLE, `.owl`/`.rdf`/`.xml` → RDFXML, `.nt` → NTriples). Pass `FORMAT` explicitly only when auto-detection would guess wrong (e.g. a `.txt` file containing Turtle, or a server that returns a generic content type):

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/data.txt' FORMAT TURTLE
```

Supported `FORMAT` keywords: `OWL`, `RDFXML`, `TURTLE`, `NTRIPLES` (`OWL` and `RDFXML` both select the RDF/XML parser). `LOAD ONTOLOGY` does **not** accept `JSONLD`, `NQUADS`, or `TRIG`, use [`LOAD DATA`](#Loading-Instance-Data) for JSON-LD and quad formats.

`VERBOSE` surfaces parser warnings (unknown constructs, malformed triples) in the result message, useful when integrating a new ontology to surface silent compatibility issues:

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/foaf.ttl' VERBOSE
```

`FORMAT` and `VERBOSE` can be combined, but `FORMAT` must come first:

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/data.txt' FORMAT TURTLE VERBOSE
```

Loading from a URL is also supported. For `https://` URLs the host's TLS certificate must be trusted by the system trust store; plain `http://` skips TLS entirely. When `FORMAT` is omitted, the loader checks the response `Content-Type` header first, then the URL's file extension, and falls back to `RDFXML` if neither gives a hint.

```gql
LOAD ONTOLOGY FROM 'https://schema.org/version/latest/schemaorg-current-https.rdf'
```

> If a URL fetch fails with a TLS error, download the file once onto the GQLDB server and load.

## Projecting the Schema as a Graph

`LOAD ONTOLOGY GRAPH` materializes the ontology **schema** (the T-Box) as real, queryable nodes and edges. The ontology then *is* a graph: you can `MATCH` over its classes and properties, traverse the hierarchy, and visualize the schema in Manager alongside instance data.

```gql
LOAD ONTOLOGY GRAPH
```

It projects every class and property currently registered in the graph — whether imported via `LOAD ONTOLOGY` or defined inline with `CREATE CLASS` / `CREATE OBJECT PROPERTY` / `CREATE DATA PROPERTY` — into nodes and edges under the `@owl:` / `@rdfs:` meta-vocabulary (the `owl` and `rdfs` prefixes are auto-registered):

| Schema element | Becomes |
| -- | -- |
| Each class | a node labeled `@owl:Class` |
| Each object property | a node labeled `@owl:ObjectProperty` |
| Each data property | a node labeled `@owl:DatatypeProperty` |
| `SUBCLASS OF` | an `@rdfs:subClassOf` edge |
| `SUBPROPERTY OF` | an `@rdfs:subPropertyOf` edge |
| `DOMAIN` / `RANGE` | `@rdfs:domain` / `@rdfs:range` edges |
| `INVERSE OF` | an `@owl:inverseOf` edge |
| `EQUIVALENT TO` restrictions | `@owl:someValuesFrom` / `@owl:allValuesFrom` edges (carrying an `onProperty` property) |

Each schema node carries `_iri`, `name` (the local name), and `prefix`. The statement returns a `message` with the counts, e.g. `Materialized ontology graph: 14 schema nodes, 25 schema edges`.

Query the schema like any other graph — for example, list every class and its direct superclass:

```gql
MATCH (sub@owl:Class)-[@rdfs:subClassOf]->(super@owl:Class)
RETURN sub.name, super.name
```

> **Run it once, on a defined schema, before `LOAD DATA`.** The projection is **not** idempotent — it has no built-in cleanup, so running it again creates duplicate schema nodes and edges. Build the schema first, project it, then load instance data for a clean schema-first reveal.

## Loading Instance Data

`LOAD DATA` imports RDF **instance** triples (the data, not the schema) as graph nodes and edges. Use it to populate an ontology graph from an RDF file in one statement. Supported formats: `TURTLE`, `NTRIPLES`, `NQUADS`, `TRIG`, `JSONLD`. (`LOAD DATA` does **not** accept `RDFXML`.)

```gql
LOAD DATA FROM 'file:///path/on/server/instances.ttl' FORMAT TURTLE
```

The file path resolves on the **GQLDB server**'s filesystem, the same as `LOAD ONTOLOGY`. URL sources are also supported. Format is auto-detected from the `.ttl` / `.nt` extension when `FORMAT` is omitted.

Triple-to-graph mapping:

| Triple shape | Becomes |
| -- | -- |
| `(s, rdf:type, C)` | node `s` gets the ontology label for class `C` |
| `(s, p, "literal")` | data property `p` on node `s` (xsd-coerced when typed) |
| `(s, p, "a"), (s, p, "b")` (repeated literal) | list-valued property `p = ['a','b']` |
| `(s, p, o)` where `o` is an IRI | edge `(s)-[:p]->(o)` |
| `rdfs:label` / `dc:title` / `foaf:name` | also copied to a readable `name` / `title` |

Every node is keyed by its subject IRI (stored as `_iri`), so repeated mentions of a subject merge onto one node and edges resolve regardless of triple order. Bare Turtle literals are typed (`30` → integer, `true` → boolean), and a predicate repeated on one subject (a multivalued slot) folds into a list rather than keeping only the last value. Classes named in `rdf:type` that aren't declared yet are auto-registered (under `WARNING` / `OFF` enforcement), and document `@prefix` declarations are registered so `@prefix:Local` labels resolve in `MATCH`. Imported data persists across restart.

> **RDF 1.2 details.** `LOAD DATA` preserves RDF 1.2 literal metadata (language tags, base direction, datatype IRIs), handles blank nodes and collections, imports named graphs (N-Quads / TriG) and JSON-LD, and supports triple terms (RDF-star). The graph also exports back to RDF with `EXPORT … FORMAT`. See [RDF 1.2 Features](/docs/ontology/rdf-1.2) for the full reference.

**Schema vs. data — split or combined.** A typical workflow keeps the schema file separate from the data file and loads them in order:

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/personinfo.owl.ttl' FORMAT TURTLE
LOAD DATA     FROM 'file:///srv/onto/instances.ttl'     FORMAT TURTLE
```

If schema and data live in the **same** file, run both statements over it — `LOAD ONTOLOGY` picks up the schema triples and ignores the rest, while `LOAD DATA` picks up the instances. Each ignores what the other handles, so there's no double-import.
