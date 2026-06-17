# LOAD CSV

## Overview

`LOAD CSV` statement has two forms:

- **Dump CSV** form reads a CSV file and returns each row as a map. Use this to preview a file.
- **Import from CSV** form writes each CSV row straight into the current graph as a node or edge. Use this to load data. Large files are streamed in batches.

Both forms read a local filesystem path, a `file://` URI, or an `http(s)://` URL. Other remote schemes (`s3://`, `ftp://`, ...) are not supported.

```syntax
<load csv statement> ::= 
  "LOAD CSV FROM" <single-quoted file source> { <dump csv> | <import csv> }

<dump csv> ::=
  [ "AS" <row variable> ]
  [ "WITH HEADER" [ "DELIMITER" <character> [ "QUOTE" <character> ] ] ]

<import csv> ::=
  "WITH HEADER" [ "DELIMITER" <character> [ "QUOTE" <character> ] ]
  "INTO" <label name>
  [ "EDGE FROM" <label name> "(" <column> ")" "TO" <label name> "(" <column> ")" ]
  [ "MAPPING" "(" <property mapping> { "," ... } ")" ]

<property mapping> ::= <property> ":" <column> [ "AS" <type> ]
```

**Details**

- `<row variable>` defaults to `row` when `AS` is omitted.
- With `WITH HEADER`, the first row is consumed as column names and each subsequent row is keyed by those names. Without `WITH HEADER`, each row is keyed positionally: `col0`, `col1`, ... .
- `DELIMITER` accepts a single character (e.g. `','`, `';'`, `'\t'`). `QUOTE` accepts the double quote (`"`) as the field-quote character.
- About the file source:
  - Path resolution: absolute paths (`/data/users.csv`) and `file:///` URIs are used as-is. **Relative paths resolve against the server process's working directory**, the directory the database was launched from, not the `.gdb` data folder. Prefer absolute paths in production.
  - HTTP(S) sources are streamed directly into the CSV reader (no temp file). Connect, TLS-handshake, and response-header waits are bounded (30 s, 30 s, 60 s); the body itself streams without a total deadline and is cancelled if the query is cancelled. Non-`200` responses fail the statement with the HTTP status.

## Example CSVs

<p tit="user.csv"></p>

```csv
_id,name,balance,risk_score,is_mule
USR_000000,David Brown,16625.7,0.86,true
USR_000001,James Johnson,62870.63,0.76,true
USR_000002,Jane Brown,17065.87,0.85,true
```

<p tit="transfers.csv"></p>

```csv
_from,_to,amount,is_suspicious,timestamp
USR_000000,USR_000002,3384.45,false,2024-01-27T19:19:00Z
USR_000001,USR_000000,4353.22,true,2024-01-25T06:18:00Z
USR_000000,USR_000001,2482.13,false,2024-01-30T15:27:00Z
USR_000001,USR_000002,4050.61,false,2024-01-28T01:02:00
```

## Dump CSV to Inspect Rows

Read a CSV file with no header. Each row is returned as a map keyed positionally (`col0`, `col1`, ...) under a single column named `row` (the default variable):

```gql
LOAD CSV FROM 'data/users.csv'
```

Result:

```json
[
  {
    "row": {
      "col2": "balance",
      "col3": "risk_score",
      "col4": "is_mule",
      "col0": "_id",
      "col1": "name"
    }
  },
  {
    "row": {
      "col0": "USR_000000",
      "col1": "David Brown",
      "col2": "16625.7",
      "col3": "0.86",
      "col4": "true"
    }
  },
  {
    "row": {
      "col0": "USR_000001",
      "col1": "James Johnson",
      "col2": "62870.63",
      "col3": "0.76",
      "col4": "true"
    }
  },
  {
    "row": {
      "col3": "0.85",
      "col4": "true",
      "col0": "USR_000002",
      "col1": "Jane Brown",
      "col2": "17065.87"
    }
  }
]
```

Read a CSV file with a header so the map is keyed by column name:

```gql
LOAD CSV FROM 'data/users.csv' WITH HEADER
```

Result:

```json
[
  {
    "row": {
      "_id": "USR_000000",
      "name": "David Brown",
      "balance": "16625.7",
      "risk_score": "0.86",
      "is_mule": "true"
    }
  },
  {
    "row": {
      "_id": "USR_000001",
      "name": "James Johnson",
      "balance": "62870.63",
      "risk_score": "0.76",
      "is_mule": "true"
    }
  },
  {
    "row": {
      "_id": "USR_000002",
      "name": "Jane Brown",
      "balance": "17065.87",
      "risk_score": "0.85",
      "is_mule": "true"
    }
  }
]
```

Bind the per-row map to a different column name with `AS`:

```gql
LOAD CSV FROM '/data/users.csv' AS u
```

Read a tab-separated file:

```gql
LOAD CSV FROM 'data/users.tsv' AS u WITH HEADER DELIMITER '\t'
```

Specify the field-quote character with `QUOTE`. The double quote (`"`) is the supported quoting character:

```gql
LOAD CSV FROM 'data/users.csv' AS u WITH HEADER DELIMITER ',' QUOTE '"'
```

Read directly from an HTTP(S) URL — the file is streamed, not downloaded to disk first:

```gql
LOAD CSV FROM 'https://example.com/data/users.csv' WITH HEADER
```

The result set has one column (`row` / `u` / whatever name `AS` specified). Each row in that column is a `MAP` — access fields client-side after fetching, e.g. `row['name']` in your driver.

The rows are returned to the client only, they cannot be passed to a following `RETURN`, `INSERT`, or `MATCH` in the same query.

## Import from CSV

Use `INTO <label>` to write each CSV row as a node (or as an edge with `EDGE FROM ... TO ...`) in a single statement, no chained `INSERT` needed. Returns a one-row summary with the count of imported (and, for edges, skipped) records.

### Node import

Without `MAPPING`, every CSV column becomes a property of the same name on the new node. `WITH HEADER` is required (the import needs column names to map by). All values default to `STRING`.

```gql
LOAD CSV FROM 'data/users.csv' WITH HEADER INTO User
```

Add a `MAPPING (...)` clause to rename columns, select a subset, and apply type coercion. Include `_id` in the mapping if you plan to reference these nodes from a later edge import.

```gql
LOAD CSV FROM 'data/users.csv' WITH HEADER
INTO Person MAPPING (
  _id: '_id',
  name: 'name',
  balance: 'balance' AS FLOAT,
  riskScore: 'risk_score' AS FLOAT,
  isMule: 'is_mule' AS BOOL
)
```

### Edge import

For edges, name the endpoint labels and the CSV columns that supply each endpoint's `_id`. Rows whose endpoint `_id` is missing in the graph are skipped and reported in the summary instead of erroring the whole import. Requires the graph to have edge `_id` enabled (default for new graphs).

```gql
LOAD CSV FROM 'data/transfers.csv' WITH HEADER
INTO TRANSFERS EDGE FROM Person('_from') TO Person('_to')
MAPPING (
  isSuspicious: 'is_suspicious' AS BOOL,
  timestamp: 'timestamp' AS TIMESTAMP
)  
```

### Supported Type Coercions

| Type | Aliases | Accepted format |
| -- | -- | -- |
| `STRING` | `TEXT`, `CHAR`, `VARCHAR` | cell preserved verbatim |
| `INT` / `INTEGER` | `BIGINT`, `SMALLINT`, `INT8/16/32/64`, `UINT`, `UINT8/16/32/64` | base-10, whitespace trimmed |
| `FLOAT` / `DOUBLE` | `REAL`, `FLOAT32`, `FLOAT64` | IEEE 754, whitespace trimmed |
| `DECIMAL` | `NUMERIC` | arbitrary-precision, stored as the original digit string |
| `BOOL` / `BOOLEAN` |  | `true/false/t/f/yes/no/y/n/1/0` (case-insensitive) |
| `DATE` |  | `YYYY-MM-DD` |
| `TIME` |  | `HH:MM[:SS[.fff]]` |
| `DATETIME` | `LOCAL_DATETIME` | RFC 3339 or `YYYY-MM-DD HH:MM:SS` (no zone) |
| `TIMESTAMP` |  | RFC 3339 (assumes UTC if no offset) |
| `ZONED_DATETIME` |  | RFC 3339 with offset (`2024-01-15T09:00:00+09:00`) |
| `DURATION` | `INTERVAL` | ISO 8601 (`PT3H30M`, `P1Y2M`, `-PT15M`, fractional units OK) |
| `BYTES` | `BLOB`, `BINARY`, `VARBINARY` | hex (`0xDEADBEEF` or `deadbeef`) or base64 |
| `POINT` |  | `1.5 2.5`, `1.5,2.5`, or `POINT(1.5 2.5)` — longitude first |
| `POINT3D` |  | `1.0 2.0 3.0`, `1.0,2.0,3.0`, or `POINT(1.0 2.0 3.0)` |

**Notes:**

- Empty CSV cells produce a `NULL` (the property is omitted from the row) rather than an empty-string value.
- Coercion failures error out with the row number and the offending column name.

## Limitations

- Every cell is read as a `STRING` in the dump form; downstream client code is responsible for any type conversion. The inline-import form does its own coercion via `AS <TYPE>` in the `MAPPING` clause.