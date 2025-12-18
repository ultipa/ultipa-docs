# Constraints

## Overview

**Constraints** enforce additional rules on the node and edge properties in the graph. Any attempt to insert or update data that violates these rules will result in an error.

Ultipa supports the following constraints in **typed graphs**:

- <a href="#NOT-NULL">NOT NULL</a>: Ensures that a property never contains `null` values.
- <a href="#UNIQUE">UNIQUE</a>: Ensures that a property contains no duplicate values.
- <a href="#EDGE-KEY">EDGE KEY</a>: Specifies a property as the unique identifier for all edges in the graph.

## Showing Constraints

To show node constraints in the current graph:

```gql
SHOW NODE CONSTRAINT
```

To show edge constraints in the current graph:

```gql
SHOW EDGE CONSTRAINT
```

The plural form `SHOW NODE|EDGE CONSTRAINTS` is also supported.

Each constraint provides the following essential metadata:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `name` | Constraint name. |
| `type` | Constraint type. |
| `schema` | The node or edge schemas where the constraint applies. |
| `properties` | The node or edge properties where the constraint applies. |
| `status` | Constraint status, which can be `DONE` or `CREATING`. |

## Creating Constraints

You can define constraints when **creating a graph**, **creating a graph type**, or **within an existing graph**. When creating constraints in an existing graph, it execute as a job, you may run `SHOW JOB <id?>` afterward to verify its success.

Note that creating a constraint in a large graph may take time, as the system must scan all existing data to ensure compliance. The creation will fail if any existing data violates the constraint. To maintain data consistency, all other data modification operations are temporarily suspended during the constraint creation process.

### NOT NULL

The `NOT NULL` constraint ensures that a property never contains null values.

To create a `NOT NULL` constraint on the property `name` of the `User` nodes:

```gql
ALTER NODE User ADD CONSTRAINT NOT NULL ON name
```

To create a `NOT NULL` constraint on the property `weight` of the `link` edges:

```gql
ALTER EDGE link ADD CONSTRAINT NOT NULL ON weight
```

The `NOT NULL` constraint can only be successfully created when there is no `null` values exist in the specified property.

You can apply the `NOT NULL` constraint to any property when creating a typed graph:

```gql
CREATE GRAPH g1 { 
  NODE User ({name STRING NOT NULL, age UINT32}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME NOT NULL}]->()
}
```

You can also apply the `NOT NULL` constraint to any property when creating a graph type:

```gql
CREATE GRAPH TYPE gType { 
  NODE User ({name STRING NOT NULL, age UINT32}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME NOT NULL}]->()
}
```

### UNIQUE

The `UNIQUE` constraint ensures that a property contains no duplicate values. A `UNIQUE` constraint can be defined on either a single property or multiple properties.

#### Single-Property UNIQUE

To create a `UNIQUE` constraint on the property `name` of the `User` nodes:

```gql
ALTER NODE User ADD CONSTRAINT UNIQUE ON name
```

To create a `UNIQUE` constraint on the property `weight` of the `link` edges:

```gql
ALTER EDGE link ADD CONSTRAINT UNIQUE ON weight
```

The `UNIQUE` constraint can only be successfully created when there is no duplicated values exist in the specified property.

#### Composite UNIQUE

To create a composite `UNIQUE` constraint on the properties `name` and `uid` of the `User` nodes:

```gql
ALTER NODE User ADD CONSTRAINT UNIQUE ON name, uid
```

To create a composite `UNIQUE` constraint on the properties `weight` and `eid` of the `link` edges:

```gql
ALTER EDGE link ADD CONSTRAINT UNIQUE ON weight, eid
```

The `UNIQUE` constraint can be created successfully only when the combined values of all specified properties contain no duplicates.

#### UNIQUE During Graph Creation

You can apply the `UNIQUE` constraint to any property when creating a typed graph:

```gql
CREATE GRAPH g1 { 
  NODE User ({name STRING UNIQUE, age UINT32}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME UNIQUE}]->()
}
```

#### UNIQUE During Graph Type Creation

You can also apply the `UNIQUE` constraint to any property when creating a graph type:

```gql
CREATE GRAPH TYPE gType { 
  NODE User ({name STRING UNIQUE, age UINT32}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME UNIQUE}]->()
}
```

### EDGE KEY

The `EDGE KEY` constraint specifies a property as the unique identifier for all edges in the graph, ensuring that its values are both non-`null` and unique. An `EDGE KEY` constraint can be defined on either a single property or multiple properties.

**Details**

- Only one `EDGE KEY` constraint can be defined per graph, either a single-property `EDGE KEY` or a composite `EDGE KEY`.
- `EDGE KEY` doesn't apply to properties of the type `LIST`.
- `EDGE KEY` properties are automatically cached to accelerate query performance.
- When the `EDGE KEY` is created, uniqueness is enforced within each shard. Duplicates may exist across shards at creation time, but all subsequent data modifications must comply with global uniqueness.

#### Single-Property EDGE KEY

To specify the edge property `eID` as `EDGE KEY`:

```gql
ALTER EDGE * ADD CONSTRAINT EDGE KEY ON eID INT32
```

To successfully create the `EDGE KEY`:

- All edges must possess an `eID` property of type `INT32`.
- The `eID` property doesn’t contain existing `null` or duplicated values.

When the property value type is not specified, it defaults to `STRING`:

```gql
ALTER EDGE * ADD CONSTRAINT EDGE KEY ON tag
```

In this case, all edges must have a `tag` property of type `STRING`.

#### Composite EDGE KEY

To specify the edge properties `eID` and `tag` as `EDGE KEY`:

```gql
ALTER EDGE * ADD CONSTRAINT EDGE KEY ON eID INT32, tag STRING
```

To successfully create the `EDGE KEY`:

- All edges must possess an `eID` property of type `INT32` and a `tag` property of type `STRING`.
- Neither the property `eID` nor `tag` may contain existing `null` values.
- The combination of the values of `eID` and `tag` must not contain any duplicated values.

#### EDGE KEY During Graph Creation

You can apply the `EDGE KEY` constraint when creating a typed graph:

```gql
CREATE GRAPH g1 { 
  NODE User ({name STRING , age UINT32}),
  NODE Club ({name STRING}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME}]->(),
  EDGE Joins ()-[]->()
}
EDGE KEY eID INT64, tag STRING
```

The specified `EDGE KEY` properties `eID` and `tag` will be automatically created for all edge schemas.

#### EDGE KEY During Graph Type Creation

You can apply the `EDGE KEY` constraint when creating a graph type:

```gql
CREATE GRAPH TYPE gType { 
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME}]->(),
  EDGE Joins ()-[]->()
}
EDGE KEY eID INT64
```

The specified `EDGE KEY` property `eID` will be automatically created for all edge schemas when this graph type is used.

### Using IF NOT EXISTS

The `IF NOT EXISTS` clause is used to prevent errors when attempting to create a constraint that already exists. It allows the statement to be safely executed.

```gql
ALTER NODE User ADD CONSTRAINT IF NOT EXISTS NOT NULL ON name
```

This creates the constraint only if there is no existing `NOT NULL` constraint on the `name` property of `User` nodes. If such a constraint already exists, the statement is ignored without throwing an error.

### Naming Convetions

Constraint names must be unique. Each constraint name must:

- Contain 2 to 64 characters.
- Begin with a letter.
- Allowed characters: letters (A-Z, a-z), numbers (0-9) and underscores (<code>_</code>).

## Dropping Constraints

To drop the `NOT NULL` constraint on the `name` property of `User` nodes from the current graph:

```gql
ALTER NODE User DROP CONSTRAINT NOT NULL ON name
```

To drop the `UNIQUE` constraint on the `name` property of `User` nodes from the current graph:

```gql
ALTER NODE User DROP CONSTRAINT UNIQUE ON name
```

To drop the `EDGE KEY` constraint from the current graph:

```gql
ALTER EDGE * DROP EDGE KEY
```

## Restrictions on Properties with Constraints

### Renaming Properties

Properties with the `NOT NULL` or `UNIQUE` constraints can be renamed. However, renaming properties with an `EDGE KEY` constraint is not allowed.

### Dropping Properties

A property with a constraint cannot be dropped until all the related constraints are deleted.