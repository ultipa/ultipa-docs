# Spread

## Overview

The `spread().src().depth()` statement performs a breadth first search (BFS), spreading outward from each traversal source. It retrieves one-step paths from the traversal source, layer by layer, expanding to its neighbors in order of increasing depth.

<div align=center drawio-diagram='19571' drawio-name="draw_d2f29a5274ff48b58586f0fea2ccdd1c.jpg"><img src="https://img.ultipa.cn/draw/draw_d2f29a5274ff48b58586f0fea2ccdd1c.jpg?v='1732586548461'"/></div>

This illustrates the process of spreading from a traversal source (represented as the red node). At each `k`-step:

- It identifies one-step paths between the `k-1` hop neighbors (which correspond to the traversal source at `k = 1`) and the `k` hop neighbors of the traversal source.
- Simultaneously, it discovers one-step paths between the `k` hop neighbors themselves, including self-loops on the `k` hop neighbors.
- Specifically, self-loops on the traversal source are identified at step 1.

## Syntax

<p tit="Syntax"></p>

```uql
spread().src(<filter?>).depth(<steps>)
```

- **Statement alias:** Type `PATH`<br>
- **Methods:**

| <div table-width=15>Method</div> | <div table-width=14>Param</div> | Description | <div table-width=9>Optional</div> | <div table-width=8>Alias Type</div> |
| -- | -- | -- | -- | -- |
| `src()` | `<filter?>` | The filtering condition enclosed in `{}`, or an alias to specify the set of nodes as traversal sources. Leaving it blank will target all nodes. | No | `NODE` |
| `depth()` | `<steps>` | The maximum number of steps (≥1) to spread. | No | N/A |
| `node_filter()` | `<filter?>` | The filtering condition enclosed in `{}` for all nodes other than the traversal sources in the paths. Leaving it blank applies no restriction. | Yes | N/A |
| `edge_filter()` | `<filter?>` | The filtering condition enclosed in `{}` for edges in the paths. Leaving it blank applies no restriction. | Yes | N/A |
| `direction()` | `<leftRight>` | Specifies the direction of edges to traverse when spreading outward, which can be `left` or `right`. | Yes | N/A |
| `limit()` | `<N>` | Limits the number of paths (`N`≥-1) returned for each traversal source; `-1` includes all paths. | Yes | N/A |

## Example Graph

<div align=center drawio-diagram='19569' drawio-name="draw_35102d99ce63496e94ce7b17e84a9342.jpg"><img src="https://img.ultipa.cn/draw/draw_35102d99ce63496e94ce7b17e84a9342.jpg?v='1732614996612'"/></div>

To create the graph, execute each of the following UQL queries sequentially in an empty graphset:

```uql
create().edge_property(@default, "weight", int32)
insert().into(@default).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}, {_id:"G"}])
insert().into(@default).edges([{_from:"A", _to:"C", weight:1}, {_from:"E", _to:"B", weight:1}, {_from:"A", _to:"E", weight:4}, {_from:"D", _to:"C", weight:2}, {_from:"E", _to:"D", weight:3}, {_from:"B", _to:"A", weight:2}, {_from:"F", _to:"A", weight:4}])
```

## Spreading From Nodes

To spread from node `B` with 1 step:

```uql
spread().src({_id == "B"}).depth(1) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19745' drawio-name="draw_39247f1ff5a84adc9c719c31d5f4d435.jpg"><img src="https://img.ultipa.cn/draw/draw_39247f1ff5a84adc9c719c31d5f4d435.jpg?v='1733887969760'"/></div>

To spread from node `B` with 2 steps:

```uql
spread().src({_id == "B"}).depth(2) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19746' drawio-name="draw_555f075a3352474583cf135ca12eb394.jpg"><img src="https://img.ultipa.cn/draw/draw_555f075a3352474583cf135ca12eb394.jpg?v='1733888285568'"/></div>

## Filtering Neighbor Nodes

To spread from node `D` with 2 steps while excluding node `E`:

```uql
spread().src({_id == "D"}).depth(2).node_filter({_id != "E"}) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19747' drawio-name="draw_5ae59e56359641018b582265da5325ef.jpg"><img src="https://img.ultipa.cn/draw/draw_5ae59e56359641018b582265da5325ef.jpg?v='1733888746844'"/></div>

When node `E` is excluded, it is equivalent to removing node `E` and all its connected edges from the graph.

## Filtering Edges

To spread from nodes `A`, `B` with 2 steps, while only traversing edges where the `weight` exceeds 1:

```uql
spread().src({_id in ["A", "B"]}).depth(2).edge_filter({weight > 1}) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19748' drawio-name="draw_254029fd07ea44eba9ada79cbcb59615.jpg"><img src="https://img.ultipa.cn/draw/draw_254029fd07ea44eba9ada79cbcb59615.jpg?v='1733886994830'"/></div>

When edges with a `weight` below 1 are excluded, it is equivalent to removing those edges from the graph.

## Setting Spreading Direction

To spread from node `B` with 2 steps through outgoing edges:

```uql
spread().src({_id == "B"}).depth(2).direction(right) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19749' drawio-name='draw_d7094a418ee84bc79ad928ea784e4478.jpg'><img src="https://img.ultipa.cn/draw/draw_d7094a418ee84bc79ad928ea784e4478.jpg?v='1733889198862'"/></div>

To spread from node `B` with 2 steps through incoming edges:

```uql
spread().src({_id == "B"}).depth(2).direction(left) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19750' drawio-name='draw_8f7f86266b354af7bc32e6849f0fc322.jpg'><img src="https://img.ultipa.cn/draw/draw_8f7f86266b354af7bc32e6849f0fc322.jpg?v='1733889408612'"/></div>

Although the results returned by the `spread()` statement are in the form of outgoing one-step paths, the `direction()` method constrains the search direction from nearer nodes to farther nodes.

## Using limit()

To spread from nodes `A`, `D` with 2 steps, return only two paths for each traversal source:

```uql
spread().src({_id in ["A", "D"]}).depth(2).limit(2) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19751' drawio-name='draw_7084cf173fb14661921969d000a96c43.jpg'><img src="https://img.ultipa.cn/draw/draw_7084cf173fb14661921969d000a96c43.jpg?v='1733889862189'"/></div>

Due to the BFS nature of spreading, paths with shallower depths are returned first.

## Using OPTIONAL

In this query, the `spread()` statement executes two times, each time using one record from `n`. With the `OPTIONAL` prefix, the query returns `null` if no result is found during execution:

```uql
find().nodes({_id in ["F", "G"]}) as n
OPTIONAL spread().src(n).depth(1) as p
return p
```

Result: `p`

<div align=center drawio-diagram='19752' drawio-name="draw_c6b9469ccd8947bbbc464350267aa479.jpg"><img src="https://img.ultipa.cn/draw/draw_c6b9469ccd8947bbbc464350267aa479.jpg?v='1733890505795'"/></div>

Without the prefix `OPTIONAL`, only one record is returned:

```uql
find().nodes({_id in ["F", "G"]}) as n
spread().src(n).depth(1) as p
return p
```

Result: p

<div align=center drawio-diagram='19753' drawio-name='draw_fad6f7f55d7b4f4f9aa0dcad9f81a8e4.jpg'><img src="https://img.ultipa.cn/draw/draw_fad6f7f55d7b4f4f9aa0dcad9f81a8e4.jpg?v='1733890662504'"/></div>
