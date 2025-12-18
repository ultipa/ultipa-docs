# toInteger()

## Overview

The `toInteger()` function converts a value to a 64-bit integer. 

When converting a textual value, the function only returns a valid result if the text begins with a number; otherwise, it returns `0`.

When provided with a NODE or EDGE value, the function returns its UUID.

For unsupported value types, the function returns `null`.

## Syntax

`toInteger(value)`

| <div table-width=12>Augment</div> | <div table-width=40>Type</div> | Description |
| -- | -- | -- |
| `value` | Numerical, textual, timestamp, boolean, NODE, EDGE | The value to be converted |

<b>Return type: </b>Int64

## Example of Result

```uql
return toInteger(-3456.7)
```

Result: -3456

```uql
return toInteger("-34.5ABC")
```

Result: -34