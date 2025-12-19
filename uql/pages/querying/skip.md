# SKIP

## Overview

The `SKIP` statement discards a specified number of records from the start of the data.

<div align=center drawio-diagram='19608' drawio-name='draw_231be39b1eb349ccacc8d4c3ea665ff4.jpg'><img src="https://img.ultipa.cn/draw/draw_231be39b1eb349ccacc8d4c3ea665ff4.jpg?v='1732784920737'"/></div>

## Syntax

<p tit="Syntax"></p>

```uql
SKIP <N>
```

**Details**

- `<N>` is a non-negative integer.

## Example Graph

<div align=center drawio-diagram='19609' drawio-name="draw_a796f9069e3041f1a10e9e48b0b9fadf.jpg"><img src="https://img.ultipa.cn/draw/draw_a796f9069e3041f1a10e9e48b0b9fadf.jpg?v='1733208115084'"/></div>

To create the graph, execute each of the following UQL queries sequentially in an empty graphset:

```uql
create().node_schema("student").node_schema("course").edge_schema("takes")
create().node_property(@*, "name").node_property(@student, "age", int32).node_property(@course, "credits", int32)
insert().into(@student).nodes([{_id:"S1", name:"Jason", age:25}, {_id:"S2", name:"Lina", age:23}, {_id:"S3", name:"Eric", age:24}, {_id:"S4", name:"Emma", age:26}, {_id:"S5", name:"Pepe", age:24}])
insert().into(@course).nodes([{_id:"C1", name:"French", credits:4}, {_id:"C2", name:"Math", credits:5}])
insert().into(@takes).edges([{_from:"S1", _to:"C1"}, {_from:"S2", _to:"C1"}, {_from:"S3", _to:"C1"}, {_from:"S2", _to:"C2"}, {_from:"S3", _to:"C2"}, {_from:"S4", _to:"C2"}, {_from:"S5", _to:"C2"}])
```

## Skipping N Records

```uql
find().nodes({@student}) as n
skip 2
return n.name
```

Result:

| n.name |
| -- |
| Eric |
| Emma |
| Lina |

## Skipping N Ordered Records

```uql
find().nodes({@student}) as n
order by n.age
skip 2
return n.name
```

Result:

| n.name |
| -- |
| Pepe |
| Jason |
| Emma |
