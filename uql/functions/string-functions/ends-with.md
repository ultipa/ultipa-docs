# endsWith()

## Overview

The `endsWith()` function checks whether a string ends with a specified substring and returns `1` if true, and `0` if false.

## Syntax

`endsWith(str, end_str)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to be checked |
| `end_str` | String | The expected ending substring |

<b>Return type: </b>Boolean

## Example of Result

```uql
return endsWith("ultipa.com", "com")
```

Result: 1

## Example of Use

Find webpages with URLs that conclude with ".com". 

```uql
find().nodes({endsWith(@webpage.url, ".com")}) as n
return n{*}
```
