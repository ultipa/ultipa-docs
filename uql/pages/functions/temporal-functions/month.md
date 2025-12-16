# month()

## Overview

The `month()` function extracts the month of the year from a time value.

## Syntax

`month(time)`

| <div table-width=12>Augment</div> | <div table-width=31>Type</div> | Description |
| -- | -- | -- |
| `time` | Datetime, timestamp, string | The time value |

<b>Return type: </b>Integer

## Example of Result

```js
return month("2022-10-5")
```

Result: 10

## Example of Use

Retrieve reviews posted in October 2018.

```js
find().nodes({year(@review.time) == 2018 && month(@review.time) == 10}) as n
return n{*}
```
