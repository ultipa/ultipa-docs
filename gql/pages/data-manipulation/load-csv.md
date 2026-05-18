# LOAD CSV

## Overview

The `LOAD CSV` statement reads a CSV file row by row and binds each row to a variable. Subsequent statements (such as `INSERT`, `MATCH`, or `RETURN`) can then reference fields of that row to drive graph mutations or queries.

The variable produced by `LOAD CSV` is a map. Field access uses `.` notation: `row.name` when reading by header column, or `row.col0`, `row.col1`, ... when there is no header.

<p tit="Syntax"></p>

```
<load csv statement> ::=
  "LOAD CSV FROM" <single-quoted file source>
  [ "AS" <row variable> ]
  [ "WITH HEADER" [ "DELIMITER" <character> ] [ "QUOTE" <character> ] ]
```

**Details**

- `<single-quoted file source>` is a local filesystem path or a `file://` URI. Remote schemes (`http://`, `https://`, `s3://`, ...) are not supported.
- `<row variable>` defaults to `row` when `AS` is omitted.
- With `WITH HEADER`, the first row is consumed as column names and each subsequent row is keyed by those names. Without `WITH HEADER`, each row is keyed positionally: `col0`, `col1`, ... .
- `DELIMITER` and `QUOTE` are only accepted after `WITH HEADER`. `DELIMITER` accepts a single character (e.g. `';'`, `'\t'`). `QUOTE` is parsed for forward compatibility; only `"` is honored at runtime.

## Reading Rows

Read a CSV file with no header and return each row positionally:

```gql
LOAD CSV FROM 'data/users.csv'
RETURN row.col0, row.col1
```

Bind the row to a different variable name:

```gql
LOAD CSV FROM 'data/users.csv' AS u
RETURN u.col0, u.col1
```

Read a CSV file with a header so fields can be accessed by name:

```gql
LOAD CSV FROM 'data/users.csv' AS u WITH HEADER
RETURN u.name, u.age
```

Read a tab-separated file:

```gql
LOAD CSV FROM 'data/users.tsv' AS u WITH HEADER DELIMITER '\t'
RETURN u.name, u.age
```

## Loading Data into the Graph

Use `LOAD CSV` together with `INSERT` to bulk-load nodes from a CSV file:

```gql
LOAD CSV FROM 'data/users.csv' AS row WITH HEADER
INSERT (:User {_id: row._id, name: row.name, age: toInteger(row.age)})
```

CSV cells are returned as strings. Convert them to the desired type with the appropriate function (`toInteger`, `toFloat`, `toBoolean`, ...) before inserting into a typed property in a closed graph.

Load edges by joining the CSV row against existing nodes:

```gql
LOAD CSV FROM 'data/friendships.csv' AS row WITH HEADER
MATCH (a:User {_id: row.from_id}), (b:User {_id: row.to_id})
INSERT (a)-[:FOLLOWS {since: row.since}]->(b)
```

## Limitations

- Only local filesystem paths and `file://` URIs are supported. HTTP(S) and object-storage sources are not yet wired in.
- Every cell is read as a `STRING`; downstream statements are responsible for converting values to their target types.
- `QUOTE '<c>'` parses but only the default `"` quote character takes effect at runtime.
- The grammar does not include a `SKIP <n>` clause in this release.
