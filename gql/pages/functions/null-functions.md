# Null Functions

## coalesce()

Returns the first non-null value from the argument list.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>coalesce(&lt;expr1&gt;, &lt;expr2&gt; [, ...])</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;expr&gt;</code></td>
      <td>Any</td>
      <td>One or more expressions</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3">Type of the first non-null argument</td>
    </tr>
  </tbody>
</table>

```gql
RETURN coalesce(null, null, 42, "hello")
```

Result: 42

## nullif()

Returns `null` if the two arguments are equal; otherwise returns the first argument.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>nullif(&lt;expr1&gt;, &lt;expr2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;expr1&gt;</code></td>
      <td>Any</td>
      <td>First expression</td>
    </tr>
    <tr>
      <td><code>&lt;expr2&gt;</code></td>
      <td>Any</td>
      <td>Second expression</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3">Type of <code>&lt;expr1&gt;</code>, or <code>NULL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN nullif(5, 5), nullif(5, 3)
```

Result:

| nullif(5, 5) | nullif(5, 3) |
| -- | -- |
| `null` | 5 |
