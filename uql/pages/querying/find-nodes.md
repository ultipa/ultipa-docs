# Find Nodes

## Overview

The `find().nodes()` statement retrieves nodes from the current graphset that meet the given conditions.

## Syntax

<p tit="Syntax"></p>

```uql
find().nodes(<filter?>)
```

- **Statement alias:** Type `NODE`; default is `nodes`
- **Methods:**

| <div table-width=10>Method</div> | <div table-width=11>Param</div> | Description | <div table-width=10>Optional</div> | <div table-width=10>Alias Type</div> |
| -- | -- | -- | -- | -- |
| `nodes()` | `<filter?>` | The filtering condition enclosed in `{}`, or an alias to specify the nodes to retrieve. If left blank, all nodes are targeted. | No | N/A |
| `limit()` | `<N>` | Limits the number of nodes (`N`≥-1) returned each time the statement executes; `-1` includes all nodes. | Yes	| N/A |

## Example Graph

<div align=center drawio-diagram='19510' drawio-name="draw_989ae99da53a466397e99319b9a3db8e.jpg"><img src="https://img.ultipa.cn/draw/draw_989ae99da53a466397e99319b9a3db8e.jpg?v='1731486856522'"/></div>

To create the graph, execute the following UQL queries sequentially in an empty graphset:

```uql
create().node_schema("User").node_schema("Club").edge_schema("Follows").edge_schema("Joins")
create().node_property(@User, "name").node_property(@Club, "name").edge_property(@Follows, "time", datetime).edge_property(@Joins, "memberNo", uint32).edge_property(@Joins, "time", datetime)
insert().into(@User).nodes([{_id:"U01", name:"Rowlock"},{_id:"U02", name:"Brainy"},{_id:"U03", name:"purplechalk"},{_id:"U04", name:"mochaeach"},{_id:"U05", name:"lionbower"}])
insert().into(@Club).nodes([{_id:"C01", name:"Rowlock Tennis"},{_id:"C02", name:"Super Yacht"}])
insert().into(@Follows).edges([{_from:"U01", _to:"U02", time:"2024-1-5"},{_from:"U02", _to:"U03", time:"2024-2-1"},{_from:"U04", _to:"U02", time:"2024-2-10"},{_from:"U03", _to:"U05", time:"2024-5-3"}])
insert().into(@Joins).edges([{_from:"U02", _to:"C01", memberNo:1, time:"2023-12-14"},{_from:"U05", _to:"C01", memberNo:2, time:"2024-2-25"},{_from:"U04", _to:"C02", memberNo:9, time:"2024-6-15"}])
```

## Finding All Nodes

To retrieve all nodes:

```uql
find().nodes() as n
return n{*}
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U05 | <span style="color: #999;">Sys-gen</span> | User | {name: "lionbower"} |
| U04 | <span style="color: #999;">Sys-gen</span> | User | {name: "mochaeach"} |
| U03 | <span style="color: #999;">Sys-gen</span> | User | {name: "purplechalk"} |
| U02 | <span style="color: #999;">Sys-gen</span> | User | {name: "Brainy"} |
| U01 | <span style="color: #999;">Sys-gen</span> | User | {name: "Rowlock"} |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | {name: "Super Yacht"} |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {name: "Rowlock Tennis"} |

## Finding Nodes with Schemas

To retrieve nodes belonging to the schema `Club`:

```uql
find().nodes({@Club}) as n
return n{*}
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | {name: "Super Yacht"} |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {name: "Rowlock Tennis"} |

To retrieve nodes belonging to the schema `Club` or `User`:

```uql
find().nodes({@Club || @User}) as n
return n{*}
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U05 | <span style="color: #999;">Sys-gen</span> | User | {name: "lionbower"} |
| U04 | <span style="color: #999;">Sys-gen</span> | User | {name: "mochaeach"} |
| U03 | <span style="color: #999;">Sys-gen</span> | User | {name: "purplechalk"} |
| U02 | <span style="color: #999;">Sys-gen</span> | User | {name: "Brainy"} |
| U01 | <span style="color: #999;">Sys-gen</span> | User | {name: "Rowlock"} |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | {name: "Super Yacht"} |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | {name: "Rowlock Tennis"} |

## Finding Nodes with Properties

In filters, properties can be used with their schema or independently. When used independently, they apply to all nodes with that property, regardless of schema. Specifically, system properties `_id` and `_uuid` cannot be used with a schema (e.g., `@User._id`) because they are unique identifiers.

To retrieve `@User` nodes where `name` is "Rowlock":

```uql
find().nodes({@User.name == "Rowlock"}) as n
return n._id
```

Result:

| n.\_id |
| -- |
| U01 |

To retrieve nodes where `name` contains "Rowlock":

```uql
find().nodes({name contains "Rowlock"}) as n
return n._id
```

Result:

| n.\_id |
| -- |
| C01 |
| U01 |

To retrieve nodes where `_id` is "U01" or "U02":

```uql
find().nodes({_id in ["U01", "U02"]}) as n
return n{*}
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U02 | <span style="color: #999;">Sys-gen</span> | User | {name: "Brainy"} |
| U01 | <span style="color: #999;">Sys-gen</span> | User | {name: "Rowlock"} |

## Using Default Alias

You can use the default alias `nodes` for the `find().nodes()` statement without explicitly declaring it.

To retrieve all nodes and return their `name` (with schema and system properties returned by default):

```uql
find().nodes()
return nodes{name}
```

Result: `nodes`

| \_id | \_uuid | schema | name |
| -- | -- | -- | -- |
| U05 | <span style="color: #999;">Sys-gen</span> | User | lionbower |
| U04 | <span style="color: #999;">Sys-gen</span> | User | mochaeach |
| U03 | <span style="color: #999;">Sys-gen</span> | User |purplechalk |
| U02 | <span style="color: #999;">Sys-gen</span> | User |Brainy |
| U01 | <span style="color: #999;">Sys-gen</span> | User | Rowlock |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | Super Yacht |
| C01 | <span style="color: #999;">Sys-gen</span> | Club |Rowlock Tennis |

## Limiting the Number of Nodes

You can use the `LIMIT` statememt immediately after the `find().nodes()` statement to restrict the number of nodes passed to subsequent statements.

To retrieve any 3 `@User` nodes:

```uql
find().nodes({@User}) as user limit 3
return user.name
```

Result:

| user.name |
| -- |
| mochaeach |
| Brainy |
| Rowlock |

## Using limit()

In this query, the `find().nodes()` statement executes two times, each time using one record from `id`. With the `limit()` method, only one node is retrieved each time:

```uql
uncollect ["U02", "U03"] as id
call {
    with id
    find().nodes({_id > id}).limit(1) as n
    return n
}
return n{*}
```

Result: `n`

| \_id | \_uuid | schema | name |
| -- | -- | -- | -- |
| U05 | <span style="color: #999;">Sys-gen</span> | User | lionbower |
| U05 | <span style="color: #999;">Sys-gen</span> | User | lionbower |

## Using OPTIONAL

In this query, the `find().nodes()` statement executes three times, each time using one record from `ID`. With the `OPTIONAL` prefix, the query returns `null` if no result is found during execution:

```uql
uncollect ["U01", "U22", "C01"] as ID
optional find().nodes({_id == ID}) as n
return n.name
```

Result:

| n.name |
| -- |
| Rowlock |
| `null` |
| Rowlock Tennis |

Without the prefix `OPTIONAL`, only two records are returned:

```uql
uncollect ["U01", "U22", "C01"] as ID
find().nodes({_id == ID}) as n
return n.name
```

Result:

| n.name |
| -- |
| Rowlock |
| Rowlock Tennis |
