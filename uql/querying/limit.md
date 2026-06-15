# LIMIT

## Overview

The `LIMIT` statement retains a specified number of records from the start of the data and discards the remaining ones.

<div align=center drawio-diagram='19610' drawio-name='draw_624d762e04784d3381f3b1e93b62da96.jpg'><img src="https://img.ultipa.cn/draw/draw_624d762e04784d3381f3b1e93b62da96.jpg?v='1732785978655'"/></div>

## Syntax

<p tit="Syntax"></p>

```uql
LIMIT <N>
```

**Details**

- `<N>` is a non-negative integer or `-1`. A value of `-1` retains all records.

## LIMIT and limit()

The `limit()` method can be chained to pathfinding and K-Hop queries (`ab()`, `autonet()`, `spread()`, `khop()`, path templates, and K-Hop templates) to restrict the number of paths or K-hop neighbors returned for each start node or node pair.

On the other hand, the `LIMIT` statement is used independently to limit the maximum number of records retained in the resulting data.

## Example Graph

<div align=center drawio-diagram='19611' drawio-name='draw_36d96bd2e51a4cb09cef790dbd750577.jpg'><img src="https://img.ultipa.cn/draw/draw_36d96bd2e51a4cb09cef790dbd750577.jpg?v='1732786332693'"/></div>

To create the graph, execute each of the following UQL queries sequentially in an empty graphset:

```uql
create().node_schema("student").node_schema("course").edge_schema("takes")
create().node_property(@*, "name").node_property(@student, "age", int32).node_property(@course, "credits", int32)
insert().into(@student).nodes([{_id:"S1", name:"Jason", age:25}, {_id:"S2", name:"Lina", age:23}, {_id:"S3", name:"Eric", age:24}, {_id:"S4", name:"Emma", age:26}, {_id:"S5", name:"Pepe", age:24}])
insert().into(@course).nodes([{_id:"C1", name:"French", credits:4}, {_id:"C2", name:"Math", credits:5}])
insert().into(@takes).edges([{_from:"S1", _to:"C1"}, {_from:"S2", _to:"C1"}, {_from:"S3", _to:"C1"}, {_from:"S2", _to:"C2"}, {_from:"S3", _to:"C2"}, {_from:"S4", _to:"C2"}, {_from:"S5", _to:"C2"}])
```

## Limiting Records Returned

```uql
find().nodes({@student}) as n
limit 3
return n.name
```

Result:

| n.name |
| -- |
| Pepe |
| Jason |
| Eric |

`LIMIT` can also be placed after `RETURN`. The following query produces the same result as the one above:

```uql
find().nodes({@student}) as n
return n.name
limit 3
```

## Limiting Records Passed Forward

```uql
find().nodes({@student}) as n limit 1
n(n).e().n({@course}) as p
return p{*}
```

Result: `p`

<div align=center drawio-diagram='19770' drawio-name='draw_144e730d709f4da28fbf8189a637a778.jpg'><img src="https://img.ultipa.cn/draw/draw_144e730d709f4da28fbf8189a637a778.jpg?v='1733911427510'"/></div>

```uql
Pepe -> Math
```

## Limiting Ordered Records

```uql
find().nodes({@student}) as n
order by n.age desc
limit 3
return n.name
```

Result:

| n.name |
| -- |
| Emma |
| Jason |
| Pepe |
