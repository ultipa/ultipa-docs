# Closed Graphs

## Overview

A **closed graph** is constrained by its **graph type**, which is a list of node types and edge types. It imposes a strict framework that governs data insertion: each node or edge belongs to exactly one **node type** or **edge type**. The graph type ensures consistent structure and guarantees high data integrity and consistency.
 
In a closed graph,

- Each node belongs to one node type with one or multiple labels, each edge belongs to one edge type with exactly one label.
- Nodes or edges of the same type share the same set of properties.

## Creating Closed Graphs

<p tit="Syntax"></p>

```
<create closed graph statement> ::=
  "CREATE GRAPH" [ "IF NOT EXISTS" ] 
  { <inline graph type> | <named graph type> | <inferred graph type> }
```

You have three ways to create a closed graph:

### Inline Graph Type

Define the node and edge types directly in the `CREATE GRAPH` statement. The graph type lives on the graph itself, with no separate named definition.

<p tit="Syntax"></p>

```
<inline graph type> ::= "{" [ <element type> [ { "," <element type> }... ] ] "}"

<element type> = <node type> | <edge type>

<node type> ::=
  "NODE" [ "TYPE" ] <node type name> "(" [ <additional labels> ] [ <property types> ] ")"

<edge type> ::=
  "EDGE" [ "TYPE" ] <edge type name> <source node type>
  "-[" [ <additional labels> ] [ <property types> ] "]->" <destination node type>

<source/destination node type> ::= "(" [ ":" <label name> [ { "&" <label name> } ... ] ] ")"

<additional labels> ::= ":" <label name> [ { "&" <label name> } ... ]

<property types> ::= "{" <property type> [ { "," <property type> } ... ] "}"

<property type> ::= <property name> <property value type> [ <constraint type> ]
```

Create a closed graph `g2` with inline graph type specification:

```gql
CREATE GRAPH g2 {
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE FOLLOWS ()-[{createdOn TIMESTAMP}]->(),
  EDGE JOINS ()-[]->()
}
```

#### Label Set

The node or edge type name automatically becomes a label. The **label set** of a node or edge type is the union of its type name and optional additional labels.

When no additional labels are specified, the type name is the only label:

```gql
-- label set: [User]
NODE User ({name STRING})
```

Add additional labels:

```gql
-- label set: [User, Employee]
NODE User (:Employee {name STRING})

-- label set: [User, Employee, Manager]
NODE User (:Employee&Manager {name STRING})
```

#### Source and Destination Node Types

Edge types can specify source and destination node types, where `<source/destination node type>` is `()` or `(<labels>)`. The `<labels>` is matched against the label sets of node types.

```gql
-- The FOLLOWS edge connects any two nodes
EDGE FOLLOWS ()-[{createdOn LOCAL DATETIME}]->()

-- The JOINS edge connects source nodes whose label set is [User,Employee] to destination nodes whose label set is [Company]
EDGE JOINS (:User&Employee)-[{title STRING}]->(:Company)
```

#### Property Value Types

Each node or edge type is associated with a set property types. Each property type is defined with a <a target="_blank" href="/docs/gql/values-and-types#Property-Value-Types">property value type</a>.

### Named Graph Type

Bind the graph to a pre-defined, reusable <a target="_blank" href="/docs/gql/graph-types">graph type</a>. The graph type lives as a separate object and can be shared by multiple graphs.

<p tit="Syntax"></p>

```
<named graph type> ::= [ "::" | "TYPED" ] <graph type name>
```

Create a closed graph `g3` with all the node and edge types and properties defined within the graph type `gType`:

```gql
-- Bare reference
CREATE GRAPH g3 gType

-- :: separator
CREATE GRAPH g3 :: gType

-- TYPED keyword
CREATE GRAPH g3 TYPED gType
```

### Inferred Graph Type

Copy the graph type from another closed graph. Only the schema (node and edge types) is copied, no data is included.

<p tit="Syntax"></p>

```
<cloned graph type> ::= "LIKE" <graph name>
```

Create a closed graph `g4` whose schema matches `g2`:

```gql
CREATE GRAPH g4 LIKE g2
```

To clone both the schema and the data, use `AS COPY OF` instead (see <a target="_blank" href="/docs/gql/graphs#cloning-graphs">Cloning Graphs</a>).

## Showing Node/Edge Types

Show node or edge types defined in the current graph:

```gql
SHOW NODE TYPES
SHOW EDGE TYPES
```

To inspect a single node or edge type:

```gql
DESCRIBE NODE TYPE Person
DESCRIBE EDGE TYPE Follows

-- DESC is a shorthand for DESCRIBE
DESC NODE TYPE Person
DESC EDGE TYPE Follows
```

Each type provides the following metadata:

| Field | Description |
| -- | -- |
| `type` | `NODE` or `EDGE`. |
| `name` | The name of the type. |
| `properties` | The associated property definitions. |

## Showing Labels

Show labels in the current graph:

```gql
SHOW LABELS
SHOW NODE LABELS
SHOW EDGE LABELS
```

To inspect a single label:

```gql
DESCRIBE LABEL myLabel

-- DESC is a shorthand for DESCRIBE
DESC LABEL myLabel
```

Each label provides the following essential metadata:

| Field | Description |
| -- | -- |
| `label` | The name of the label. |
| `type` | The type of the label, `NODE` or `EDGE`. |

## Adding Node/Edge Types

Add node and edge types to a closed graph: 

```gql
-- Add node type Book to g2
ALTER GRAPH g2 ADD NODE Book ({name STRING, author STRING})

-- Add edge type PURCHASED to g2
ALTER GRAPH g2 ADD EDGE PURCHASED (:User)-[{createdOn TIMESTAMP}]->(:Book)
```

## Adding Properties

Add properties to node and edge types in the current graph:

```gql
-- Add property gender to node type User
ALTER NODE User ADD PROPERTY gender STRING

-- Add property memberNo to edge type JOINS
ALTER EDGE JOINS ADD PROPERTY memberNo INT32
```

## Renaming Node/Edge Types

Rename node and edge types in the current graph:

```gql
-- Rename node type User to People
ALTER NODE User RENAME TO People

-- Rename edge type FOLLOWS to LINKS
ALTER EDGE FOLLOWS RENAME TO LINKS
```

## Renaming Properties

Rename node and edge properties in the current graph:

```gql
-- Rename property name to title for Book node type
ALTER NODE Book PROPERTY name RENAME TO title

-- Rename property memberNo to memberNumber for JOINS edge type
ALTER EDGE JOINS PROPERTY memberNo RENAME TO memberNumber
```

## Dropping Node/Edge Types

A node or edge type can only be dropped when no nodes or edges of that type exist. Drop node and edge types from a graph:

```gql
-- Drop node type User from g2
ALTER GRAPH g2 DROP NODE User

-- Drop edge type FOLLOWS from g2
ALTER GRAPH g2 DROP EDGE FOLLOWS
```

## Dropping Properties

When a property is dropped, all related data - including the property values, associated indexes, and cached values - is permanently removed. Drop node and edge properties from the current graph:

```gql
-- Drop property name from node type User
ALTER NODE User DROP PROPERTY name

-- Drop property createdOn from edge type FOLLOWS
ALTER EDGE FOLLOWS DROP PROPERTY createdOn
```
