# Schema

## Overview

In Ultipa Graph, a schema represents a node or edge type. When modeling a real-world scenario into a graph, node schemas are generally used to depict different types of **entities** (such as Account, Company, Card), and edge schemas represent types of **relations** between entities (such as Follow, Hold, Transfer).

The definition of schemas is a prerequisite for creating any node or edge data. Each node or edge is designated to one and only one schema. A graphset usually contains multiple node schemas and edge schemas.

A node schema and an edge schema both named *default* are automatically created during the creation of a graphset. They can be freely utilized. However, the two *default* schemas are not allowed to be altered or dropped.

The symbol `@` is used in UQL to denote a schema. The expression `@<schema>` specifies a certain schema, such as `@Account`.

## Show Schema

```uql
// Show all schemas in the graphset
show().schema()

// Show all node schemas in the graphset
show().node_schema()

// Show all edge schemas in the graphset
show().edge_schema()

// Show the node schema named movie in the graphset
show().node_schema(@movie)

// Show the edge schema named filmedIn in the graphset
show().edge_schema(@filmedIn)
```

Example result:

`_nodeSchema`

| <div table-width=10>name</div> | <div table-width=14>totalNodes</div> | <div table-width=14>description</div> | properties |
| -- | -- | -- | -- |
| default | 0 | default schema | [] |
| movie | 92 | | [{name: "name", type: "string", description: "", lte: "true", extra: "{}"},<br>{name: "genre", type: "string", description: "", lte: "false", extra: "{}"},<br>{name: "rating", type: "double", description: "", lte: "false", extra: "{}"}] |
| country | 78 | | [{name: "name", type: "string", description: "", lte: "false", extra: "{}"}] |

`_edgeSchema`

| <div table-width=10>name</div> | <div table-width=14>totalEdges</div> | <div table-width=14>description</div> | properties |
| -- | -- | -- | -- |
| default | 0 | default schema | [] |
| filmedIn | 192 | | [{name: "time", type: "timestamp", description: "", lte: "false", extra: "{}"}] |

The `properties` only contains custom properties; system properties are not included in the results.

## Create Schema

```uql
// Create a node schema named movie in the graphset, and provide description
create().node_schema("movie", "The movies added by the admin")

// Create an edge schema named filmedIn in the graphset
create().edge_schema("filmedIn")

// Create multiple node/edge schemas at one time
create()
  .node_schema("movie", "The movies added by the admin")
  .node_schema("country")
  .edge_schema("filmedIn")
```

### Naming Conventions

Here are the naming conventions for schemas:

- Contains 2 to 64 characters.
- Not allowed to start with a tilde symbol `~`.
- Not allowed to contain backquote symbol `` ` ``.
- Not allowed to use any <a href="/docs/uql/reserved-words">reserved words</a>.

All node schemas in a graphset must have distinct names, and the same applies for edge schemas. A node schema and an edge schema may share the same name.

When the schema name contains characters other than letters (A-Z, a-z), numbers (0-9) and underscores (`_`), the schema name must be wrapped with a pair of backquotes (`` ` ``) when being used.

```uql
find().nodes({@`movie*`}) as n
return n
```

### Use TRY

Create three node schemas at the same time, but one of the names (*default*) is duplicated with an existing node schema.

```uql
create().node_schema("new_1").node_schema("default").node_schema("new_2")
```

The creation of the node schema *new_1*, which was specified before the duplicated schema, succeeds. However, the one (*new_2*) specified after the duplicated schema fails, with the error message `Schema already exist!` returned.

```uql
TRY create().node_schema("new_1").node_schema("default").node_schema("new_2")
```

The creation of the schemas is the same as above, though the error message is shielded by the `TRY` prefix, while returning the message `SUCCEED`.

## Alter Schema

```uql
// Alter name and description of the node schema currently named movie
alter().node_schema(@movie)
  .set({name: "Adm_movie", description: "Movies added by the admin"})

// Alter description of the edge schema named filmedIn
alter().edge_schema(@filmedIn).set({description: "The country where a movie is filmed"})
```

## Drop Schema

Dropping a schema means to delete the schema, along with any nodes or edges belonging to that schema. The two default schemas cannot be dropped.

```uql
// Drop the node schema named movie
drop().node_schema(@movie)

// Drop the edge schema named filmedIn
drop().edge_schema(@filmedIn)
                   
// Drop multiple node/edge schemas at one time
drop()
  .node_schema(@movie)
  .node_schema(@country)
  .edge_schema(@filmedIn)
```
