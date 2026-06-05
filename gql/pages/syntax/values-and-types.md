# Values and Types

GQL supports various values and types to represent data within the graph database. Understanding these values and types is essential for effective query construction and data manipulation.

## Property Value Types

A property value type refers to the data type of the values of a property. In a **closed graph**, property types are explicitly defined when creating node/edge types. The following types are available:

### Numeric

| Type | Description |
| -- | -- |
| `INT8` | 8-bit signed integer ranging from `-128` to `127`. |
| `INT16`/<br>`SMALLINT` | 16-bit signed integer ranging from `-32,768` to `32,767`. |
| `INT`/<br>`INT32`/<br>`INTEGER` | 32-bit signed integer ranging from `-2,147,483,648` to `2,147,483,647`. |
| `INT64`/<br>`BIGINT` | 64-bit signed integer ranging from `-9,223,372,036,854,775,808` to `9,223,372,036,854,775,807`. |
| `UINT8` | 8-bit unsigned integer ranging from `0` to `255`. |
| `UINT16` | 16-bit unsigned integer ranging from `0` to `65,535`. |
| `UINT`/<br>`UINT32` | 32-bit unsigned integer ranging from `0` to `4,294,967,295`. |
| `UINT64` | 64-bit unsigned integer ranging from `0` to `18,446,744,073,709,551,615`. |
| `FLOAT`/<br>`FLOAT32`/<br>`REAL` | 32-bit single-precision floating-point number with approximately 7 significant digits of precision. |
| `DOUBLE`/<br>`FLOAT64` | 64-bit double-precision floating-point number supporting up to 15 significant digits. This includes all non-zero digits and any zeros between them, e.g., `0.0123456789012345`. |
| `DECIMAL`/<br>`NUMERIC` | A fixed-point number with a specified precision (1 to 65, total number of digits) and scale (0 to 30, number of digits after the decimal point). E.g., `DECIMAL(10,4)` represents a number with up to `10` total digits, of which up to `4` can appear after the decimal point. |

### Textual

| Type | Description |
| -- | -- |
| `STRING`/<br>`CHAR`/<br>`VARCHAR` | A sequence of characters enclosed in quotes, with a maximum size of `60,000` bytes. |
| `TEXT` | A sequence of characters enclosed in quotes with no length limit. |

### Temporal Instant

| Type | Description |
| -- | -- |
| `DATE`/<br>`LOCAL DATE` |  A date value without any timezone information. E.g., `2025-01-01`, `20250101`. |
| `LOCAL DATETIME` | A date-time value without any timezone information. E.g., `2025-01-01 12:20:02`, `20250101T122002.55254`. |
| `LOCAL TIME`/<br>`TIME` |  A time value without any timezone information. E.g., `12:20:02`, `122002.55254`. |
| `ZONED DATETIME` | A date-time value that includes timezone information. E.g., `2025-01-01T12:20:02+08:00`, `2025-01-01T12:20:02Z`. |
| `ZONED TIME` | A time value that includes timezone information. E.g., `12:20:02+08:00`, `12:20:02Z`. |
| `TIMESTAMP` | A Unix timestamp representing the number of seconds since `1970-01-01 00:00:00 UTC`. E.g., `1751422921`. Also accepts date-time formatted strings: timezone-naive strings are parsed as UTC, timezone-aware strings (RFC 3339) use the embedded offset. |
| `DATETIME` | Similar to `LOCAL DATETIME`, but with more flexible input formats. See format notes below. |

**Date Formats**

- `2025-01-05` or `2025-1-5`
- `2025/01/05` or `2025/1/5`
- `20250105`

**Time Formats**

- `12:20:02.55254` (with fractional seconds up to 9 digits)
- `12:20:02`
- `12:20` (without seconds)
- `122002` or `122002.55254`

**Date-Time Formats**

The date and time parts are joined by either a space or the letter `T`:

- `2025-01-05 12:20:02`
- `2025-01-05T12:20:02`

**Timezone Formats**

For `ZONED DATETIME` and `ZONED TIME`, timezone is specified as an RFC 3339 UTC offset:

- `+08:00`, `-05:30`
- `Z` (UTC)

**DATETIME Additional Formats**

`DATETIME` accepts all the above date-time formats, plus:

- `25-1-1 12:20:2` (two-digit year)
- `2025-01-01` (time part omitted, defaults to `00:00:00`)

### Temporal Duration

| Type | Description |
| -- | -- |
| `DURATION`/<br>`INTERVAL` | A time duration in ISO 8601 format. Supports two forms:<br><br>**Year-month**: measured in years and months only. E.g., `P2Y5M` (2 years and 5 months), `-P1Y2M` (minus 1 year and 2 months).<ul><li>Format: <code>[-]P[nY][nM]</code></li><li>Range: <code>-P178956969Y12M</code> to <code>P178956969Y12M</code></li></ul>**Day-time**: measured in days, hours, minutes, seconds, and optional fractional seconds. E.g., `P3DT4H` (3 days and 4 hours), `-P1DT2H3M4.12S` (minus 1 day, 2 hours, 3 minutes, and 4.12 seconds).<ul><li>Format: <code>[-]P[nD][T[nH][nM][nS]]</code> (the letter <code>T</code> is required to join the day and time parts)</li><li>Range: <code>-P106750DT23H59M59.999999999S</code> to <code>P106750DT23H59M59.999999999S</code></li></ul> |

### Boolean

| Type | Description |
| -- | -- |
| `BOOL`/<br>`BOOLEAN` | Represents two possible values: `1` or `TRUE`, `0` or `FALSE`. |

### Spatial

| Type | Description |
| -- | -- |
| `POINT` | A two-dimensional geographical coordinate. Constructed with `point(longitude, latitude)`. The coordinate values are stored as `DOUBLE`. |
| `POINT3D` | A three-dimensional Cartesian coordinate. Constructed with `point3d(x, y, z)`. The coordinate values are stored as `DOUBLE`. |

### Binary

| Type | Description |
| -- | -- |
| `BLOB`/<br>`BINARY`/<br>`VARBINARY`/<br>`BYTES` | Stores binary data, which can be used for images, audio, video, or other unstructured files. |

### Record

| Type | Description |
| -- | -- |
| `RECORD`/<br>`MAP` | A collection of key-value pairs where keys are strings and values can be any type. |

### List

| Type | Description |
| -- | -- |
| `LIST<subType>` | An ordered collection of elements of the specified subtype. Supports all of the above types as subtypes. |

### Vector

| Type | Description |
| -- | -- |
| `VECTOR` | A fixed-length array of floating-point numbers, used for vector similarity search. Accepts vectors of any dimension. |
| `VECTOR(N)` | A vector with a declared dimension `N`. Every value written to this property must have exactly `N` coordinates; mismatched-dimension inserts are rejected at write time. Use this for embedding columns where every row must share the same model's output shape (e.g. `VECTOR(1536)` for OpenAI `text-embedding-3-small`). |

### Open Graph Property Types

In an **open graph**, property types are not explicitly defined. Instead, the type is inferred from the literal value at insertion time. The following types are used:

| Type | Inferred From |
| -- | -- |
| `INT` | Integer literals, e.g., `30`, `-5` |
| `FLOAT` | Floating-point literals, e.g., `3.14`, `-0.5` |
| `DECIMAL` | Decimal literals, e.g., `DECIMAL '123.45'` |
| `STRING` | String literals, e.g., `"hello"`, `'world'` |
| `DATE` | Date function, e.g., `date('2025-01-05')` |
| `DATETIME` | Local datetime function, e.g., `local_datetime('2025-01-05 12:00:00')` |
| `TIME` | Time function, e.g., `time('12:20:02')` |
| `ZONED DATETIME` | Zoned datetime function, e.g., `zoned_datetime('2025-01-05T12:00:00+08:00')` |
| `ZONED TIME` | Zoned time function, e.g., `zoned_time('12:20:02+08:00')` |
| `TIMESTAMP` | Integer Unix timestamp, e.g., `1751422921` |
| `DURATION` | Duration function, e.g., `duration('P3DT4H')` |
| `BOOL` | Boolean literals, e.g., `TRUE`, `FALSE` |
| `POINT` | Point constructor, e.g., `point(125.6, 22.3)` |
| `POINT3D` | Point3D constructor, e.g., `point3d(10, 3.4, 6.2)` |
| `BYTES` | Binary data |
| `MAP` | Map literals, e.g., `{key: "value", count: 5}` |
| `LIST` | List literals, e.g., `[1, 2, 3]`, `["a", "b"]` |
| `VECTOR` | Vector literals, e.g., `[0.1, 0.2, 0.3]` |

The same property name on different nodes can have different types. There is no fine-grained type control (e.g., `UINT32` vs `INT64` — all integers are stored as `INT`).

> Unlike closed graphs where string values are auto-converted to the defined property type (e.g., `'2025-01-05'` is auto-parsed as `DATE`), open graphs store string values as `STRING`. To create temporal, spatial, or vector values in an open graph, use constructor functions such as `date('2025-01-05')`, `local_datetime('2025-01-01 12:00:00')`, `duration('P2Y5M')`, `point(125.6, 22.3)`, `ai.vector(\[0.1, 0.2])`, etc.

## Query Response

Query results are returned as a list of rows, where each row is a map of column names to typed values.

```gql
MATCH (n:User) RETURN n, n.name LIMIT 2
```

```json
[
  {
    "n": {
      "id": "U1",
      "labels": ["User", "Employee"],
      "properties": {"name": "Quasar92"}
    },
    "n.name": "Quasar92"
  },
  {
    "n": {
      "id": "5944db0b-aa82-419c-bdd6-d332f0372b89",
      "labels": ["User"],
      "properties": {"name": "claire", "gender": "female"}
    },
    "n.name": "claire"
  }
]
```

Each cell value has one of the following types:

| Value Type | Fields | Example Query |
| -- | -- | -- |
| Node | `id`, `labels`, `properties` | `MATCH (n) RETURN n` |
| Edge | `id`, `label`, `fromNodeId`, `toNodeId`, `properties` | `MATCH ()-[e]->() RETURN e` |
| Path | `nodes` (array of nodes), `edges` (array of edges) | `MATCH p = ()->() RETURN p` |
| Scalar | A primitive value (integer, float, string, boolean, etc.) | `MATCH (n) RETURN n.name` |
| List | An ordered collection of values | `RETURN [1, 2, 3]` |
| Map | A collection of key-value pairs | `RETURN {a: 1, b: 2}` |

Driver libraries provide convenience methods to extract typed objects from the response. See the <a target="_blank" href="/docs/drivers">Driver Documentation</a> for details.

## Null Value

The `null` value is a special value available in all nullable types. Any non-null value is a material value.

### Null Scenarios

The `null` values can arise in various contexts, including:

- **Default Assignment:** In a closed graph, when nodes or edges are inserted, properties not explicitly provided default to `null` (unless a `NOT NULL` constraint is defined).
- **Explicit Null Specification:** During node or edge insertion, nullable properties can be intentionally set to `null`.
- **Value Removal:** Using `REMOVE` on a property sets its value to `null` in a closed graph. In an open graph, the property is removed from the node or edge.
- **New Property Assignment:** In a closed graph, when adding a new property to a type, any existing nodes or edges of that type are assigned `null` for the new property by default.
- **Nonexistent Property References:** Referencing a property that does not exist returns `null`.
- **Optional Matching:** When the `OPTIONAL` keyword is used with the `MATCH` statement, if no result is found for the pattern, `MATCH` yields `null` instead of empty return.
- **NULLIF Expression**: The `NULLIF` expression returns `null` if the two compared values are equal.

### Null in Comparisons

The `null` value is not comparable to any other value due to its inherently unknown nature. Consequently, comparisons involving `null` using normal operators such as `=` or `<>` do not typically yield true or false but rather an unknown result, also represented by `null`.

| Example | Result |
| -- | -- |
| `RETURN null = null` | `null` |
| `RETURN null > 3` | `null` |
| `RETURN [1,null,2] <> [1,null,2]` | `null` |
| `RETURN 3 IN [1,null,2]` | `null` |
| `RETURN null IN [1,2]` | `null` |
| `RETURN null IN []` | 0 |

Comparisons involving `null` require special handling with null predicates (`IS NULL` and `IS NOT NULL`).

| Example | Result |
| -- | -- |
| `RETURN null IS NULL` | 1 |
| `RETURN null IS NOT NULL` | 0 |

### Null Treatments

The `null` values receive special treatment in some contexts. For instance:

- Aggregate functions typically ignore `null` values.
- The `GROUP BY` clause groups all `null` values together.
- The `ORDER BY` statement allows for null ordering using the `NULLS FIRST` and `NULLS LAST` keywords.