# Constraints

## Overview

**Constraints** enforce rules on the property values of nodes and edges in the graph. Any attempt to insert or update data that violates these rules will result in an error.

The following constraints are supported:

- <a href="#NOT-NULL">NOT NULL</a>
- <a href="#EDGE-KEY">EDGE KEY</a>

## Showing Constraints

To retrieve information about constraints created in the current graph:

```uql
// Shows all constraints
show().constraint()

// Shows all constraints created on node properties
show().node_constraint()

// Shows all constraints created on edge properties
show().edge_constraint()
```

The information about constraints is organized into the `_nodeConstraint` or `_edgeConstraint` table. Each table includes fields that provide essential details about each constraint:

| <div table-width="13">Field</div> | Description |
| -- | -- |
| `name` | Constraint name. |
| `type` | Constraint type. |
| `schema` | The node or edge schemas where the constraint applies. |
| `properties` | The node or edge properties where the constraint applies. |
| `status` | Constraint status, which can be `DONE` or `CREATING`. |

## Creating Constraints

A constraint is created with the `CREATE CONSTRAINT` statement. Constraint creation is executed as a job; you may then run `show().job()` to verify its success.

Note that creating a constraint in a large, active graph may take time, as the system must scan all existing data to ensure compliance. The creation will fail if any existing data violates the constraint. To maintain data consistency, all other data modification operations are temporarily suspended during the constraint creation process.

### NOT NULL

The `NOT NULL` constraint enforces that a property **cannot have `null` values**, guaranteeing that a value is always provided.

**Details**

- A `NOT NULL` constraint must be created for a single specified schema.
- Only one property can be designated per `NOT NULL` constraint.

To create a `NOT NULL` constraint named `nn_1` on the property `name` of the `user` nodes:

```uql
CREATE CONSTRAINT nn_1
FOR (u:user) REQUIRE u.name IS NOT NULL
```

To create a `NOT NULL` constraint named `nn_2` on the property `weight` of the `link` edges:

```uql
CREATE CONSTRAINT nn_2
FOR ()-[e:link]-() REQUIRE e.weight IS NOT NULL
```

These constraints can only be successfully created  when no `null` values exist in the specified property.

### EDGE KEY

An `EDGE KEY` constraint designates one or multiple edge properties as the unique identifier for all edges in the graph, ensuring that these properties are both non-`null` and unique. When multiple properties are specified, it is also referred to as a composite `EDGE KEY`.

**Details**

- Only one `EDGE KEY` can be defined per graph - either a single-property `EDGE KEY` or a composite `EDGE KEY`.
- `EDGE KEY` doesn't apply to properties of the type `list`.
- `EDGE KEY` properties are automatically cached to accelerate query performance.
- When the `EDGE KEY` is created, uniqueness is enforced within each shard. Duplicates may exist across shards at creation time, but all subsequent data modifications must comply with global uniqueness.

#### Single-Property EDGE KEY

To create a single-property `EDGE KEY` constraint named `eUID`:

```uql
CREATE CONSTRAINT eUID
FOR ()-[e]-() REQUIRE e.createdOn IS EDGE KEY
OPTIONS {
  type: {createdOn: "datetime"}
}
```

To successfully create the `EDGE KEY`:

- All edge schemas in the graph must possess an `createdOn` property of type `datetime`.
- `createdOn` doesn't contain existing `null` or duplicated values.

When the property value type is not specified, it defaults to `string`:

```uql
CREATE CONSTRAINT eUID
FOR ()-[e]-() REQUIRE e.createdOn IS EDGE KEY
```

In this case, all edge schemas must have a `createdOn` property of type `string`.

#### Composite EDGE KEY

To create a composite `EDGE KEY` constraint named `eUIDs`:

```uql
CREATE CONSTRAINT eUIDs
FOR ()-[e]-() REQUIRE (e.createdOn, e.weight) IS EDGE KEY
OPTIONS {
  type: {createdOn: "datetime", weight: "float"}
}
```

To successfully create the `EDGE KEY`:

- All edge schemas in the graph must possess an `createdOn` property of type `datetime` and a `weight` property of type `float`.
- Neither `createdOn` nor `weight` may contain existing `null` values.
- The combination of `createdOn` and `weight` must not contain any duplicated values.

### Using IF NOT EXISTS

Constraint names in a graph must be unique. If you attempt to create a constraint with a name that already exists, the creation will fail, and an error message will indicate the duplication.

If the `IF NOT EXISTS` flag is used, the job completes with a `FINISHED` status when a duplicate name is detected. No error message will be returned, and no new constraint is created.

To create a `NOT NULL` constraint named `nn_1`. If the constraint name already exists, skip the creation without returning an error message:

```uql
CREATE CONSTRAINT nn_1
FOR (u:user) REQUIRE u.age IS NOT NULL
```

### Naming Conventions

Constraint name must:

- Contain 2 to 64 characters.
- Begin with a letter.
- Allowed characters: letters (A-Z, a-z), numbers (0-9) and underscores (`_`).

Constraint names must be unique.

## Dropping Constraints

A constraint can be dropped with the `DROP CONSTRAINT` statement.

To drop a constraint named `nn_1`:

```uql
DROP CONSTRAINT nn_1
```

### Using IF EXISTS

If the specified constraint name does not exist, deleting the constraint fails and returns an error message.

With the `IF EXISTS` flag, no error message will be returned when the specified constraint name is not found, and no constraint is deleted.

To drop a constraint named `nn`. If the constraint name does not exist, skip the deletion without returning an error message:

```uql
DROP CONSTRAINT nn_1 IF EXISTS
```

## Restrictions on Properties with Constraints

### Renaming Properties

Properties with the `NOT NULL` constraints can be renamed. However, renaming properties with an `EDGE KEY` constraint is not allowed.

### Dropping Properties

A property with a constraint cannot be dropped until all the related constraints are deleted.
