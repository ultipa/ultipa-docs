# Between or Equal

- Expression: `<value>` <=> [`<lower>`, `<upper>`]
- Operand: string, number, time

## Constant

Example: Judge whether "abc" is in the closed interval ["123", "abc"] 
<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
return "abc" <=> ["123", "abc"]
```
<p tit="Result"></p>

```bash
1
```

## Function

Example: Judge whether PI is in the closed interval [3.14, 3.15] 
<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
with [3.14, 3.15] as a
return pi() <=> [a[0], a[1]]
```
<p tit="Result"></p>

```bash
1
```

## Alias

Example: Judge each row of an alias whether it is in the closed interval [2, 4]
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
uncollect [1,2,3,2,2] as a
return a <=> [2, 4]
```
<p tit="Result"></p>

```bash
0
1
1
1
1
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

Example: Find nodes whose age is in the closed interval [25, 35]
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().nodes({age <=> [25, 35]}) as n
return n{*} 
```
<p tit="Result"></p>

```bash
|--------------- @professor --------------|
|  _id  | _uuid |  age  |       email     |
|-------|-------|-------|-----------------|
| P002  |   2   |  27   | test@ultipa.com |

|---------------- @student ---------------|
|  _id  | _uuid |  age  |       email     |
|-------|-------|-------|-----------------|
| S001  |   3   |  27   | test@yeah.net   |
| S003  |   5   |  25   | test@gmail.com  |
```

Example: Find nodes of @professor, whose age is in the closed interval [25, 35]
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().nodes({@professor.age <=> [25, 35]}) as n
return n{*} 
```
<p tit="Result"></p>

```bash
|--------------- @professor --------------|
|  _id  | _uuid |  age  |       email     |
|-------|-------|-------|-----------------|
| P002  |   2   |  27   | test@ultipa.com |
```