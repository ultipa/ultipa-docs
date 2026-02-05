# Using Ontology Labels

## Overview

Use ontology class and property labels in INSERT, MATCH, and REMOVE operations to leverage semantic capabilities.

## Ontology Labels on Nodes

Use the `@prefix:ClassName` syntax to assign ontology class labels to nodes:

**Syntax:** `:@prefix:ClassName` in INSERT or MATCH patterns.

| Syntax | Description |
| -- | -- |
| `:@prefix:ClassName` | Assign an ontology class to a node |
| `:@prefix:Class1&@prefix:Class2` | Assign multiple ontology classes using & |

Insert node with ontology class label:

```gql
INSERT (:@foaf:Person {name: 'Alice', age: 30})
```

Insert node with multiple ontology labels:

```gql
INSERT (:@foaf:Person&@foaf:Agent {name: 'Bob'})
```

Create a path with ontology labels:

```gql
INSERT (:@ex:Person {name: 'Alice'})-[:@ex:knows]->(:@ex:Person {name: 'Bob'})
```

## Ontology Labels on Edges

Edges can also have ontology labels using the `@prefix:propertyName` syntax. This enables domain/range validation and property characteristics like SYMMETRIC and TRANSITIVE.

**Syntax:** `[:@prefix:propertyName]` in edge patterns.

| Syntax | Description |
| -- | -- |
| `[:@prefix:propertyName]` | Assign an ontology object property to an edge |
| `[@<http://full-iri>]` | Use full IRI for edge type |

Insert edge with ontology label:

```gql
MATCH (a@ex:Person), (b@ex:Person)
WHERE a.name = 'Alice' AND b.name = 'Bob'
INSERT (a)-[:@ex:knows]->(b)
```

Match edges by ontology property:

```gql
MATCH (a)-[r:@ex:knows]->(b)
RETURN a.name, b.name
```

Edge with full IRI syntax:

```gql
MATCH (a)-[@<http://example.org/knows>]->(b)
RETURN a.name, b.name
```

## Matching by Ontology Label

Use `@prefix:name` (without colon before @) to match nodes by their ontology class label:

**Important:** This matches the actual label assigned to the node.

| Syntax | Description |
| -- | -- |
| `MATCH (n@prefix:ClassName)` | Match nodes by ontology class label |
| `MATCH (n) WHERE n@prefix:ClassName` | Filter by ontology label in WHERE clause |

Match nodes by ontology class:

```gql
MATCH (n@foaf:Person)
RETURN n.name
```

Subclass inference - Employee extends Person:

```gql
// Querying Person also returns Employee nodes
MATCH (n@ex:Person)
RETURN n.name, n.role
```

Match with both label and properties:

```gql
MATCH (n@ex:Person)
WHERE n.age > 25
RETURN n.name, n.age
```

## IRI Matching (@= Syntax)

The `@=` syntax matches nodes by their `_iri` property value, NOT by their label. This is useful for finding specific individuals in semantic web data.

**Key Distinction:**
- `@prefix:name` - matches by **label** (ontology class)
- `@=prefix:name` - matches by **_iri property** value

| Syntax | Description |
| -- | -- |
| `@=prefix:localName` | Match node where _iri equals the expanded IRI |
| `@=<http://full-iri>` | Match node where _iri equals the full IRI |

Insert nodes with _iri property:

```gql
INSERT (:Person {name: 'Alice', _iri: 'http://example.org/alice'})
INSERT (:Person {name: 'Bob', _iri: 'http://example.org/bob'})
```

Match by IRI using prefix:

```gql
MATCH (n@=ex:alice)
RETURN n.name
```

| n.name |
| -- |
| Alice |

Match by full IRI:

```gql
MATCH (n@=<http://example.org/bob>)
RETURN n.name
```

| n.name |
| -- |
| Bob |

Label match vs IRI match:

```gql
// Given: (:@ex:Person {name: 'Alice', _iri: 'http://example.org/alice'})

// This matches by LABEL (ontology class)
MATCH (n@ex:Person) RETURN n.name  // Returns Alice

// This matches by _iri PROPERTY
MATCH (n@=ex:alice) RETURN n.name  // Returns Alice

// These are DIFFERENT - one checks label, one checks _iri property
```

## Removing Ontology Labels

Use the `REMOVE` clause to remove ontology labels from nodes. The node itself remains; only the label is removed.

**Syntax:** `REMOVE variable@prefix:ClassName`

Remove ontology label from a node:

```gql
MATCH (n@foaf:Person)
WHERE n.name = 'Alice'
REMOVE n@foaf:Person
```

Verify label was removed:

```gql
// This now returns empty - Alice no longer has the label
MATCH (n@foaf:Person)
WHERE n.name = 'Alice'
RETURN n
```

Node still exists with its properties:

```gql
MATCH (n)
WHERE n.name = 'Alice'
RETURN n.name, n.age
```

## Combining Labels

You can combine regular labels, ontology labels, and IRI matching using `&` (conjunction) and `|` (disjunction).

| Syntax | Description |
| -- | -- |
| `:Label&@prefix:Class` | Match nodes with both labels (AND) |
| `:Label\|@prefix:Class` | Match nodes with either label (OR) |

Combine regular label with IRI match:

```gql
MATCH (n:Person&@=ex:alice)
RETURN n.name
```

Multiple ontology labels:

```gql
MATCH (n@foaf:Person&@foaf:Agent)
RETURN n.name
```

Insert with regular and ontology labels:

```gql
INSERT (:Employee&@ex:Person {name: 'Carol', role: 'Developer'})
```
