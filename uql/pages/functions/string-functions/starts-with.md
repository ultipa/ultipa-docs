# startsWith()

## Overview

The `startsWith()` function checks whether a string starts with a specified substring and returns `1` if true, and `0` if false.

## Syntax

`startsWith(str, start_str)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to be checked |
| `start_str` | String | The expected starting substring |

<b>Return type: </b>Boolean

## Example of Result

```js
return startsWith("ultipa.com", "Ultipa")
```

Result: 0

## Example of Use

Find webpages with URLs that begin with "https://". 

```js
find().nodes({startsWith(@webpage.url, "https://")}) as n
return n{*}
```
