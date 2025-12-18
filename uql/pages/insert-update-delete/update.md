# Update

## Overview

The `update()` clauses is used to update values of properties (except `_id` and `_uuid`) of nodes and edges that meet the given conditions.

## Syntax

<p tit="Syntax"></p> 

```uql
// Update nodes
update().nodes(<filter>)
  .set({<property1>: <value1>, <property2>: <value2> ...})
  .limit(<N>)

// Update edges
update().edges(<filter>)
  .set({<property1>: <value1>, <property2>: <value2> ...})
  .limit(<N>)
```

- The nodes or edges to be updated must meet the conditions specified in the `nodes()` or `edges()` method. Leave it blank to specify all nodes or edges.
- Provide new values for properties in the `set()` method.
- Optionally use the `limit()` method to restrict the number of nodes or edges to update.
- Allow to define an alias for the clause, with the data type being either NODE or EDGE.

## Example Graph

<div align=center drawio-diagram='15464' drawio-name="draw_7ba67eef1d1944c68565eb64b7a3cdf9.jpg"><img src="https://img.ultipa.cn/draw/draw_7ba67eef1d1944c68565eb64b7a3cdf9.jpg?v='1715850533768'"/></div>

Run these UQLs row by row in an empty graphset to create this graph:

<p tit="" fold="true"></p>

```uql
create().node_schema("user").edge_schema("follow")
create().node_property(@user, "name").node_property(@user, "age", int32).edge_property(@follow, "time", datetime)
insert().into(@user).nodes([{_id:"U001", _uuid:1, name:"Jason", age:30}, {_id:"U002", _uuid:2, name:"Tim"}, {_id:"U003", _uuid:3, name:"Grace", age:25}, {_id:"U004", _uuid:4, name:"Ted", age:26}])
insert().into(@follow).edges([{_uuid:1, _from_uuid:4, _to_uuid:1, time:"2021-9-10"}, {_uuid:2, _from_uuid:3, _to_uuid:2, time:"2020-3-12"}, {_uuid:3, _from_uuid:4, _to_uuid:2, time:"2023-7-30"}])
```

## Examples

### Update Nodes

```uql
update().nodes({name == "Tim"}).set({name: "Tom"})
```

This updates the `name` property of nodes whose `name` is Tim. The node with `_id` U002 is updated.

### Update Edges

```uql
update().edges({time > "2021-5-1"}).set({time: dateAdd(time, 1, "day")}) as edges
return edges{*}
```

This updates the `time` property of edges whose `time` is later than 2021-5-1, to one day after.

Result:

| \_uuid | \_from | \_to | <div table-width=15>\_from_uuid</div> | \_to_uuid| <div table-width=23>time</div> |
| -- | -- | -- | -- | -- | -- |
| 1 | U004 | U001 | 4 | 1 | 2021-09-11 00:00:00 |
| 3 | U004 | U002 | 4 | 2 | 2023-07-31 00:00:00 |

### Update All Nodes/Edges

```uql
update().nodes().set({age: age + 1}) as n
return table(n.name, n.age)
```

Result:

| name | age |
| -- | -- |
| Jason | 31 |
| Tom | `null` |
| Grace | 26 |
| Ted | 27 |

### Update Limited Nodes/Edges

```uql
update().nodes({@user}).set({name: lower(name)}).limit(2) as nodes
return nodes{*}
```

This updates the `name` property of `@user` nodes to lowercase characters, but only for two nodes.

Result:

| \_id | \_uuid | name | age |
| -- | -- | -- | -- |
| U001 | 1 | jason | 31 |
| U002 | 2 | tom | `null` |

## Common Reasons for Failures

- Update fails when `_uuid` or `_id` is included in the `set()` method, as unique identifier properties cannot be updated.
