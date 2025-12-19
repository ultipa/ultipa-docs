# String Functions

## btrim()

Removes characters from both ends of a given string until encountering a character not included in the specified set of characters.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:14%;">
    <col style="width:18%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>btrim(&lt;str&gt;[, &lt;chars&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td>Textual</td>
      <td>The original string</td>
    </tr>
    <tr>
      <td><code>&lt;chars&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The set of characters to look for; it defaults to a space</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```uql
return btrim("  Ultipa Graph   ") AS newString
```

Result:

| newString |
| -- |
| `Ultipa Graph` |

```uql
return btrim("123ABC341", "123") AS newString
```

Result:

| newString |
| -- |
| ABC34 |

## endsWith()

Checks whether a string ends with a specified substring, returning `1` for true and `0` for false.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:18%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>endsWith(&lt;str&gt;, &lt;subStr&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td>Textual</td>
      <td>The input string</td>
    </tr>
    <tr>
      <td><code>&lt;subStr&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The substring to look for</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```uql
return endsWith("ultipa.com", "com")
```

Result:

| endsWith("ultipa.com", "com") |
| -- |
| 1 |

## length()

Returns the number of characters in a string.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>length(&lt;str&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td>Textual</td>
      <td>The input string</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```uql
return length("Ultipa Graph")
```

Result:

| length("Ultipa Graph") |
| -- |
| 12 |

## lower()

Converts all the characters in a given string to lowercase.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col style="width:25%;">
    <col style="width:35%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>lower(&lt;str&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td>Textual</td>
      <td>The original string</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```uql
return lower("Ultipa Graph")
```

Result:

| lower("Ultipa Graph") |
| -- |
| ultipa graph |

## ltrim()

Removes characters from the begining of a given string until encountering a character that is not contained in the specified set of characters.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:14%;">
    <col style="width:18%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ltrim(&lt;str&gt;[, &lt;chars&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td>Textual</td>
      <td>The original string</td>
    </tr>
    <tr>
      <td><code>&lt;chars&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The set of characters to look for; it defaults to a space</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```uql
return ltrim("  Ultipa Graph   ") AS newString
```

Result:

| newString |
| -- |
| `Ultipa Graph   ` |

```uql
return ltrim("124ABC341", "123") AS newString
```

Result:

| newString |
| -- |
| 4ABC341 |

## rtrim()

Removes characters from the end of a given string until encountering a character that is not contained in the specified set of characters.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:14%;">
    <col style="width:18%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>rtrim(&lt;str&gt;[, &lt;chars&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td>Textual</td>
      <td>The original string</td>
    </tr>
    <tr>
      <td><code>&lt;chars&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The set of characters to look for; it defaults to a space</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```uql
return rtrim("  Ultipa Graph   ") AS newString
```

Result:

| newString |
| -- |
| `  Ultipa Graph` |

```uql
return rtrim("123ABC4321", "123") AS newString
```

Result:

| newString |
| -- |
| 123ABC4 |

## split()

Splits a string into a list of substrings using the specified delimiter.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:18%;">
    <col style="width:18%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>split(&lt;str&gt;, &lt;delimiter&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td>Textual</td>
      <td>The input string</td>
    </tr>
    <tr>
      <td><code>&lt;delimiter&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The delimiter</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```uql
return split("apple, pumpkin, lemon tart", ", ") as strList
```

Result:

| strList |
| -- |
| ["apple","pumpkin","lemon tart"] |

## startsWith()

Checks whether a string begins with a specified substring and returns `1` for true or `0` for false.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:18%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>startsWith(&lt;str&gt;, &lt;subStr&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td>Textual</td>
      <td>The input string</td>
    </tr>
    <tr>
      <td><code>&lt;subStr&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The substring to look for</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```uql
return startsWith("ultipa.com", "ultipa")
```

Result:

| startsWith("ultipa.com", "ultipa") |
| -- |
| 1 |

## upper()

Converts all the characters in a given string to uppercase.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col style="width:25%;">
    <col style="width:35%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>upper(&lt;str&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td>Textual</td>
      <td>The original string</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```uql
return upper("Ultipa Graph")
```

Result:

| upper("Ultipa Graph") |
| -- |
| ULTIPA GRAPH |
