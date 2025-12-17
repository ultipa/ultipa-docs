# Triangle Counting

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stats</b></span></div>

## Overview

The Triangle Counting algorithm identifies triangles in a graph, where a triangle represents a set of three nodes that are connected to each other. Triangles are important in graph analysis as they reflect the presence of loops or strong connectivity patterns within the graph. 

Triangles in social networks indicate the presence of cohesive communities. Identifying triangles helps in understanding the clustering and interconnectedness of individuals or groups within the network. In financial networks or transaction networks, the presence of triangles can be indicative of suspicious or fraudulent activities. Triangle counting can help identify patterns of collusion or interconnected transactions that might require further investigation.

## Concepts

### Triangle

In a complex graph, it is possible for multiple edges to exist between two nodes. This can lead to the formation of more than one triangle involving three nodes. Take the graph below as an example:

- Counting triangles assembled by <b>edges</b>, there are 4 different triangles. 
- Counting triangles assembled by <b>nodes</b>, there are 2 different triangles. 

<div align=center drawio-diagram='6058' drawio-name="draw_ec968583a26b4b3f8924e5b3288adeda.jpg"><img src="https://img.ultipa.cn/draw/draw_ec968583a26b4b3f8924e5b3288adeda.jpg?v='1685431709519'"/></div>

The number of triangles assembled by edges tends to be greater than those assembled by nodes in complex graph. The choice of assembly principle should align with the objectives of the analysis and the insights sought from the graph data. In social network analysis, where the focus is often on understanding connectivity patterns among individuals, the assembling by node principle is commonly adopted. In financial network analysis or other similar domains, the assembling by edge principle is often preferred. Here, the emphasis is on the relationships between nodes, such as financial transactions or interactions. Assembling triangles based on edges allows for the examination of how tightly nodes are connected and how funds or information flow through the network. 

## Considerations

- The Triangle Counting algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(triangle_counting)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="7">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| type | int | `1`, `2` | `1` | Yes | `1` to assemble triangles by edges, `2` to assemble triangles by nodes |
| result_type | int | `1`, `2` | `1` | Yes | `1` to return the number of triangles, `2` to return triangles in the form of nodes or edges |
| limit | int |	≥-1	| `-1` | Yes | Number of results to return, `-1` to return all results

## Examples

The example graph is as follows:

<div align='center' drawio-diagram='6059' drawio-name="draw_c2bcc65029194100ba8e9c4e73d8fad9.jpg"><img src="https://img.ultipa.cn/draw/draw_c2bcc65029194100ba8e9c4e73d8fad9.jpg?v='1685436315790'"/></div>

### File Writeback

| <div table-width="13">Spec</div> | Content |
| --- | --- |
| filename | `edge1`,`edge2`,`edge3` or `node1`,`node2`,`node3` |

```js
algo(triangle_counting).params({
  type: 1,
  result_type: 2
}).write({
  file:{
    filename: "te"
}})
```

Statistics: triangle_count = 3<br>
Results: File <i>te</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
103,104,101
103,104,102
105,104,106
```

```js
algo(triangle_counting).params({
  type: 2,
  result_type: 2
}).write({
  file:{
    filename: "tn"
}})
```

Statistics: triangle_count = 2<br>
Results: Files <i>tn</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
C4,C2,C1
C3,C2,C1
```

### Direct Return

| <div table-width="8">Alias Ordinal</div> | <div table-width="13">Type</div> | Description | Columns |
| --- | --- | --- | --- |
| 0 | KV or []perTriangle | Number of triangles or triangles | `triangle_count` or `edge1`, `edge2`, `edge3` or `node1`, `node2`, `node3` |

```js
algo(triangle_counting).params({
  result_type: 1
}) as count 
return count
```

Results: <i>count</i>

| triangle_count |
| -- |
| 3 |

```js
algo(triangle_counting).params({
  result_type: 2
}) as triangles 
return triangles
```

Results: <i>triangles</i>

| edge1 | edge2 | edge3 |
| -- | -- | -- |
| 103 | 104 | 101 |
| 103 | 104 | 102 |
| 105 | 104 | 106 |

### Stream Return

| <div table-width="8">Alias Ordinal</div> | <div table-width="13">Type</div> | Description | Columns |
| --- | --- | --- | --- |
| 0 | KV or []perTriangle | Number of triangles or triangles | `triangle_count` or `edge1`, `edge2`, `edge3` or `node1`, `node2`, `node3` |

```js
algo(triangle_counting).params({
  type: 2, 
  result_type:2 
}).stream() as t
call {
  with t
  find().nodes({_uuid in [t.node1, t.node2, t.node3]}) as nodes
  return sum(nodes.amount) as sumAmount
}
return table(t.node1, t.node2, t.node3, sumAmount)
```

Results: <i>table(t.node1, t.node2, t.node3, sumAmount)</i>

| t.node1 | t.node2 | t.node3 | sumAmount |
| -- | -- | -- | -- |
| 4 | 2 | 1 | 12 |
| 3 | 2 | 1 | 9 |

```js
algo(triangle_counting).params({
  type: 2, 
  result_type:1
}).stream() as tNodes 
algo(triangle_counting).params({
  type: 1, 
  result_type:1
}).stream() as tEdges
return table(tNodes.triangle_count, tEdges.triangle_count)
```

Results: <i>table(tNodes.triangle_count, tEdges.triangle_count)</i>

| tNodes.triangle_count | tEdges.triangle_count |
| -- | -- |
| 2 | 3 |

### Stats Return

| Alias Ordinal | Type | <div table-width="25">Description</div> | <div table-width="30">Columns</div> |
| --- | --- | --- | --- |
| 0 | KV | Number of triangles | `triangle_count` |

```js
algo(triangle_counting).params({
  result_type: 1
}).stats() as sta 
return sta
```

Results: <i>sta</i>

| triangle_count |
| -- |
| 3 |