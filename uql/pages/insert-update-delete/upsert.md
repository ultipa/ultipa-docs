# Upsert

## Overview

The `upsert().into()` clause facilitates either the update of existing nodes or edges within a single schema or the insertion of new nodes or edges.

## Syntax

<p tit="Syntax"></p> 

```uql
// Update or insert nodes
upsert().into(@<schema>).nodes([
  {<property1>: <value1>, <property2>: <value2>, ...},
  {<property1>: <value1>, <property2>: <value2>, ...}
])

// Update or insert edges
upsert().into(@<schema>).edges([
  {<property1>: <value1>, <property2>: <value2>, ...},
  {<property1>: <value1>, <property2>: <value2>, ...}
])
```

- Specify one schema in the `into()` method.
- Include one or multiple nodes or edges in the `nodes()` or `edges()` method.
  - Provide key-value pairs of properties for each node or edge enclosed in `{ }`. 
  - If there is only one node or edge, the outer `[ ]` can be omitted.
- Allow to define an alias for the clause, with the data type being either NODE or EDGE.

When a node or edge is updated:

- The targeted node is specified by its `_id` and/or `_uuid`; the targeted edge is specified by its `_uuid`, `_from` and `_to` (or `_from_uuid` and `_to_uuid`)
- The values of provided custom properties will be updated; the values of missing custom properties will remain unchanged.
- The values of system properties (`_id`, `_uuid`, `_from`, `_to`, `_from_uuid`, `_to_uuid`) remain unchanged.

A new node is inserted when new `_id` or `_uuid` is provided, or when both `_id` and `_uuid` are missing.

A new edge is inserted when new `_uuid` is provided, or when `_uuid` is missing.

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

### Update or Insert Nodes

```uql
upsert().into(@user).nodes([
  {_id: "U001", name: "John"},
  {_id: "U005", name: "Alice"},
  {age: 12}
]) as n
return n{*}
```

- The first node with the provided `_id` U001 exists in the graph, so it is updated.
- The second is a new node to be inserted, as the provided `_id` U005 does not exist in the graph.
- The third is a new node to be inserted, as both `_id` and `_uuid` are missing.

Result:

| <div table-width=35>\_id</div> | \_uuid | name | age |
| -- | -- | -- | -- |
| U001 | 1 | John | 30 |
| U005 | 5 | Alice | `null` |
| ULTIPA8000000000000006 | 6 | `null` | 12 |

### Update or Insert Edges

```uql
upsert().into(@follow).edges([
  {_uuid: 1, _from: "U004", _to: "U001", time: "2022-9-12"},
  {_uuid: 4, _from: "U002", _to: "U003"},
  {_from: "U002", _to: "U001", time: "2023-9-6"}
]) as e
return e{*}
```

- The first edge with the provided `_uuid` 1, `_from` U004, and `_to` U001 exists in the graph, so it's updated.
- The second is a new edge to be inserted, as the provided `_uuid` 4 does not exist in the graph.
- The third is a new edge to be inserted, as `_uuid` is missing.

Result:

| \_uuid | \_from | \_to | <div table-width=15>\_from_uuid</div> | \_to_uuid| <div table-width=23>time</div> |
| -- | -- | -- | -- | -- | -- |
| 1 | U004 | U001 | 4 | 1 | 2022-09-12 00:00:00 |
| 4 | U002 | U003 | 2 | 3 | `null` |
| 5 | U002 | U001 | 2 | 1 | 2023-09-06 00:00:00 |
 
## Common Reasons for Failures

- Node update or insertion fails when both `_id` and `_uuid` are provided, one of their values exists in the graph while the other one does not.
- Node update or insertion fails when `_id` and `_uuid` are provided, they both exist in the graph but they don't match.
- Edge update or insertion fails when the start or end node is not specified.
- Edge update or insertion fails when the specified start or end node does not exist in the graph.
- Edge update fails when the given existing `_uuid` does not match the given start and end nodes.
