# Resource Allocation

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

The Resource Allocation algorithm assumes that nodes distribute resources to each other through shared neighbors, who act as transmitters. In its basic form, each transmitter is considered to possess a single unit of resource, which is evenly distributed among its neighbors. As a result, the similarity between two nodes is measured by the amount of resource one node is able to transmit to the other through these shared neighbors. This concept was introduced by Tao Zhou, Linyuan Lü, and Yi-Cheng Zhang in 2009:

- T. Zhou, L. Lü, Y. Zhang, <a href="https://arxiv.org/pdf/0901.0553.pdf" target="_blank">Predicting Missing Links via Local Information</a> (2009)

It is computed using the following formula:

<center><img width="260" src="https://img.ultipa.cn/2022-08-10-09-56-21-RA.jpg"></center>

where <i>N(u)</i> is the set of nodes adjacent to <i>u</i>. For each common neighbor <i>u</i> of the two nodes, the Resource Allocation first calculates the reciprocal of its degree |N(u)|, and then sums these values across all common neighbors.

When calculating the degree for nodes in the graphset:
- Edges connecting the same two nodes are counted only once;
- Self-loops are excluded from the calculation.

Higher Resource Allocation scores indicate greater similarity between nodes, while a score of 0 indicates no similarity.

<div align=center drawio-diagram='6591' drawio-name='draw_b86689aa4f2e4c5598dd981e0958996c.jpg'><img src="https://img.ultipa.cn/draw/draw_b86689aa4f2e4c5598dd981e0958996c.jpg?v='1691984801387'"/></div>

In this example, N(D) ∩ N(E) = {B, F}, RA(D,E) = <math><mfrac><mn>1</mn><mi>|N(B)|</mi></mfrac></math> + <math><mfrac><mn>1</mn><mi>|N(F)|</mi></mfrac></math> = <math><mfrac><mn>1</mn><mi>4</mi></mfrac></math> + <math><mfrac><mn>1</mn><mi>3</mi></mfrac></math> = 0.5833.

## Considerations

- The Resource Allocation algorithm treats all edges as undirected, ignoring their original direction.

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
| `type` | String | `Resource_Allocation` | `Adamic_Adar` | No | Specifies the similarity type; for Resource Allocation, keep it as `Resource_Allocation`. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results.|

## File Writeback

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.write("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A","E","G"],
  type: "Resource_Allocation",
  return_id_uuid: "id"
}, {
  file: {
    filename: "ra"
  }
})
```

```uql
algo(topological_link_prediction).params({
  projection: "my_hdc_graph",
  ids: ["C"],
  ids2: ["A","E","G"],
  type: "Resource_Allocation",
  return_id_uuid: "id"
}).write({
  file: {
    filename: "ra"
  }
})
```

</div>

Result:

<p tit="File: ra"></p>

```
_id1,_id2,result
C,A,0.25
C,E,0.5
C,G,0.333333
```

## Full Return

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.run("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A","C","E","G"],
  type: "Resource_Allocation",
  return_id_uuid: "id"
}) YIELD ra
RETURN ra
```

```uql
exec{
  algo(topological_link_prediction).params({
    ids: ["C"],
    ids2: ["A","C","E","G"],
    type: "Resource_Allocation",
    return_id_uuid: "id"
  }) as ra
  return ra
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | result |
| -- | -- | -- |
| C | A | 0.25 |
| C | E | 0.5 |
| C | G | 0.333333 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.topological_link_prediction.stream("my_hdc_graph", {
  ids: ["C"],
  ids2: ["A", "B", "D", "E", "F", "G"],
  type: "Resource_Allocation",
  return_id_uuid: "id"
}) YIELD ra
FILTER ra.result >= 0.3
RETURN ra
```

```uql
exec{
  algo(topological_link_prediction).params({
    ids: ["C"],
    ids2: ["A", "B", "D", "E", "F", "G"],
    type: "Resource_Allocation",
    return_id_uuid: "id"
  }).stream() as ra
  where ra.result >= 0.3
  return ra
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | result |
| -- | -- | -- |
| C | D | 0.583333 |
| C | E | 0.5 |
| C | G | 0.333333 |
