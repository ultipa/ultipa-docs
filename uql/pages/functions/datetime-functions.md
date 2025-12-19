# Datetime Functions

# Datetime Value Functions

A datetime value function returns a temporal instant value.

## date()

Returns a value of type `DATE`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>date([&lt;param&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;param&gt;</code></td>
      <td><code>STRING</code> or <code>MAP</code></td>
      <td>Either a date string (<a href="#Datetime-String-Format">format</a>) or a map with the fields <code>year</code>, <code>month</code>, and <code>day</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DATE</code></td>
    </tr>
  </tbody>
</table>

When called without a parameter, `date()` returns the current session date (or the server date if no session timezone is set). It is equivalent to `current_date`.

```uql
return date(), current_date
```

Result:

| date() | current_date |
| -- | -- |
| 2025-08-21 | 2025-08-21 |

The parameter should match one of the supported formats:

```uql
uncollect [
  date("1993-05-09"),
  date("19930509"),
  date({year: 1993, month: 5, day: 9}),
  date({year: 1993, month: 5}),
  date({year: 1993})
] as value
return value
```

Result:

| value |
| -- |
| 1993-05-09 |
| 1993-05-09 |
| 1993-05-09 |
| 1993-05-01 |
| 1993-01-01 |

## local_datetime()

Returns a value of type `LOCAL DATETIME`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>local_datetime([&lt;param&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;param&gt;</code></td>
      <td><code>STRING</code> or <code>MAP</code></td>
      <td>Either a datetime string (<a href="#Datetime-String-Format">format</a>) or a map with the fields <code>year</code>, <code>month</code>, <code>day</code>, <code>hour</code>, <code>minute</code>, <code>second</code>, and one of <code>millisecond</code> (3 digits), <code>microsecond</code> (6 digits), or <code>nanosecond</code> (9 digits)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LOCAL DATETIME</code></td>
    </tr>
  </tbody>
</table>

When called without a parameter, `local_datetime()` returns the current session datetime (or the server datetime if no session timezone is set). It is equivalent to `local_timestamp`.

```uql
return local_datetime(), local_timestamp
```

Result:

| local_datetime() | local_timestamp |
| -- | -- |
| 2025-08-21 15:20:30.625790824 | 2025-08-21 15:20:30.625790824 |

The parameter should match one of the supported formats:

```uql
uncollect [
  local_datetime("1993-05-09T03:02:11.70"),
  local_datetime("1993-05-09 03:02:11.70"),
  local_datetime("19930509T030211"),
  local_datetime("19930509 030211"),
  local_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11, millisecond: 70}),
  local_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11, microsecond: 70}),
  local_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11, nanosecond: 70}),
  local_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11}),
  local_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2}),
  local_datetime({year: 1993, month: 5, day: 9, hour: 3})
] as value
return value
```

Result:

| value |
| -- |
| 1993-05-09 03:02:11.7 |
| 1993-05-09 03:02:11.7 |
| 1993-05-09 03:02:11 |
| 1993-05-09 03:02:11 |
| 1993-05-09 03:02:11.07 |
| 1993-05-09 03:02:11.00007 |
| 1993-05-09 03:02:11.00000007 |
| 1993-05-09 03:02:11 |
| 1993-05-09 03:02:00 |
| 1993-05-09 03:00:00 |

## local_time()

Returns a value of type `LOCAL TIME`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>local_time([&lt;param&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;param&gt;</code></td>
      <td><code>STRING</code> or <code>MAP</code></td>
      <td>Either a time string (<a href="#Datetime-String-Format">format</a>) or a map with the fields <code>hour</code>, <code>minute</code>, <code>second</code>, and one of <code>millisecond</code> (3 digits), <code>microsecond</code> (6 digits), or <code>nanosecond</code> (9 digits)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LOCAL TIME</code></td>
    </tr>
  </tbody>
</table>

When called without a parameter, `local_time()` returns the current session time (or the server time if no session timezone is set).

```uql
return local_time()
```

Result:

| local_time() |
| -- |
| 15:20:30.625790824 |

The parameter should match one of the supported formats:

```uql
uncollect [
  local_time("03:02:11.70"),
  local_time("030211.70"),
  local_time("03:02:11"),
  local_time("030211"),
  local_time({hour: 3, minute: 2, second: 11, millisecond: 70}),
  local_time({hour: 3, minute: 2, second: 11, microsecond: 70}),
  local_time({hour: 3, minute: 2, second: 11, nanosecond: 70}),
  local_time({hour: 3, minute: 2, second: 11}),
  local_time({hour: 3, minute: 2}),
  local_time({hour: 3})
] as value
return value
```

Result:

| value |
| -- |
| 03:02:11.7 |
| 03:02:11.7 |
| 03:02:11 |
| 03:02:11 |
| 03:02:11.07 |
| 03:02:11.00007 |
| 03:02:11.00000007 |
| 03:02:11 |
| 03:02:00 |
| 03:00:00 |

## now()

Returns the current datetime in Coordinated Universal Time (UTC).

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td><code>now()</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td><code>DATETIME</code></td>
    </tr>
  </tbody>
</table>

```uql
return now()
```

Result:

| now() |
| -- |
| 2025-08-21 09:20:30.625790824 |

## zoned_datetime()

Returns a value of type `ZONED DATETIME`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>zoned_datetime([&lt;param&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;param&gt;</code></td>
      <td><code>STRING</code> or <code>MAP</code></td>
      <td>Either a datetime string (<a href="#Datetime-String-Format">format</a>) or a map with the fields <code>year</code>, <code>month</code>, <code>day</code>, <code>hour</code>, <code>minute</code>, <code>second</code>, one of <code>millisecond</code> (3 digits), <code>microsecond</code> (6 digits), or <code>nanosecond</code> (9 digits), as well as <code>timezone</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>ZONED DATETIME</code></td>
    </tr>
  </tbody>
</table>

When called without a parameter, `zoned_datetime()` returns the current session datetime (or the server datetime if no session timezone is set). It is equivalent to `current_timestamp`.

```uql
return zoned_datetime(), current_timestamp
```

Result:

| zoned_datetime() | current_timestamp |
| -- | -- |
| 2025-08-21 15:20:30.625790824-0600 | 2025-08-21 15:20:30.625790824-0600 |

The parameter should match one of the supported formats:

```uql
uncollect [
  zoned_datetime("1993-05-09T03:02:11.70-0600"),
  zoned_datetime("1993-05-09 03:02:11.70-06:00"),
  zoned_datetime("19930509T030211-06:00"),
  zoned_datetime("19930509 030211-0600"),
  zoned_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11, millisecond: 70, timezone: -0600}),
  zoned_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11, microsecond: 70, timezone: -0600}),
  zoned_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11, nanosecond: 70, timezone: -0600}),
  zoned_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11, timezone: -0600}),
  zoned_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, timezone: -0600}),
  zoned_datetime({year: 1993, month: 5, day: 9, hour: 3, timezone: -0600})
] as value
return value
```

Result:

| value |
| -- |
| 1993-05-09 03:02:11.7-0600 |
| 1993-05-09 03:02:11.7-0600 |
| 1993-05-09 03:02:11-0600 |
| 1993-05-09 03:02:11-0600 |
| 1993-05-09 03:02:11.07-0600 |
| 1993-05-09 03:02:11.00007-0600 |
| 1993-05-09 03:02:11.00000007-0600 |
| 1993-05-09 03:02:11-0600 |
| 1993-05-09 03:02:00-0600 |
| 1993-05-09 03:00:00-0600 |

## zoned_time()

Returns a value of type `ZONED TIME`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>zoned_time([&lt;param&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;param&gt;</code></td>
      <td><code>STRING</code> or <code>MAP</code></td>
      <td>Either a time string (<a href="#Datetime-String-Format">format</a>) or a map with the fields <code>hour</code>, <code>minute</code>, <code>second</code>, one of <code>millisecond</code> (3 digits), <code>microsecond</code> (6 digits), or <code>nanosecond</code> (9 digits), as well as <code>timezone</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>ZONED TIME</code></td>
    </tr>
  </tbody>
</table>

When called without a parameter, `zoned_time()` returns the current session time (or the server time if no session timezone is set). It is equivalent to `current_time`.

```uql
return zoned_time(), current_time
```

Result:

| zoned_time() | current_time |
| -- | -- |
| 15:20:30.625790824-0600 | 15:20:30.625790824-0600 |

The parameter should match one of the supported formats:

```uql
uncollect [
  zoned_time("03:02:11.70-06:00"),
  zoned_time("030211.70-0600"),
  zoned_time("03:02:11-06:00"),
  zoned_time("030211-0600"),
  zoned_time({hour: 3, minute: 2, second: 11, millisecond: 70, timezone: "-0600"}),
  zoned_time({hour: 3, minute: 2, second: 11, microsecond: 70, timezone: "-0600"}),
  zoned_time({hour: 3, minute: 2, second: 11, nanosecond: 70, timezone: "-0600"}),
  zoned_time({hour: 3, minute: 2, second: 11, timezone: "-0600"}),
  zoned_time({hour: 3, minute: 2, timezone: "-0600"}),
  zoned_time({hour: 3, timezone: "-0600"})
] as value
return value
```

Result:

| value |
| -- |
| 03:02:11.7-0600 |
| 03:02:11.7-0600 |
| 03:02:11-0600 |
| 03:02:11-0600 |
| 03:02:11.07-0600 |
| 03:02:11.00007-0600 |
| 03:02:11.00000007-0600 |
| 03:02:11-0600 |
| 03:02:00-0600 |
| 03:00:00-0600 |

# Other Temporal Functions

## dateAdd()

Adds a specified time interval to a given date.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:17%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>dateAdd(&lt;time&gt;, &lt;interval&gt;, &lt;unit&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;time&gt;</code></td>
      <td>Temporal</td>
      <td>The initial time</td>
    </tr>
    <tr>
      <td><code>&lt;interval&gt;</code></td>
      <td><code>INT</code></td>
      <td>The number of units to add (positive value to add, negative to subtract)</td>
    </tr>
    <tr>
      <td><code>&lt;unit&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The unit of time to add, which can be <code>year</code>, <code>month</code>, <code>day</code>, <code>hour</code>, <code>minute</code>, or <code>second</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DATETIME</code></td>
    </tr>
  </tbody>
</table>

```uql
return dateAdd("1970-1-1", -1, "hour") as newTime
```

Result:

| newTime |
| -- |
| 1969-12-31 23:00:00 |

```uql
return dateAdd("1970-1-1", 10, "year")
```

Result:

| newTime |
| -- |
| 1980-01-01 00:00:00 |

## dateDiff()

Computes the difference between two dates (`time1` - `time2`) and returns the result as a specified unit of time.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>dateAdd(&lt;time1&gt;, &lt;time2&gt;, &lt;unit&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;endTime&gt;</code></td>
      <td>Temporal</td>
      <td>The first time</td>
    </tr>
    <tr>
      <td><code>&lt;time2&gt;</code></td>
      <td>Temporal</td>
      <td>The second time</td>
    </tr>
    <tr>
      <td><code>&lt;unit&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The unit of difference, which can be <code>day</code>, <code>hour</code>, <code>minute</code>, or <code>second</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DATETIME</code></td>
    </tr>
  </tbody>
</table>

```uql
return dateDiff("1970-01-01 10:00:00", "1970-01-01 12:00:20", "minute") as diff
```

Result:

| diff |
| -- |
| -120 |

## dateFormat()

Prints a given date in the specific format.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:21%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>dateFormat(&lt;time&gt;, &lt;formatCode&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;time&gt;</code></td>
      <td>Temporal</td>
      <td>The input time</td>
    </tr>
    <tr>
      <td><code>&lt;formatCode&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The format code</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

<b>Format codes:</b>

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

```uql
return dateFormat("2010/9/25 6:12:30","%A %e %B, %G") as newFormat
```

Result:

| newFormat |
| -- |
| Saturday 25 September, 2010 |

## day()

Extracts the day component from a given date.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>day(&lt;time&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;time&gt;</code></td>
      <td>Temporal</td>
      <td>The input time</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```uql
return day("2022-10-5")
```

Result:

| day("2022-10-5") |
| -- |
| 5 |

## dayOfWeek()

Returns a number (from `1` to `7`, where `1` = Sunday and `7` = Saturaday) representing the day of the week for a given date.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>dayOfWeek(&lt;time&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;time&gt;</code></td>
      <td>Temporal</td>
      <td>The input time</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```uql
return dayOfWeek("2024-12-5")
```

Result:

| dayOfWeek("2024-12-5") |
| -- |
| 5 |

## month()

Extracts the month component from a given date.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>month(&lt;time&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;time&gt;</code></td>
      <td>Temporal</td>
      <td>The input time</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```uql
return month("2022-10-5")
```

Result:

| month("2022-10-5") |
| -- |
| 10 |

## year()

Extracts the year component from a given date.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>year(&lt;time&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;time&gt;</code></td>
      <td>Temporal</td>
      <td>The input time</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```uql
return year("2022-10-5")
```

Result:

| year("2022-10-5") |
| -- |
| 2022 |

# Datetime String Format

**Date string**

- Format: `yyyy-mm-dd` or `yyyymmdd`
- Range: `-9999-12-31` to `9999-12-31`

**Time string**

- Format: `hh:mm:ss[.fraction]` or `hhmmss[.fraction]`
- Range: `00:00:00.000000000` to `23:59:59.999999999`

**Datetime string**

- Format: The date and time strings are joined by either a space or the letter `T`.
- Range: `-9999-01-01 00:00:00.000000000` to `9999-12-31 23:59:59.999999999`

**Timezone string**

- Format: Represented as a UTC offset in the form of `±hh:mm` or `±hhmm`, appended directly to the time value.
- Range: `UTC-15:00` to `UTC+15:00`
