# UNCOLLECT

## Overview

The `UNCOLLECT` statement transforms elements in a list into individual records.

<div align=center drawio-diagram='19647' drawio-name="draw_b29c8aeff25f4a4a9ee13f917eff8bf8.jpg"><img src="https://img.ultipa.cn/draw/draw_b29c8aeff25f4a4a9ee13f917eff8bf8.jpg?v='1733198954735'"/></div>

## Syntax

<p tit="Syntax"></p>

```uql
UNCOLLECT <listExp> as <alias>
```

**Details**

- The `<listExp>` is an expression that represents or produces data of the `list` type.
- An `<alias>` is mandatory to represent the data uncollected.

## Example Graph

<div align=center drawio-diagram='19648' drawio-name='draw_3f9344f207da499b8002d43478454333.jpg'><img src="https://img.ultipa.cn/draw/draw_3f9344f207da499b8002d43478454333.jpg?v='1733199570408'"/></div>

To create the graph, execute each of the following UQL queries sequentially in an empty graphset:

```uql
create().edge_property(@default, "weight", int32)
insert().into(@default).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}])
insert().into(@default).edges([{_from:"A", _to:"C", weight:1}, {_from:"E", _to:"B", weight:1}, {_from:"A", _to:"E", weight:4}, {_from:"D", _to:"C", weight:2}, {_from:"E", _to:"D", weight:3}, {_from:"B", _to:"A", weight:2}, {_from:"F", _to:"A", weight:4}])
```

## Uncollecting a List

```uql
uncollect [1,1,2,3,null] as item
return item
```

Result:

| item |
| -- |
| 1 |
| 1 |
| 2 |
| 3 |
| `null` |

```uql
uncollect [[1,2], [2,3,5]] as item
return item
```

Result:

| item |
| -- |
| [1,2] |
| [2,3,5] |

## Uncollecting Node/Edge Lists

The `pnodes()` or `pedges()` function collects nodes or edges in a path into a list.

```uql
n({_id == "A"}).e()[2].n({_id == "D"}) as p
call {
  with p
  uncollect pedges(p) as edges
  return sum(edges.weight) as totalWeights
}
return totalWeights
```

Result:

| totalWeights |
| -- |
| 3 |
| 7 |
