# trim()

## Overview

The `trim()` function removes any leading and trailing spaces of a string and returns the modified string. 

## Syntax

`trim(str)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to modify |

<b>Return type: </b>String

## Example of Result

```uql
return trim("  cloud service   ")
```

Result: cloud service

## Example of Use

Remove any leading and trailing spaces from the input before saving it into the database.

```uql
with " johndoe@gmail.com  " as input
insert().into(@user).nodes({email: trim(input)})
```
