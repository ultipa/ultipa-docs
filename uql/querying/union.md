# UNION

## Overview

The `UNION` statement combines results of two or more queries into a single result set that includes the distinct records present in any of the query. When multiple return items are involved, the combination of their values is unique.

<div align=center drawio-diagram='19649' drawio-name="draw_a432ba5cb9894759a59a48dfa80fcd64.jpg"><img src="https://img.ultipa.cn/draw/draw_a432ba5cb9894759a59a48dfa80fcd64.jpg?v='1733207813068'"/></div>

To keep all the records without deduplication, use the `UNION ALL` statement.

## Syntax

<p tit="Syntax"></p>

```uql
...
return <item1> as <alias1?>, <item2?> as <alias2?>, ...
union
...
return <item1> as <alias1?>, <item2?> as <alias2?>, ...
```

**Details**

- The return items in all queries combined by `UNION` must be identical.

## Example Graph

<div align=center drawio-diagram='19650' drawio-name="draw_82d2c7ac4f294ae08cda8d92ffe9bccb.jpg"><img src="https://img.ultipa.cn/draw/draw_82d2c7ac4f294ae08cda8d92ffe9bccb.jpg?v='1733208697137'"/></div>

To create the graph, execute each of the following UQL queries sequentially in an empty graphset:

```uql
create().node_schema("student").node_schema("course").edge_schema("takes")
create().node_property(@*, "name").node_property(@student, "age", int32).node_property(@course, "credits", int32)
insert().into(@student).nodes([{_id:"S1", name:"Jason", age:25}, {_id:"S2", name:"Lina", age:23}, {_id:"S3", name:"Eric", age:24}, {_id:"S4", name:"Emma", age:26}, {_id:"S5", name:"Pepe", age:24}])
insert().into(@course).nodes([{_id:"C1", name:"French", credits:4}, {_id:"C2", name:"Math", credits:5}])
insert().into(@takes).edges([{_from:"S1", _to:"C1"}, {_from:"S2", _to:"C1"}, {_from:"S3", _to:"C1"}, {_from:"S2", _to:"C2"}, {_from:"S3", _to:"C2"}, {_from:"S4", _to:"C2"}, {_from:"S5", _to:"C2"}])
```

## Combining Queries

```uql
n({@course.name == "French"}).e().n({@student} as s) return s.name
union
n({@course.name == "Math"}).e().n({@student} as s) return s.name
```

Result:

| s.name |
| -- |
| Lina |
| Eric |
| Jason |
| Emma |
| Pepe |

```uql
n({@course.name == "French"} as c).e().n({@student} as s) return c.name, s.age
union
n({@course.name == "Math"} as c).e().n({@student} as s) return c.name, s.age
```

Result:

| c.name | s.age |
| -- | -- |
| French | 23 |
| French | 24 |
| French | 25 |
| Math | 23 |
| Math | 26 |
| Math | 24 |
