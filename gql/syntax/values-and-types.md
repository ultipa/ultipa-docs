# Values and Types

GQL supports various values and types to represent data within the graph database. Understanding these values and types is essential for effective query construction and data manipulation.

## Property Value Types

A property value type refers to the data type of the values of a property. Ultipa supports the following property value types:

### Numeric

| <div table-width="15">Type</div> | Description|
| -- | -- |
| `INT`/<br>`INTEGER`/<br>`INT32`/<br>`INTEGER32` | 32-bit signed integer ranging from `-2,147,483,648` to `2,147,483,647`. |
| `UINT`/<br>`UINT32` | 32-bit unsigned integer ranging from `0` to `4,294,967,295`. |
| `INT64`/<br>`INTEGER64` | 64-bit signed integer ranging from `-9,223,372,036,854,775,808` to `9,223,372,036,854,775,807`. |
| `UINT64` | 64-bit unsigned integer ranging from `0` to `18,446,744,073,709,551,615`. |
| `FLOAT` | 32-bit single-precision floating-point number supporting up to 6 digits after the decimal point. | 
| `DOUBLE` | 64-bit double-precision floating-point number supporting up to 15 significant digits. This includes all non-zero digits and any zeros between them, e.g., `0.0123456789012345`. |
| `DECIMAL` | A fixed-point number with a specified precision (1 to 65, total number of digits) and scale (0 to 30, number of digits after the decimal point). E.g., `DECIMAL(10,4)` represents a number with up to `10` total digits, of which up to `4` can appear after the decimal point. |

### Textual

| <div table-width="13">Type</div> | Description|
| -- | -- |
| `STRING` | A sequence of characters enclosed in quotes, with a maximum size of `60,000` bytes. This is the **default type** when creating a property. |
| `TEXT` | A sequence of characters enclosed in quotes with no length limit. |

### Temporal Instant

| <div table-width="22">Type</div> | Description|
| -- | -- |
| `DATE` |  A date value without any timezone information. E.g., `2025-01-01`, `20250101`. |
| `LOCAL DATETIME` | A date-time value without any timezone information. E.g., `2025-01-01 12:20:02`, `20250101T122002.55254`. |
| `LOCAL TIME` |  A time value without any timezone information. E.g., `12:20:02`, `122002.55254`. |
| `ZONED DATETIME` | An instant date-time value that includes timezone information. E.g., `2025-01-01 12:20:02-1030`, `20250101T122002.55254+0900`. |
| `ZONED TIME` | A time value that includes timezone information. E.g., `12:20:02-1030`, `122002.55254+0900`. |
| `TIMESTAMP` | A Unix timestamp representing the number of seconds since `1970-01-01 00:00:00 UTC`. E.g., `1751422921` corresponds to `2025-07-02 02:22:01 UTC`.<br><br>When a date-time formatted value is provided, the system automatically converts it to a timestamp based on the local timezone, client settings, or SDK configuration. Likewise, when displaying a timestamp in date-time format, the output is adjusted according to the configured timezone. |
| `DATETIME` | A date-time value without timezone information, ranging from `1000-01-01 00:00:00.000000` to `9999-12-31 23:59:59.499999`. This is an extended property type provided by Ultipa, similar to the standard GQL type `LOCAL DATETIME`, but with more flexible input formats. For example:<br><br><ul><li><code>25-1-1 12:20:2</code>: Supports two-digit years (`YY`) and allows single-digit month, day, hour, minute, and second without leading zeros.</li><li><code>2025/1/1T12:20:2.55254</code>: Supports `/` as a date separator and up to 6 fractional digits for seconds.</li><li><code>2025-01-01</code>: If the time part is omitted, it defaults to <code>00:00:00</code>.</li></ul> |

**Date**

- Format: `yyyy-[m]m-[d]d` or `yyyymmdd`
- Range: `-9999-12-31` to `9999-12-31`

**Time**

- Format: `hh:mm:ss[.fraction]` or `hhmmss[.fraction]`
- Range: `00:00:00.000000000` to `23:59:59.999999999`

**Date and Time**

- Format: The date and time parts are joined by either a space or the letter `T`.
- Range: `-9999-01-01 00:00:00.000000000` to `9999-12-31 23:59:59.999999999`

**Timezone**

- Format: Represented as a UTC offset in the form of `±hh:mm` or `±hhmm`, appended directly to the time value.
- Range: `UTC-15:00` to `UTC+15:00`

### Temporal Duration

| <div table-width="20">Type</div> | Description|
| -- | -- |
| `DURATION(YEAR TO MONTH)` | A time duration measured in years and months only. E.g., `P2Y5M` (2 years and 5 months), `-P1Y2M` (minus 1 year and 2 months).<br><br><ul><li>Format: <code>[-]P[nY][nM]</code></li><li>Range: <code>-P178956969Y12M</code> to <code>P178956969Y12M</code></li></ul> |
| `DURATION(DAY TO SECOND)` | A time duration measured in days, hours, minutes, seconds, and optional fractional seconds. E.g., `P3DT4H` (3 days and 4 hours), `-P1DT2H3M4.12S` (minus 1 day, 2 hours, 3 minutes, and 4.12 seconds).<br><br><ul><li>Format: <code>P[nD][T[nH][nM][nS]]</code> (the letter <code>T</code> is required to join the day and time parts)</li><li>Range: <code>-P106750DT23H59M59.999999999S</code> to <code>P106750DT23H59M59.999999999S</code></li></ul> |

### Boolean

| <div table-width="13">Type</div> | Description|
| -- | -- |
| `BOOL` | Represents two possible values:<ul><li>`1` or `TRUE`</li><li>`0` or `FALSE`</li></ul> |

### Spatial

| <div table-width="13">Type</div> | Description|
| -- | -- |
| `POINT` | A two-dimensional geographical coordinate `(latitude, longitude)` that indicate a specific position. The coordinate values are stored as `DOUBLE`. |
| `POINT3D` | A three-dimensional Cartesian coordinate `(x, y, z)` that indicate a specific position. The coordinate values are stored as `DOUBLE`. |

### Record

| <div table-width="12">Type</div> | Description |
| -- | -- |
| `RECORD` | A set of fields, each such field has a name and a value. |

### Binary

| <div table-width="10">Type</div> | Description |
| -- | -- |
| `BLOB` | Stores binary data, which can be used for images, audio, video, or other unstructured files. |

### List

| <div table-width="20">Type</div> | Description|
| -- | -- |
| `LIST<subType>` | An ordered collection of elements of the specified subtype. Supports all of the above types as subtypes, except for `BOOL`. |

## Constructed Value Types

A constructed value type is a data type comprising composite elements. GQL defines the following constructed value types:

| Type | <div table-width="82">Description</div> |
| -- | -- |
| `PATH` | Represents the path value type. A path value encapsulates the ordered list of nodes and edges that form a path in the graph. |
| `LIST` or `ARRAY` | Represents the list value type. A list value is an ordered collection of elements of the same or different types.<br><br>A list value is either a regular list value or a <a target="_blank" href="/docs/gql/quantified-paths#Group-Variables">group list</a> value. A regular list value is a list value that is not a group list value. |
| `RECORD` | Represents the record type. A record is a set of fields, each such field has a name and a value. |

## Result Types

A result type refers to the data type of the values returned by a query. Ultipa defines the following result types.

<div align=center drawio-diagram='17704' drawio-name='draw_8be5f8d8cfa246b4afd18dd9e963181e.jpg'><img src="https://img.ultipa.cn/draw/draw_8be5f8d8cfa246b4afd18dd9e963181e.jpg?v='1728900974556'"/></div>

### RESULT_TYPE_NODE

This query returns all nodes labeled `Paper` bound to the variable `n`:

```gql
MATCH (n:Paper) RETURN n
```

Data structure of `n`:

<p tit="n"></p>

```json
{
  "data": [
    {
      "id": "P2",
      "uuid": "8718971077612535835",
      "schema": "Paper",
      "values": {
        "title": "Optimizing Queries",
        "score": 9
      }
    },
    {
      "id": "P1",
      "uuid": "8791028671650463770",
      "schema": "Paper",
      "values": {
        "title": "Efficient Graph Search",
        "score": 6
      }
    }
  ],
  "alias": "n",
  "type": 2,
  "type_desc": "RESULT_TYPE_NODE"
}
```

### RESULT_TYPE_EDGE

This query returns all outgoing edges labeled `Cites` bound to the variable `e`:

```gql
MATCH ()-[e:Cites]->() RETURN e
```

Data structure of `e`:

<p tit="e"></p>

```json
{
  "data": [
    {
      "from": "P1",
      "to": "P2",
      "uuid": "1",
      "from_uuid": "8791028671650463770",
      "to_uuid": "8718971077612535835",
      "schema": "Cites",
      "values": {
        "weight": 2
      }
    }
  ],
  "alias": "e",
  "type": 3,
  "type_desc": "RESULT_TYPE_EDGE"
}
```

### RESULT_TYPE_PATH

This query returns all outgoing 1-step paths bound to the variable `p`:

```gql
MATCH p = ()-[]->() RETURN p
```

Data structure of `p`:

<p tit="p"></p>

```json
{
  "data": [
    {
      "nodes": [
        {
          "id": "P1",
          "uuid": "8791028671650463770",
          "schema": "Paper",
          "values": {
            "title": "Efficient Graph Search",
            "score": 6
          }
        },
        {
          "id": "P2",
          "uuid": "8718971077612535835",
          "schema": "Paper",
          "values": {
            "title": "Optimizing Queries",
            "score": 9
          }
        }
      ],
      "edges": [
        {
          "from": "P1",
          "to": "P2",
          "uuid": "1",
          "from_uuid": "8791028671650463770",
          "to_uuid": "8718971077612535835",
          "schema": "Cites",
          "values": {
            "weight": 2
          }
        }
      ],
      "length": 1
    }
  ],
  "alias": "p",
  "type": 1,
  "type_desc": "RESULT_TYPE_PATH"
}
```

### RESULT_TYPE_ATTR

This query returns the `title` property of nodes labeled `Paper`:

```gql
MATCH (n:Paper) RETURN n.title
```

Data structure of `n.title`:

<p tit="n.title"></p>

```json
{
  "data": {
    "alias": "n.title",
    "type": 4,
    "type_desc": "RESULT_TYPE_ATTR",
    "values": [
      "Optimizing Queries",
      "Efficient Graph Search"
    ]
  },
  "alias": "n.title",
  "type": 4,
  "type_desc": "RESULT_TYPE_ATTR"
}
```

### RESULT_TYPE_TABLE

This query returns a table bound to the variable `table`:

```gql
MATCH (n:Paper) RETURN table(n.title, n.score) AS table
```

Data structure of `table`:

<p tit="table"></p>

```json
{
  "data": {
    "name": "table",
    "alias": "table",
    "headers": [
      "n.title",
      "n.score"
    ],
    "rows": [
      [
        "Optimizing Queries",
        "9"
      ],
      [
        "Efficient Graph Search",
        "6"
      ]
    ]
  },
  "alias": "table",
  "type": 5,
  "type_desc": "RESULT_TYPE_TABLE"
}
```

## Null Value

The `null` value is a special value available in all nullable types. Any non-null value is a material value.

### Null Scenarios

The `null` values can arise in various contexts, including:

- **Default Assignment:** When nodes or edges are inserted, nullable properties that lack specified values automatically receive `null`.
- **Explicit Null Specification:** During node or edge insertion, nullable properties can be intentionally set to `null`.
- **Value Removal:** Removing a property’s value sets it to `null`.
- **New Property Assignment:** When adding a new property to a label, any existing nodes or edges with that label are assigned `null` for the new property by default.
- **Nonexistent Property References:** Referencing a property that does not exist returns `null`.
- **Optional Matching:** When the `OPTIONAL` keyword is used with the `MATCH` statement, if no result is found for the pattern, `MATCH` yields `null` instead of empty return.
- **NULLIF Expression**: The `NULLIF` expression returns `null` if the two compared values are equal.

### Null in Comparisons

The `null` value is not comparable to any other value due to its inherently unknown nature. Consequently, comparisons involving `null` using normal operators such as `=` or `<>` do not typically yield true or false but rather an unknown result, also represented by `null`.

| Example | <div table-width='30'>Result</div> |
| -- | -- |
| `RETURN null = null` | `null` |
| `RETURN null > 3` | `null` |
| `RETURN [1,null,2] <> [1,null,2]` | `null` |
| `RETURN 3 IN [1,null,2]` | `null` |
| `RETURN null IN [1,2]` | `null` |
| `RETURN null IN []` | 0 |

Comparisons involving `null` require special handling with null predicates (`IS NULL` and `IS NOT NULL`).

| Example | <div table-width='30'>Result</div> |
| -- | -- |
| `RETURN null IS NULL` | 1 |
| `RETURN null IS NOT NULL` | 0 |

### Null Treatments

The `null` values receive special treatment in some contexts. For instance:

- Aggregate functions typically ignore `null` values.
- The `GROUP BY` clause groups all `null` values together.
- The `ORDER BY` statement allows for null ordering using the `NULLS FIRST` and `NULL LAST` keywords.