# Not Belong to

- Expression: `<value>` NIN `<list>`
- Left operand: string, number, time, list, point, NODE, EDGE
- Right operand: list

## Constant

Example: Judge whether 2 does not belong to [1,2,3]
 

```uql
return 2 nin [1,2,3]
```
<p tit="Result"></p>

```
0
```

## Function

Example: Judge whether 2 does not belong to the intersection of [1,2,3] and [3,2,5]


```uql
return 2 nin intersection([1,2,3], [3,2,5])
```
<p tit="Result"></p>

```
0
```

## Alias

Example: Judge each row of an alias whether it does not belong to [0,1,3]
 

```uql
uncollect [1,2,3,2,2] as a
return a nin [0,1,3]
```
<p tit="Result"></p>

```
0
1
0
1
1
```

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6069' drawio-name="draw_060a6c5dfe884a59bce022892f28fa5f.jpg"><img src="https://img.ultipa.cn/draw/draw_060a6c5dfe884a59bce022892f28fa5f.jpg"/></div>
Run below UQLs one by one in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```uql
create().node_schema("professor").node_schema("student")
create().node_property(@*, "age", int32).node_property(@*, "email", string)
insert().into(@professor).nodes([{_id:"P001",_uuid:1,age:53,email:"test@yahoo.cn"},{_id:"P002",_uuid:2,age:27,email:"test@ultipa.com"}])
insert().into(@student).nodes([{_id:"S001",_uuid:3,age:27,email:"test@yeah.net"},{_id:"S002",_uuid:4,age:20,email:"test@w3.org"},{_id:"S003",_uuid:5,age:25,email:"test@gmail.com"}])
```

## Property

Example: Find nodes whose age does not belong to [20,25,30,35]
 

```uql
find().nodes({age nin [20,25,30,35]}) as n
return n{*} 
```
<p tit="Result"></p>

```
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

Example: Find nodes of @professor, whose age does not belong to [20,25,30,35]
 

```uql
find().nodes({@professor.age nin [20,25,30,35]}) as n
return n{*} 
```
<p tit="Result"></p>

```
|--------------- @professor --------------|
|  _id  | _uuid |  age  |       email     |
|-------|-------|-------|-----------------|
| P001  |   1   |  53   | test@yahoo.cn   |
| P002  |   2   |  27   | test@ultipa.com |
```


