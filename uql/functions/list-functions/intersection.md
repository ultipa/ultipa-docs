# intersection()

Function `intersection()` calculates the common elements of two <i>list</i>s and returns them as a new <i>list</i>, namely, returns the intersection of these two <i>list</i>s (repeated elements are allowed in the intersection).

Arguments：
- 1st list \<list>
- 2nd list \<list>

Returns：
- Intersection \<list>


## Common Usage

Example: Direct calculate


```uql
uncollect [[1,2,2],[2,4,5]] as a
uncollect [[2,4,7],[4,5,7]] as b
return table(toString(a), toString(b), toString(intersection(a, b)))
```
<p tit="Result"></p>

```
| toString(a) | toString(b) | toString(intersection(a, b)) |
|-------------|-------------|------------------------------|
| [1,2,2]     | [2,4,7]     | [2]                          |
| [2,4,5]     | [4,5,7]     | [4,5]                        |
```

Example: Multiply and calculate


```uql
uncollect [[1,2,2],[2,4,5]] as a
uncollect [[2,4,7],[4,5,7]] as b
with intersection(a, b) as c
return table(toString(a), toString(b), toString(c))
```
<p tit="Result"></p>

```
| toString(a) | toString(b) | toString(c) |
|-------------|-------------|-------------|
| [1,2,2]     | [2,4,7]     | [2]         |
| [1,2,2]     | [4,5,7]     | []          |
| [2,4,5]     | [2,4,7]     | [2,4]       |
| [2,4,5]     | [4,5,7]     | [4,5]       |
```

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6165' drawio-name="draw_fd8656adf7c843908a8228941a425401.jpg"><img src="https://img.ultipa.cn/draw/draw_fd8656adf7c843908a8228941a425401.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```uql
create().node_schema("student").node_schema("course")
create().node_property(@*, "name").node_property(@student, "age", int32).node_property(@course, "credit", int32)
insert().into(@student).nodes([{_id:"S001", _uuid:1, name:"Jason", age:25}, {_id:"S002", _uuid:2, name:"Lina", age:23}, {_id:"S003", _uuid:3, name:"Eric", age:24}, {_id:"S004", _uuid:4, name:"Emma", age:26}, {_id:"S005", _uuid:5, name:"Pepe", age:24}])
insert().into(@course).nodes([{_id:"C001", _uuid:6, name:"French", credit:4}, {_id:"C002", _uuid:7, name:"Math", credit:5}])
insert().into(@default).edges([{_uuid:1, _from_uuid:1, _to_uuid:6}, {_uuid:2, _from_uuid:2, _to_uuid:6}, {_uuid:3, _from_uuid:3, _to_uuid:6}, {_uuid:4, _from_uuid:2, _to_uuid:7}, {_uuid:5, _from_uuid:3, _to_uuid:7}, {_uuid:6, _from_uuid:4, _to_uuid:7}, {_uuid:7, _from_uuid:5, _to_uuid:7}])
```

Example: Find the students that select both French and Math


```uql
khop().src({name == "French"}).depth(1) as n1
with collect(n1) as l1
khop().src({name == "Math"}).depth(1) as n2
with collect(n2) as l2
return intersection(l1, l2)
```
<p tit="Result"></p>

```
[
  {"id":"","uuid":"2","schema":"student","values":{}},
  {"id":"","uuid":"3","schema":"student","values":{}}
]
```
