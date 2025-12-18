# p-Cohesion

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

The p-Cohesion algorithm identifies groups of network players (nodes) that are highly connected with each other, represented by cohesive subgraphs. It reveals the level of connectivity and interdependence within these groups, supporting in-depth analysis of  graph structure and behavior. 

The concept of p-cohesion was first proposed by S. Morris in a contagion model describing interactions within large populations:

- S. Morris, <a target='blank' href="http://snap.stanford.edu/class/cs224w-readings/morris98contagion.pdf">Contagion</a>. The Review of Economic Studies, 67(1), 57–78 (2000)

## Concepts

### p-Cohesion

One natural measure of the 'cohesion' of a group is the relative frequency of ties among its members compared to non-members. Let cohesion be a constant <i>p</i> ∈ (0,1). A <b>p-Cohesion</b> is a connected subgraph in which every node has, at least, a proportion <i>p</i> of its neighbors within the subgraph. In other words, each node has at most, a proportion <i>(1 − p)</i> of its neighbors outside the subgraph. 

The p-Cohesion model offers two key advantages over other cohesive subgraph models:
- With a high <i>p</i> value, p-Cohesion ensures both strong internal cohesiveness and sparse connections to outside nodes. 
- It considers the proportion of neighbors within the group rather than a fixed number (such as the <i>k</i> value in <a target="_blank" href="https://www.ultipa.cn/document/graph-analytics-algorithms/k-core">k-Core</a>), making it better suited for graphs with varying node degrees. 

The example graph below illustrates this. Suppose <i>p</i> = 0.6. A grey label next to each node shows the minimum number of internal neighbors required for the node to remain in a p-Cohesion.

<div align='center' drawio-diagram='6166' drawio-name="draw_ffcc9719bb274bcfbf8e12a701061851.jpg"><img src="https://img.ultipa.cn/draw/draw_ffcc9719bb274bcfbf8e12a701061851.jpg?v='1686797368509'"/></div>

Below are the minimal p-Cohesion subgraphs, in terms of node count, that include node <i>a</i> and node <i>j</i>, respectively.

<div align='center' drawio-diagram='6168' drawio-name="draw_78908f02c70f425bacaa4146c8f0687d.jpg"><img src="https://img.ultipa.cn/draw/draw_78908f02c70f425bacaa4146c8f0687d.jpg?v='1687921148878'"/></div>

Ultipa's p-Cohesion algorithm returns an approximate minimal p-Cohesion subgraph for each query node, represented as a set of nodes.

## Considerations

- The p-Cohesion algorithm treats all edges as undirected, ignoring their original direction.

## Example Graph

<div align='center' drawio-diagram='6236' drawio-name='draw_8154c0855e72495cb96b11dc28dd52c1.jpg'><img src="https://img.ultipa.cn/draw/draw_8154c0855e72495cb96b11dc28dd52c1.jpg?v='1687920551178'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
INSERT (A:default {_id: "A"}),
       (B:default {_id: "B"}),
       (C:default {_id: "C"}),
       (D:default {_id: "D"}),
       (E:default {_id: "E"}),
       (F:default {_id: "F"}),
       (G:default {_id: "G"}),
       (H:default {_id: "H"}),
       (I:default {_id: "I"}),
       (J:default {_id: "J"}),
       (K:default {_id: "K"}),
       (L:default {_id: "L"}),
       (K)-[:default]->(J),
       (K)-[:default]->(L),
       (J)-[:default]->(L),
       (L)-[:default]->(C),
       (C)-[:default]->(A),
       (A)-[:default]->(B),
       (C)-[:default]->(B),
       (A)-[:default]->(D),
       (B)-[:default]->(G),
       (B)-[:default]->(D),
       (D)-[:default]->(C),
       (C)-[:default]->(E),
       (C)-[:default]->(F),
       (D)-[:default]->(E),
       (E)-[:default]->(F),
       (D)-[:default]->(F),
       (D)-[:default]->(H),
       (I)-[:default]->(H),
       (F)-[:default]->(I);
```

```uql
insert().into(@default).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}, {_id:"G"}, {_id:"H"}, {_id:"I"}, {_id:"J"}, {_id:"K"}, {_id:"L"}]);
insert().into(@default).edges([{_from:"K", _to:"J"}, {_from:"K", _to:"L"}, {_from:"J", _to:"L"}, {_from:"L", _to:"C"}, {_from:"C", _to:"A"}, {_from:"A", _to:"B"}, {_from:"C", _to:"B"}, {_from:"A", _to:"D"}, {_from:"B", _to:"G"}, {_from:"B", _to:"D"}, {_from:"D", _to:"C"}, {_from:"C", _to:"E"}, {_from:"C", _to:"F"}, {_from:"D", _to:"E"}, {_from:"E", _to:"F"}, {_from:"D", _to:"F"}, {_from:"D", _to:"H"}, {_from:"I", _to:"H"}, {_from:"F", _to:"I"}]);
```

</div>

## Creating HDC Graph

To load the entire graph to the HDC server `hdc-server-1` as `my_hdc_graph`:

<div tab="code">
  
```gql
CREATE HDC GRAPH my_hdc_graph ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}
```

```uql
hdc.graph.create("my_hdc_graph", {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}).to("hdc-server-1")
```

</div>

## Parameters

Algorithm name: `p_cohesion`

| <div table-width="17">Name</div> | <div table-width="9">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | []`_id` | / | / | Yes | Specifies each node by its `_id` to find the approximate minimal p-cohesions that include it. If unset, specifies all nodes. |
| `uuids` | []`_uuid` | / | / | Yes | Specifies each node by its `_uuid` to find the approximate minimal p-cohesions that include it. If unset, specifies all nodes. |
| `p` | Float | (0,1) | / | No | For each node in a p-cohesion, at least a proportion <i>p</i> of its neighbors are within the p-cohesion, and no more than a proportion <i>(1−p)</i> are outside it. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |

## File Writeback

<div tab="code">
  
```gql
CALL algo.p_cohesion.write("my_hdc_graph", {
  ids: ["A","I"],
  p: 0.7,
  return_id_uuid: "id"
}, {
  file: {
    filename: "cohesion"
  }
})
```

```uql
algo(p_cohesion).params({
  projection: "my_hdc_graph",
  ids: ["A","I"],
  p: 0.7,
  return_id_uuid: "id"
}).write({
  file: {
    filename: "cohesion"
  }
})
```

</div>

Result:

<p tit="File: cohesion"></p>

```
subgraph contains A: D,F,B,A,E,C,
subgraph contains I: I,D,F,H,B,A,E,C,
```

## Stats Writeback

<div tab="code">
  
```gql
CALL algo.p_cohesion.write("my_hdc_graph", {
  ids: ["A","I"],
  p: 0.7,
  return_id_uuid: "id"
}, {
  stats: {}
})
```

```uql
algo(p_cohesion).params({
  projection: "my_hdc_graph",
  ids: ["A","I"],
  p: 0.7,
  return_id_uuid: "id"
}).write({
  stats: {}
})
```

</div>

Result:

| max size of subgraphs |
| -- | 
| 8 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.p_cohesion.stream("my_hdc_graph", {
  ids: ["A","I"],
  p: 0.7,
  return_id_uuid: "id"
}) YIELD s
RETURN s
```

```uql
exec{
  algo(p_cohesion).params({
    ids: ["A","I"],
    p: 0.7,
    return_id_uuid: "id"
  }).stream() as s
  return s
} on my_hdc_graph
```

</div>

Result:

| subgraph contains(id) | \_ids |
| --- | --- |
| A | [D,F,B,A,E,C] |
| I | [D,F,H,B,A,E,C,I]

## Stats Return

<div tab="code">
  
```gql
CALL algo.p_cohesion.stats("my_hdc_graph", {
  ids: ["A","I"],
  p: 0.7
}) YIELD s
RETURN s
```

```uql
exec{
  algo(p_cohesion).params({
    ids: ["A","I"],
    p: 0.7
  }).stats() as s
  return s
} on my_hdc_graph
```

</div>

Result:

| max size of subgraphs |
| --- | 
| 8 |
