# Class Definitions

## Overview

A **class** is a globally-identified category that nodes belong to, formally similar to a "type" or "label," but with semantic structure attached:

- **Identified by an IRI**. `@foaf:Person` is shorthand for `<http://xmlns.com/foaf/0.1/Person>`. Two systems that use the same IRI are talking about the same class.
- **Can sit in a hierarchy** via `SUBCLASS OF`. If `@ex:Employee SUBCLASS OF @foaf:Person`, querying `MATCH (n@foaf:Person)` returns Employees . This is **subclass inference**.
- **Can be declared disjoint** from others via `DISJOINT WITH`. `@ex:Cat DISJOINT WITH @ex:Dog` means no node may carry both labels.
- **Can act as a domain/range** for object properties. See <a href="/docs/ontology/property-definitions">Property Definitions</a>.
- A node can carry **multiple classes** at once (`:@foaf:Person&@foaf:Agent`), unlike single-inheritance OOP.

How it compares to what you already know:

| | LPG label | Ontology class |
| -- | -- | -- |
| Identity | Local string (`"Person"`) | Global IRI (`@foaf:Person`) |
| Hierarchy | None | `SUBCLASS OF` with automatic inference |
| Disjointness | None | `DISJOINT WITH` enforced by validator |
| Multi-typing | Yes | Yes |
| Schema role | Optional/free-form | Defines what properties are valid |

## Example Graph

The examples below use the `@ex:` and `@foaf:` prefixes. `LOAD ALL PREFIX` registers `foaf` (and the 13 other built-ins), but `ex` is not built-in and must be loaded explicitly. Run this before working through the examples:

```gql
CREATE GRAPH my_ontology_graph WITH ONTOLOGY
USE my_ontology_graph
LOAD ALL PREFIX
LOAD PREFIX ex FROM 'http://example.org/'
```

## Creating Classes

Define a single class:

```gql
CREATE CLASS @ex:Country
```

Define multiple classes back-to-back:

```gql
CREATE CLASS @ex:City
CREATE CLASS @ex:River
CREATE CLASS @ex:Mountain
CREATE CLASS @ex:Location
```

### SUBCLASS OF

Use `SUBCLASS OF` to declare inheritance. 

```gql
-- @foaf:Agent has @foaf:Person as its superclass
CREATE CLASS @foaf:Person
CREATE CLASS @foaf:Agent SUBCLASS OF @foaf:Person

-- Insert an agent
INSERT (@foaf:Agent {name: 'Alice'})

-- Query for @foaf:Person
MATCH (n@foaf:Person) RETURN n.name  // Alice
```

Hierarchies can chain:

```gql
-- @ex:Manager is a subclass of @ex:Employee, which is a subclass of @ex:Person
CREATE CLASS @ex:Person
CREATE CLASS @ex:Employee SUBCLASS OF @ex:Person
CREATE CLASS @ex:Manager SUBCLASS OF @ex:Employee

-- Insert a manager
INSERT (@ex:Manager {name: 'Bob'})

-- Query for @ex:Employee
MATCH (n@ex:Employee) RETURN n.name  // Bob

-- Query for @ex:Person
MATCH (n@ex:Person) RETURN n.name    // Bob
```

A class can have multiple direct superclasses (OWL multi-parent inheritance). List the parents after `SUBCLASS OF`, separated by commas. A node of the subclass is automatically inferred to belong to every ancestor class, and a query for any parent returns it.

Two parallel roles combined into one class:

```gql
-- @ex:TeachingAssistant is a subclass of both @ex:Student and @ex:Staff
CREATE CLASS @ex:Student
CREATE CLASS @ex:Staff
CREATE CLASS @ex:TeachingAssistant SUBCLASS OF @ex:Student, @ex:Staff

-- Insert a TeachingAssistant
INSERT (@ex:TeachingAssistant {name: 'Amy'})

-- Query for @ex:Student
MATCH (n@ex:Student) RETURN n.name  // Amy

-- Query for @ex:Staff
MATCH (n@ex:Staff) RETURN n.name    // Amy
```

### DISJOINT WITH

Declare two classes mutually exclusive — no node may carry both labels:

```gql
-- @ex:Cat and @ex:Dog are disjoint 
CREATE CLASS @ex:Cat
CREATE CLASS @ex:Dog DISJOINT WITH @ex:Cat
```

By default, ontology violations are logged as warnings but the operation proceeds (mode `WARNING`). Switch to `STRICT` to make violations fail with an error:

```gql
SET ONTOLOGY ENFORCEMENT STRICT
```

Now the following insert fails — a node cannot be both `@ex:Cat` and `@ex:Dog`:

```gql
// Error: DISJOINT WITH violation
INSERT (@ex:Cat&@ex:Dog {name: 'Mystery'})
```

`DISJOINT WITH` accepts a comma-separated list, so a class can be declared disjoint from several others at once:

```gql
CREATE CLASS @ex:Mammal
CREATE CLASS @ex:Bird DISJOINT WITH @ex:Mammal
CREATE CLASS @ex:Fish DISJOINT WITH @ex:Mammal, @ex:Bird
```

`SUBCLASS OF` and `DISJOINT WITH` can be combined in one statement. Here `@ex:Intern` is a subclass of `@ex:Person` and disjoint with `@ex:Contractor`:

```gql
CREATE CLASS @ex:Contractor
CREATE CLASS @ex:Intern SUBCLASS OF @ex:Person DISJOINT WITH @ex:Contractor
```

## Showing Classes

List all defined classes:

```gql
SHOW CLASSES
```

Returned columns:

| Column | Description |
| -- | -- |
| `class` | The full IRI of the class — the prefix value concatenated with the local name (e.g., `http://example.org/Person` for `@ex:Person`). |
| `localName` | The part after the colon in `@prefix:LocalName` (e.g., `Person`). |
| `superClasses` | The full IRI(s) of the direct parent(s) declared via `SUBCLASS OF`, comma-separated when there is more than one. Empty when the class has no parent. |
| `label` | Human-readable label for the class. Falls back to the qualified `@prefix:LocalName` form when no `rdfs:label` was attached (for example, when the class is hand-created with bare `CREATE CLASS @ex:Manager`). |

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
DROP CLASS @ex:Employee
```

Equivalent to:

```gql
DROP CLASS @ex:Employee RESTRICT
```

Use `CASCADE` to strip the class label from every node that has it:

```gql
DROP CLASS @ex:Employee CASCADE
```

`CASCADE` removes the label from the affected nodes; the nodes themselves, their other labels, and their properties are left intact. If a node had `@ex:Employee` as its only label, it survives as an unlabeled node.
