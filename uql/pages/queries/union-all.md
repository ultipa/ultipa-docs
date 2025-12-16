# UNION ALL 

UNION ALL splices return values that have same alias from two RETURNs head-to-tail and unite the data of each return value in the same row as an integrated row. It has an operational efficiency higher than that of UNION since no deduplication is executed against the united rows.

Syntax:
 <br>
... RETURN `<expression1_A>` as `<alias_A>`, `<expression1_B>` as `<alias_B>`, ...
<br>UNION ALL<br>
... RETURN `<expression2_A>` as `<alias_A>`, `<expression2_B>` as `<alias_B>`, ...
<br>
Input:
- \<expression1>: Return values of the 1st RETURN
- \<expression2>: Return values of the 2nd RETURN, should have the same number of return values as the 1st RETURN and the same data structure of each same alias
- \<alias>: The alias of return value (different order allowed) 


For instance, splice heterologous return values <i>a</i> and <i>b</i>:

<div align=center drawio-diagram='2781' drawio-name="draw_329de20bec2f4b6e97214f5d3334abeb.jpg"><img src="https://img.ultipa.cn/draw/draw_329de20bec2f4b6e97214f5d3334abeb.jpg?v='1681108084497'"/></div>

```js
uncollect [1,2,3]) as a
uncollect [3,4,5]) as b
return a, b
union all
uncollect [1,2]) as a
uncollect [3,5]) as b
return a, b
```

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6165' drawio-name="draw_fd8656adf7c843908a8228941a425401.jpg"><img src="https://img.ultipa.cn/draw/draw_fd8656adf7c843908a8228941a425401.jpg?v=''"/></div>
Run below UQLs one by one to in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```js
create().node_schema("student").node_schema("course")
create().node_property(@*, "name").node_property(@student, "age", int32).node_property(@course, "credit", int32)
insert().into(@student).nodes([{_id:"S001", _uuid:1, name:"Jason", age:25}, {_id:"S002", _uuid:2, name:"Lina", age:23}, {_id:"S003", _uuid:3, name:"Eric", age:24}, {_id:"S004", _uuid:4, name:"Emma", age:26}, {_id:"S005", _uuid:5, name:"Pepe", age:24}])
insert().into(@course).nodes([{_id:"C001", _uuid:6, name:"French", credit:4}, {_id:"C002", _uuid:7, name:"Math", credit:5}])
insert().into(@default).edges([{_uuid:1, _from_uuid:1, _to_uuid:6}, {_uuid:2, _from_uuid:2, _to_uuid:6}, {_uuid:3, _from_uuid:3, _to_uuid:6}, {_uuid:4, _from_uuid:2, _to_uuid:7}, {_uuid:5, _from_uuid:3, _to_uuid:7}, {_uuid:6, _from_uuid:4, _to_uuid:7}, {_uuid:7, _from_uuid:5, _to_uuid:7}])
```


## Common Usage

Example: Find students no elder than 24-year-old that select French, also find students no younger than 24-year-old that select Math, return these students
<p run-tag="true" graph="uql_manual_graph_8"></p> 

```js
n({@course.name == "French"}).e().n({@student.age <= 24} as n) return n.name
union all
n({@course.name == "Math"}).e().n({@student.age >= 24} as n) return n.name
```
<p tit="Result"></p> 

```bash
Lina
Eric
Pepe
Eric
Emma
```
