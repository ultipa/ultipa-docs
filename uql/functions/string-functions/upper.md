# upper()

## Overview

The `upper()` function converts all letters within a string to uppercase, leaving other characters unchanged, and returns the modified string.

## Syntax

`upper(str)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to be modified |

<b>Return type: </b>String

## Example of Result

```uql
return upper("abc536")
```

Result: ABC536

## Example of Use

Retrieve posts and showcase their titles in uppercase format.

```uql
find().nodes({@post}) as posts
return upper(posts.title)
```
