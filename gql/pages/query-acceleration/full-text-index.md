# Full-text Index

## Overview

A full-text index is a type of index specialized for efficient searching for `string` or `text` properties, especially in large text fields like descriptions, comments, or articles.

Full-text indexes work by breaking down the text into smaller segments called tokens. When a query is performed, the search engine matches specified keywords against these tokens instead of the original full text, allowing for faster retrieval of relevant results.

Ultipa's full-text search engine provides BM25 relevance scoring, fuzzy search, phrase search, boolean queries, and Chinese text support.

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
CREATE FULLTEXT prodDesc ON NODE product (description)
```

To create a full-text index named `review` for the property `content` of `review` edges:

```gql
CREATE FULLTEXT review ON EDGE review (content)
```

### Multi-Schema Full-text Index

A full-text index can span multiple schemas, enabling unified search across different node or edge types with results ranked by a single relevance score.

**Shared properties** — all schemas use the same property list:

```gql
CREATE FULLTEXT search_name ON NODE movie|account (name)
```

**Per-schema properties** — each schema specifies its own properties:

```gql
CREATE FULLTEXT unified_search ON NODE movie(title)|account(name)
```

You can also combine multiple schemas with multiple properties:

```gql
CREATE FULLTEXT global_search ON NODE movie(title, director)|account(name, industry)|book(title, author)
```

Multi-schema full-text indexes for edges follow the same syntax:

```gql
CREATE FULLTEXT rel_search ON EDGE knows(project)|works_with(title, department)
```

> The shared-property syntax and per-schema-property syntax cannot be mixed in the same statement.

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

To use a full-text index in the search conditions, use the syntax `~<fulltextName> CONTAINS '<query>'`:

- The `~` symbol marks the full-text index.
- The operator `CONTAINS` checks if the segmented tokens in the full-text index match the query.

### Basic Search

To find nodes where tokens include "graph" and "database":

```gql
MATCH (n WHERE ~prodDesc CONTAINS 'graph database')
RETURN n
```

### BM25 Relevance Scoring

Use the `score()` function to retrieve BM25 relevance scores for full-text search results:

```gql
MATCH (n:doc WHERE ~ft_content CONTAINS 'graph database')
RETURN n._id, score(n) AS relevance
ORDER BY relevance DESC
```

The `score()` function works for both node and edge full-text searches:

```gql
MATCH ()-[e:cites WHERE ~ft_note CONTAINS 'important']->()
RETURN e, score(e) AS relevance
```

### Fuzzy Search

Append `~` followed by an edit distance to a keyword for fuzzy matching:

```gql
// Edit distance 1: matches "grpah", "grph", etc.
MATCH (n:doc WHERE ~ft_content CONTAINS 'graph~1') RETURN n

// Edit distance 2 (default when ~ has no number)
MATCH (n:doc WHERE ~ft_content CONTAINS 'graph~') RETURN n
```

### Phrase Search

Enclose keywords in double quotes for exact phrase matching:

```gql
MATCH (n:doc WHERE ~ft_content CONTAINS '"graph database"') RETURN n
```

### Boolean Queries

Use boolean operators to combine search terms:

```gql
// AND — both terms must match
MATCH (n:doc WHERE ~ft_content CONTAINS 'graph AND database') RETURN n

// OR — either term matches
MATCH (n:doc WHERE ~ft_content CONTAINS 'graph OR tree') RETURN n

// NOT — exclude a term
MATCH (n:doc WHERE ~ft_content CONTAINS 'graph NOT tree') RETURN n

// +/- operators — require or exclude terms
MATCH (n:doc WHERE ~ft_content CONTAINS '+graph -tree') RETURN n
```

### Chinese Text Support

Chinese text is automatically tokenized using the Jieba tokenizer:

```gql
MATCH (n:doc WHERE ~ft_content CONTAINS '图数据库') RETURN n
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

## Configuration

Add the following section to `shard-server.config` to configure the full-text search engine:

```ini
[Fulltext]
engine = tantivy
tantivy_memory_mb = 64
```

| <div table-width="25">Parameter</div> | Default | Hot-Updatable | Description |
| -- | -- | -- | -- |
| `engine` | `tantivy` | Yes | Full-text search engine. |
| `tantivy_memory_mb` | `64` | Yes | Writer memory limit in MB (minimum 16). |

## Limitations

- Full-text index updates are applied immediately and are not transactional. An INSERT within a transaction is visible in full-text search before COMMIT, and ROLLBACK does not undo the full-text index entries.
- Edge full-text queries with named endpoints (e.g., `MATCH (a)-[e:schema WHERE ~idx CONTAINS 'x']->(b)`) may produce errors. Use anonymous endpoints instead: `MATCH ()-[e:schema WHERE ~idx CONTAINS 'x']->()`.
- The `score()` function must be used directly in the `RETURN` clause. Using it in a `WITH` pipeline (e.g., `WITH n, score(n) AS s WHERE s > 0.5`) is not supported.
