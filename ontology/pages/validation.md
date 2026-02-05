# Validation & Enforcement

## Overview

Control how strictly ontology rules are enforced and validate data against ontology constraints.

## Enforcement Modes

Control how strictly ontology rules are enforced with three modes:

| Mode | Behavior |
| -- | -- |
| **STRICT** | Violations cause errors and block operations |
| **WARNING** | Violations are logged but operations proceed |
| **OFF** | No validation (useful for bulk imports) |

| Command | Description |
| -- | -- |
| `SET ONTOLOGY ENFORCEMENT STRICT \| WARNING \| OFF` | Set the enforcement mode |
| `SHOW ONTOLOGY ENFORCEMENT` | View current enforcement mode |

Enable strict enforcement:

```gql
SET ONTOLOGY ENFORCEMENT STRICT
```

Enable warning mode:

```gql
SET ONTOLOGY ENFORCEMENT WARNING
```

Disable enforcement:

```gql
SET ONTOLOGY ENFORCEMENT OFF
```

Check current enforcement mode:

```gql
SHOW ONTOLOGY ENFORCEMENT
```

| enforcement_mode |
| -- |
| STRICT |

## Strict Mode

In STRICT mode, any ontology constraint violation will cause an error and block the operation. Use this in production to ensure data quality.

Setup domain/range constraints:

```gql
CREATE OBJECT PROPERTY @ex:worksFor DOMAIN @ex:Person RANGE @ex:Organization

SET ONTOLOGY ENFORCEMENT STRICT

// This succeeds: Person -> Organization
INSERT (:@ex:Person {name: 'Alice'})-[:@ex:worksFor]->(:@ex:Organization {name: 'Acme'})
```

Invalid data is rejected:

```gql
// This fails in STRICT mode: Organization -> Organization violates DOMAIN
INSERT (:@ex:Organization {name: 'Org1'})-[:@ex:worksFor]->(:@ex:Organization {name: 'Org2'})
// Error: Domain constraint violation - source must be @ex:Person
```

Disjoint class violation:

```gql
CREATE CLASS @ex:Cat
CREATE CLASS @ex:Dog DISJOINT WITH @ex:Cat

INSERT (:@ex:Cat&@ex:Dog {name: 'Mystery'})
// Error: Disjoint class violation - cannot be both Cat and Dog
```

Functional property violation:

```gql
CREATE OBJECT PROPERTY @ex:hasBirthPlace FUNCTIONAL

// First birthPlace assignment succeeds
INSERT (:@ex:Person {name: 'Alice'})-[:@ex:hasBirthPlace]->(:@ex:Location {name: 'Paris'})

// Second birthPlace fails - functional constraint violation
MATCH (a@ex:Person) WHERE a.name = 'Alice'
INSERT (a)-[:@ex:hasBirthPlace]->(:@ex:Location {name: 'London'})
// Error: Functional property violation - Alice already has a birthPlace
```

## Warning Mode

In WARNING mode, constraint violations are logged but operations proceed. Use this during migration or development to identify issues without blocking work.

```gql
SET ONTOLOGY ENFORCEMENT WARNING

// This succeeds but logs a warning
INSERT (:@ex:Organization {name: 'Org1'})-[:@ex:worksFor]->(:@ex:Organization {name: 'Org2'})
// Warning logged: Domain constraint violation - source should be @ex:Person
```

View warnings after operations:

```gql
SHOW ONTOLOGY WARNINGS
```

| timestamp | type | message |
| -- | -- | -- |
| 2024-03-15T10:30:00 | DOMAIN_MISMATCH | worksFor: source should be Person, got Organization |

## Bulk Import Workflow

For large data imports, disable enforcement during import and validate afterward for better performance.

```gql
// Disable enforcement for bulk import
SET ONTOLOGY ENFORCEMENT OFF

// Perform bulk import operations
INSERT (:@ex:Person {name: 'Alice'})
INSERT (:@ex:Person {name: 'Bob'})
INSERT (:@ex:Organization {name: 'Acme'})
// ... thousands more inserts ...

// Re-enable enforcement
SET ONTOLOGY ENFORCEMENT WARNING

// Validate the imported data
VALIDATE ONTOLOGY
```

## VALIDATE Command

Run validation to check existing data against ontology constraints.

```gql
VALIDATE ONTOLOGY
```

Validation returns any constraint violations found:

| type | element | constraint | message |
| -- | -- | -- | -- |
| DOMAIN_MISMATCH | edge:456 | worksFor | Source must be Person |
| RANGE_MISMATCH | edge:789 | worksFor | Target must be Organization |

## Viewing Warnings

When using WARNING mode, violations are stored in a warnings log that you can query.

```gql
SHOW ONTOLOGY WARNINGS
```

| timestamp | type | element | message |
| -- | -- | -- | -- |
| 2024-03-15T10:30:00 | DOMAIN_MISMATCH | edge:123 | worksFor: source should be Person |
| 2024-03-15T10:35:00 | CLASS_NOT_FOUND | node:456 | Unknown class: @ex:Unknown |

## Validation Types

The ontology validator checks for several types of constraint violations:

| Type | Description |
| -- | -- |
| **CLASS_NOT_FOUND** | Node has ontology label for undefined class |
| **DOMAIN_MISMATCH** | Edge source doesn't match property domain |
| **RANGE_MISMATCH** | Edge target doesn't match property range |
| **DISJOINT_VIOLATION** | Node has labels from disjoint classes |
| **FUNCTIONAL_VIOLATION** | Multiple edges for functional property |
| **TYPE_MISMATCH** | Data property value doesn't match XSD type |

Domain violation example:

```gql
CREATE OBJECT PROPERTY @ex:employs DOMAIN @ex:Organization RANGE @ex:Person

// Wrong: Person cannot employ (domain is Organization)
INSERT (:@ex:Person {name: 'Alice'})-[:@ex:employs]->(:@ex:Person {name: 'Bob'})
// DOMAIN_MISMATCH: source must be @ex:Organization
```

Range violation example:

```gql
// Wrong: Organization cannot be employed (range is Person)
INSERT (:@ex:Organization {name: 'Acme'})-[:@ex:employs]->(:@ex:Organization {name: 'Other'})
// RANGE_MISMATCH: target must be @ex:Person
```
