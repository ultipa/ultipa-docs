# SKIP

SKIP discards the first N rows in the alias.

Syntax: SKIP `<N>` 
<br>
Input:
- \<N> The number of rows to be discarded

For instance, discard the first two rows of <i>path</i>:

<div align=center drawio-diagram='13986' drawio-name='draw_4c91c9a34fa442719545ba8af111be0f.jpg'><img src="https://img.ultipa.cn/draw/draw_4c91c9a34fa442719545ba8af111be0f.jpg?v='1703130961618'"/></div>

```js
n([1, 5]).e()[:2].n() as path
skip 2
return path
```

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6165' drawio-name="draw_fd8656adf7c843908a8228941a425401.jpg"><img src="https://img.ultipa.cn/draw/draw_fd8656adf7c843908a8228941a425401.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```js
create().node_schema("student").node_schema("course")
create().node_property(@*, "name").node_property(@student, "age", int32).node_property(@course, "credit", int32)
insert().into(@student).nodes([{_id:"S001", _uuid:1, name:"Jason", age:25}, {_id:"S002", _uuid:2, name:"Lina", age:23}, {_id:"S003", _uuid:3, name:"Eric", age:24}, {_id:"S004", _uuid:4, name:"Emma", age:26}, {_id:"S005", _uuid:5, name:"Pepe", age:24}])
insert().into(@course).nodes([{_id:"C001", _uuid:6, name:"French", credit:4}, {_id:"C002", _uuid:7, name:"Math", credit:5}])
insert().into(@default).edges([{_uuid:1, _from_uuid:1, _to_uuid:6}, {_uuid:2, _from_uuid:2, _to_uuid:6}, {_uuid:3, _from_uuid:3, _to_uuid:6}, {_uuid:4, _from_uuid:2, _to_uuid:7}, {_uuid:5, _from_uuid:3, _to_uuid:7}, {_uuid:6, _from_uuid:4, _to_uuid:7}, {_uuid:7, _from_uuid:5, _to_uuid:7}])
```

## Common Usage

Example: Find nodes of @student, discard two youngest students and return <i>name</i>
 

```js
find().nodes({@student}) as n
order by n.age 
skip 2
return n.name
```
<p tit="Result"></p> 

```bash
Eric
Jason
Emma
```


