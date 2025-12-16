# K-Hop Template

## Overview

The k-hop template clause `khop().n()...n()` utilizes a path template to query for **k-hop neighbors** of the start nodes in the paths. 

With the defined path template, the value of k depends on the shortest distance between two nodes, same as explained in the <a href="https://www.ultipa.com/docs/uql/k-hop/">k-hop clause</a>. Additionally, the returned nodes must satisfy the condition set for the destination nodes in the path template.

### K-Hop vs. K-Hop Template

| | <div table-width=20>K-Hop</div> | <div table-width=20>K-Hop Template</div> |
| -- | -- | -- |
| Start nodes | Single | Single or multiple |
| Filtering rules for edges | All the same | Can be different |
| Filtering rules for nodes other than the start nodes | All the same | Can be different |

### Path Template vs. K-Hop Template

While achieving the same query function, the K-Hop template generally offers better performance than the path template.

For example, the two UQLs return the same results - the number of distinct ads clicked by a user. It's important to note that the destination nodes returned by the path template are not automatically deduplicated, whereas the results of the k-hop template are deduplicated.

```js
// Path Template
n({_id == "u316591"}).e({@clicks}).n({@ad} as ads)
return count(DISTINCT ads)

// K-Hop Template
khop().n({_id == "u316591"}).e({@clicks}).n({@ad}) as ads
with count(ads)
```

## Syntax

- **Clause alias:** NODE type
- **Regarding the path template:**
  - The initial `n()` must have a valid filter which can specify multiple nodes.
  - The `[<steps>]` in multi-edge templates `e()[<steps>]` and `e().nf()[<steps>]` don't support the format of `[*:N]`, as the k-hop query automatically traverses through the shortest paths.
  - Inter-step filtering is not supported, whether using system alias (`prev_n`, `prev_e`) or custom alias.
- **Methods:**

| <div table-width=14>Method</div> | <div table-width=9>Param Type</div> | <div table-width=8>Param Spec</div> | <div table-width=9>Required</div> | Description | <div table-width=7>Alias</div> |
| ---  | --- | --- | --- | --- | --- |
| `limit()` | Integer | ≥-1 | No | Number of k-hop neighbors to return for each start node (note that not each subquery), `-1` signifies returning all | N/A |

## Examples

### Example Graph

<div align=center drawio-diagram='15290' drawio-name="draw_29979ef7ec9e402498c5b69577e7e6a3.jpg"><img src="https://img.ultipa.cn/draw/draw_29979ef7ec9e402498c5b69577e7e6a3.jpg?v='1713324743376'"/></div>

Run these UQLs row by row in an empty graphset to create this graph:

<p tit="" fold="true"></p>

```js
create().node_schema("country").node_schema("movie").node_schema("director").node_schema("actor").edge_schema("filmedIn").edge_schema("direct").edge_schema("cast").edge_schema("bornIn")
create().node_property(@*, "name")
insert().into(@country).nodes([{_id:"C001", _uuid:1, name:"France"}, {_id:"C002", _uuid:2, name:"USA"}])
insert().into(@movie).nodes([{_id:"M001", _uuid:3, name:"Léon"}, {_id:"M002", _uuid:4, name:"The Terminator"}, {_id:"M003", _uuid:5, name:"Avatar"}])
insert().into(@director).nodes([{_id:"D001", _uuid:6, name:"Luc Besson"}, {_id:"D002", _uuid:7, name:"James Cameron"}])
insert().into(@actor).nodes({_id:"A001", _uuid:8, name:"Zoe Saldaña"})
insert().into(@filmedIn).edges([{_uuid:1, _from_uuid:3, _to_uuid:1}, {_uuid:2, _from_uuid:4, _to_uuid:1}, {_uuid:3, _from_uuid:4, _to_uuid:2}, {_uuid:4, _from_uuid:5, _to_uuid:2}])
insert().into(@direct).edges([{_uuid:5, _from_uuid:6, _to_uuid:3}, {_uuid:6, _from_uuid:7, _to_uuid:4}, {_uuid:7, _from_uuid:7, _to_uuid:5}])
insert().into(@cast).edges([{_uuid:8, _from_uuid:8, _to_uuid:5}])
insert().into(@bornIn).edges([{_uuid:9, _from_uuid:8, _to_uuid:2}])
```

### Set Fixed-Length Path

Find the 2-hop neighbors of each country that can be reached through a certain path.

<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
khop().n({@country} as a).le({@filmedIn}).n({@movie}).le({@direct}).n({@director}) as b
return table(a.name, b.name)
```

Result: 

| a.name |     b.name    |
|--------|---------------|
| USA    | James Cameron |
| France | James Cameron |
| France | Luc Besson    |

### Set Non-Fixed-Length Path

Find the 1- and 2-hop neighbors of each country that can be reached through a certain path.

<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
khop().n({@country} as a).e({!@direct})[:2].n({!@country}) as b
return table(a.name, b.name)
```

Result:

| a.name |     b.name    |
|--------|---------------|
| USA | Zoe Saldaña |
| USA | The Terminator |
| USA | Avatar |
| France | The Terminator |
| France | Léon |

### Destination Node Filtering

Find the 2-hop *@director* neighbors of each country.

<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
khop().n({@country} as a).e()[2].n({@director}) as b
return table(a.name, b.name)
```

Result: 

| a.name |     b.name    |
|--------|---------------|
| USA    | James Cameron |
| France | James Cameron |
| France | Luc Besson    |

### Take the Shortest Path

Find the 2-hop *@country* neighbors of one actor.

<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
khop().n({@actor.name == "Zoe Saldaña"}).e()[2].n({@country}) as a return a
```

Result: No return data.

Even though there exists a 2-step path from the actor to a country (`Zoe Saldaña - [@cast] - Avatar - [filmedIn]- USA`), that's not the shortest path (`Zoe Saldaña - [@bornIn] - USA`) between them.

### Use limit()

Find one 1-hop neighbor for each director that can be reached through a certain path.

<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
khop().n({@director} as a).e({@direct}).n().limit(1) as b
return table(a.name, b.name)
```

Result:

| a.name |   b.name   |
|--------|------------|
| James Cameron | The Terminator |
| Luc Besson | Léon |

### Use OPTIONAL

Find the 2-hop *@actor* neighbors of each country that can be reached through a certain path. Return null if no neighbors are found.

<p run-tag="true" graph="uql_manual_graph_5"></p> 

```js
find().nodes({@country}) as cty
optional khop().n(cty).e({!@bornIn})[2].n({@actor}) as actor
return table(cty.name, actor.name)
```

Result:

| cty.\_id | actor.\_id |
|-----|-------|
| France | null |
| USA | Zoe Saldaña |
null
