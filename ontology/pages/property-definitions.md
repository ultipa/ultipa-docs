# Property Definitions

## Overview

A **property** in an ontology is a globally-identified, schema-bound description of either an edge or a node attribute. It carries the same kind of semantic structure as a <a href="/docs/ontology/class-definitions">class</a>.

Two flavors:

- **Object property**: an ontology-typed **edge**. It connects two nodes and is constrained by optional `DOMAIN` (the source class) and `RANGE` (the target class). Object properties can be marked `SYMMETRIC`, `TRANSITIVE`, or `FUNCTIONAL`, declared `INVERSE OF` another property, and given `CARDINALITY {min, max}` bounds.
- **Data property**: an ontology-typed **node attribute** with a typed value. It has a `DOMAIN` (the class that may carry the attribute) and a `RANGE` that is an XSD datatype (`xsd:string`, `xsd:integer`, `xsd:date`, …). Example: `@foaf:name DOMAIN @foaf:Agent RANGE xsd:string`.

How it compares to plain LPG edges/properties:

| | LPG edge / property | Ontology object / data property |
| -- | -- | -- |
| Identity | Local string (`"KNOWS"`, `"name"`) | Global IRI (`@foaf:knows`, `@foaf:name`) |
| Endpoint constraint | None | `DOMAIN` and `RANGE` validated by the engine |
| Type constraint | None (any value) | `RANGE xsd:type` for data properties |
| Inference | None | `SYMMETRIC` / `TRANSITIVE` / `INVERSE OF` add inferred edges; subclass inference applies through the hierarchy |
| Cardinality | None | `CARDINALITY {min, max}` and `FUNCTIONAL` |

Mental model: an LPG edge is just a typed wire between two nodes, and an LPG property is a free-form key/value. An ontology object property is a wire that **also** says where it's allowed to start and end and how it behaves under inference; an ontology data property is an attribute that **also** says which classes it belongs to and what type its value must be — and the database uses those declarations during query and validation.

## Creating Object Properties

Object properties define **edge types**.

<p tit="Syntax"></p>

```
<create object property statement> ::=
  "CREATE OBJECT PROPERTY" <object property name> 
  [ "DOMAIN" <source class> [ "RANGE" <target class> ] ]
  [ <property characteristics> | <inverse properties> | <cardinality constraints> ] 

<property characteristics> ::= 
    "SYMMETRIC" | "TRANSITIVE" | "FUNCTIONAL"  
  | "SYMMETRIC TRANSITIVE" | "FUNCTIONAL SYMMETRIC" | "FUNCTIONAL TRANSITIVE"

<inverse properties> ::=
    "INVERSE OF" <object property> ["TRANSITIVE" ]
  | "TRANSITIVE" "INVERSE OF" <object property>

<cardinality constraints> ::= "CARDINALITY" "{" <min> "," <max> "}"
```

The minimal form just registers the property identity:

```gql
CREATE OBJECT PROPERTY @ex:links
```

With no `DOMAIN` or `RANGE`, the engine performs no endpoint validation: `@ex:links` may connect any two nodes (ontology-classed, unlabeled, or plain LPG-labeled, in any combination).

### DOMIAN and RANGE

`DOMAIN` (source class) and `RANGE` (target class) are both optional and independent. When present, the engine validates that edges of this property go from a node of the domain class to a node of the range class:

> The classes named in `DOMAIN` and `RANGE` do not need to exist when the property is created, they are stored as IRIs and only checked at insert/match time. Only the **prefix** must be loaded.

```gql
-- Person knows Person
CREATE OBJECT PROPERTY @ex:knows DOMAIN @ex:Person RANGE @ex:Person

-- Person works for Organization
CREATE OBJECT PROPERTY @ex:worksFor DOMAIN @ex:Person RANGE @foaf:Organization

-- Only the source is constrained, RANGE can be anything
CREATE OBJECT PROPERTY @ex:owns DOMAIN @ex:Person
```

### Property Characteristics

Properties can have special characteristics that affect behavior. The DDL keywords below can be set when creating an object property:

| Characteristic | Description |
| -- | -- |
| `SYMMETRIC` | If A→B exists, B→A is inferred |
| `TRANSITIVE` | If A→B and B→C exist, A→C is inferred |
| `FUNCTIONAL` | Each node can have at most one outgoing edge for this property |

> Reflexive, irreflexive, and inverse-functional characteristics are recognised when loading external OWL ontologies (`owl:ReflexiveProperty`, `owl:IrreflexiveProperty`, `owl:InverseFunctionalProperty`) but are not exposed as DDL keywords — declare them in the source ontology and import via `LOAD ONTOLOGY`.

#### SYMMETRIC

Insert one direction; the reverse is inferred.

```gql
-- knows is symmetric: if A knows B, B knows A
CREATE OBJECT PROPERTY @ex:knows DOMAIN @ex:Person RANGE @ex:Person SYMMETRIC

-- Insert Lee -> Julia
INSERT (:@ex:Person {name: 'Lee'})-[:@ex:knows]->(:@ex:Person {name: 'Julia'})

-- Match knows relationships
MATCH (a)-[:@ex:knows]->(b) RETURN a.name, b.name  // (Lee, Julia) and (Julia, Lee)
```

#### TRANSITIVE

Insert a chain; the end-to-end edge is inferred.

```gql
-- ancestorOf is transitive: if A ancestor of B, B ancestor of C, then A ancestor of C
CREATE OBJECT PROPERTY @ex:ancestorOf DOMAIN @ex:Person RANGE @ex:Person TRANSITIVE 

-- Insert D->C->B->A
INSERT (@ex:Person {name: 'D'})-[@ex:ancestorOf]->(@ex:Person {name: 'C'})-[@ex:ancestorOf]->(@ex:Person {name: 'B'})-[@ex:ancestorOf]->(@ex:Person {name: 'A'})

-- Match C->A
MATCH p = (@ex:Person {name: 'C'})-[@ex:ancestorOf]->(@ex:Person {name: 'A'}) 
RETURN p  // C->A

-- Match D->A
MATCH p = (@ex:Person {name: 'D'})-[@ex:ancestorOf]->(@ex:Person {name: 'A'}) 
RETURN p  // D->A
```

Transitive inference is bounded by a per-graph **maximum expansion depth**; chains longer than the limit are not inferred.

- **Default**: `10` hops. With the default, K→...→A over 10 intermediate `@ex:ancestorOf` edges still infers K→A, but a 11-hop chain (L→A) does not.
- **Configurable** with `SET ONTOLOGY TRANSITIVE DEPTH <N>`. The value must be a positive integer (`1, 2, 3, …`) or the sentinel `-1` for unbounded expansion. Any other value is rejected.

```gql
-- Limit transitive expansion to 25 levels
SET ONTOLOGY TRANSITIVE DEPTH 25

-- Remove the limit (full transitive closure)
SET ONTOLOGY TRANSITIVE DEPTH -1
```

Cycles are detected at traversal time, so a closed loop in the chain does not cause infinite expansion regardless of the configured depth.

#### FUNCTIONAL

Each source node may have at most one outgoing edge of this property. Under `STRICT` enforcement a second insert fails; under the default `WARNING` mode it is logged but proceeds.

```gql
SET ONTOLOGY ENFORCEMENT STRICT

-- hasBirthPlace is functional: a person has only one birthplace
CREATE OBJECT PROPERTY @ex:hasBirthPlace DOMAIN @ex:Person RANGE @ex:Location FUNCTIONAL

-- Insert Jeff -> Boston
INSERT (@ex:Person {name: 'Jeff'})-[:@ex:hasBirthPlace]->(@ex:Location {name: 'Boston'})

-- Insert Jeff -> Boston 
-- FUNCTIONAL violation error: Jeff cannot have two hasBirthPlace edges
MATCH (jeff@ex:Person {name: 'Jeff'})
INSERT (jeff)-[@ex:hasBirthPlace]->(@ex:Location {name: 'Chicago'})
```

### Inverse Properties

Define inverse relationships. When you create one edge, the inverse is automatically inferred.

```gql
-- worksFor and employs are inverses
CREATE OBJECT PROPERTY @ex:worksFor DOMAIN @ex:Person RANGE @ex:Organization
CREATE OBJECT PROPERTY @ex:employs DOMAIN @ex:Organization RANGE @ex:Person INVERSE OF @ex:worksFor

-- Insert Emily worksFor Acme Inc
INSERT (@ex:Person {name: 'Emily'})-[@ex:worksFor]->(@ex:Organization {name: 'Acme Inc'})

-- Query the inverse with employs edge
MATCH p = (org)-[@ex:employs]->(person)
RETURN p  // Acme Inc -> Emily
```

### Cardinality Constraints

Use `CARDINALITY {min, max}` to limit how many outgoing edges of a property a source node may have. `*` denotes "unbounded". Cardinality is enforced for object properties at insert time.

```gql
// Exactly one: every country has exactly one capital
CREATE OBJECT PROPERTY @ex:hasCapital
  DOMAIN @ex:Country
  RANGE @ex:City
  CARDINALITY {1,1}
```

```gql
// Up to N: between 0 and 5 pets
CREATE OBJECT PROPERTY @ex:hasPet
  DOMAIN @ex:Person
  RANGE @ex:Pet
  CARDINALITY {0,5}
```

```gql
// Unbounded: zero or more friends
CREATE OBJECT PROPERTY @ex:hasFriend
  DOMAIN @ex:Person
  RANGE @ex:Person
  CARDINALITY {0,*}
```

`FUNCTIONAL` is a shorthand for `CARDINALITY {0,1}`:

```gql
// A person can have at most one spouse
CREATE OBJECT PROPERTY @ex:hasSpouse
  DOMAIN @ex:Person
  RANGE @ex:Person
  FUNCTIONAL
```

## Creating Data Properties

Data properties define attributes with XSD types. Both `DOMAIN` and `RANGE` are optional, and `RANGE` takes the XSD type.

<p tit="Syntax"></p>

```
<create data property statement> ::=                      
  "CREATE DATA PROPERTY" <data property name> 
  [ 
      "DOMAIN" <class> [ "RANGE" <xsd type> [ <cardinality constraints> ] ]
    | "RANGE" <xsd type> [ <cardinality constraints> ]
    | <cardinality constraints>
  ]

<xsd type> ::= "xsd:" <type name>

<cardinality constraints> ::= "CARDINALITY" "{" <min> "," <max> "}"
```

```gql
-- String properties
CREATE DATA PROPERTY @foaf:name DOMAIN @foaf:Agent RANGE xsd:string

-- Numeric properties
CREATE DATA PROPERTY @foaf:age DOMAIN @foaf:Person RANGE xsd:integer
CREATE DATA PROPERTY @ex:salary DOMAIN @ex:Employee RANGE xsd:decimal

-- Datetime properties
CREATE DATA PROPERTY @ex:birthDate DOMAIN @ex:Person RANGE xsd:date
CREATE DATA PROPERTY @ex:createdAt DOMAIN @ex:Document RANGE xsd:dateTime

-- Boolean properties
CREATE DATA PROPERTY @ex:isActive DOMAIN @ex:Account RANGE xsd:boolean
```

Data properties accept the same `CARDINALITY {min, max}` clause as object properties:

```gql
-- Required, single-valued: every Person must have exactly one name
CREATE DATA PROPERTY @ex:fullName
  DOMAIN @ex:Person
  RANGE xsd:string
  CARDINALITY {1,1}

-- Multi-valued: a Person may carry up to 3 email addresses
CREATE DATA PROPERTY @ex:email
  DOMAIN @ex:Person
  RANGE xsd:string
  CARDINALITY {0,3}

-- Unbounded: zero or more tags
CREATE DATA PROPERTY @ex:tag
  DOMAIN @ex:Document
  RANGE xsd:string
  CARDINALITY {0,*}
```

At insert time the engine rejects values that violate the bounds: too few (when `min > 0`) or more than `max` values for the same property on a single node.

### Supported XSD Types

| Type | Description | Example |
| -- | -- | -- |
| `xsd:string` | Text | "Alice" |
| `xsd:integer` | Whole number | 42 |
| `xsd:decimal` | Decimal number | 3.14 |
| `xsd:float` | Floating point | 1.5e10 |
| `xsd:double` | Double precision | 1.5e100 |
| `xsd:boolean` | True/false | true |
| `xsd:date` | Date | 2024-03-15 |
| `xsd:dateTime` | Date and time | 2024-03-15T10:30:00 |
| `xsd:time` | Time | 10:30:00 |
| `xsd:duration` | ISO 8601 duration | P1Y2M3D |

### Using Data Properties

A data property is used as a key in the node's property map, using its **local name** (not the prefixed form). The value is validated against the property's `RANGE`.

```gql
-- Every Person must have exactly one integer-valued age
CREATE DATA PROPERTY @ex:age 
  DOMAIN @ex:Person RANGE xsd:integer 
  CARDINALITY {1,1}

-- Insert Person with integer-valued age
INSERT (@ex:Person {name: 'Alice', age: 30})

-- Insert Person with string-valued age
-- Type validation error (or warning, depending on enforcement mode)
INSERT (@ex:Person {name: 'Bob', age: 'thirty'})

-- Insert Person without age
-- Cardinality validation error (or warning, depending on enforcement mode)
INSERT (@ex:Person {name: 'Sam'})
```

Attributes whose local name doesn't match any declared data property are stored as plain LPG properties without ontology validation.

## Showing Properties

Show all defined properties (both object and data):

```gql
SHOW PROPERTIES

-- SHOW PROPERTY is a singular alias
SHOW PROPERTY

-- List only one kind
SHOW OBJECT PROPERTIES
SHOW DATA PROPERTIES

-- Filter by ontology prefix with `FROM`:
SHOW PROPERTIES FROM foaf
SHOW OBJECT PROPERTIES FROM ex
SHOW DATA PROPERTIES FROM foaf
```

Returned columns:

| Column | Description |
| -- | -- |
| `property` | The full IRI of the property — the prefix value concatenated with the local name (e.g., `http://example.org/knows` for `@ex:knows`). |
| `localName` | The part after the colon in `@prefix:LocalName` (e.g., `knows`). |
| `type` | `ObjectProperty` for an object property, `DatatypeProperty` for a data property. |
| `domain` | The full IRI of the class declared in `DOMAIN`. Empty when no `DOMAIN` was specified. |
| `range` | For an object property, the full IRI of the class in `RANGE`. For a data property, the XSD-type IRI (e.g., `http://www.w3.org/2001/XMLSchema#integer`). Empty when no `RANGE` was specified. |
| `characteristics` | Comma-separated list of property characteristics. For object properties: any subset of `Symmetric`, `Transitive`, `Functional`, `InverseFunctional`, `Reflexive`, `Irreflexive`, `Asymmetric` (the last four only appear when imported from an external OWL ontology). For data properties: only `Functional` is reported. Empty when no characteristic is set. **`INVERSE OF` and `CARDINALITY {min,max}` are stored but not surfaced here** — inspect the underlying ontology metadata to see those. |

Example output:

| property | localName | type | domain | range | characteristics |
| -- | -- | -- | -- | -- | -- |
| http://example.org/knows | knows | ObjectProperty | http://example.org/Person | http://example.org/Person | Symmetric |
| http://example.org/ancestorOf | ancestorOf | ObjectProperty | http://example.org/Person | http://example.org/Person | Transitive |
| http://example.org/hasBirthPlace | hasBirthPlace | ObjectProperty | http://example.org/Person | http://example.org/Location | Functional |
| http://example.org/worksFor | worksFor | ObjectProperty | http://example.org/Person | http://xmlns.com/foaf/0.1/Organization | |
| http://example.org/employs | employs | ObjectProperty | http://xmlns.com/foaf/0.1/Organization | http://example.org/Person | |
| http://example.org/links | links | ObjectProperty | | | |
| http://example.org/age | age | DatatypeProperty | http://example.org/Person | http://www.w3.org/2001/XMLSchema#integer | |

## Dropping Properties

Object and data properties are dropped with separate statements:

```gql
DROP OBJECT PROPERTY @ex:tempRelation
```

```gql
DROP DATA PROPERTY @ex:tempField
```
