# Introduction

GQLDB supports ontology features that bring semantic web capabilities to your graph database. This allows you to define classes, properties with domain/range constraints, and enable inference based on class hierarchies.

## Key Concepts

- **Classes**: Define types for nodes with inheritance (`SUBCLASS OF`) and exclusivity (`DISJOINT WITH`).
- **Object Properties**: Define edge types with domain/range constraints and characteristics (SYMMETRIC, TRANSITIVE).
- **Data Properties**: Define typed properties on nodes with XSD types.
- **Prefixes**: Shorthand for IRI namespaces (like `foaf:` for FOAF vocabulary).
- **Inference**: Automatic classification based on class hierarchies.

## LPG vs Ontology Graph

| Feature | LPG (Labeled Property Graph) | Ontology Graph |
| -- | -- | -- |
| Node labels | Free-form labels | Ontology class labels (`@prefix:Class`) |
| Edge types | Free-form types | Object properties with domain/range |
| Schema | Optional (open graph) or defined (closed graph) | Class and property definitions |
| Inference | None | Subclass inference, property characteristics |
| Validation | Type checking only | Domain, range, cardinality, disjoint checks |

## Creating Ontology Graphs

Create a graph with ontology support enabled:

```gql
CREATE GRAPH my_ontology_graph WITH ONTOLOGY
```

## Loading Prefixes

A **prefix** is a short alias for a long IRI (Internationalized Resource Identifier — a URL used as a globally unique identifier). Ontology terms are identified by full IRIs, a prefix lets you write a short name instead.

For example, after loading `foaf` as an alias for `http://xmlns.com/foaf/0.1/`, the term `<http://xmlns.com/foaf/0.1/Person>` can be written as the ontology label `@foaf:Person` in GQLDB patterns.

A few things follow from this:

- Prefixes are **per-graph** state. After `CREATE GRAPH … WITH ONTOLOGY` you start with no prefixes loaded; load the built-ins with `LOAD ALL PREFIX` and any others you need with `LOAD PREFIX ... FROM …`.
- The prefix name is just a local handle. Convention reuses the names the rest of the semantic-web community uses (`foaf`, `rdfs`, `schema`, `ex`) so that snippets translate between systems, but the choice is yours.
- Two graphs from different sources can both define a class named `Person`, but `http://xmlns.com/foaf/0.1/Person` and `http://schema.org/Person` are distinct concepts. Prefixes are how you keep them apart while still writing readable queries.

Load common vocabularies one at a time:

```gql
// Load common prefixes
LOAD PREFIX foaf FROM 'http://xmlns.com/foaf/0.1/'
LOAD PREFIX ex FROM 'http://example.org/'
LOAD PREFIX rdfs FROM 'http://www.w3.org/2000/01/rdf-schema#'
```

The `FROM` clause also accepts an IRI literal (angle-bracketed) instead of a quoted string:

```gql
LOAD PREFIX foaf FROM <http://xmlns.com/foaf/0.1/>
```

Or load all built-in standard prefixes (foaf, rdf, rdfs, owl, xsd, etc.) in one statement:

```gql
LOAD ALL PREFIX
```

View loaded prefixes:

```gql
SHOW PREFIX
```

## Loading External Ontologies

An **external ontology** is a vocabulary file authored outside of GQLDB, typically published by a standards body or community containing class hierarchies, property definitions, prefix declarations, and constraints in a serialization like OWL, Turtle, RDF/XML, or JSON-LD. Common examples include FOAF (people and social relations), Schema.org (web-structured-data terms used by Google), SKOS (concept schemes), Dublin Core (metadata terms), and PROV-O (provenance).

`LOAD ONTOLOGY FROM 'file:///<path>'` reads such a file and registers everything inside in one shot, saving you from defining classes and properties for each term by hand. `<path>` is resolved by the GQLDB server: the file must exist on the **server's** filesystem (and the GQLDB process must have read permission). Loading from a server-local file is the most reliable form as it avoids network and TLS variability.

Load from a file on the GQLDB server, format auto-detected from the `.ttl` extension:

```gql
LOAD ONTOLOGY FROM 'file:///path/on/server/foaf.ttl'
```

The loader auto-detects from the file extension (`.ttl` → TURTLE, `.owl`/`.rdf`/`.xml` → RDFXML, `.nt` → NTriples). Pass `FORMAT` explicitly only when auto-detection would guess wrong (e.g. a `.txt` file containing Turtle, or a server that returns a generic content type):

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/data.txt' FORMAT TURTLE
```

Supported `FORMAT` keywords: `OWL`, `TURTLE`, `RDFXML`, `JSONLD`.

`VERBOSE` surfaces parser warnings (unknown constructs, malformed triples) in the result message — useful when integrating a new ontology to surface silent compatibility issues:

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

## Viewing Ontologies

```gql
SHOW ONTOLOGY
```

Example output:

| name | iri | classes | objectProperties | dataProperties |
| -- | -- | -- | -- | -- |
| FOAF | http://xmlns.com/foaf/0.1/ | 14 | 25 | 19 |
| local | urn:local:my_ontology_graph | 3 | 1 | 2 |

It lists every ontology in the current graph with summary counts. It covers **both** imports and inline definitions:

- One row per `LOAD ONTOLOGY` import, named after the source IRI.
- One additional `"local"` row (IRI `urn:local:<graphName>`) if you've defined any classes and properties.

Related `SHOW` commands for finer views:

| Command | Returns |
| -- | -- |
| `SHOW PREFIX` | Loaded prefix → IRI mappings |
| `SHOW CLASSES` | Every class, with `localName`, `superClasses`, `label` |
| `SHOW PROPERTIES` | Every object/data property, with `localName`, `type`, `domain`, `range`, `characteristics` |