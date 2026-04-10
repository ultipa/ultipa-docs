# String Functions

## char_length()

Returns the number of characters in a string. `character_length()` and `length()` are synonyms.

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
      <td colspan="3"><code>char_length(&lt;str&gt;)</code></td>
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

```gql
RETURN char_length("Ultipa Graph")
```

Result: 12

## byte_length()

Returns the number of bytes in a string. `octet_length()` is a synonym to `byte_length()`.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>byte_length(&lt;str&gt;)</code> or <code>octet_length(&lt;str&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The input string</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN byte_length("hello"), byte_length("你好")
```

Result:

| byte_length("hello") | byte_length("你好") |
| -- | -- |
| 5 | 6 |

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

```gql
RETURN lower("Ultipa Graph")
```

Result: "ultipa graph"

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

```gql
RETURN upper("Ultipa Graph")
```

Result: "ULTIPA GRAPH"

## left()

Returns a substring of the given string containing the specified number of leftmost characters.

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
      <td colspan="3"><code>left(&lt;str&gt;, &lt;length&gt;)</code></td>
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
      <td><code>&lt;length&gt;</code></td>
      <td><code>UINT</code></td>
      <td>Length of the substring</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN left("Ultipa Graph", 6)
```

Result: "Ultipa"

## right()

Returns a substring of the given string containing the specified number of rightmost characters.

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
      <td colspan="3"><code>right(&lt;str&gt;, &lt;length&gt;)</code></td>
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
      <td><code>&lt;length&gt;</code></td>
      <td><code>UINT</code></td>
      <td>Length of the substring</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN right("Ultipa Graph", 5)
```

Result: "Graph"

## substring()

Returns a substring of a given length from the given string, beginning with a 0-based index start. `substr()` is a synonym to `substring()`.

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
      <td colspan="3"><code>substring(&lt;str&gt;, &lt;startIndex&gt;, &lt;length&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
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
      <td><code>&lt;startIndex&gt;</code></td>
      <td>Integer</td>
      <td>The start position of the new string.</td>
    </tr>
    <tr>
      <td><code>&lt;length&gt;</code></td>
      <td>Integer</td>
      <td>The length of the substring.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN substring("crystal hawk river", 0, 7)
```

Result: "crystal"

## trim()

Removes all the occurrences of the specified single character from either the leftmost, rightmost, or both ends of a given string.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:13%;">
    <col style="width:15%;">
    <col>
    <col style="width:18%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="4"><code>trim([[&lt;spec&gt;] [&lt;char&gt;] FROM] &lt;str&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
      <td><b>Note</b></td>
    </tr>
    <tr>
      <td><code>&lt;spec&gt;</code></td>
      <td>/</td>
      <td>The trim specification keyword:<ul><li><code>BOTH</code> (default) removes every leading and trailing character equals to <code>&lt;char&gt;</code> from <code>&lt;str&gt;</code></li><li><code>LEADING</code> removes every leading character equals to <code>&lt;char&gt;</code> from <code>&lt;str&gt;</code></li><li><code>TRAILING</code> removes every trailing character equals to <code>&lt;char&gt;</code> from <code>&lt;str&gt;</code></li></ul></td>
      <td rowspan="2">If <code>FROM</code> is specified, then at least one of <code>&lt;spec&gt;</code> and <code>&lt;char&gt;</code> shall be specified.</td>
    </tr>
    <tr>
      <td><code>&lt;char&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The character to look for; it defaults to a space</td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td>Textual</td>
      <td>The original string</td>
      <td>/</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="4"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN trim("  Ultipa Graph   ") AS newString
```

Result: "Ultipa Graph"

```gql
RETURN trim(BOTH "a" FROM "aaGraph DBa") AS newString
```

Result: "Graph DB"

```gql
RETURN trim(LEADING "a" FROM "aaGraph DBa") AS newString
```

Result:

| newString |
| -- |
| Graph DBa |

```gql
RETURN trim(TRAILING FROM "  Graph DB   ") AS newString
```

Result: "  Graph DB"

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

```gql
RETURN ltrim("  Ultipa Graph   ") AS newString
```

Result: "Ultipa Graph   "

```gql
RETURN ltrim("124ABC341", "123") AS newString
```

Result: "4ABC341"

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

```gql
RETURN rtrim("  Ultipa Graph   ") AS newString
```

Result: "  Ultipa Graph"

```gql
RETURN rtrim("123ABC4321", "123") AS newString
```

Result: "123ABC4"

## btrim()

Removes characters from both ends of a given string until encountering a character that is not contained in the specified set of characters.

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

```gql
RETURN btrim("  Ultipa Graph   ") AS newString
```

Result: "Ultipa Graph"

```gql
RETURN btrim("123ABC341", "123") AS newString
```

Result: "ABC34"

## replace()

Returns a string where all occurrences of a specified substring are replaced with another string.

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
      <td colspan="3"><code>replace(&lt;str&gt;, &lt;find&gt;, &lt;replace&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
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
      <td><code>&lt;find&gt;</code></td>
      <td>Textual</td>
      <td>The substring to search for within the original string.</td>
    </tr>
    <tr>
      <td><code>&lt;replace&gt;</code></td>
      <td>Textual</td>
      <td>The new string that replaces each occurrence of the search string.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN replace("hello world", "world", "graph") AS result
```

Result: "hello graph"

## split()

Returns a list of string resulting from the splitting of the given string around matches of the given delimiter.

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
      <td>The original string</td>
    </tr>
    <tr>
      <td><code>&lt;delimiter&gt;</code></td>
      <td>Textual</td>
      <td>The delimiter string with which to split the original string.</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST&lt;STRING&gt;</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN split("apple,banana,grape", ",")
```

Result: ["apple","banana","grape"]

```gql
RETURN split("appleLEE@gmail.com", "@")[0] AS username
```

Result: "appleLEE"

## contains()

Returns `true` if a string contains the specified substring.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>contains(&lt;str&gt;, &lt;substring&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The input string</td>
    </tr>
    <tr>
      <td><code>&lt;substring&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The substring to search for</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN contains("Graph Database", "Graph")
```

Result: true

## starts_with()

Returns `true` if a string starts with the specified prefix.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>starts_with(&lt;str&gt;, &lt;prefix&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The input string</td>
    </tr>
    <tr>
      <td><code>&lt;prefix&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The prefix to check</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN starts_with("Graph Database", "Graph")
```

Result: true

## ends_with()

Returns `true` if a string ends with the specified suffix.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ends_with(&lt;str&gt;, &lt;suffix&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The input string</td>
    </tr>
    <tr>
      <td><code>&lt;suffix&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The suffix to check</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ends_with("Graph Database", "Database")
```

Result: true

## normalize()

Converts a string into a consistent format based on the normalization form specified, in accordance with <a target="_blank" href="https://www.unicode.org/reports/tr15/">Unicode Standard Annex #15</a>.

This function is typically used to compare two strings by their Unicode codepoints. Two characters appear identical to human eyes may have different codepoints, such as the multiplication sign `×` (U+00D7) and the letter `x` (U+0078).

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:13%;">
    <col style="width:15%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>normalize(&lt;str&gt;[, &lt;form&gt;])</code></td>
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
      <td><code>&lt;form&gt;</code></td>
      <td>/</td>
      <td>The normalzation form (NF) keyword:<ul><li><code>NFC</code> (default): Canonical Composition. Characters are composed into their most composed forms. E.g., <code>Å</code> (U+00C5) as a single character.</li><li><code>NFD</code>: Canonical Decomposition. Characters are decomposed into their constituent parts. E.g., <code>Å</code> (U+00C5) becomes <code>A</code> (U+0041) + <code>◌̊ </code> (U+030A).</li><li><code>NFKC</code>: Similar to <code>NFC</code> but also replaces compatibility characters with their canonical equivalents. E.g., <code>2⁵</code> (U+0032 U+2075) becomes <code>25</code> (U+0032 U+0035).</li><li><code>NFKD</code>: Similar to <code>NFD</code> but also replaces compatibility characters with their canonical equivalents. E.g., <code>2⁵</code> (U+0032 U+2075) becomes <code>25</code> (U+0032 U+0035).</li></ul></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN normalize('×') = normalize('x')
```

Result: false

## hex()

Encodes a string or bytes value to a hexadecimal string.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>hex(&lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td><code>STRING</code>, <code>BYTES</code></td>
      <td>The input value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN hex("hello")
```

Result: "68656c6c6f"

## unhex()

Decodes a hexadecimal string to bytes.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>unhex(&lt;hexStr&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;hexStr&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The hexadecimal string</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN unhex("68656c6c6f")
```

Result:

```json
{
  "0": 104,
  "1": 101,
  "2": 108,
  "3": 108,
  "4": 111
}
```

## base64()

Encodes a string to a Base64 string.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>base64(&lt;str&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;str&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The input string</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN base64("hello")
```

Result: "aGVsbG8="

## unbase64()

Decodes a Base64 string to bytes.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>unbase64(&lt;base64Str&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;base64Str&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The Base64 encoded string</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN unbase64("aGVsbG8=")
```

Result:

```json
{
  "0": 104,
  "1": 101,
  "2": 108,
  "3": 108,
  "4": 111
}
```
