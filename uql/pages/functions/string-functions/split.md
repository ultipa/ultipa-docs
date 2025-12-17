# split()

## Overview

The `split()` function divides a string into smaller strings based on the given delimiter, returning a list of the resulting substrings.

## Syntax

`split(str, delimiter)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string to be divided |
| `delimiter` | String | The delimiter |

<b>Return type: </b>String[]

## Example of Result

```js
return split("apple, pumpkin, lemon tart", ", ")
```

Result: ["apple","pumpkin","lemon tart"]

## Example of Use

Use a space to split the values of the *genre* property of the *@movie* node (such as "crime drama romance"), expand the list elements into individual data entries and deduplicate all entries. 

```js
find().nodes({@movie}) as mov
with split(mov.genre, " ") as genreList
uncollect genreList as genre
return DISTINCT genre
```