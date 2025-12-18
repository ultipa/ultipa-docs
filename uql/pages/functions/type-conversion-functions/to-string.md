# toString()

## Overview

The `toString()` function converts a value to a string.

## Syntax

`toString(value)`

| <div table-width=20>Augment</div> | <div table-width=20>Type</div> | Description |
| -- | -- | -- |
| `value` | Any | The value to be converted |

<b>Return type: </b>String

## Example of Result

```uql
return toString([24, 20, 12])
```

Result: [24,20,12]

```uql
return toString(0.000000001)
```

Result: 1e-09
