# Class Definitions

## Overview

Define ontology classes to categorize nodes with semantic meaning. Classes support inheritance hierarchies and can be marked as disjoint.

## Creating Classes

Define a new ontology class:

```gql
CREATE CLASS @ex:Person
```

Create a class with description:

```gql
CREATE CLASS @ex:Employee DESCRIPTION 'A person who works for an organization'
```

Create multiple related classes:

```gql
CREATE CLASS @ex:Person
CREATE CLASS @ex:Organization
CREATE CLASS @ex:Location
```

## Class Hierarchy (EXTENDS)

Create subclasses using EXTENDS to define inheritance:

```gql
// Person is a subclass of Agent
CREATE CLASS @foaf:Agent
CREATE CLASS @foaf:Person EXTENDS @foaf:Agent
CREATE CLASS @foaf:Organization EXTENDS @foaf:Agent
```

```gql
// Employee extends Person
CREATE CLASS @ex:Person
CREATE CLASS @ex:Employee EXTENDS @ex:Person
CREATE CLASS @ex:Manager EXTENDS @ex:Employee
```

## Subclass Inference

When you query for a superclass, nodes with subclass labels are automatically included:

```gql
// Insert an Employee (which extends Person)
INSERT (:@ex:Employee {name: 'Alice', role: 'Engineer'})
```

```gql
// Query for Person - also returns Employee nodes
MATCH (n@ex:Person)
RETURN n.name, n.role
```

| n.name | n.role |
| -- | -- |
| Alice | Engineer |

```gql
// Query specifically for Employee
MATCH (n@ex:Employee)
RETURN n.name, n.role
```

| n.name | n.role |
| -- | -- |
| Alice | Engineer |

## Disjoint Classes

Mark classes as mutually exclusive - a node cannot have labels from both:

```gql
CREATE CLASS @ex:Cat
CREATE CLASS @ex:Dog DISJOINT WITH @ex:Cat
```

Attempting to create a node with both labels will fail in STRICT enforcement mode:

```gql
// This fails: Cannot be both Cat and Dog
INSERT (:@ex:Cat&@ex:Dog {name: 'Mystery'})
// Error: Disjoint class violation
```

Multiple disjoint declarations:

```gql
CREATE CLASS @ex:Mammal
CREATE CLASS @ex:Bird DISJOINT WITH @ex:Mammal
CREATE CLASS @ex:Fish DISJOINT WITH @ex:Mammal, @ex:Bird
```

## Viewing Classes

List all defined classes:

```gql
SHOW CLASSES
```

| class | superclass | disjoint_with | description |
| -- | -- | -- | -- |
| @ex:Person | | | |
| @ex:Employee | @ex:Person | | A person who works for an organization |
| @ex:Cat | | | |
| @ex:Dog | | @ex:Cat | |

## Deleting Classes

Remove a class definition:

```gql
DROP CLASS @ex:TempClass
```

Remove if exists (no error if class doesn't exist):

```gql
DROP CLASS IF EXISTS @ex:TempClass
```
