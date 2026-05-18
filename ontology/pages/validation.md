# Validation & Enforcement

## Overview

Control how strictly ontology rules are enforced and validate data against ontology constraints.

## Enforcement Modes

Control how strictly ontology rules are enforced with three modes:

| Mode | Behavior |
| -- | -- |
| `STRICT` | Violations cause errors and block operations |
| `WARNING` (default) | Violations are logged but operations proceed |
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

### Strict Mode

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

### Warning Mode

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

## Bulk Import Workflow

For large data imports, disable enforcement during import and validate afterward for better performance.

```gql
-- Disable enforcement for bulk import
SET ONTOLOGY ENFORCEMENT OFF

-- Perform bulk import operations
INSERT (@ex:Person {name: 'Alice'})
INSERT (@ex:Person {name: 'Bob'})
INSERT (@ex:Organization {name: 'Acme'})
// thousands more inserts ...

-- Re-enable enforcement
SET ONTOLOGY ENFORCEMENT WARNING

-- Validate the imported data
VALIDATE ONTOLOGY
```

## Validating Ontology

`VALIDATE ONTOLOGY` returns a one-row snapshot of the current ontology and the count of accumulated warnings. It does **not** rescan data — to find individual violations, look at `SHOW ONTOLOGY WARNINGS` (populated as INSERTs run under `WARNING` mode).

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

| Type | Description |
| -- | -- |
| `CLASS_NOT_FOUND` | Node has an ontology label for an undefined class |
| `DOMAIN_MISMATCH` | Edge source doesn't match the property's `DOMAIN` |
| `RANGE_MISMATCH` | Edge target doesn't match the property's `RANGE` |
| `DISJOINT_VIOLATION` | Node has labels from two `DISJOINT WITH` classes |
| `FUNCTIONAL_VIOLATION` | Multiple outgoing edges for a `FUNCTIONAL` (or `CARDINALITY {0,1}`) property |
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

When using WARNING mode, violations are stored in a warnings log that you can query.

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

The value must be a positive integer (`>= 1`); `0` or negative values are rejected. The default when never set is `10`. There is no "unlimited" sentinel — to allow deeper chains, set a larger explicit value.