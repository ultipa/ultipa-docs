# ltrim()

## Overview

The `ltrim()` function removes any leading spaces of a string and returns the modified string. 

## Syntax

`ltrim(str)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to modify |

<b>Return type: </b>String

## Example of Result

```uql
return ltrim("    cloud")
```

Result: cloud

## Example of Use

Remove any leading spaces from the input before saving it into the database.

```uql
with " johndoe@gmail.com" as input
insert().into(@user).nodes({email: ltrim(input)})
```
