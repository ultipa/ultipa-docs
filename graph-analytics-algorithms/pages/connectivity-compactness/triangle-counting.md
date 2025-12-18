# Triangle Counting

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span> <span class="flag" style="background:#014d4e;color:#fff;"><b>Distributed</b></span></div>

## Overview

The Triangle Counting algorithm identifies triangles in a graph, where each triangle consists of three mutually connected nodes. Triangles indicate the presence of loops and strong connectivity patterns, making them important for graph structure analysis.

In social networks, triangles indicate cohesive communities, helping to reveal clustering and interconnectedness of individuals or groups within the network. In financial or transaction networks, triangles may signal suspicious or fraudulent behavior. Triangle counting aids in detecting potential patterns of collusion or tightly linked transactions that might require further investigation.

## Concepts

### Triangle

In a complex graph, multiple edges may exist between two nodes, which can lead to the formation of more than one triangle involving three nodes. Take the graph below as an example:

- When counting triangles formed by <b>edges</b>, there are 4 distinct triangles. 
- When counting triangles formed by <b>nodes</b>, there are 2 distinct triangles. 

<div align=center drawio-diagram='6058' drawio-name="draw_ec968583a26b4b3f8924e5b3288adeda.jpg"><img src="https://img.ultipa.cn/draw/draw_ec968583a26b4b3f8924e5b3288adeda.jpg?v='1685431709519'"/></div>

In complex graphs, the number of triangles formed by edges often exceeds that formed by nodes. The choice of assembly principle should align with the objectives of the analysis and the insights intended to be derived from the graph data. In social network analysis, where the focus is often on connectivity patterns among individuals, the node-based assembly principle is commonly adopted. In financial network analysis or other similar domains, the edge-based assembly principle is often preferred. Here, the emphasis is on the relationships between nodes, such as financial transactions or interactions. Assembling triangles based on edges allows for the examination of how tightly nodes are connected and how funds or information flow through the network. 

## Considerations

- The Triangle Counting algorithm treats all edges as undirected, ignoring their original direction.

## Example Graph

<div align=center drawio-diagram='19811' drawio-name="draw_2f145cf5adbe4f858e681b244512bb94.jpg"><img src="https://img.ultipa.cn/draw/draw_2f145cf5adbe4f858e681b244512bb94.jpg?v='1735098361969'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
AALTER NODE default ADD PROPERTY {
  amount int32
};
INSERT (C1:default {_id: "C1", amount: 1}),
       (C2:default {_id: "C2", amount: 6}),
       (C3:default {_id: "C3", amount: 2}),
       (C4:default {_id: "C4", amount: 5}),
       (C5:default {_id: "C5", amount: 5}),
       (C6:default {_id: "C6", amount: 2}),
       (C4)-[:default]->(C1),
       (C4)-[:default]->(C1),
       (C4)-[:default]->(C2),
       (C1)-[:default]->(C2),
       (C2)-[:default]->(C3),
       (C1)-[:default]->(C3),
       (C3)-[:default]->(C5),
       (C3)-[:default]->(C6);
```

```uql
create().node_property(@default, "amount", int32);
insert().into(@default).nodes([{_id:"C1", amount: 1}, {_id:"C2", amount: 6}, {_id:"C3", amount: 2}, {_id:"C4", amount: 5}, {_id:"C5", amount: 5}, {_id:"C6", amount: 2}]);
insert().into(@default).edges([{_from:"C4", _to:"C1"}, {_from:"C4", _to:"C1"}, {_from:"C4", _to:"C2"}, {_from:"C1", _to:"C2"}, {_from:"C2", _to:"C3"}, {_from:"C1", _to:"C3"}, {_from:"C3", _to:"C5"}, {_from:"C3", _to:"C6"}]);
```

</div>

## Running on HDC Graphs

### Creating HDC Graph

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

### Parameters

Algorithm name: `triangle_counting`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `type` | Integer | `1`, `2` | `1` | Yes | Set to `1` to assemble triangles by edges, or `2` to assemble triangles by nodes. |
| `result_type` | Integer | `1`, `2` | `1` | Yes | Set to `1` to return the number of triangles, or `2` to return nodes or edges in each triangle. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. Edges can only be represented by `_uuid`. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results. |

### File Writeback

<div tab="code">
  
```gql
CALL algo.triangle_counting.write("my_hdc_graph", {
  type: 1,
  result_type: 2
}, {
  file: {
    filename: "byEdges"
  }
})
```

```uql
algo(triangle_counting).params({
  projection: "my_hdc_graph",
  type: 1,
  result_type: 2  
}).write({
  file: {
      filename: "byEdges"
  }
})
```

</div>

Result:

<p tit="File: byEdges"></p>

```
_edge_uuids
1,3,4
2,3,4
6,5,4
```

<div tab="code">
  
```gql
CALL algo.triangle_counting.write("my_hdc_graph", {
  return_id_uuid: "id",
  type: 2,
  result_type: 2
}, {
  file: {
    filename: "byNodes"
  }
})
```

```uql
algo(triangle_counting).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  type: 2,
  result_type: 2  
}).write({
  file: {
      filename: "byNodes"
  }
})
```

</div>

Result:

<p tit="File: byNodes"></p>

```
_node_ids
C1,C4,C2
C1,C3,C2
```

### Stats Writeback

<div tab="code">

```gql
CALL algo.triangle_counting.write("my_hdc_graph", {}, {
  stats: {}
})
```

```uql
algo(triangle_counting).params({
  projection: "my_hdc_graph"
}).write({
  stats: {}
})
```

</div>

Result:

| triangle_count |
| -- |
| 3 |

### Full Return

<div tab="code">
  
```gql
CALL algo.triangle_counting.run("my_hdc_graph", {
  result_type: 1
}) YIELD r
RETURN r
```

```uql
exec{
  algo(triangle_counting).params({
    result_type: 1
  }) as r
  return r
} on my_hdc_graph
```

</div>

Result:

| triangle_count |
| -- |
| 3 |

### Stream Return

<div tab="code">
  
```gql
CALL algo.triangle_counting.stream("my_hdc_graph", {
  return_id_uuid: "id",
  type: 2,
  result_type: 2
}) YIELD r
RETURN r
```

```uql
exec{
  algo(triangle_counting).params({
    return_id_uuid: "id",
    type: 2,
    result_type: 2
  }).stream() as r
  return r
} on my_hdc_graph
```

</div>

Result:

|\_ids|
| -- |
|["C1","C4","C2"]|
|["C1","C3","C2"]|

### Stats Return

<div tab="code">
  
```gql
CALL algo.triangle_counting.stats("my_hdc_graph", {
  result_type: 1
}) YIELD stats
RETURN stats
```

```uql
exec{
  algo(triangle_counting).params({
    result_type: 1
  }).stats() as stats
  return stats
} on my_hdc_graph
```

</div>

Result:

| triangle_count |
| --- | 
| 3 |

## Running on Distributed Projections

### Creating Distributed Projection

To project the entire graph to its shard servers as `myProj`:

<div tab="code">

```gql
CREATE PROJECTION myProj OPTIONS {
  nodes: {"*": ["*"]}, 
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true
}
```
  
```uql
create().projection("myProj", {
  nodes: {"*": ["*"]}, 
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true
})
```

</div>

### Parameters

Algorithm name: `triangle_counting`

| <div table-width="14">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="8">Default</div> | <div table-width="9">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `result_type` | Integer | `1`, `2` | `1` | Yes | Sets to `1` to return the number of triangles, or `2` to return nodes or edges in each triangle. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned; `-1` includes all results. |

The distributed version of this algorithm only supports identifying triangles by nodes in the graph.

### File Writeback

<div tab="code">
  
```gql
CALL algo.triangle_counting.write("myProj", {
  result_type: 1
}, {
  file: {
    filename: "triCnt"
  }
})
```

```uql
algo(triangle_counting).params({
  projection: "myProj",
  result_type: 1
}).write({
  file: {
      filename: "triCnt"
  }
})
```

</div>

<p tit="File: triCnt"></p>

```
triangle
2
```

<div tab="code">
  
```gql
CALL algo.triangle_counting.write("myProj", {
  result_type: 2
}, {
  file: {
    filename: "triNodes"
  }
})
```

```uql
algo(triangle_counting).params({
  projection: "myProj",
  result_type: 2
}).write({
  file: {
      filename: "triNodes"
  }
})
```

</div>

<p tit="File: triNodes"></p>

```
triangle
216173881625411585,3386708019294240770,13330655996528295937
216173881625411585,10088064264821538817,13330655996528295937
```

> The results utilize nodes' `_uuid` values.
