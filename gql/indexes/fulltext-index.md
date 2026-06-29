# Full-text Index

## Overview

A full-text index is a type of index specialized for efficient searching for textual properties, especially in large text fields like descriptions, comments, or articles.

Full-text indexes work by breaking down the text into smaller segments called **tokens**. When a query is performed, the search engine matches specified keywords against these tokens instead of the original full text, allowing for faster retrieval of relevant results. Full-text indexes support both precise and fuzzy matches.

### Analyzers

An analyzer determines how text is broken into tokens, normalized (lower-casing, stemming, stop-word removal), and segmented (especially for CJK - Chinese, Japanese, Korean - text, which is written without whitespace between words). The analyzer is fixed at index-creation time; the same analyzer is applied to both indexed text and query terms, so they tokenize consistently.

| Analyzer | Tokenization | Best for |
| -- | -- | -- |
| `mixed` | **Default.** Auto-detects language per segment: simple tokenization + Porter stemming + stop-word removal for English, GSE word-segmentation for CJK. | Mixed-language content (English + Chinese in the same field). The safe default. `pipeline` is a synonym. |
| `simple` | Whitespace + punctuation split, lower-cased. No stemming, no stop-word removal. | Identifiers, codes, or exact-form English where stemming would cause false matches (e.g., a search for 'run' shouldn't hit a SKU literally named 'running'; under the default analyzer the Porter stemmer collapses both to the same token). |
| `cjk` | Bigram tokenization for CJK characters; falls back to simple for non-CJK. | CJK-only content where the GSE dictionary is undesirable. |
| `gse` | GSE word-segmentation. Honors `gseMode` for segmentation aggressiveness. | Chinese-heavy content where dictionary-based word segmentation is required. |

The `gseMode` option (`mixed` and `gse` analyzers only) controls how aggressively GSE segments Chinese text:

| `gseMode` | Behavior |
| -- | -- |
| `precise` | **Default.** Single best segmentation. `北京大学` → `["北京大学"]`. Fewer, more specific tokens. |
| `search` | Search-oriented overlapping segments. `北京大学` → `["北京", "大学", "北京大学"]`. Recall-friendly. |
| `full` | Every possible segmentation. Maximum recall, larger index. |

To preview how a given analyzer tokenizes a string, use the [`ft.analyze` procedure](#ft-analyze).

### Relevance Scoring (BM25)

Once a query's tokens are matched against the index, **BM25** (Best Matching 25) ranks the hits, where higher score means more relevant. It blends three signals per query term:

- **Term frequency:** how often the term appears in the document (with saturation, so the 50th occurrence adds less than the 2nd).
- **Inverse document frequency:** how rare the term is across all indexed documents. Rare terms score higher.
- **Length normalization:** long documents are penalized so they don't win by size alone.

When an index covers multiple properties, **each property contributes its own BM25 score** and the `weight_<property>` option is a multiplier on that contribution. For example, `OPTIONS { weight_p1: 3.0, weight_p2: 1.0 }`, then weighted BM25 score is computed by `3.0 * BM25(p1, query) + 1.0 * BM25(p2, query)`. So it makes a match in `p1` count for 3× a match in `p2`. Weights default to `1.0` (all properties treated equally).

## Showing Full-text Index

Retrieve full-text indexes in the current graph:

```gql
SHOW FULLTEXT

-- Filtered by entity type
SHOW NODE FULLTEXT
SHOW EDGE FULLTEXT
```

The result includes the following fields:

| Field | Description |
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

```syntax
<create full-text index statement> ::=
  "CREATE FULLTEXT" <index name> "ON" < "NODE" | "EDGE" > <label name>
  "(" <property> [ { "," <property> }... ] ")"
  [ "OPTIONS" "{" <option> [ { "," <option> }... ] "}" ]

<option> ::= 
    "analyzer:" <analyzer name>
  | "gseMode:" <gse mode>
  | "weight_" <property> ":" <positive number>
```

**Details**

- The `<index name>` must be unique among nodes and among edges, but a node full-text index and an edge full-text index may share the same name.
- The optional `OPTIONS` clause tunes tokenization and ranking:

| Option | Default | Description |
| -- | -- | -- |
| `analyzer` | `mixed` | One of `mixed`, `simple`, `cjk`, `gse`. (`pipeline` is accepted as an alias for `mixed`.) See [Analyzers](#Analyzers). |
| `gseMode` | `precise` | One of `precise`, `search`, `full`. Applies to the `gse` and `mixed` analyzers. See [Analyzers](#Analyzers). |
| `weight_<property>` | `1.0` | Per-property [BM25](#Relevance-Scoring-BM25) weight for indexes covering multiple properties. Use to bias scoring. |

```gql
-- Full-text index prodDesc on product nodes' description
CREATE FULLTEXT prodDesc ON NODE product (description)

-- Full-text index reviewText on review edges' content and excerpt
CREATE FULLTEXT reviewText ON EDGE review (content, excerpt)

-- English-only index, no stemming
CREATE FULLTEXT skuCode ON NODE product (sku) OPTIONS { analyzer: 'simple' }

-- Chinese-only, recall-oriented segmentation
CREATE FULLTEXT zhArticle ON NODE article (body) OPTIONS { analyzer: 'gse', gseMode: 'search' }

-- Multi-property index, title weighted 3× over body in BM25 scoring
CREATE FULLTEXT articleText ON NODE article (title, body)
  OPTIONS { weight_title: 3.0, weight_body: 1.0 }
```

## Dropping Full-text Index

Dropping a full-text index does not affect the actual property values. Full-text index names are unique within a graph, so the `NODE` / `EDGE` qualifier is optional on `DROP`:

```gql
-- Unqualified form (recommended)
DROP FULLTEXT prodDesc

-- Qualified forms
DROP NODE FULLTEXT prodDesc
DROP EDGE FULLTEXT reviewText
```

Use `IF EXISTS` to avoid errors when the index doesn't exist:

```gql
DROP FULLTEXT IF EXISTS prodDesc
```

## Using Full-text Index

Use a full-text index in search conditions with the syntax `WHERE ~<index name> CONTAINS "<search>"`:

- The `~` symbol marks the full-text index.
- The operator `CONTAINS` checks if the segmented tokens in the full-text index match the query.
- Results are ranked by BM25 relevance score (highest relevance first).
- If a double quotation mark appears in a keyword, prefix it with a backslash (`\`) to escape.

### Search Syntax

By default, multiple keywords separated by spaces are combined with AND (all must match). Additional operators are supported within the `<search>` string:

| Operator | Syntax | Description |
| -- | -- | -- |
| AND | `"graph database"` | **Default.** Entries whose tokens include both `graph` and `database`. |
| OR | `"graph OR database"` | Entries whose tokens include `graph` or `database` (or both). |
| NOT | `"-graph"` | Entries whose tokens do not include `graph`. |
| Phrase | `"\"graph database\""` | Entries whose tokens include `graph` followed immediately by `database`. |
| Proximity | `"\"graph database\"~5"` | Entries whose tokens include both `graph` and `database` within 5 token positions of each other. |
| Wildcard | `"graph*"` | Entries whose tokens start with `graph` (e.g., `graph`, `graphics`, `graphdb`). |
| Wildcard | `"grap?"` | Entries whose tokens match with `?` as any single character (e.g., `graph`, `grape`). |
| Fuzzy | `"graph~2"` | Entries whose tokens are within `N` character edits of the term (default `N=2`). Catches typos — `"graph~2"` matches `grph`, `garph`, `graphs`. |
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

**Note:** In path-returning queries, putting the inline form on the first node is the only supported placement.

```gql
MATCH p = (WHERE ~prodDesc CONTAINS "graph")-[]-(n)
RETURN p
```

To filter on any other element, run the full-text match in its own `MATCH` first, then build the path from the bound variable:

```gql
-- ✗ not supported; uses full-text index on the last node
MATCH p = ()-[]-(WHERE ~prodDesc CONTAINS "graph") 
RETURN p

-- ✓ run the full-text match in its own MATCH first
MATCH (n WHERE ~prodDesc CONTAINS "graph")
MATCH p = ()-[]-(n)
RETURN p

-- ✗ not supported; uses full-text index on the edge
MATCH p = ()-[WHERE ~reviewText CONTAINS "ult*"]-()
RETURN p

-- ✓ run the full-text match in its own MATCH first
MATCH ()-[e WHERE ~reviewText CONTAINS "ult*"]-()
MATCH p = ()-[e]-()
RETURN p
```

## Procedures

### ft.search

The `WHERE ~<index name> CONTAINS "<search>"` form above is convenient as an inline filter inside `MATCH`, but for **top-N ranked retrieval** the `ft.search` procedure is the preferred entry point. It runs a BM25-ranked search over a named full-text index, and yields each matching node with its relevance score.

```syntax
CALL ft.search(<index name>, <search> [ , <options> ]) 
YIELD <column1>, <column2>, ...
```

**Parameters**:

<table style="width: 100%;">
  <colgroup>
    <col style="width:14%;">
    <col style="width:13%;">
    <col style="width:12%;">
    <col style="width:11%;">
    <col>
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Parameter</th>
      <th>Type</th>
      <th>Default</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td colspan="2"><code>&lt;index name&gt;</code></td>
      <td><code>STRING</code></td>
      <td>—</td>
      <td>Name of a full-text index.</td>
    </tr>
    <tr>
      <td colspan="2"><code>&lt;search&gt;</code></td>
      <td><code>STRING</code></td>
      <td>—</td>
      <td>The search string. Same syntax as the inline <code>CONTAINS</code> form, see <a href="#Search-Syntax">Search Syntax</a>.</td>
    </tr>
    <tr>
      <td rowspan="4"><code>&lt;options&gt;</code><br><code>MAP</code></td>
      <td><code>limit</code></td>
      <td><code>INTEGER</code></td>
      <td><code>10</code></td>
      <td>Maximum number of ranked results to return.</td>
    </tr>
    <tr>
      <td><code>offset</code></td>
      <td><code>INTEGER</code></td>
      <td><code>0</code></td>
      <td>Number of top-ranked results to skip (pagination).</td>
    </tr>
    <tr>
      <td><code>minScore</code></td>
      <td><code>FLOAT</code></td>
      <td><code>0</code></td>
      <td>Drop results whose BM25 score is below this floor.</td>
    </tr>
    <tr>
      <td><code>highlight</code></td>
      <td><code>MAP</code></td>
      <td>(off)</td>
      <td>
        Returns an additional <code>highlight</code> column containing a snippet of the matching text with the matched tokens wrapped in tags. Use it for search-result UIs, snippet previews, or to confirm visually which tokens the engine matched.
        <br><br>
        Nested keys:
        <ul style="margin: 4px 0;">
          <li><code>field</code>: <b>required</b>; the indexed property to extract the snippet from. Highlighting is off unless this is set.</li>
          <li><code>preTag</code>: default <code>&lt;em&gt;</code>; inserted immediately before each matched token.</li>
          <li><code>postTag</code>: default <code>&lt;/em&gt;</code>; inserted immediately after each matched token.</li>
          <li><code>fragmentSize</code>: approximate snippet length in characters; controls how much surrounding context is shown.</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

**Return columns**:

| Column | Type | Description |
| -- | -- | -- |
| `node` | `NODE` | The matching node, bindable downstream. |
| `score` | `FLOAT` | BM25 relevance score; higher is more relevant. |
| `id` | `STRING` | The matching node's `_id`. |
| `highlight` | `STRING` | Highlighted fragment from the field named in `highlight.field`. Present only when highlighting is enabled. |

```gql
-- Top 10 ranked results
CALL ft.search('prodDesc', 'graph database') YIELD node, score
RETURN node, score ORDER BY score DESC

-- Paginated with relevance floor
CALL ft.search('prodDesc', 'graph database', {limit: 20, offset: 20, minScore: 0.5})
YIELD node, score
RETURN node.name, score

-- Phrase and exclusion
CALL ft.search('prodDesc', '"graph database" -deprecated', {limit: 10})
YIELD node, score
RETURN node, score

-- Search then traverse
CALL ft.search('prodDesc', 'graph database', {limit: 5}) YIELD node, score
MATCH (node)-[:WROTE]-(a:Author)
RETURN node.title, score, collect(a.name) AS authors
ORDER BY score DESC

-- With highlighted snippet
CALL ft.search('prodDesc', 'graph database',
               {limit: 5,
                highlight: {field: 'description', preTag: '<mark>', postTag: '</mark>', fragmentSize: 150}})
YIELD node, score, highlight
RETURN node._id, score, highlight
```

### ft.analyze

Tokenizes a string with a named analyzer and returns the resulting tokens with their positions. Use this to debug why a query term does or doesn't match indexed text. Common causes are stemming ('Running' → 'run'), stop-word removal ('the' dropped), or CJK segmentation that differs from what you expected.

```syntax
CALL ft.analyze(<analyzer>, <text>)
YIELD <column1>, <column2>, ...
```

**Parameters**:

| Parameter | Type | Description |
| -- | -- | -- |
| `<analyzer>` | `STRING` | One of `mixed`, `simple`, `cjk`, `gse`. (`pipeline` is accepted as an alias for `mixed`.) |
| `<text>` | `STRING` | Text to tokenize. Empty string yields zero rows. |

**Return columns**:

| Column | Type | Description |
| -- | -- | -- |
| `token` | `STRING` | A normalized token (after lower-casing, stemming, CJK segmentation). |
| `position` | `INTEGER` | 0-based token position in the text. |

```gql
-- English stemming under the default analyzer
CALL ft.analyze('mixed', 'Running graphs') YIELD token, position
RETURN token, position

-- Same input, no stemming
CALL ft.analyze('simple', 'Running graphs') YIELD token
RETURN token

-- CJK segmentation
CALL ft.analyze('mixed', '北京大学') YIELD token, position
RETURN token, position
```

### ft.suggest

Returns indexed terms that start with a given prefix, most frequent first. Suggestions come from the index's term dictionary, so they reflect the analyzed (lower-cased, stemmed, segmented) forms actually stored. A typical search box uses `ft.suggest` for the autocomplete dropdown to complete the word a user is typing.

```syntax
CALL ft.suggest(<index name>, <prefix> [ , <options> ])
YIELD <column1>, <column2>, ...
```

**Parameters**:

| Parameter | Type | Description |
| -- | -- | -- |
| `<index name>` | `STRING` | Name of a full-text index. |
| `<prefix>` | `STRING` | The partial term typed so far. It is lower-cased to match indexed terms; an empty string returns the most frequent terms. |
| `<options>` | `RECORD` | Optional. `{limit: <n>}` caps the number of suggestions (default `10`, minimum `1`). |

**Return columns**:

| Column | Type | Description |
| -- | -- | -- |
| `suggestion` | `STRING` | A matching indexed term. |
| `docFreq` | `INTEGER` | Number of documents containing the term (popularity). |

```gql
-- Autocomplete: terms starting with 'grap', most popular first
CALL ft.suggest('prodDesc', 'grap', {limit: 5}) YIELD suggestion, docFreq
RETURN suggestion ORDER BY docFreq DESC

-- Works script-agnostically: a CJK prefix returns the segmented terms that start with it
CALL ft.suggest('zhDesc', '社', {limit: 5}) YIELD suggestion, docFreq
RETURN suggestion ORDER BY docFreq DESC
```
