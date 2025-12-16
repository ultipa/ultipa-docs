# day()

## Overview

The `day()` function extracts the day of the month from a time value.

## Syntax

`day(time)`

| <div table-width=12>Augment</div> | <div table-width=31>Type</div> | Description |
| -- | -- | -- |
| `time` | Datetime, timestamp, string | The time value |

<b>Return type: </b>Integer

## Example of Result

```js
return day("2022-10-05")
```

Result: 5

## Example of Use

Retrieve reviews posted on 11 October each year.

```js
find().nodes({month(@review.time) == 10 && day(@review.time) == 11}) as n
return n{*}
```
