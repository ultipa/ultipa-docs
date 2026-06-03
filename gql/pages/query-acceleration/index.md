# Index

## Overview

**Indexing**, or **property indexing**, is a technique used to accelerate the retrieval of nodes and edges with specific properties. By avoiding full graph scans, indexes enable the database to quickly locate relevant data. This is especially advantageous when working with large graphs.

An index is created on a single property of a label.

## Showing Index

Retrieve indexes in the current graph:

```gql
SHOW INDEX
SHOW NODE INDEX
SHOW EDGE INDEX
```

The result includes the following fields:

| <div table-width="15">Field</div> | Description |
| -- | -- |
| `index_name` | Index name. |
| `entity_type` | `NODE` or `EDGE`. |
| `label` | The label of the indexed property. |
| `property` | The indexed property name. |
| `prefix_length` | For string/text properties, the maximum indexed byte length. `null` if not set. |
| `status` | Index status: `ready`, `building`, or `error`. |
| `progress` | Build progress (e.g., `100%`, `50.0% (500/1000)`). |
| `indexed_count` | Number of entries indexed. |
| `total_count` | Total number of entries to index. |
| `error` | Error message if the build failed. |

## Creating Index

You can create an index using the `CREATE INDEX` statement. The index is built asynchronously in the background, use `SHOW INDEX` to check build progress.

<p tit="Syntax"></p>

```
<create index statement> ::=
  "CREATE INDEX" [ <index name> ] "ON" < "NODE" | "EDGE" > <label name>
  "(" <property name> [ "(" <length> ")" ] ")"
```

**Details**

- The `<index name>` is optional. If omitted, the system assigns a generated name of the form `idx_<label>_<property>` (e.g., `CREATE INDEX ON NODE card (balance)` yields `idx_card_balance`). If that name is already taken, a numeric suffix is appended (`idx_card_balance_2`, `_3`, …) so repeated unnamed creates on the same column don't collide.
- For `STRING` or `TEXT` properties, you can optionally specify `<length>` to limit the number of characters indexed per value. If omitted, the full string is indexed. See <a href="#String-Length-Limitation">String Length Limitation</a>.

```gql
-- Index for the balance property of card nodes
-- Index name auto-generated as idx_card_balance
CREATE INDEX ON NODE card (balance)

-- Index for the STRING-type property name of card nodes, limiting the indexed length to 10 characters
CREATE INDEX name ON NODE card (name(10))

-- Index transAmount for the amount property of transfer edges
CREATE INDEX transAmount ON EDGE transfer (amount)
```

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
