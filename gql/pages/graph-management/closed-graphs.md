# Closed Graphs

## Overview

A **closed graph** is constrained by its **graph type**, which is a list of node types and edge types. It imposes a strict framework that governs data insertion: each node or edge belongs to exactly one **node type** or **edge type**. The graph type ensures consistent structure and guarantees high data integrity and consistency.

### Node Types

A node type is the schema definition that nodes of a closed graph must conform to. Each node type is identified by a unique node type name and consists of a label set and a set of property types. **Each node belongs to one node type.**

<p tit="Syntax"></p>

```
<node type> ::=
  "NODE" [ "TYPE" ] <node type name> "(" [ <implied labels> ] [ <property types> ] ")"

<implied labels> ::= ":" <label name> [ { "&" <label name> } ... ]

<property types> ::= "{" <property type> [ { "," <property type> } ... ] "}"

<property type> ::= <property name> <property value type> [ <constraint type> ]
```

The node type name automatically becomes a label. The **label set** of a node type is the union of its type name and optional implied labels. When no additional labels are specified, the type name is the only label.

<p tit="Node Type"></p>

```gql
-- No implied labels specified, node type name is the only label
-- Label set is :User
NODE User ({name STRING})

-- One implied label specified
-- Label set is :User&Employee
NODE User (:Employee {name STRING})

-- Multiple implied labels specified
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
  "(" [ <source node type name> ] ")-[" [ <property types> ] "]->(" [ <destination node type name> ] ")"

<edge type phrase> ::=
  [ <property types> ] "CONNECTING" "(" <source node type name> < "->" | "TO" > <destination node type name> ")"
```

Unlike node types, edge types do not support implied labels — the edge type name is its only label. The property types follow the same rules as on <a href="#Node-Types">node types</a>.

An edge type can constrain its endpoints to defined node types. The **pattern form** accepts either `()` (any node) or `(<NodeTypeName>)` on each side; the **phrase form** `CONNECTING (Source -> Destination)` requires a node-type name on both sides. 

<div tab="code">

<p tit="Edge Type: Pattern Form"></p>

```gql
-- Connects any node to any node, no properties
EDGE FOLLOWS ()-[]->()

-- Connects any node to any node, with property 'since' of type DATE
EDGE LIKES ()-[{since DATE}]->()

-- Both source and destination node type names are User
EDGE FOLLOWS (User)-[{since DATE}]->(User)

-- Source node type name is User, destination node type name is Company
EDGE WORKS_AT (User)-[{title STRING}]->(Company)
```

<p tit="Edge Type: Phrase Form"></p>

```gql
-- Source and destination are both node type User
EDGE FOLLOWS CONNECTING (User -> User)

-- TO is an alias for ->
EDGE JOINS CONNECTING (User TO Club)

-- Properties precede the CONNECTING clause
EDGE WORKS_AT {title STRING} CONNECTING (Employee -> Company)
```

</div>

A single declaration constrains an edge type to one (source → target) pair. To allow the **same edge type** between more than one node-type pair, declare it multiple times under the same name with different endpoints. All declarations of the same name must share identical property types — only the endpoints may vary; the engine merges them into one edge type with a list of allowed endpoint pairs.

<p tit="Edge Type"></p>

```gql
-- WORKS_AT accepts (Employee → Company) and (Contractor → Company)
EDGE WORKS_AT (Employee)-[{title STRING}]->(Company),
EDGE WORKS_AT (Contractor)-[{title STRING}]->(Company)
```

If the bodies differ, the engine will reject:

```gql
-- Error: property definitions differ
EDGE WORKS_AT (Employee)-[{title STRING}]->(Company),
EDGE WORKS_AT (Contractor)-[{title STRING, since DATE}]->(Company)
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
<inline graph type> ::= "{" [ <element type> [ { "," <element type> }... ] ] "}"

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
  EDGE FOLLOWS (User)-[{createdOn TIMESTAMP}]->(User),
  EDGE JOINS (User)-[]->(Club)
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

Each row provides the following metadata:

| Field | Description |
| -- | -- |
| `type` | `NODE` or `EDGE`. |
| `name` | The name of the type. |
| `properties` | The associated property definitions. |
| `source_types` | For edges: a list of source node-type names from one allowed endpoint pair. Empty for nodes and for edges with no endpoint constraint. |
| `target_types` | For edges: a list of target node-type names from one allowed endpoint pair. Empty for nodes and for edges with no endpoint constraint. |

An edge type declared with multiple endpoint pairs renders as **one row per pair**, sharing the same `type` / `name` / `properties` but with different `source_types` / `target_types`.

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

## Creating Node/Edge Types

Create new node and edge types in a closed graph using the `CREATE NODE/EDGE [TYPE]` statement:

```gql
-- Add node type Book to the current graph
CREATE NODE Book ({name STRING, author STRING})

-- Add edge type PURCHASED to graph g2
CREATE EDGE PURCHASED (User)-[{createdOn TIMESTAMP}]->(Book) ON GRAPH g2

-- Skip if a node type with the same name already exists
CREATE NODE IF NOT EXISTS Book ({name STRING, author STRING})

-- Replace the existing node type with the same name
CREATE OR REPLACE NODE Book ({name STRING, author STRING, isbn STRING})
```

## Dropping Node/Edge Types

A node or edge type can only be dropped when it has no dependent objects. Dependents include:

- Existing nodes or edges of that type.
- Named constraints registered on that type.
- For node types: any edge type that references it as a source or destination endpoint. Drop such edge types first.

Drop node and edge types from a closed graph using the `DROP NODE/EDGE [TYPE]` statement:

```gql
-- Drop node type User from the current graph
DROP NODE User

-- Drop edge type FOLLOWS from graph g2
DROP EDGE TYPE FOLLOWS ON GRAPH g2

-- Skip if the type does not exist
DROP NODE IF EXISTS Book

-- Drop the type along with its nodes and any constraints registered on it
DROP NODE User CASCADE
```

`CASCADE` removes the dependent nodes/edges and named constraints alongside the type, but does **not** drop other type definitions that depend on it — edge types referencing a node type as endpoint must be dropped explicitly first.

## Renaming Node/Edge Types

Rename node and edge types in the current graph:

```gql
-- Rename node type User to People
ALTER NODE User RENAME TO People

-- Rename edge type FOLLOWS to LINKS
ALTER EDGE FOLLOWS RENAME TO LINKS
```

## Adding Properties

Add properties to node and edge types in the current graph:

```gql
-- Add property gender to node type User
ALTER NODE User ADD PROPERTY gender STRING

-- Add property memberNo to edge type JOINS
ALTER EDGE JOINS ADD PROPERTY memberNo INT32
```

## Renaming Properties

Rename node and edge properties in the current graph:

```gql
-- Rename property name to title for Book node type
ALTER NODE Book PROPERTY name RENAME TO title

-- Rename property memberNo to memberNumber for JOINS edge type
ALTER EDGE JOINS PROPERTY memberNo RENAME TO memberNumber
```

## Dropping Properties

When a property is dropped, all related data - including the property values, associated indexes, and cached values - is permanently removed. Drop node and edge properties from the current graph:

```gql
-- Drop property name from node type User
ALTER NODE User DROP PROPERTY name

-- Drop property createdOn from edge type FOLLOWS
ALTER EDGE FOLLOWS DROP PROPERTY createdOn
```
