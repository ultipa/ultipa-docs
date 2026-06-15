# All Functions

This section contains a summary of all functions supported in UQL.

## Function Naming Convention

For function names that follow the camelCase convention (e.g., `pedgeUuids()`), the name must be used exactly as defined, preserving the original capitalization.

For function names that do not follow camelCase, it is acceptable to use either all uppercase or all lowercase when referencing them (e.g., `length()` or `LENGTH()`).

## Path Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/uql/path-functions#length()">length()</a> | Returns the number of edges in a path. |
| <a href="/docs/uql/path-functions#pedges()">pedges()</a> | Collects edges in a path into a list. |
| <a href="/docs/uql/path-functions#pedgeUuids()">pedgeUuids()</a> | Collects the `_uuid` values of edges in a path into a list. |
| <a href="/docs/uql/path-functions#pnodes()">pnodes()</a> | Collects nodes in a path into a list. |
| <a href="/docs/uql/path-functions#pnodeIds()">pnodeIds()</a> | Collects the `_id` values of nodes in a path into a list. |

## Aggregate Functions

| <div table-width="20">Function</div> | Description |
| -- | -- |
| <a href="/docs/uql/aggregate-functions#avg()">avg()</a> | Computes the average of a set of numeric values. |
| <a href="/docs/uql/aggregate-functions#collect()">collect()</a> | Collects a set of values into a list. |
| <a href="/docs/uql/aggregate-functions#count()">count()</a> | Returns the number of rows in the input. |
| <a href="/docs/uql/aggregate-functions#max()">max()</a> | Returns the maximum value in a set of values. |
| <a href="/docs/uql/aggregate-functions#min()">min()</a> | Returns the minimum value in a set of values. |
| <a href="/docs/uql/aggregate-functions#stddev_pop()">stddev_pop()</a> | Computes the population standard deviation of a set of numeric values. |
| <a href="/docs/uql/aggregate-functions#stddev_samp()">stddev_samp()</a> | Computes the sample standard deviation of a set of numeric values. |
| <a href="/docs/uql/aggregate-functions#sum()">sum()</a> | Computes the sum of a set of numeric values. |

## Mathematical Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/uql/mathematical-functions#abs()">abs()</a> | Returns the absolute value of a given number. |
| <a href="/docs/uql/mathematical-functions#ceil()">ceil()</a> | Rounds a given number up to the nearest integer. |
| <a href="/docs/uql/mathematical-functions#floor()">floor()</a> | Rounds a given number down to the nearest integer. |
| <a href="/docs/uql/mathematical-functions#pi()">pi()</a> | Returns the mathematical constant π (pi). |
| <a href="/docs/uql/mathematical-functions#pow()">pow()</a> | Raises a number to the power of another number. |
| <a href="/docs/uql/mathematical-functions#round()">round()</a> | Returns the nearest value of a given number, rounded to a specified position of digits. |
| <a href="/docs/uql/mathematical-functions#sqrt()">sqrt()</a> | Computes the square root of a given number. |

## Trigonometric Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/uql/trigonometric-functions#acos()">acos()</a> | Computes the angle in radians whose cosine is a given number. |
| <a href="/docs/uql/trigonometric-functions#asin()">asin()</a> | Computes the angle in radians whose sine is a given number. |
| <a href="/docs/uql/trigonometric-functions#atan()">atan()</a> | Computes the angle in radians whose tangent is a given number. |
| <a href="/docs/uql/trigonometric-functions#cos()">cos()</a> | Computes the cosine of an angle expressed in radian. |
| <a href="/docs/uql/trigonometric-functions#cot()">cot()</a> | Computes the cotangent of an angle expressed in radian. |
| <a href="/docs/uql/trigonometric-functions#sin()">sin()</a> | Computes the sine of an angle expressed in radian. |
| <a href="/docs/uql/trigonometric-functions#tan()">tan()</a> | Computes the tangent of an angle expressed in radian. |

## String Functions

| <div table-width="16">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/string-functions#btrim()">btrim()</a> | Removes characters from both ends of a given string until encountering a character that is not contained in the specified set of characters. |
| <a href="/docs/uql/string-functions#endsWith()">endsWith()</a> | Checks whether a string ends with a specified substring. |
| <a href="/docs/uql/string-functions#length()">length()</a> | Returns the number of characters in a string. |
| <a href="/docs/uql/string-functions#lower()">lower()</a> | Converts all the characters in a given string to lowercase. |
| <a href="/docs/uql/string-functions#ltrim()">ltrim()</a> | Removes characters from the begining of a given string until encountering a character that is not contained in the specified set of characters. |
| <a href="/docs/uql/string-functions#rtrim()">rtrim()</a> | Removes characters from the end of a given string until encountering a character that is not contained in the specified set of characters. |
| <a href="/docs/uql/string-functions#split()">split()</a> | Splits a string into a list of substrings using the specified delimiter. |
| <a href="/docs/uql/string-functions#startsWith()">startsWith()</a> | Checks whether a string begins with a specified substring. |
| <a href="/docs/uql/string-functions#upper()">upper()</a> | Converts all the characters in a given string to uppercase. |

## List Functions

| <div table-width="16">Function</div> | Description |
| -- | -- |
| <a href="/docs/uql/list-functions#append()">append()</a> | Adds an element to the end of a list and returns the new list. |
| <a href="/docs/uql/list-functions#difference()">difference()</a> | Returns the difference between two lists. |
| <a href="/docs/uql/list-functions#head()">head()</a> | Returns the first element in a list. |
| <a href="/docs/uql/list-functions#intersection()">intersection()</a> | Returns the intersection of two lists. |
| <a href="/docs/uql/list-functions#listContains()">listContains()</a> | Checks whether a specified element exists in a list. |
| <a href="/docs/uql/list-functions#listUnion()">listUnion()</a> | Returns the union of two lists. |
| <a href="/docs/uql/list-functions#reduce()">reduce()</a> | Performs a calculation iteratively using each element in a list. |
| <a href="/docs/uql/list-functions#size()">size()</a> | Returns the number of elements in a list. |

## Datetime Functions

| <div table-width="20">Function</div> | Description |
| -- | -- |
| <a href="/docs/uql/datetime-functions#date()">date()</a> | Returns a value of type `DATE`. |
| <a href="/docs/uql/datetime-functions#local_datetime()">local_datetime()</a> | Returns a value of type `LOCAL DATETIME`. |
| <a href="/docs/uql/datetime-functions#local_time()">local_time()</a> | Returns a value of type `LOCAL TIME`. |
| <a href="/docs/uql/datetime-functions#now()">now()</a> | Returns the current datetime in UTC. |
| <a href="/docs/uql/datetime-functions#zoned_datetime()">zoned_datetime()</a> | Returns a value of type `ZONED DATETIME`. |
| <a href="/docs/uql/datetime-functions#zoned_time()">zoned_time()</a> | Returns a value of type `ZONED TIME`. |
| <a href="/docs/uql/datetime-functions#dateAdd()">dateAdd()</a> | Adds a specified time interval to a given date. |
| <a href="/docs/uql/datetime-functions#dateDiff()">dateDiff()</a> | Computes the difference between two dates and returns the result as a specified unit of time. |
| <a href="/docs/uql/datetime-functions#dateFormat()">dateFormat()</a> | Prints a given date in the specific format. |
| <a href="/docs/uql/datetime-functions#day()">day()</a> | Extracts the day component from a given date. |
| <a href="/docs/uql/datetime-functions#dayOfWeek()">dayOfWeek()</a> | Returns a number representing the day of the week for a given date. |
| <a href="/docs/uql/datetime-functions#month()">month()</a> | Extracts the month component from a given date. |
| <a href="/docs/uql/datetime-functions#year()">year()</a> | Extracts the year component from a given date. |

# Spatial Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/uql/spatial-functions#distance()">distance()</a> | Computes the straight-line distance between two points. |
| <a href="/docs/uql/spatial-functions/#point()">point()</a> | Constructs a two-dimensional geographical coordinate. |
| <a href="/docs/uql/spatial-functions/#point3d()">point3d()</a> | Constructs a three-dimensional Cartesian coordinate. |

## Table Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/uql/table-functions#table()">table()</a> | Constructs an output table. |

## Null Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/uql/null-functions#coalesce()">coalesce()</a> | Returns the first non-`null` value from a list of provided values. |

## Type Conversion Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/uql/type-conversion-functions#toDouble()">toDouble()</a> | Converts a value to a double-precision floating-point number. |
| <a href="/docs/uql/type-conversion-functions#toFloat()">toFloat()</a> | Converts a value to a single-precision floating-point number. |
| <a href="/docs/uql/type-conversion-functions#toInteger()">toInteger()</a> | Converts a value to a 64-bit integer. |
| <a href="/docs/uql/type-conversion-functions#toString()">toString()</a> | Converts a value to a string. |
