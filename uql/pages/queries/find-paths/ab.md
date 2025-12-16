# AB

## Overview

The clause `ab().src().dest().depth()` retrieves paths between a single source node and a single destination node.

## Syntax

**Clause Alias:** PATH type

| <div table-width=14>Method</div> | <div table-width=13>Param Type</div> | <div table-width=8>Param Spec</div> | <div table-width=9>Required</div> | Description | <div table-width=7>Alias</div> |
| ---- | ---- | ---- | ---- | ---- | ---- |
| `src()` | Filter | / | Yes | The conditions of the single source node; error occurs if multiple nodes are specified | NODE |
| `dest()` | Filter | / | Yes | The conditions of the single destination node; error occurs if multiple nodes are specified | NODE |
| `depth()` | Range | / | Yes | Depth of the paths (N≥1):<br>`depth(N)`: N edges<br>`depth(:N)`: 1~N edges<br>`depth(M:N)`: M~N edges (M≥0) | N/A |
| `shortest()` | / or `@<schema>.<property>` | LTE-ed numeric edge property | No | Return the (weighted) shortest path. When an edge property (with non-negative values) is specified, edges without that property will not be considered<br><br>The `shortest()` method only supports `depth(N)`, indicating the (weighted) shortest paths within N steps | N/A |
| `node_filter()` | Filter | / | No | The conditions that all intermediate nodes in the paths must satisfy | N/A |
| `edge_filter()` | Filter | / | No | The conditions that all edges in the paths must satisfy | N/A |
| `path_ascend()` | `@<schema>.<property>` | LTE-ed numeric edge property | No | Return paths where the specified property values ascend from source to destination (edges without the property will not be considered) | N/A |
| `path_descend()` | `@<schema>.<property>` | LTE-ed numeric edge property | No | Return paths where the specified property values descend from source to destination (edges without the property will not be considered) | N/A |
| `direction()` | String | `left`, `right` | No | Direction of all edges in the paths | N/A |
| `no_circle()` | / | / | No | Paths with circles will not be returned<br><br>Exception: When `src()` and `dest()` specify the same node and that node does not appear in any intermediate position, the path will still be returned | N/A |
| `limit()` | Integer | ≥-1 | No | Number of results to return for each subquery, `-1` signifies returning all | N/A |

## Examples

### Example Graph

<div align=center drawio-diagram='6118' drawio-name="draw_4a8c9133ff214eca84de09920c95bc4c.jpg"><img src="https://img.ultipa.cn/draw/draw_4a8c9133ff214eca84de09920c95bc4c.jpg?v=''"/></div>

Run these UQLs row by row in an empty graphset to create this graph:

<p tit="" fold="true"></p>

```js
create().edge_property(@default, "weight", int32)
insert().into(@default).nodes([{_id:"A", _uuid:1}, {_id:"B", _uuid:2}, {_id:"C", _uuid:3}, {_id:"D", _uuid:4}, {_id:"E", _uuid:5}, {_id:"F", _uuid:6}])
insert().into(@default).edges([{_uuid:1, _from_uuid:1, _to_uuid:3, weight:1}, {_uuid:2, _from_uuid:5, _to_uuid:2 , weight:1}, {_uuid:3, _from_uuid:1, _to_uuid:5 , weight:4}, {_uuid:4, _from_uuid:4, _to_uuid:3 , weight:2}, {_uuid:5, _from_uuid:5, _to_uuid:4 , weight:3}, {_uuid:6, _from_uuid:2, _to_uuid:1 , weight:2}, {_uuid:7, _from_uuid:6, _to_uuid:1 , weight:4}])
```

### Filter Depth

Example: Find 3-step paths from A to E, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(3) as p
return p{*}
```
<p tit="Result"></p>

```bash
A --1--> C <--4-- D <--5-- E
```


Example: Find 1~3-step paths from A to E, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(:3) as p
return p{*}
```
<p tit="Result"></p>

```bash
A --3--> E
A --1--> C <--4-- D <--5-- E
A <--6-- B <--2-- E
```


Example: Find 2~3-step paths from A to E, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(2:3) as p
return p{*}
```
<p tit="Result"></p>

```bash
A --1--> C <--4-- D <--5-- E
A <--6-- B <-2-- E
```

### Non-weighted Shortest Path

Example: Find shortest paths from A to E within 3 steps, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(3)
  .shortest() as p
return p{*}
```
<p tit="Result"></p>

```bash
A --3--> E
```

### Weighted Shortest Path

Example: Find shortest paths from A to E within 3 steps, use <i>@default.weight</i> as weight, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(3)
  .shortest(@default.weight) as p
return p{*}
```
<p tit="Result"></p>

```bash
A <--6-- B <--2-- E
```
Analysis: Porperty <i>@default.weight</i> should be loaded to engine (LTE).


### Filter Intermediate Nodes

Example: Find 1~3-step paths from A to E and not passing D, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(:3)
  .node_filter({_id != "D"}) as p
return p{*}
```
<p tit="Result"></p>

```bash
A --3--> E
A <--6-- B <--2-- E
```

### Filter Edges

Example: Find 1~3-step paths from A to E where the <i>weight</i> of edge is greater than 1, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(:3)
  .edge_filter({weight > 1}) as p
return p{*}
```
<p tit="Result"></p>

```bash
A --3--> E
```

### Edge Property Ascend/Descend

Example: Find 1~3-step paths from A to E with property <i>@default.weight</i> ascending along the path, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(:3)
  .path_ascend(@default.weight) as p
return p{*}
```
<p tit="Result"></p>

```bash
A --3--> E
A --1--> C <--4-- D <--5-- E
```
Analysis: Porperty <i>@default.weight</i> should be loaded to engine (LTE).

Example: Find 1~3-step paths from A to E with property <i>@default.weight</i> descending along the path, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(:3)
  .path_descend(@default.weight) as p
return p{*}
```
<p tit="Result"></p>

```bash
A --3--> E
A <--6-- B <--2-- E
```
Analysis: Porperty <i>@default.weight</i> should be loaded to engine (LTE).

### Filter Edge Direction

Example: Find 1~3-step paths from A to E with all edges right-pointing, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(:3)
  .direction(right) as p
return p{*}
```
<p tit="Result"></p>

```bash
A --3--> E
```

Example: Find 1~3-step paths from A to E with all edges left-pointing, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(:3)
  .direction(left) as p
return p{*}
```
<p tit="Result"></p>

```bash
A <--6-- B <--2-- E
```

### Filter Circles

Example: Find 4-step paths from A to E that do not contain circle, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "C"}).depth(4).no_circle() as p
return p{*}
```
<p tit="Result"></p>

```bash
A <--6-- B <--2-- E --3--> D --4--> C
```
Analysis: Paths with circle will be returned if not using no_circle():
<p tit="Result"></p>

```bash
A --3--> E --2--> B --6--> A --1--> C
A <--6-- B <--2-- E --3--> D --4--> C
A <--6-- B <--2-- E <--3-- A --1--> C
```

### limit()

Example: Find a 1~3-step path from A to E, carry all properties
<p run-tag="true" graph="uql_manual_graph_4"></p> 

```js
ab().src({_id == "A"}).dest({_id == "E"}).depth(:3).limit(1) as p
return p{*}
```
<p tit="Result"></p>

```bash
A <--6-- B <--2-- E
```
