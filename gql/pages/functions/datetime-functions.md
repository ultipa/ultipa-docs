# Datetime Functions

## Datetime Value Functions

A datetime value function creates a temporal instant or duration value. Refer to <a href="/docs/gql/values-and-types">Values and Types</a> for date and time string formats.

### date()

Creates a value of type `DATE` (`LOCAL DATE`).

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
      <td><code>STRING</code>, <code>RECORD</code>, or 3 <code>INT</code>s</td>
      <td>A date string, a record with <code>year</code>/<code>month</code>/<code>day</code> fields, or three integers (year, month, day)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DATE</code></td>
    </tr>
  </tbody>
</table>

```gql
// returns the current local date, date() is equivalent to CURRENT_DATE
RETURN date(), CURRENT_DATE
```

```gql
RETURN date("1993-05-09"),
       date("1993-5-9"),
       date("19930509"),
       date("1993/05/09"),
       date("1993/5/9"),
       date({year: 1993, month: 5, day: 9}),
       date(1993, 5, 9)
```

### local_time()

Creates a value of type `LOCAL TIME`. `time()` is a synonym.

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
      <td><code>STRING</code> or <code>RECORD</code></td>
      <td>A time string or a record with <code>hour</code>/<code>minute</code>/<code>second</code> fields and optionally <code>millisecond</code>, <code>microsecond</code>, or <code>nanosecond</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LOCAL TIME</code></td>
    </tr>
  </tbody>
</table>

```gql
// returns the current local time, local_time() is equivalent to LOCAL_TIME
RETURN local_time(), LOCAL_TIME
```

```gql
RETURN local_time("03:02:11.700000000"),
       local_time("03:02:11"),
       local_time("03:02"),
       local_time("030211"),
       local_time("030211.700000000"),
       local_time({hour: 3, minute: 2, second: 11}),
       local_time({hour: 3, minute: 2, second: 11, millisecond: 700}),
       local_time({hour: 3, minute: 2, second: 11, microsecond: 700}),
       local_time({hour: 3, minute: 2, second: 11, nanosecond: 700})
```

### local_datetime()

Creates a value of type `LOCAL DATETIME`.

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
      <td><code>STRING</code> or <code>RECORD</code></td>
      <td>A datetime string or a record with <code>year</code>/<code>month</code>/<code>day</code>/<code>hour</code>/<code>minute</code>/<code>second</code> fields and optionally <code>millisecond</code>, <code>microsecond</code>, or <code>nanosecond</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LOCAL DATETIME</code></td>
    </tr>
  </tbody>
</table>

```gql
// returns the current local datetime, local_datetime() is equivalent to LOCAL_TIMESTAMP
RETURN local_datetime(), LOCAL_TIMESTAMP
```

```gql
RETURN local_datetime("1993-05-09T03:02:11.70"),
       local_datetime("1993-05-09 03:02:11"),
       local_datetime("1993/05/09 03:02:11"),
       local_datetime("1993/5/9 03:02:11"),
       local_datetime("19930509T030211"),
       local_datetime("19930509 030211"),
       local_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11}),
       local_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11, millisecond: 700}),
       local_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11, microsecond: 700}),
       local_datetime({year: 1993, month: 5, day: 9, hour: 3, minute: 2, second: 11, nanosecond: 700})
```

### zoned_time()

Creates a value of type `ZONED TIME`.

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
      <td colspan="3"><code>zoned_time([&lt;param&gt; [, &lt;timezone&gt;]])</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>[&lt;param&gt;]</code></td>
      <td><code>STRING</code>, <code>RECORD</code>, or <code>TIME</code></td>
      <td>A time string with timezone, a record with <code>hour</code>/<code>minute</code>/<code>second</code>/<code>timezone</code> fields and optionally <code>millisecond</code>, <code>microsecond</code>, or <code>nanosecond</code></td>
    </tr>
    <tr>
      <td><code>&lt;timezone&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Target timezone offset (e.g., <code>"+05:30"</code>, <code>"Z"</code>) used to convert the first argument to a different timezone</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>ZONED TIME</code></td>
    </tr>
  </tbody>
</table>

```gql
// returns the current local zoned time, zoned_time() is equivalent to CURRENT_TIME
RETURN zoned_time(), CURRENT_TIME
```

```gql
RETURN zoned_time("12:20:02+08:00"),
       zoned_time("12:20:02Z"),
       zoned_time({hour: 12, minute: 20, second: 2, timezone: "+08:00"}),
       zoned_time({hour: 12, minute: 20, second: 2, timezone: "+08:00", millisecond: 500}),
       zoned_time({hour: 12, minute: 20, second: 2, timezone: "-06:00", microsecond: 700}),
       zoned_time({hour: 12, minute: 20, second: 2, timezone: "Z", nanosecond: 700})
```

Convert an existing time to a different timezone:

```gql
RETURN zoned_time("12:20:02+08:00", "+05:30")
```

### zoned_datetime()

Creates a value of type `ZONED DATETIME`.

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
      <td colspan="3"><code>zoned_datetime(&lt;param&gt; [, &lt;timezone&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;param&gt;</code></td>
      <td><code>STRING</code>, <code>RECORD</code>, <code>TIMESTAMP</code>, or <code>ZONED DATETIME</code></td>
      <td>A datetime string with timezone, a record with <code>year</code>/<code>month</code>/<code>day</code>/<code>hour</code>/<code>minute</code>/<code>second</code>/<code>timezone</code> fields and optionally <code>millisecond</code>, <code>microsecond</code>, or <code>nanosecond</code></td>
    </tr>
    <tr>
      <td><code>&lt;timezone&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Target timezone offset (e.g., <code>"+05:30"</code>, <code>"Z"</code>) used to convert the first argument to a different timezone</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>ZONED DATETIME</code></td>
    </tr>
  </tbody>
</table>

```gql
// returns the current local datetime, zoned_datetime() is equivalent to CURRENT_TIMESTAMP
RETURN zoned_datetime(), CURRENT_TIMESTAMP
```

```gql
RETURN zoned_datetime("2025-01-01T12:20:02+08:00"),
       zoned_datetime("2025-01-01T12:20:02Z"),
       zoned_datetime({year: 2025, month: 1, day: 1, hour: 12, minute: 20, second: 2, timezone: "+08:00"}),
       zoned_datetime({year: 2025, month: 1, day: 1, hour: 12, minute: 20, second: 2, timezone: "+08:00", millisecond: 500}),
       zoned_datetime({year: 2025, month: 1, day: 1, hour: 12, minute: 20, second: 2, timezone: "-06:00", microsecond: 700}),
       zoned_datetime({year: 2025, month: 1, day: 1, hour: 12, minute: 20, second: 2, timezone: "Z", nanosecond: 700})
```

Convert an existing datetime to a different timezone:

```gql
RETURN zoned_datetime("2025-01-01T12:20:02+08:00", "+05:30")
```

### now()

Returns the current zoned datetime in the server's local timezone. It is equivalent to `CURRENT_TIMESTAMP`.

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
      <td><code>ZONED DATETIME</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN now(), CURRENT_TIMESTAMP
```

### duration()

Creates a value of type `DURATION`.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>duration(&lt;durationStr&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;durationStr&gt;</code></td>
      <td><code>STRING</code></td>
      <td>An ISO 8601 duration string (e.g., <code>"P2Y5M"</code>, <code>"P3DT4H"</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DURATION</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN duration("P2Y5M"), duration("P3DT4H30M")
```

## Other Datetime Functions

### date_add()

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
      <td colspan="3"><code>date_add(&lt;time&gt;, &lt;interval&gt;, &lt;unit&gt;)</code></td>
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

```gql
RETURN date_add("1970-1-1", -1, "hour")
```

Result: 

```json
{
  "_type": "localDatetime",
  "year": 1969,
  "month": 12,
  "day": 31,
  "hour": 23,
  "minute": 0,
  "second": 0,
  "nanosecond": 0
}
```

```gql
RETURN date_add("1970-1-1", 10, "year")
```

Result: 

```json
{
  "_type": "localDatetime",
  "year": 1980,
  "month": 1,
  "day": 1,
  "hour": 0,
  "minute": 0,
  "second": 0,
  "nanosecond": 0
}
```

### date_diff()

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
      <td colspan="3"><code>date_diff(&lt;time1&gt;, &lt;time2&gt;, &lt;unit&gt;)</code></td>
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

```gql
RETURN date_diff("1970-01-01 10:00:00", "1970-01-01 12:00:20", "minute")
```

Result: -120

### day_of_week()

Returns a number (from `0` to `6`, where `0` = Sunday and `6` = Saturday) representing the day of the week for a given date.

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
      <td colspan="3"><code>day_of_week(&lt;time&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;time&gt;</code></td>
      <td><code>STRING</code> or Temporal</td>
      <td>A date/time string or a temporal value (<code>DATE</code>, <code>LOCAL DATETIME</code>, <code>ZONED DATETIME</code>, <code>LOCAL TIME</code>, <code>TIMESTAMP</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN day_of_week("2024-12-5")
```

Result: 4

### year()

Extracts the year from a date or datetime value.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>year(&lt;temporal&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;temporal&gt;</code></td>
      <td><code>STRING</code> or Temporal</td>
      <td>A date/time string or a temporal value (<code>DATE</code>, <code>LOCAL DATETIME</code>, <code>ZONED DATETIME</code>, <code>LOCAL TIME</code>, <code>TIMESTAMP</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN year("2025-03-15"), year(date("2025-03-15"))
```

### month()

Extracts the month from a date or datetime value.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>month(&lt;temporal&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;temporal&gt;</code></td>
      <td><code>STRING</code> or Temporal</td>
      <td>A date/time string or a temporal value (<code>DATE</code>, <code>LOCAL DATETIME</code>, <code>ZONED DATETIME</code>, <code>LOCAL TIME</code>, <code>TIMESTAMP</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN month("2025-03-15"), month(date("2025-03-15"))
```

### day()

Extracts the day from a date or datetime value.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>day(&lt;temporal&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;temporal&gt;</code></td>
      <td><code>STRING</code> or Temporal</td>
      <td>A date/time string or a temporal value (<code>DATE</code>, <code>LOCAL DATETIME</code>, <code>ZONED DATETIME</code>, <code>LOCAL TIME</code>, <code>TIMESTAMP</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN day("2025-03-15"), day(date("2025-03-15"))
```

### hour()

Extracts the hour from a time or datetime value.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>hour(&lt;temporal&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;temporal&gt;</code></td>
      <td><code>STRING</code> or Temporal</td>
      <td>A date/time string or a temporal value (<code>DATE</code>, <code>LOCAL DATETIME</code>, <code>ZONED DATETIME</code>, <code>LOCAL TIME</code>, <code>TIMESTAMP</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN hour("2025-03-15 14:30:45"), hour(local_datetime("2025-03-15 14:30:45"))
```

### minute()

Extracts the minute from a time or datetime value.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>minute(&lt;temporal&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;temporal&gt;</code></td>
      <td><code>STRING</code> or Temporal</td>
      <td>A date/time string or a temporal value (<code>DATE</code>, <code>LOCAL DATETIME</code>, <code>ZONED DATETIME</code>, <code>LOCAL TIME</code>, <code>TIMESTAMP</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN minute("2025-03-15 14:30:45"), minute(local_datetime("2025-03-15 14:30:45"))
```

### second()

Extracts the second from a time or datetime value.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>second(&lt;temporal&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;temporal&gt;</code></td>
      <td><code>STRING</code> or Temporal</td>
      <td>A date/time string or a temporal value (<code>DATE</code>, <code>LOCAL DATETIME</code>, <code>ZONED DATETIME</code>, <code>LOCAL TIME</code>, <code>TIMESTAMP</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN second("2025-03-15 14:30:45"), second(local_datetime("2025-03-15 14:30:45"))
```

### duration_between()

Computes the duration between two temporal values.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>duration_between(&lt;temporal1&gt;, &lt;temporal2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;temporal1&gt;</code></td>
      <td><code>DATE</code>, <code>DATETIME</code>, <code>TIMESTAMP</code></td>
      <td>Start temporal value</td>
    </tr>
    <tr>
      <td><code>&lt;temporal2&gt;</code></td>
      <td><code>DATE</code>, <code>DATETIME</code>, <code>TIMESTAMP</code></td>
      <td>End temporal value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>DURATION</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN duration_between(date("2025-01-01"), date("2025-03-15"))
```

Result:

```json
{
  "seconds": 6307200, "nanoseconds": 0
}
```

### dateformat()

Formats a temporal value as a string using a Java SimpleDateFormat-style pattern.

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
      <td colspan="3"><code>dateformat(&lt;temporal&gt;, &lt;format&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;temporal&gt;</code></td>
      <td>Temporal</td>
      <td>A datetime value or a parsable string</td>
    </tr>
    <tr>
      <td><code>&lt;format&gt;</code></td>
      <td><code>STRING</code></td>
      <td>A Java SimpleDateFormat-style pattern (e.g., <code>"yyyy-MM-dd"</code>, <code>"yyyy-MM-dd HH:mm:ss"</code>)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

Supported pattern tokens (case-sensitive; the longest match wins):

| Token | Meaning | Example |
| -- | -- | -- |
| `yyyy` / `yy` | 4- or 2-digit year | `2024` / `24` |
| `MMMMM` / `MMMM` / `MMM` / `MM` / `M` | Month: one-letter abbreviation / full name / short name / 2-digit / 1-digit | `J` / `January` / `Jan` / `01` / `1` |
| `dd` / `d` | Day of month: padded / unpadded | `02` / `2` |
| `EEEE` / `EEE` / `EE` / `E` | Day name: full / 3-letter abbreviation | `Monday` / `Mon` |
| `HH` / `H` | Hour 0-23, always 2-digit padded | `15` |
| `hh` / `h` | Hour 1-12: padded / unpadded | `03` / `3` |
| `mm` / `m` | Minute: padded / unpadded | `04` / `4` |
| `ss` / `s` | Second: padded / unpadded | `05` / `5` |
| `SSSSSSSSS` / `SSSSSS` / `SSS` / `SS` / `S` | Fractional second: 9 / 6 / 3 / 2 / 1 digits (use after `.` or `,`) | `123456789` / `123456` / `123` / `12` / `1` |
| `a` | AM/PM marker | `PM` |
| `XXX` / `XX` / `X` | ISO 8601 zone offset | `-07:00` / `-0700` / `-07` |
| `Z` | RFC 822 zone offset | `-0700` |
| `z` | Time zone abbreviation | `MST` |

```gql
RETURN dateformat(date("2025-03-15"), "yyyy-M-d") AS value1,
       dateformat(local_datetime("2025-03-15T14:30:45"), "yyyy-MM-dd HH:mm:ss") AS value2
       dateformat(CURRENT_DATE, "'today is' yyyy-MM-dd") AS value3  // single-quote escape
```

Result:

| value1 | value2 | value3 |
| -- | -- | -- |
| "2025-3-15" | "2025-03-15 14:30:45" | "today is 2026-05-18" |

