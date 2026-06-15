# rtrim()

## Overview

The `rtrim()` function removes any trailing spaces of a string and returns the modified string. 

## Syntax

`rtrim(str)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to modify |

<b>Return type: </b>String

## Example of Result

```uql
return rtrim("cloud    ")
```

Result: cloud

## Example of Use

Remove any trailing spaces from the input before saving it into the database.

```uql
with "johndoe@gmail.com " as input
insert().into(@user).nodes({email: rtrim(input)})
```
