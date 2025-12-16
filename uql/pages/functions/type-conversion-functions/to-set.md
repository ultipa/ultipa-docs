# toSet()

## Overview

The `toSet()` function deduplicates the elements in a list and converts it to a set. If provided with a non-list-type value, it wraps it into a set.

## Syntax

`toSet(value)`

| <div table-width=20>Augment</div> | <div table-width=20>Type</div> | Description |
| -- | -- | -- |
| `value` | Any | The value to be converted |

<b>Return type: </b>Set

## Example of Result

```js
return toSet([1,2,3,4,3,2])
```

Result: [4,3,1,2]

```js
return toSet("abc")
```

Result: ["abc"]
