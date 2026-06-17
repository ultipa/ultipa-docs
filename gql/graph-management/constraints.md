# Constraints

## Overview

**Constraints** enforce extra validation on node and edge properties in the graph. Any attempt to insert or update data that violates these rules will result in an error.

Ultipa supports the following constraint types:

| Constraint Type | Description | Composite of Properties | 
| -- | -- | -- |
| `NOT NULL` | Ensures a property never contains `null` values. | Not supported |
| `UNIQUE` | Ensures a property contains no duplicate values. | Supported |
| `KEY` | Combines `NOT NULL` and `UNIQUE`, marking a property as the identifying key of a node type. Available on **node types only**. | Supported |

When a constraint type supports a composite of properties, a row violates the constraint only when **all** listed properties match an existing row.

## Showing Constraints

Show constraints in the current graph:

```gql
SHOW CONSTRAINTS
SHOW NODE CONSTRAINTS
SHOW EDGE CONSTRAINTS
```

Filter by the label set a constraint targets with `ON`:

```gql
-- Only node constraints whose target label set is {Person}
SHOW CONSTRAINTS ON (:Person)

-- Only node constraints whose target label set is {A, B}
SHOW CONSTRAINTS ON (:A&B)

-- Only edge constraints whose target label set is {KNOWS}
SHOW CONSTRAINTS ON ()-[:KNOWS]->()
```

To inspect a single constraint by name:

```gql
DESCRIBE CONSTRAINT myConstraint

-- DESC is a shorthand for DESCRIBE
DESC CONSTRAINT myConstraint
```

Each constraint provides the following metadata:

| Field | Description |
| -- | -- |
| `name` | The user-supplied or auto-generated name.. |
| `type` | `node`, `edge`, or `wildcard`. |
| `matchers` | A list of `<labels>.<properties>` descriptors, one per OR alternative the constraint targets. <ul><li>Single property: `User.email`.</li><li>Composite tuple: `Person.(firstName, lastName)`.</li><li>Multi-label key set: `A&B.x`.</li><li>Wildcard target: `%.status`.</li><li>Label disjunction (`:A\|B`): one entry per alternative, e.g. `["User.email", "Actor.email"]`.</li></ul> |
| `constraint_type` | `NOT NULL`, `UNIQUE`, or `KEY`. |

## Creating Constraints

Creating a constraint on a non-empty graph scans existing data to verify compliance, and may take time on large graphs. The creation fails if any existing row violates the constraint.

Constraints can be created two ways:

### CREATE CONSTRAINT

```syntax
<create constraint statement> ::=
  "CREATE" { "CONSTRAINT" [ "IF NOT EXISTS" ] | "OR REPLACE CONSTRAINT" } [ <constraint name> ]
  "FOR" <constraint scope> "REQUIRE" <constraint requirement>

<constraint scope> ::= <node constraint scope> | <edge constraint scope>

<node constraint scope> ::= "(" <node variable declaration> <label set> ")"

<edge constraint scope> ::= "()-[" <edge variable declaration> <label set> "]->()"

<label set> ::=  
    ":" <label conjunction> [ { "|" <label conjunction> }... ]
  | ":%"

<label conjunction> ::= <label name> [ { "&" <label name> }... ]

<constraint requirement> ::= <property references> "IS" <constraint type>

<property references> ::=
    <property reference>
  | "(" <property reference> [ { "," <property reference> }... ] ")"

<property reference> ::= <node/edge variable> "." <property name>
```

**Details**

- The constraint name is optional. When omitted, the engine derives the name from `<labels>_<properties>_<type>`, e.g. `User_email_not_null`, `Person_firstName_lastName_unique`. The `IF NOT EXISTS` and `OR REPLACE` variants still require an explicit name as they identify the constraint by name.
- A constraint scope can be:
  - **Single label** (`:A`): applies to nodes/edges with that label.
  - **Conjunction** (`:A&B`): applies to nodes/edges whose contains every scope label. `{A, B}` and `{A, B, C}` both satisfy; `{A}` alone does not.
  - **Disjunction** (`:A|B`): applies to nodes/edges that have any of the alternatives. `A`, `B`, or both.
  - **Mixed** (`:A&B|C`): `&` binds tighter than `|`, so this parses as `(A&B) | C`.
  - **Wildcard** (`:%`): applies to every node or edge in the graph.

```gql
-- NOT NULL constraint on User nodes' name
CREATE CONSTRAINT nn_user_name FOR (n:User) REQUIRE n.name IS NOT NULL

-- UNIQUE constraint on KNOWS edges' eid
CREATE CONSTRAINT FOR ()-[e:KNOWS]->() REQUIRE e.eid IS UNIQUE

-- Composite UNIQUE constraint User nodes' firstName and lastName
CREATE CONSTRAINT FOR (n:User) REQUIRE (n.firstName, n.lastName) IS UNIQUE

-- KEY constraint on User nodes' uid
CREATE CONSTRAINT user_key FOR (n:User) REQUIRE n.uid IS KEY

-- Composite KEY constraint on Account nodes' tenantId and externalId 
CREATE CONSTRAINT account_key FOR (n:Account) REQUIRE (n.tenantId, n.externalId) IS KEY

-- Wildcard NOT NULL: every node must have a non-null createdAt
CREATE CONSTRAINT FOR (n:%) REQUIRE n.createdAt IS NOT NULL

-- Wildcard UNIQUE: every edge's eid must be unique
CREATE CONSTRAINT FOR ()-[r:%]->() REQUIRE r.eid IS UNIQUE

-- Conjunction: email is unique only on nodes that carry BOTH User and Employee labels
CREATE CONSTRAINT FOR (n:User&Employee) REQUIRE n.email IS UNIQUE

-- Disjunction: email is unique on every User node and every Actor node
CREATE CONSTRAINT FOR (n:User|Actor) REQUIRE n.email IS UNIQUE

-- Mixed: parses as (Employee&Manager) | (Contractor&Lead)
-- Enforces on nodes that are EITHER {Employee, Manager} OR {Contractor, Lead}
CREATE CONSTRAINT FOR (n:Employee&Manager|Contractor&Lead) REQUIRE n.badgeId IS UNIQUE
```

You can use the `IF NOT EXISTS` clause to prevent errors when attempting to create a constraint that already exists. It allows the statement to be safely executed.

```gql
CREATE CONSTRAINT IF NOT EXISTS KNOWS_eid_unique FOR ()-[e:KNOWS]->() REQUIRE e.eid IS UNIQUE
```

You can use `OR REPLACE` to drop an existing constraint with the same name and create a new one in its place:

```gql
CREATE OR REPLACE CONSTRAINT KNOWS_eid_unique FOR ()-[e:KNOWS]->() REQUIRE e.eid IS UNIQUE
```

### Inline in CREATE GRAPH or CREATE GRAPH TYPE

Inline declaration attaches constraint type keywords directly to a property in a node or edge type definition, alongside its data type. The constraint takes effect as soon as the graph or graph type is created.

Inline declarations are limited to **single-property** constraints. For composite constraint, use the `CREATE CONSTRAINT` statement instead.

Inline constraints get the same auto-generated name as a nameless `CREATE CONSTRAINT FOR …`. For example, `NODE User ({uid STRING KEY})` registers a constraint named `User_uid_key`. A property declared `NOT NULL UNIQUE` (without `KEY`) registers two separate constraints: `<Label>_<prop>_not_null` and `<Label>_<prop>_unique`.

Inline form in `CREATE GRAPH`:

```gql
CREATE GRAPH myGraph {
  NODE User ({uid STRING KEY, name STRING NOT NULL UNIQUE, age UINT32}),
  EDGE KNOWS ()-[{createdOn TIMESTAMP NOT NULL, eid STRING}]->()
}
```

Inline form in `CREATE GRAPH TYPE`:

```gql
CREATE GRAPH TYPE gType {
  NODE User ({uid STRING KEY, name STRING NOT NULL UNIQUE, age UINT32}),
  EDGE KNOWS ()-[{createdOn TIMESTAMP NOT NULL, eid STRING}]->()
}
```

When applied to the same property, constraint type keywords can be written in either order. For example, `NOT NULL UNIQUE` and `UNIQUE NOT NULL` are equivalent.

## Dropping Constraints

Drop a constraint by its name:

```gql
DROP CONSTRAINT nn_user_name
```

The `IF EXISTS` clause is used to prevent errors when attempting to delete a constraint that does not exist. It allows the statement to be safely executed.

```gql
DROP CONSTRAINT IF EXISTS nn_user_name
```
