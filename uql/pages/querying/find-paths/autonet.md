# Autonet

## Overview

The `autonet().src().dest().depth()` statement retrieves paths between nodes.

When two sets of nodes are provided, the query attempts to find paths between each node in the source set and each node in the destination set. If only one set of nodes is given, each node in the set is paired with all other nodes in the same set to search for paths.

## Syntax

<p tit="Syntax"></p>

```uql
autonet().src(<filter?>).dest(<filter?>).depth(<range>)
```

- **Statement alias:** Type `PATH`<br>
- **Methods:**

| <div table-width=13>Method</div> | <div table-width=13>Param</div> | Description | <div table-width=9>Optional</div> | <div table-width=8>Alias Type</div> |
| -- | -- | -- | -- | -- |
| `src()` | `<filter?>` | The filtering condition enclosed in `{}`, or an alias to specify the set of nodes as traversal sources. If left blank, all nodes are targeted. | No | `NODE` |
| `dest()` | `<filter?>` | The filtering condition enclosed in `{}`, or an alias to specify the set of nodes as traversal destinations. If left blank, all nodes are targeted. If omitted, paths will be found only between nodes specified in `src()`. | Yes | `NODE` |
| `depth()` | `<range>` | The number of steps to travese (N≥1):<ul><li>`depth(N)`: N edges</li><li>`depth(:N)`: 1 ~ N edges</li><li>`depth(N:M)`: N ~ M edges</li></ul> | No | N/A |
| `shortest()` | `<weight?>` | Leaves it blank to find unweighted shortest paths or specifies a numeric edge property in the format `@<schema>.<property>` to find weighted shortest paths. The property shouldn't have negative values, and edges without these properties are disregarded. Only supports `depth(N)` for the shortest paths within `N` steps. | Yes | N/A |
| `node_filter()` | `<filter?>` | The filtering condition enclosed in `{}` for all intermediate nodes in the paths. If left blank, no restriction is applied. | Yes | N/A |
| `edge_filter()` | `<filter?>` | The filtering condition enclosed in `{}` for edges in the paths. If left blank, no restriction is applied. | Yes | N/A |
| `path_ascend()` | `<property>` | Specifies a numeric edge property in the format `@<schema>.<property>` to find paths where this property values ascend from `src()` to `dest()`; edges without these properties are disregarded. | Yes | N/A |
| `path_descend()` | `<property>` | Specifies a numeric edge property in the format `@<schema>.<property>` to find paths where this property values descend from `src()` to `dest()`; edges without these properties are disregarded. | Yes | N/A |
| `direction()` | `<leftRight>` | Specifies the direction of all edges in the paths, which can be `left` or `right`. | Yes | N/A |
| `no_circle()` | / | Excludes paths that form circles. A path has circles when it has repeated nodes. An exception is when `src()` and `dest()` specify the same node and that node does not appear as an intermediate node, the corresponding paths will still be returned. | Yes | N/A |
| `limit()` | `<N>` | Limits the number of paths (`N`≥-1) returned for each node pair; `-1` includes all paths. | Yes | N/A |

## Example Graph

<div align=center drawio-diagram='19582' drawio-name='draw_f886b63b7a3d47e784d035c5e0313630.jpg'><img src="https://img.ultipa.cn/draw/draw_f886b63b7a3d47e784d035c5e0313630.jpg?v='1732671119118'"/></div>

To create the graph, execute each of the following UQL queries sequentially in an empty graphset:

```uql
create().edge_property(@default, "weight", int32)
insert().into(@default).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}])
insert().into(@default).edges([{_from:"A", _to:"C", weight:1}, {_from:"E", _to:"B", weight:1}, {_from:"A", _to:"E", weight:4}, {_from:"D", _to:"C", weight:2}, {_from:"E", _to:"D", weight:3}, {_from:"B", _to:"A", weight:2}, {_from:"F", _to:"A", weight:4}])
```

## Finding Paths of Varying Depths

### Within N Steps

To find paths within 3 steps between nodes `A`, `C` and nodes `D`, `E`:

```uql
autonet().src({_id in ["A", "C"]}).dest({_id in ["D", "E"]}).depth(:3) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19715' drawio-name="draw_124c6417f5b74aa1a0f900b06071b944.jpg"><img src="https://img.ultipa.cn/draw/draw_124c6417f5b74aa1a0f900b06071b944.jpg?v='1733795829473'"/></div>

### Exact N Steps

To find paths with exact 3 steps between nodes `A`, `C` and nodes `D`, `E`:

```uql
autonet().src({_id in ["A", "C"]}).dest({_id in ["D", "E"]}).depth(3) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19717' drawio-name="draw_06f48ac56c20485883da2532232e0a7c.jpg"><img src="https://img.ultipa.cn/draw/draw_06f48ac56c20485883da2532232e0a7c.jpg?v='1733796391028'"/></div>

### Within N to M Steps

To find paths with 2 to 3 steps between nodes `A`, `C` and nodes `D`, `E`:

```uql
autonet().src({_id in ["A", "C"]}).dest({_id in ["D", "E"]}).depth(2:3) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19718' drawio-name="draw_f7cf303c54f043f9a937b257916b2be9.jpg"><img src="https://img.ultipa.cn/draw/draw_f7cf303c54f043f9a937b257916b2be9.jpg?v='1733797168212'"/></div>

## Finding Unweighted Shortest Paths

To find the shortest paths within 5 steps between node `A` and node `D`:

```uql
autonet().src({_id == "A"}).dest({_id == "D"}).depth(5).shortest() as p
return p
```

Result: `p`

<div align=center drawio-diagram='19719' drawio-name="draw_9052dc633c4e4e2da4a4e3f342910d35.jpg"><img src="https://img.ultipa.cn/draw/draw_9052dc633c4e4e2da4a4e3f342910d35.jpg?v='1733797352368'"/></div>

## Finding Weighted Shortest Paths

To find the shortest paths weighted by the property `@default.weight` within 5 steps between node `A` and node `D`, and compute the total weight of the paths:

```uql
autonet().src({_id == "A"}).dest({_id == "D"}).depth(5).shortest(@default.weight) as p
call {
  with p
  uncollect pedges(p) as edges
  return sum(edges.weight) as weights
}
return p, weights
```

Result:

| p | <div table-width=12>weights</div> |
| -- | -- |
| <div align=center drawio-diagram='19721' drawio-name='draw_a29dcddc74194c069c9d6a4943db21a0.jpg'><img src="https://img.ultipa.cn/draw/draw_a29dcddc74194c069c9d6a4943db21a0.jpg?v='1733797863932'"/></div> | 3 |

## Filtering Intermediate Nodes

To find paths within 5 steps between node `F` and nodes `E` without passing through node `D`:

```uql
autonet().src({_id == "F"}).dest({_id == "E"}).depth(:5).node_filter({_id != "D"}) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19722' drawio-name='draw_2ae47ae831304ccdb8bf53a4789b5bfc.jpg'><img src="https://img.ultipa.cn/draw/draw_2ae47ae831304ccdb8bf53a4789b5bfc.jpg?v='1733798325429'"/></div>

## Filtering Edges

To find paths within 3 steps between node `A` and node `E`, where the property `weight` of each edge is greater than 1:

```uql
autonet().src({_id == "A"}).dest({_id == "E"}).depth(:3).edge_filter({weight > 1}) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19723' drawio-name='draw_e4286cf7ce584b12832910d1ad497acb.jpg'><img src="https://img.ultipa.cn/draw/draw_e4286cf7ce584b12832910d1ad497acb.jpg?v='1733798468670'"/></div>

## Setting Ascending or Descending Edge Property Values

To find paths within 3 steps between node `A` to node `E`, where the property `@default.weight` values ascend along the path:

```uql
autonet().src({_id == "A"}).dest({_id == "E"}).depth(:3).path_ascend(@default.weight) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19724' drawio-name='draw_6ff225df169e4097b2054c1f52414a74.jpg'><img src="https://img.ultipa.cn/draw/draw_6ff225df169e4097b2054c1f52414a74.jpg?v='1733798782971'"/></div>

To find paths within 3 steps between node `A` to node `E`, where the property `@default.weight` values descend along the path:

```uql
autonet().src({_id == "A"}).dest({_id == "E"}).depth(:3).path_descend(@default.weight) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19725' drawio-name='draw_f2222ca368a749f09c827297c7565c96.jpg'><img src="https://img.ultipa.cn/draw/draw_f2222ca368a749f09c827297c7565c96.jpg?v='1733799045274'"/></div>

## Setting Edge Directions

To find paths within 2 to 4 steps between nodes `A`, `C` and node `E` with all edges pointing to the left:

```uql
autonet().src({_id in ["A", "C"]}).dest({_id == "E"}).depth(2:3).direction(left) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19726' drawio-name='draw_c4aa1415e4e64b43a6e3fab6460b92d4.jpg'><img src="https://img.ultipa.cn/draw/draw_c4aa1415e4e64b43a6e3fab6460b92d4.jpg?v='1733799391851'"/></div>

## Excluding Circles

To find paths with exact 4 steps between node `A` and `E` without any circles:

```uql
autonet().src({_id == "A"}).dest({_id == "C"}).depth(4).no_circle() as p
return p
```

Result: `p`

<div align=center drawio-diagram='19727' drawio-name='draw_f5293908485649b68a773446d324ec83.jpg'><img src="https://img.ultipa.cn/draw/draw_f5293908485649b68a773446d324ec83.jpg?v='1733799621052'"/></div>

Without the `no_circle()` method, three paths will be returned:

```uql
autonet().src({_id == "A"}).dest({_id == "C"}).depth(4) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19728' drawio-name="draw_5492cd914ea04670b935b12cfef16994.jpg"><img src="https://img.ultipa.cn/draw/draw_5492cd914ea04670b935b12cfef16994.jpg?v='1733800141469'"/></div>

## Using limit()

To find paths within 3 steps between nodes `A`, `C` and node `E`, return only one path for each node pair:

```uql
autonet().src({_id in ["A", "C"]}).dest({_id == "E"}).depth(:3).limit(1) as p
return p{*}
```

Result: `p`

<div align=center drawio-diagram='19729' drawio-name='draw_14ff77fe6f794bc099a9f60007c0ad08.jpg'><img src="https://img.ultipa.cn/draw/draw_14ff77fe6f794bc099a9f60007c0ad08.jpg?v='1733800722881'"/></div>

## Using OPTIONAL

In this query, the `autonet()` statement executes two times, each time using one record from `n`. With the `OPTIONAL` prefix, the query returns `null` if no result is found during execution:

```uql
find().nodes({_id in ["A","C"]}) as n
optional autonet().src(n).dest({_id == "D"}).depth(1) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19730' drawio-name='draw_adfda973866545288fbaa7b693b2edcd.jpg'><img src="https://img.ultipa.cn/draw/draw_adfda973866545288fbaa7b693b2edcd.jpg?v='1733800986581'"/></div>

Without the prefix `OPTIONAL`, only one record is returned:

```uql
find().nodes({_id in ["A","C"]}) as n
autonet().src(n).dest({_id == "D"}).depth(1) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19731' drawio-name='draw_80a935c58f1348689cc93bd287553483.jpg'><img src="https://img.ultipa.cn/draw/draw_80a935c58f1348689cc93bd287553483.jpg?v='1733801128783'"/></div>
