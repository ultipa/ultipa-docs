# Autonet

The `autonet().src().dest().depth()` query can find and return paths from a group of initial-nodes to a group of terminal-nodes. It is a batch processing of A-B path query by paring an initial-node and a terminal-node for each query, and its parameter `limit()` is limiting the number of returns of each A-B pair of each subquery, but not that of all A-B pairs of each subquery.

Determined by the usage of parameter `dest()`, autonet query works in two modes:

a) Inter-group Networking (when setting `dest()`)
- `N` nodes from one group pairing with `M` nodes from another group
- `N * M` times of A-B path query
- When the parameter `limit(n)` is carried and the value of n is not -1, maximum `n` * `N * M` paths will be found
  
b) Intra-group Networking (when omitting `dest()`)
- N nodes from one group pairing with each other:
- `N(N-1)/2` times of A-B path query
- When the parameter `limit(n)` is carried and the value of n is not -1, maximum `n` * `N(N-1)/2` paths will be found
 
<div align=center drawio-diagram='13965' drawio-name='draw_d5dd0cba9d9642ebb807d8c6bd8d01c9.jpg'><img src="https://img.ultipa.cn/draw/draw_d5dd0cba9d9642ebb807d8c6bd8d01c9.jpg?v='1703123344286'"/></div>

<center><i> Inter-group Networking (Left image) and Intra-group Networking (Right image) </i></center>
<center><i> (Each Line represents an A-B query execution) </i></center>

Syntax:

- Statement alias: supported (PATH)
- All parameters:
 
| Parameter | Type | Specification | Description | Structure of Custom Alias |
| ---- | ---- | ------------- | ----------- | --------------- |
| `src()` | Filter | Mandatory | The filtering rules of the start node | NODE |
| `dest()` | Filter |   | The filtering rules of the end node | NODE |
| `depth()` | Range | Mandatory | To set the depth of the path <br> `depth(N)`: N edges <br> `depth(:N)`: 1~N edges <br> `depth(M:N)`: M~N edges <br> `depth(N).shortest()`: the shortest path within N edges | Not supported |
| `shortest()` | / or `@<schema>.<property>` | LTE-ed numeric edge property | Return the (weighted) shortest path. When an edge property (with non-negative values) is specified, edges without that property will not be considered<br><br>The `shortest()` method only supports `depth(N)`, indicating the (weighted) shortest paths within N steps | Not supported |
| `node_filter()` | Filter |   | The filtering rules that nodes other than `src` and `dest` need to satisfy	 | Not supported |
| `edge_filter()` | Filter |   | The filtering rules that all edges need to satisfy	| Not supported |
| `direction()` | String | left, right | To specify the direction of the edge | Not supported |
| `no_circle()` | / | / | To dismiss the paths with circles; see <i>Basic Concept</i> - <i>Terminologies</i> for the definition of circle   | Not supported |
| `limit()` | Int | -1 or >=0 | Number of results of each A-B pair to return, -1 means to return all results | Not supported |

Sample graph: (to be used for the following examples)

<div align=center drawio-diagram='6118' drawio-name="draw_4a8c9133ff214eca84de09920c95bc4c.jpg"><img src="https://img.ultipa.cn/draw/draw_4a8c9133ff214eca84de09920c95bc4c.jpg?v=''"/></div>
<center><i>(All nodes and edges are of schema @default)</i></center>
Run below UQLs one by one in an empty graphset to create graph data:
<p tit="" fold="true"></p>

```js
create().edge_property(@default, "weight", int32)
insert().into(@default).nodes([{_id:"A", _uuid:1}, {_id:"B", _uuid:2}, {_id:"C", _uuid:3}, {_id:"D", _uuid:4}, {_id:"E", _uuid:5}, {_id:"F", _uuid:6}])
insert().into(@default).edges([{_uuid:1, _from_uuid:1, _to_uuid:3, weight:1}, {_uuid:2, _from_uuid:5, _to_uuid:2 , weight:1}, {_uuid:3, _from_uuid:1, _to_uuid:5 , weight:4}, {_uuid:4, _from_uuid:4, _to_uuid:3 , weight:2}, {_uuid:5, _from_uuid:5, _to_uuid:4 , weight:3}, {_uuid:6, _from_uuid:2, _to_uuid:1 , weight:2}, {_uuid:7, _from_uuid:6, _to_uuid:1 , weight:4}])
```


## Inter-Group: Filter Depth

Example: Find 1~3-step paths from [A,B] to [D,E], carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
autonet().src({_id in ["A","B"]}).dest({_id in ["D","E"]}).depth(:3) as p
return p{*}
```
<p tit="Result"></p>

```bash
A --3--> E --5--> D
A --1--> C <--4-- D
A <--6-- B <--2-- E --5--> D
A --3--> E
A --1--> C <--4-- D <--5-- E
A <--6-- B <--2-- E
B --6--> A --3--> E --5--> D
B --6--> A --1--> C <--4-- D
B <--2-- E --5--> D
B --6--> A --3--> E
B <--2-- E
```

## Inter-Group: Non-weighted Shortest Path

Example: Find shortest paths from [A,B] to [D,E] within 3 steps, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
autonet().src({_id in ["A","B"]}).dest({_id in ["D","E"]}).depth(3)
  .shortest() as p
return p{*}
```
<p tit="Result"></p>

```bash
A --1--> C <--4-- D
A --3--> E --5--> D
A --3--> E
B <--2-- E --5--> D
B <--2-- E
```

## Inter-Group: limit()

Example: Find 1~3-step paths from [A,B] to [D,E], return 1 path for each pair of nodes, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
autonet().src({_id in ["A","B"]}).dest({_id in ["D","E"]}).depth(:3).limit(1) as p
return p{*}
```
<p tit="Result"></p>

```bash
A <--6-- B <--2-- E --5--> D
A <--6-- B <--2-- E
B <--2-- E --5--> D
B <--2-- E
```

## Intra-Group: Filter Depth

Example: Find 1~3-step paths among [A,B,C], carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
autonet().src({_id in ["A","B","C"]}).depth(:3) as p
return p{*}
```
<p tit="Result"></p>

```bash
A --3--> E --2--> B
A <--6-- B
A --3--> E --5--> D --4--> C
A --1--> C
B --6--> A --1--> C
B <--2-- E --5--> D --4--> C
B <--2-- E <--3-- A --1--> C
```

## Intra-Group: Non-weighted Shortest Path

Example: Find shortest paths among [A,B,C] within 3 steps, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
autonet().src({_id in ["A","B","C"]}).depth(3)
  .shortest() as p
return p{*}
```
<p tit="Result"></p>

```bash
A <--6-- B
A --1--> C
B --6--> A --1--> C
```

## Intra-Group: limit()

Example: Find 1~3-step paths among [A,B,C], return 1 path for each pair of nodes, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
autonet().src({_id in ["A","B","C"]}).depth(:3).limit(1) as p
return p{*}
```
<p tit="Result"></p>

```bash
A <--6-- B
A --1--> C
B <--2-- E <--3-- A --1--> C
```
