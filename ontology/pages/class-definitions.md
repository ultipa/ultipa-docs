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

Mental model: an LPG label is just a sticker on a node. An ontology class is a sticker that **also** says what it's a kind of, what it can't be, and what edges/properties make sense on it, and the database uses all of that during query and validation.

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
```

## Creating Class Hierarchy

### SUBCLASS OF

Use `SUBCLASS OF` to declare inheritance. Here `@foaf:Person` and `@foaf:Organization` both have `@foaf:Agent` as their superclass:

```gql
CREATE CLASS @foaf:Agent
CREATE CLASS @foaf:Person SUBCLASS OF @foaf:Agent
CREATE CLASS @foaf:Organization SUBCLASS OF @foaf:Agent
```

Hierarchies can chain. Here `@ex:Manager` is a subclass of `@ex:Employee`, which is a subclass of `@ex:Person`:

```gql
CREATE CLASS @ex:Person
CREATE CLASS @ex:Employee SUBCLASS OF @ex:Person
CREATE CLASS @ex:Manager SUBCLASS OF @ex:Employee
```

### Subclass Inference

Continuing from the chain above (`@ex:Employee SUBCLASS OF @ex:Person`), insert an Employee:

```gql
INSERT (:@ex:Employee {name: 'Alice', role: 'Engineer'})
```

Query for `@ex:Person` — `Alice` is returned, because `Employee` is a subclass of `Person`:

```gql
MATCH (n@ex:Person)
RETURN n.name, n.role
```

Result:

| n.name | n.role |
| -- | -- |
| Alice | Engineer |

Querying for `@ex:Employee` directly returns the same row:

```gql
MATCH (n@ex:Employee)
RETURN n.name, n.role
```

Result:

| n.name | n.role |
| -- | -- |
| Alice | Engineer |

## Disjoining Classes

### DISJOINT WITH

Declare two classes mutually exclusive — no node may carry both labels:

```gql
CREATE CLASS @ex:Cat
CREATE CLASS @ex:Dog DISJOINT WITH @ex:Cat
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

### Disjoint Classes

By default, ontology violations are logged as warnings but the operation proceeds (mode `WARNING`). Switch to `STRICT` to make violations fail with an error:

```gql
SET ONTOLOGY ENFORCEMENT STRICT
```

Now the following insert fails — a node cannot be both `@ex:Cat` and `@ex:Dog`:

```gql
// Error: DISJOINT WITH violation
INSERT (:@ex:Cat&@ex:Dog {name: 'Mystery'})
```

See <a href="/docs/ontology/validation">Validation & Enforcement</a> for the full mode comparison.

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
| `superClasses` | The full IRI of the direct parent declared via `SUBCLASS OF`. Empty when the class has no parent. |
| `label` | Human-readable label for the class. Defaults to the local name when none was set by the source ontology. |

Example output:

| class | localName | superClasses | label |
| -- | -- | -- | -- |
| http://example.org/Person | Person | | Person |
| http://example.org/Employee | Employee | http://example.org/Person | Employee |
| http://example.org/Cat | Cat | | Cat |
| http://example.org/Dog | Dog | | Dog |

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
