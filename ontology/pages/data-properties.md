# Data Properties

## Overview

A **data property** is an ontology-typed **node attribute** with a typed value. It has an optional `DOMAIN` (the class that may carry the attribute) and an optional `RANGE` that is an XSD datatype (`xsd:string`, `xsd:integer`, etc.).

Data properties attach to **nodes only**. Edge attributes (e.g., `weight: 0.7` on a `:Knows` edge) are stored as plain LPG properties — the ontology validator doesn't type-check them. This matches OWL DL semantics, where `owl:DatatypeProperty` has `rdfs:domain` ranging over `owl:Class`, which is instantiated by node-equivalent individuals.

## Creating Data Properties

```syntax
<create data property statement> ::=                      
  "CREATE DATA PROPERTY" <data property name> 
  [ "DOMAIN" <class> ] [ "RANGE" <xsd type> ] [ "FUNCTIONAL" | <cardinality> ]

<xsd type> ::= "xsd:" <type name>

<cardinality> ::= "CARDINALITY" <cardinality range>

<cardinality range> ::=
    "{" <min> "," <max> "}"    -- both bounds explicit
  | "{" <min> "," "*"   "}"    -- min only, unbounded max
  | "{" <min> ","       "}"    -- min only, unbounded max
  | "{"       "," <max> "}"    -- max only, min defaults to 0
  | <n>                        -- exact, equivalent to {n,n}
```

**Details**

- Data properties **do not** have an inline DDL form for `SUBPROPERTY OF` like <a target="_blank" href="/docs/ontology/object-properties#subproperty-of" target="_blank">object properties</a>. Hierarchies between data properties can still be expressed by **importing** an OWL / Turtle file that declares `rdfs:subPropertyOf` axioms via `LOAD ONTOLOGY`; the engine stores and respects those rollups when queries hit a super-property.

### Basic Form

```gql
-- String property @ex:name on @ex:Agent nodes
CREATE DATA PROPERTY @ex:name DOMAIN @ex:Agent RANGE xsd:string

-- When DOMAIN is omitted, the property doesn't have a class to anchor to
-- Any node can carry tag, still validated as xsd:string
CREATE DATA PROPERTY @ex:tag RANGE xsd:string

-- When RANGE is omitted, the validator skips XSD type-checking of the value.
-- The attribute is restricted to @ex:Document, but the value can be any type
CREATE DATA PROPERTY @ex:metadata DOMAIN @ex:Document
```

### Cardinality Constraint

Data properties accept the same `CARDINALITY` clause as <a target="_blank" href="/docs/ontology/object-properties#Cardinality-Constraint">object properties</a>:

```gql
-- Required, single-valued: every Person must have exactly one name
CREATE DATA PROPERTY @ex:fullName
  DOMAIN @ex:Person RANGE xsd:string
  CARDINALITY 1

-- Multi-valued: a Person may carry up to 3 email addresses
CREATE DATA PROPERTY @ex:email
  DOMAIN @ex:Person RANGE xsd:string
  CARDINALITY {,3}

-- Unbounded: zero or more tags
CREATE DATA PROPERTY @ex:tag
  DOMAIN @ex:Document RANGE xsd:string
  CARDINALITY {0,}
```

### Supported XSD Types

| Type | Description | Example |
| -- | -- | -- |
| `xsd:string` | Text | `"Alice"` |
| `xsd:integer` | Whole number | `42` |
| `xsd:decimal` | Decimal number | `3.14` |
| `xsd:float` | Floating point | `1.5e10` |
| `xsd:double` | Double precision | `1.5e100` |
| `xsd:boolean` | True / false | `true` |
| `xsd:date` | Date | `2024-03-15` |
| `xsd:dateTime` | Date and time | `2024-03-15T10:30:00` |
| `xsd:time` | Time | `10:30:00` |
| `xsd:duration` | ISO 8601 duration | `P1Y2M3D` |

### Property Characteristics

`FUNCTIONAL` is the only OWL characteristic that applies to data properties. It's the shorthand for `CARDINALITY {0,1}` (at most one value):

```gql
-- A person has at most one primary email
CREATE DATA PROPERTY @ex:primaryEmail
  DOMAIN @ex:Person RANGE xsd:string
  FUNCTIONAL
```

The remaining characteristics (`SYMMETRIC`, `TRANSITIVE`, `INVERSE_FUNCTIONAL`, `REFLEXIVE`, `IRREFLEXIVE`, `ASYMMETRIC`) describe relations between two individuals and don't apply to scalar attributes — they're reserved for <a target="_blank" href="/docs/ontology/object-properties#property-characteristics">object properties</a>.

## Using Data Properties

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

## Showing Data Properties

```gql
SHOW DATA PROPERTIES

-- Filter by ontology prefix
SHOW DATA PROPERTIES FROM foaf
```

Example output:

| property | localName | type | domain | range | characteristics |
| -- | -- | -- | -- | -- | -- |
| http://example.org/age | age | DatatypeProperty | http://example.org/Person | http://www.w3.org/2001/XMLSchema#integer | |
| http://example.org/primaryEmail | primaryEmail | DatatypeProperty | http://example.org/Person | http://www.w3.org/2001/XMLSchema#string | Functional |
| http://example.org/birthDate | birthDate | DatatypeProperty | http://example.org/Person | http://www.w3.org/2001/XMLSchema#date | |

To see both data **and** object properties in one result, use `SHOW PROPERTIES` (covered in <a href="/docs/ontology/introduction#viewing-ontologies" target="_blank">Introduction → Viewing Ontologies</a>).

## Dropping Data Properties

```gql
DROP DATA PROPERTY @ex:tempField
```

`DROP DATA PROPERTY` does **not** touch any existing node attributes that use the property's local name, they remain in the graph as plain LPG properties, no longer subject to ontology validation. The attribute remains queryable via `MATCH (n) RETURN n.tempField`.

What stops applying after the drop:

- XSD type-checking against the property's `RANGE`: new inserts may carry any value type for that attribute.
- `DOMAIN` enforcement: the attribute can now be attached to nodes of any class.
- `CARDINALITY` and `FUNCTIONAL` constraints: multi-value bounds stop firing.

If you want a clean teardown, strip the attribute from existing nodes first, then drop the schema:

```gql
-- Remove the attribute from every node that carries it
MATCH (n) WHERE n.tempField IS NOT NULL REMOVE n.tempField

-- Then drop the ontology definition
DROP DATA PROPERTY @ex:tempField
```
