# Property Definitions

## Overview

Define ontology properties to describe relationships between classes (object properties) and attributes of nodes (data properties).

## Object Properties

Object properties define edge types with domain (source) and range (target) constraints:

```gql
// Person knows Person
CREATE OBJECT PROPERTY @foaf:knows DOMAIN @foaf:Person RANGE @foaf:Person
```

```gql
// Person works for Organization
CREATE OBJECT PROPERTY @ex:worksFor DOMAIN @ex:Person RANGE @ex:Organization
```

```gql
// Organization employs Person
CREATE OBJECT PROPERTY @ex:employs DOMAIN @ex:Organization RANGE @ex:Person
```

## Property Characteristics

Properties can have special characteristics that affect behavior:

| Characteristic | Description |
| -- | -- |
| SYMMETRIC | If A->B exists, B->A is inferred |
| TRANSITIVE | If A->B and B->C exist, A->C is inferred |
| REFLEXIVE | Every node is related to itself |
| IRREFLEXIVE | No node can be related to itself |
| FUNCTIONAL | Each node can have at most one outgoing edge |
| INVERSE FUNCTIONAL | Each node can have at most one incoming edge |

Create property with characteristics:

```gql
// knows is symmetric - if Alice knows Bob, Bob knows Alice
CREATE OBJECT PROPERTY @foaf:knows DOMAIN @foaf:Person RANGE @foaf:Person SYMMETRIC
```

```gql
// ancestorOf is transitive - if A ancestor of B, B ancestor of C, then A ancestor of C
CREATE OBJECT PROPERTY @ex:ancestorOf DOMAIN @ex:Person RANGE @ex:Person TRANSITIVE
```

```gql
// hasBirthPlace is functional - a person has only one birthplace
CREATE OBJECT PROPERTY @ex:hasBirthPlace DOMAIN @ex:Person RANGE @ex:Location FUNCTIONAL
```

## Inverse Properties

Define inverse relationships:

```gql
// worksFor and employs are inverses
CREATE OBJECT PROPERTY @ex:worksFor DOMAIN @ex:Person RANGE @ex:Organization
CREATE OBJECT PROPERTY @ex:employs DOMAIN @ex:Organization RANGE @ex:Person INVERSE OF @ex:worksFor
```

When you create one edge, the inverse is automatically inferred:

```gql
// Insert worksFor edge
INSERT (:@ex:Person {name: 'Alice'})-[:@ex:worksFor]->(:@ex:Organization {name: 'Acme'})

// Query employs (inverse) - returns the same relationship
MATCH (org@ex:Organization)-[:@ex:employs]->(person@ex:Person)
RETURN org.name, person.name
```

| org.name | person.name |
| -- | -- |
| Acme | Alice |

## Cardinality Constraints

Limit the number of relationships:

```gql
// A person can have at most one spouse
CREATE OBJECT PROPERTY @ex:hasSpouse FUNCTIONAL
```

```gql
// A country has exactly one capital
CREATE OBJECT PROPERTY @ex:hasCapital
  DOMAIN @ex:Country
  RANGE @ex:City
  FUNCTIONAL
```

## Data Properties

Data properties define attributes with XSD types:

```gql
// String property
CREATE DATA PROPERTY @foaf:name DOMAIN @foaf:Agent TYPE xsd:string
```

```gql
// Numeric properties
CREATE DATA PROPERTY @foaf:age DOMAIN @foaf:Person TYPE xsd:integer
CREATE DATA PROPERTY @ex:salary DOMAIN @ex:Employee TYPE xsd:decimal
```

```gql
// Date/time properties
CREATE DATA PROPERTY @ex:birthDate DOMAIN @ex:Person TYPE xsd:date
CREATE DATA PROPERTY @ex:createdAt DOMAIN @ex:Document TYPE xsd:dateTime
```

```gql
// Boolean property
CREATE DATA PROPERTY @ex:isActive DOMAIN @ex:Account TYPE xsd:boolean
```

Supported XSD types:

| Type | Description | Example |
| -- | -- | -- |
| xsd:string | Text | "Alice" |
| xsd:integer | Whole number | 42 |
| xsd:decimal | Decimal number | 3.14 |
| xsd:float | Floating point | 1.5e10 |
| xsd:double | Double precision | 1.5e100 |
| xsd:boolean | True/false | true |
| xsd:date | Date | 2024-03-15 |
| xsd:dateTime | Date and time | 2024-03-15T10:30:00 |
| xsd:time | Time | 10:30:00 |

## Viewing Properties

List all defined properties:

```gql
SHOW PROPERTIES
```

| property | type | domain | range | characteristics |
| -- | -- | -- | -- | -- |
| @foaf:knows | OBJECT | @foaf:Person | @foaf:Person | SYMMETRIC |
| @ex:worksFor | OBJECT | @ex:Person | @ex:Organization | |
| @ex:employs | OBJECT | @ex:Organization | @ex:Person | INVERSE OF @ex:worksFor |
| @foaf:name | DATA | @foaf:Agent | xsd:string | |
| @foaf:age | DATA | @foaf:Person | xsd:integer | |

## Deleting Properties

Remove a property definition:

```gql
DROP PROPERTY @ex:tempProperty
```

Remove if exists:

```gql
DROP PROPERTY IF EXISTS @ex:tempProperty
```
