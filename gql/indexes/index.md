# Index

## Overview

**Indexing**, or **property indexing**, is a technique used to accelerate the retrieval of nodes and edges with specific properties. By avoiding full graph scans, indexes enable the database to quickly locate relevant data. This is especially advantageous when working with large graphs.

An index can be created on a single property, or on multiple properties of a label (a **composite index**).

## Showing Index

Retrieve indexes in the current graph:

```gql
SHOW INDEX
-- alias
SHOW INDEXES

-- All node-side / edge-side indexes
SHOW NODE INDEX
SHOW EDGE INDEX

-- Verbose form: adds the live_entry_count and build_skipped_sample columns
SHOW INDEX VERBOSE
```

The result includes the following fields:

| Field | Description |
| -- | -- |
| `index_name` | Index name. |
| `entity_type` | `NODE` or `EDGE`. |
| `label` | The label of the indexed property. |
| `property` | The indexed property name. For a composite index, the property tuple joined by commas (e.g. `lastName, firstName`). |
| `prefix_length` | For string/text properties, the maximum indexed length. `null` if not set. For a composite index with per-property lengths, a comma-joined list where `-` marks a full (unlimited) property (e.g. `10, -`); `null` if no property has a length. |
| `status` | Index status: `ready`, `building`, or `error`. |
| `progress` | Build progress (e.g., `100%`, `50.0% (500/1000)`). |
| `indexed_count` | Number of entries indexed. |
| `total_count` | Total number of entries to index. |
| `build_skipped` | Number of entries the build saw but could not index (e.g., an unreadable record). A non-zero value means the index is missing legitimate rows — drop and recreate the index after resolving the cause. |
| `propagation_failures` | Number of times a write (`INSERT` / `SET` / `DELETE` / label change) failed to update the index. A non-zero value indicates lost index updates. |
| `dangling_pointers` | Number of index entries that no longer resolve to a live node or edge (stale entries, excluded from results). A non-zero value suggests a rebuild. |
| `error` | Error message if the build failed. |
| `comment` | The index description. |
| `live_entry_count` | `VERBOSE` only. The actual entry count visible to queries, obtained by walking the index. Expensive on large indexes. |
| `build_skipped_sample` | `VERBOSE` only. A bounded sample of the entries counted in `build_skipped`, for triage. |

## Creating Index

You can create an index using the `CREATE INDEX` statement. The index is built asynchronously in the background, use `SHOW INDEX` to check build progress.

```syntax
<create index statement> ::=
  "CREATE INDEX" [ <index name> ] "ON" < "NODE" | "EDGE" > <label name>
  "(" <property spec> [ "," <property spec> ]... ")"

<property spec> ::= <property name> [ "(" <length> ")" ]
```

**Details**

- If the `<index name>` is omitted, the generated name joins all properties: `idx_<label>_<prop1>_<prop2>_…` (e.g. `idx_Person_lastName_firstName`), with a numeric suffix on collision.
- For `STRING` or `TEXT` properties, you can optionally specify `<length>` to limit the number of characters indexed per value. If omitted, the full string is indexed. See <a href="#String-Length-Limitation">String Length Limitation</a>.
- For a composite index:
  - The property order matters: `(lastName, firstName)` and `(firstName, lastName)` are different indexes.
  - A node or edge is indexed only if it has all the indexed properties. If any property value is missing or `null`, the entity is not indexed and queries on it fall back to a label scan.
  - One composite index is allowed per exact property tuple on a label. A different tuple, including a prefix like `(lastName)` or a longer `(lastName, firstName, age)`, is a distinct index and can coexist. A property cannot appear twice in the same list.

```gql
-- Index on balance of card nodes
-- Index name auto-generated as idx_card_balance
CREATE INDEX ON NODE card (balance)

-- Index on name (STRING-type) of card nodes, limiting the indexed length to 10 characters
CREATE INDEX name ON NODE card (name(10))

-- Named index on amount of transfer edges
CREATE INDEX transAmount ON EDGE transfer (amount)
```

A **composite index** covers two or more properties of a label as an ordered tuple. It serves queries that filter or sort on those properties together, and can replace intersecting several single-property indexes.

List the properties in order inside the parentheses. Each property may carry its own `STRING`/`TEXT` length limit:

```gql
-- Composite index on (lastName, firstName) of Person nodes
-- Index name auto-generated as idx_Person_lastName_firstName
CREATE INDEX ON NODE Person (lastName, firstName)

-- Named composite index with a per-property length limit on the first property
CREATE INDEX fullName ON NODE Person (lastName(20), firstName)
```

For which queries a composite index accelerates, see <a href="#Leftmost-Prefix-Matching">Leftmost-Prefix Matching</a> and <a href="#Ordering-and-Grouping">Ordering and Grouping</a> under Using Indexes.

## Renaming Index

Rename an index:

```gql
ALTER INDEX idx_card_balance RENAME TO idx_card_bal
```

## Commenting Index

Attach a descriptive comment:

```gql
ALTER INDEX idx_card_balance COMMENT 'Hot-path lookup for fraud scoring'
```

## Rebuilding Index

Rebuild a property index from the current data:

```gql
ALTER INDEX idx_card_balance REBUILD
```

Rebuilding is a **recovery action, not routine maintenance**. Property indexes are maintained incrementally on every write, so ordinary data changes keep them in sync automatically. Rebuild only when an index has drifted from the data, which the database surfaces in two ways:

- A non-zero health column in `SHOW INDEX` → `build_skipped`, `propagation_failures`, or `dangling_pointers`, or a `status` of `error`.
- The `property_index_drift` check in `db.validate_graph()` flags the index.

Typical causes are a crash mid-write, an IO error, schema-version drift, or a compaction race that left an undecodable record. A crash mid-rebuild is handled automatically at startup, so it needs no manual action.

## Dropping Index

Dropping an index does not affect the actual property values.

```gql
DROP INDEX idx_card_balance

-- You can also specify NODE or EDGE explicitly
DROP NODE INDEX idx_card_balance
DROP EDGE INDEX transAmountNotes
```

Use `IF EXISTS` to avoid errors when the index doesn't exist:

```gql
DROP INDEX IF EXISTS idx_card_balance
```

## Using Indexes

### Applicable Queries

Indexes accelerate the following types of queries:

| Query Type | Example |
| -- | -- |
| Exact match | `WHERE p.name = 'Alice'` |
| Range queries | `WHERE p.age > 25`, `WHERE p.age >= 20 AND p.age < 40` |
| Prefix search | `WHERE p.name STARTS WITH 'Al'` |

**Exact match:**

```gql
MATCH (p:Person WHERE p.name = 'Alice')
RETURN p
```

**Range queries:**

```gql
MATCH ()-[e:Links WHERE e.weight > 5]->()
RETURN e
```

**Prefix search:**

```gql
MATCH (p:Person WHERE p.name STARTS WITH 'Al')
RETURN p.name
```

### Leftmost-Prefix Matching

A composite index on `(a, b, c)` serves a query that constrains a **leftmost prefix** of its properties: equality on the leading properties, optionally followed by a single range or `STARTS WITH` on the next property. Any condition the index does not cover is re-applied to the candidate rows.

Assuming an index on `(a, b, c)`:

| Query condition | Uses the index? |
| -- | -- |
| `a = X` | Yes, on `a` |
| `a = X AND b = Y` | Yes, on `a, b` |
| `a = X AND b = Y AND c = Z` | Yes, full tuple |
| `a = X AND b STARTS WITH 'Sm'` | Yes, equality on `a`, prefix on `b` |
| `a = X AND b > 5` | Yes, equality on `a`, range on `b` (properties after a range are not used) |
| `a = X AND c = Z` | Partially, on `a` only (`c` is applied as a filter) |
| `b = Y AND c = Z` (skips leading `a`) | No, falls back to a label scan |

### Ordering and Grouping

A composite index also accelerates `ORDER BY` and `GROUP BY` on a leftmost prefix of its properties, avoiding a separate sort or grouping pass. This requires the index to cover every node or edge of the label (no rows missing due to a null property).

```gql
-- Ordered walk straight off the (lastName, firstName) index, no sort step
MATCH (n:Person)
RETURN n.lastName, n.firstName
ORDER BY n.lastName, n.firstName

-- Grouped counts read directly from the index
MATCH (n:Person)
RETURN n.lastName, COUNT(*)
GROUP BY n.lastName
```

All `ORDER BY` properties must share the same direction (all ascending or all descending). A mixed-direction order (e.g. `ORDER BY n.lastName ASC, n.firstName DESC`) falls back to a sort.

### String Length Limitation

When a length limit `N` is specified for a string index, the index stores only the first `N` characters of each value. Queries that filter by a string longer than the limit won't match in the index.

For example, an index `Username` is created for the `name` property of `user` nodes with an 8-character limit:

```gql
CREATE INDEX Username ON NODE user (name(8))
```

The query below won't utilize the `Username` index because `"Aventurine"` (10 characters) exceeds the 8-character limit:

```gql
MATCH (n:user {name: "Aventurine"})
RETURN n
```

Queries with strings of 8 characters or fewer will use the index:

```gql
MATCH (n:user {name: "Kavi"})
RETURN n
```
