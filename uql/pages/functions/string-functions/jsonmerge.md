# JSON_merge()

## Overview

The `JSON_merge()` function merges two JSON-formatted strings into a new JSON-formatted string and returns the result. When there are conflicting keys between the two input strings, the values from the second string take precedence in the merged output.

## Syntax

`JSON_merge(str_1, str_2)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str_1` | String | The first JSON-formatted string |
| `str_2` | String | The second JSON-formatted string |

<b>Return type: </b>String

## Example of Result

```js
return JSON_merge('{"name":"Lisa","age":23}','{"name":"Lisa","age":30,"interest":"football"}')
```

Result: {"age":30,"interest":"football","name":"Lisa"}

> It's advisable to use distinct quotation marks (`"` or `'`) within JSON objects and to encapsulate the two input strings. The pairing of these quotation marks is essential for the correct parsing of the statement.

## Example of Use

Consolidate information from different sources into a single JSON object, preserving unique keys and their corresponding values.

```js
with '{
  "name": "John Doe",
  "age": 30,
  "city": "New York"
}' as s1
with '{
  "name": "John Doe",
  "age": 29,
  "email": "john.doe@example.com"
}' as s2
return JSON_merge(s1, s2)
```

Result: {"age":29,"city":"New York","email":"john.doe@example.com","name":"John Doe"}
