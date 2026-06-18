# All Functions

This section contains a summary of all functions supported in GQL.

## Naming Convention

Multi-word function names follow ISO/IEC 39075 snake case (`to_integer`, `date_add`, `db.node_labels`, ...). Single-word names (`upper`, `cardinality`, `coalesce`, `normalize`, `nullif`, ...) are kept unbroken per the standard; numeric suffixes attach directly (`log10`, `point3d`).

In GQLDB, function lookup is **case-insensitive and underscore-insensitive**. `to_integer`, `TO_INTEGER`, `tointeger`, and `ToInteger` all resolve to the same function.

## Showing Functions

To list the functions registered in your running engine, run:

```gql
SHOW FUNCTIONS
```

Use the `LIKE` clause to filter by name pattern:

```gql
SHOW FUNCTIONS LIKE 'date%'
```

Use the `FORMAT` clause to render each function's signature in a tool-calling schema, designed to be passed to an LLM as a list of callable tools. The output is a single row containing one JSON blob. All three formats are JSON Schema-based; only the wrapper shape differs.

| Format | Output shape |
| -- | -- |
| `MCP` | MCP tool-list JSON: array of `{name, description, inputSchema}`, ready to plug into a Model Context Protocol server |
| `JSON_SCHEMA` | Alias for `MCP` |
| `OPENAI` | OpenAI function-calling JSON: array of `{type: "function", function: {name, description, parameters}}`, the shape OpenAI's chat-completions API expects under `tools` |

```gql
SHOW FUNCTIONS FORMAT MCP
SHOW FUNCTIONS FORMAT JSON_SCHEMA
SHOW FUNCTIONS FORMAT OPENAI
```

## Function Categories

### Element Functions

| Function | Description |
| -- | -- |
| <a href="/docs/gql/element-functions#id">id()</a> | Gets the unique identifier `_id` of a graph element. |
| <a href="/docs/gql/element-functions#internal_id">internal_id()</a> | Returns the system-internal numeric id (`_uuid`) as a string. |
| <a href="/docs/gql/element-functions#labels">labels()</a> | Gets the labels of a graph element. |
| <a href="/docs/gql/element-functions#type">type()</a> | Gets the label of an edge. |
| <a href="/docs/gql/element-functions#keys">keys()</a> | Returns the property names of a node, edge, or the key names of a record. |
| <a href="/docs/gql/element-functions#values">values()</a> | Returns the property values of a node, edge, or the values of a record. |
| <a href="/docs/gql/element-functions#properties">properties()</a> | Returns the properties of a node or edge as a record. |
| <a href="/docs/gql/element-functions#property_exists">property_exists()</a> | Checks whether a property exists on a node or edge. |

### Path Functions

| Function | Description |
| -- | -- |
| <a href="/docs/gql/path-functions#path_length">path_length()</a> | Returns the number of edges in a path. |
| <a href="/docs/gql/path-functions#elements">elements()</a> | Returns the nodes and edges of a path as a list. |
| <a href="/docs/gql/path-functions#pnodes">pnodes()</a> | Returns the nodes of a path as a list. |
| <a href="/docs/gql/path-functions#pedges">pedges()</a> | Returns the edges of a path as a list. |
| <a href="/docs/gql/path-functions#node_ids">node_ids()</a> | Collects the `_id` values of nodes in a path into a list. |
| <a href="/docs/gql/path-functions#edge_ids">edge_ids()</a> | Collects the `_id` values of edges in a path into a list. |
| <a href="/docs/gql/path-functions#ids">ids()</a> | Generic `_id` accessor for a path, node/edge, or list of nodes/edges. |

### Aggregate Functions

| Function | Description |
| -- | -- |
| <a href="/docs/gql/aggregate-functions#collect">collect()</a> | Collects a set of values into a list. |
| <a href="/docs/gql/aggregate-functions#collect_distinct">collect_distinct()</a> | Collects a set of values into a list, removing duplicates. |
| <a href="/docs/gql/aggregate-functions#count">count()</a> | Returns the number of rows in the input. |
| <a href="/docs/gql/aggregate-functions#max">max()</a> | Returns the maximum value in a set of values. |
| <a href="/docs/gql/aggregate-functions#min">min()</a> | Returns the minimum value in a set of values. |
| <a href="/docs/gql/aggregate-functions#avg">avg()</a> | Computes the average of a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#sum">sum()</a> | Computes the sum of a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#percentile_cont">percentile_cont()</a> | Computes the continuous percentile value over a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#percentile_disc">percentile_disc()</a> | Computes the discrete percentile value over a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#stddev_samp">stddev_samp()</a> | Computes the sample standard deviation of a set of numeric values。 |
| <a href="/docs/gql/aggregate-functions#stddev_pop">stddev_pop()</a> | Computes the population standard deviation of a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#var_samp">var_samp()</a> | Computes the sample variance of a set of numeric values. |
| <a href="/docs/gql/aggregate-functions#var_pop">var_pop()</a> | Computes the population variance of a set of numeric values. |

### Mathematical Functions

| Function | Description |
| -- | -- |
| <a href="/docs/gql/mathematical-functions#abs">abs()</a> | Returns the absolute value of a given number. |
| <a href="/docs/gql/mathematical-functions#ceil">ceil()</a> | Rounds a given number up to the nearest integer. |
| <a href="/docs/gql/mathematical-functions#floor">floor()</a> | Rounds a given number down to the nearest integer. |
| <a href="/docs/gql/mathematical-functions#round">round()</a> | Returns the nearest value of a given number, rounded to a specified position of digits. |
| <a href="/docs/gql/mathematical-functions#mod">mod()</a> | Computes the modulus, or the remainder when one number is divided by another. |
| <a href="/docs/gql/mathematical-functions#sqrt">sqrt()</a> | Computes the square root of a given number. |
| <a href="/docs/gql/mathematical-functions#exp">exp()</a> | Computes the value of Euler's number 𝑒 raised to the power of a given number. |
| <a href="/docs/gql/mathematical-functions#power">power()</a> | Raises a number to the power of another number. |
| <a href="/docs/gql/mathematical-functions#ln">ln()</a> | Computes the natural logarithm of a given number. |
| <a href="/docs/gql/mathematical-functions#log">log()</a> | Computes the logarithm of a specified number with respect to a given base. |
| <a href="/docs/gql/mathematical-functions#log10">log10()</a> | Computes the base 10 logarithm of a given number. |
| <a href="/docs/gql/mathematical-functions#pi">pi()</a> | Returns the mathematical constant π (pi). |
| <a href="/docs/gql/mathematical-functions#e">e()</a> | Returns the mathematical constant *e* (Euler's number). |
| <a href="/docs/gql/mathematical-functions#random">random()</a> | Returns a random floating-point number between 0 and 1. |
| <a href="/docs/gql/mathematical-functions#sign">sign()</a> | Returns the sign of a number: -1, 0, or 1. |

### Trigonometric Functions

| <div table-width="15">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/trigonometric-functions#acos">acos()</a> | Computes the angle in radians whose cosine is a given number. |
| <a href="/docs/gql/trigonometric-functions#asin">asin()</a> | Computes the angle in radians whose sine is a given number. |
| <a href="/docs/gql/trigonometric-functions#atan">atan()</a> | Computes the angle in radians whose tangent is a given number. |
| <a href="/docs/gql/trigonometric-functions#atan2">atan2()</a> | Computes the angle in radians from the positive x-axis to the point (x, y). |
| <a href="/docs/gql/trigonometric-functions#cos">cos()</a> | Computes the cosine of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#cosh">cosh()</a> | Computes the hyperbolic cosine of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#cot">cot()</a> | Computes the cotangent of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#degrees">degrees()</a> | Converts an angle from radians to degrees. |
| <a href="/docs/gql/trigonometric-functions#radians">radians()</a> | Converts an angle from degrees to radians. |
| <a href="/docs/gql/trigonometric-functions#sin">sin()</a> | Computes the sine of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#sinh">sinh()</a> | Computes the hyperbolic sine of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#tan">tan()</a> | Computes the tangent of an angle expressed in radian. |
| <a href="/docs/gql/trigonometric-functions#tanh">tanh()</a> | Computes the angle in radians whose cosine is a given number. |

### String Functions

| Function | Description |
| -- | -- |
| <a href="/docs/gql/string-functions#char_length">char_length()</a> | Returns the number of characters in a string. |
| <a href="/docs/gql/string-functions#byte_length">byte_length()</a> | Returns the number of bytes in a string. |
| <a href="/docs/gql/string-functions#lower">lower()</a> | Converts all characters to lowercase. |
| <a href="/docs/gql/string-functions#upper">upper()</a> | Converts all characters to uppercase. |
| <a href="/docs/gql/string-functions#left">left()</a> | Returns the specified number of leftmost characters. |
| <a href="/docs/gql/string-functions#right">right()</a> | Returns the specified number of rightmost characters. |
| <a href="/docs/gql/string-functions#substring">substring()</a> | Returns a substring from the given string. |
| <a href="/docs/gql/string-functions#trim">trim()</a> | Removes characters from either end of a string. |
| <a href="/docs/gql/string-functions#trim_sc_both">trim_sc_both()</a> | Removes a specified single character from both ends of a string. |
| <a href="/docs/gql/string-functions#trim_sc_leading">trim_sc_leading()</a> | Removes a specified single character from the leading end of a string. |
| <a href="/docs/gql/string-functions#trim_sc_trailing">trim_sc_trailing()</a> | Removes a specified single character from the trailing end of a string. |
| <a href="/docs/gql/string-functions#ltrim">ltrim()</a> | Removes characters from the beginning of a string. |
| <a href="/docs/gql/string-functions#rtrim">rtrim()</a> | Removes characters from the end of a string. |
| <a href="/docs/gql/string-functions#btrim">btrim()</a> | Removes characters from both ends of a string. |
| <a href="/docs/gql/string-functions#reverse">reverse()</a> | Reverses a string. |
| <a href="/docs/gql/string-functions#replace">replace()</a> | Replaces all occurrences of a substring with another string. |
| <a href="/docs/gql/string-functions#split">split()</a> | Splits a string by a delimiter into a list. |
| <a href="/docs/gql/string-functions#contains">contains()</a> | Returns `true` if a string contains the specified substring. |
| <a href="/docs/gql/string-functions#starts_with">starts_with()</a> | Returns `true` if a string starts with the specified prefix. |
| <a href="/docs/gql/string-functions#ends_with">ends_with()</a> | Returns `true` if a string ends with the specified suffix. |
| <a href="/docs/gql/string-functions#normalize">normalize()</a> | Converts a string to a Unicode normalization form. |
| <a href="/docs/gql/string-functions#hex">hex()</a> | Encodes a string to hexadecimal. |
| <a href="/docs/gql/string-functions#unhex">unhex()</a> | Decodes a hexadecimal string to bytes. |
| <a href="/docs/gql/string-functions#base64">base64()</a> | Encodes a string to a Base64 string. |
| <a href="/docs/gql/string-functions#unbase64">unbase64()</a> | Decodes a Base64 string to bytes. |

### List Functions

| Function | Description |
| -- | -- |
| <a href="/docs/gql/list-functions#head">head()</a> | Returns the first element in a list. |
| <a href="/docs/gql/list-functions#last">last()</a> | Returns the last element of a list. |
| <a href="/docs/gql/list-functions#tail">tail()</a> | Returns all elements except the first. |
| <a href="/docs/gql/list-functions#reverse">reverse()</a> | Returns a list with elements in reversed order. |
| <a href="/docs/gql/list-functions#size">size()</a> | Returns the number of elements in a list. |
| <a href="/docs/gql/list-functions#append">append()</a> | Adds an element to the end of a list. |
| <a href="/docs/gql/list-functions#range">range()</a> | Generates a list of integers. |
| <a href="/docs/gql/list-functions#list_contains">list_contains()</a> | Returns `true` if a value exists in a specified list. |
| <a href="/docs/gql/list-functions#list_union">list_union()</a> | Returns the union of two lists. |
| <a href="/docs/gql/list-functions#intersection">intersection()</a> | Returns the intersection of two lists. |
| <a href="/docs/gql/list-functions#difference">difference()</a> | Returns the difference between two lists. |
| <a href="/docs/gql/list-functions#list_sort">list_sort()</a> | Sorts a list. |
| <a href="/docs/gql/list-functions#list_filter">list_filter()</a> | Filters a list by a condition. |
| <a href="/docs/gql/list-functions#reduce">reduce()</a> | Performs a calculation iteratively using each element in a list. |

### Datetime Functions

| <div table-width="20">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/datetime-functions#date">date()</a> | Creates a value of type `DATE` (`LOCAL DATE`). |
| <a href="/docs/gql/datetime-functions#local_time">local_time()</a> | Creates a value of type `LOCAL TIME`. |
| <a href="/docs/gql/datetime-functions#local_datetime">local_datetime()</a> | Creates a value of type `LOCAL DATETIME`. |
| <a href="/docs/gql/datetime-functions#zoned_time">zoned_time()</a> | Creates a value of type `ZONED TIME`. |
| <a href="/docs/gql/datetime-functions#zoned_datetime">zoned_datetime()</a> | Creates a value of type `ZONED DATETIME`. |
| <a href="/docs/gql/datetime-functions#now">now()</a> | Returns the current zoned datetime in the server's local timezone. |
| <a href="/docs/gql/datetime-functions#duration">duration()</a> | Creates a value of type `DURATION`. |
| <a href="/docs/gql/datetime-functions#date_add">date_add()</a> | Adds a time interval to a date. |
| <a href="/docs/gql/datetime-functions#date_diff">date_diff()</a> | Computes the difference between two dates. |
| <a href="/docs/gql/datetime-functions#day_of_week">day_of_week()</a> | Returns the day of the week for a given date. |
| <a href="/docs/gql/datetime-functions#year">year()</a> | Extracts the year. |
| <a href="/docs/gql/datetime-functions#month">month()</a> | Extracts the month. |
| <a href="/docs/gql/datetime-functions#day">day()</a> | Extracts the day. |
| <a href="/docs/gql/datetime-functions#hour">hour()</a> | Extracts the hour. |
| <a href="/docs/gql/datetime-functions#minute">minute()</a> | Extracts the minute. |
| <a href="/docs/gql/datetime-functions#second">second()</a> | Extracts the second. |
| <a href="/docs/gql/datetime-functions#duration_between">duration_between()</a> | Computes the duration between two temporal values. |
| <a href="/docs/gql/datetime-functions#date_format">date_format()</a> | Formats a temporal value as a string. |

### Spatial Functions

| <div table-width="16">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/spatial-functions/#point">point()</a> | Creates a `POINT` or `POINT3D` value. |
| <a href="/docs/gql/spatial-functions/#point3d">point3d()</a> | Creates a `POINT3D` value. |
| <a href="/docs/gql/spatial-functions/#distance">distance()</a> | Computes the distance between two points. |
| <a href="/docs/gql/spatial-functions/#point_get">point_get()</a> | Extracts a coordinate value from a point by index. |

### Null Functions

| Function | Description |
| -- | -- |
| <a href="/docs/gql/null-functions#coalesce">coalesce()</a> | Returns the first non-null value from the argument list. |
| <a href="/docs/gql/null-functions#nullif">nullif()</a> | Returns `null` if two arguments are equal; otherwise returns the first. |

### Utility Functions

| Function | Description |
| -- | -- |
| <a href="/docs/gql/utility-functions#cardinality">cardinality()</a> | Returns the size of a path, list, or record. |
| <a href="/docs/gql/utility-functions#type_of">type_of()</a> | Returns the type name of a value as a string. |
| <a href="/docs/gql/utility-functions#all_different">all_different()</a> | Returns `true` if all arguments are different graph elements. |

### Type Conversion Functions

| Function | Description |
| -- | -- |
| <a href="/docs/gql/type-conversion-functions#cast">cast()</a> | Converts a value to the specified type. |
| <a href="/docs/gql/type-conversion-functions#to_integer">to_integer()</a> | Converts a value to an integer. |
| <a href="/docs/gql/type-conversion-functions#to_float">to_float()</a> | Converts a value to a float. |
| <a href="/docs/gql/type-conversion-functions#to_string">to_string()</a> | Converts a value to a string. |
| <a href="/docs/gql/type-conversion-functions#to_boolean">to_boolean()</a> | Converts a value to a boolean. |
| <a href="/docs/gql/type-conversion-functions#to_list">to_list()</a> | Converts a value to a list. |
| <a href="/docs/gql/type-conversion-functions#to_map">to_map()</a> | Creates a record from key-value pairs. |

### Table Functions

| <div table-width="16">Function</div> | Description |
| -- | -- |
| <a href="/docs/gql/table-functions#table">table()</a> | Constructs a table. |

### Database Functions

Database functions report on the running server and the current graph: version, license, loaded plugins, statistics, schema, backups, and graph-health diagnostics.

- **Introspection:** `db.version()`, `db.license()`, `db.stats()`, `db.overview()`, `db.node_labels()`, `db.edge_labels()`, `db.label_property()`, etc. See <a target="_blank" href="/docs/operations/database-info">Operations → Database Info</a>.
- **Backup and Restore:** `db.backup()`, `db.restore()`, `db.backups()`, etc. See <a target="_blank" href="/docs/operations/backup-restore">Operations → Backup & Restore</a>.
- **Diagnostics and Repair:** `db.validate_graph()`, `db.storage_health()`, `db.reload_stats()`, `db.repair_label_index()`, `db.repair_storage()`, `db.delete_orphans_edges()`, etc. See <a target="_blank" href="/docs/operations/diagnostics-and-repair">Operations → Diagnostics and Repair</a>.

### AI & Vector Functions

AI and vector functions (vector creation, embeddings, similarity, vector index ops, NL→GQL pipeline) are documented in <a href="/docs/ai-and-vectors">AI &amp; Vectors</a>.