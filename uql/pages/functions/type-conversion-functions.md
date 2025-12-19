# Type Conversion Functions

# toDouble()

Converts a value to a double-precision floating-point number.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:25%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>toDouble(&lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Numeric, Textual</td>
      <td>The input value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DOUBLE</code></td>
    </tr>
  </tbody>
</table>

```uql
uncollect [-36.123456789012345, "-36.123abc", "a10"] as item
return table(item, toDouble(item))
```

Result:

| item | toDouble(item) |
| -- | -- |
| -36.1234567890123 | 36.1234567890123 |
| -36.123abc | -36.123 |
| a10 | 0 |

# toFloat()

Converts a value to a single-precision floating-point number.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:25%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>toFloat(&lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Numeric, Textual</td>
      <td>The input value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```uql
uncollect [-36.123456789012345, "-36.123abc", "a10"] as item
return table(item, toFloat(item))
```

Result:

| item | toFloat(item) |
| -- | -- |
| -36.1234567890123 | -36.12346 |
| -36.123abc | -36.123 |
| a10 | 0 |

# toInteger()

Converts a value to a 64-bit integer.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:25%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>toInteger(&lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Numeric, Textual</td>
      <td>The input value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT64</code></td>
    </tr>
  </tbody>
</table>

```uql
uncollect [-36.123456789012345, "-36.123abc", "a10"] as item
return table(item, toInteger(item))
```

Result:

| item | toInteger(item) |
| -- | -- |
| -36.1234567890123 | -36 |
| -36.123abc | -36 |
| a10 | 0 |

# toString()

Converts a value to a string.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:25%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>toString(&lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Numeric, Textual</td>
      <td>The input value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```uql
uncollect [24, 0.000000001, [23,21]] as item
return toString(item)
```

Result:

| toString(item) |
| -- |
| 24 |
| 1e-09 |
| [23,21] |
