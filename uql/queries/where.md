# WHERE

WHERE keeps the rows in the data stream that meet the conditions, and discards those that do not meet the conditions. 

Syntax 1: WHERE `<condition>`
<br>
Syntax 2: WHERE `<query>` (Under development)
<br>
Input
- \<condition>: Judgement condition, rows that are judged as TRUE will be kept
- \<query>: Query statement, rows that have return will be kept

> The statement right following WHERE clause should call the alias (or its homologous alias) that enters WHERE clause, otherwise this statement will not be valid.

For instance, compare <i>n1</i> and <i>n2</i> that are heterologous, return them if they have the same color:

<div align=center drawio-diagram='13989' drawio-name='draw_3b5d84f665c44041ba9dc1c1ab39a9ce.jpg'><img src="https://img.ultipa.cn/draw/draw_3b5d84f665c44041ba9dc1c1ab39a9ce.jpg?v='1703131062595'"/></div>

```uql
find().nodes({shape == "square"}) as n1
find().nodes({shape == "round"}) as n2
where n1.color == n2.color
return n1, n2
```

## WHERE `<condition>`

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


Example: Find 1-step paths @course-@student, if the <i>credit</i> of course is 4, or the <i>age</i> of student is 24, then return the path
 

```uql
n({@course} as a).e().n({@student} as b) as p
where a.credit == 4 || b.age == 24
return p{*}
```
<p tit="Result"></p> 

```
French <---- Jason
French <---- Lina
French <---- Eric
Math <---- Pepe
Math <---- Eric
```


## WHERE `<query>` (Under Development)

Example: find an intermediate card with alias 'agent' that satisfies conditions as shown in the image below: Card CA002 transfers money to Card CA001 via agent; agent is a neighbor to Card CA003 within 2 hops

<div align=center drawio-diagram='2853' drawio-name='draw_03126f9d4de842cea8862f837f35904b.jpg'><img src="https://img.ultipa.cn/draw/draw_03126f9d4de842cea8862f837f35904b.jpg?v='1660009744934'"/></div>

```uql
n({_id == "CA002"}).re().n({@card} as agent).re().n({_id == "CA001"})
where n(agent).e()[*:2].n({_id == "CA003"})
return agent{*}
```

Analysis: WHERE further filters data columns "agent": it judges if the shortest paths from "agent" to Card CA003 exist, if true, then it passes "agent" to later "return" 

The example above can be put in a subgraph template as shown below:
```uql
subgraph([
  n({_id == "CA002"}).re().n({@card} as agent).re().n({_id == "CA001"}),
  n(agent).e()[*:2].n({_id == "CA003"})
])
return agent{*}
```

