# Query Acceleration

## Index

## Overview

**Indexing**, or **property indexing**, is a technique used in Ultipa to accelerate the retrieval of nodes and edges with specific properties. By avoiding full graph scans, indexes enable the database to quickly locate relevant data. This is especially advantageous when working with large graphs.

### Index Types

Ultipa supports **single index** on one property and **composite index** which involve multiple properties from a label.

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
| `label` | The label of the properties involved in the index. |
| `status` | Index status, which can be `DONE` or `CREATING`. |

## Creating an Index

You can create an index using the `CREATE INDEX` statement. Note that each property can only have one single index. The index creation runs as a job, you may run `SHOW JOB <id?>` afterward to verify the success of the creation.

System properties in Ultipa are inherently optimized for query performance and have built-in efficiencies. They do not support indexing.

<p tit="Syntax"></p>

```gql
<create index statement> ::=
  "CREATE INDEX" <index name> "ON" < "NODE" | "EDGE" > <label name>
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
MATCH (p:Person WHERE p.age >= 25 AND p.age < 40)
RETURN p.name, p.age
```

**Prefix search:**

```gql
MATCH (p:Person WHERE p.name STARTS WITH 'Al')
RETURN p.name
```

**Edge property queries:**

```gql
MATCH ()-[e:Links WHERE e.weight > 5]->()
RETURN e
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
