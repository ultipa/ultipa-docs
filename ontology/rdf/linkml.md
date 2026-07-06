# Loading LinkML Schemas and Data

## Overview

<a target="_blank" href="https://linkml.io/">LinkML</a> (Linked data Modeling Language) is a YAML-based data modeling language widely used in biomedical and research data communities. A LinkML schema defines:

- **Classes**: entity types (e.g., `Person`, `Gene`)
- **Slots**: attributes and relationships, with `range`, `required`, `multivalued`, `inverse`, `symmetric`, etc.
- **Types**: primitive datatypes
- **Enums**: controlled vocabularies, optionally mapped to ontology terms via `meaning:`
- **Prefixes**: CURIE-to-URI mappings
- Inheritance via `is_a` and `mixins`

GQLDB has no dedicated LinkML importer; instead, LinkML enters through the existing RDF import path: the schema compiles to an **OWL ontology** and the data converts to **instance triples**; both serialized as RDF (Turtle), loaded with the `LOAD ONTOLOGY` and `LOAD DATA` statements. No special LinkML statement is required, and LinkML's relational slot facets map almost one-to-one onto GQLDB's ontology features.

## The Workflow

LinkML ships a Python toolchain (`pipx install linkml`). Convert once, then load the generated artifacts.

**Step 1**: Schema → OWL (Turtle is `gen-owl`'s default serialization)

```bash
gen-owl personinfo.yaml -f ttl > personinfo.owl.ttl
```

**Step 2**: Data → RDF Turtle (the schema drives identifier/predicate IRIs)

```bash
linkml-convert -s personinfo.yaml -o data.ttl data.yaml
```

**Step 3**: Load schema + data into an ontology graph in GQLDB

```gql
CREATE GRAPH people WITH ONTOLOGY
USE people
LOAD ONTOLOGY FROM 'file:///path/personinfo.owl.ttl'
LOAD DATA     FROM 'file:///path/data.ttl'
```

`LOAD ONTOLOGY` imports the schema triples (classes, properties, restrictions); `LOAD DATA` imports the instance triples (the data), see <a href="/docs/ontology/rdf-import-and-export" target="_blank">RDF Import & Export</a>.

**Step 4**: Query with the LinkML class/slot vocabulary

```gql
MATCH (n@personinfo:Person) RETURN n.name
MATCH (a@personinfo:Person)-[@personinfo:knows]->(b) RETURN a.name, b.name
```

## How LinkML Maps to GQLDB

| LinkML construct | `gen-owl` / `linkml-convert` emits | GQLDB result |
| -- | -- | -- |
| `class` | `owl:Class` (default-prefix IRI) | ontology class `@prefix:Class` |
| `is_a`, `mixins` | `rdfs:subClassOf` (named) | superclass → <a href="/docs/ontology/classes#SUBCLASS-OF" target="_blank">subclass inference</a> |
| relationship slot (`range:` a class) | `owl:ObjectProperty` + `owl:Restriction allValuesFrom` | object property (`DOMAIN` + `RANGE`) |
| attribute slot (`range:` a type/enum) | `owl:DatatypeProperty` | data property |
| `identifier: true` slot | the object's subject IRI | node `_iri` |
| `required: true` | `owl:minCardinality 1` restriction | `CARDINALITY {1,}` (required, enforced) |
| single-valued slot | `owl:maxCardinality 1` restriction | `CARDINALITY {,1}` (functional, enforced) |
| `multivalued: true` | no max-cardinality / repeated triples | unbounded; data → list property or multiple edges |
| `symmetric: true` | `owl:SymmetricProperty` | <a href="/docs/ontology/object-properties#SYMMETRIC" target="_blank">symmetric inference</a> |
| `inverse:` | `owl:inverseOf` | inverse inference |
| `transitive` / `reflexive` / `irreflexive` / `asymmetric` | `owl:*Property` | OWL <a href="/docs/ontology/object-properties#Property-Characteristics" target="_blank">property characteristics</a> |
| `enum` value with `meaning:` | the value's `meaning` IRI in data | edge to the term node (a plain value stays a literal) |

In the data, a `rdf:type` triple becomes the node's ontology label, literal objects become (xsd-typed) data properties, and IRI-valued objects become edges.

## Formats and Limitations

- **Use Turtle for the LinkML workflow.** The schema must go through `LOAD ONTOLOGY`, which accepts `OWL` / `RDFXML` / `TURTLE` / `NTRIPLES` (not JSON-LD), so emit Turtle for both artifacts (`gen-owl -f ttl`, `linkml-convert -o data.ttl …`). `LOAD DATA` additionally accepts `NQUADS`, `TRIG`, and `JSONLD`, but there is no need to use them for a LinkML import.
- **RDF/XML is partial.** `gen-owl -f xml` loads classes, named `is_a` / `mixins` superclasses, characteristics, and inverses, but **not** the blank-node `owl:Restriction` cardinality axioms. Cardinality (`required` / single-valued) is captured from **Turtle** only — prefer the Turtle output.
- **External `class_uri` / `slot_uri`.** If your slots / classes map to an external vocabulary (e.g., `class_uri: schema:Person`), `linkml-convert` types and predicates the *data* with those URIs (`schema:Person`), while `gen-owl` keeps the native `personinfo:` URIs in the OWL (linked by `skos:exactMatch`). Both vocabularies resolve as labels automatically (the document declares `personinfo:`, and `schema:` is a built-in standard prefix seeded on load), but the data is still typed `@schema:Person`, so avoid external `*_uri` overrides when you want `MATCH (n@personinfo:Class)` to find the instances.
- **Not imported / not enforced.** LinkML rules that compile to `owl:propertyChainAxiom`, and pure-LinkML validation facets (`pattern`, `minimum_value`, `maximum_value`) that have no OWL characteristic, are not captured. See [Enforcement](#Enforcement) below for the characteristics GQLDB does enforce.

## Enforcement

Loading a LinkML schema brings its `required` and cardinality constraints with it. Under `STRICT` enforcement, inserting a `Person` without a required `name` (or a second value for a single-valued slot) is rejected; under the default `WARNING` mode it is recorded in `SHOW ONTOLOGY WARNINGS`. Set the mode per graph:

```gql
SET ONTOLOGY ENFORCEMENT STRICT
```

See <a href="/docs/ontology/inference-and-validation" target="_blank">Inference & Validation</a> for the full enforcement model, the validation types, and `VALIDATE ONTOLOGY`.
