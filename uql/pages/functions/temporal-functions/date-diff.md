# dateDiff()

## Overview

The `dateDiff()` function calculates the time interval in the specified unit between two given time values (`end_time` - `start_time`) and returns the integer part of the interval.

## Syntax

`dateDiff(end_time, start_time, unit)`

| <div table-width=12>Augment</div> | <div table-width=31>Type</div> | Description |
| -- | -- | -- |
| `end_time` | Datetime, timestamp, string | The end time |
| `start_time` | Datetime, timestamp, string | The start time |
| `unit` | string | The unit of the interval, which can be set as `day`, `hour`, `minute`, or `second` |

<b>Return type: </b>Integer

## Example of Result

```uql
return dateDiff("1970-01-01 10:00:00", "1970-01-01 12:00:20", "minute")
```

Result: -120

## Example of Use

Retrieve employees who have worked for over 730 days.

```uql
find().nodes({@employee}) as e
where dateDiff(now(), e.startDate, "day") > 730
return table(e.name, e.startDate) order by e.startDate
```
