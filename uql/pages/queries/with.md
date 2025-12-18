# WITH

WITH performs functional operations on the alias and pass the result onto later statements. Heterologous aliases will be Cartesian multiplied.

Syntax: WITH `<expression>` as `<alias>`, `<expression>` as `<alias>`, ...
<br>
Input:
- \<expression>: Operational expression 
- \<alias>: Alias of operational result, optional

Deduplicating an alias in WITH will affect its homologous aliases.

For instance, the deduplication against <i>n2.color</i> affects its homologous alias <i>pnodes(path)</i>; the Cartesian multiplication against heterologous aliases <i>n1</i> and <i>list</i> also affects <i>color</i>, the homologous alias of <i>list</i>:

<div align=center drawio-diagram='13991' drawio-name='draw_f0b0e26d5e044e2e8f782facc11a657e.jpg'><img src="https://img.ultipa.cn/draw/draw_f0b0e26d5e044e2e8f782facc11a657e.jpg?v='1703131188590'"/></div>

```js
find().nodes() as n1 limit 2
n(3).e()[2].n(as n2) as path
with pnodes(path) as list, dedup(n2.color) as color
with n1, list
return n1, list, color
```

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6143' drawio-name="draw_bbab900d4783471e8b55ce938555bbc2.jpg"><img src="https://img.ultipa.cn/draw/draw_bbab900d4783471e8b55ce938555bbc2.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```js
create().node_schema("account").node_schema("movie").edge_schema("rate").edge_schema("wishlist")
create().node_property(@*, "name").node_property(@account, "age", int32).node_property(@movie, "year", int32).edge_property(@rate, "score", int32)
insert().into(@account).nodes([{_id:"S001", _uuid:1, name:"Pepe", age:24}, {_id:"S002", _uuid:2, name:"Lina", age:23}, {_id:"S003", _uuid:3, name:"Emma", age:26}])
insert().into(@movie).nodes([{_id:"M001", _uuid:4, name:"Léon", year:1994}, {_id:"M002", _uuid:5, name:"Avatar", year:2009}])
insert().into(@rate).edges([{_uuid:1, _from_uuid:1, _to_uuid:4, score:9}, {_uuid:2, _from_uuid:3, _to_uuid:5, score:8}])
insert().into(@wishlist).edges([{_uuid:3, _from_uuid:2, _to_uuid:4}, {_uuid:4, _from_uuid:3, _to_uuid:4}])
```


## Functional Operation

Example: Find all the nodes of @account that are youngest, return their <i>name</i>
 

```js
find().nodes({@account}) as a
with min(a.age) as minAge
find().nodes({@account.age == minAge}) as b
return b.name
```
<p tit="Result"></p> 

```bash
Lina
```
Analysis: The method of sorting all accounts into ascending <i>age</i> and return only one result might miss some results that are also the youngest.

## Cartesian Product

Example: Pair nodes of @account and @movie, find 1-step paths @account-@movie, return `null` for those pairs that do not have any path
 

```js
find().nodes({@account}) as a
find().nodes({@movie}) as b
with a, b
optional n(a).e().n(b) as p
return p{*}
```
<p tit="Result"></p> 

```bash
Pepe --@rate--> Léon
null --null-- null
Lina --@wishlist--> Léon
null --null-- null
Emma --@wishlist--> Léon
Emma --@rate--> Avatar
```

