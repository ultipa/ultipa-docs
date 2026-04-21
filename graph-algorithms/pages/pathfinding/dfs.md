# Depth-First Search (DFS)

## Overview

Graph traversal is a search technique used to systematically visit and explore all the nodes in a graph. Its primary goal is to reveal and examine the structure and connections of the graph. There are two common strategies for graph traversal:

- <a target="_blank" href="/docs/graph-analytics-algorithms/bfs">Breadth-First Search (BFS)</a>
- Depth-First Search (DFS)

The Depth-First Search (DFS) algorithm is based on the principle of backtracking and proceeds as follows:

1. Create a <i>stack</i> (last-in, first-out) to keep track of visited nodes.
2. Start from a selected node, push it into the stack, and mark it as visited.
3. Push any unvisited neighbor of the node on the top of the stack into the stack, and mark it as visited. If multiple unvisited neighbors exist, select one arbitrarily or according to a predefined order.
4. Repeat step 3 until there are no more unvisited neighbors to push into the stack. 
5. When there are no new nodes to visit, backtrack to the previous node (the one from which the current node was explored) by popping the top node from the stack.
6. Repeat steps 3, 4 and 5 until the stack is empty.

Below is an example of traversing the graph using the DFS approach, starting from node <i>A</i> and assuming to visit neighbors in alphabetical order (A~Z):

<div align=center drawio-diagram='6527' drawio-name="draw_9649268c928a4549953d069be862a609.jpg"><img src="https://img.ultipa.cn/draw/draw_9649268c928a4549953d069be862a609.jpg?v='1691377192398'"/></div>

## Considerations

- Only nodes within the same connected component as the start node will be traversed. Nodes in other connected components are excluded from the traversal results.

## Example Graph

<div align=center drawio-diagram='20005' drawio-name='draw_e160cf27e5c64f57a5fbd4faa56ce10d.jpg'><img src="https://img.ultipa.cn/draw/draw_e160cf27e5c64f57a5fbd4faa56ce10d.jpg?v='1735109792822'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

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

## Parameters

Algorithm name: `traverse`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="8">Default</div> | <div table-width="9">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | `_id` | / | / | No | Specifies the node to start traversal by its `_id`. |
| `uuids` | `_uuid` | / | / | No | Specifies the node to start traversal by its `_uuid`. |
| `direction` | String | `in`, `out` | / | Yes | Specifies to traverse through only incoming edges (`in`) or outgoing edges (`out`). |
| `traverse_type` | String | `dfs` | `bfs` | No | To traverse the graph in the DFS fashion, keep it as `dfs`. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |

## File Writeback

  
```gql  
CALL algo.traverse.write("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ['B'],
  direction: 'in',
  traverse_type: 'dfs'
}, {
  file: {
    filename: "visited_nodes"
  }
})
```

Result:

<p tit="File: visited_nodes"></p>
```
nodes
B,A,C,F,E,
```
