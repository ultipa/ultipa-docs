# Delete

## Overview

The `delete()` clause is used to delete nodes or edges that meet the given conditions. It's important to note that deleting a node leads to the removal of all edges that are connected to it.

The delete operation is irreversible.

## Syntax

<p tit="Syntax"></p> 

```js
// Delete nodes
delete().nodes(<filter>).limit(<N>)
               
// Delete edges
delete().edges(<filter>).limit(<N>)
```

- The nodes or edges to be deleted must meet the conditions specified in the `nodes()` or `edges()` method. Leave it blank to specify all nodes or edges.
- Optionally use the `limit()` method to restrict the number of nodes or edges to delete.
- Not allowed to define an alias for the clause.

## Example Graph

<div align=center drawio-diagram='15464' drawio-name="draw_7ba67eef1d1944c68565eb64b7a3cdf9.jpg"><img src="https://img.ultipa.cn/draw/draw_7ba67eef1d1944c68565eb64b7a3cdf9.jpg?v='1715850533768'"/></div>

Run these UQLs row by row in an empty graphset to create this graph:

<p tit="" fold="true"></p>

```js
create().node_schema("user").edge_schema("follow")
create().node_property(@user, "name").node_property(@user, "age", int32).edge_property(@follow, "time", datetime)
insert().into(@user).nodes([{_id:"U001", _uuid:1, name:"Jason", age:30}, {_id:"U002", _uuid:2, name:"Tim"}, {_id:"U003", _uuid:3, name:"Grace", age:25}, {_id:"U004", _uuid:4, name:"Ted", age:26}])
insert().into(@follow).edges([{_uuid:1, _from_uuid:4, _to_uuid:1, time:"2021-9-10"}, {_uuid:2, _from_uuid:3, _to_uuid:2, time:"2020-3-12"}, {_uuid:3, _from_uuid:4, _to_uuid:2, time:"2023-7-30"}])
```

## Examples

### Delete Nodes

```js
delete().nodes({name == "Grace"})
```

The node with `_id` U003 is deleted, along with the edge with `_uuid` 2.

### Delete Edges

```js
delete().edges({@follow})
```

All `@follow` edges are deleted.

### Delete Limited Nodes

```js
delete().nodes({@user.age > 26}).limit(2)
```

This deletes the `@user` nodes whose `age` property values are greater than 26, limited to two nodes.