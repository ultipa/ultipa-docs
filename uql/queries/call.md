# CALL 

CALL executes operations against the query result of each subquery, NOT all the result of a query command. It wraps query commands and the operations in curly braces `{}`, passes in the alias that triggers each subquery using a WITH clause and passes out the result of each subquery using a RETURN clause. 

Syntax:
<br>
CALL { <br>
&emsp; WITH `<alias_In>`, `<alias_In>`, ...<br>
&emsp; ...<br>
&emsp; RETURN `<expression>` as `<alias_Out>`, `<expression>` as `<alias_Out>`, ...<br>
}
Input:
- \<alias_In>: The alias that triggers the subquery
- \<expression>: The return value of the subquery
- \<alias_Out>: The alias of return value of the subquery, optional when \<expression> is alias


For instance, skip the first row of each subquery result <i>p</i>: 

<div align=center drawio-diagram='13994' drawio-name='draw_a3d1441245d64a9c95705725ff28a33a.jpg'><img src="https://img.ultipa.cn/draw/draw_a3d1441245d64a9c95705725ff28a33a.jpg?v='1703131287436'"/></div>

```uql
find().nodes([1, 5]) as nodes
call {
  with nodes
  n(nodes).e()[:2].n() as p
  skip 1
  return p as path
}
return path
```

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6135' drawio-name="draw_f8ef91a691c64099bc29dc89ec48b1af.jpg"><img src="https://img.ultipa.cn/draw/draw_f8ef91a691c64099bc29dc89ec48b1af.jpg?v=''"/></div>
Run below UQLs one by one to in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```uql
create().node_schema("country").node_schema("movie").node_schema("director").edge_schema("filmedIn").edge_schema("direct")
create().node_property(@*, "name")
insert().into(@country).nodes([{_id:"C001", _uuid:1, name:"France"}, {_id:"C002", _uuid:2, name:"USA"}])
insert().into(@movie).nodes([{_id:"M001", _uuid:3, name:"Léon"}, {_id:"M002", _uuid:4, name:"The Terminator"}, {_id:"M003", _uuid:5, name:"Avatar"}])
insert().into(@director).nodes([{_id:"D001", _uuid:6, name:"Luc Besson"}, {_id:"D002", _uuid:7, name:"James Cameron"}])
insert().into(@filmedIn).edges([{_uuid:1, _from_uuid:3, _to_uuid:1}, {_uuid:2, _from_uuid:4, _to_uuid:1}, {_uuid:3, _from_uuid:3, _to_uuid:2}, {_uuid:4, _from_uuid:4, _to_uuid:2}, {_uuid:5, _from_uuid:5, _to_uuid:2}])
insert().into(@direct).edges([{_uuid:6, _from_uuid:6, _to_uuid:3}, {_uuid:7, _from_uuid:7, _to_uuid:4}, {_uuid:8, _from_uuid:7, _to_uuid:5}])
```

## Common Usage

Example: Not using GROUP BY, find how many movies are filmed in each country
 

```uql
find().nodes({@country}) as nodes
call { 
  with nodes
  n(nodes).e().n({@movie} as n)
  return count(n) as number
}
return table(nodes.name, number)
```
<p tit="Result"></p> 

```
| nodes.name | number |
|------------|--------|
| France     | 2      |
| USA        | 3      |
```


