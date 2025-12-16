# reduce()

Function `reduce()` iterates a designated calculation against each elements in a <i>list</i> one after another. Developers need to define the calculation via an expression, firstly execute the calculation based on an initial value and the 1st element in the <i>list</i>, then re-execute the calculation based on the calculation result and the 2nd element in the <i>list</i>, ... until all elements in the <i>list</i> are traversed. 

> The iteration pattern of this function is similar to the 'for' in most programming languages, just that the index of each iteration is not exposed to developers.

Syntax：
<p tit= "Syntax"></p> 

```js
reduce(<result> = <initial_value>, <element> in <list> | <expression>) 
```

- \<result> denotes the variable name of the calculation result
- \<initial_value> denotes the initial value
- \<element> denotes the variable name of element in the <i>list</i>
- \<list> denotes the alias of the <i>list</i>
- \<expression> denotes the calculation


## Common Usage

Example: Calculate the sum of all numbers in [1,2,3]
<p run-tag="true" graph="uql_manual_graph_3"></p>

```js
with [1,2,3] as list
return reduce(sum = 0, element in list | sum + element) as mySum
```
<p tit="Result"></p>

```bash
6
```

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6094' drawio-name="draw_7d6a28dbf9f54170ac9537f312b2e3d8.jpg"><img src="https://img.ultipa.cn/draw/draw_7d6a28dbf9f54170ac9537f312b2e3d8.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```js
create().node_schema("firm").node_schema("human").edge_schema("hold")
create().edge_property(@hold, "portion", double)
insert().into(@firm).nodes([{_id:"F001", _uuid:1}, {_id:"F002", _uuid:2}])
insert().into(@human).nodes([{_id:"H001", _uuid:3}, {_id:"H002", _uuid:4}])
insert().into(@hold).edges([{_uuid:1, _from_uuid:3, _to_uuid:1, portion:0.3}, {_uuid:2, _from_uuid:2, _to_uuid:1, portion:0.7}, {_uuid:3, _from_uuid:3, _to_uuid:2, portion:0.4}, {_uuid:4, _from_uuid:4, _to_uuid:2, portion:0.6}])
```

Example: Calculate the share of each UBO of F001
<p run-tag="true" graph="uql_manual_graph_3"></p>

```js
n({_id == "F001"}).le()[:5].n({@human} as UBO) as p
with pedges(p) as edgeList
call{
  with edgeList
  uncollect edgeList as edges
  with collect(edges.portion) as portionList
  return reduce(init = 1, element in portionList | init * element) as share
}
group by UBO
return table(UBO._id, sum(share))
```
<p tit="Result"></p>

```bash
| UBO._id | sum(share) |
|---------|------------|
| H001    | 0.58       |
| H002    | 0.42       |
```

