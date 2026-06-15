# Breadth-First Search (BFS)

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

Graph traversal is a search technique used to systematically visit and explore all the nodes in a graph. Its primary goal is to reveal and examine the structure and connections of the graph. There are two common strategies for graph traversal: 

- Breadth-First Search (BFS)
- <a target="_blank" href="/docs/graph-analytics-algorithms/dfs">Depth-First Search (DFS)</a>

The Breadth-First Search (BFS) algorithm explores a graph level by level and proceeds as follows:

1. Create a <i>queue</i> (first in, first out) to keep track of visited nodes.
2. Start from a selected node, enqueue it into the queue, and mark it as visited.
3. Dequeue a node from the front of the queue, enqueue all its unvisited neighbors into the queue and mark them as visited.
4. Repeat step 3 until the queue is empty.

The following example demonstrates BFS traversal starting from node <i>A</i>, assuming neighbors are visited in alphabetical order (A–Z):

<div align=center drawio-diagram='6535' drawio-name="draw_e5c774b715f54c97a2d274aa865d9942.jpg"><img src="https://img.ultipa.cn/draw/draw_e5c774b715f54c97a2d274aa865d9942.jpg?v='1691389506508'"/></div>

## Considerations

- Only nodes within the same connected component as the start node will be traversed. Nodes in other connected components are excluded from the traversal results.

## Example Graph

<div align=center drawio-diagram='20004' drawio-name='draw_1b6bd1981a044cb59d4dc27c44f26f3c.jpg'><img src="https://img.ultipa.cn/draw/draw_1b6bd1981a044cb59d4dc27c44f26f3c.jpg?v='1735109600915'"/></div>

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
       (A)-[:default]->(D),
       (B)-[:default]->(E),
       (C)-[:default]->(A),
       (E)-[:default]->(F),
       (F)-[:default]->(C),
       (G)-[:default]->(D);
```

```uql
insert().into(@default).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}, {_id:"G"}]);
insert().into(@default).edges([{_from:"G", _to:"D"}, {_from:"A", _to:"D"}, {_from:"A", _to:"B"}, {_from:"B", _to:"E"}, {_from:"E", _to:"F"}, {_from:"F", _to:"C"}, {_from:"C", _to:"A"}]);
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

Algorithm name: `traverse`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="8">Default</div> | <div table-width="9">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | `_id` | / | / | No | Specifies the node to start traversal by its `_id`. |
| `uuids` | `_uuid` | / | / | No | Specifies the node to start traversal by its `_uuid`. |
| `direction` | String | `in`, `out` | / | Yes | Specifies to traverse through only incoming edges (`in`) or outgoing edges (`out`). |
| `traverse_type` | String | `bfs` | `bfs` | Yes | To traverse the graph in the BFS fashion, keep it as `bfs`. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |

## File Writeback

<div tab="code">
  
```gql  
CALL algo.traverse.write("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ['A'],
  direction: 'out',
  traverse_type: 'bfs'
}, {
  file: {
    filename: "visited_nodes"
  }
})
```

```uql
algo(traverse).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  ids: ['A'],
  direction: 'out',
  traverse_type: 'bfs'
}).write({
  file: {
    filename: "visited_nodes"
  }
})
```

</div>

Result:

<p tit="File: visited_nodes"></p>

```
node,parent
D,A
F,E
B,A
A,A
E,B
C,F
```
