# Update

## Overview

The `update()` statement updates custom property values of nodes and edges that meet the given conditions.

System properties of nodes and edges (`_id`, `_uuid`) are immutable. Similarly, the source and destination nodes of an edge cannot be reassigned once the edge is created.

<p tit="Syntax"></p>

```uql
// Updates nodes
update().nodes(<filter?>)
  .set({<property1>: <value1>, <property2?>: <value2?> ...})

// Updates edges
update().edges(<filter?>)
  .set({<property1>: <value1>, <property2?>: <value2?> ...})
```

| <div table-width="12">Method</div> | <div table-width="15">Param</div> | Description |
| -- | -- | -- |
| `nodes()` or `edges()` | `<filter?>` | The filtering condition enclosed in `{}`, or an alias to specify the nodes or edges to update. Leaving it blank will target all nodes or edges. |
| `set()` | Property specification | Assigns the updates with a property specification wrapped in `{}`. |

## Example Graph

<div align=center drawio-diagram='19329' drawio-name='draw_3e4c20cc74cb4e8082574f247bbfdc54.jpg'><img src="https://img.ultipa.cn/draw/draw_3e4c20cc74cb4e8082574f247bbfdc54.jpg?v='1730165675609'"/></div>

To create the graph, execute each of the following UQL queries sequentially in an empty graphset:

```uql
create().node_schema("user").edge_schema("follow")
create().node_property(@user, "name").node_property(@user, "age", int32).edge_property(@follow, "time", datetime)
insert().into(@user).nodes([{_id:"U001", name:"Jason", age:30}, {_id:"U002", name:"Tim"}, {_id:"U003", name:"Grace", age:25}, {_id:"U004", name:"Ted", age:26}])
insert().into(@follow).edges([{_from:"U004", _to:"U001", time:"2021-9-10"}, {_from:"U003", _to:"U001", time:"2020-3-12"}, {_from:"U004", _to:"U002", time:"2023-7-30"}])
```

## Updating Nodes

To update the `name` property of nodes whose `name` is currently Tim:

```uql
update().nodes({name == "Tim"}).set({name: "Tom"})
```

## Updating Edges

To update the `time` property of edges whose current `time` is later than 2021-5-21, setting it to one day later, and to return the updated edges:

```uql
update().edges({time > "2021-5-1"}).set({time: dateAdd(time, 1, "day")}) as edges
return edges{*}
```

Result: `edges`

| <div table-width="9">_uuid</div> | <div table-width="6">_from</div> | <div table-width="6">_to</div> | <div table-width="14">_from_uuid</div> | <div table-width="14">_to_uuid</div> | <div table-width="8">schema</div> | values |
| -- | -- | -- | -- | -- | -- | -- |
| <span style="color: #999;">Sys-gen</span> | U004 | U001 | <span style="color: #999;">UUID of U004</span> | <span style="color: #999;">UUID of U001</span> | follow | {time: "2021-09-11 00:00:00"} |
| <span style="color: #999;">Sys-gen</span> | U004 | U002 | <span style="color: #999;">UUID of U004</span> | <span style="color: #999;">UUID of U002</span> | follow | {time: "2023-07-31 00:00:00"} |

## Updating All

To update the `age` property of all nodes by incrementing it to the next integer value:

```uql
update().nodes().set({age: age + 1}) as n
return table(n.name, n.age)
```

Result:

| name | age |
| -- | -- |
| Jason | 31 |
| Tim | `null` |
| Grace | 26 |
| Ted | 27 |

## Limiting the Amount to Update

To limit the number of nodes or edges to update, first retrieve the data from the database using a clause like `find()`, then apply the `LIMIT N` clause to keep only the first `N` rows before passing the alias to the `update()` clause.

To update the `name` property of only two `@user` nodes, setting it to lowercase:

```uql
find().nodes({@user}) as n1 limit 2
update().nodes(n1).set({name: lower(name)}) as n2
return n2{*}
```

Result: `n2`

| <div table-width="9">_id</div> | <div table-width="9">_uuid</div> | <div table-width="10">schema</div> | values |
| -- | -- | -- | -- |
| U004 | <span style="color: #999;">Sys-gen</span> | user | {name: "ted", age: 26} |
| U002 | <span style="color: #999;">Sys-gen</span> | user | {name: "tim", age: `null`} |

## Removing Property Values

To remove the `name` and `age` property values of the node with `_id` U001:

```uql
update().nodes({_id == "U001"}).set({name: null, age: null})
```
