# Index

## Overview

**Indexing**, or **property indexing**, is a technique used in Ultipa to accelerate the retrieval of nodes and edges with specific properties. By avoiding full graph scans, indexes enable the database to quickly locate relevant data. This is especially advantageous when working with large graphs.

### Index Types

Ultipa supports **single index** on one property and **composite index** which involve multiple properties from a schema.

## Showing Indexes

To retrieve indexes in the current graphset:

```uql
// Shows all indexes
show().index()

// Shows all node indexes
show().node_index()

// Shows all edge indexes
show().edge_index()
```

The information about indexes is organized into the `_nodeIndex` or `_edgeIndex` table. Each table provides essential details about each index:

| <div table-width="15">Field</div> | Description |
| -- | -- |
| `id` | Index id. |
| `name` | Index name. |
| `properties` | The properties involved in the index. |
| `schema` | The schema of the properties involved in the index. |
| `status` | Index status, which can be `DONE` or `CREATING`. |

## Creating Indexes

You can create one or more indexes using a single `create()` statement. Each index is created by chaining a `node_index()` or `edge_index()` method. Note that each property can only have one single index. The index creation runs as a job, you may run `show().job(<id?>)` afterward to verify the success of the creation.

System properties in Ultipa are inherently optimized for query performance and have built-in efficiencies. They do not support indexing.

<p tit="Syntax"></p>

```uql
create()
  .node_index(@<schema>.<property>(<bytes?>), "<indexName>")
  .edge_index(@<schema>.<property>(<bytes?>), "<indexName>")
  .node_index(@<schema>(<property1>(<bytes1?>), <property2>(<bytes2?>), ...), "<indexName>")
  .edge_index(@<schema>(<property1>(<bytes1?>), <property2>(<bytes2?>), ...), "<indexName>")
  ...
```

<table>
  <thead>
    <tr>
      <th style="width:17%">Method</th>
      <th style="width:26%">Param</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan=3><code>node_index()</code> or <code>edge_index()</code></td>
      <td><code>@&lt;schema&gt;.&lt;property&gt;(&lt;bytes?&gt;)</code> or <code>@&lt;schema&gt;(&lt;property1&gt;(&lt;bytes1?&gt;), &lt;property2&gt;(&lt;bytes2?&gt;),...)</code></td>
      <td>For a <b>single index</b>, specifies the property and its schema using <code>@&lt;schema&gt;.&lt;property&gt;</code>. For a <b>composite index</b>, lists multiple properties within a schema using <code>@&lt;schema&gt;(&lt;property1&gt;, &lt;property2&gt;,...)</code>.<br><br>If a specified property is of type <code>string</code> or <code>text</code>, you can specify the maximum number of <b>bytes</b> <sup>[1]</sup> (count from left) to be indexed for each value. If omitted, the default indexing length is <code>1024</code> bytes for <code>string</code> and <code>2048</code> bytes for <code>text</code>. Learn more about <a href="#String-Byte-Length-Limitation">how this byte-length limitation affects queries</a>.</td>
    </tr>
    <tr>
      <td><code>&lt;indexName&gt;</code></td>
      <td>The name of the index. It must be unique among node indexes and among edge indexes, though a node index and an edge index may share the same name.</td>
    </tr>
  </tbody>
</table>

<sup>[1]</sup> In standard English text, most encodings (such as ASCII or UTF-8) use 1 byte per character. However, for non-English characters, the byte size may vary—for example, one Chinese character typically occupies 3 bytes.

To create single index named `cBalance` for the property `balance` of `card` nodes:

```uql
create().node_index(@card.balance, "cBalance")
```

To create single index named `name` for the property `name` (`string` type) of `card` nodes, restricting the indexed byte-length as `10`:

```uql
create().node_index(@card.name(10), "name")
```

To create composite index named `transAmountNotes` for properties `amount` and `notes` (`text` type, restricting the indexed byte-length as `10`) for `transfer` edges:

```uql
create().edge_index(@transfer(amount, notes(10)), "transAmountNotes")
```

To create multiple indexes:

```uql
create()
  .node_index(@card.balance, "balance")
  .edge_index(@transfer(amount, notes(10)), "transAmountNotes")
```

## Dropping Indexes

You can drop one or more indexes using a single `drop()` statement. Each index is specified by chaining a `node_index()` or `edge_index()` method. Dropping an index does not affect the actual property values stored in shards.

> A property with an index cannot be dropped until the index is deleted.

To drop the node index `cBalance`:

```uql
drop().node_index("cBalance")
```

To drop the edge index `transAmountNotes`:

```uql
drop().edge_index("transAmountNotes")
```

To drop multiple indexes:

```uql
drop().node_index("balance").edge_index("transAmountNotes")
```

## Using Indexes

### Applicable Queries

Indexes are automatically applied when the corresponding properties are used in the following types of queries. They are not effective in other types of queries.

**1. Node retrieval using `find().nodes().`** For example,

```uql
create().node_index(@user.age, "user_age_index")
```

The `user_age_index` is effective in the following queries:

```uql
find().nodes({@user.age == 45}) as n return n
```

```uql
find().nodes({age > 45}) as n return n
```

In the second query, the node schema is not specified, so `user_age_index` is only partially used during the search for `user` nodes.

**2. Edge retrieval using `find().edges()`.** For example,

```uql
create().edge_index(@links.weight, "links_weight_index")
```

The `links_weight_index` is effective in the following query:

```uql
find().edges({@links.weight == 2}) as e return e
```

**3. Start node filtering in path patterns.**

The above `user_age_index` is effective in the following query:

```uql
n({@user.age > 45}).e().n().e().n() as p return p
```

It does not apply to the following query:

```uql
n().e().n().e().n({@user.age > 45}) as p return p
```

### Leftmost Prefix Rule

The order of properties in a composite index matters — queries that match the leftmost properties of the index (i.e., the first property or the first few properties in the defined order) will benefit from the index.

For example:

```uql
create().node_index(@user(name(10),age), 'name_age')
```

- `find().nodes({@user.name == "Kavi" && @user.age > 20})` uses the index.
- `find().nodes({@user.name == "Kavi"})` uses the index.
- `find().nodes({@user.age > 20})` doesn't use the index.
- `find().nodes({@user.name == "Kavi" && @user.age > 20 && @user.grade == 7})` uses the index, meanwhile it contains the filtering for the `@user.grade` property which lacks an index.

### String Byte-Length Limitation

When using indexes with `string` or `text` properties, ensure the byte-length of the string used in the filter does not exceed the defined limit when creating the index.

For example, an index `Username` is created for the `name` property of the `user` nodes with a 8-byte limitation:

```uql
create().node_index(@user.name(8), "Username")
```

The query below won't utilize the `Username` index as the specified string `Aventurine` exceeds the 8-byte limit:

```uql
find().nodes({@user.name == "Aventurine"}) as n return n
```
