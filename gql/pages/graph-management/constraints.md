# Constraints

## Overview

**Constraints** enforce additional rules on the node and edge properties in the graph. Any attempt to insert or update data that violates these rules will result in an error.

Ultipa supports the following constraint types:

| Constraint Type | Description | Composite of Properties | 
| -- | -- | -- |
| `NOT NULL` | Ensures that a property never contains `null` values. | Not supported |
| `UNIQUE` | Ensures that a property contains no duplicate values. | Supported |
| `KEY` | Combines `NOT NULL` and `UNIQUE`, marking a property as the identifying key of a node type. Available on **node types only**. | Supported |

When a constraint type supports a composite of properties, a row violates the constraint only when **all** listed properties match an existing row.

## Showing Constraints

Show constraints in the current graph:

```gql
SHOW CONSTRAINTS
SHOW NODE CONSTRAINTS
SHOW EDGE CONSTRAINTS
```

To inspect a single constraint:

```gql
DESCRIBE CONSTRAINT myConstraint

-- DESC is a shorthand for DESCRIBE
DESC CONSTRAINT myConstraint
```

Each constraint provides the following metadata:

| Field | Description |
| -- | -- |
| `entity_type` | `NODE` or `EDGE`. |
| `type` | The node or edge type where the constraint applies. |
| `property` | The property where the constraint applies. For composite constraints, properties are comma-separated. |
| `constraint_type` | Constraint type. |
| `constraint_name` | The user-supplied name of the constraint. |

## Creating Constraints

Creating a constraint on a non-empty graph scans existing data to verify compliance, and may take time on large graphs. The creation fails if any existing row violates the constraint.

Constraints can be created two ways:

### CREATE CONSTRAINT

```syntax
<create constraint statement> ::=
  "CREATE" { "CONSTRAINT" [ "IF NOT EXISTS" ] | "OR REPLACE CONSTRAINT" } <constraint name> 
  "FOR" { <constraint node pattern> | <constraint edge pattern> } "REQUIRE" <constraint requirement>

<constraint node pattern> ::= "(" <node variable declaration> [ <label set> ] ")"

<constraint edge pattern> ::= "()-[" <edge variable declaration> [ <label set> ] "]->()"

<label set> ::= < ":" | "IS" > <label name> [ { "&" <label name> }... ]

<constraint requirement> ::= <key value components> "IS" <constraint type>

<key value components> ::=
    <key value component>
  | "(" <key value component> [ { "," <key value component> }... ] ")"

<key value component> ::= <node/edge variable> "." <property name>
```

**Details**

- A constraint can be scoped to a label set — one or more labels joined by `&`.

```gql
-- NOT NULL constraint nn_user_name on the property name of User nodes
CREATE CONSTRAINT nn_user_name FOR (n:User) REQUIRE n.name IS NOT NULL

-- UNQIUE constraint nn_knows_eid on the property eid of KNOWS edges
CREATE CONSTRAINT nn_knows_eid FOR ()-[e:KNOWS]->() REQUIRE e.eid IS UNIQUE

-- Composite UNIQUE constraint uq_user_name on properties firstName and lastName of User nodes
CREATE CONSTRAINT uq_user_name FOR (n:User) REQUIRE (n.firstName, n.lastName) IS UNIQUE

-- KEY constraint user_key on the property uid of User nodes
CREATE CONSTRAINT user_key FOR (n:User) REQUIRE n.uid IS KEY
```

You can use the `IF NOT EXISTS` clause to prevent errors when attempting to create a constraint that already exists. It allows the statement to be safely executed.

```gql
CREATE CONSTRAINT IF NOT EXISTS nn_knows_eid FOR ()-[e:KNOWS]->() REQUIRE e.eid IS UNIQUE 
```

You can use `OR REPLACE` to drop an existing constraint with the same name and create a new one in its place:

```gql
CREATE OR REPLACE CONSTRAINT nn_knows_eid FOR ()-[e:KNOWS]->() REQUIRE e.eid IS UNIQUE 
```

### Inline in CREATE GRAPH or CREATE GRAPH TYPE

Inline declaration attaches constraint type keywords directly to a property in a node or edge type definition, alongside its data type. The constraint takes effect as soon as the graph or graph type is created.

Inline declarations are limited to **single-property** constraints. For composite constraint, use the `CREATE CONSTRAINT` statement instead.

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
