# Index

## Overview

**Indexing**, or **property indexing**, is a technique used in Ultipa to accelerate the retrieval of nodes and edges with specific properties. By avoiding full graph scans, indexes enable the database to quickly locate relevant data. This is especially advantageous when working with large graphs.

### Index Types

Ultipa supports **single index** on one property, **composite index** which involve multiple properties from a schema, and **expression index** on computed expressions of properties.

## Showing Indexes

To retrieve node indexes in the current graph:

```gql
SHOW NODE INDEX
```

To retrieve edge indexes in the current graph:

```gql
SHOW EDGE INDEX
```

The information about indexes is organized into the `_nodeIndex` or `_edgeIndex` table with the following fields:

| <div table-width="15">Field</div> | Description |
| -- | -- |
| `id` | Index id. |
| `name` | Index name. |
| `properties` | The properties involved in the index. |
| `schema` | The schema of the properties involved in the index. |
| `status` | Index status, which can be `DONE` or `CREATING`. |

## Creating an Index

You can create an index using the `CREATE INDEX` statement. Note that each property can only have one single index. The index creation runs as a job, you may run `SHOW JOB <id?>` afterward to verify the success of the creation.

System properties in Ultipa are inherently optimized for query performance and have built-in efficiencies. They do not support indexing.

<p tit="Syntax"></p>

```gql
<create index statement> ::=
  "CREATE INDEX" <index name> "ON" < "NODE" | "EDGE" > <schema name>
  "(" <property index item> [ { "," <property index item> }... ] ")"

<property index item> ::=
  <property name> [ "(" <bytes> ")" ]
```

**Details**

- The `<index name>` must be unique among nodes and among edges, but a node index and an edge index may share the same name.
- For a <b>single index</b>, specifies one `<property index item>`; for a <b>composite index</b>, lists multiple `<property index item>`.
- If a specified property is of type `string` or `text`, you can specify the maximum number of **bytes** <sup>[1]</sup> (count from left) to be indexed for each value. If omitted, the default indexing length is `1024` bytes for `string` and `2048` bytes for `text`. Learn more about <a href="#String-Byte-Length-Limitation">how this byte-length limitation affects queries</a>.

<sup>[1]</sup> In standard English text, most encodings (such as ASCII or UTF-8) use 1 byte per character. However, for non-English characters, the byte size may vary—for example, one Chinese character typically occupies 3 bytes.

To create single index named `cBalance` for the property `balance` of `card` nodes:

```gql
CREATE INDEX cBalance ON NODE card (balance)
```

To create single index named `name` for the property `name` (`string` type) of `card` nodes, restricting the indexed byte-length as `10`:

```gql
CREATE INDEX name ON NODE card (name(10))
```

To create composite index named `transAmountNotes` for properties `amount` and `notes` (`text` type, restricting the indexed byte-length as `10`) for `transfer` edges:

```gql
CREATE INDEX transAmountNotes ON EDGE transfer (amount, notes(10))
```

## Dropping an Index

You can drop an index using the `DROP NODE INDEX` or `DROP EDGE INDEX` statement. Dropping an index does not affect the actual property values stored in shards. 

> A property with an index cannot be dropped until the index is deleted.

To drop the node index `cBalance`:

```gql
DROP NODE INDEX cBalance
```

To drop the edge index `transAmountNotes`:

```gql
DROP EDGE INDEX transAmountNotes
```

## Using Indexes

### Applicable Queries

Indexes are automatically applied when the corresponding properties are used in the following types of queries. They are not effective in other types of queries.

**1. Node retrieval using a single node pattern.** For example, 

```gql
CREATE INDEX user_age_index ON NODE user (age)
```

The `user_age_index` is effective in the following queries:

```gql
MATCH (n:user {age: 45}) RETURN n
```

```gql
MATCH (n) WHERE n.age > 45 RETURN n
```

In the second query, the node label is not specified, so `user_age_index` is only partially used during the search for `user` nodes.

**2. Edge retrieval using a one-step path pattern.** For example, 

```gql
CREATE INDEX links_weight_index ON EDGE links (weight)
```

The `links_weight_index` is effective in the following query:

```gql
MATCH ()-[e:links WHERE e.weight = 2]->() RETURN e
```

The edge direction can be left (`<-[]-`), right (`-[]->`), or any (`-[]-`). 

The following query does not use `links_weight_index` because it retrieves paths, not edges:

```gql
MATCH p = ()-[e:links WHERE e.weight = 2]->() RETURN p
```

**3. Start node filtering in path patterns.**  

The above `user_age_index` is effective in the following query:

```gql
MATCH p = (n:user WHERE n.age > 45)-[]-()-[]-() RETURN p
```

It does not apply to the following query:

```gql
MATCH p = ()-[]-(n:user WHERE n.age > 45) RETURN p
```

### Leftmost Prefix Rule

The order of properties in a composite index matters — queries that match the leftmost properties of the index (i.e., the first property or the first few properties in the defined order) will benefit from the index.

For example:

```gql
CREATE INDEX name_age ON NODE user (name(10),age)
```

- `MATCH (u:user WHERE u.name = "Kavi" AND u.age > 20)` uses the index.
- `MATCH (u:user WHERE u.name = "Kavi")` uses the index.
- `MATCH (u:user WHERE u.age > 20)` doesn't use the index.
- `MATCH (u:user WHERE u.name = "Kavi" AND u.age > 20 AND u.grade = 7)` uses the index, meanwhile it contains the filtering for the `grade` property which lacks an index.

### String Byte-Length Limitation

When using indexes with `string` or `text` properties, ensure the byte-length of the string used in the filter does not exceed the defined limit when creating the index.

For example, an index `Username` is created for the `name` property of the `user` nodes with a 8-byte limitation:

```gql
CREATE INDEX Username ON NODE user (name(8))
```

The query below won't utilize the `Username` index as the specified string `Aventurine` exceeds the 8-byte limit:

```gql
MATCH (n:user {name: "Aventurine"})
RETURN n
```

## Expression Index

An expression index indexes the **computed result** of a function applied to a property, rather than the raw property value. When a query contains a matching function expression, the optimizer automatically uses the expression index to accelerate the query.

### Supported Functions

| Function | Input Type | Output Type | Description |
| -- | -- | -- | -- |
| `lower()` | STRING | STRING | Converts to lowercase. |
| `upper()` | STRING | STRING | Converts to uppercase. |
| `year()` | DATETIME | INT32 | Extracts the year. |
| `month()` | DATETIME | INT32 | Extracts the month (1–12). |
| `day()` | DATETIME | INT32 | Extracts the day (1–31). |
| `abs()` | INT32/INT64/FLOAT/DOUBLE | Same as input | Returns the absolute value. |

### Creating an Expression Index

```gql
CREATE INDEX <indexName> ON NODE <schemaName> (<function>(<propertyName>))
CREATE INDEX <indexName> ON EDGE <schemaName> (<function>(<propertyName>))
```

Expression indexes can also be combined with regular properties in a composite index:

```gql
CREATE INDEX <indexName> ON NODE <schemaName> (<function>(<propertyName>), <propertyName2>)
```

### Examples

Case-insensitive string matching:

```gql
CREATE INDEX idx_lower_name ON NODE Person (lower(name))

MATCH (n:Person) WHERE lower(n.name) = "alice" RETURN n
```

Filtering by date component:

```gql
CREATE INDEX idx_year_bday ON NODE Person (year(birthday))

MATCH (n:Person) WHERE year(n.birthday) = 1994 RETURN n
```

Absolute value query:

```gql
CREATE INDEX idx_abs_salary ON NODE Person (abs(salary))

MATCH (n:Person) WHERE abs(n.salary) = 5000.0 RETURN n
```

Composite expression index:

```gql
CREATE INDEX idx_lower_name_age ON NODE Person (lower(name), age)

MATCH (n:Person) WHERE lower(n.name) = "alice" AND n.age = 30 RETURN n
```

Edge expression index:

```gql
CREATE INDEX idx_year_since ON EDGE KNOWS (year(since))

MATCH ()-[e:KNOWS]->() WHERE year(e.since) = 2020 RETURN e
```

### Expression Index Behavior

- Expression indexes are automatically maintained when data is inserted, updated, upserted, or deleted.
- The `SHOW NODE INDEX` and `SHOW EDGE INDEX` output displays expression functions in the `properties` field (e.g., `lower(name)` instead of `name`).
- Duplicate detection prevents creating two expression indexes with the same function and property combination. Different functions on the same property are allowed (e.g., `lower(name)` and `upper(name)`).
- Regular property queries (e.g., `n.name = "Alice"`) do not use expression indexes (e.g., `lower(name)` index).
- The <a href="#Leftmost-Prefix-Rule">leftmost prefix rule</a> applies to composite expression indexes.

### Expression Index Limitations

- Only equality queries (`=`) can use expression indexes. Range queries (`<`, `>`, `BETWEEN`) are not supported.
- Only the six functions listed above are supported.
- Each expression function applies to a single property only; multi-property expressions (e.g., `lower(first_name + last_name)`) are not supported.
