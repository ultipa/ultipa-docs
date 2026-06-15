# Filter

## Overview

A filter sets conditions for retrieving nodes and edges based on schemas and properties and is used within certain clause methods.

In UQL, filters are enclosed in curly braces `{}`. Filter expressions typically contain comparison operators such as `=`, `>`, `<`, and logical operators such as `AND` and `OR`. Each filter expression evaluates to a boolean (TRUE or FALSE) or `null`, validating nodes or edges only it returns TRUE.

## General Filter

In this example, the filter `{@user || @movie.rating > 3}` specifies that the clause retrieves `@user` nodes or `@movie` nodes with a `rating` greater than 3:

```uql
find().nodes({@user || @movie.rating > 3}) as n
return n{*}
```

## Simplified Filter

In this example, the filter `{age}` specifies that the clause retrieves nodes with an `age` property whose value, when subtracted by 30, is non-zero:

```uql
find().nodes({age - 30}) as n
return n{*}
```

The table below summarizes how different data types are evaluated as TRUE or FALSE in filters:

| <div table-width="28">Type</div> | TRUE | FALSE |
| -- | -- | -- |
| `int32`，`uint32`，`int64`，`uint64`，`float`，`double` | Non-Zero | 0 |
| `string`，`text` | Does not start with the character "0" | Starts with the character "0" |
| `datetime` | Any date except `0000-00-00 00:00:00` | `0000-00-00 00:00:00` |
| `timestamp` | Any date except `1970-01-01 08:00:00 +08:00` or equivalent | `1970-01-01 08:00:00 +08:00` or equivalent |
| `point` | Never | Any value |
| `list` | Never | Any value |

## Inter-Step Filter

In a **path template**, you can use the <a target="_blank" href="/docs/uqlalias#System-Alias">system alias `prev_n` or `prev_e`</a> to facilitate inter-step filtering.

This query finds 4-step outgoing transaction paths between `@card` nodes, ensuring that each transaction time is greater than the previous one:

```uql
n({@card}).re({@transfers}).n({@card})
  .re({@transfers.time > prev_e.time})[3]
  .n({@card}) as p
return p{*}
```

Any property called by `prev_n` or `prev_e`, such as the `time` property in the example, must be <a target="_blank" href="/docs/uqllte">LTE</a>-ed for acceleration.
