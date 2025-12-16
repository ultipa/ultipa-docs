# Constant

Example: Judge whether "2020-01-04" is greater than or equal to "2020-04-27"
<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
return "2020-01-04" >= "2020-04-27"
```
<p tit="Result"></p>

```bash
0
```

## Function

Example: Judge whether PI is greater than or equal to 3
<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
return pi() >= 3
```
<p tit="Result"></p>

```bash
1
```

## Alias

Example: Judge each row of an alias whether it is greater than or equal to 2
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
uncollect [1,2,3,2,2] as a
return a >= 2
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

Example: Find nodes whose age is greater than or equal to 27
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().nodes({age >= 27}) as n
return n{*} 
```
<p tit="Result"></p>

```bash
|--------------- @professor --------------|
|  _id  | _uuid |  age  |       email     |
|-------|-------|-------|-----------------|
| P001  |   1   |  53   | test@yahoo.cn   |
| P002  |   2   |  27   | test@ultipa.com |

|---------------- @student ---------------|
|  _id  | _uuid |  age  |       email     |
|-------|-------|-------|-----------------|
| S001  |   3   |  27   | test@yeah.net   |
```

Example: Find nodes of @professor, whose age is greater than or equal to 27
<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().nodes({@professor.age >= 27}) as n
return n{*} 
```
<p tit="Result"></p>

```bash
|--------------- @professor --------------|
|  _id  | _uuid |  age  |       email     |
|-------|-------|-------|-----------------|
| P001  |   1   |  53   | test@yahoo.cn   |
| P002  |   2   |  27   | test@ultipa.com |
```


## Between

- Expression: `<value>` <> [`<lower>`, `<upper>`]
- Operand: string, number, time

