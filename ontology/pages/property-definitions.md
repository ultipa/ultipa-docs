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

## Object Properties

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
// Person knows Person
CREATE OBJECT PROPERTY @ex:knows DOMAIN @ex:Person RANGE @ex:Person
```

```gql
// Person works for Organization
CREATE OBJECT PROPERTY @ex:worksFor DOMAIN @ex:Person RANGE @foaf:Organization
```

```gql
// Only the source is constrained, RANGE can be anything
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
// knows is symmetric: if A knows B, B knows A
CREATE OBJECT PROPERTY @ex:knows DOMAIN @ex:Person RANGE @ex:Person SYMMETRIC
```

Example:

```gql
INSERT (:@ex:Person {name: 'Alice'})-[:@ex:knows]->(:@ex:Person {name: 'Bob'})
MATCH (a)-[:@ex:knows]->(b) RETURN a.name, b.name
```

Result: 

| a.name | b.name |
| -- | -- |
| Alice | Bob |
| Bob | Alice |

#### TRANSITIVE

Insert a chain; the end-to-end edge is inferred.

```gql
// ancestorOf is transitive: if A ancestor of B, B ancestor of C, then A ancestor of C
CREATE OBJECT PROPERTY @ex:ancestorOf DOMAIN @ex:Person RANGE @ex:Person TRANSITIVE
```

Example:

```gql
INSERT (:@ex:Person {name: 'Alice'})-[:@ex:ancestorOf]->(:@ex:Person {name: 'Bob'})-[:@ex:ancestorOf]->(:@ex:Person {name: 'Carol'})
MATCH (x)-[:@ex:ancestorOf]->(y) RETURN x.name, y.name
```

Result:

| x.name | y.name |
| -- | -- |
| Alice | Bob |
| Bob | Carol |
| Alice | Carol |

#### FUNCTIONAL

Each source node may have at most one outgoing edge of this property. Under `STRICT` enforcement a second insert fails; under the default `WARNING` mode it is logged but proceeds.

```gql
SET ONTOLOGY ENFORCEMENT STRICT

// hasBirthPlace is functional: a person has only one birthplace
CREATE OBJECT PROPERTY @ex:hasBirthPlace DOMAIN @ex:Person RANGE @ex:Location FUNCTIONAL
```

Example:

```gql
// Error: FUNCTIONAL violation — Alice has two hasBirthPlace edges
INSERT (a@ex:Person {name: 'Alice'}),
       (a)-[:@ex:hasBirthPlace]->(:@ex:Location {name: 'Boston'}),
       (a)-[:@ex:hasBirthPlace]->(:@ex:Location {name: 'Chicago'})
```

### Inverse Properties

Define inverse relationships. When you create one edge, the inverse is automatically inferred:

```gql
// worksFor and employs are inverses
CREATE OBJECT PROPERTY @ex:worksFor DOMAIN @ex:Person RANGE @foaf:Organization
CREATE OBJECT PROPERTY @ex:employs DOMAIN @foaf:Organization RANGE @ex:Person INVERSE OF @ex:worksFor
```

Example:

```gql
// Insert worksFor edge
INSERT (:@ex:Person {name: 'Alice'})-[:@ex:worksFor]->(:@foaf:Organization {name: 'Acme'})

// Query employs (inverse) - returns the same relationship
MATCH (org)-[:@ex:employs]->(person)
RETURN org.name, person.name
```

Result:

| org.name | person.name |
| -- | -- |
| Acme | Alice |

### Cardinality Constraints

Use `CARDINALITY {min, max}` to limit how many outgoing edges of a property a source node may have. `*` denotes "unbounded". Cardinality is enforced for **object properties** at insert time.

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

## Data Properties

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
// String property
CREATE DATA PROPERTY @foaf:name DOMAIN @foaf:Agent RANGE xsd:string
```

```gql
// Numeric properties
CREATE DATA PROPERTY @foaf:age DOMAIN @foaf:Person RANGE xsd:integer
CREATE DATA PROPERTY @ex:salary DOMAIN @ex:Employee RANGE xsd:decimal
```

```gql
// Date/time properties
CREATE DATA PROPERTY @ex:birthDate DOMAIN @ex:Person RANGE xsd:date
CREATE DATA PROPERTY @ex:createdAt DOMAIN @ex:Document RANGE xsd:dateTime
```

```gql
// Boolean property
CREATE DATA PROPERTY @ex:isActive DOMAIN @ex:Account RANGE xsd:boolean
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
CREATE DATA PROPERTY @ex:age DOMAIN @ex:Person RANGE xsd:integer
```

```gql
INSERT (:@ex:Person {name: 'Alice', age: 30})

MATCH (p@ex:Person)
RETURN p.name, p.age
```

Result:

| p.name | p.age |
| -- | -- |
| Alice | 30 |

A value that doesn't match `RANGE` raises a `TYPE_MISMATCH` validation error (or warning, depending on enforcement mode):

```gql
// Error: TYPE_MISMATCH — age expects xsd:integer
INSERT (:@ex:Person {name: 'Bob', age: 'thirty'})
```

Attributes whose local name doesn't match any declared data property are stored as plain LPG properties without ontology validation:

```gql
// nickname is not a declared data property — stored as plain LPG property, no type check
INSERT (:@ex:Person {name: 'Carol', nickname: 'C'})
```

## Showing Properties

List all defined properties:

```gql
SHOW PROPERTIES
```

Returned columns:

| Column | Description |
| -- | -- |
| `property` | The full IRI of the property — the prefix value concatenated with the local name (e.g., `http://example.org/knows` for `@ex:knows`). |
| `localName` | The part after the colon in `@prefix:LocalName` (e.g., `knows`). |
| `type` | `ObjectProperty` for an object property, `DatatypeProperty` for a data property. |
| `domain` | The full IRI of the class declared in `DOMAIN`. Empty when no `DOMAIN` was specified. |
| `range` | For an object property, the full IRI of the class in `RANGE`. For a data property, the XSD-type IRI (e.g., `http://www.w3.org/2001/XMLSchema#integer`). Empty when no `RANGE` was specified. |
| `characteristics` | `Symmetric`, `Transitive`, or `Functional` when set. Empty otherwise. **`INVERSE OF` and `CARDINALITY {min,max}` are stored but not surfaced here** — inspect the underlying ontology metadata to see those. |

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
