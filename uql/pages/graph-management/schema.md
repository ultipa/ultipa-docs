# Schema

## Overview

A schema defines the graph model by specifying the allowed node and edge types, their <a target="_blank" href="/docs/uql/property">properties</a>, and associated <a target="_blank" href="/docs/uql/constraints">constraints</a>.

In a **schema-free graph**, no explicit schema definitions are required before inserting data. You can directly insert nodes and edges into the graph, and the corresponding schemas and properties will be automatically created on the fly.

In a **schema-constrained graph**, however, schemas must be defined before any node or edge data can be inserted.

In Ultipa, every node belongs to exactly one node schema, and every edge belongs to exactly one edge schema. The operator `@` denotes a schema. For example, `@Account` specifies the `Account` schema.

## Built-in Default Schemas

Each graphset comes with a built-in node schema and edge schema, both named `default`. The two default schemas are available for unrestricted use but cannot be deleted or altered.

## Showing Schemas

Retrieves schemas in the current graphset:

```uql
// Shows all schemas
show().schema()

// Shows all node schemas
show().node_schema()

// Shows the specified node schema
show().node_schema(@user)

// Shows all edge schemas
show().edge_schema()

// Shows the specified edge schema
show().edge_schema(@transfers)
```

The information about schemas is organized into different tables:

- **Node schemas**: Stored in `_nodeSchema` (all schemas) and `_nodeSchema_shard_<id>` (schemas with data stored in one shard) tables.
- **Edge schemas**: Stored in `_edgeSchema` (all schemas) and `_edgeSchema_shard_<id>` (schemas with data stored in one shard) tables.

> Ultipa Manager has been configured to display only the `_nodeSchema` and `_edgeSchema` tables.

Each table includes the following fields:

| <div table-width="17">Field</div> | Description |
| -- | -- |
| `id` | The id of the schema. |
| `name` | The name assigned to the schema. |
| `description` | The description given to the schema. |
| `status` | The current state of the schema, which can only be `CREATED`. |
| `properties` | The properties of the schema, with each property contains `name`, `id`, `type`, `description`, `index`, `fulltext`, `nullable`, `lte`, `read`, `write`, `encrypt`, and `is_deleted`. |

There is another table, `_graphCount`, which provides an overview of the number of nodes and edges for each schema. Each edge schema is counted based on the distinct combinations of the start and end node schemas it connects.

## Creating Schemas

You can create one or more schemas using a single `create()` statement. Each schema is defined by calling a `node_schema()` or `edge_schema()` method as part of a method chain.

<p tit="Syntax"></p>

```uql
create()
  .node_schema("<schemaName>", "<schemaDesc?>")
  .edge_schema("<schemaName>", "<schemaDesc?>")
  ...
```

<table>
  <thead>
    <tr>
      <th style="width:18%">Method</th>
      <th style="width:20%">Param</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan=2><code>node_schema()</code> or <code>edge_schema()</code></td>
      <td><code>&lt;schemaName&gt;</code></td>
      <td>Name of the schema. Naming conventions are:<br><ul><li>2 to 127 characters.</li><li>Cannot start with an underscore(<code>_</code>) or a tilde (<code>~</code>).</li><li>Cannot contain backticks (<code>`</code>) or the name of any system properties, system table aliases and system aliases (refer to <a target="_blank" href="/docs/uqlreserved-keywords">Reserved Keywords</a>).</li></ul>Names must be unique among node schemas and among edge schemas, but a node schema and an edge schema may share the same name.</td>
    </tr>
    <tr>
      <td><code>&lt;schemaDesc?&gt;</code></td>
      <td>Optional. Description of the schema.</td>
    </tr>
  </tbody>
</table>

To create a node schema:

```uql
create().node_schema("user", "Self-registeration")
```

To create an edge schema:

```uql
create().edge_schema("likes")
```

To create multiple schemas:

```uql
create()
  .node_schema("user", "Self-registeration")
  .node_schema("movie")
  .edge_schema("likes")
```

## Altering Name and Description

You can modify the name and description of a schema using the `alter().node_schema().set()` or `alter().edge_schema().set()` statement. The two default schemas cannot be altered.

To alter both name and description of the node schema `@user`:

```uql
alter().node_schema(@user).set({name: "User", description: "club users"})
```

To alter name and remove description of the edge schema `@join`:

```uql
alter().edge_schema(@join).set({name: "joins", description: ""})
```

To alter name of the node schema `@account`:

```uql
alter().node_schema(@account).set({name: "user"})
```

To alter description of the edge schema `@link`:

```uql
alter().edge_schema(@link).set({description: "the link between people and event"})
```

## Dropping Schemas

You can drop one or more schemas using a single `drop()` statement. Each schema is specified by chaining a `node_schema()` or `edge_schema()` method. The schema dropping operation runs as a job, you may run `show().job(<id?>)` afterward to verify its completion.

Dropping a schema deletes both the schema and any nodes or edges that belong to it from the database. Note that the deletion of a node leads to the removal of all edges that are connected to it. The two default schemas cannot be dropped.

To drop the node schema `@user`:

```uql
drop().node_schema(@user)
```

To drop the edge schema `@likes`:

```uql
drop().edge_schema(@likes)
```

To drop multiple schemas:

```uql
drop().node_schema(@user).edge_schema(@likes)
```
