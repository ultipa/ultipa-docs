# dateFormat()

## Overview

The `dateFormat()` function prints a specific format for a given time value.

## Syntax

`dateFormat(time, format)`

| <div table-width=12>Augment</div> | <div table-width=31>Type</div> | Description |
| -- | -- | -- |
| `time` | Datetime, timestamp, string | The time value |
| `format` | String | The format to print the time |

<b>Date/Time format codes:</b>

| <div table-width=8>Code</div> | <div table-width=58>Description</div> | Examples / Range |
|-|-| - |
| `%a` | Abbreviated weekday name in the system language  | (en_US) Sun, Mon |
| `%A` | Full weekday name in the system language | (en_US) Sunday, Monday |
| `%b` | Abbreviated month name in the system language | (en_US) Jan, Feb |
| `%B` | Full month name in the system language | (en_US) January, February |
| `%c` | Default date and time format in the system settings | Wed Jan 11 10:59:28 2023 |
| `%C` | Century number (year/100) in 2 digits | 00, 01, ..., 99 |
| `%d` | Day of the month (zero-padded) | 01, 02, ..., 31 |
| `%D` | Equivalent to `%m/%d/%y` | 01/11/23 |
| `%e` | Day of the month | 1, 2, ..., 31 |
| `%Ez` | Time zone | +08:00 |
| `%g` | Year without the century | 00, 01, ..., 99 |
| `%G` | Year in 4 digits | 0000, 0001, ..., 9999 |
| `%h` | Equivalent to `%b` | See `%b` |
| `%H` | Hour using a 24-hour clock (zero-padded)  | 00, 01, ..., 23 |
| `%I` | Hour using a 12-hour clock (zero-padded) | 01, 02, ..., 12 |
| `%j` | Day of the year (zero-padded) | 001, 002, ..., 366 |
| `%m` | Month of the year (zero-padded) | 01, 02, ..., 12 |
| `%M` | Minute (zero-padded) | 00, 01, ..., 59 |
| `%n` | Line break | |
| `%p` | Either 'AM' or 'PM' according to the given time value | (en_US) AM, PM |
| `%P` | Either 'am' or 'pm' according to the given time value | (en_US) am, pm   |
| `%r` | Equivalent to `%I/%M/%S %p` | 01:49:23 AM |
| `%R` | Equivalent to `%H:%M` | 13:49 |
| `%S` | Second (zero-padded) | 00, 01, ..., 59 |
| `%t` | Tab | |
| `%T` | Equivalent to `%H:%M:%S` | 23:02:05 |
| `%u` | Day number of the week, Monday being 1 (Sunday being 1 in a Sun Solaris system) | 1, 2, ..., 7 |
| `%U` | Week number of the year (zero-padded), starting with the first Sunday as the first day of week 01 | 00, 01, ..., 53 |
| `%V` | Week number of year (zero-padded), with Monday as the first day of the week, week 01 is the first week that has at least 4 days in the current year | 01, 02, ..., 53 |
| `%W` | Week number of the year (zero-padded), starting with the first Monday as the first day of week 01 | 00, 01, ..., 53
| `%w` | Day number of the week, Sunday being 0 | 0, 1, ..., 6 |
| `%x` | Default date format in the system settings | 01/11/23 |
| `%X` | Default time format in the system settings | 06:38:45 |
| `%y` | Equivalent to `%g` | See `%g` |
| `%Y` | Equivalent to `%G` | See `%G` |
| `%z` | Offset from UTC in the format of `±HHMM[SS]` | +0000, -0400, +1030, ... |
| `%Z` | Name of the time zone | GMT, UTC, IST, CST, ... |
| `%%` | Character % | % |

<b>Return type: </b>String

## Example of Result

```uql
return dateFormat("2010/9/25 6:12:30","%A %e %B, %G")
```

Result: Saturday 25 September, 2010

## Example of Use

Display the times of reviews in a desired format.

```uql
find().nodes({@review}) as n
return dateFormat(n.time,"%e %b, %G")
```