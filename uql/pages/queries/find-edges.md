# Find Edges

## Overview

The clause `find().edges()` retrieves edges from the graphset that meet specified conditions.

## Syntax

**Clause alias:** EDGE type; default alias is `edges`

| <div table-width=10>Method</div> | <div table-width=9>Param Type</div> | <div table-width=8>Param Spec</div> | <div table-width=9>Required</div> | Description | <div table-width=7>Alias</div> |
| ---- | ---- | ---- | ---- | ---- | ---- |
| `edges()` | Filter | / | Yes | The conditions of edges to be retrieved | N/A |
| `limit()` | Integer | ≥-1 | No | Number of results to return for each subquery, `-1` signifies returning all | N/A |

## Examples

### Example Graph

<div align=center drawio-diagram='15541' drawio-name='draw_aa36dc7bd3dc4b74b15f4b47eb76292a.jpg'><img src="https://img.ultipa.cn/draw/draw_aa36dc7bd3dc4b74b15f4b47eb76292a.jpg?v='1716968983671'"/></div>

Run these UQLs row by row in an empty graphset to create this graph:

<p tit="" fold="true"></p>

```js
create().node_schema("professor").node_schema("student").edge_schema("mentor").edge_schema("assist")
create().node_property(@*, "age", int32).node_property(@*, "email", string).edge_property(@*, "year", int32)
insert().into(@professor).nodes([{_id:"P001",_uuid:1,age:53,email:"test@yahoo.cn"},{_id:"P002",_uuid:2,age:27,email:"test@ultipa.com"}])
insert().into(@student).nodes([{_id:"S001",_uuid:3,age:27,email:"test@yeah.net"},{_id:"S002",_uuid:4,age:20,email:"test@w3.org"},{_id:"S003",_uuid:5,age:25,email:"test@gmail.com"}])
insert().into(@mentor).edges([{_uuid:1, _from_uuid:2, _to_uuid:3, year:2020},{_uuid:2, _from_uuid:1, _to_uuid:3, year:2021},{_uuid:3, _from_uuid:1, _to_uuid:4, year:2021},{_uuid:4, _from_uuid:1, _to_uuid:5, year:2022}])
insert().into(@assist).edges([{_uuid:5, _from_uuid:3, _to_uuid:2, year:2020},{_uuid:6, _from_uuid:4, _to_uuid:1, year:2022}])
```

### Find All Edges

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges() as e
return e{*}
```

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 1 | P002 | S001 | 2 | 3 | mentor | 2020 |
| 2 | P001 | S001 | 1 | 3 | mentor | 2021 |
| 3 | P001 | S002 | 1 | 4 | mentor | 2021 |
| 4 | P001 | S003 | 1 | 5 | mentor | 2022 |

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 5 | S001 | P002 | 3 | 2 | assist | 2020 |
| 6 | S002 | P001 | 4 | 1 | assist | 2022 |

### Find Edges by UUID

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges(1) as e
return e{*}
```

> The filter `{_uuid == 1}` can be simplified to `1`.

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 1 | P002 | S001 | 2 | 3 | mentor | 2020 |

<br>

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges([1,3]) as e
return e{*}
```

> The filter `{_uuid in [1,3]}` can be simplified to `[1,3]`.

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 1 | P002 | S001 | 2 | 3 | mentor | 2020 |
| 3 | P001 | S002 | 1 | 4 | mentor | 2021 |

### Find Edges by Start Nodes

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges({_from == "P001"}) as e
return e{*}
```

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 2 | P001 | S001 | 1 | 3 | mentor | 2021 |
| 3 | P001 | S002 | 1 | 4 | mentor | 2021 |
| 4 | P001 | S003 | 1 | 5 | mentor | 2022 |

### Find Edges by End Nodes

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges({_to == "P001"}) as e
return e{*}
```

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 6 | S002 | P001 | 4 | 1 | assist | 2022 |

### Find Edges by Schema

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges({@assist}) as e
return e{*}
```

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 5 | S001 | P002 | 3 | 2 | assist | 2020 |
| 6 | S002 | P001 | 4 | 1 | assist | 2022 |

<br>

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges({@assist || @mentor}) as e
return e{*}
```

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 1 | P002 | S001 | 2 | 3 | mentor | 2020 |
| 2 | P001 | S001 | 1 | 3 | mentor | 2021 |
| 3 | P001 | S002 | 1 | 4 | mentor | 2021 |
| 4 | P001 | S003 | 1 | 5 | mentor | 2022 |

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 5 | S001 | P002 | 3 | 2 | assist | 2020 |
| 6 | S002 | P001 | 4 | 1 | assist | 2022 |

### Find Edges by Property

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges({year == 2020}) as e
return e{*}
```

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 1 | P002 | S001 | 2 | 3 | mentor | 2020 |

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 5 | S001 | P002 | 3 | 2 | assist | 2020 |

### Find Edges by Schema and Property

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges({@assist.year == 2020}) as e
return e{*}
```

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 5 | S001 | P002 | 3 | 2 | assist | 2020 |

### Use Default Clause Alias

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges().limit(3)
return edges{*}
```

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 1 | P002 | S001 | 2 | 3 | mentor | 2020 |
| 2 | P001 | S001 | 1 | 3 | mentor | 2021 |
| 3 | P001 | S002 | 1 | 4 | mentor | 2021 |

### Use limit()

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
find().edges().limit(3) as e
return e{*}
```

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 1 | P002 | S001 | 2 | 3 | mentor | 2020 |
| 2 | P001 | S001 | 1 | 3 | mentor | 2021 |
| 3 | P001 | S002 | 1 | 4 | mentor | 2021 |

### Use OPTIONAL

<p run-tag="true" graph="uql_manual_graph_2"></p> 

```js
uncollect [2022, 2023, 2024] as value
optional find().edges({year == value}) as e
return e{*}
```

Result:

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 4 | P001 | S003 | 1 | 5 | mentor | 2022 |

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema | year |
| -- | -- | -- | -- | -- | -- | -- |
| 6 | S002 | P001 | 4 | 1 | assist | 2022 |

| \_uuid | \_from | \_to | <div table-width=13>\_from_uuid</div> | \_to_uuid | Schema |
| -- | -- | -- | -- | -- | -- |
| null | null | null | null | null | null |
| null | null | null | null | null | null |

If the prefix `OPTIONAL` is not used, null results will not be returned.
