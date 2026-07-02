# Using Ontology Labels & IRIs

## Overview

Use ontology class and property labels in `INSERT`, `MATCH`, and `REMOVE` operations to leverage semantic capabilities.

## Ontology Labels

### Ontology Labels on Nodes

Use the `@prefix:class` syntax to assign ontology class labels to nodes. The form works with or without a node variable.

Insert node with ontology class label:

```gql
INSERT (@foaf:Person {name: 'Alice', age: 30})

-- With node variable
INSERT (n@foaf:Person {name: 'Bob'}) RETURN n

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

### Default-Prefix Form (`@:name`)

When a loaded RDF document declares the default (empty) prefix (e.g., `@prefix : <http://example.org/ontology#> .`), its terms are addressable with the `@:name` shorthand. It expands to the full IRI of the default namespace, so it is equivalent to the [full-IRI form](#Full-IRI-Form). It works in `MATCH` and `INSERT`:

```gql
-- These two are equivalent when : maps to http://example.org/ontology#
MATCH (n@:Person) RETURN n.name
MATCH (n@<http://example.org/ontology#Person>) RETURN n.name

-- Insert using the default-prefix form
INSERT (@:Person {name: 'Zoe'})
```

`@:name` is valid syntax even when no default namespace is registered; it simply matches nothing (an empty result, not an error).

### Full IRI Form

Anywhere an ontology label `@prefix:name` or `@:name` is accepted, the full-IRI form `@<http://full-iri>` works as a drop-in replacement. These forms are equivalent; the parser resolves them all to the same IRI internally. The full form is useful when no prefix is loaded for the namespace, or when copy-pasting IRIs from an external ontology.

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

The IRI inside the angle brackets is an `IRI_LITERAL` token. It must be a valid IRI with no embedded whitespace or unescaped `>` characters.

## Data Querying

### Matching by Ontology Label

Match a node or edge by its ontology label by writing the label `@prefix:name` / `@:name` inside the pattern or filter in a `WHERE` clause using `IS LABELED`.

```gql
-- Match nodes by ontology class inside the pattern
MATCH (n@ex:Person WHERE n.age > 25)
RETURN n.name

-- Match edges by ontology object property inside the pattern
MATCH (a)-[@ex:knows]->(b)
RETURN a.name, b.name
```

Filter with `IS LABELED`, it works on a node or an edge variable:

```gql
-- Node
MATCH (n) WHERE n IS LABELED @ex:Person
RETURN n.name

-- Edge
MATCH (a)-[e]->(b) WHERE e IS LABELED @ex:knows
RETURN a.name, b.name
```

### IRI Matching

The `@=` syntax matches nodes by their `_iri` property value. This is useful for finding specific individuals in semantic web data.

**What is the `_iri` property?**

The `_iri` is a regular property that you can optionally set yourself at `INSERT` time. The engine never automatically derives it from the node's class or name. The one path that populates it automatically is <a target="_blank" href="/docs/ontology/loading#Loading-Instance-Data">`LOAD DATA`</a>, which sets it from each RDF subject IRI. A node inserted without `_iri` (e.g., `INSERT (@ex:Person {name: 'Alice'})`) is perfectly valid; it just won't match any `@=` query. The engine maintains a dedicated property index on `_iri` for fast `@=` lookup, but the value itself is yours to assign. 

`_iri` is set once at `INSERT` or by `LOAD DATA`; it is **immutable via `SET`**. `SET n._iri = …` is rejected, and you cannot add one to a node that was inserted without it. To change it, delete and re-insert the node. `_iri` is **node-only**. Edges don't carry one, and setting `_iri` on an edge is rejected as an error.

There are two forms to match by the `_iri` property:

| Syntax | How the target IRI is formed |
| -- | -- |
| `@=prefix:name` | Parser expands `prefix` via the prefix table, then appends `name` (e.g., `ex:alice` → `http://example.org/alice`) |
| `@=<full-iri>` | The literal IRI written directly in angle brackets, no prefix lookup |

```gql
-- Insert nodes with _iri property
INSERT (@ex:Person {name: 'Alice', _iri: 'http://example.org/alice'}),
       (@ex:Person {name: 'Bob', _iri: 'http://example.org/bob'})

-- Match by IRI using prefix
MATCH (n@=ex:alice) RETURN n.name  // Alice

-- Match by full IRI
MATCH (n@=<http://example.org/bob>) RETURN n.name  // Bob
```

### Label vs IRI Matching

The `@` and `@=` forms look similar but ask different questions:

- `@` checks the label (what type the element is), while 
- `@=` checks the `_iri` property (which individual a node is). 

This holds for both the prefixed and full-IRI spellings. The `=` is what decides, not the angle brackets.

| Form | Matches on | The IRI names a… | Works on |
| -- | -- | -- | -- |
| `@prefix:name` / `@<full-iri>` | ontology label (class / object property) | a type | nodes and edges |
| `@=prefix:name` / `@=<full-iri>` | the `_iri` property | an individual | nodes only (edges have no `_iri`) |

```gql
-- Given: (@ex:Person {name: 'Alice', _iri: 'http://example.org/alice'})

-- By label (ontology class): is Alice a Person?
MATCH (n@ex:Person) RETURN n.name                     // Alice
MATCH (n@<http://example.org/Person>) RETURN n.name   // Alice (same, full-IRI spelling)

-- By _iri property: is this the node identified by …/alice?
MATCH (n@=ex:alice) RETURN n.name                     // Alice
MATCH (n@=<http://example.org/alice>) RETURN n.name   // Alice (same, full-IRI spelling)
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

## Combining Ontology and LPG Labels

You can combine ontology labels and LPG labels using `&` (conjunction) and `|` (disjunction).

| Syntax | Description |
| -- | -- |
| `:label&@prefix:class` | Match nodes with both labels (AND) |
| `:label\|@prefix:class` | Match nodes with either label (OR) |

```gql
-- Multiple ontology labels
MATCH (n@foaf:Person&@foaf:Agent) RETURN n.name

-- LPG and ontology labels
INSERT (:Employee&@ex:Person {name: 'Carol', role: 'Developer'})

-- Combine LPG label with IRI match
MATCH (n:Person&@=ex:alice) RETURN n.name
```
