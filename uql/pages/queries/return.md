# RETURN

RETURN performs functional operations on the alias, and assembles multiple <i>return values</i> to send back to client end. Return values that are heterologous will NOT be trimmed.

Syntax: RETURN `<expression>` as `<alias>`, `<expression>` as `<alias>`, ...
<br>
Input:
- \<expression>: Return value
- \<alias>: Alias of return value, optional

RETURN clause is usually the last statement of a UQL, but can also be followed by ORDER BY, LIMIT or SKIP. Deduplicating an alias in RETURN clause will not affect its homologous aliases.

For instance, assemble 3 return values, of which <i>n1</i> is heterologous with the other two; the deduplication against <i>n2.color</i> does NOT affect <i>pnodes(path)</i>, which is homologous with <i>n2.color</i>:

<div align=center drawio-diagram='13990' drawio-name='draw_f847d00a55324b3db604a6b5a2f8b07e.jpg'><img src="https://img.ultipa.cn/draw/draw_f847d00a55324b3db604a6b5a2f8b07e.jpg?v='1703131131890'"/></div>

```js
find().nodes() as n1 limit 5
n(3).e()[2].n(as n2) as path
return n1, pnodes(path), dedup(n2.color)
```

> For information on how to designate properties to be carried by NODE, EDGE, or PATH in RETURN clause, please refer to Chapter <i>Query</i> - <i>Alias System</i>.


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

## Return NODE

Example: Carry all properties
<p run-tag="true" graph="uql_manual_graph_10"></p> 

```js
find().nodes({@account}) as n
return n{*} 
```
<p tit="Result"></p> 

```bash
|-------- @account ---------|
| _id  | _uuid | name | age |
|------|-------|------|-----|
| S001 | 1     | Pepe | 24  |
| S002 | 2     | Lina | 23  |
| S003 | 3     | Emma | 26  |
```

Example: Carry some custom properties
<p run-tag="true" graph="uql_manual_graph_10"></p> 

```js
find().nodes() as n
return n{name, year} 
```
<p tit="Result"></p> 

```bash
|------ @account -----|
| _id  | _uuid | name |
|------|-------|------|
| S001 | 1     | Pepe |
| S002 | 2     | Lina |
| S003 | 3     | Emma |

|----------- @movie -----------|
| _id  | _uuid |  name  | year |
|------|-------|--------|------|
| M001 | 4     | Léon   | 1994 |
| M002 | 5     | Avatar | 2009 |
```
Analysis: NODE only carries the properties that it has.

Example: Carry only system properties
<p run-tag="true" graph="uql_manual_graph_10"></p> 

```js
find().nodes({@movie}) as n
return n 
```
<p tit="Result"></p> 

```bash
|--- @movie ---|
| _id  | _uuid |
|------|-------|
| M001 | 4     |
| M002 | 5     |
```


## Return EDGE

Example: Carry all properties
<p run-tag="true" graph="uql_manual_graph_10"></p> 

```js
find().edges({@rate}) as e
return e{*} 
```
<p tit="Result"></p> 

```bash
|------------------------ @rate -----------------------|
| _uuid | _from | _to  | _from_uuid | _to_uuid | score |
|-------|-------|------|------------|----------|-------|
|   1   | S001  | M001 | 1          | 4        | 9     |
|   2   | S003  | M002 | 3          | 5        | 8     |
```

Example: Carry only system properties
<p run-tag="true" graph="uql_manual_graph_10"></p> 

```js
find().edges() as e
return e 
```
<p tit="Result"></p> 

```bash
|-------------------- @rate -------------------|
| _uuid | _from | _to  | _from_uuid | _to_uuid |
|-------|-------|------|------------|----------|
|   1   | S001  | M001 | 1          | 4        |
|   2   | S003  | M002 | 3          | 5        |

|------------------ @wishlist -----------------|
| _uuid | _from | _to  | _from_uuid | _to_uuid |
|-------|-------|------|------------|----------|
|   3   | S002  | M001 | 2          | 4        |
|   4   | S003  | M001 | 3          | 4        |
```

## Return PATH 

Example: Carry some custom properties
<p run-tag="true" graph="uql_manual_graph_10"></p> 

```js
n({@account}).e({@rate}).n({@movie}) as p
return p{name}{*}
```
<p tit="Result"></p> 

```bash
[
  {
    "nodes":[
      {"id":"S001","uuid":"1","schema":"account","values":{"name":"Pepe"}},
      {"id":"M001","uuid":"4","schema":"movie","values":{"name":"Léon"}}
    ],
    "edges":[
      {"uuid":"1","from":"S001","to":"M001","from_uuid":"1","to_uuid":"4","schema":"rate","values":{"score":"9"}}
    ],
    "length":1
  },
  {
    "nodes":[
      {"id":"S003","uuid":"3","schema":"account","values":{"name":"Emma"}},
      {"id":"M002","uuid":"5","schema":"movie","values":{"name":"Avatar"}}
    ],
    "edges":[
      {"uuid":"2","from":"S003","to":"M002","from_uuid":"3","to_uuid":"5","schema":"rate","values":{"score":"8"}}
    ],
    "length":1
  }
]
```

Example: Carry only system properties
<p run-tag="true" graph="uql_manual_graph_10"></p> 

```js
n({@movie}).e({@rate}).n({@account}).e({@wishlist}).n({@movie}) as p
return p
```
<p tit="Result"></p> 

```bash
[
  {
    "nodes":[
      {"id":"M002","uuid":"5","schema":"movie","values":{}},
      {"id":"S003","uuid":"3","schema":"account","values":{}},
      {"id":"M001","uuid":"4","schema":"movie","values":{}}
    ],
    "edges":[
      {"uuid":"2","from":"S003","to":"M002","from_uuid":"3","to_uuid":"5","schema":"rate","values":{}},
      {"uuid":"4","from":"S003","to":"M001","from_uuid":"3","to_uuid":"4","schema":"wishlist","values":{}}
    ],
    "length":2
  }
]
```

## Return TABLE

Example: Find 1-step path @account-@movie, assemble the <i>name</i> of accounts and movies into a table
<p run-tag="true" graph="uql_manual_graph_10"></p> 

```js
n({@account} as a).e({@wishlist}).n({@movie} as b)
return table(a.name, b.name)
```
<p tit="Result"></p> 

```bash
| a.name | b.name |
|--------|--------|
| Lina   | Léon   | 
| Emma   | Léon   | 
```

## Return ATTR - Atomic

Example: Return custom properties of nodes independently
<p run-tag="true" graph="uql_manual_graph_10"></p> 

```js
find().nodes() as n
return n.name, n.age, n.year 
```
<p tit="Result - n.name"></p> 

```bash
Pepe
Lina
Emma
Léon
Avatar
```
<p tit="Result - n.age"></p> 

```bash
24
23
26
null
null
```
<p tit="Result - n.year"></p> 

```bash
null
null
null
1994
2009
```
Analysis: A `null` will be returned when calling a property that is not existent.


## Return ATTR - List

Example: Assemble the <i>name</i> of 1-Hop neighbors of each movie into a list
<p run-tag="true" graph="uql_manual_graph_10"></p> 

```js
khop().n({@movie} as a).e().n() as b
group by a
return a.name, collect(b.name)
```
<p tit="Result - a.name"></p> 

```bash
Léon
Avatar
```
<p tit="Result - collect(b.name)"></p> 

```bash
["Pepe","Lina","Emma"]
["Emma"]
```

## Valid Return Format

Suppose that <i>nodes</i>, <i>edges</i>, <i>paths</i>, <i>mytable</i>, <i>mylist</i>, <i>mypoint</i> and <i>myitem</i> are aliases of type NODE, EDGE, PATH, TABLE, <i>list</i>, <i>point</i> and others, below return formats are supported:

| Return Format | Return Content | <div table-width="20">Return Type</div> |
| ----------- | ------------------- |:-------------:|
| `nodes` 				| Node (carrying schema and system properties) 			| NODE 	|
| `nodes.<property>` 	| Node property | ATTR (return `null` if property does not exist) 	|
| `nodes.@` 			| Node schema 	| ATTR 	|
| `nodes{<property>, ...}` 	| Node (carrying schema, system properties and listed custom properties) 		| NODE 	|
| `nodes{*}` 				| Node (carrying schema, system properties and all custom properties)		| NODE 	|
| `edges` 				| Edge (carrying schema and system properties)  		| EDGE 	|
| `edges.<property>` 	| Edge property | ATTR (return `null` if property does not exist) 	|
| `edges.@` 			| Edge schema 	| ATTR 	|
| `edges{<property>, ...}` 	| Edge (carrying schema, system properties and listed custom properties) 		| EDGE 	|
| `edges{*}` 				| Edge (carrying schema, system properties and all custom properties)		| EDGE 	|
| `paths` 				| Path (carrying schema and system properties of metadata)  | PATH 	|
| `paths{<property>, ...}{<property>, ...}` | Path (carrying schema and system properties of metadata, carrying separately listed custom properties of nodes and edges)  | PATH 	|
| `paths{*}{<property>, ...}` | Path (carrying schema and system properties of metadata, carrying all custom properties of nodes and listed custom properties of edges)  | PATH 	|
| `paths{<property>, ...}{*}` | Path (carrying schema and system properties of metadata, carrying listed custom properties of nodes and all custom properties of edges)  | PATH 	|
| `paths{<property>}` 	| Path (carrying schema, system properties and listed custom properties of metadata)  | PATH 	|
| `paths{*}` 			| Path (carrying schema, system properties and all custom properties of metadata)  | PATH 	|
| `mytable`				| The whole table			| TABLE |
| `mylist` 				| The whole list			| ATTR |
| `mylist[n]` 			| The element with index n 	| ATTR |
| `mylist[n1:n2]` 		| A sub-list formed by element with index n1~n2 			| ATTR |
| `mylist[:n]` 			| A sub-list formed by element with index  0~n  			| ATTR |
| `mylist[n:]` 			| A sub-list formed by element with index  n~\<length-1> 	| ATTR |
| `mypoint` 			| The whole coordinates | ATTR |
| `mypoint.x` 			| The coordinate x		| ATTR |
| `mypoint.y` 			| The coordinate y		| ATTR |
| `myitem` 				| The value 			| ATTR |



