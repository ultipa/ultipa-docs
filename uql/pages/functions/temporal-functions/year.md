# year()

## Overview

The `year()` function extracts the year from a time value.

## Syntax

`year(time)`

| <div table-width=12>Augment</div> | <div table-width=31>Type</div> | Description |
| -- | -- | -- |
| `time` | Datetime, timestamp, string | The time value |

<b>Return type: </b>Integer

## Example of Result

```js
return year("2022-10-5")
```

Result: 2022

## Example of Use

Retrieve reviews posted in 2018.

```js
find().nodes({year(@review.time) == 2018}) as n
return n{*}
```
