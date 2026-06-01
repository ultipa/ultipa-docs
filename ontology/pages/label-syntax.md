# Using Ontology Labels

## Overview

Use ontology class and property labels in `INSERT`, `MATCH`, and `REMOVE` operations to leverage semantic capabilities.

## Ontology Labels

### Ontology Labels on Nodes

Use the `@prefix:class` syntax to assign ontology class labels to nodes. The form works with or without a variable.

Insert node with ontology class label:

```gql
INSERT (@foaf:Person {name: 'Alice', age: 30})

-- Multiple ontology labels using &
INSERT (@foaf:Person&@foaf:Agent {name: 'Bob'})
```

### Ontology Labels on Edges

Edges use the `@prefix:objectProperty` syntax. The form works with or without an edge variable.

Insert edge with ontology label:

```gql
MATCH (a@ex:Person), (b@ex:Person)
WHERE a.name = 'Alice' AND b.name = 'Bob'
INSERT (a)-[@ex:knows]->(b)
```

### Full IRI Form

Anywhere the prefixed form `@prefix:name` is accepted, the full-IRI form `@<http://full-iri>` works as a drop-in replacement. The two are equivalent; the parser resolves both to the same IRI internally. The full form is useful when no prefix is loaded for the namespace, or when copy-pasting IRIs from an external ontology.

Node patterns:

```gql
-- These two are equivalent
MATCH (n@ex:Person) RETURN n.name
MATCH (n@<http://example.org/Person>) RETURN n.name
```

Edge patterns:

```gql
-- These two are equivalent
MATCH (a)-[@ex:knows]->(b) RETURN a.name, b.name
MATCH (a)-[@<http://example.org/knows>]->(b) RETURN a.name, b.name
```

DDL:

```gql
CREATE CLASS @<http://example.org/Person>

CREATE OBJECT PROPERTY @<http://example.org/knows>
  DOMAIN @<http://example.org/Person>
  RANGE @<http://example.org/Person>
```

The IRI inside the angle brackets is a `IRI_LITERAL` token. It must be a valid IRI with no embedded whitespace or unescaped `>` characters.

## Matching by Ontology Label

Match nodes by their ontology label by writing `@prefix:name` inside the pattern, or filter in a `WHERE` clause using `IS LABELED`.

| Syntax | Description |
| -- | -- |
| `MATCH (n@prefix:class)` | Match nodes by ontology class inside the pattern |
| `MATCH (n) WHERE n IS LABELED @prefix:class` | Filter by ontology label in a `WHERE` clause |

Match nodes by ontology class inside the pattern:

```gql
MATCH (n@ex:Person)
WHERE n.age > 25
RETURN n.name, n.age
```

Filter in a `WHERE` clause with `IS LABELED`:

```gql
MATCH (n)
WHERE n IS LABELED @ex:Person
RETURN n.name
```

## IRI Matching

The `@=` syntax matches nodes by their `_iri` property value, NOT by their label. This is useful for finding specific individuals in semantic web data.

The two forms below are just different ways to write the same target IRI. The prefixed form is expanded by the parser into the full IRI before comparison.

| Syntax | How the target IRI is formed |
| -- | -- |
| `@=prefix:localName` | Parser expands `prefix` via the prefix table, concatenates `localName` (e.g., `ex:alice` → `http://example.org/alice`) |
| `@=<http://full-iri>` | The literal IRI written directly in angle brackets, no prefix lookup |

The `_iri` is a regular property that you must set explicitly at `INSERT` time. The engine does not auto-populate it from the node's class or any other source. A node inserted without `_iri` (e.g., `INSERT (@ex:Person {name: 'Alice'})`) will never match an `@=` query. The engine maintains a dedicated property index on `_iri` for fast `@=` lookup, but the value itself is yours to assign.

Insert nodes with `_iri` property:

```gql
INSERT (@ex:Person {name: 'Alice', _iri: 'http://example.org/alice'}),
       (@ex:Person {name: 'Bob', _iri: 'http://example.org/bob'})
```

Match by IRI using prefix:

```gql
MATCH (n@=ex:alice)
RETURN n.name
```

Result: 

| n.name |
| -- |
| Alice |

Match by full IRI:

```gql
MATCH (n@=<http://example.org/bob>)
RETURN n.name
```

Result: 

| n.name |
| -- |
| Bob |

Label match vs IRI match:

```gql
-- Given: (@ex:Person {name: 'Alice', _iri: 'http://example.org/alice'})

-- This matches by LABEL (ontology class)
MATCH (n@ex:Person) RETURN n.name  // Returns Alice

-- This matches by _iri PROPERTY
MATCH (n@=ex:alice) RETURN n.name  // Returns Alice

-- These are DIFFERENT: one checks label, one checks _iri property
```

## Removing Ontology Labels

Use the `REMOVE` statement to remove ontology labels from nodes. The node itself remains; only the label is removed.

Remove ontology label from a node:

```gql
MATCH (n@foaf:Person)
WHERE n.name = 'Alice'
REMOVE n@foaf:Person
```

Verify label was removed:

```gql
-- This now returns empty; Alice no longer has the label
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
| `:label&@prefix:class` | Match nodes with both labels (AND) |
| `:label\|@prefix:class` | Match nodes with either label (OR) |

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
