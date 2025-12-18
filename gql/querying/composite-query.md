# Composite Query

## Overview

A composite query combines the result sets of multiple <a target="_blank" href="/docs/gql/query-composition">linear queries</a> using the following query conjunctions:

| <div table-width="22">Query Conjunction</div> | Description |
| -- | -- |
| `UNION` | Returns **distinct** records from all result sets. |
| `UNION ALL` | Returns all records from all result sets. |
| `EXCEPT` | Returns **distinct** records in the 1st result set that do not appear in others. |
| `EXCEPT ALL` | Returns all records in the 1st result set that do not appear in others. |
| `INTERSECT` | Returns **distinct** records that appear in all result sets. |
| `INTERSECT ALL` | Returns all records that appear in all result sets. |
| `OTHERWISE` | Returns the first non-empty result set, in order of appearance. |

**Details**

- `UNION`, `EXCEPT`, and `INTERSECT` perform deduplication on the final result set by default. They are equivalent to `UNION DISTINCT`, `EXCEPT DISTINCT`, and `INTERSECT DISTINCT`.
- Different query conjunctions can be used within a composite query statement.

To combine the result sets of multiple linear queries, the `RETURN` statements in all linear queries include the same number of return items, in the same order and with the same names. Each return item with the same name must also have the same type.

## Example Graph

<div align=center drawio-diagram='17053' drawio-name="draw_93e533a0a4df40389f5e67f0b8abbde4.jpg"><img src="https://img.ultipa.cn/draw/draw_93e533a0a4df40389f5e67f0b8abbde4.jpg?v='1726718106654'"/></div>

<div tab="code">

<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph { 
  NODE User ({name string}),
  NODE Club (),
  EDGE Follows ()-[{}]->(),
  EDGE Joins ()-[{}]->()
} PARTITION BY HASH(Crc32) SHARDS [1]
```

<p tit="Insert data to the graph"></p>

```gql
INSERT (rowlock:User {_id:'U01', name:'rowlock'}),
       (brainy:User {_id:'U02', name:'Brainy'}),
       (purplechalk:User {_id:'U03', name:'purplechalk'}),
       (mochaeach:User {_id:'U04', name:'mochaeach'}),
       (lionbower:User {_id:'U05', name:'lionbower'}),
       (c01:Club {_id:'C01'}),
       (c02:Club {_id:'C02'}),
       (rowlock)-[:Follows]->(brainy),
       (brainy)-[:Follows]->(rowlock),
       (mochaeach)-[:Follows]->(brainy),
       (brainy)-[:Follows]->(purplechalk),
       (purplechalk)-[:Follows]->(brainy),
       (brainy)-[:Joins]->(c01),
       (lionbower)-[:Joins]->(c01),
       (mochaeach)-[:Joins]->(c02)
```

</div>

## UNION

```gql
MATCH (n:Club) RETURN n
UNION
MATCH (n) RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | |
| U05 | <span style="color: #999;">Sys-gen</span> | User | {name: "lionbower"} |
| U04 | <span style="color: #999;">Sys-gen</span> | User | {name: "mochaeach"} |
| U03 | <span style="color: #999;">Sys-gen</span> | User | {name: "purplechalk"} |
| U02 | <span style="color: #999;">Sys-gen</span> | User | {name: "Brainy"} |
| U01 | <span style="color: #999;">Sys-gen</span> | User | {name: "rowlock"} |

## UNION ALL

```gql
MATCH (n:Club) RETURN n
UNION ALL
MATCH (n) RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | |
| U05 | <span style="color: #999;">Sys-gen</span> | User | {name: "lionbower"} |
| U04 | <span style="color: #999;">Sys-gen</span> | User | {name: "mochaeach"} |
| U03 | <span style="color: #999;">Sys-gen</span> | User | {name: "purplechalk"} |
| U02 | <span style="color: #999;">Sys-gen</span> | User | {name: "Brainy"} |
| U01 | <span style="color: #999;">Sys-gen</span> | User | {name: "rowlock"} |
| C02 | <span style="color: #999;">Sys-gen</span> | Club | |
| C01 | <span style="color: #999;">Sys-gen</span> | Club | |

## EXCEPT

```gql
MATCH ({_id: "U02"})-(n) RETURN n
EXCEPT
MATCH ({_id: "U05"})-(n) RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U04 | <span style="color: #999;">Sys-gen</span> | User | {name: "mochaeach"} |
| U03 | <span style="color: #999;">Sys-gen</span> | User | {name: "purplechalk"} |
| U01 | <span style="color: #999;">Sys-gen</span> | User | {name: "rowlock"} |

## EXCEPT ALL

```gql
MATCH ({_id: "U02"})-(n) RETURN n
EXCEPT ALL
MATCH ({_id: "U05"})-(n) RETURN n
```

Result: `n`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U01 | <span style="color: #999;">Sys-gen</span> | User | {name: "rowlock"} |
| U03 | <span style="color: #999;">Sys-gen</span> | User | {name: "purplechalk"} |
| U04 | <span style="color: #999;">Sys-gen</span> | User | {name: "mochaeach"} |
| U03 | <span style="color: #999;">Sys-gen</span> | User | {name: "purplechalk"} |
| U01 | <span style="color: #999;">Sys-gen</span> | User | {name: "rowlock"} |

## INTERSECT

```gql
MATCH ({_id: "U01"})-(u:User) RETURN u
INTERSECT
MATCH ({_id: "U03"})-(u:User) RETURN u
```

Result: `u`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U02 | <span style="color: #999;">Sys-gen</span> | User | {name: "Brainy"} |

## INTERSECT ALL

```gql
MATCH ({_id: "U01"})-(u:User) RETURN u
INTERSECT ALL
MATCH ({_id: "U03"})-(u:User) RETURN u
```

Result: `u`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U02 | <span style="color: #999;">Sys-gen</span> | User | {name: "Brainy"} |
| U02 | <span style="color: #999;">Sys-gen</span> | User | {name: "Brainy"} |

## OTHERWISE

```gql
MATCH ({_id: "U04"})<-[]-(u:User) RETURN u
OTHERWISE
MATCH ({_id: "U02"})<-[]-(u:User) RETURN u
```

Result: `u`

| \_id | \_uuid | schema | <div table-width="50">values</div> |
| -- | -- | -- | -- |
| U01 | <span style="color: #999;">Sys-gen</span> | User | {name: "rowlock"} |
| U03 | <span style="color: #999;">Sys-gen</span> | User | {name: "purplechalk"} |
| U04 | <span style="color: #999;">Sys-gen</span> | User | {name: "mochaeach"} |

In this example, the result set of the first linear query returns a `null` value due to the usage of `OPTIONAL`:

```gql
OPTIONAL MATCH ({_id: "U04"})<-[]-(u:User) RETURN u
OTHERWISE
MATCH ({_id: "U02"})<-[]-(u:User) RETURN u
```

Result:

| u |
| -- |
| `null` |

## Renaming Return Items

You may use the `AS` keyword to rename return items to ensure that the results of linear queries can be combined.

```gql
MATCH ({_id: "C01"})<-(u) RETURN u.name, 1 AS Club
UNION
MATCH ({_id: "C02"})<-(u) RETURN u.name, 2 AS Club
```

Result:

| u.name | Club |
| -- | -- |
| Brainy | 1 |
| lionbower | 1 |
| mochaeach | 2 |

## Using Different Query Conjunctions

```gql
MATCH (n:Club) RETURN n._id
OTHERWISE
MATCH (n) RETURN n._id
UNION ALL
MATCH (n)-[]->(:Club) RETURN n._id
```

Result:

| n.\_id |
| -- |
| C01 |
| C02 |
| U05 |
| U04 |
| U02 |

## Deduplicating Multiple Return Items

When the `RETURN` statements contain multiple return items, `DISTINCT` removes duplicate records based on the combined values of all return items.

```gql
MATCH (u1 {name: "rowlock"})-(u2:User) RETURN u1.name, u2.name
UNION DISTINCT
MATCH (u1 {name: "purplechalk"})-(u2:User) RETURN u1.name, u2.name
```

Result:

| u1.name | u2.name
| -- | -- |
| rowlock | Brainy |
| purplechalk | Brainy |

You may compare the results returned by `UNION ALL`:

```gql
MATCH (u1 {name: "rowlock"})-(u2:User) RETURN u1.name, u2.name
UNION ALL
MATCH (u1 {name: "purplechalk"})-(u2:User) RETURN u1.name, u2.name
```

Result:

| u1.name | u2.name
| -- | -- |
| rowlock | Brainy |
| rowlock | Brainy |
| purplechalk | Brainy |
| purplechalk | Brainy |
