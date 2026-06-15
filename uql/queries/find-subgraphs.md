# Find Subgraphs

## Overview

The `subgraph([<path_template1>, <path_template2>, ...])` statement describes and searches subgraphs conform to a structure formed by multiple <a target="blank" href="/docs/uql/path-template">path template</a>. These path templates typically intersect at nodes or edges, achieved through the reuse of aliases to establish shared elements within the subgraph.

<div align=center drawio-diagram='13974' drawio-name="draw_b0d2c31b24cb4f728686a4543f0723af.jpg"><img src="https://img.ultipa.cn/draw/draw_b0d2c31b24cb4f728686a4543f0723af.jpg?v='1732695711564'"/></div>

## Syntax

- **Statement alias:** N/A
- It is not permitted to declare aliases for the path templates involved, but aliases can be defined within the single-node templates `n()` and single-edge templates `e()`.

<p tit="Syntax"></p>
  
```uql
subgraph([
  <path_template1>, 
  <path_template2>, 
  ...
])
```

## Example Graph

<div align=center drawio-diagram='19587' drawio-name="draw_ee27c3d206724ea8bb153fc2403843e4.jpg"><img src="https://img.ultipa.cn/draw/draw_ee27c3d206724ea8bb153fc2403843e4.jpg?v='1732699342225'"/></div>

To create the graph, execute each of the following UQL queries sequentially in an empty graphset:

```uql
create().node_schema("user").node_schema("card").edge_schema("owns").edge_schema("transfers")
insert().into(@user).nodes([{_id:"user1"}, {_id:"user2"}, {_id:"user3"}, {_id:"user4"}, {_id:"user5"}])
insert().into(@card).nodes([{_id:"card14"}, {_id:"card22"}, {_id:"card37"}, {_id:"card45"}, {_id:"card63"}, {_id:"card65"}])
insert().into(@owns).edges([{_from:"user1", _to:"card45"}, {_from:"user2", _to:"card65"}, {_from:"user3", _to:"card37"}, {_from:"user4", _to:"card14"}, {_from:"user4", _to:"card22"}, {_from:"user5", _to:"card63"}])
insert().into(@transfers).edges([{_from:"card45", _to:"card14"}, {_from:"card65", _to:"card14"}, {_from:"card63", _to:"card14"}, {_from:"card65", _to:"card37"}, {_from:"card22", _to:"card65"}, {_from:"card37", _to:"card22"}, {_from:"card22", _to:"card37"}, {_from:"card22", _to:"card14"}])
```

## Single Intersection

To find users who received direct transaction from both `user1` and `user2`:

<div align=center drawio-diagram='19588' drawio-name="draw_e4b28d625ace456192f233728c42b1c5.jpg"><img src="https://img.ultipa.cn/draw/draw_e4b28d625ace456192f233728c42b1c5.jpg?v='1732697941584'"/></div>

```uql
subgraph([
  n({_id == "user1"}).e().n({@card}).re({@transfers}).n({@card} as c).e().n({@user} as u),
  n({_id == "user2"}).e().n({@card}).re({@transfers}).n(c)
])
return u._id
```

Result:

| u.\_id |
| -- |
| user4 |

## Multiple Intersections

To find 3-step single-direction circular transaction paths between different accounts, return those account owners: 

<div align=center drawio-diagram='19589' drawio-name="draw_fda700339de34fd282f18e975707fe73.jpg"><img src="https://img.ultipa.cn/draw/draw_fda700339de34fd282f18e975707fe73.jpg?v='1732698526987'"/></div>

```uql
subgraph([
  n({@user} as u1).e().n({@card} as c1),
  n({@user && _id > u1._id} as u2).e().n({@card} as c2),
  n({@user && _id > u2._id} as u3).e().n({@card} as c3),
  n(c1).re().n(c2).re().n(c3).re().n(c1)
])
return table(u1._id, u2._id, u3._id)
```

| u1.\_id | u2.\_id | u3.\_id |
| -- | -- | -- |
| user2 | user3 | user4 |

To find card pairs which both cards sent transactions to cards `card14` and `card37`, and there are direct transactions between the card pair:

<div align=center drawio-diagram='19591' drawio-name="draw_4824ee2d90b34b06b764baf7fc74d5c7.jpg"><img src="https://img.ultipa.cn/draw/draw_4824ee2d90b34b06b764baf7fc74d5c7.jpg?v='1732700063401'"/></div>

```uql
subgraph([
  n({@card} as c1).e().n({@card} as c2),
  n(c1 as c11).re().n({_id == "card14"}).le().n(c2 as c22),
  n(c11).re().n({_id == "card37"}).le().n(c22)
])
where c1._id > c2._id
return table(c11._id, c22._id)
```

Result:

| c11.\_id | c22.\_id | 
| -- | -- | 
| card65 | card22 | 

If an alias needs to be referenced multiple times in different path templates within a `subgraph()`, it must be renamed after it is referenced the first time to keep it in scope. This ensures that the alias is available across multiple templates and avoids any potential conflicts or out-of-scope errors.
