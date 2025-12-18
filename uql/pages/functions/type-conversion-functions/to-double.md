# toDouble()

## Overview

The `toDouble()` function converts a value to a double-precision floating-point number.

When converting a textual value, the function only returns a valid result if the text begins with a number; otherwise, it returns `0`.

When provided with a NODE or EDGE value, the function returns its UUID.

For unsupported value types, the function returns `null`.

## Syntax

`toDouble(value)`

| <div table-width=12>Augment</div> | <div table-width=40>Type</div> | Description |
| -- | -- | -- |
| `value` | Numerical, textual, timestamp, boolean, NODE, EDGE | The value to be converted |

<b>Return type: </b>Double

## Example of Result
 
```uql
return toDouble(-36.123456789012345)
```

Result: -36.1234567890123

```uql
return toDouble("-36.1234abc")
```

Result: -36.1234