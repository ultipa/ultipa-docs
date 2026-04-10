# Constraints

## Overview

**Constraints** enforce additional rules on the node and edge properties in the graph. Any attempt to insert or update data that violates these rules will result in an error.

Ultipa supports the following constraints in **closed graphs**:

- <a href="#NOT-NULL">NOT NULL</a>: Ensures that a property never contains `null` values.
- <a href="#UNIQUE">UNIQUE</a>: Ensures that a property contains no duplicate values.

## Showing Constraints

Show all constraints in the current graph:

```gql
SHOW CONSTRAINTS
```

Show node constraints in the current graph:

```gql
SHOW NODE CONSTRAINTS
```

Show edge constraints in the current graph:

```gql
SHOW EDGE CONSTRAINTS
```

Each constraint provides the following metadata:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `entity_type` | `NODE` or `EDGE`. |
| `type` | The node or edge type where the constraint applies. |
| `property` | The property where the constraint applies. |
| `constraint_type` | Constraint type (`NOT NULL`, `UNIQUE`). |

## Creating Constraints

You can define constraints when **creating a closed graph**, **creating a graph type**, or **within an existing closed graph**.

Note that creating a constraint in a large graph may take time, as the system must scan all existing data to ensure compliance. The creation will fail if any existing data violates the constraint.

### NOT NULL

The `NOT NULL` constraint ensures that a property never contains `null` values.

Create a `NOT NULL` constraint on the property `name` of node type `User`:

```gql
ALTER NODE User ADD CONSTRAINT NOT NULL ON name
```

Create a `NOT NULL` constraint on the property `createdOn` of edge type `KNOWS`:

```gql
ALTER EDGE KNOWS ADD CONSTRAINT NOT NULL ON createdOn
```

The `NOT NULL` constraint can only be successfully created when no `null` values exist in the specified property.

You can apply the `NOT NULL` constraint to any property when creating a closed graph:

```gql
CREATE GRAPH myGraph {
  NODE User ({name STRING NOT NULL, age UINT32}),
  EDGE KNOWS ()-[{createdOn TIMESTAMP NOT NULL, eid STRING}]->()
}
```

You can also apply the `NOT NULL` constraint to any property when creating a graph type:

```gql
CREATE GRAPH TYPE gType {
  NODE User ({name STRING NOT NULL, age UINT32}),
  EDGE KNOWS ()-[{createdOn TIMESTAMP NOT NULL, eid STRING}]->()
}
```

### UNIQUE

The `UNIQUE` constraint ensures that a property contains no duplicate values.

Create a `UNIQUE` constraint on the property `name` of node type `User`:

```gql
ALTER NODE User ADD CONSTRAINT UNIQUE ON name
```

Create a `UNIQUE` constraint on the property `eid` of edge type `KNOWS`:

```gql
ALTER EDGE KNOWS ADD CONSTRAINT UNIQUE ON eid
```

The `UNIQUE` constraint can only be successfully created when no duplicate values exist in the specified property.

You can apply the `UNIQUE` constraint to any property when creating a closed graph:

```gql
CREATE GRAPH myGraph {
  NODE User ({name STRING UNIQUE, age UINT32}),
  EDGE KNOWS ()-[{createdOn TIMESTAMP, eid STRING UNIQUE}]->()
}
```

You can also apply the `UNIQUE` constraint to any property when creating a graph type:

```gql
CREATE GRAPH TYPE gType {
  NODE User ({name STRING UNIQUE, age UINT32}),
  EDGE KNOWS ()-[{createdOn TIMESTAMP, eid STRING UNIQUE}]->()
}
```

## Dropping Constraints

Drop the `NOT NULL` constraint on the `name` property of node type `User` from the current graph:

```gql
ALTER NODE User DROP CONSTRAINT NOT NULL ON name
```

Drop the `UNIQUE` constraint on the `eid` property of edge type `KNOWS` from the current graph:

```gql
ALTER EDGE KNOWS DROP CONSTRAINT UNIQUE ON eid
```