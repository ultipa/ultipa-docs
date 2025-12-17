# toDecimal()

## Overview

The `toDecimal()` function converts a value to a decimal number with a specified scale.

When converting a textual value, the function only returns a valid result if the content is a pure number; otherwise, it returns `null`.

When provided with a NODE or EDGE value, the function returns its UUID.

For unsupported value types, the function returns `null`.

## Syntax

`toDecimal(value, scale)`

| <div table-width=12>Augment</div> | <div table-width=30>Type</div> | Description |
| -- | -- | -- |
| `value` | Numerical, textual, timestamp, boolean, NODE, EDGE | The value to be converted |
| `scale` | Integer ∈ [0, 30] | The number of digits to the right of the decimal point; the function takes the scale from the `value` if not set |

<b>Return type: </b>Decimal

## Example of Result

```js
return toDecimal(123.456, 2)
```

Result: 123.46

```js
return toDecimal("123.456")
```

Result: 123.456

```js
return toDecimal("123.456abc", 1)
```

Result: null