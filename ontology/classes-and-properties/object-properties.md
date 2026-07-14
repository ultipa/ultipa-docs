# Object Properties

## Overview

An **object property** is an ontology-typed **edge label**. It connects two nodes and is constrained by optional `DOMAIN` (source class) and `RANGE` (target class) and other features.

## Example Graph

Run this before working through the examples:

```gql
CREATE GRAPH myOntology WITH ONTOLOGY
USE myOntology
LOAD PREFIX ex FROM 'http://example.org/'
CREATE CLASS @ex:Person
CREATE CLASS @ex:Organization
CREATE CLASS @ex:Location
CREATE CLASS @ex:SocialSecurityNumber
CREATE CLASS @ex:Thing
CREATE CLASS @ex:Film
```

## Creating Object Properties

```syntax
<create object property statement> ::=
  "CREATE OBJECT PROPERTY" <object property name> [ <object property body> ]

<object property body> ::= <structural features> | <subproperty of> | <property chain>

<structural features> ::= <endpoints> [ <characteristics and inverse of> | <cardinality> ]

<characteristics and inverse of> ::=
    <characteristics> [ <inverse of> ]
  | <inverse of> [ <characteristics> ]
```

### Basic Form

The minimal form just registers the property identity:

```gql
CREATE OBJECT PROPERTY @ex:links
```

With no `DOMAIN` or `RANGE`, the engine performs no endpoint validation: `@ex:links` edge connects any two nodes.

### DOMAIN and RANGE

```syntax
<endpoints> ::= [ "DOMAIN" <source class> ] [ "RANGE" <target class> ]
```

`DOMAIN` (source class) and `RANGE` (target class) are both optional. When present, the engine validates that edges of this property go from a node of the domain class to a node of the range class.

```gql
-- Person knows Person
CREATE OBJECT PROPERTY @ex:knows DOMAIN @ex:Person RANGE @ex:Person

-- Person works for Organization
CREATE OBJECT PROPERTY @ex:worksFor DOMAIN @ex:Person RANGE @ex:Organization

-- Only the source is constrained, RANGE can be anything
CREATE OBJECT PROPERTY @ex:owns DOMAIN @ex:Person

-- Only the range is constrained, DOMAIN can be anything
CREATE OBJECT PROPERTY @ex:sings RANGE @ex:Song
```

> The classes named in `DOMAIN` and `RANGE` do not need to exist when the property is created. They are stored as IRIs and only checked at insert / match time. Only the **prefix** must be loaded.

### Property Characteristics

Object properties can have special characteristics that affect behavior. 

```syntax
<characteristics> ::= <characteristic> { <characteristic> }...

<characteristic> ::=
    "SYMMETRIC" | "ASYMMETRIC" | "TRANSITIVE" | "FUNCTIONAL"
  | "INVERSE_FUNCTIONAL" | "REFLEXIVE" | "IRREFLEXIVE"
```

The DDL keywords match the corresponding OWL property classes, so a property declared with `LOAD ONTOLOGY` and one declared inline with the DDL keyword behave identically. Two paths to the same end state.

**Path 1:** Inline DDL (GQL syntax)

```gql
CREATE OBJECT PROPERTY @ex:knowsSelf DOMAIN @ex:Person RANGE @ex:Person REFLEXIVE
```

**Path 2:** Loaded from an OWL / Turtle / RDF file

<p tit="people.ttl"></p>

```ttl
@prefix ex:   <http://example.org/> .
@prefix owl:  <http://www.w3.org/2002/07/owl#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

ex:knowsSelf a owl:ObjectProperty, owl:ReflexiveProperty ;
              rdfs:domain ex:Person ;
              rdfs:range  ex:Person .
```
  
Loaded with:

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/people.ttl'
```

#### SYMMETRIC

Only one direction is stored; the reverse is **inferred at query time**. A directed `MATCH` pattern picks up both directions.

```gql
-- knows is symmetric: if A knows B, B knows A
CREATE OBJECT PROPERTY @ex:knows DOMAIN @ex:Person RANGE @ex:Person SYMMETRIC

-- Insert Lee -> Julia
INSERT (@ex:Person {name: 'Lee'})-[@ex:knows]->(@ex:Person {name: 'Julia'})

-- Match outgoing knows relationships
MATCH (a)-[@ex:knows]->(b) RETURN a.name, b.name  // (Lee, Julia) and (Julia, Lee)
```

In this example, only edge `Lee -> Julia` exists on disk, edge `Julia -> Lee` is inferred at query time because of `SYMMETRIC`.

Note that GQL supports **undirected edge patterns**, `MATCH (a)-[@ex:knows]-(b)` (no arrowhead) traverses an edge in either direction at query time, regardless of whether the property is declared `SYMMETRIC`. So if all you need is bidirectional traversal, the undirected pattern alone is enough; no `SYMMETRIC` declaration required.

```gql
-- friends is not declared as symmetric
CREATE OBJECT PROPERTY @ex:friends DOMAIN @ex:Person RANGE @ex:Person

-- Insert Anna -> Sue
INSERT (@ex:Person {name: 'Anna'})-[@ex:friends]->(@ex:Person {name: 'Sue'})

-- Directed MATCH
MATCH (a)-[@ex:friends]->(b) RETURN a.name, b.name  // (Anna, Sue)

-- Undirected MATCH
MATCH (a)-[@ex:friends]-(b) RETURN a.name, b.name  // (Anna, Sue) and (Sue, Anna)
```

Reach for `SYMMETRIC` when you want one of:

- **OWL interoperability:** the property's symmetry travels as an axiom in any `LOAD ONTOLOGY` import or export, so external semantic-web tooling sees the same semantics.
- **Directed patterns to behave bidirectionally:** useful when downstream queries are written with edge direction and you don't want to rewrite them to use the undirected form.
- **Schema documentation:** `SHOW OBJECT PROPERTIES` reports `Symmetric` in the characteristics column, making the relationship's nature explicit to anyone reading the ontology.

#### ASYMMETRIC

If A→B exists, B→A is rejected. Useful when the relationship is directional and the reverse is meaningless or contradictory.

```gql
SET ONTOLOGY ENFORCEMENT STRICT

-- descendantOf is asymmetric: if A is B's descendant, B cannot also be A's descendant
CREATE OBJECT PROPERTY @ex:descendantOf DOMAIN @ex:Person RANGE @ex:Person ASYMMETRIC

-- Insert Bill -> John
INSERT (@ex:Person {name: 'Bill'})-[@ex:descendantOf]->(@ex:Person {name: 'John'})

-- Insert John -> Bill — rejected, the reverse already exists
-- ASYMMETRIC violation
MATCH (bill@ex:Person {name: 'Bill'}),(john@ex:Person {name: 'John'})
INSERT (john)-[@ex:descendantOf]->(bill)

-- ASYMMETRIC also rejects self-edges
INSERT (x@ex:Person {name: 'X'})-[@ex:descendantOf]->(x)
```

#### TRANSITIVE

Insert a chain; the end-to-end edge is inferred.

```gql
-- ancestorOf is transitive: if A ancestor of B, B ancestor of C, then A ancestor of C
CREATE OBJECT PROPERTY @ex:ancestorOf DOMAIN @ex:Person RANGE @ex:Person TRANSITIVE 

-- Insert D->C->B->A
INSERT (@ex:Person {name: 'D'})-[@ex:ancestorOf]->(@ex:Person {name: 'C'})-[@ex:ancestorOf]->(@ex:Person {name: 'B'})-[@ex:ancestorOf]->(@ex:Person {name: 'A'})

-- Query descendants
MATCH (@ex:Person {name: 'C'})-[@ex:ancestorOf]->(p@ex:Person) 
RETURN p.name  // B, A

MATCH (@ex:Person {name: 'D'})-[@ex:ancestorOf]->(p@ex:Person)
RETURN p.name // C, B, A
```

Transitive inference is bounded by a per-graph **maximum expansion depth**; chains longer than the limit are not inferred.

- **Default**: `10` hops. With the default, K→…→A over 10 intermediate `@ex:ancestorOf` edges still infers K→A, but an 11-hop chain (L→A) does not.
- **Configurable** with `SET ONTOLOGY TRANSITIVE DEPTH <N>`. The value must be a positive integer (`1, 2, 3, …`) or the sentinel `-1` for unbounded expansion.

```gql
-- Limit transitive expansion to 25 levels
SET ONTOLOGY TRANSITIVE DEPTH 25

-- Remove the limit (full transitive closure)
SET ONTOLOGY TRANSITIVE DEPTH -1
```

Cycles are detected at traversal time, so a closed loop in the chain does not cause infinite expansion regardless of the configured depth.

#### FUNCTIONAL

Each source node may have at most one **outgoing** edge of this property. Under `STRICT` enforcement a second insert fails; under the default `WARNING` mode it is logged but proceeds.

```gql
SET ONTOLOGY ENFORCEMENT STRICT

-- hasBirthPlace is functional: a person has only one birthplace
CREATE OBJECT PROPERTY @ex:hasBirthPlace 
  DOMAIN @ex:Person RANGE @ex:Location FUNCTIONAL

-- Insert Jeff -> Boston
INSERT (@ex:Person {name: 'Jeff'})-[@ex:hasBirthPlace]->(@ex:Location {name: 'Boston'})

-- Insert Jeff -> Chicago
-- FUNCTIONAL violation error: Jeff cannot have more than one outgoing hasBirthPlace edge
MATCH (jeff@ex:Person {name: 'Jeff'})
INSERT (jeff)-[@ex:hasBirthPlace]->(@ex:Location {name: 'Chicago'})
```

#### INVERSE_FUNCTIONAL

Each target node may have at most one **incoming** edge of this property (the mirror image of `FUNCTIONAL`). Useful for identity-style properties where the target uniquely identifies the source.

```gql
SET ONTOLOGY ENFORCEMENT STRICT

-- hasSSN is inverse-functional: every SSN belongs to at most one Person
CREATE OBJECT PROPERTY @ex:hasSSN
  DOMAIN @ex:Person RANGE @ex:SocialSecurityNumber INVERSE_FUNCTIONAL

-- Insert Alice -> SSN-12345
INSERT (@ex:Person {name: 'Alice'})-[@ex:hasSSN]->(@ex:SocialSecurityNumber {value: 'SSN-12345'})

-- Insert Bob -> SSN-12345
-- INVERSE_FUNCTIONAL violation: SSN-12345 cannot have more than one incoming hasSSN edge
MATCH (ssn@ex:SocialSecurityNumber {value: 'SSN-12345'})
INSERT (@ex:Person {name: 'Bob'})-[@ex:hasSSN]->(ssn)
```

The two-word `INVERSE FUNCTIONAL` is accepted as a lexer-fused alias for the same characteristic.

#### REFLEXIVE

Every node that's a member of the property's `DOMAIN` class (direct or via subclass inference) is inferred to have a self-edge.

If no `DOMAIN` was declared, the inference fires for **every node in the graph**, which is usually too broad to be useful, so declare a `DOMAIN` whenever you set `REFLEXIVE`.

```gql
CREATE OBJECT PROPERTY @ex:sameAs DOMAIN @ex:Thing RANGE @ex:Thing REFLEXIVE

-- City renamed historically
INSERT (constantinople:@ex:Thing {name: 'Constantinople'}),
       (istanbul:@ex:Thing {name: 'Istanbul'}),
       (constantinople)-[@ex:sameAs]->(istanbul)
  
-- Self-edges surface even though we never inserted them
MATCH (t1)-[@ex:sameAs]->(t2) 
RETURN t1.name, t2.name   // (Constantinople, Istanbul), (Constantinople, Constantinople), (Istanbul, Istanbul)

-- To filter out self-edges
MATCH (t1)-[@ex:sameAs]->(t2)
WHERE t1 <> t2
RETURN t1.name, t2.name   // (Constantinople, Istanbul)
```

**Common misconception:** `REFLEXIVE` fires on **class membership**, not on whether a node already participates in any edges of the property. Every `@ex:Thing` in the graph gets a self-edge, even a node like `Byzantium` that has no `sameAs` edges in or out. As long as it's a `@ex:Thing`, it qualifies. The DOMAIN in "Every node in the DOMAIN" means the **declared class**, not "the source of an existing edge."

```gql
INSERT (:@ex:Thing {name: 'Byzantium'})

-- No sameAs edge was inserted for Byzantium, but the query below still returns a result (the REFLEXIVE self-edge).
MATCH p = (@ex:Thing {name: 'Byzantium'})-[@ex:sameAs]->(@ex:Thing {name: 'Byzantium'}) 
RETURN p  // (Byzantium, Byzantium)
```

Before declaring `REFLEXIVE`, ask whether every node in the property's `DOMAIN` genuinely relates to itself via this property. If "every Person born to themselves" or "every Book wrote itself" reads as wrong for your domain, `REFLEXIVE` isn't the right flag. The textbook cases (`sameAs`, `partOf`, `subClassOf`) are all relations where the self-case is trivially true by definition.

#### IRREFLEXIVE

Self-edges are rejected. The mirror of `REFLEXIVE` — instead of inferring self-edges, the validator refuses to let you insert one.

```gql
SET ONTOLOGY ENFORCEMENT STRICT

-- parentOf is irreflexive: no one can be their own parent
CREATE OBJECT PROPERTY @ex:parentOf DOMAIN @ex:Person RANGE @ex:Person IRREFLEXIVE

-- Insert Mary -> Doe — fine, two different nodes
INSERT (@ex:Person {name: 'Mary'})-[@ex:parentOf]->(@ex:Person {name: 'Doe'})

-- Insert Alice -> Alice — rejected
-- IRREFLEXIVE violation
MATCH (alice@ex:Person {name: 'Alice'})
INSERT (alice)-[@ex:parentOf]->(alice)   
```

#### Combining Characteristics

Multiple characteristics can be combined in any order. 

```gql
-- owl:equivalentClass needs both SYMMETRIC and TRANSITIVE
CREATE OBJECT PROPERTY @ex:equivalentTo SYMMETRIC TRANSITIVE
```

### INVERSE OF

Define inverse relationships. When you create one edge, the inverse is automatically inferred.

```syntax
<inverse of> ::= "INVERSE OF" <object property name>
```

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

### CARDINALITY

Use `CARDINALITY` to limit how many outgoing edges of a property a source node may have. Cardinality is enforced at insert time.

```syntax
<cardinality> ::= "CARDINALITY" <cardinality range>

<cardinality range> ::=
    "{" <min> "," <max> "}"    -- both bounds explicit
  | "{" <min> "," "*"   "}"    -- min only, unbounded max
  | "{" <min> ","       "}"    -- min only, unbounded max
  | "{"       "," <max> "}"    -- max only, min defaults to 0
  | <n>                        -- exact, equivalent to {n,n}
```

```gql
-- Exactly one: every country has exactly one capital
-- CARDINALITY 1 is the shorthand for {1,1}
CREATE OBJECT PROPERTY @ex:hasCapital
  DOMAIN @ex:Country RANGE @ex:City
  CARDINALITY 1

-- Up to N: between 0 and 5 pets
-- CARDINALITY {,5} is the shorthand for {0,5}
CREATE OBJECT PROPERTY @ex:hasPet
  DOMAIN @ex:Person RANGE @ex:Pet
  CARDINALITY {,5}

-- Unbounded: one or more friends
-- CARDINALITY {1,} is the shorthand for {1,*}
CREATE OBJECT PROPERTY @ex:hasFriend
  DOMAIN @ex:Person RANGE @ex:Person
  CARDINALITY {1,}
```

`FUNCTIONAL` constrains a source node to at most one outgoing edge of this property — the same effect as `CARDINALITY {0,1}`. (For object properties `FUNCTIONAL` is the OWL characteristic; it is a distinct clause from `CARDINALITY`, so the two cannot be combined in one statement.)

```gql
-- A person can have at most one spouse
CREATE OBJECT PROPERTY @ex:hasSpouse
  DOMAIN @ex:Person RANGE @ex:Person FUNCTIONAL
```

**Restrictions:**

- `CARDINALITY` **cannot** appear in the same statement as any characteristic (`SYMMETRIC`, `TRANSITIVE`, etc.) or with `INVERSE OF`.
- `CARDINALITY` **cannot** combine with `SUBPROPERTY OF` or `PROPERTY CHAIN`.

### SUBPROPERTY OF

`SUBPROPERTY OF` declares that one property is a specialization of another. A `MATCH` on the super-property also returns edges typed with any of its sub-properties — computed at query time, never materialized onto the edges.

```syntax
<subproperty of> ::=
  "SUBPROPERTY OF" <object property name> { "," <object property name> }
```

<p tit="Hierarchy"></p>

```gql
    @ex:contributedTo
     /             \
@ex:wrote      @ex:starredIn
```

```gql
-- A general "contributedTo" with two specific roles beneath it
CREATE OBJECT PROPERTY @ex:contributedTo
CREATE OBJECT PROPERTY @ex:wrote      SUBPROPERTY OF @ex:contributedTo
CREATE OBJECT PROPERTY @ex:starredIn  SUBPROPERTY OF @ex:contributedTo

-- Insert two Persons, one Film, and one edge per role
INSERT (zak:@ex:Person {name: 'Zak'}),
       (keanu:@ex:Person {name: 'Keanu'}),
       (matrix:@ex:Film {name: 'The Matrix'}),
       (zak)-[@ex:wrote]->(matrix),
       (keanu)-[@ex:starredIn]->(matrix)

-- One MATCH on the super-property surfaces every role
MATCH (p)-[@ex:contributedTo]->(f@ex:Film {name: 'The Matrix'})
RETURN p.name        // Zak, Keanu
```

Multi-level chains work too. `@ex:coWrote ⊆ @ex:wrote ⊆ @ex:contributedTo` rolls up through all ancestors.

<p tit="Hierarchy"></p>

```gql
      @ex:contributedTo
       /             \
  @ex:wrote      @ex:starredIn
    /
@ex:coWrote
```

```gql
CREATE OBJECT PROPERTY @ex:coWrote SUBPROPERTY OF @ex:wrote

-- Lana and Zak co-wrote a sequel
MATCH (zak@ex:Person {name: 'Zak'})
INSERT (zak)-[@ex:coWrote]->(reloaded@ex:Film {name: 'The Matrix Reloaded'}),
       (lana@ex:Person {name: 'Lana'})-[@ex:coWrote]->(reloaded)

-- The one coWrote edge rolls up through both wrote and contributedTo
MATCH (p)-[@ex:wrote]->(f@ex:Film {name: 'The Matrix Reloaded'}) 
RETURN p.name  // Lana, Zak (via coWrote)

MATCH (p)-[@ex:contributedTo]->(f@ex:Film {name: 'The Matrix Reloaded'}) 
RETURN p.name  // Lana, Zak (via wrote → contributedTo)
```

Multiple super-properties can be specified as a comma-separated list. A `@ex:wroteAndStarredIn` edge surfaces under both `@ex:wrote` and `@ex:starredIn` queries (and through `@ex:contributedTo` since both parents roll up to it):

<p tit="Hierarchy"></p>

```gql
            @ex:contributedTo
             /             \
       @ex:wrote      @ex:starredIn
        /      \           /
@ex:coWrote  @ex:wroteAndStarredIn
```

```gql
CREATE OBJECT PROPERTY @ex:wroteAndStarredIn SUBPROPERTY OF @ex:wrote, @ex:starredIn

-- Kavi both wrote and starred in this hypothetical film
INSERT (@ex:Person {name: 'Kavi'})-[@ex:wroteAndStarredIn]->(@ex:Film {name: 'Side Project'})

-- MATCH on either parent surfaces the edge
MATCH (@ex:Person {name: 'Kavi'})-[@ex:wrote]->(f)
RETURN f.name   // Side Project

MATCH (@ex:Person {name: 'Kavi'})-[@ex:starredIn]->(f)
RETURN f.name   // Side Project

MATCH (@ex:Person {name: 'Kavi'})-[@ex:contributedTo]->(f) 
RETURN f.name   // Side Project (transitive rollup)
```

### PROPERTY CHAIN

`PROPERTY CHAIN` declares that a property is implied by walking an ordered sequence of other properties. The derived property stores no edges of its own; a `MATCH` on it computes the endpoints at query time by walking the chain.

```syntax
<property chain> ::=
  "PROPERTY CHAIN" <object property name> "," <object property name> { "," <object property name> }...
```

A classic example is **kinship**: a grandparent is your parent's parent, a great grandparent is your parent's grandparent. Declare two `hasParent` hops as a single derived `hasGrandparent` property, three `hasParent` hops as a single derived `hasGreatGrandparent` property:

```gql
CREATE OBJECT PROPERTY @ex:hasParent DOMAIN @ex:Person RANGE @ex:Person
CREATE OBJECT PROPERTY @ex:hasGrandparent PROPERTY CHAIN @ex:hasParent, @ex:hasParent
CREATE OBJECT PROPERTY @ex:hasGreatGrandparent PROPERTY CHAIN @ex:hasParent, @ex:hasParent, @ex:hasParent

-- Four-generation family: Josh->Ben->Carol->Sam
INSERT (josh@ex:Person {name: 'Josh'}),
       (ben@ex:Person {name: 'Ben'}),
       (carol@ex:Person {name: 'Carol'}),
       (sam@ex:Person {name: 'Sam'}),
       (josh)-[@ex:hasParent]->(ben),
       (ben)-[@ex:hasParent]->(carol),
       (carol)-[@ex:hasParent]->(sam)

-- Match Josh's grandparent
MATCH (@ex:Person {name: 'Josh'})-[@ex:hasGrandparent]->(g)
RETURN g.name   // Carol

-- Match Josh's great grandparent
MATCH (@ex:Person {name: 'Josh'})-[@ex:hasGreatGrandparent]->(gg)
RETURN gg.name   // Sam
```

Chain depth is bounded by `SET ONTOLOGY TRANSITIVE DEPTH n` (default 10), the same setting that bounds plain `TRANSITIVE` properties.

### Equivalent Properties (Load-Only)

GQLDB recognizes one OWL object-property constructor carried in a <a href="/docs/ontology/rdf-import-and-export" target="_blank"><code>LOAD ONTOLOGY</code></a> file: `owl:equivalentProperty`. It has no inline DDL keyword.

`owl:equivalentProperty` makes two properties interchangeable: a `MATCH` on either one also returns edges typed with the other, computed at query time and never materialized. It behaves like a mutual `SUBPROPERTY OF` (`p ≡ q ⟺ p ⊑ q ∧ q ⊑ p`), and the equivalence composes transitively with the sub-property hierarchy:

<p tit="props.ttl"></p>

```ttl
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix ex:  <http://example.org/> .

ex:likes  a owl:ObjectProperty .
ex:enjoys a owl:ObjectProperty ; owl:equivalentProperty ex:likes .
```

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/props.ttl'
```

With only an `enjoys` edge stored, a `MATCH` on `@ex:likes` still finds it, and vice versa:

```gql
-- Only an enjoys edge exists on disk
INSERT (@ex:Person {name: 'Alice'})-[@ex:enjoys]->(@ex:Person {name: 'Bob'})

MATCH (a)-[@ex:likes]->(b)  RETURN a.name, b.name   // Alice, Bob — via equivalentProperty
MATCH (a)-[@ex:enjoys]->(b) RETURN a.name, b.name   // Alice, Bob — the stored edge
```

## Showing Object Properties

```gql
SHOW OBJECT PROPERTIES

-- Filter by ontology prefix
SHOW OBJECT PROPERTIES FROM ex
```

Example output:

| property | localName | type | domain | range | characteristics |
| -- | -- | -- | -- | -- | -- |
| http://example.org/knows | knows | ObjectProperty | http://example.org/Person | http://example.org/Person | Symmetric |
| http://example.org/ancestorOf | ancestorOf | ObjectProperty | http://example.org/Person | http://example.org/Person | Transitive |
| http://example.org/hasBirthPlace | hasBirthPlace | ObjectProperty | http://example.org/Person | http://example.org/Location | Functional |
| http://example.org/worksFor | worksFor | ObjectProperty | http://example.org/Person | http://xmlns.com/foaf/0.1/Organization | |
| http://example.org/employs | employs | ObjectProperty | http://xmlns.com/foaf/0.1/Organization | http://example.org/Person | |
| http://example.org/links | links | ObjectProperty | | | |

## Dropping Object Properties

```gql
DROP OBJECT PROPERTY @ex:tempRelation
```

`DROP OBJECT PROPERTY` does **not** delete any existing edges that use this property, they remain on disk and `MATCH (a)-[@ex:tempRelation]->(b)` still finds them as long as the `ex` prefix is loaded (the engine stores IRIs, not the short name).

What stops applying after the drop:

- Validation against `DOMAIN` / `RANGE` and characteristics: new inserts of `@ex:tempRelation` edges have no schema to check against.
- Inferences that relied on the property: `SYMMETRIC` / `TRANSITIVE` / `INVERSE OF` / `REFLEXIVE` / property-chain rollups stop firing for this predicate.

If you want a clean teardown, delete the edges first and then drop the schema:

```gql
-- Remove edges first
MATCH ()-[r@ex:tempRelation]->() DELETE r

-- Then drop the ontology definition
DROP OBJECT PROPERTY @ex:tempRelation
```