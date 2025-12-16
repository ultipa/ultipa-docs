# reverse()

## Overview

The `reverse()` function returns a string with the order of characters reversed from the given string.

## Syntax

`reverse(str)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string whose characetrs need to be reversed |

<b>Return type: </b>String

## Example of Result

```js
return reverse("abc")
```

Result: cba

## Example of Use

Retrieve API keys but reverse their characters for security concerns.

```js
find().nodes({@api}) as apis
return reverse(apis.key)
```
