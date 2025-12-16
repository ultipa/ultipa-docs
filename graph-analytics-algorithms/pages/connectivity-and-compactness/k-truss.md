# k-Truss

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The k-Truss algorithm identifies the maximal cohesive subgraph called <i>truss</i> in the graph. It has wide-ranging applications across various domains, including social networks, biological networks, and transportation networks. By uncovering communities or clusters of closely related nodes, the k-Truss algorithm provides valuable insights into the structure and connectivity of complex networks.

k-Truss were originally defined by J. Cohen in 2005:

- J. Cohen, <a target='blank' href="https://documents.pub/document/trusses-cohesive-subgraphs-for-social-network-analysis.html">Trusses: Cohesive Subgraphs for Social Network Analysis</a> (2005)

## Concepts

### k-Truss

The truss is motivated by a natural observation of social cohesion: if two people are strongly tied, it is likely that they also share ties to others. <b>k-Truss</b> is thus created in this way: a tie between A and B is considered legitimate only if supported by at least <i>k–2</i> other people who are each tied to A and to B. In other words, each edge in a k-truss joins two nodes that have at least <i>k–2</i> common neighbors. 

The formal definition is, a k-truss is a maximal subgraph in the graph such that each edge is supported by at least <i>k–2</i> pairs of edges making triangles with the that edge. 

The entire graph is shown below, the 3-truss and 4-truss are highlighted in red. This graph does not have truss with 5 or larger value of <i>k</i>.

<div align='center' drawio-diagram='6150' drawio-name="draw_89d92df096414bd69a3e1ed22f6a58a2.jpg"><img src="https://img.ultipa.cn/draw/draw_89d92df096414bd69a3e1ed22f6a58a2.jpg?v='1686712760996'"/></div>

Ultipa's k-Truss algorithm identifies the maximal truss in each connected component.

## Considerations

- At least 3 nodes are contained in a truss (when k≥3).
- In a complex graph where multiple edges can exist between two nodes, the triangles in a truss are counted by edges. Please also refer to the <a href="https://www.ultipa.com/docs/graph-analytics-algorithms/triangle-counting">Triangle Counting</a> algorithm.
- The k-Truss algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(k_truss)`
- Parameters:

| <div table-width="8">Name</div> | <div table-width="7">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| k | int | ≥2 | / | No | Each edge in the k-truss is contained in at least <i>k − 2</i> triangles |

## Examples

The example graph is as follows:

<div align='center' drawio-diagram='6151' drawio-name="draw_1c68121b9ba64d14889a65b9608d5cfb.jpg"><img src="https://img.ultipa.cn/draw/draw_1c68121b9ba64d14889a65b9608d5cfb.jpg?v='1686709939980'"/></div>

### File Writeback

| <div table-width="13">Spec</div> | <div table-width="18">Content</div> | Description |
| --- | --- | --- |
| filename | `_id--[_uuid]--_id` | One-step path in the truss: (start node)--(edge)--(end node) |

```js
algo(k_truss).params({k: 4}).write({
  file:{
      filename: 'truss'
  }
})
```

Results: File <i>truss</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
d--[102]--a
c--[103]--a
d--[104]--c
f--[105]--a
f--[106]--d
d--[107]--f
f--[108]--d
d--[109]--e
e--[110]--f
f--[111]--c
k--[117]--f
k--[119]--l
g--[120]--k
m--[121]--k
i--[122]--f
m--[123]--f
f--[124]--g
g--[125]--m
m--[126]--l
```

### Direct Return

| <div table-width="13">Alias Ordinal</div> | <div table-width="9">Type</div> | Description |
| --- | --- | --- |
| 0 | []`path` | One-step path in the truss: <br>`_uuid` (start node) -- `[_uuid]` (edge) -- `_uuid` (end node) |

```js
algo(k_truss).params({k: 5}) as truss return truss
```

Results: <i>subgraph</i>

<table>
<tr><td>4--[102]--1</td></tr>
<tr><td>4--[104]--3</td></tr>
<tr><td>6--[105]--1</td></tr>
<tr><td>6--[106]--4</td></tr>
<tr><td>4--[107]--6</td></tr>
<tr><td>6--[108]--4</td></tr>
<tr><td>4--[109]--5</td></tr>
<tr><td>5--[110]--6</td></tr>
<tr><td>6--[111]--3</td></tr>
</table>

### Stream Return

| <div table-width="13">Alias Ordinal</div> | <div table-width="9">Type</div> | Description |
| --- | --- | --- |
| 0 | []`path` | One-step path in the truss: <br>`_uuid` (start node) -- `_uuid` (edge) -- `_uuid` (end node) |

```js
algo(k_truss).params({k: 5}).stream() as truss5
with pedges(truss5) as e
find().edges(e) as edges
return edges{*}
```

Results: <i>edges</i>


| \_uuid | \_from | \_to | \_from_uuid | \_to_uuid |
| -- | -- | -- | -- | -- |
| 102 | d | a | 4 | 1 |
| 104 | d | c | 4 | 3 |
| 105 | f | a | 6 | 1 |
| 106 | f | d | 6 | 4 |
| 107 | d | f | 4 | 6 |
| 108 | f | d | 6 | 4 |
| 109 | d | e | 4 | 5 |
| 110 | e | f | 5 | 6 |
