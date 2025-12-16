# LIMIT

LIMIT keeps the first N rows in the alias, and discards the rest of rows.

Syntax: LIMIT `<number>` 
<br>
Input: 
- \<number>: The number of rows to keep, or keep all rows when set to -1

For instance, keep the first 2 rows of <i>path</i>:

<div align=center drawio-diagram='13987' drawio-name='draw_11b8c4f5bc3c4bffb90d3864be17d42d.jpg'><img src="https://img.ultipa.cn/draw/draw_11b8c4f5bc3c4bffb90d3864be17d42d.jpg?v='1703130993772'"/></div>

```js
find().nodes([1, 5]) as nodes
n(nodes).e()[:2].n() as path
limit 2
return path
```

Please note the difference between clause LIMIT and chain command parameter `.limit()`, that `.limit()` keeps the first 2 rows of each subquery of <i>path</i>, not the first 2 rows of the whole <i>path</i>:

<div align=center drawio-diagram='13988' drawio-name='draw_75a746e64024490a83c6f00159c4f8e6.jpg'><img src="https://img.ultipa.cn/draw/draw_75a746e64024490a83c6f00159c4f8e6.jpg?v='1703131021447'"/></div>

```js
find().nodes([1, 5]) as nodes
n(nodes).e()[:2].n().limit(2) as path
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

Example: Find 3 nodes of @student that are eldest
<p run-tag="true" graph="uql_manual_graph_8"></p> 

```js
find().nodes({@student}) as n
order by n.age desc
limit 3
return n.name
```
<p tit="Result"></p> 

```bash
Emma
Jason
Pepe
```


