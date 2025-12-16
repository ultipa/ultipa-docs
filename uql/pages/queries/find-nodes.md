# Find Nodes

## Overview

The clause `find().nodes()` retrieves nodes from the graphset that meet specified conditions.

## Syntax

**Clause alias:** NODE type; default alias is `nodes`

| <div table-width=10>Method</div> | <div table-width=9>Param Type</div> | <div table-width=8>Param Spec</div> | <div table-width=9>Required</div> | Description | <div table-width=7>Alias</div> |
| ---- | ---- | ---- | ---- | ---- | ---- |
| `nodes()` | Filter | / | Yes | The conditions of nodes to be retrieved | N/A |
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

### Find All Nodes

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes() as n
return n{*}
```

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| P001 | 1 | professor | 53 | test@yahoo.cn |
| P002 | 2 | professor | 27 | test@ultipa.com |

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| S001 | 3 | student | 27 | test@yeah.net |
| S002 | 4 | student | 20 | test@w3.org |
| S003 | 5 | student | 25 | test@gmail.com |

### Find Nodes by ID

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes({_id == "S001"}) as n
return n{*}
```

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| S001 | 3 | student | 27 | test@yeah.net |

<br>

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes({_id in ["P001", "P002"]}) as n
return n{*}
```

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| P001 | 1 | professor | 53 | test@yahoo.cn |
| P002 | 2 | professor | 27 | test@ultipa.com |

### Find Nodes by UUID

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes(1) as n
return n{*}
```

> The filter `{_uuid == 1}` can be simplified to `1`.

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| P001 | 1 | professor | 53 | test@yahoo.cn |

<br>

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes([1,3]) as n
return n{*}
```

> The filter `{_uuid in [1,3]}` can be simplified to `[1,3]`.

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| P001 | 1 | professor | 53 | test@yahoo.cn |

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| S001 | 3 | student | 27 | test@yeah.net |

### Find Nodes by Schema

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes({@student}) as n
return n{*}
```

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| S001 | 3 | student | 27 | test@yeah.net |
| S002 | 4 | student | 20 | test@w3.org |
| S003 | 5 | student | 25 | test@gmail.com |

<br>

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes({@student || @professor}) as n
return n{*}
```

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| P001 | 1 | professor | 53 | test@yahoo.cn |
| P002 | 2 | professor | 27 | test@ultipa.com |

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| S001 | 3 | student | 27 | test@yeah.net |
| S002 | 4 | student | 20 | test@w3.org |
| S003 | 5 | student | 25 | test@gmail.com |

### Find Nodes by Property

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes({age > 30}) as n
return n{*}
```

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| P001 | 1 | professor | 53 | test@yahoo.cn |

### Find Nodes by Schema and Property

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes({@student.age > 25}) as n
return n{*}
```

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| S001 | 3 | student | 27 | test@yeah.net |

### Use Default Clause Alias

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes().limit(1)
return nodes{*}
```

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| P001 | 1 | professor | 53 | test@yahoo.cn |

### Use limit()

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
find().nodes().limit(3) as n
return n{*}
```

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| P001 | 1 | professor | 53 | test@yahoo.cn |
| P002 | 2 | professor | 27 | test@ultipa.com |

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| S001 | 3 | student | 27 | test@yeah.net |

### Use OPTIONAL

<p run-tag="true" graph="uql_manual_graph_2"></p>

```js
uncollect [53, 55, 57] as value
optional find().nodes({age == value}) as n
return n{*}
```

Result:

| \_id  | \_uuid | Schema | age | <div table-width=30>email</div> |
| -- | -- | -- | -- | -- |
| P001 | 1 | professor | 53 | test@yahoo.cn |

| \_id  | \_uuid | Schema |
| -- | -- | -- |
| null | null | null |
| null | null | null |

If the prefix `OPTIONAL` is not used, null results will not be returned.
