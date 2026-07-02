# Inference & Validation

## Overview

An ontology in GQLDB does two jobs at runtime: it **infers** extra facts when you query, and it **validates** your data against constraints when you write. The two are independent: inference always runs, while validation is what the enforcement modes control.

This page draws that distinction, then covers the enforcement modes that tune validation, how to surface violations, and the transitive-inference depth control.

## Inference vs. Validation

GQLDB acts on ontology axioms in two distinct ways, on opposite sides of a query:

- **Inference (read side).** The engine derives facts at query time. Nothing is written to disk, the extra results are computed on read. Inference is always applied.
- **Validation (write side).** The engine checks data against constraints at write time. The [enforcement mode](#Enforcement-Modes) decides what happens when a violation is detected.

| Side | Ontology features |
| -- | -- |
| **Inference** | `SUBCLASS OF`, `EQUIVALENT TO`, `owl:unionOf`/`intersectionOf`/`oneOf`/`equivalentClass`, `SYMMETRIC`, `TRANSITIVE`, `REFLEXIVE`, `INVERSE OF`, `SUBPROPERTY OF`, `PROPERTY CHAIN`, `owl:equivalentProperty` |
| **Validation** | `DISJOINT WITH`, `DOMAIN`/`RANGE`, `ASYMMETRIC`, `FUNCTIONAL`, `INVERSE_FUNCTIONAL`, `IRREFLEXIVE`, `CARDINALITY`, data-property XSD type |

## Enforcement Modes

Control how strictly ontology rules are validated with three modes:

| Mode | Behavior |
| -- | -- |
| `STRICT` | Violations cause errors and block operations |
| `WARNING` | **Default.** Violations are logged but operations proceed |
| `OFF` | No validation (useful for bulk imports) |

```gql
-- Check current enforcement mode
SHOW ONTOLOGY ENFORCEMENT

-- Enable strict enforcement
SET ONTOLOGY ENFORCEMENT STRICT

-- Enable warning mode
SET ONTOLOGY ENFORCEMENT WARNING

-- Disable enforcement
SET ONTOLOGY ENFORCEMENT OFF
```

### STRICT

In `STRICT` mode, any ontology constraint violation will cause an error and block the operation. Use this in production to ensure data quality.

```gql
-- Setup domain/range constraints
CREATE OBJECT PROPERTY @ex:worksFor DOMAIN @ex:Person RANGE @ex:Organization

SET ONTOLOGY ENFORCEMENT STRICT

-- This succeeds: Person -> Organization
INSERT (@ex:Person {name: 'Alice'})-[@ex:worksFor]->(@ex:Organization {name: 'Acme'})

-- This fails: Organization -> Organization violates DOMAIN
INSERT (@ex:Organization {name: 'Org1'})-[@ex:worksFor]->(@ex:Organization {name: 'Org2'})
```

### WARNING

In `WARNING` mode, constraint violations are logged but operations proceed. Use this during migration or development to identify issues without blocking work.

```gql
SET ONTOLOGY ENFORCEMENT WARNING

-- This succeeds but logs a warning
-- Warning logged: Domain constraint violation - source should be @ex:Person
INSERT (@ex:Organization {name: 'Org1'})-[@ex:worksFor]->(@ex:Organization {name: 'Org2'})
```

View warnings after operations:

```gql
SHOW ONTOLOGY WARNINGS
```

Result:

| type | message | timestamp |
| -- | -- | -- |
| DOMAIN_MISMATCH | Source node does not match domain constraint for @ex:worksFor (expected: [http://example.org/Person]) | 1779101828 |

### Bulk Import Note

For large imports, use `WARNING` mode: constraint violations are logged (not blocking) as each row is written, so the import runs to completion and you can review the issues afterward.

```gql
SET ONTOLOGY ENFORCEMENT WARNING

-- Bulk import; violations are logged, not blocked
INSERT (@ex:Person {name: 'Alice'})
INSERT (@ex:Person {name: 'Bob'})
INSERT (@ex:Organization {name: 'Acme'})
// thousands more inserts ...

-- Review what was flagged during the import
SHOW ONTOLOGY WARNINGS
VALIDATE ONTOLOGY
```

`OFF` is faster still as it skips the constraint checks entirely, but no warnings are logged. Use `OFF` only for data you already trust; to check `OFF`-imported data you must re-run the writes under `WARNING` or `STRICT`.

## Validating Ontology

`VALIDATE ONTOLOGY` returns a one-row snapshot: the ontology counts plus the number of warnings currently in the warning store. It does not rescan stored data, it just reports the violations already logged at write time (as `INSERT`s ran under `WARNING` mode), not a fresh audit of the graph. So it never surfaces problems in data written under `OFF`, or in data that predates the constraint. For the individual violations, use `SHOW ONTOLOGY WARNINGS`.

```gql
VALIDATE ONTOLOGY
```

Example output:

| status | ontologies | classes | properties | warnings |
| -- | -- | -- | -- | -- |
| OK | 1 | 18 | 8 | 0 |

Returned columns:

| Column | Description |
| -- | -- |
| `status` | `OK` when the warnings count is zero, `WARNINGS` otherwise. |
| `ontologies` | Number of registered ontologies (one per `LOAD ONTOLOGY` import plus an optional `local` one for inline `CREATE` definitions). |
| `classes` | Total class count across all ontologies. |
| `properties` | Total object + data property count across all ontologies. |
| `warnings` | Number of warnings currently in the warning store. Cleared by `CLEAR ONTOLOGY WARNINGS`. |

Worked example — set up a constraint, plant a violation under `WARNING`, then check the report:

```gql
CREATE OBJECT PROPERTY @ex:employs DOMAIN @ex:Organization RANGE @ex:Person

SET ONTOLOGY ENFORCEMENT WARNING

-- DOMAIN_MISMATCH: source should be @ex:Organization, not @ex:Person
INSERT (@ex:Person {name: 'Alice'})-[@ex:employs]->(@ex:Person {name: 'Bob'})

VALIDATE ONTOLOGY
```

The report increments `warnings` and flips `status` to `WARNINGS`, while the per-row details are available via `SHOW ONTOLOGY WARNINGS`.

`VALIDATE ONTOLOGY` also accepts an optional mode that updates the current enforcement before running:

```gql
VALIDATE ONTOLOGY STRICT
VALIDATE ONTOLOGY WARNING
```

### Validation Types

The ontology validator checks for the following types of constraint violations. The same types appear in `SHOW ONTOLOGY WARNINGS` and in `VALIDATE ONTOLOGY` output.

| Type | Triggered by |
| -- | -- |
| `CLASS_NOT_FOUND` | Node has an ontology label for an undefined class |
| `DOMAIN_MISMATCH` | Edge source doesn't match the property's `DOMAIN` |
| `RANGE_MISMATCH` | Edge target doesn't match the property's `RANGE` |
| `DISJOINT_VIOLATION` | Node carries labels from two `DISJOINT WITH` classes |
| `ASYMMETRIC_VIOLATION` | An `ASYMMETRIC` property has the reverse edge, or a self-loop |
| `IRREFLEXIVE_VIOLATION` | An `IRREFLEXIVE` property has a self-loop |
| `FUNCTIONAL_VIOLATION` | More than one outgoing edge for a `FUNCTIONAL` (i.e. `CARDINALITY {0,1}`) property |
| `INVERSE_FUNCTIONAL_VIOLATION` | An `INVERSE_FUNCTIONAL` property's target already has a different source |
| `CARDINALITY_VIOLATION` | Value/edge count falls outside the declared `CARDINALITY` bounds |
| `TYPE_MISMATCH` | Data property value doesn't match the declared XSD type |

Domain violation example:

```gql
CREATE OBJECT PROPERTY @ex:employs DOMAIN @ex:Organization RANGE @ex:Person

-- Wrong: Person cannot employ (domain is Organization)
-- DOMAIN_MISMATCH: source must be @ex:Organization
INSERT (@ex:Person {name: 'Alice'})-[@ex:employs]->(@ex:Person {name: 'Bob'})
```

Range violation example:

```gql
-- Wrong: Organization cannot be employed (range is Person)
-- RANGE_MISMATCH: target must be @ex:Person
INSERT (@ex:Organization {name: 'Acme'})-[@ex:employs]->(@ex:Organization {name: 'Other'})
```

## Viewing Warnings

When using `WARNING` mode, violations are stored in a warnings log that you can query.

```gql
SHOW ONTOLOGY WARNINGS
```

Example output:

| type | message | timestamp |
| -- | -- | -- |
| TYPE_MISMATCH	| Property age expects http://www.w3.org/2001/XMLSchema#integer, got types.StringValue | 1779101357 |
| CARDINALITY_VIOLATION	| Property fullName requires at least 1 value(s), got 0	| 1779101357 |

Reset the accumulated warnings log:

```gql
CLEAR ONTOLOGY WARNINGS
```

## Transitive Inference Depth

`TRANSITIVE` object properties expand inference chains across edges. Use `SET ONTOLOGY TRANSITIVE DEPTH` to cap how many hops the engine will traverse — useful in deep graphs where unbounded expansion is too expensive.

```gql
SET ONTOLOGY TRANSITIVE DEPTH 5
```

The depth is the **maximum length of the real-edge chain** that produces an inferred edge. With `5`, source-to-target chains of 1–5 real edges yield an inferred edge; chains of 6 or more do not.

For a chain `A → B → C → D → E → F → G` (each `→` a real `TRANSITIVE` edge):

| Source | Inferred edge to | Real-chain length | Created? |
| -- | -- | -- | -- |
| A | B | 1 | ✓ (also the real edge) |
| A | C | 2 | ✓ |
| A | D | 3 | ✓ |
| A | E | 4 | ✓ |
| A | F | 5 | ✓ |
| A | G | 6 | ✗ |

The value must be a positive integer (`>= 1`), or the sentinel `-1` for unbounded expansion. `0` and any other negative value are rejected. The default when never set is `10`.

```gql
-- Unbounded expansion (no depth cap)
SET ONTOLOGY TRANSITIVE DEPTH -1
```

Use `-1` deliberately;1 unbounded expansion on a deep graph can be expensive.