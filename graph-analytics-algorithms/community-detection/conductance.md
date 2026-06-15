# Conductance

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

Conductance is a metric used to evaluate the quality of a community or cluster within a graph. Studies have shown that scoring functions that are based on conductance best capture the structure of ground-truth communities.

- J. Yang, J. Leskovec, <a href="https://cs.stanford.edu/~jure/pubs/comscore-icdm12.pdf" target="_blank">Defining and Evaluating Network Communities based on Ground-truth</a> (2012)

## Concepts

### Conductance

Intuitively, a good community should have strong internal connections and only weak connections to the rest of the graph.

For a community `C` and its complement `C'`, the conductance of `C` is defined as the ratio of the **cut size** (the number of edges crossing between `C` and `C'`) to the minimum **volume** of `C` and `C'` (i.e., the sum of degrees of nodes within each set):

<center><img width=300 src="https://img.ultipa.cn/img/2024-12-31-16-34-20-conductance.jpg"></center>

In the example below, the community `C` is connected to the rest of the graph with three edges, i.e., `cut(C, C') = 3`. The conductance of `C` is then `cond(C) = 3/min(19, 17) = 3/17 = 0.176471`.  

<div align=center drawio-diagram='20040' drawio-name="draw_435686e016b341bfbe9d79bffe713d42.jpg"><img src="https://img.ultipa.cn/draw/draw_435686e016b341bfbe9d79bffe713d42.jpg?v='1735634801113'"/></div>

If we adjust the cut to inlcude one more node in `C`, the conductance becomes `cond(C) = 3/min(21, 15) = 3/15 = 0.2`.  

<div align=center drawio-diagram='20041' drawio-name='draw_30994ca0ad4d46d7bd13e5aabb2047f6.jpg'><img src="https://img.ultipa.cn/draw/draw_30994ca0ad4d46d7bd13e5aabb2047f6.jpg?v='1735634855110'"/></div>

A small conductance value is desirable in community detection because it indicates a dense community with relatively few edges connecting to the outside. Conversely, a large conductance value means the community is loosely connected internally and has many edges reaching nodes outside the community. This suggests that the community is not tightly knit.

## Example Graph

<div align=center drawio-diagram='20026' drawio-name="draw_6ad46828255f4bb2ab31c30b03f529d1.jpg"><img src="https://img.ultipa.cn/draw/draw_6ad46828255f4bb2ab31c30b03f529d1.jpg?v='1735635964911'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER NODE default ADD PROPERTY {
  community_id uint32
};
INSERT (A:default {_id: "A", community_id: 1}),
       (B:default {_id: "B", community_id: 1}),
       (C:default {_id: "C", community_id: 1}),
       (D:default {_id: "D", community_id: 2}),
       (E:default {_id: "E", community_id: 2}),
       (F:default {_id: "F", community_id: 2}),
       (G:default {_id: "G", community_id: 1}),
       (H:default {_id: "H", community_id: 3}),
       (I:default {_id: "I", community_id: 3}),
       (J:default {_id: "J", community_id: 3}),
       (K:default {_id: "K", community_id: 3}),
       (A)-[:default]->(B),
       (A)-[:default]->(C),
       (A)-[:default]->(D),
       (A)-[:default]->(E),
       (A)-[:default]->(G),
       (D)-[:default]->(E),
       (D)-[:default]->(F),
       (E)-[:default]->(F),
       (G)-[:default]->(D),
       (G)-[:default]->(H),
       (H)-[:default]->(K),
       (I)-[:default]->(H),
       (I)-[:default]->(J),
       (J)-[:default]->(D),
       (J)-[:default]->(K);
```

```uql
create().node_property(@default, "community_id", uint32);
insert().into(@default).nodes([{_id:"A", community_id: 1}, {_id:"B", community_id: 1}, {_id:"C", community_id: 1}, {_id:"D", community_id: 2}, {_id:"E", community_id: 2}, {_id:"F", community_id: 2}, {_id:"G", community_id: 1}, {_id:"H", community_id: 3}, {_id:"I", community_id: 3}, {_id:"J", community_id: 3}, {_id:"K", community_id: 3}]);
insert().into(@default).edges([{_from:"A", _to:"B"}, {_from:"A", _to:"C"}, {_from:"A", _to:"D"}, {_from:"A", _to:"E"}, {_from:"A", _to:"G"}, {_from:"D", _to:"E"}, {_from:"D", _to:"F"}, {_from:"E", _to:"F"}, {_from:"G", _to:"D"}, {_from:"G", _to:"H"}, {_from:"J", _to:"D"}, {_from:"I", _to:"H"}, {_from:"I", _to:"J"}, {_from:"H", _to:"K"}, {_from:"J", _to:"K"}]);
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

Algorithm name: `conductance`

| <div table-width="15">Name</div> | <div table-width="15">Type</div> | <div table-width="5">Spec</div> | <div table-width="5">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `community_property` | "`<@schema.?>property`" | / | / | No | The numeric node property holds the values representing community IDs. |

## File Writeback

<div tab="code">
  
```gql
CALL algo.conductance.write("my_hdc_graph", {
   community_property: "community_id"
}, {
  file: {
    filename: "conductance"
  }
})
```

```uql
algo(conductance).params({
  projection: "my_hdc_graph",
  community_property: "community_id"
}).write({
  file: {
    filename: "conductance"
  }
})
```

</div>

<p tit="File: conductance"></p>

```
community,conductance
2,0.4
1,0.4
3,0.2
```

## Full Return

<div tab="code">
  
```gql
CALL algo.conductance.run("my_hdc_graph", {
  community_property: "community_id"
}) YIELD r
RETURN r
```

```uql
exec{
  algo(conductance).params({
    community_property: "community_id"
  }) as r
  return r
} on my_hdc_graph
```

</div>

Result:

| community | conductance |
| -- | -- |
| 2 | 0.4 |
| 1 | 0.4 |
| 3 | 0.2 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.conductance.stream("my_hdc_graph", {
  community_property: "community_id"
}) YIELD r
RETURN r
```

```uql
exec{
  algo(conductance).params({
    community_property: "community_id"
  }).stream() as r
  return r
} on my_hdc_graph
```

</div>

Result:

| community | conductance |
| -- | -- |
| 2 | 0.4 |
| 1 | 0.4 |
| 3 | 0.2 |