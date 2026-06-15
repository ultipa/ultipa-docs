# JSON_decode()

## Overview

The `JSON_decode()` function converts a JSON-formatted string to an object and returns the object.

## Syntax

`JSON_decode(str)`

| Argument | Type | <div table-width=60>Description</div> |
| -- | -- | -- |
| `str` | String | The JSON-formatted string |

<b>Return type: </b>Object

## Example of Result

```uql
return JSON_decode('{"name":"Lisa","age":23}')
```

Result: {"name":"Lisa","age":23}

## Example of Use

Parse JSON-formatted data into usable object format, and dynamically update nodes based on the keys of the parsed object.

```uql
UNCOLLECT ['{"name":"Lisa","age":23}', '{"name":"Paul","age":35}'] as strings
with JSON_decode(strings) as object
update().nodes({name == object.name}).set({age: object.age})
```
