# dateAdd()

## Overview

The `dateAdd()` function adds a specified time interval to a given time and returns the result.

## Syntax

`dateAdd(time, interval, unit)`

| <div table-width=12>Augment</div> | <div table-width=31>Type</div> | Description |
| -- | -- | -- |
| `time` | Datetime, timestamp, string | The orginal time |
| `interval` | Integer | The value of time interval to add |
| `unit` | string | The unit of the `interval`, which can be set as `year`, `month`, `day`, `hour`, `minute`, or `second` |

<b>Return type: </b>Datetime

## Example of Result

```uql
return dateAdd("1970-01-01 10:00:00", -1, "hour")
```

Result: 1970-01-01 09:00:00

## Example of Use

Extend all memberships by 3 days and 12 hours.

```uql
update().nodes({@membership}).set({
  expiry: dateAdd(dateAdd(expiry, 3, "day"), 12, "hour")
})
```
