# Full-text Index

## Overview

A full-text index is a type of index specialized for efficient searching for `string` or `text` properties, especially in large text fields like descriptions, comments, or articles.

Full-text indexes work by breaking down the text into smaller segments called tokens. When a query is performed, the search engine matches specified keywords against these tokens instead of the original full text, allowing for faster retrieval of relevant results. Full-text indexes support both precise and fuzzy matches.

## Showing Full-text Index

Retrieve all full-text indexes in the current graph:

```gql
SHOW FULLTEXT
```

Retrieve only node or edge full-text indexes:

```gql
SHOW NODE FULLTEXT
```

```gql
SHOW EDGE FULLTEXT
```

The result includes the following fields:

| <div table-width="15">Field</div> | Description |
| -- | -- |
| `index_name` | Full-text index name. |
| `entity_type` | `NODE` or `EDGE`. |
| `schema_name` | The label of the full-text index. |
| `properties` | The indexed properties. |
| `analyzer` | The text analyzer used. |
| `status` | Index status: `ready`, `loading`, or `building`. |
| `doc_count` | Number of documents indexed. |
| `progress` | Build/loading progress. |

## Creating Full-text Index

You can create a full-text index using the `CREATE FULLTEXT` statement. The index is built asynchronously, use `SHOW FULLTEXT` to check build progress.

<p tit="Syntax"></p>

```
<create full-text index statement> ::=
  "CREATE FULLTEXT" <index name> "ON" < "NODE" | "EDGE" > <label>
  "(" <property name> [ { "," <property name> }... ] ")"
```

**Details**

- The `<index name>` must be unique among nodes and among edges, but a node full-text index and an edge full-text index may share the same name.

Create a full-text index named `prodDesc` for the `description` property of `product` nodes:

```gql
CREATE FULLTEXT prodDesc ON NODE product (description)
```

Create a full-text index named `reviewText` for the `content` and `excerpt` properties of `review` edges:

```gql
CREATE FULLTEXT reviewText ON EDGE review (content, excerpt)
```

## Dropping Full-text Index

Dropping a full-text index does not affect the actual property values.

```gql
DROP NODE FULLTEXT prodDesc
```

```gql
DROP EDGE FULLTEXT reviewText
```

Use `IF EXISTS` to avoid errors when the index doesn't exist:

```gql
DROP NODE FULLTEXT IF EXISTS prodDesc
```

## Using Full-text Index

Use a full-text index in search conditions, use the syntax `~<fulltextIndexName> CONTAINS "<keywords>"`:

- The `~` symbol marks the full-text index.
- The operator `CONTAINS` checks if the segmented tokens in the full-text index match the query.
- Results are ranked by BM25 relevance score (highest relevance first).
- If a double quotation mark appears in a keyword, prefix it with a backslash (`\`) to escape.

### Query Syntax

By default, multiple keywords separated by spaces are combined with AND (all must match). Additional operators are supported within the `<keywords>` string:

| Operator | Syntax | Description |
| -- | -- | -- |
| AND (default) | `"graph database"` | Entries whose tokens include both `graph` and `database`. |
| OR | `"graph OR database"` | Entries whose tokens include `graph` or `database` (or both). |
| NOT | `"-graph"` | Entries whose tokens do not include `graph`. |
| Phrase | `"\"graph database\""` | Entries whose tokens include `graph` followed immediately by `database`. |
| Proximity | `"\"graph database\"~5"` | Entries whose tokens include both `graph` and `database` within 5 token positions of each other. |
| Wildcard | `"graph*"` | Entries whose tokens start with `graph` (e.g., `graph`, `graphics`, `graphdb`). |
| Wildcard | `"grap?"` | Entries whose tokens match with `?` as any single character (e.g., `graph`, `grape`). |
| Grouped | `"(graph OR network) AND database"` | Entries matching the combined sub-expressions; parentheses control precedence. |

### Retrieving Nodes or Edges

Find nodes using the full-text index `prodDesc` where their tokens include `graph` and `database`:

```gql
MATCH (n WHERE ~prodDesc CONTAINS "graph database")
RETURN n
```

Find nodes using the full-text index `prodDesc` where their tokens include `graph` or `database`:

```gql
MATCH (n WHERE ~prodDesc CONTAINS "graph OR database")
RETURN n
```

Find edges using the full-text index `reviewText` where their tokens include `graph` and those start with `ult`:

```gql
MATCH ()-[e WHERE ~reviewText CONTAINS "graph ult*"]-()
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
MATCH p = ()-[WHERE ~reviewText CONTAINS "ult*"]-()
RETURN p
```

You may revise the query as follows:

```gql
MATCH ()-[e WHERE ~reviewText CONTAINS "ult*"]-()
MATCH p = ()-[e]-()
RETURN p
```
