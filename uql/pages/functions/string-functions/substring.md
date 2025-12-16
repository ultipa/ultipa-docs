# substring()

## Overview

The `substring()` function returns a substring extracted from the given string, with the specified start zero-based index and continuing for the specified number of characters.

## Syntax

`substring(str, start, length)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to extract substring from |
| `start` | Integer ≥ 0 | The index where the substring begins |
| `length` | Integer > 0 | The number of characters in the substring |

<b>Return type: </b>String

## Example of Result

```js
return substring("a database", 2, 4)
```

Result: data

## Example of Use

Extract the first 150 characters of the post content as a preview.

```js
find().nodes({@post.title == "High Density Parallel Computing"}) as post
return substring(post.content, 0, 150)
```
