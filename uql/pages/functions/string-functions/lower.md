# lower()

## Overview

The `lower()` function converts all letters within a string to lowercase, leaving other characters unchanged, and returns the modified string.

## Syntax

`lower(str)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to be modified |

<b>Return type: </b>String

## Example of Result

```js
return lower("ABc536")
```

Result: abc536

## Example of Use

Retrieve users whose *city* property values, when converted to lowercase, match "new york".

```js
find().nodes({lower(@user.city) == "new york"}) as n
return n{*}
```
