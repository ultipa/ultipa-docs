# Type Conversion Functions

## cast()

Converts a value to the specified type.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>cast(&lt;value&gt; AS &lt;type&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Any</td>
      <td>The value to convert</td>
    </tr>
    <tr>
      <td><code>&lt;type&gt;</code></td>
      <td>/</td>
      <td>Target type (see supported types below)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3">As specified by <code>&lt;type&gt;</code></td>
    </tr>
  </tbody>
</table>

Supported target types:

| Category | Types |
| -- | -- |
| Integer | `INT`, `INTEGER`, `INT8`, `INT16`, `INT32`, `INT64`, `UINT`, `UINT8`, `UINT16`, `UINT32`, `UINT64` |
| Float | `FLOAT`, `FLOAT32`, `FLOAT64`, `DOUBLE`, `DECIMAL`, `REAL` |
| String | `STRING`, `TEXT`, `VARCHAR` |
| Boolean | `BOOL`, `BOOLEAN` |
| Temporal | `DATE`, `LOCAL TIME`, `LOCAL DATETIME`, `TIMESTAMP`, `ZONED DATETIME`, `DURATION` |
| Collection | `LIST`, `RECORD` |
| Binary | `BYTES`, `BINARY` |

```gql
RETURN cast(1 AS STRING), cast("42" AS INT), cast("true" AS BOOL)
```

## to_integer()

Converts a value to an integer. Returns `null` if conversion is not possible.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>to_integer(&lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td><code>INT</code>, <code>FLOAT</code>, <code>BOOL</code>, or <code>STRING</code></td>
      <td>The value to convert</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN to_integer("42"), to_integer(3.7), to_integer(true)
```

Result: 42, 3, 1

## to_float()

Converts a value to a float. Returns `null` if conversion is not possible.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>to_float(&lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td><code>FLOAT</code>, <code>INT</code>, <code>BOOL</code>, or <code>STRING</code></td>
      <td>The value to convert</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN to_float("3.14"), to_float(42), to_float(true)
```

Result: 3.14, 42, 1

## to_string()

Converts a value to a string. Returns `null` if conversion is not possible.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>to_string(&lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Any</td>
      <td>The value to convert</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN to_string(42), to_string(3.14), to_string(true)
```

Result: "42", "3.14", "true"

## to_boolean()

Converts a value to a boolean. Returns `null` if conversion is not possible. Accepted string values: `"true"`, `"t"`, `"yes"`, `"y"`, `"1"` for `true`; `"false"`, `"f"`, `"no"`, `"n"`, `"0"` for `false` (case-insensitive).

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>to_boolean(&lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td><code>BOOL</code>, <code>INT</code>, <code>FLOAT</code>, or <code>STRING</code></td>
      <td>The value to convert</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN to_boolean("true"), to_boolean(1), to_boolean("yes")
```

Result: true, true, true

## to_list()

Converts a value to a list. Strings are split into a list of characters. Paths are converted to a list of alternating nodes and edges. Other values are wrapped in a single-element list.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>to_list(&lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Any</td>
      <td>The value to convert</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN to_list("hello")
```

Result: ["h", "e", "l", "l", "o"]

## to_map()

Creates a record (map) from key-value pairs.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>to_map(&lt;key1&gt;, &lt;value1&gt; [, &lt;key2&gt;, &lt;value2&gt;, ...])</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;key&gt;</code></td>
      <td><code>STRING</code></td>
      <td>A key name</td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Any</td>
      <td>The value for the preceding key</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>RECORD</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN to_map("name", "Alice", "age", 30)
```

Result: {"name": "Alice", "age": 30}
