# dayOfWeek()

## Overview

The `dayOfWeek()` function returns a number (from 1 to 7) indicating the day of the week of a given time value.

## Syntax

`dayOfWeek(time)`

| <div table-width=12>Augment</div> | <div table-width=31>Type</div> | Description |
| -- | -- | -- |
| `time` | Datetime, timestamp, string | The time value |

<b>Return type: </b>Integer, where `1` = Sunday and `7` = Saturaday.

## Example of Result
 
```js
return dayOfWeek("2023-04-30 22:30:35")
```

Result: 1

## Example of Use

Display the day of week for each review.

```js
find().nodes({@review}) as n
return case dayOfWeek(n.time)
when 1 then "Sunday"
when 2 then "Monday"
when 3 then "Tuesday"
when 4 then "Wednesday"
when 5 then "Thursday"
when 6 then "Friday"
else "Saturday"
end
```
