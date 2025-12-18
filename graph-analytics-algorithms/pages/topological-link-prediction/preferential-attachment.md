# Preferential Attachment

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

Preferential attachment is a common phenomenon in complex networks, where nodes with more existing connections are more likely to attract new ones. When both nodes have a large number of connections, the probability of them forming a connection is significantly higher. This phenomenon was utilized by A. Barabási and R. Albert in their proposed BA model for generating random scale-free networks in 2002:

- R. Albert, A. Barabási, <a href="https://arxiv.org/pdf/cond-mat/0106096.pdf" target="_blank">Statistical mechanics of complex networks</a> (2001)

The Preferential Attachment algorithm measures the similarity between two nodes by multiplying the number of neighbors each node has. It is computed using the following formula:

<center><img width="240" src="https://img.ultipa.cn/2022-08-10-09-24-26-PA.jpg"></center>

where <i>N(x)</i> and <i>N(y)</i> are the sets of adjacent nodes to nodes <i>x</i> and <i>y</i> respectively. 

Higher Preferential Attachment scores indicate a greater similarity between two nodes, while a score of 0 indicates no such similarity.

<div align=center drawio-diagram='6589' drawio-name='draw_4b46a0b60fa141698093b656f3600ea2.jpg'><img src="https://img.ultipa.cn/draw/draw_4b46a0b60fa141698093b656f3600ea2.jpg?v='1691983066684'"/></div>

In this example, PA(D,E) = |N(D)| * |N(E)| = |{B, C, E, F}| * |{B, D, F}| = 4 * 3 = 12.

## Considerations

- The Preferential Attachment algorithm treats all edges as undirected, ignoring their original direction.

## Example Graph

<div align=center drawio-diagram='19979' drawio-name='draw_61c75b80d2e043f492eab4e1a3065a46.jpg'><img src="https://img.ultipa.cn/draw/draw_61c75b80d2e043f492eab4e1a3065a46.jpg?v='1735032400364'"/></div>

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
       (A)-[:default]->(B),
       (B)-[:default]->(E),
       (C)-[:default]->(B),
       (C)-[:default]->(D),
       (C)-[:default]->(F),
       (D)-[:default]->(B),
       (D)-[:default]->(E),
       (F)-[:default]->(D),
       (F)-[:default]->(G);
```

```uql
insert().into(@default).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}, {_id:"G"}]);
insert().into(@default).edges([{_from:"A", _to:"B"}, {_from:"B", _to:"E"}, {_from:"C", _to:"B"}, {_from:"C", _to:"D"}, {_from:"C", _to:"F"}, {_from:"D", _to:"B"}, {_from:"D", _to:"E"}, {_from:"F", _to:"D"}, {_from:"F", _to:"G"}]);
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

Algorithm name: `topological_link_prediction`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | []`_id` | / | / | No | Specifies the first group of nodes for computation by their `_id`. If unset, all nodes in the graph are used as the first group of nodes. |
| `uuids` | []`_uuid` | / | / | No | Specifies the first group of nodes for computation by their `_uuid`. If unset, all nodes in the graph are used as the first group of nodes. |
| `ids2` | []`_id` | / | / | No | Specifies the second group of nodes for computation by their `_id`. If unset, all nodes in the graph are used as the second group of nodes. |
| `uuids2` | []`_uuid` | / | / | No | Specifies the second group of nodes for computation by their `_uuid`. If unset, all nodes in the graph are used as the second group of nodes. |
| `type` | String | `Preferential_Attachment` | `Adamic_Adar` | No | Specifies the similarity type; for Preferential Attachment, keep it as `Preferential_Attachment`. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results.|

## File Writeback

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.write("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A","E","G"],
  type: "Preferential_Attachment",
  return_id_uuid: "id"
}, {
  file: {
    filename: "pa"
  }
})
```

```uql
algo(topological_link_prediction).params({
  projection: "my_hdc_graph",
  ids: ["C"],
  ids2: ["A","E","G"],
  type: "Preferential_Attachment",
  return_id_uuid: "id"
}).write({
  file: {
    filename: "pa"
  }
})
```

</div>

Result:

<p tit="File: pa"></p>

```
_id1,_id2,result
C,A,3
C,E,6
C,G,3
```

## Full Return

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.run("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A","C","E","G"],
  type: "Preferential_Attachment",
  return_id_uuid: "id"
}) YIELD pa
RETURN pa
```

```uql
exec{
  algo(topological_link_prediction).params({
    ids: ["C"],
    ids2: ["A","C","E","G"],
    type: "Preferential_Attachment",
    return_id_uuid: "id"
  }) as pa
  return pa
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | result |
| -- | -- | -- |
| C | A | 3 |
| C | E | 6 |
| C | G | 3 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.stream("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A", "B", "D", "E", "F", "G"],
  type: "Preferential_Attachment",
  return_id_uuid: "id"
}) YIELD pa
FILTER pa.result >= 6
RETURN pa
```

```uql
exec{
  algo(topological_link_prediction).params({
    ids: ["C"],
    ids2: ["A", "B", "D", "E", "F", "G"],
    type: "Preferential_Attachment",
    return_id_uuid: "id"
  }).stream() as pa
  where pa.result >= 6
  return pa
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | result |
| -- | -- | -- |
| C | B | 12 |
| C | D | 12 |
| C | E | 6 |
| C | F | 9 |
