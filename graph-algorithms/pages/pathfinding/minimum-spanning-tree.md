# Minimum Spanning Tree

## Overview

The Minimum Spanning Tree (MST) algorithm computes a spanning tree with the minimum total edge weight for each connected component in a graph.

The MST has a wide range of applications, including network design, clustering, and other optimization problems where minimizing overall cost or weight is essential.

## Concepts

### Spanning Tree

A spanning tree is a connected subgraph that includes all the nodes of a connected graph <i>G = (V, E)</i> (or of a connected component) and forms a tree (i.e., a graph with no circles). A graph may have multiple spanning trees, but each spanning tree must contain (|V| - 1) edges.

In the example below, the 11 nodes of the graph and the 10 edges highlighted in red form a spanning tree:

<div align=center drawio-diagram='6362' drawio-name="draw_0c34b3642e464fc8a2a536844032f142.jpg"><img src="https://img.ultipa.cn/draw/draw_0c34b3642e464fc8a2a536844032f142.jpg?v='1689661402106'"/></div>

### Minimum Spanning Tree (MST)

An MST is a spanning tree with the minimum total sum of edge weights. The construction of an MST begins from a given start node. While the choice of the start node does not affect the correctness of the algorithm, it can influence the structure of the MST and the order in which edges are added. Different start nodes may result in different MSTs, but all of them will be valid MSTs for the given graph.

In the example below, after assigning weights to the edges, three valid MSTs—each starting from a different node—are highlighted in red:

<div align=center drawio-diagram='6363' drawio-name="draw_f328b3c4a99c4bf8a075d69897400c50.jpg"><img src="https://img.ultipa.cn/draw/draw_f328b3c4a99c4bf8a075d69897400c50.jpg?v='1689661304468'"/></div>

Start Node Selection for MST Computation:

- Each connected component requires only one start node. If multiple start nodes are specified within the same component, only the first one will be used.
- No MST will be computed for any connected component that lacks a specified start node.
- Isolated nodes are not valid as start nodes for MST computation.

<div align=center drawio-diagram='2233' drawio-name="draw_720492664e30472299567955274233dd.jpg"><img src="https://img.ultipa.cn/draw/draw_720492664e30472299567955274233dd.jpg?v='1689661829537'"/></div>

## Considerations

- The MST algorithm treats all edges as undirected, ignoring their original direction.

## Example Graph

<div align=center drawio-diagram='19999' drawio-name="draw_214992c937194875ab0f3a138d04a638.jpg"><img src="https://img.ultipa.cn/draw/draw_214992c937194875ab0f3a138d04a638.jpg?v='1735098786603'"/></div>

Run the following statements on an empty graph to define its structure and insert data:


```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  electricCenter (),
  village ()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  connects ()-[{distance float}]->()
};
INSERT (A:electricCenter {_id: "A"}),
       (B:village {_id: "B"}),
       (C:village {_id: "C"}),
       (D:village {_id: "D"}),
       (E:village {_id: "E"}),
       (F:village {_id: "F"}),
       (G:village {_id: "G"}),
       (H:village {_id: "H"}),
       (A)-[:connects {distance: 1}]->(B),
       (A)-[:connects {distance: 2.4}]->(C),
       (A)-[:connects {distance: 1.2}]->(D),
       (A)-[:connects {distance: 0.7}]->(E),
       (A)-[:connects {distance: 2.2}]->(F),
       (A)-[:connects {distance: 1.6}]->(G),
       (A)-[:connects {distance: 0.4}]->(H),
       (B)-[:connects {distance: 1.3}]->(C),
       (C)-[:connects {distance: 1}]->(D),
       (D)-[:connects {distance: 1.65}]->(H),
       (E)-[:connects {distance: 1.27}]->(F),
       (E)-[:connects {distance: 0.9}]->(G),
       (F)-[:connects {distance: 0.45}]->(G);
```



## Parameters

Algorithm name: `algo(mst)`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | []`_id` | / | / | Yes | Specifies the start node by its `_id` for each connected component; the system will choose the start nodes if it is unset. |
| `uuids` | []`_uuid` | / | / | Yes | Specifies the start node by its `_uuid` for each connected component; the system will choose the start nodes if it is unset. |
| `edge_schema_property` | []"`<@schema.?><property>`" | / | / | No | Specifies a numeric edge property used as weight; for each edge, the property’s smallest value is used. Edges without this property are ignored. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. Edges can only be represented by `_uuid`; this option is only valid in <a href="#File-Writeback">File Writeback</a>. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results. |

## File Writeback

  
```gql
CALL algo.mst.write("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["A"],
  edge_schema_property: "distance"
}, {
  file: {
    filename: "paths"
  }
})
```



Result:

<p tit="File: paths"></p>

```
A--[107]--H
A--[108]--E
E--[111]--G
F--[113]--G
A--[101]--B
A--[104]--D
C--[103]--D
```

## Full Return

  
```gql
CALL algo.mst.run("my_hdc_graph", {
  ids: ["A"],
  edge_schema_property: "@connects.distance"
}) YIELD mst
RETURN mst
```

  
</div>

Result:

<div align=center drawio-diagram='20000' drawio-name="draw_75c98ff93f594b749931cfe061ed7b73.jpg"><img src="https://img.ultipa.cn/draw/draw_75c98ff93f594b749931cfe061ed7b73.jpg?v='1735100234279'"/></div>

## Stream Return

  
```gql
CALL algo.mst.stream("my_hdc_graph", {
  ids: ["A"],
  edge_schema_property: "distance"
}) YIELD mst
FOR e1 IN pedges(mst)
MATCH ()-[e2 WHERE e2._uuid = e1._uuid]->()
RETURN sum(e2.distance)
```

  
</div>

Result: 5.65
