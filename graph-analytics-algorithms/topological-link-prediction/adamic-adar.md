# Adamic-Adar Index

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

The Adamic-Adar Index (AA Index) is a node similarity metric named after its creators Lada Adamic and Eytan Adar. It measures the strength of potential connection between two nodes based on their common neighbors.

- L.A. Adamic, E. Adar, <a href="http://cond.org/fnn.pdf" target="_blank">Friends and Neighbors on the Web</a> (2003)

The core idea behind the AA Index is that common neighbors with lower degrees contribute more valuable information about the similarity between two nodes than those with higher degrees. The index is calculated using the following formula:

<div align=center><img width=290 src="https://img.ultipa.cn/2022-08-10-09-53-17-AA.jpg"></div>

where <i>N(u)</i> is the set of nodes adjacent to <i>u</i>. For each common neighbor <i>u</i> of the two nodes, the AA Index first calculates the reciprocal of the logarithm of its degree <i>|N(u)|</i>, and then sums these values across all common neighbors.

A higher AA Index score indicates greater similarity between the nodes, while a score of 0 indicates no similarity between two nodes.

<div align=center drawio-diagram='6570' drawio-name='draw_74f94d72d0804bbda280f06a5cf2b398.jpg'><img src="https://img.ultipa.cn/draw/draw_74f94d72d0804bbda280f06a5cf2b398.jpg?v='1691662039000'"/></div>

In this example, N(D) ∩ N(E) = {B, F}, where <math><mfrac><mn>1</mn><mi>log|N(B)|</mi></mfrac></math> = <math><mfrac><mn>1</mn><mi>log4</mi></mfrac></math> = 1.6610, <math><mfrac><mn>1</mn><mi>log|N(F)|</mi></mfrac></math> = <math><mfrac><mn>1</mn><mi>log3</mi></mfrac></math> = 2.0959, thus AA(D,E) = 1.6610 + 2.0959 = 3.7569.

## Considerations

- The AA Index algorithm treats all edges as undirected, ignoring their original direction.

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
| `type` | String | `Adamic_Adar` | `Adamic_Adar` | Yes | Specifies the similarity type; for AA Index, keep it as `Adamic_Adar`. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results.|

## File Writeback

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.write("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A","E","G"],
  return_id_uuid: "id"
}, {
  file: {
    filename: "aa"
  }
})
```

```uql
algo(topological_link_prediction).params({
  projection: "my_hdc_graph",
  ids: ["C"],
  ids2: ["A","E","G"],
  return_id_uuid: "id"
}).write({
  file: {
    filename: "aa"
  }
})
```

</div>

Result:

<p tit="File: aa"></p>

```
_id1,_id2,result
C,A,1.66096
C,E,3.32193
C,G,2.0959
```

## Full Return

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.run("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A","C","E","G"],
  type: "Adamic_Adar",
  return_id_uuid: "id"
}) YIELD aa
RETURN aa
```

```uql
exec{
  algo(topological_link_prediction).params({
    ids: ["C"],
    ids2: ["A","C","E","G"],
    type: "Adamic_Adar",
    return_id_uuid: "id"
  }) as aa
  return aa
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | result |
| -- | -- | -- |
| C | A | 1.660964 |
| C | E | 3.321928 |
| C | G | 2.095903 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.stream("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A", "B", "D", "E", "F", "G"],
  type: "Adamic_Adar",
  return_id_uuid: "id"
}) YIELD aa
FILTER aa.result >= 2
RETURN aa
```

```uql
exec{
  algo(topological_link_prediction).params({
    ids: ["C"],
    ids2: ["A", "B", "D", "E", "F", "G"],
    type: "Adamic_Adar",
    return_id_uuid: "id"
  }).stream() as aa
  where aa.result >= 2
  return aa
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | result |
| -- | -- | -- |
| C | D | 3.756867 |
| C | E | 3.321928 |
| C | G | 2.095903 |
