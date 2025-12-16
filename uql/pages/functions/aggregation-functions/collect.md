# collect()

Function `collect()` arranges each row of an alias into a list (ignoring the rows that are <i>null</i>), in their original order, and returns this list. Only one row from the alias will be kept after this function is called, and all the rest rows will be abandoned. 

Arguments：
- Alias \<any>, object value of each NODE/EDGE/PATH in the alias, and list value of each row in the TABLE alias

Returns：
- List \<list>


Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6069' drawio-name="draw_060a6c5dfe884a59bce022892f28fa5f.jpg"><img src="https://img.ultipa.cn/draw/draw_060a6c5dfe884a59bce022892f28fa5f.jpg"/></div>
Run below UQLs one by one in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```js
create().node_schema("professor").node_schema("student")
create().node_property(@*, "age", int32).node_property(@*, "email", string)
insert().into(@professor).nodes([{_id:"P001",_uuid:1,age:53,email:"test@yahoo.cn"},{_id:"P002",_uuid:2,age:27,email:"test@ultipa.com"}])
insert().into(@student).nodes([{_id:"S001",_uuid:3,age:27,email:"test@yeah.net"},{_id:"S002",_uuid:4,age:20,email:"test@w3.org"},{_id:"S003",_uuid:5,age:25,email:"test@gmail.com"}])
```

## Common Usage

Example: Return the list of <i>age</i> of all nodes in the graph
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().nodes() as n
return collect(n.age)
```
<p tit="Result"></p>

```bash
[53,27,20,27,25]
```

Example: Return the list of nodes of <i>@professor</i> in the graph
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().nodes({@professor}) as n
return collect(n)
```
<p tit="Result"></p>

```bash
[
  {"id":"P001","uuid":"1","schema":"professor","values":{"age":"53","email":"test@yahoo.cn"}},
  {"id":"P002","uuid":"2","schema":"professor","values":{"age":"27","email":"test@ultipa.com"}}
]
```
