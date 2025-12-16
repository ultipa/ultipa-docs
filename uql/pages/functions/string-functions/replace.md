# replace()

## Overview

The `replace()` function searches for all occurrences of a given string in a string, and replaces them with another specified string, returning the resulting new string.

## Syntax

`replace(str, find, replace)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The string whose substrings are to be found and replaced |
| `find` | String | The string to be searched for and replaced |
| `replace` | String | The string to replace `find` |

<b>Return type: </b>String

## Example of Result

```js
return replace("ultipa graph", "u", "U")
```

Result: Ultipa graph

## Example of Use

Update the values of *gender* property of the *@account* nodes ("female" or "male") by replacing their first letters with their capitalizations.

```js
find().nodes({@account}) as acc
return case acc.gender
when "female" then replace(acc.gender, "f", "F")
else replace(acc.gender, "m", "M")
end
```
