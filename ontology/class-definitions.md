# Class Definitions

## Overview

A **class** is a globally-identified category that nodes belong to, formally similar to a "type" or "label," but with semantic structure attached:

- **Identified by an IRI**. `@foaf:Person` is shorthand for `<http://xmlns.com/foaf/0.1/Person>`. Two systems that use the same IRI are talking about the same class.
- **Can sit in a hierarchy** via `SUBCLASS OF`. If `@ex:Employee SUBCLASS OF @foaf:Person`, querying `MATCH (n@foaf:Person)` returns Employees. This is **subclass inference**.
- **Can be declared disjoint** from others via `DISJOINT WITH`. `@ex:Cat DISJOINT WITH @ex:Dog` means no node may carry both labels.
- **Can be defined by inference** via `EQUIVALENT TO`. `@ex:Director EQUIVALENT TO (@ex:directed SOME @ex:Film)` means any individual directed at least one film is classified at query time as `@ex:Director`.

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
LOAD PREFIX foaf FROM 'http://xmlns.com/foaf/0.1/'
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

Use `SUBCLASS OF` to declare a subclass relationship: every member of the child class is also a member of the parent class.

<p tit="Hierarchy"></p>

```gql
@foaf:Person
   └── @foaf:Agent
```

```gql
CREATE CLASS @foaf:Person
CREATE CLASS @foaf:Agent SUBCLASS OF @foaf:Person

-- Insert an agent
INSERT (@foaf:Agent {name: 'Alice'})

-- Query for @foaf:Person also returns @foaf:Agent
MATCH (n@foaf:Person) RETURN n.name  // Alice
```

Hierarchies can chain:

<p tit="Hierarchy"></p>

```gql
@ex:Person
   └── @ex:Employee
          └── @ex:Manager
```

```gql
CREATE CLASS @ex:Person
CREATE CLASS @ex:Employee SUBCLASS OF @ex:Person
CREATE CLASS @ex:Manager SUBCLASS OF @ex:Employee

-- Insert a manager
INSERT (@ex:Manager {name: 'Bob'})

-- Query for @ex:Employee also returns @ex:Manager
MATCH (n@ex:Employee) RETURN n.name  // Bob

-- Query for @ex:Person also returns @ex:Employee and @ex:Manager 
MATCH (n@ex:Person) RETURN n.name    // Bob
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

-- Query for @ex:Student also returns @ex:TeachingAssistant
MATCH (n@ex:Student) RETURN n.name  // Amy

-- Query for @ex:Staff also returns @ex:TeachingAssistant
MATCH (n@ex:Staff) RETURN n.name    // Amy
```

### DISJOINT WITH

Declare two classes mutually exclusive — no node may carry both labels:

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

### EQUIVALENT TO

A **defined class** declares membership by an `EQUIVALENT TO` axiom instead of an explicit label. Members are **inferred at query time** from a property restriction. The database classifies entities automatically, with no labeling and no materialization.

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

If Lana later stops directing films (the edges to `@ex:Film` are deleted), the next `MATCH (n@ex:Director)` excludes her — no relabeling required. Useful for derived categories that would otherwise drift out of sync with the data.

`EQUIVALENT TO` can also combine a class restriction:

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
