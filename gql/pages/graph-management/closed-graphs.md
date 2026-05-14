# Closed Graphs

## Overview

A **closed graph** is constrained by its **graph type**, which is a list of node types and edge types. It imposes a strict framework that governs data insertion: each node or edge belongs to exactly one **node type** or **edge type**. The graph type ensures consistent structure and guarantees high data integrity and consistency.

### Node Types

A node type is the schema definition that nodes of a closed graph must conform to. Each node type is identified by a unique node type name and consists of a label set and a set of property types. **Each node belongs to one node type.**

<p tit="Syntax"></p>

```
<node type> ::=
  "NODE" [ "TYPE" ] <node type name> "(" [ <additional labels> ] [ <property types> ] ")"

<additional labels> ::= ":" <label name> [ { "&" <label name> } ... ]

<property types> ::= "{" <property type> [ { "," <property type> } ... ] "}"

<property type> ::= <property name> <property value type> [ <constraint type> ]
```

The node type name automatically becomes a label. The **label set** of a node type is the union of its type name and optional additional labels. When no additional labels are specified, the type name is the only label.

<p tit="Node Type"></p>

```gql
-- No additional labels specified, node type name is the only label
-- Label set is :User
NODE User ({name STRING})

-- One additional label specified
-- Label set is :User&Employee
NODE User (:Employee {name STRING})

-- Multiple additional labels specified
-- Label set is :User&Employee&Manager
NODE User (:Employee&Manager {name STRING})
```

A **property type** is the schema-level declaration of a single property belonging to a node type or edge type. It has three parts:

- **Property name:** A unique identifier of the property within the type (e.g. `name`, `age`, `createdOn`).
- **Property value type:** An explicit value type that all values of this property must conform to (e.g. `STRING`, `INT32`, `LOCAL DATETIME`). See <a target="_blank" href="/docs/gql/values-and-types#Property-Value-Types">Property Value Types</a>.
- **Constraint type:** Optional, additional validation rule on the property (e.g. `NOT NULL`). See <a target="_blank" href="/docs/gql/constraints">Constraints</a>.

```gql
-- 'name' must be a non-null string; 'age' must be an integer; no other properties are allowed
NODE User ({name STRING NOT NULL, age INTEGER})
```

### Edge Types

An edge type is the schema definition that edges of a closed graph must conform to. Each edge type is identified by a unique edge type name and consists of one label and a set of property types. **Each edge belongs to one edge type.**

<p tit="Syntax"></p>

```
<edge type> ::= 
  "EDGE" [ "TYPE" ] <edge type name> { <edge type pattern> | <edge type phrase> }

<edge type pattern> ::=
  <source node label set> "-[" [ <property types> ] "]->" <destination node label set>

<edge type phrase> ::=
  [ <property types> ] "CONNECTING" "(" <source node type name> < "->" | "TO" > <destination node type name> ")"

<property types> ::= "{" <property type> [ { "," <property type> } ... ] "}"

<property type> ::= <property name> <property value type> [ <constraint type> ]
```

Unlike a node type, an edge type does not support additional labels — the edge type name is its only label. The property types follow the same rules as on <a href="#Node-Types">node types</a>.

An edge type can also constrain its endpoints. The **pattern form** matches source and destination by label sets, while the **phrase form** references node-type names.

Pattern form examples (endpoints are node-type label sets defined in the same graph type):

<p tit="Edge Type"></p>

```gql
-- Connects any node to any node, no properties
EDGE FOLLOWS ()-[]->()

-- Connects any node to any node, with property 'since' of type DATE
EDGE LIKES ()-[{since DATE}]->()

-- Both source and destination label sets are :User
EDGE FOLLOWS (:User)-[{since DATE}]->(:User)

-- Source label set is :User&Employee, destination labet set is :Company
EDGE WORKS_AT (:User&Employee)-[{title STRING}]->(:Company)
```

Phrase form examples (endpoints are node-type names defined in the same graph type):

<p tit="Edge Type"></p>

```gql
-- Source and destination are both node type User
EDGE FOLLOWS CONNECTING (User -> User)

-- TO is an alias for ->
EDGE JOINS CONNECTING (User TO Club)

-- Properties precede the CONNECTING clause
EDGE WORKS_AT {title STRING} CONNECTING (Employee -> Company)
```

## Creating Closed Graphs

You have three ways to specify the graph type when creating a closed graph:

<p tit="Syntax"></p>

```
<graph type specification> ::= 
  <inline graph type> | <named graph type> | <inferred graph type>
```

### Inline Graph Type

Define the node and edge types directly in the `CREATE GRAPH` statement.

<p tit="Syntax"></p>

```
<inline graph type> ::= 
  "{" [ <element type> [ { "," <element type> }... ] ] "}"

<element type> = <node type> | <edge type>
```

Create a closed graph `g1` with inline graph type specification:

```gql
CREATE GRAPH g1 {
  NODE User ({name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE FOLLOWS ()-[{createdOn TIMESTAMP}]->(),
  EDGE JOINS ()-[]->()
}
```

You can also constrain edge type endpoints:

```gql
CREATE GRAPH g2 {
  NODE User (:Player {name STRING, age UINT32}),
  NODE Club ({name STRING}),
  EDGE FOLLOWS (:User&Player)-[{createdOn TIMESTAMP}]->(:User&Player),
  EDGE JOINS (:User&Player)-[]->(:Club)
}
```

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
