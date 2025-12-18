# Full-text Index

## Overview

A full-text index is a type of index specialized for efficient searching for `string` or `text` properties, especially in large text fields like descriptions, comments, or articles.

Full-text indexes work by breaking down the text into smaller segments called tokens. When a query is performed, the search engine matches specified keywords against these tokens instead of the original full text, allowing for faster retrieval of relevant results. Full-text indexes support both precise and fuzzy matches.

## Showing Full-text Indexes

To retrieve node full-text indexes in the current graph:

```gql
SHOW NODE FULLTEXT
```

To retrieve edge full-text indexes in the current graph:

```gql
SHOW EDGE FULLTEXT
```

The information about full-text indexes is organized into the `_nodeFulltext` or `_edgeFulltext` table with the following fields:

| <div table-width="15">Field</div> | Description |
| -- | -- |
| `name` | Full-text index name. |
| `properties` | The property of the full-text index. |
| `schema` | The schema of the full-text index. |
| `status` | Full-text index status, which can be `DONE` or `CREATING`. |

## Creating a Full-text Index

You can create a full-text index using the `CREATE FULLTEXT` statement. Note that each property can only have one full-text index. The full-text index creation runs as a job, you may run `SHOW JOB <id?>` afterward to verify the success of the creation.

System properties in Ultipa are inherently optimized for query performance and have built-in efficiencies. They do not support full-text indexing.

<p tit="Syntax"></p>

```gql
<create full-text index statement> ::=
  "CREATE FULLTEXT" <full-text index name> "ON" < "NODE" | "EDGE" > <schema name> "(" <property name> ")"
```

**Details**

- The `<full-text index name>` must be unique among nodes and among edges, but a node full-text index and an edge full-text index may share the same name. Naming conventions are:
  - 2 to 64 characters.
  - Begins with a letter.
  - Allowed characters: letters (A-Z, a-z), numbers (0-9) and underscores (<code>_</code>).

To create a full-text index named `prodDesc` for the property `description` of `product` nodes:

```gql
CREATE FULLTEXT prodDesc on NODE product (description)
```

To create a full-text index named `review` for the property `content` of `review` edges:

```gql
CREATE FULLTEXT review on EDGE review (content)
```

## Dropping a Full-text Index

You can drop a full-text index using the `DROP NODE FULLTEXT` or `DROP EDGE FULLTEXT` statement. Dropping a full-text index does not affect the actual property values stored in shards. 

> A property with a full-text index cannot be dropped until the full-text index is deleted.

To drop the node full-text index `prodDesc`:

```gql
DROP NODE FULLTEXT prodDesc
```

To drop the edge full-text index `review`:

```gql
DROP EDGE FULLTEXT review
```

## Using Full-text Indexes

To use a full-text index in the search conditions, use the syntax `~<fulltextName> CONTAINS "<keyword1> <keyword2> ..."`:

- The `~` symbol marks the full-text index.
- The operator `CONTAINS` checks if the segmented tokens in the full-text index include all the specified keywords.
- Multiple keywords should be separated by spaces. If a double quotation mark appears in a keyword, prefix it with a backslash (`\`) to escape.

There are two search modes for full-text indexes:

- **Precise search** matches exact tokens to keywords.
- **Fuzzy search** occurs when a keyword ends with an asterisk (`*`), matching tokens that begin with the keyword.

### Retrieving Nodes or Edges

To find nodes using the full-text index `prodDesc` where their tokens include "graph" and "database":

```gql
MATCH (n WHERE ~prodDesc CONTAINS "graph database")
RETURN n
```

To find nodes using the full-text index `prodDesc` where their tokens include "graph" or "database":

```gql
MATCH (n WHERE ~prodDesc CONTAINS "graph" OR ~prodDesc contains "database")
RETURN n
```

To find edges using the full-text index `review` where their tokens include "graph" and those start with "ult":

```gql
MATCH ()-[e WHERE ~review CONTAINS "graph ult*"]-()
RETURN e
```

### Retrieving Paths

**Note:** Full-text indexes only apply to the first node in a path pattern when retrieving paths. 

For example, this query is not supported:

<p tit="GQL - Not supported"></p>

```gql
MATCH p = ()-[]-(WHERE ~prodDesc CONTAINS "graph")
RETURN p
```

You may revise the query as follows:

```gql
MATCH (n WHERE ~prodDesc CONTAINS "graph")
MATCH p = ()-[]-(n)
RETURN p
```

This query is not supported either:

<p tit="GQL - Not supported"></p>

```gql
MATCH p = ()-[WHERE ~review CONTAINS "ult*"]-()
RETURN p
```

You may revise the query as follows:

```gql
MATCH ()-[e WHERE ~review CONTAINS "ult*"]-()
MATCH p = ()-[e]-()
RETURN p
```
