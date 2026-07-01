# Introduction

## Overview

GQLDB supports ontology features that bring semantic web capabilities to your graph database.

### Key Concepts

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

Prefixes are loaded per-graph. After creating an ontology graph, you start with no prefixes loaded. To load prefixes:

```gql
-- Load all built-in standard prefixes (foaf, rdf, rdfs, owl, xsd, etc.)
LOAD ALL PREFIX

-- Load common vocabularies
LOAD PREFIX foaf FROM 'http://xmlns.com/foaf/0.1/'
LOAD PREFIX ex FROM 'http://example.org/'
LOAD PREFIX rdfs FROM 'http://www.w3.org/2000/01/rdf-schema#'

-- FROM also accepts an IRI literal (angle-bracketed)
LOAD PREFIX foaf FROM <http://xmlns.com/foaf/0.1/>
```

To bulk-load all prefixes declared in an RDF document at a URL or file path:

```gql
LOAD PREFIX ALL FROM 'http://xmlns.com/foaf/spec/index.rdf'
LOAD PREFIX ALL FROM <http://xmlns.com/foaf/spec/index.rdf>
LOAD PREFIX ALL FROM 'file:///srv/onto/foaf.ttl'
```

A few things follow from this:

- The prefix is just your local alias for the full IRI. `LOAD PREFIX bigbird FROM 'http://xmlns.com/foaf/0.1/'` works, and `@bigbird:Person` then means the same FOAF Person that `@foaf:Person` would. By convention, reuse the community-standard names (`foaf`, `rdfs`, `schema`, `ex`).
- Identity is by full IRI, not by short name. FOAF's `Person` (`http://xmlns.com/foaf/0.1/Person`) and Schema.org's `Person` (`http://schema.org/Person`) are distinct classes in the database even though both spell their local name `Person`; the prefix is what keeps them apart. A single node can be tagged as both without contradiction.

View loaded prefixes:

```gql
SHOW PREFIX
```

Drop a prefix:

```gql
DROP PREFIX foaf
```

After dropping a prefix, ontology labels that referenced it (`@foaf:Person`, etc.) no longer resolve at parse time and queries using the short form fail. Any nodes / edges already stored under the prefix's full IRIs remain in the graph (the database stores IRIs, not the short name); re-`LOAD PREFIX foaf FROM '…'` to address them by short form again.

## Loading Ontologies & Data

Populate an external ontologies and data from RDF documents. See <a href="/docs/ontology/loading" target="_blank">Loading Ontologies & Data</a>.

## Inspecting & Visualizing

Inspect loaded or defined ontologies, or project it as a queryable graph. See <a href="/docs/ontology/inspecting" target="_blank">Inspecting & Visualizing Ontologies</a>.