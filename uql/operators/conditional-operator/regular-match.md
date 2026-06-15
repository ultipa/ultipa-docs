# Regular Match

- Expression: `<string>` =~ "`<regexp>`"
- Left operand: string
- Right operand: regular expression

## Constant

Example: judge if String "adfAWa" is composed of uncapitalized letters


```uql
return "Ultipa" =~ "^[a-z]+$"
```
<p tit="Result"></p>

```
0
```

## Function

Example: Convert 'Graph Database' to lowercase and judge whether it is composed of uncapitalized letters


```uql
return lower("Ultipa.com") =~ "^[a-z]+$"
```
<p tit="Result"></p>

```
0
```

## Alias

Example: Judge each row of an alias whether it is composed of uncapitalized letters
 

```uql
uncollect ["Ultipa.com", "grAph", "graph"] as a
return a =~ "^[a-z]+$"
```
<p tit="Result"></p>

```
0
0
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

Example: Find nodes whose email is in format xxx@xxx.com or xxx@xxx.cn 


```uql
find().nodes({email =~ "^[a-zA-Z0-9_.-]+@[a-zA-Z0-9]+\.(com|cn)$"}) as n
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
| S003  |   5   |  25   | test@gmail.com  |
```

Example: Find nodes of @professor, whose email is in format xxx@xxx.com or xxx@xxx.cn 


```uql
find().nodes({@professor.email =~ "^[a-zA-Z0-9_.-]+@[a-zA-Z0-9]+\.(com|cn)$"}) as n
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


