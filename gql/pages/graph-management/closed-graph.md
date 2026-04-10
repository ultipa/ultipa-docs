# Closed Graph

## Overview

The **closed graph** is constrained by its **graph type**, which imposes a strict framework that governs data insertion: each node or edge belongs to exactly one pre-defined **node type** or **edge type**.

In a closed graph,

- Each node has one or multiple labels, each edge has one label.
- Nodes or edges of the same type have the same set of properties.

While the graph type can be altered after a graph is created, its defined data model ensures consistent structure, guaranteeing high data integrity and consistency.

## Node/Edge Type

### Syntax

<p tit="Syntax"></p>

```
<node type> ::=
  "NODE" [ "TYPE" ] <node type name> "(" [ <additional labels> ] [ <property types> ] ")"

<edge type> ::=
  "EDGE" [ "TYPE" ] <edge type name> <source node type reference> 
  "-[" [ <additional labels> ] [ <property types> ] "]->" <destination node type reference>

<additional labels> ::=
  < ":" | "IS" > <label name> [ { "&", <label name> } ... ]

<property types> ::=
  "{" <property type> [ { "," <property type> } ... ] "}"

<property type> ::=
  <property name> <property value type> 
```

Each node or edge type has a unique type name, and is associated with a set of labels and property types. Each property type is defined with a property name and a <a target="_blank" href="/docs/gql/values-and-types#Property-Value-Types">property value type</a>.

### Labels

The node or edge type name automatically becomes a label. The **label set** of a node or edge type is the union of its type name and additional labels (optional).

When no additional labels are specified, the type name is the only label:

```gql
-- label set: [User]
NODE User ({name STRING})
```

Add additional labels:

```gql
-- label set: [User, Employee]
NODE User (:Employee {name STRING})
```

```gql
-- label set: [User, Employee, Manager]
NODE User (:Employee&Manager {name STRING})
```

### Edge Type Endpoints

Edge types can specify source and destination node types, where `<source/destination node type reference>` is `()` or `(<labels>)`. The `<labels>` is matched against the label sets of node types.

```gql
-- The FOLLOWS edge connects any two nodes
EDGE FOLLOWS ()-[{createdOn LOCAL DATETIME}]->()

-- The JOINS edge connects source nodes whose label set is [User,Employee] to destination nodes whose label set is [Company]                  
EDGE JOINS (:User&Employee)-[{title STRING}]->(:Company)
```

## Creating Closed Graphs

### Inline Graph Type

Create a closed graph `g2` with inline graph type specification, which defines:

- Node type `User` with properties `name` (`STRING` type) and `age` (`UINT32` type)
- Node type `Club` with a property `name` (`STRING` type)
- Edge type `FOLLOWS` with a property `createdOn` (`LOCAL DATETIME` type)
- Edge type `JOINS` with no properties

```gql
CREATE GRAPH g2 {
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE FOLLOWS ()-[{createdOn TIMESTAMP}]->(),
  EDGE JOINS ()-[]->()
}
```

### Defined Graph Type

Create a closed graph `g3` based on the defined graph type named `gType` (<a href="#Managing-Graph-Types">How to manage graph types</a>), you have three equivalent GQL options to specify the graph type to be used:

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

The graph `g3` is created with all the types and properties defined within the graph type `gType`.

## Managing Graph Types

The graph type defines structural rules for graphs by outlining the allowed node and edge types. You can define and store graph types in the database, making them reusable when creating new graphs.

### Showing Graph Types

Show graph types defined in the database:

```gql
SHOW GRAPH TYPES
```

Each graph type provides the following essential metadata:

| Field | Description |
| -- | -- |
| `name` | The unique name assigned to the graph type. |
| `node_type_count` | Number of node types. |
| `edge_type_count` | Number of edge types. |
| `node_types` | Comma-separated list of node type names. |
| `edge_types` | Comma-separated list of edge type names. |
| `definition` | The type definitions. |
| `bound_graphs` | Graphs that use this graph type. |
| `comment` | The comment of the graph type. |
| `created_at` | Creation time. |
| `updated_at` | Last update time. |

### Creating Graph Types

Create a graph type `gType`:

```gql
CREATE GRAPH TYPE gType {
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE FOLLOWS ()-[{createdOn TIMESTAMP}]->(),
  EDGE JOINS ()-[]->()
}
```

### Dropping Graph Types

Drop the graph type `gType`:

```gql
DROP GRAPH TYPE gType
```

The `IF EXISTS` clause is used to prevent errors when attempting to delete a graph type that does not exist. It allows the statement to be safely executed.

```gql
DROP GRAPH TYPE IF EXISTS gType
```

This deletes the graph type `gType` only if a graph type with that name does exist. If `gType` does not exist, the statement is ignored without throwing an error.

## Showing Node/Edge Types

Show node types defined in the current graph:

```gql
SHOW NODE TYPES
```

Show edge types defined in the current graph:

```gql
SHOW EDGE TYPES
```

Each type provides the following metadata:

| <div table-width="20">Field</div> | Description |
| -- | -- |
| `type` | `NODE` or `EDGE`. |
| `name` | The name of the type. |
| `properties` | The associated property definitions. |

## Showing Labels

Show labels in the current graph:

```gql
SHOW LABELS
```

Show node labels in the current graph:

```gql
SHOW NODE LABELS
```

Show edge labels in the current graph:

```gql
SHOW EDGE LABELS
```

Each label provides the following essential metadata:

| <div table-width="17">Field</div> | Description |
| -- | -- |
| `label` | The name of the label. |
| `type` | The type of the label, `NODE` or `EDGE`. |

## Altering Graph Types

You can alter the graph type of an existing closed graph.

### Adding Node/Edge Types

Add a node type `Book` in the graph `g2`:

```gql
ALTER GRAPH g2 ADD NODE Book ({name STRING, author STRING})
```

Add an edge type `PURCHASED` in the graph `g2`:

```gql
ALTER GRAPH g2 ADD EDGE PURCHASED (:User)-[{createdOn TIMESTAMP}]->(:Book)
```

### Adding Properties

Add a property `gender` to the node type `User` in the current graph:

```gql
ALTER NODE User ADD PROPERTY gender STRING
```

Add a property `memberNo` to the edge type `JOINS` within the current graph:

```gql
ALTER EDGE JOINS ADD PROPERTY memberNo INT32
```

### Renaming Node/Edge Types

To rename the node type `User` to `People` in the current graph:

```gql
ALTER NODE User RENAME TO People
```

To rename the edge type `FOLLOWS` to `LINKS` in the current graph:

```gql
ALTER EDGE FOLLOWS RENAME TO LINKS
```

### Renaming Properties

To rename the property `name` to `title` for the node type `Book` in the current graph:

```gql
ALTER NODE Book PROPERTY name RENAME TO title
```

To rename the property `memberNo` to `memberNumber` for the edge type `JOINS` in the current graph:

```gql
ALTER EDGE JOINS PROPERTY memberNo RENAME TO memberNumber
```

### Dropping Node/Edge Types

A node or edge type can only be dropped when no nodes or edges of that type exist.

Drop the node type `User` from the graph `g2`:

```gql
ALTER GRAPH g2 DROP NODE User
```

Drop the edge type `FOLLOWS` from the graph `g2`:

```gql
ALTER GRAPH g2 DROP EDGE FOLLOWS
```

### Dropping Properties

When a property is dropped, all related data - including the property values, associated indexes, and cached values - is permanently removed.

Drop the property `name` from the node type `User` in the current graph:

```gql
ALTER NODE User DROP PROPERTY name
```

Drop the property `createdOn` from the edge type `FOLLOWS` in the current graph:

```gql
ALTER EDGE FOLLOWS DROP PROPERTY createdOn
```
