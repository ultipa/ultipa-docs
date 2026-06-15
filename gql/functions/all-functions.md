# All Functions

This section contains a summary of all functions supported in GQL.

## Function Naming Convention

For function names that follow the camelCase convention (e.g., `pedgeUuids()`), the name must be used exactly as defined, preserving the original capitalization.

For function names that do not follow camelCase, it is acceptable to use either all uppercase or all lowercase when referencing them (e.g., `path_length()` or `PATH_LENGTH()`).

## Scalar Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/scalar-functions#cardinality">cardinality()</a> | Returns the cardinality of a path, a list, or a record. |
| <a href="/docs/gql/scalar-functions#cast">cast()</a> | Specifies a data conversion. |
| <a href="/docs/gql/scalar-functions#element_id">element_id()</a> | Gets the unique identifier `_uuid` of a graph element. |

## Path Functions

| <div table-width="17">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/path-functions#nodes">nodes()</a> | Extracts all nodes from a path as a list. |
| <a href="/docs/gql/path-functions#path_length">path_length()</a> | Returns the number of edges in a path. |
| <a href="/docs/gql/path-functions#pedges">pedges()</a> | Collects edges in a path into a list. |
| <a href="/docs/gql/path-functions#pedgeUuids">pedgeUuids()</a> | Collects the `_uuid` values of edges in a path into a list. |
| <a href="/docs/gql/path-functions#pnodes">pnodes()</a> | Collects nodes in a path into a list. |
| <a href="/docs/gql/path-functions#pnodeIds">pnodeIds()</a> | Collects the `_id` values of nodes in a path into a list. |
| <a href="/docs/gql/path-functions#relationships">relationships()</a> | Extracts all edges from a path as a list. |

## Aggregate Functions

| <div table-width="20">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/aggregate-functions#avg">avg()</a> | Computes the average of a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#collect_list">collect_list()</a> | Collects a set of values into a list. |
| <a href="/docs/gql/aggregate-functions#count">count()</a> | Returns the number of rows in the input. |
| <a href="/docs/gql/aggregate-functions#max">max()</a> | Returns the maximum value in a set of values. |
| <a href="/docs/gql/aggregate-functions#min">min()</a> | Returns the minimum value in a set of values. |
| <a href="/docs/gql/aggregate-functions#percentile_cont">percentile_cont()</a> | Computes the continuous percentile value over a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#percentile_disc">percentile_disc()</a> | Computes the discrete percentile value over a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#stddev_pop">stddev_pop()</a> | Computes the population standard deviation of a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#stddev_samp">stddev_samp()</a> | Computes the sample standard deviation of a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#sum">sum()</a> | Computes the sum of a set of numeric values. |

## Mathematical Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/mathematical-functions#abs">abs()</a> | Returns the absolute value of a given number. |
| <a href="/docs/gql/mathematical-functions#ceil">ceil()</a> | Rounds a given number up to the nearest integer. |
| <a href="/docs/gql/mathematical-functions#exp">exp()</a> | Computes the value of Euler's number 𝑒 raised to the power of a given number. |
| <a href="/docs/gql/mathematical-functions#floor">floor()</a> | Rounds a given number down to the nearest integer. |
| <a href="/docs/gql/mathematical-functions#ln">ln()</a> | Computes the natural logarithm of a given number. |
| <a href="/docs/gql/mathematical-functions#log">log()</a> | Computes the logarithm of a specified number with respect to a given base. |
| <a href="/docs/gql/mathematical-functions#log10">log10()</a> | Computes the base 10 logarithm of a given number. |
| <a href="/docs/gql/mathematical-functions#mod">mod()</a> | Computes the modulus, or the remainder when one number is divided by another. |
| <a href="/docs/gql/mathematical-functions#pi">pi()</a> | Returns the mathematical constant π (pi). |
| <a href="/docs/gql/mathematical-functions#power">power()</a> | Raises a number to the power of another number. |
| <a href="/docs/gql/mathematical-functions#round">round()</a> | Returns the nearest value of a given number, rounded to a specified position of digits. |
| <a href="/docs/gql/mathematical-functions#sqrt">sqrt()</a> | Computes the square root of a given number. |

## Trigonometric Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/trigonometric-functions#acos">acos()</a> | Computes the angle in radians whose cosine is a given number. |
| <a href="/docs/gql/trigonometric-functions#asin">asin()</a> | Computes the angle in radians whose sine is a given number. |
| <a href="/docs/gql/trigonometric-functions#atan">atan()</a> | Computes the angle in radians whose tangent is a given number. |
| <a href="/docs/gql/trigonometric-functions#cos">cos()</a> | Computes the cosine of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#cosh">cosh()</a> | Computes the hyperbolic cosine of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#cot">cot()</a> | Computes the cotangent of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#degrees">degrees()</a> | Converts an angle from radians to degrees. |
| <a href="/docs/gql/trigonometric-functions#radians">radians()</a> | Converts an angle from degrees to radians. |
| <a href="/docs/gql/trigonometric-functions#sin">sin()</a> | Computes the sine of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#sinh">sinh()</a> | Computes the hyperbolic sine of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#tan">tan()</a> | Computes the tangent of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#tanh">tanh()</a> | Computes the angle in radians whose cosine is a given number. |

## String Functions

| <div table-width="16">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/string-functions#btrim">btrim()</a> | Removes characters from both ends of a given string until encountering a character that is not contained in the specified set of characters. |
| <a href="/docs/gql/string-functions#char_length">char_length()</a> | Returns the number of characters in a string. |
| <a href="/docs/gql/string-functions#left">left()</a> | Returns a substring of the given string containing the specified number of leftmost characters. |
| <a href="/docs/gql/string-functions#lower">lower()</a> | Converts all the characters in a given string to lowercase. |
| <a href="/docs/gql/string-functions#ltrim">ltrim()</a> | Removes characters from the begining of a given string until encountering a character that is not contained in the specified set of characters. |
| <a href="/docs/gql/string-functions#normalize">normalize()</a> | Converts a string into a consistent format based on the normalization form specified. |
| <a href="/docs/gql/string-functions#replace">replace()</a> | Returns a string where all occurrences of a specified substring are replaced with another string. |
| <a href="/docs/gql/string-functions#right">right()</a> | Returns a substring of the given string containing the specified number of rightmost characters. |
| <a href="/docs/gql/string-functions#rtrim">rtrim()</a> | Removes characters from the end of a given string until encountering a character that is not contained in the specified set of characters. |
| <a href="/docs/gql/string-functions#split">split()</a> | Returns a list of string resulting from the splitting of the given string around matches of the given delimiter. |
| <a href="/docs/gql/string-functions#substring">substring()</a> | Returns a substring of a given length from the given string, beginning with a 0-based index start. |
| <a href="/docs/gql/string-functions#trim">trim()</a> | Removes all the occurrences of the specified single character from either the leftmost, rightmost, or both ends of a given string. |
| <a href="/docs/gql/string-functions#upper">upper()</a> | Converts all the characters in a given string to uppercase. |

## List Functions

| <div table-width="16">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/list-functions#append">append()</a> | Adds an element to the end of a list and returns the new list. |
| <a href="/docs/gql/list-functions#difference">difference()</a> | Returns the difference between two lists. |
| <a href="/docs/gql/list-functions#elements">elements()</a> | Returns a list containing the nodes and edges that make up a path. |
| <a href="/docs/gql/list-functions#head">head()</a> | Returns the first element in a list. |
| <a href="/docs/gql/list-functions#intersection">intersection()</a> | Returns the intersection of two lists. |
| <a href="/docs/gql/list-functions#listContains">listContains()</a> | Checks whether a specified element exists in a list. |
| <a href="/docs/gql/list-functions#listUnion">listUnion()</a> | Returns the union of two lists. |
| <a href="/docs/gql/list-functions#reduce">reduce()</a> | Performs a calculation iteratively using each element in a list. |
| <a href="/docs/gql/list-functions#size">size()</a> | Returns the number of elements in a list. |
| <a href="/docs/gql/list-functions#append">trim()</a> | Removes a specified number of elements from the right end of the list. |

## Datetime Functions

| <div table-width="20">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/datetime-functions#date">date()</a> | Returns a value of type `DATE`. |
| <a href="/docs/gql/datetime-functions#local_datetime">local_datetime()</a> | Returns a value of type `LOCAL DATETIME`. |
| <a href="/docs/gql/datetime-functions#local_time">local_time()</a> | Returns a value of type `LOCAL TIME`. |
| <a href="/docs/gql/datetime-functions#now">now()</a> | Returns the current datetime in UTC. |
| <a href="/docs/gql/datetime-functions#zoned_datetime">zoned_datetime()</a> | Returns a value of type `ZONED DATETIME`. |
| <a href="/docs/gql/datetime-functions#zoned_time">zoned_time()</a> | Returns a value of type `ZONED TIME`. |
| <a href="/docs/gql/datetime-functions#dateAdd">dateAdd()</a> | Adds a specified time interval to a given date. |
| <a href="/docs/gql/datetime-functions#dateDiff">dateDiff()</a> | Computes the difference between two dates and returns the result as a specified unit of time. |
| <a href="/docs/gql/datetime-functions#dateFormat">dateFormat()</a> | Prints a given date in the specific format. |
| <a href="/docs/gql/datetime-functions#dayOfWeek">dayOfWeek()</a> | Returns a number representing the day of the week for a given date. |

## Spatial Functions

| <div table-width="16">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/spatial-functions/#distance">distance()</a> | Computes the straight-line distance between two points. |
| <a href="/docs/gql/spatial-functions/#point">point()</a> | Constructs a two-dimensional geographical coordinate. |
| <a href="/docs/gql/spatial-functions/#point3d">point3d()</a> | Constructs a three-dimensional Cartesian coordinate. |
| <a href="/docs/gql/spatial-functions/#pointget">pointget()</a> | Extracts the coordinate values in the `point` or `point3d` property. |

## Label Functions

| <div table-width="20">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/label-functions#labelContains">labelContains()</a> | Checks whether an entity has a specific label. |
| <a href="/docs/gql/label-functions#labelHasAny">labelHasAny()</a> | Checks whether an entity has at least one label. |
| <a href="/docs/gql/label-functions#labels">labels()</a> | Returns a list of all labels on an entity. |

## Record Functions

| <div table-width="20">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/record-functions#keys">keys()</a> | Returns a list of all field names in a record. |
| <a href="/docs/gql/record-functions#recordContains">recordContains()</a> | Returns `true` if the record contains the specified field. |
| <a href="/docs/gql/record-functions#recordGet">recordGet()</a> | Returns the value of the specified field in a record. |
| <a href="/docs/gql/record-functions#recordRemove">recordRemove()</a> | Returns a new record with the specified field removed. |
| <a href="/docs/gql/record-functions#recordSet">recordSet()</a> | Returns a new record with the specified field set to the given value. |

## Table Functions

| <div table-width="16">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/table-functions#table">table()</a> | Constructs a table. |
