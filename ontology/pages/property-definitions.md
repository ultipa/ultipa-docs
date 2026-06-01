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
  "CREATE OBJECT PROPERTY" <object property name> [ <object property body> ]

<object property body> ::=
  <structural clause> | <subproperty clause> | <property chain clause>

<structural clause> ::=
  [ "DOMAIN" <source class> ] [ "RANGE" <target class> ]
  [ <property characteristics and inverse> | <cardinality constraint> ] 

<property characteristics and inverse> ::=
    <property characteristics> [ "INVERSE OF" <object property name> ]
  | "INVERSE OF" <object property name> [ <property characteristics> ]

<property characteristics> ::= <property characteristic> { <property characteristic> }

<property characteristic> ::= "SYMMETRIC" | "TRANSITIVE" | "FUNCTIONAL"  

<cardinality constraint> ::=
    "CARDINALITY" "{" <min> "," <max> "}"    -- both bounds explicit
  | "CARDINALITY" "{" <min> "," "*"   "}"    -- min only, unbounded max
  | "CARDINALITY" "{" <min> ","       "}"    -- min only, unbounded max
  | "CARDINALITY" "{"       "," <max> "}"    -- max only, min defaults to 0
  | "CARDINALITY" <n>                        -- exact, equivalent to {n,n}

<subproperty clause> ::=
  "SUBPROPERTY OF" <object property name> { "," <object property name> }

<property chain clause> ::=
  "PROPERTY CHAIN" <object property name> "," <object property name> { "," <object property name> }
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
INSERT (@ex:Person {name: 'Lee'})-[@ex:knows]->(@ex:Person {name: 'Julia'})

-- Match knows relationships
MATCH (a)-[@ex:knows]->(b) RETURN a.name, b.name  // (Lee, Julia) and (Julia, Lee)
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
INSERT (@ex:Person {name: 'Jeff'})-[@ex:hasBirthPlace]->(@ex:Location {name: 'Boston'})

-- Insert Jeff -> Boston 
-- FUNCTIONAL violation error: Jeff cannot have two hasBirthPlace edges
MATCH (jeff@ex:Person {name: 'Jeff'})
INSERT (jeff)-[@ex:hasBirthPlace]->(@ex:Location {name: 'Chicago'})
```

#### Combining Characteristics

A property can carry any non-empty subset of `SYMMETRIC`, `TRANSITIVE`, and `FUNCTIONAL` in **any order**.

```gql
-- owl:equivalentClass needs both SYMMETRIC and TRANSITIVE
CREATE OBJECT PROPERTY @ex:equivalentTo SYMMETRIC TRANSITIVE
```

### INVERSE OF

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

### SUBPROPERTY OF

`SUBPROPERTY OF` (RDFS `subPropertyOf`) declares that one property is a specialization of another. A `MATCH` on the super-property also returns edges typed with any of its sub-properties — computed at query time, never materialized onto the edges.

```gql
-- A general "contributedTo" with three specific roles beneath it
CREATE OBJECT PROPERTY @ex:contributedTo
CREATE OBJECT PROPERTY @ex:directed   SUBPROPERTY OF @ex:contributedTo
CREATE OBJECT PROPERTY @ex:wrote      SUBPROPERTY OF @ex:contributedTo
CREATE OBJECT PROPERTY @ex:starredIn  SUBPROPERTY OF @ex:contributedTo

-- Insert three Persons, one Film, and one edge per role
INSERT (lana:@ex:Person {name: 'Lana'}),
       (zak:@ex:Person {name: 'Zak'}),
       (keanu:@ex:Person {name: 'Keanu'}),
       (matrix:@ex:Film {name: 'The Matrix'}),
       (lana)-[@ex:directed]->(matrix),
       (zak)-[@ex:wrote]->(matrix),
       (keanu)-[@ex:starredIn]->(matrix)

-- One MATCH on the super-property surfaces every role
MATCH (p)-[@ex:contributedTo]->(f@ex:Film {name: 'The Matrix'})
RETURN p.name        // Lana, Zak, Keanu
```

Multi-level chains work too — `@ex:coWrote ⊆ @ex:wrote ⊆ @ex:contributedTo` rolls up through all ancestors.

```gql
CREATE OBJECT PROPERTY @ex:coWrote SUBPROPERTY OF @ex:wrote

-- Lana and Zak co-wrote a sequel
INSERT (@ex:Film {name: 'The Matrix Reloaded'})

MATCH (lana@ex:Person {name: 'Lana'}),
      (zak@ex:Person {name: 'Zak'}),
      (reloaded@ex:Film {name: 'The Matrix Reloaded'})
INSERT (lana)-[@ex:coWrote]->(reloaded),
       (zak)-[@ex:coWrote]->(reloaded)

-- The one coWrote edge rolls up through both wrote and contributedTo
MATCH (p)-[@ex:coWrote]->(f@ex:Film {name: 'The Matrix Reloaded'}) 
RETURN p.name  // Lana, Zak

MATCH (p)-[@ex:wrote]->(f@ex:Film {name: 'The Matrix Reloaded'}) 
RETURN p.name  // Lana, Zak (via coWrote)

MATCH (p)-[@ex:contributedTo]->(f@ex:Film {name: 'The Matrix Reloaded'}) 
RETURN p.name  // Lana, Zak (via wrote → contributedTo)
```

Multiple super-properties can be specified as a comma-separated list. A `@ex:wroteAndStarredIn` edge surfaces under both `@ex:wrote` and `@ex:starredIn` queries (and through `@ex:contributedTo` since both parents roll up to it):

```gql
CREATE OBJECT PROPERTY @ex:wroteAndStarredIn SUBPROPERTY OF @ex:wrote, @ex:starredIn

-- Keanu both wrote and starred in this hypothetical film
MATCH (keanu@ex:Person {name: 'Keanu'})
INSERT (keanu)-[@ex:wroteAndStarredIn]->(:@ex:Film {name: 'Side Project'})

-- MATCH on either parent surfaces the edge
MATCH (p)-[@ex:wrote]->(f)
RETURN f.name   // includes Side Project

MATCH (p)-[@ex:starredIn]->(f)
RETURN f.name   // includes Side Project

MATCH (p)-[@ex:contributedTo]->(f) 
RETURN f.name   // also includes Side Project (transitive rollup)
```

### PROPERTY CHAIN

`PROPERTY CHAIN` (OWL `propertyChainAxiom`) declares that a property is implied by walking an ordered sequence of other properties. The derived property stores no edges of its own; a `MATCH` on it computes the endpoints at query time by walking the chain.

A classic example is **kinship**: a grandparent is your parent's parent. Declare two `hasParent` hops as a single derived `hasGrandparent` property:

```gql
CREATE OBJECT PROPERTY @ex:hasParent DOMAIN @ex:Person RANGE @ex:Person
CREATE OBJECT PROPERTY @ex:hasGrandparent PROPERTY CHAIN @ex:hasParent, @ex:hasParent

-- Three-generation family: (alice)-[hasParent]->(bob)-[hasParent]->(carol)
INSERT (alice@ex:Person {name: 'Alice'}),
       (bob@ex:Person {name: 'Bob'}),
       (carol@ex:Person {name: 'Carol'}),
       (alice)-[@ex:hasParent]->(bob),
       (bob)-[@ex:hasParent]->(carol)

-- Match Alice's grandparent
MATCH (a@ex:Person {name: 'Alice'})-[@ex:hasGrandparent]->(g)
RETURN g.name   // Carol
```

Chain depth is bounded by `SET ONTOLOGY TRANSITIVE DEPTH n` (default 10), the same setting that bounds plain `TRANSITIVE` properties.

### Cardinality Constraint

Use `CARDINALITY` to limit how many outgoing edges of a property a source node may have. Cardinality is enforced for object properties at insert time.

```gql
-- Exactly one: every country has exactly one capital
-- CARDINALITY 1 is the shorthand for {1,1}
CREATE OBJECT PROPERTY @ex:hasCapital
  DOMAIN @ex:Country
  RANGE @ex:City
  CARDINALITY 1

-- Up to N: between 0 and 5 pets
-- CARDINALITY {,5} is the shorthand for {0,5}
CREATE OBJECT PROPERTY @ex:hasPet
  DOMAIN @ex:Person
  RANGE @ex:Pet
  CARDINALITY {,5}

-- Unbounded: one or more friends
-- CARDINALITY {1,} is the shorthand for {1,*}
CREATE OBJECT PROPERTY @ex:hasFriend
  DOMAIN @ex:Person
  RANGE @ex:Person
  CARDINALITY {1,}
```

`FUNCTIONAL` is a shorthand for `CARDINALITY {0,1}`:

```gql
-- A person can have at most one spouse
CREATE OBJECT PROPERTY @ex:hasSpouse
  DOMAIN @ex:Person
  RANGE @ex:Person
  FUNCTIONAL
```

**Restrictions:**

- `CARDINALITY` **cannot** appear in the same statement as `SYMMETRIC`, `TRANSITIVE`, `FUNCTIONAL`, or `INVERSE OF`.
- `CARDINALITY` **cannot** combine with `SUBPROPERTY OF` or `PROPERTY CHAIN`.

```gql
-- ✗ parse error: characteristic + CARDINALITY in the same statement
CREATE OBJECT PROPERTY @ex:hasFriend
  DOMAIN @ex:Person
  RANGE @ex:Person
  SYMMETRIC CARDINALITY {0,10}
```

## Creating Data Properties

Data properties define attributes with XSD types. Both `DOMAIN` and `RANGE` are optional, and `RANGE` takes the XSD type.

<p tit="Syntax"></p>

```
<create data property statement> ::=                      
  "CREATE DATA PROPERTY" <data property name> 
  [ 
      "DOMAIN" <class> [ "RANGE" <xsd type> [ <cardinality constraint> ] ]
    | "RANGE" <xsd type> [ <cardinality constraint> ]
    | <cardinality constraint>
  ]

<xsd type> ::= "xsd:" <type name>

<cardinality constraint> ::= -- same five forms as Object Properties above
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

Data properties accept the same `CARDINALITY` clause as object properties:

```gql
-- Required, single-valued: every Person must have exactly one name
CREATE DATA PROPERTY @ex:fullName
  DOMAIN @ex:Person
  RANGE xsd:string
  CARDINALITY 1

-- Multi-valued: a Person may carry up to 3 email addresses
CREATE DATA PROPERTY @ex:email
  DOMAIN @ex:Person
  RANGE xsd:string
  CARDINALITY {,3}

-- Unbounded: zero or more tags
CREATE DATA PROPERTY @ex:tag
  DOMAIN @ex:Document
  RANGE xsd:string
  CARDINALITY {0,}
```

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
