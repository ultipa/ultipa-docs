# Introduction

## Overview

GQLDB supports ontology features that bring semantic web capabilities to your graph database.

### Key Concepts

- **RDF**: The Resource Description Framework — the W3C data model this builds on. Every fact is a triple (subject–predicate–object, e.g. `ex:alice ex:knows ex:bob`); subjects and predicates are IRIs, objects are IRIs or literals, and a set of triples forms a graph.
- **IRI Identity**: Classes, properties, and individuals are identified by globally unique IRIs, addressed in queries via the `@prefix:LocalName` shorthand.
- **Prefixes**: Local aliases for IRI namespaces, such as `foaf:` → `http://xmlns.com/foaf/0.1/`.
- **Classes**: Node types organized by `SUBCLASS OF` hierarchy, `DISJOINT WITH` exclusivity, `EQUIVALENT TO` membership etc..
- **Object Properties**: Edge types with `DOMAIN` / `RANGE` and OWL characteristics (`SYMMETRIC`, `TRANSITIVE`, `FUNCTIONAL`, `INVERSE OF`, etc.).
- **Data Properties**: XSD-typed node attributes (`xsd:string`, `xsd:integer`, etc.), optionally constrained by cardinality.
- **Ontologies**: Formal, explicit specification of a shared conceptualization containing classes, properties, and the axioms that constrain how they relate.

### LPG vs Ontology Graph

| Feature | LPG (Labeled Property Graph) | Ontology Graph |
| -- | -- | -- |
| **Identity** | Local identifier | Global IRI (`foaf`, `ex`) |
| **Node Labels** | Free-form labels | Ontology class labels (`@prefix:Class`)|
| **Edge Labels** | Free-form labels | Object properties |
| **Node Attributes** | Free-form key / value | Data properties |
| **Edge attributes** | Free-form key / value | None |
| **Schema** | Schemaless (open) or label-typed (closed) | Classes and properties with OWL axioms |
| **Inference** | None; what you store is what you query | Subclass closure, OWL characteristics, and class / property constructors (union, intersection, oneOf, equivalence), at query time |

## Creating Ontology Graphs

Create a graph with ontology support:

```gql
CREATE GRAPH myOntology WITH ONTOLOGY
```

## Loading Prefixes

A **prefix** is a short alias for a long IRI (Internationalized Resource Identifier). Ontology terms are identified by full IRIs, a prefix lets you write a short name instead.

For example, after loading `foaf` as an alias for `http://xmlns.com/foaf/0.1/`, the term `<http://xmlns.com/foaf/0.1/Person>` can be written as the ontology label `@foaf:Person` in GQL graph patterns.

Prefixes are loaded per-graph. After creating an ontology graph, you start with no prefixes loaded.

### Standard Prefixes

Load all built-in standard prefixes:

```gql
LOAD ALL PREFIX
```

It registers the built-in standard set below in one step. These cover the common RDF, RDFS, OWL, and vocabulary namespaces:

| Prefix | Namespace IRI |
| -- | -- |
| `rdf` | `http://www.w3.org/1999/02/22-rdf-syntax-ns#` |
| `rdfs` | `http://www.w3.org/2000/01/rdf-schema#` |
| `owl` | `http://www.w3.org/2002/07/owl#` |
| `xsd` | `http://www.w3.org/2001/XMLSchema#` |
| `foaf` | `http://xmlns.com/foaf/0.1/` |
| `schema` | `http://schema.org/` |
| `dc` | `http://purl.org/dc/elements/1.1/` |
| `dcterms` | `http://purl.org/dc/terms/` |
| `skos` | `http://www.w3.org/2004/02/skos/core#` |
| `prov` | `http://www.w3.org/ns/prov#` |
| `geo` | `http://www.opengis.net/ont/geosparql#` |
| `time` | `http://www.w3.org/2006/time#` |
| `dcat` | `http://www.w3.org/ns/dcat#` |
| `org` | `http://www.w3.org/ns/org#` |

Any prefix outside this set (e.g. a domain vocabulary like `dbo`) must be loaded explicitly with `LOAD PREFIX`.

### Loading a Prefix

To load a prefix:

```gql
-- Load a vocabulary outside the standard set (prefix name + namespace IRI)
LOAD PREFIX ex FROM 'http://example.org/'
LOAD PREFIX dbo FROM 'http://dbpedia.org/ontology/'

-- FROM also accepts an IRI literal (angle-bracketed)
LOAD PREFIX dbo FROM <http://dbpedia.org/ontology/>
```

### Bulk-Loading from an RDF Document

To bulk-load all prefixes declared in an RDF document at a URL or file path:

```gql
LOAD PREFIX ALL FROM 'http://xmlns.com/foaf/spec/index.rdf'
LOAD PREFIX ALL FROM <http://xmlns.com/foaf/spec/index.rdf>
LOAD PREFIX ALL FROM 'file:///srv/onto/foaf.ttl'
```

### Aliases and IRI Identity

A few things follow from prefixes being local aliases:

- The prefix is just your local alias for the full IRI. `LOAD PREFIX bigbird FROM 'http://xmlns.com/foaf/0.1/'` works, and `@bigbird:Person` then means the same FOAF Person that `@foaf:Person` would. By convention, reuse the community-standard names (`foaf`, `rdfs`, `schema`, `ex`).
- Identity is by full IRI, not by short name. FOAF's `Person` (`http://xmlns.com/foaf/0.1/Person`) and Schema.org's `Person` (`http://schema.org/Person`) are distinct classes in the database even though both spell their local name `Person`; the prefix is what keeps them apart. A single node can be tagged as both without contradiction.

### Viewing Prefixes

View loaded prefixes:

```gql
SHOW PREFIX
```

### Dropping Prefixes

Drop a prefix:

```gql
DROP PREFIX foaf
```

After dropping a prefix, ontology labels that referenced it (`@foaf:Person`, etc.) no longer resolve at parse time and queries using the short form fail. Any nodes / edges already stored under the prefix's full IRIs remain in the graph (the database stores IRIs, not the short name); re-`LOAD PREFIX foaf FROM '…'` to address them by short form again.

## RDF

Import external ontologies and RDF data into a graph and export it back out, and work with RDF data-model features (literals, blank nodes, named graphs, triple terms, etc.). See <a href="/docs/ontology/rdf-import-and-export" target="_blank">RDF Import & Export</a> and <a href="/docs/ontology/working-with-rdf" target="_blank">Working with RDF</a>.

## Classes & Properties

Define the ontology's building blocks: classes and their object / data properties, with hierarchy, characteristics, and constraints. See <a href="/docs/ontology/classes" target="_blank">Classes</a>, <a href="/docs/ontology/object-properties" target="_blank">Object Properties</a>, and <a href="/docs/ontology/data-properties" target="_blank">Data Properties</a>.

## Inspecting & Visualizing

Inspect loaded or defined ontologies, or project it as a queryable graph. See <a href="/docs/ontology/inspecting" target="_blank">Inspecting & Visualizing Ontologies</a>.