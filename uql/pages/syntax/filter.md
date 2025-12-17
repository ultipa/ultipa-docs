# Filter

## Overview

In UQL, a **filter** is used to set conditions for retrieving nodes and edges based on their schemas and properties. 

Filters are implemented within some methods that represent nodes or edges in query clauses. For example, the `nodes()` and `edges()` methods.

## Syntax

A filter is an expression enclosed within curly braces `{ }`. Typically, it involves references of the schemas and properties of nodes and edges.

Example: Find `@user` nodes, and `@movie` nodes whose `rating` property values are above 3.
```js
find().nodes({@user || @movie.rating > 3}) as n
return n{*}
```

A filter evaluates either a boolean value or null. It determines the validity of a node or edge by returning true when the filter condition is met.

In cases where the expression of the filter does not yield a boolean value or null, the result is converted to either true or false based on its type and value:

| Type | Convert to true | Convert to false |
|-|-|-|
| int32，uint32，int64，uint64，float，double | When it is not equal to 0 | When it is equal to 0 |
| string，text | When the first character is not '0'| When the first character is '0' |
| datetime | When it is not '0000-00-00 00:00:00'  | When it is '0000-00-00 00:00:00' |
| timestamp | When it is not '1970-01-01 08:00:00 +08:00' (or equivalent) | When it is '1970-01-01 08:00:00 +08:00' (or equivalent) |
| point | Never  | Any value |
| list | Never  | Any value |

Example: Find `@user` nodes whose `age` property values, when subtracted by 33, result in non-zero values.
```js
find().nodes({@user.age - 33}) as n
return n{*}
```

## Examples

### General Filter

In any query clause, you can filter nodes and edges by comparing their schemas and properties with some constant values and/or aliases.

```js
find().nodes({@user.registeredOn >= "2021-09-01 09:00:00"}) as u1
with max(u1.age) as maxAge
find().nodes({@user.age == maxAge}) as u2
return u2
```

```js
n(as start).e()[3].n({level == start.level}) as p
return p
```

Note: The second node template `n()` calls the alias defined in the first node template.

> Generally, properties referenced in the filter can be used directly without any indexing. However, different types of indexing should be contemplated when seeking to expedite the query process. Please refer to <a href="/docs/uql/acceleration">Acceleration</a> for more information.

### Inter-Step Filter

In a template-based query clause, you can employ the system aliases <a href="/docs/uql/alias#prev_n">prev_n</a> and <a href="/docs/uql/alias#prev_e">prev_e</a> to facilitate inter-step filtering.

```js
n({@card}).e({@transfersTo.time > prev_e.time})[3].n({@card}) as p
return p
```

> The properties referenced by `prev_n` and `prev_e` (such as the *time* property in the example) must be <a href="/docs/uql/lte">LTE</a>-ed for acceleration.

The methods `path_ascend()` and `path_descend()` in certain path query commands like `ab()` serve the same purpose of inter-step comparison, and they necessitate the subject property to be LTE-ed as well. However, the input for these methods does not take the form of a filter.

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(:3).path_ascend(@default.weight) as p
return p{*}
```

### Full-Text Filter

In any query clause, nodes and edges can be filtered using a created <a href="/docs/uql/full-text">full-text index</a>.

```js
find().nodes({~content CONTAINS "graph computing parallel"}) as n
return n{*}
```
