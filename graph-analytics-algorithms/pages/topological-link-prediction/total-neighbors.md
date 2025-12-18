# Total Neighbors

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

The Total Neighbors algorithm measures the similarity between two nodes by calculating the total number of distinct neighbors they have combined.

Unlike algorithms that focus solely on common neighbors, this method provides a broader perspective by considering the entire neighborhood of both nodes, offering a more comprehensive assessment of their similarity. It is computed using the following formula:

<center><img width="220" src="https://img.ultipa.cn/2022-08-10-11-38-04-TU.jpg"></center>

where <i>N(x)</i> and <i>N(y)</i> are the sets of adjacent nodes to nodes <i>x</i> and <i>y</i> respectively. 

More total neighbors indicate greater similarity between nodes, while a count of 0 indicates no similarity.

<div align=center drawio-diagram='6594' drawio-name='draw_cf9f39ce32334d1e9c8afedd35c05c9b.jpg'><img src="https://img.ultipa.cn/draw/draw_cf9f39ce32334d1e9c8afedd35c05c9b.jpg?v='1691985837823'"/></div>

In this example, TN(D,E) = |N(D) ∪ N(E)| = |{B, C, E, F} ∪ {B, D, F}| = |{B, C, D, E, F}| = 5.

## Considerations

- The Total Neighbors algorithm treats all edges as undirected, ignoring their original direction.

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
| `type` | String | `Total_Neighbors` | `Adamic_Adar` | No | Specifies the similarity type; for Total Neighbors, keep it as `Total_Neighbors`. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results.|

## File Writeback

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.write("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A","E","G"],
  type: "Total_Neighbors",
  return_id_uuid: "id"
}, {
  file: {
    filename: "tn"
  }
})
```

```uql
algo(topological_link_prediction).params({
  projection: "my_hdc_graph",
  ids: ["C"],
  ids2: ["A","E","G"],
  type: "Total_Neighbors",
  return_id_uuid: "id"
}).write({
  file: {
    filename: "tn"
  }
})
```

</div>

Result:

<p tit="File: tn"></p>

```
_id1,_id2,result
C,A,3
C,E,3
C,G,3
```

## Full Return

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.run("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A","C","E","G"],
  type: "Total_Neighbors",
  return_id_uuid: "id"
}) YIELD tn
RETURN tn
```

```uql
exec{
  algo(topological_link_prediction).params({
    ids: ["C"],
    ids2: ["A","C","E","G"],
    type: "Total_Neighbors",
    return_id_uuid: "id"
  }) as tn
  return tn
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | result |
| -- | -- | -- |
| C | A | 3 |
| C | E | 3 |
| C | G | 3 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.stream("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A", "B", "D", "E", "F", "G"],
  type: "Total_Neighbors",
  return_id_uuid: "id"
}) YIELD tn
FILTER tn.result >= 4
RETURN tn
```

```uql
exec{
  algo(topological_link_prediction).params({
    ids: ["C"],
    ids2: ["A", "B", "D", "E", "F", "G"],
    type: "Total_Neighbors",
    return_id_uuid: "id"
  }).stream() as tn
  where tn.result >= 4
  return tn
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | result |
| -- | -- | -- |
| C | B | 6 |
| C | D | 5 |
| C | F | 5 |