# right()

## Overview

The `right()` function returns a substring of a given string, containing a specified number of rightmost characters. 

## Syntax

`right(str, length)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to extract substring from |
| `length` | Integer > 0 | The number of characters in the substring |

<b>Return type: </b>String

## Example of Result

```uql
return right("a database", 4)
```

Result: base

## Example of Use

Extract the last 4 characters of the certificate numbers.

```uql
find().nodes({@certificate}) as cert
return right(cert.no, 4)
```
