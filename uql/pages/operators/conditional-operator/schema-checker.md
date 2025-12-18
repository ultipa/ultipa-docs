# Schema Checker

- Expression: @`<schema>`
- Operand: string constant

> When combined with property filtering, i.e., when `@<schema> && <property> == 123` is shortened as `@<schema>.<property> == 123`, the `<property>` cannot be <i>_id</i> or <i>_uuid</i>
  
> The `@<schema>` and `@<schema>.<property>` that appear in an Ultipa filter find the metadata of a specific schema and/or property, which is different than the `@<schema>` and `@<schema>.<property>` that appear in some other chain statements that find a specific schema and/or property in a graph model. Please read <i>GraphSet | Schema | Property</i> for more information.

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

## Schema

Example: Find nodes of @student 
 

```js
find().nodes({@student}) as n
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
Analysis: This filter is equivalent to `{this.@ == "student"}`

## Schema & Property

Example: Find nodes of @student, whose age is 27
 

```js
find().nodes({@student.age == 27}) as n
return n{*} 
```
<p tit="Result"></p>

```bash
|---------------- @student ---------------|
|  _id  | _uuid |  age  |       email     |
|-------|-------|-------|-----------------|
| S001  |   3   |  27   | test@yeah.net   |
```
Analysis: This filter is equivalent to `{@student && age == 27}`.