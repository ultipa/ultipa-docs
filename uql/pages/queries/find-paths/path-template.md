# Path Template

A path template `n().e()...n()` can apply filters on each node and edge of a path independently. Paths with circle can be filtered out, and the number of result of subquery can be limited.

> For the usage of basic templates `n()`, `e()` and so on, please refer to <a href="https://www.ultipa.com/docs/uql/basic-templates">Basic Templates</a>.

Syntax:
- Statement alias: supported (PATH)
- Prefix: OPTIOANL (returns a path whose nodes and edges are all `null` for any subquery that finds no result)
- Optional parameters:

| Parameter | Type | Specification | Description | Structure of Custom Alias |
| ---- | ---- | ------------- | ----------- | --------------- |
| `no_circle()` | / | / | To dismiss the paths with circles; see <i>Basic Concept</i> - <i>Terminologies</i> for the definition of circle  | Not supported |
| `limit()` | Int | -1 or >=0 | Number of results to return for each subquery, -1 means to return all results | Not supported |

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

## Filter Single Node/Edge

Example: Find single-node paths of @movie, carry all properties
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
n({@movie}) as p
return p{*}
```
<p tit="Result"></p> 

```bash
Léon
Avatar
The Terminator
```

Example: Find 4-step paths of @movie-@country-@movie-@director-@movie, carry all properties
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
n({@movie}).re({@filmedIn}).n({@country})
  .le({@filmedIn}).n({@movie})
  .le({@direct}).n({@director})
  .re({@direct}).n({@movie}) as p
return p{*}
```
<p tit="Result"></p> 

```bash
Léon ----> France <---- The Terminator <---- James Cameron ----> Avatar
Léon ----> USA <---- The Terminator <---- James Cameron ----> Avatar
Léon ----> USA <---- Avatar <---- James Cameron ----> The Terminator
The Terminator ----> USA <---- Avatar <---- James Cameron ----> The Terminator
Avatar ----> USA <---- The Terminator <---- James Cameron ----> Avatar
```

## Filter Multi-Edge

Example: Find 1~4-step paths from Léon to Avatar, carry all properties
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
n({@movie.name == "Léon"}).e()[:4].n({@movie.name == "Avatar"}) as p
return p{*}
```
<p tit="Result"></p> 

```bash
Léon ----> France <---- The Terminator ----> USA <---- Avatar
Léon ----> France <---- The Terminator <---- James Cameron ----> Avatar
Léon ----> USA <---- The Terminator <---- James Cameron ----> Avatar
Léon ----> USA <---- Avatar
```

## Filter Multi-Edge and Intermediate Nodes

Example: Find 1~4-step paths from Léon to Avatar and not passing France, carry all properties
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
n({@movie.name == "Léon"}).e().nf({name != "France"})[:4].n({@movie.name == "Avatar"}) as p
return p{*}
```
<p tit="Result"></p> 

```bash
Léon ----> USA <---- The Terminator <---- James Cameron ----> Avatar
Léon ----> USA <---- Avatar
```

## Non-weighted Shortest Path

Example: Find shortest paths from Léon to Avatar within 4 steps, carry all properties
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
n({@movie.name == "Léon"}).e()[*:4].n({@movie.name == "Avatar"}) as p
return p{*}
```
<p tit="Result"></p> 

```bash
Léon ----> USA <---- Avatar
```
Analysis: The multi-edge template `e()[*:N]` or `e().nf()[*:N]`  that represent shortest path must be the last edge template in the path.

## Filter Circle

Example: Find 4-step paths of @movie-@country-@movie-@director-@movie, with the initial-node and terminal-node representing the same node, carry all properties
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
n({@movie} as a).re({@filmedIn}).n({@country})
  .le({@filmedIn}).n({@movie})
  .le({@direct}).n({@director})
  .re({@direct}).n(a) as p
return p{*}
```
<p tit="Result"></p> 

```bash
The Terminator ----> USA <---- Avatar <---- James Cameron ----> The Terminator
Avatar ----> USA <---- The Terminator <---- James Cameron ----> Avatar
```

Example: Find 4-step paths of @movie-@country-@movie-@director-@movie, remove paths with circles, carry all properties
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
n({@movie}).re({@filmedIn}).n({@country})
  .le({@filmedIn}).n({@movie})
  .le({@direct}).n({@director})
  .re({@direct}).n({@movie}).no_circle() as p
return p{*}
```
<p tit="Result"></p> 

```bash
Léon ----> France <---- The Terminator <---- James Cameron ----> Avatar
Léon ----> USA <---- The Terminator <---- James Cameron ----> Avatar
Léon ----> USA <---- Avatar <---- James Cameron ----> The Terminator
```

## limit()

Example: Find two 4-step paths of @movie-@country-@movie-@director-@movie, carry all properties
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
n({@movie}).re({@filmedIn}).n({@country})
  .le({@filmedIn}).n({@movie})
  .le({@direct}).n({@director})
  .re({@direct}).n({@movie}).limit(2) as p
return p{*}
```
<p tit="Result"></p> 

```bash
Léon ----> France <---- The Terminator <---- James Cameron ----> Avatar
Léon ----> USA <---- The Terminator <---- James Cameron ----> Avatar
```

## OPTIONAL

Example: Find 2-step paths from Luc Besson to Avatar, carry all properties; return `null` if no result
<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
optional n({@director.name == "Luc Besson"}).e()[2].n({@movie.name == "Avatar"}) as p
return p{*}
```
<p tit="Result"></p> 

```bash
null --null-- null --null-- null
```
Analysis: This query will give no return if not using OPTIONAL.

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6141' drawio-name="draw_8257c4dc021644c4bce1b09c9eeee012.jpg"><img src="https://img.ultipa.cn/draw/draw_8257c4dc021644c4bce1b09c9eeee012.jpg?v=''"/></div>
Run below UQLs one by one in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```js
create().node_schema("customer").node_schema("account").edge_schema("has").edge_schema("transfer")
create().edge_property(@transfer, "time", datetime)
insert().into(@customer).nodes([{_id:"C001", _uuid:1}])
insert().into(@account).nodes([{_id:"A001", _uuid:2}, {_id:"A002", _uuid:3}, {_id:"A003", _uuid:4}, {_id:"A004", _uuid:5}])
insert().into(@has).edges([{_uuid:1, _from_uuid:1, _to_uuid:2}, {_uuid:2, _from_uuid:1, _to_uuid:3}])
insert().into(@transfer).edges([{_uuid:3, _from_uuid:2, _to_uuid:4, time:"2023-03-01"}, {_uuid:4, _from_uuid:2, _to_uuid:5, time:"2023-04-25"}, {_uuid:5, _from_uuid:4, _to_uuid:5, time:"2023-03-27"}, {_uuid:6, _from_uuid:5, _to_uuid:3, time:"2023-02-15"}])
```

## Filter 0 Step

Example: Find 0~2-step outward-transferring paths from the accounts held by C001 to other accounts, carry all properties
<p run-tag="true" graph="uql_manual_graph_6"></p> 

```js
n({_id == "C001"}).re({@has}).n({@account})
  .re({@transfer})[0:2].n({@account}) as p
return p{*}
```
<p tit="Result"></p> 

```bash
C001 ----> A001
C001 ----> A001 ----> A003
C001 ----> A001 ----> A003 ----> A004
C001 ----> A001 ----> A004
C001 ----> A001 ----> A004 ----> A002
C001 ----> A002
```
Analysis: The 0-step in multi-edge template `e()[0:N]` or `e().nf()[0:N]` works only when both `n()` before and after this multi-edge template have same filtering condition.

## Inter-Step Filtering

Example: Find 2-step outward-transferring paths between accounts, with property <i>time</i> ascending along the path, carry all properties
<p run-tag="true" graph="uql_manual_graph_6"></p> 

```js
n({@account}).re({@transfer.time > prev_e.time})[2].n({@account}) as p
return p{*}
```
<p tit="Result"></p> 

```bash
A001 ----> A003 ----> A004
```
Analysis: Porperty <i>@transfer.time</i> should be loaded to engine (LTE).
null
