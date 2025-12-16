# Belong to

- Expression: `<value>` IN `<list>`
- Left operand: string, number, time, list, point, NODE, EDGE
- Right operand: list

## Constant

Example: Judge whether 2 belongs to [1,2,3]
<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
return 2 in [1,2,3]
```
<p tit="Result"></p>

```bash
1
```

## Function

Example: Judge whether 2 belongs to the intersection of [1,2,3] and [3,2,5]
<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
return 2 in intersection([1,2,3], [3,2,5])
```
<p tit="Result"></p>

```bash
1
```

## Alias

Example: Judge each row of an alias whether it belongs to [0,1,3]
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
uncollect [1,2,3,2,2] as a
return a in [0,1,3]
```
<p tit="Result"></p>

```bash
1
0
1
0
0
```

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

## Property

Example: Find nodes whose age belongs to [20,25,30,35]
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().nodes({age in [20,25,30,35]}) as n
return n{*} 
```
<p tit="Result"></p>

```bash
|---------------- @student ---------------|
|  _id  | _uuid |  age  |       email     |
|-------|-------|-------|-----------------|
| S002  |   4   |  20   | test@w3.org     |
| S003  |   5   |  25   | test@gmail.com  |
```

Example: Find nodes of @professor, whose age belongs to [20,25,30,35]
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().nodes({@professor.age in [20,25,30,35]}) as n
return n{*} 
```
<p tit="Result"></p>

```bash
No return data
```

## \_uuid (Abbreviated)

When a filter only judges whether the `_uuid` of the current node/edge belongs to a list of integers, the filter can be abbreviated as below：

| Standard Form	| <div table-width="20">Abbreviated Form</div>	| Specification	|
|-|-|-|
| ({ \_uuid in [1,2,3]})	| ([1,2,3])	| |
| ({ \_uuid in `intList`})	| (`intList`)	| `intList` is the alias of an interger list |
| ({ \_uuid in [`node1`.\_uuid, `node2`.\_uuid, ...]})	| (`nodeList`)	| `nodeList` is the alias of [`node1`, `node2`, ...] 	|
| ({ \_uuid in [`edge1`.\_uuid, `edge2`.\_uuid, ...]})	| (`edgeList`)	| `edgeList` is the alias of [`edge1`, `edge2`, ...] 	|



Example: Find node whose `_uuid` belongs to [2,3,5]
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().nodes([2,3,5]) as n
return n{*} 
```
<p tit="Result"></p>

```bash
|---------------- @student ---------------|
|  _id  | _uuid |  age  |       email     |
|-------|-------|-------|-----------------|
| S001  |   3   |  27   | test@yeah.net   |
| S002  |   4   |  20   | test@w3.org     |
| S003  |   5   |  25   | test@gmail.com  |
```
