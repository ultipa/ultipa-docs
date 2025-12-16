# ORDER BY

ORDER BY adjusts the order of rows in the alias.

Syntax: ORDER BY `<expression>` `<string>`, `<expression>` `<string>`, ...
<br>
Input:
- \<expression>: Sorting criterion; multiple criteria must be homologous and are operated from left to right
- \<alias>: Fashion of sorting, either <i>ASC</i> or <i>DESC</i> (case insensitive), or <i>ASC</i> when omitted

For instance, adjusts the order of one-step paths  <i>path</i>, first into descending radius of terminal-nodes <i>n</i>, then into ascending ID of <i>n</i> if <i>n</i> shares the same radius.

<div align=center drawio-diagram='13985' drawio-name='draw_67147cadf7d743cd8935831ee14838fd.jpg'><img src="https://img.ultipa.cn/draw/draw_67147cadf7d743cd8935831ee14838fd.jpg?v='1703130926088'"/></div>

```js
n([4, 2]).e().n(as n) as path
order by n.radius desc, n
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

## Grouping and Ordering

Example: Find 1-step paths @course-@student, group by course and calculate number of students in each group, and order the results into descening count

<p run-tag="true" graph="uql_manual_graph_8"></p> 

```js
n({@course} as a).e().n({@student})
group by a
with count(a) as b
order by b desc 
return table(a.name, b)
```

<p tit="Result"></p> 

```bash
| a.name | b |
|--------|---|
| Math   | 4 |
| French | 3 |
```

## Multi-level Ordering

Example: Find 1-step paths @course-@student, order the results into ascending <i>credit</i> of course, then into descending <i>age</i> of student
<p run-tag="true" graph="uql_manual_graph_8"></p> 

```js
n({@course} as a).e().n({@student} as b) as p
order by a.credit, b.age desc 
return p{*}
```

<p tit="Result"></p> 

```bash
French <---- Jason
French <---- Eric
French <---- Lina
Math <---- Emma
Math <---- Eric
Math <---- Pepe
Math <---- Lina
```


