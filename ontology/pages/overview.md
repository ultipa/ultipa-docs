# Ontology

## Overview

GQLDB supports ontology features that bring semantic web capabilities to your graph database. This allows you to define classes, properties with domain/range constraints, and enable inference based on class hierarchies.

**Key Concepts:**

- **Classes** - Define types for nodes with inheritance (EXTENDS) and exclusivity (DISJOINT)
- **Object Properties** - Define edge types with domain/range constraints and characteristics (SYMMETRIC, TRANSITIVE)
- **Data Properties** - Define typed properties on nodes with XSD types
- **Prefixes** - Shorthand for IRI namespaces (like foaf: for FOAF vocabulary)
- **Inference** - Automatic classification based on class hierarchies

## LPG vs Ontology Graph

| Feature | LPG (Labeled Property Graph) | Ontology Graph |
| -- | -- | -- |
| Node labels | Free-form labels | Ontology class labels (@prefix:Class) |
| Edge types | Free-form types | Object properties with domain/range |
| Schema | Optional (open graph) or defined (closed graph) | Class and property definitions |
| Inference | None | Subclass inference, property characteristics |
| Validation | Type checking only | Domain, range, cardinality, disjoint checks |

## Creating an Ontology Graph

Create a graph with ontology support enabled:

```gql
CREATE GRAPH my_ontology_graph ONTOLOGY
```

## Loading Prefixes

Prefixes provide shorthand for IRI namespaces. Load common vocabularies:

```gql
// Load common prefixes
LOAD PREFIX foaf FROM 'http://xmlns.com/foaf/0.1/'
LOAD PREFIX ex FROM 'http://example.org/'
LOAD PREFIX rdfs FROM 'http://www.w3.org/2000/01/rdf-schema#'
```

View loaded prefixes:

```gql
SHOW PREFIXES
```

| prefix | iri |
| -- | -- |
| foaf | http://xmlns.com/foaf/0.1/ |
| ex | http://example.org/ |
| rdfs | http://www.w3.org/2000/01/rdf-schema# |

## Loading External Ontologies

Import ontology definitions from OWL/RDF files:

```gql
// Load FOAF ontology from URL
LOAD ONTOLOGY FROM 'http://xmlns.com/foaf/spec/index.rdf'
```

```gql
// Load from local file
LOAD ONTOLOGY FROM 'file:///path/to/my-ontology.owl'
```

```gql
// Load with specific format
LOAD ONTOLOGY FROM 'http://example.org/onto.ttl' FORMAT 'turtle'
```

## Viewing Ontology Information

View defined classes:

```gql
SHOW CLASSES
```

| class | superclass | description |
| -- | -- | -- |
| @foaf:Person | @foaf:Agent | A person |
| @foaf:Organization | @foaf:Agent | An organization |
| @ex:Employee | @foaf:Person | An employee |

View defined properties:

```gql
SHOW PROPERTIES
```

| property | type | domain | range | characteristics |
| -- | -- | -- | -- | -- |
| @foaf:knows | OBJECT | @foaf:Person | @foaf:Person | SYMMETRIC |
| @ex:worksFor | OBJECT | @foaf:Person | @foaf:Organization | |
| @foaf:name | DATA | @foaf:Agent | xsd:string | |

See the following pages for detailed information:

- [Class Definitions](/docs/ontology/class-definitions)
- [Property Definitions](/docs/ontology/property-definitions)
- [Using Ontology Labels](/docs/ontology/label-syntax)
- [Validation & Enforcement](/docs/ontology/validation)
