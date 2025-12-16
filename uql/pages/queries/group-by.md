# GROUP BY

GROUP BY divides the rows in the alias into groups, for each group keeps one row and discard the rest of rows; it is always used in combination with aggregation and ORDER BY operations.

Syntax: GROUP BY `<expression>` as `<alias>`, `<expression>` as `<alias>`, ...
<br>
Input:
- \<expression>: Grouping criterion; multiple criteria must be homologous and are operated from left to right
- \<alias>: Alias of grouping criterion, optional

For instance, apply mult-level grouping to <i>path</i>, first by the shape of initial-nodes <i>n1</i>, then by the colour of terminal-nodes <i>n2</i> in each group; count the number of paths in each group and return both <i>path</i> and the count.

<div align=center drawio-diagram='13984' drawio-name='draw_7df57b2e0a9e46b396eca05bd512aa3d.jpg'><img src="https://img.ultipa.cn/draw/draw_7df57b2e0a9e46b396eca05bd512aa3d.jpg?v='1703130884165'"/></div>

```js
n(as n1).re().n(as n2) as path
group by n1.shape, n2.color
return path, count(path)
```

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6135' drawio-name="draw_f8ef91a691c64099bc29dc89ec48b1af.jpg"><img src="https://img.ultipa.cn/draw/draw_f8ef91a691c64099bc29dc89ec48b1af.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```js
create().node_schema("country").node_schema("movie").node_schema("director").edge_schema("filmedIn").edge_schema("direct")
create().node_property(@*, "name")
insert().into(@country).nodes([{_id:"C001", _uuid:1, name:"France"}, {_id:"C002", _uuid:2, name:"USA"}])
insert().into(@movie).nodes([{_id:"M001", _uuid:3, name:"Léon"}, {_id:"M002", _uuid:4, name:"The Terminator"}, {_id:"M003", _uuid:5, name:"Avatar"}])
insert().into(@director).nodes([{_id:"D001", _uuid:6, name:"Luc Besson"}, {_id:"D002", _uuid:7, name:"James Cameron"}])
insert().into(@filmedIn).edges([{_uuid:1, _from_uuid:3, _to_uuid:1}, {_uuid:2, _from_uuid:4, _to_uuid:1}, {_uuid:3, _from_uuid:3, _to_uuid:2}, {_uuid:4, _from_uuid:4, _to_uuid:2}, {_uuid:5, _from_uuid:5, _to_uuid:2}])
insert().into(@direct).edges([{_uuid:6, _from_uuid:6, _to_uuid:3}, {_uuid:7, _from_uuid:7, _to_uuid:4}, {_uuid:8, _from_uuid:7, _to_uuid:5}])
```

## Grouping and Aggregating

Example: Find 2-step paths @country-@movie-@director, group by director and count the number of paths in each group
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
n({@country}).e().n({@movie}).e().n({@director} as n)
group by n
return table(n.name, count(n))
```
<p tit="Result"></p> 

```bash
|     n.name    | count(n) |
|---------------|----------|
| Luc Besson    | 2        |
| James Cameron | 3        |
```
Analysis: An aggregation is executed within each group only if the aggregation funciton is composed right after the GROUP BY clause. 

## Multi-level Grouping

Example: Find 2-step paths @country-@movie-@director, group by country and then by director, count the number of paths in each group
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
n({@country} as a).e().n({@movie}).e().n({@director} as b)
group by a, b
return table(a.name, b.name, count(a))
```
<p tit="Result"></p> 

```bash
| a.name |     b.name    | count(a) |
|--------|---------------|----------|
| France | Luc Besson    | 1        |
| France | James Cameron | 1        |
| USA    | Luc Besson    | 1        |
| USA    | James Cameron | 2        |
```
