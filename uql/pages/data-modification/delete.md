# Delete

## Overview

The `delete()` statement removes nodes or edges that meet specified conditions.

<p tit="Syntax"></p>

```uql
// Deletes isolated nodes
delete().nodes(<filter?>).nodetach()

// Deletes nodes along with any edges connected to them
delete().nodes(<filter?>).detach()

// Deletes edges
delete().edges(<filter?>)
```

| <div table-width="14">Method</div> | <div table-width="11">Param</div> | Description | <div table-width="11">Optional</div> |
| -- | -- | -- | -- |
| `nodes()` or `edges()` | `<filter?>` | The filtering condition enclosed in `{}`, or an alias to specify the nodes or edges to delete. If left blank, all nodes or edges are targeted. | No |
| `nodetach()` | / | Prevents the deletion of nodes that still have edges connected to them; it is implicitly applied. | Yes |
| `detach()` | / | Enforces the deletion of nodes along with edges connected to them. | Yes |

An edge cannot exist if any of its endpoints is removed from the graph. By default, UQL does not allow to delete a node while it still has edges connected to it.

However, you can use the method `detach()` or `nodetach().force()` to enable the deletion of nodes along with their connected edges. For example, when node `B` is deleted, edges `1`, `2` and `4` will also be deleted.

<div align=center drawio-diagram='19514' drawio-name='draw_da0e5858a9524759ad9de6112e7d2c62.jpg'><img src="https://img.ultipa.cn/draw/draw_da0e5858a9524759ad9de6112e7d2c62.jpg?v='1731490716601'"/></div>

## Example Graph

<div align=center drawio-diagram='19330' drawio-name="draw_76ac5e1951d84252acacc3ebdc27c9b9.jpg"><img src="https://img.ultipa.cn/draw/draw_76ac5e1951d84252acacc3ebdc27c9b9.jpg?v='1731490809049'"/></div>

To create the graph, execute the following UQL queries sequentially in an empty graphset:

```uql
create().node_schema("user").edge_schema("follow")
create().node_property(@user, "name").node_property(@user, "age", int32).edge_property(@follow, "time", datetime)
insert().into(@user).nodes([{_id:"U001", name:"Jason", age:30}, {_id:"U002", name:"Tim"}, {_id:"U003", name:"Grace", age:25}, {_id:"U004", name:"Ted", age:26}, {_id:"U005", name:"Kyle", age:21}])
insert().into(@follow).edges([{_from:"U004", _to:"U001", time:"2021-9-10"}, {_from:"U003", _to:"U001", time:"2020-3-12"}, {_from:"U004", _to:"U002", time:"2023-7-30"}])
```

## Deleting Isolated Nodes

To delete the isolated node whose `name` is Kyle:

```uql
delete().nodes({name == "Kyle"})
```

The `delete().nodes()` query can only delete isolated nodes, if any node specified has connected edges, an error will be thrown, and no nodes will be deleted.

## Deleting Any Nodes

To delete the node whose `name` is Grace along with its connected edges:

```uql
delete().nodes({name == "Grace"}).detach()
```

To delete all nodes along with all edges:

```uql
delete().nodes().detach()
```

## Deleting Edges

To delete `@follow` edges:

```uql
delete().edges({@follow})
```

## Limiting the Amount to Delete

To limit the number of nodes or edges to delete, first retrieve the data from the database using statements like `find()`, then apply the `LIMIT` statement to keep only the first N records before passing the alias to the `delete()` statement.

To delete any two edges:

```uql
find().edges() as e limit 2
delete().edges(e)
return e{*}
```

Result: `e`

| <div table-width="9">_uuid</div> | <div table-width="6">_from</div> | <div table-width="6">_to</div> | <div table-width="14">_from_uuid</div> | <div table-width="14">_to_uuid</div> | <div table-width="8">schema</div> | values |
| -- | -- | -- | -- | -- | -- | -- |
| <span style="color: #999;">Sys-gen</span> | U004 | U001 | <span style="color: #999;">UUID of U004</span> | <span style="color: #999;">UUID of U001</span> | follow | {time: "2021-09-11 00:00:00"} |
| <span style="color: #999;">Sys-gen</span> | U004 | U002 | <span style="color: #999;">UUID of U004</span> | <span style="color: #999;">UUID of U002</span> | follow | {time: "2023-07-31 00:00:00"} |
