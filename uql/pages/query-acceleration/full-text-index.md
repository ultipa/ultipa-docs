# Full-text Index

## Overview

A full-text index is a type of index specialized for efficient searching for `string` or `text` properties, especially in large text fields like descriptions, comments, or articles.

Full-text indexes work by breaking down the text into smaller segments called tokens. When a query is performed, the search engine matches specified keywords against these tokens instead of the original full text, allowing for faster retrieval of relevant results. Full-text indexes support both precise and fuzzy matches.

## Showing Full-text Indexes

To retrieve information about full-text indexes in the current graphset:

```uql
// Shows all full-text indexes
show().fulltext()

// Show all node full-text indexes
show().node_fulltext()

// Show all edge full-text indexes
show().edge_fulltext()
```

The information about full-text indexes is organized into the `_nodeFulltext` or `_edgeFulltext` table. Each table provides essential details about each full-text index:

| <div table-width="15">Field</div> | Description |
| -- | -- |
| `name` | Full-text index name. |
| `properties` | The property of the full-text index. |
| `schema` | The schema of the full-text index. |
| `status` | Full-text index status, which can be `DONE` or `CREATING`. |

## Creating a Full-text Index

You can create a node or edge full-text index using the `create().node_fulltext()` or `create().edge_fulltext()` statement. Note that each property can only have one full-text index. The full-text index creation runs as a job, you may run `show().job(<id?>)` afterward to verify the success of the creation.

System properties in Ultipa are inherently optimized for query performance and include built-in efficiencies. They do not support full-text indexing.

<p tit="Syntax"></p>

```uql
// Creates a node full-text index
create().node_fulltext(@<schema>.<property>, "<fulltextName>")

// Creates an edge full-text index
create().edge_fulltext(@<schema>.<property>, "<fulltextName>")
```

<table>
  <thead>
    <tr>
      <th style="width:17%">Method</th>
      <th style="width:18%">Param</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan=3><code>node_fulltext()</code> or <code>edge_fulltext()</code></td>
      <td><code>@&lt;schema&gt;.&lt;property&gt;</code></td>
      <td>Specifies the <code>string</code> or <code>text</code> property and its schema.</td>
    </tr>
    <tr>
      <td><code>&lt;fulltextName&gt;</code></td>
      <td>The name of the full-text index. Naming conventions are:<br><ul><li>2 to 64 characters.</li><li>Begins with a letter.</li><li>Allowed characters: letters (A-Z, a-z), numbers (0-9) and underscores (<code>_</code>).</li></ul>Names must be unique among nodes and among edges, but a node full-text index and an edge full-text index may share the same name.</td>
    </tr>
  </tbody>
</table>

To create a full-text index named `prodDesc` for the property `description` of `product` nodes:

```uql
create().node_fulltext(@product.description, "prodDesc")
```

To create a full-text index named `review` for the property `content` of `review` edges:

```uql
create().edge_fulltext(@review.content, "review")
```

## Dropping a Full-text Index

You can drop a node or edge full-text index using the `drop().node_fulltext()` or `drop().edge_fulltext()` statement. Dropping a full-text index does not affect the actual property values stored in shards.

> A property with a full-text index cannot be dropped until the full-text index is deleted.

To drop the node full-text index `prodDesc`:

```uql
drop().node_fulltext("prodDesc")
```

To drop the edge full-text index `review`:

```uql
drop().edge_fulltext("review")
```

## Using Full-text Indexes

To use a full-text index in filters, use the syntax `{~<fulltextName> contains "<keyword1> <keyword2> ..."}`:

- The `~` symbol marks the full-text index.
- The operator `contains` checks if the segmented tokens in the full-text index include all the specified keywords.
- Multiple keywords should be separated by spaces. If a double quotation mark appears in a keyword, prefix it with a backslash (`\`) to escape.

There are two search modes for full-text indexes:

- **Precise search** matches exact tokens to keywords.
- **Fuzzy search** occurs when a keyword ends with an asterisk (`*`), matching tokens that begin with the keyword.

### Retrieving Nodes or Edges

To find nodes using the full-text index `prodDesc` where their tokens include "graph" and "database":

```uql
find().nodes({~prodDesc contains "graph database"}) as n
return n
```

To find nodes using the full-text index `prodDesc` where their tokens include "graph" or "database":

```uql
find().nodes({~prodDesc contains "graph" || ~prodDesc contains "database"}) as n
return n
```

To find edges using the full-text index `review` where their tokens include "graph" and those start with "ult":

```uql
find().edges({~review contains "graph ult*"}) as e
return e
```

### Retrieving Paths

Using the `ab()` query to find paths within 5 steps, with the full-text index `companyName` applied to both the source and destination nodes:

```uql
ab().src({~companyName contains "Sequoia*"}).dest({~companyName contains "Hillhouse*"}).depth(:5) as p
return p
```

**Note:** Full-text indexes only apply to the first node in a <a target="_blank" href="/docs/uqlpath-template">Path Template</a> or a <a target="_blank" href="/docs/uqlk-hop-template">K-Hop Template</a>  when retrieving paths.

For example, this query is not supported:

<p tit="UQL - Not supported"></p>

```uql
n().e().n({~prodDesc contains "graph"}) as p
return p
```

You may revise the query as follows:

```uql
find().nodes({~prodDesc contains "graph"}) as dest
n().e().n({_id == dest._id}) as p
return p
```

This query is not supported either:

<p tit="UQL - Not supported"></p>

```uql
n().e({~review contains "ult*"}).n() as p
return p
```

You may revise the query as follows:

```uql
find().edges({~review contains "ult*"}) as e
n().e({_uuid == e._uuid}).n() as p
return p
```
