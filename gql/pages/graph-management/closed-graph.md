# Closed Graph

## Overview

The **closed graph** is constrained by its **graph type** (or schema), which imposes a strict framework that governs data insertion: nodes and edges with schemas or properties not defined cannot be added. While the graph type can be altered after a graph is created, its defined data model ensures consistent structure, guaranteeing high data integrity and consistency.

In a closed graph,

- Each node or edge belongs to exactly one schema.
- Each schema is associated with a set of properties; each property is defined with a specific <a target="_blank" href="/docs/gql/values-and-types#Property-Value-Types">value type</a>.

For closed graphs, node and edge schemas, along with their properties, must be explicitly defined.  This definition can occur either during graph creation or later, and can be easily altered as necessary throughout the graph's lifecycle.

## Creating Closed Graph

### Empty Graph Type

To create a graph `g1` with an empty graph type:

```gql
CREATE GRAPH g1
```

The graph `g1` is created as a closed graph, containing only the built-in `default` node schema and `default` edge schema.

### Customized Graph Type

To create a graph `g2` with a graph type specification, which defines:

- Node schema `User` with properties `name` (`STRING` type) and `age` (`UINT32` type).
- Node schema `Club` with a property `name` (`STRING` type).
- Edge schema `Follows` with a property `createdOn` (`LOCAL DATETIME` type).
- Edge schema `Joins` with no properties.
  
```gql
CREATE GRAPH g2 { 
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME}]->(),
  EDGE Joins ()-[]->()
}
```

### Defined Graph Type

To create a graph `g3` based on the defined graph type named `gType` (<a href="#Managing-Graph-Types">How to manage graph types</a>), you have three equivalent GQL options to specify the graph type to be used:

```gql
CREATE GRAPH g3 gType
```

or
  
```gql
CREATE GRAPH g3 :: gType
```

or 

```gql
CREATE GRAPH g3 TYPED gType
```

The graph `g3` is created with all the schemas and properties defined within the graph type `gType`.

### Graph Type of Another Graph

To create a graph `g4` by copying the graph type of an existing graph `trans`:
  
```gql
CREATE GRAPH g4 LIKE trans
```

The `LIKE` keyword specifies the graph whose graph type is to be copied. The graph `g4` is created with the same schemas and properties defined within the graph `trans`.

## Managing Graph Types

The graph type defines structural rules for graphs by outlining the allowed node and edge schemas, and their associated properties. You can define and store graph types in the database, making them reusable when creating new graphs.

### Showing Graph Types

To show graph types defined in the database:

```gql
SHOW GRAPH TYPE
```

Each graph type provides the following essential metadata:

| <div table-width="15">Field</div> | Description |
| -- | -- |
| `name` | The unique name assigned to the graph type. |
| `gql` | The GQL query used to create the graph type. |

### Creating Graph Type

To create a graph type `gType`:
  
```gql
CREATE GRAPH TYPE gType { 
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME}]->(),
  EDGE Joins ()-[]->()
}
```

### Dropping Graph Type

To drop the graph type `gType`:

```gql
DROP GRAPH TYPE gType
```

The `IF EXISTS` clause is used to prevent errors when attempting to delete a graph type that does not exist. It allows the statement to be safely executed.

```gql
DROP GRAPH TYPE IF EXISTS gType
```

This deletes the graph type `gType` only if a graph type with that name does exist. If `gType` does not exist, the statement is ignored without throwing an error.

## Encrypting Properties

When creating a closed graph or a graph type, you can configure any property to be encrypted using one of the supported encryption methods: `AES128`, `AES256`, `RSA` and `ECC`.

To create a graph `g5`, encrypting the `name` property of the node schema `User`:

```gql
CREATE GRAPH g5 { 
  NODE User ({name STRING encrypt("AES128"), age UINT32}),
  NODE Club ({name STRING}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME}]->(),
  EDGE Joins ()-[]->()
}
```

To create a graph type `gType_1`, encrypting the `name` property of the node schema `User`:

```gql
CREATE GRAPH TYPE gType_1 { 
  NODE User ({name STRING encrypt("AES128"), age UINT32}),
  NODE Club ({name STRING}),
  EDGE Follows ()-[{createdOn LOCAL DATETIME}]->(),
  EDGE Joins ()-[]->()
}
```

## Showing Schemas and Properties

To show node schemas defined in the current graph:

```gql
SHOW NODE SCHEMA
```

To show edge schemas defined in the current graph:

```gql
SHOW EDGE SCHEMA
```

To show properties associated with the node schema `User` in the current graph:

```gql
SHOW NODE User PROPERTY
```

To show properties associated with the edge schema `Joins` in the current graph:

```gql
SHOW EDGE Joins PROPERTY
```

Each schema provides the following essential metadata:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `id` | The ID of the schema. |
| `name` | The name assigned to the schema. |
| `description` | The comment given to the schema. |
| `status` | The state of the schema, which can only be `CREATED`. |
| `properties` | The associated properties of the schema. |

Each property provides the following essential metadata:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `name` | The property name. |
| `type` | The property value type. |
| `lte` | Whether the property is loaded to the shards' memory for query acceleration. |
| `read` | Whether the current database user can read the property. `1` for true, `0` for false. |
| `write` | Whether the current database user can write the property. `1` for true, `0` for false. |
| `schema` | The schema that the property is associated with. |
| `description` | The comment given to the property. |
| `encrypt` | The encryption method used for the property. |

## Adding Schemas and Properties

You can add new schemas and properties within a closed graph.

To add node schemas `User` and `Club` within the graph `g1`: 

```gql
ALTER GRAPH g1 ADD NODE {
  User ({username STRING, gender STRING}),
  Club ({name STRING, score FLOAT})
}
```

To add an edge schema `Follows` within the graph `g1`: 

```gql
ALTER GRAPH g1 ADD EDGE {
  Follows ()-[{createdOn DATE}]->()
}
```
 
To add a property `tags` to the node schema `User` within the current graph:

```gql
ALTER NODE user ADD PROPERTY {tags LIST<STRING>}
```

To add properties `distance` and `weight` to the edge schema `links` within the current graph:

```gql
ALTER EDGE links ADD PROPERTY {
  distance FLOAT, 
  weight DECIMAL(10,5)
}
```

You can add properties to all node or edge schemas. For example, to add a property `when` to all edge schemas within the current graph:

```gql
ALTER EDGE * ADD PROPERTY {when DATE}
```

## Altering Schemas

You can alter the name and comment of a schema in the current graph.

To rename the node schema `School` to `University` in the current graph:

```gql
ALTER NODE School RENAME TO University
```

To rename the edge schema `Follows` to `Follow` in the current graph:

```gql
ALTER EDGE Follows RENAME TO Follow
```

To update the comment of the node schema `User` in the current graph:

```gql
ALTER NODE User COMMENT "Self-registration"
```

To update the comment of the edge schema `Follows` in the current graph:

```gql
ALTER EDGE Follows COMMENT "From user to user"
```

You can perform both operations in a single statement:

```gql
ALTER NODE User RENAME TO User_s2 COMMENT "Self-registration"
```

## Altering Properties 

You can alter the name and comment of a property in the current graph.

To rename the property `name` to `username` for `User` nodes in the current graph:

```gql
ALTER NODE User name RENAME TO username
```

To rename the property `createdOn` to `startDate` for `Follows` edges in the current graph:

```gql
ALTER EDGE Follows createdOn RENAME TO startDate
```

To update the comment for the `name` property of `User` nodes in the current graph:

```gql
ALTER NODE User name COMMENT "Contains 5 to 64 characters"
```

To update the comment for the `createdOn` property of `Follows` edges in the current graph:

```gql
ALTER EDGE Follows createdOn COMMENT "When the relationship is established"
```

You can perform both operations in a single statement:

```gql
ALTER EDGE Follows createdOn RENAME TO startDate COMMENT "When the relationship is established"
```

## Dropping Schemas and Properties

You can delete schemas and properties from a graph. 

- **Dropping a schema:** Deleting a node or edge schema also deletes all nodes or edges that belong to that schema. Note that this deletion of nodes automatically triggers the removal of all edges connected to them. The two built-in `default` schemas cannot be dropped.
- **Dropping a property:** When a property is dropped, all related data - including the property values, associated indexes, and cached values - is permanently removed.

The schema dropping operation runs as a job, you may run `SHOW JOB <id?>` afterward to verify its completion.

To drop the node schema `User` from the graph `g1`:

```gql
ALTER GRAPH g1 DROP NODE User 
```

To drop edge schemas `Follows` and `StudyAt` from the graph `g1`:

```gql
ALTER GRAPH g1 DROP EDGE Follows, StudyAt 
```

To drop properties `name` and `age` from `User` nodes in the current graph:

```gql
ALTER NODE User DROP PROPERTY name, age
```

To drop the property `when` from `links` edges in the current graph:

```gql
ALTER EDGE links DROP PROPERTY when
```

To drop the property `location` from all nodes in the current graph:

```gql
ALTER NODE * DROP PROPERTY location
```
