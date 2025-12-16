# Minimum Spanning Tree

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The Minimum Spanning Tree (MST) algorithm computes the spanning tree with the minimum sum of edge weights for each connected component in a graph.

The MST has various applications, such as network design, clustering, and optimization problems where minimizing the total cost or weight is important.

## Concepts

### Spanning Tree

A spanning tree is a connected subgraph that all nodes of a connected graph <i>G= = (V, E)</i> (or a connected component) and forms a tree (i.e., no circles). There may exist multiple spanning trees for a graph, and each spanning tree must have (|V| - 1) edges.

The 11 nodes in the graph below, along with the 10 edges highlighted in red, form a spanning tree of this graph:

<div align=center drawio-diagram='6362' drawio-name="draw_0c34b3642e464fc8a2a536844032f142.jpg"><img src="https://img.ultipa.cn/draw/draw_0c34b3642e464fc8a2a536844032f142.jpg?v='1689661402106'"/></div>

### Minimum Spanning Tree (MST)

The MST is the spanning tree that has the minimum sum of edge weights. The construction of the MST starts from a given start node. The choice of the start node does not impact the correctness of the MST algorithm, but it can affect the structure of the MST and the order in which edges are added. Different start nodes may result in different MSTs, but all of them will be valid MSTs for the given graph.

After assigning edge weights to the above example, the three possible MSTs with different start nodes are highlighted in red below:

<div align=center drawio-diagram='6363' drawio-name="draw_f328b3c4a99c4bf8a075d69897400c50.jpg"><img src="https://img.ultipa.cn/draw/draw_f328b3c4a99c4bf8a075d69897400c50.jpg?v='1689661304468'"/></div>

Regarding the selection of start nodes:

- Each connected component requires only one start node. If multiple start nodes are specified, the first one will be considered valid.
- No MST will be computed for connected components that do not have a specified start node.
- Isolated nodes are not considered valid start nodes for computing the MST.

<div align=center drawio-diagram='2233' drawio-name="draw_720492664e30472299567955274233dd.jpg"><img src="https://img.ultipa.cn/draw/draw_720492664e30472299567955274233dd.jpg?v='1689661829537'"/></div>

## Considerations

- The MST algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(mst)`
- Parameters:

| <div table-width="15">Name</div> | <div table-width="8">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | Yes | ID/UUID of the start nodes; the system chooses the start node for each connected component if not set |
| edge_schema_property | []`@<schema>?.<property>` | Numeric type, must LTE | / | No | Edge properties to use as weights; for each edge, the specified property with the smallest value is considered as its weight; edges without any specified property will not be included in any MST |
| limit | int |	≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Examples

The example graph is as below, node <i>A</i> is an electric center, node <i>B~H</i> are the surrounding villages. Each edge is labeled with its UUID and the distance between the connected locations, which represents the required cable length:

<div align=center drawio-diagram='6364' drawio-name='draw_6300a3807703469db1464b17f1507fca.jpg'><img src="https://img.ultipa.cn/draw/draw_6300a3807703469db1464b17f1507fca.jpg?v='1689665496141'"/></div>

### File Writeback

| <div table-width="15">Spec</div> | <div table-width="20">Content</div> | Description |
| --- | --- | --- |
| filename | `_id--[_uuid]--_id` | One-step path in the MST:<br>(start node)--(edge)--(end node) |

```js
algo(mst).params({
  uuids: [1],
  edge_schema_property: 'distance'
}).write({
  file:{
    filename: 'solution'
    }
})
```

Results: File <i>solution</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
A--[107]--H
A--[108]--E
E--[111]--G
F--[113]--G
A--[101]--B
A--[104]--D
C--[103]--D
```

### Direct Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="10">Type</div> | Description |
| --- | --- | --- |
| 0 | []path | One-step path in the MST: <br>`_uuid` (start node) -- [`_uuid`] (edge) -- `_uuid` (end node) |

```js
algo(mst).params({
  ids: 'A',
  edge_schema_property: '@connect.distance'
}) as mst 
return mst
```

Results: <i>mst</i>

<table>
<tr><td>1--[107]--8</td></tr>
<tr><td>1--[108]--5</td></tr>
<tr><td>5--[111]--7</td></tr>
<tr><td>6--[113]--7</td></tr>
<tr><td>1--[101]--2</td></tr>
<tr><td>1--[104]--4</td></tr>
<tr><td>3--[103]--4</td></tr>
</table>

### Stream Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="10">Type</div> | Description |
| --- | --- | --- |
| 0 | []path | One-step path in the MST: <br>`_uuid` (start node) -- [`_uuid`] (edge) -- `_uuid` (end node) |

```js
algo(mst).params({
  uuids: [1],
  edge_schema_property: 'distance'
}).stream() as mst
with pedges(mst) as mstUUID
find().edges(mstUUID) as edges
return sum(edges.distance)
```

