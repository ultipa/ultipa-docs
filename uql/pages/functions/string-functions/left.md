# left()

## Overview

The `left()` function returns a substring of a given string, containing a specified number of leftmost characters. 

## Syntax

`left(str, length)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to extract substring from |
| `length` | Integer > 0 | The number of characters in the substring |

<b>Return type: </b>String

## Example of Result

```js
return left("a database", 6)
```

Result: a data

## Example of Use

Extract the first 4 characters of the certificate numbers.

```js
find().nodes({@certificate}) as cert
return left(cert.no, 4)
```
