# Class Definitions

## Overview

A **class** is a globally-identified category that nodes belong to, formally similar to a "type" or "label," but with semantic structure attached:

- **Identified by an IRI**. `@foaf:Person` is shorthand for `<http://xmlns.com/foaf/0.1/Person>`. Two systems that use the same IRI are talking about the same class.
- **Can sit in a hierarchy** via `SUBCLASS OF`. If `@ex:Employee SUBCLASS OF @ex:Person`, querying `MATCH (n@ex:Person)` returns Employees. This is **subclass inference**.
- **Can be declared disjoint** from others via `DISJOINT WITH`. `@ex:Cat DISJOINT WITH @ex:Dog` means no node may carry both labels.
- **Can be defined by inference** via `EQUIVALENT TO`. `@ex:Director EQUIVALENT TO (@ex:directed SOME @ex:Film)` means any individual directed at least one film is classified at query time as `@ex:Director`.
- **Can be assembled from other classes** via the OWL constructors `owl:unionOf` / `owl:intersectionOf` / `owl:oneOf` / `owl:equivalentClass`, carried in a loaded ontology.

How it compares to LPG:

| | LPG label | Ontology class |
| -- | -- | -- |
| Identity | Local string (`:Person`) | Global IRI (`@foaf:Person`) |
| Hierarchy | None | `SUBCLASS OF` with automatic inference |
| Disjointness | None | `DISJOINT WITH` enforced by validator |
| Defined / inferred classes | None | `EQUIVALENT TO` rule classifies members at query time |
| Multiple labels per node | Yes | Yes |

## Example Graph

Run this before working through the examples:

```gql
CREATE GRAPH myOntology WITH ONTOLOGY
USE myOntology
LOAD PREFIX ex FROM 'http://example.org/'
```

## Creating Classes

### Basic Form

Define classes without any axioms:

```gql
CREATE CLASS @ex:Country
CREATE CLASS @ex:City
```

### SUBCLASS OF

Use `SUBCLASS OF` to declare a subclass inference: every member of the child class is also a member of the parent class.

<p tit="Hierarchy"></p>

```gql
@ex:Agent
   └── @ex:Person
          └── @ex:Employee
                └── @ex:Manager
```

```gql
CREATE CLASS @ex:Agent
CREATE CLASS @ex:Person SUBCLASS OF @ex:Agent

-- Hierarchies can chain

CREATE CLASS @ex:Employee SUBCLASS OF @ex:Person
CREATE CLASS @ex:Manager SUBCLASS OF @ex:Employee

-- Insert a manager Bob
INSERT (@ex:Manager {name: 'Bob'})

-- Query for @ex:Employee / @ex:Person / @ex:Agent also returns Bob
MATCH (n@ex:Employee) RETURN n.name  // Bob
MATCH (n@ex:Person) RETURN n.name    // Bob
MATCH (n@ex:Agent) RETURN n.name     // Bob
```

A class can have multiple direct superclasses (multi-parent hierarchy). List the parents after `SUBCLASS OF`, separated by commas. A node of the subclass is automatically inferred to belong to every ancestor class, and a query for any parent returns it.

Two parallel roles combined into one class:

<p tit="Hierarchy"></p>

```gql
@ex:Student    @ex:Staff
       \          /
   @ex:TeachingAssistant
```

```gql
CREATE CLASS @ex:Student
CREATE CLASS @ex:Staff
CREATE CLASS @ex:TeachingAssistant SUBCLASS OF @ex:Student, @ex:Staff

-- Insert a TeachingAssistant
INSERT (@ex:TeachingAssistant {name: 'Amy'})

-- Query for @ex:Student / @ex:Staff also returns @ex:TeachingAssistant
MATCH (n@ex:Student) RETURN n.name  // Amy
MATCH (n@ex:Staff) RETURN n.name    // Amy
```

### DISJOINT WITH

Declare two classes mutually exclusive, means no node may carry both labels:

```gql
CREATE CLASS @ex:Cat
CREATE CLASS @ex:Dog DISJOINT WITH @ex:Cat
```

By default, ontology violations are logged as warnings but the operation proceeds (`WARNING` mode). Switch to `STRICT` to make violations fail with an error:

```gql
SET ONTOLOGY ENFORCEMENT STRICT
```

Now the following insert fails as a node cannot be both `@ex:Cat` and `@ex:Dog`:

```gql
-- Error: DISJOINT WITH violation
INSERT (@ex:Cat&@ex:Dog {name: 'Mystery'})
```

`DISJOINT WITH` accepts a comma-separated list, so a class can be declared disjoint from several others at once:

```gql
CREATE CLASS @ex:Mammal
CREATE CLASS @ex:Bird DISJOINT WITH @ex:Mammal
CREATE CLASS @ex:Fish DISJOINT WITH @ex:Mammal, @ex:Bird
```

`SUBCLASS OF` and `DISJOINT WITH` can be combined:

```gql
CREATE CLASS @ex:Contractor
CREATE CLASS @ex:Intern SUBCLASS OF @ex:Person DISJOINT WITH @ex:Contractor
```

In GQLDB, `DISJOINT WITH` is a **write-time validation**; it is not an inference rule. It does not expand the subclass hierarchy or any inferred membership: a node carrying both `@ex:Cat` and `@ex:Dog` is caught, but one carrying `@ex:Kitten` (a subclass of `@ex:Cat`) alongside `@ex:Dog` is not.

This is a deliberate design choice. GQLDB gives `owl:disjointWith` a closed-world, constraint reading, the same approach as [SHACL](https://www.w3.org/TR/shacl/) validation rather than the open-world OWL entailment reading, where a Cat-and-Dog node would instead render the whole model logically inconsistent. The constraint reading is what data-ingestion workflows typically want: reject the offending write, pinpointed to the node, rather than a global inconsistency. The [`STRICT` / `WARNING` / `OFF` enforcement modes](/docs/ontology/validation) tune how strictly it's applied.

### EQUIVALENT TO

A **defined class** declares membership by an `EQUIVALENT TO` axiom instead of an explicit label. Members are **inferred at query time** from a property restriction. The database classifies entities automatically, with no labeling and no materialization.

`EQUIVALENT TO` classification is **one-directional**: entities matching the axiom are classified into the defined class, but the class itself stays virtual (never a stored label) and adds nothing back to those entities. This differs from a loaded `owl:equivalentClass` axiom, which makes two classes **mutually** inclusive. See [Class Constructors (Load-Only)](#Class-Constructors-(Load-Only)).

To see the contrast, compare a **primitive** class (you tag the node) with a **defined** class (the rule tags it for you):

```gql
-- Primitive class: Lana must be explicitly labeled @ex:Director on insert
CREATE CLASS @ex:Director
INSERT (@ex:Director {name: 'Lana'})

MATCH (n@ex:Director) RETURN n.name   // Lana, label was written on the node
```

```gql
-- Defined class: no @ex:Director label is written anywhere
CREATE CLASS @ex:Film
CREATE OBJECT PROPERTY @ex:directed
CREATE CLASS @ex:Director EQUIVALENT TO (@ex:directed SOME @ex:Film)

-- Any individual who directed at least one film is inferred as a director
-- No @ex:Director label needs to be written
INSERT (lana@ex:Person {name: 'Lana'})-[@ex:directed]->(@ex:Film {name: 'The Matrix'})

MATCH (n@ex:Director) RETURN n.name   // Lana, classified at query time by the rule
```

`EQUIVALENT TO` can also use `AND` to combine a named class (subclass-aware) with a property restriction, so membership requires **both**: being a member of the class and satisfying the restriction.

```gql
-- A Veteran is a @ex:Person who served in at least one MilitaryBranch
CREATE CLASS @ex:MilitaryBranch
CREATE OBJECT PROPERTY @ex:servedIn
CREATE CLASS @ex:Veteran EQUIVALENT TO @ex:Person AND (@ex:servedIn SOME @ex:MilitaryBranch)

-- An equipment once served is not a veteran
CREATE CLASS @ex:Equipment
INSERT (@ex:Equipment {name: 'Tank-72'})-[@ex:servedIn]->(@ex:MilitaryBranch {name: 'Army 07'})

MATCH (n@ex:Veteran) RETURN n.name   // No data
```

Supported restriction operators:

| Operator | OWL equivalent | Meaning |
| -- | -- | -- |
| `SOME` | `owl:someValuesFrom` | At least one value of the property is in the filler class. |
| `ONLY` | `owl:allValuesFrom` | Every value of the property is in the filler class (vacuously true when there are no such edges). |

```gql
-- A vegetarian restaurant is one whose menu, if it has one, is entirely vegetarian
CREATE CLASS @ex:Dish
CREATE CLASS @ex:VegetarianDish SUBCLASS OF @ex:Dish
CREATE CLASS @ex:Restaurant
CREATE OBJECT PROPERTY @ex:serves DOMAIN @ex:Restaurant RANGE @ex:Dish
CREATE CLASS @ex:VegetarianRestaurant EQUIVALENT TO @ex:Restaurant AND (@ex:serves ONLY @ex:VegetarianDish)
```

### Class Constructors (Load-Only)

GQLDB recognizes four OWL class constructors carried in a <a href="/docs/ontology/loading" target="_blank"><code>LOAD ONTOLOGY</code></a> file. They classify members **at query time**: the constructed class label is never stored on the node — a node inserted as `@ex:Cat` keeps only that label, yet still matches `@ex:Pet` if `Pet` is the union of `Cat` and `Dog`.

| Constructor | A node is a member of the class when it… |
| -- | -- |
| `owl:unionOf` | carries **any one** of the member classes (or a subclass of one) |
| `owl:intersectionOf` | carries **every** one of the member classes (subclass-aware) |
| `owl:oneOf` | is **one of the enumerated individuals** (matched by `_iri`) |
| `owl:equivalentClass` | carries the equivalent class (equivalence is **mutual**) |

They have no inline DDL keywords.

Load this vocabulary:

<p tit="vehicles.ttl"></p>

```ttl
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix ex:  <http://example.org/> .

ex:Car a owl:Class .
ex:Truck a owl:Class .
ex:Emergency a owl:Class .
ex:Motorcycle a owl:Class .

# unionOf: a Vehicle is a Car or a Truck
ex:Vehicle a owl:Class ; owl:unionOf ( ex:Car ex:Truck ) .

# intersectionOf: a FireTruck is both a Truck and an Emergency vehicle
ex:FireTruck a owl:Class ;
  owl:equivalentClass [ owl:intersectionOf ( ex:Truck ex:Emergency ) ] .

# equivalentClass: Motorbike and Motorcycle are the same class
ex:Motorbike a owl:Class ; owl:equivalentClass ex:Motorcycle .

# oneOf: a SignalColor is exactly Red or Green
ex:SignalColor a owl:Class ; owl:oneOf ( ex:Red ex:Green ) .
```

```gql
LOAD ONTOLOGY FROM 'file:///srv/onto/vehicles.ttl'
```

Then load some instance data — each subject IRI becomes the node's `_iri`, which is what `owl:oneOf` matches on:

<p tit="vehicles-data.ttl"></p>

```ttl
@prefix ex: <http://example.org/> .

ex:tesla   a ex:Car .
ex:engine1 a ex:Truck , ex:Emergency .
ex:harley  a ex:Motorcycle .
ex:Red     a ex:Color .
ex:Green   a ex:Color .
ex:Amber   a ex:Color .
```

```gql
LOAD DATA FROM 'file:///srv/onto/vehicles-data.ttl'
```

The four constructors now classify these nodes at query time:

```gql
MATCH (n@ex:Vehicle)     RETURN n   // tesla (Car) + engine1 (Truck) — union members
MATCH (n@ex:FireTruck)   RETURN n   // engine1 only — carries both Truck and Emergency
MATCH (n@ex:Motorbike)   RETURN n   // harley — Motorbike ≡ Motorcycle
MATCH (n@ex:SignalColor) RETURN n   // Red + Green, not Amber — enumerated individuals
```

A few details worth knowing:

- **`owl:unionOf` is retrieval-only.** Members are treated as subclasses of the union (`Car ⊑ Vehicle`, `Truck ⊑ Vehicle`), so querying the union returns their instances. GQLDB does not read it in reverse to require that every `@ex:Vehicle` also be a `Car` or `Truck`.
- **`owl:equivalentClass` is mutual and composes with the hierarchy.** Querying either class returns the other's instances, transitively through `SUBCLASS OF`.
- **`owl:oneOf` matches by `_iri`.** The enumerated members are identified by their subject IRI (the `_iri` property `LOAD DATA` assigns each node), not by class label. A node created with a plain GQL `INSERT` that doesn't set `_iri` has none, so no `owl:oneOf` class will match it.
- Because all four are inferred live, they stay in sync with the data: deleting a node's `@ex:Emergency` label drops it from `@ex:FireTruck` on the next query.

## Showing Classes

List all defined classes:

```gql
SHOW CLASSES
```

Example output:

| class | localName | superClasses | label |
| -- | -- | -- | -- |
| http://example.org/Person | Person | | @ex:Person |
| http://example.org/Employee | Employee | http://example.org/Person | @ex:Employee |
| http://example.org/Manager | Manager | http://example.org/Employee, http://example.org/Leader | @ex:Manager |
| http://example.org/Cat | Cat | | @ex:Cat |

Filter the output to a single prefix:

```gql
SHOW CLASSES FROM ex
```

Drill down into one class with `SHOW CLASS @prefix:Name` — a richer view that adds subclasses, disjoint classes, the properties that name this class as their domain, and a live instance count:

```gql
SHOW CLASS @ex:Person
```

Returned columns:

| Column | Description |
| -- | -- |
| `class` | The full IRI of the class. |
| `localName` | The local name (the part after the colon). |
| `prefix` | The prefix associated with the class's IRI namespace. |
| `superClasses` | Comma-separated full IRIs of every direct parent. |
| `subclasses` | Comma-separated full IRIs of every direct subclass. |
| `disjointWith` | Comma-separated full IRIs of classes declared mutually exclusive via `DISJOINT WITH`. |
| `domainOf` | Comma-separated full IRIs of object and data properties whose `DOMAIN` includes this class. |
| `instanceCount` | The number of nodes currently carrying this class label (taken from statistics). |

## Dropping Classes

The `RESTRICT` mode is applied by default when dropping a class, where the drop fails if any nodes still carry the class label.

```gql
DROP CLASS @ex:Person

-- Equivalent to
DROP CLASS @ex:Person RESTRICT
```

Use `CASCADE` to strip the class label from every node that has it:

```gql
DROP CLASS @ex:Person CASCADE
```

`CASCADE` removes the label from the affected nodes; the nodes themselves, their other labels, and their properties are left intact. If a node had `@ex:Person` as its only label, it survives as an unlabeled node.
