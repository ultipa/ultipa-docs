# Breadth-First Seach (BFS)

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Direct Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

Graph traversal is a search technique used to visit and explore all the nodes of a graph systematically. The primary goal of graph traversal is to uncover and examine the structure and connections of the graph. There are two common strategies for graph traversal: 

- Breadth-First Seach (BFS)
- <a href="https://www.ultipa.com/docs/graph-analytics-algorithms/dfs">Depth-First Search (DFS)</a>

The Breadth-First Search (BFS) algorithm explores a graph layer by layer and follows these steps:

1. Create a <i>queue</i> (first in, first out) to keep track of visited nodes.
2. Start from a selected node, enqueue it into the queue, and mark it as visited.
3. Dequeue a node from the front of the queue, enqueue all its unvisited neighbors into the queue and mark them as visited.
4. Repeat step 3 until the queue is empty.

Below is an example of traversing the graph using the BFS approach, starting from node <i>A</i> and assuming to visit neighbors in alphabetical order (A~Z):

<div align=center drawio-diagram='6535' drawio-name="draw_e5c774b715f54c97a2d274aa865d9942.jpg"><img src="https://img.ultipa.cn/draw/draw_e5c774b715f54c97a2d274aa865d9942.jpg?v='1691389506508'"/></div>

## Considerations

- Only nodes that are in the same connected component as the start node can be traversed. Nodes in different connect components will not be included in the traversal results.

## Syntax

- Command: `algo(traverse)`
- Parameters:

| <div table-width="15">Name</div> | <div table-width="8">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | `_id` / `_uuid` | / | / | No | ID/UUID of the start node to traverse the graph |
| direction | string | `in`, `out` | / | Yes | Direction of edges when traversing the graph |
| traverse_type | string | `bfs` | `bfs` | Yes | To traverse the graph in the BFS approach, keep it as `bfs` |

## Examples

<div align=center drawio-diagram='6705' drawio-name="draw_e6a9e59f0c314070abc384efb3186911.jpg"><img src="https://img.ultipa.cn/draw/draw_e6a9e59f0c314070abc384efb3186911.jpg?v='1693898747250'"/></div>

### File Writeback

| <div table-width="15">Spec</div> | <div table-width="15">Content</div> | Description |
| --- | --- | --- |
| filename | `_id,_id` | The visited node (toNode), and the node from which it is visited (fromNode) |

```js
algo(traverse).params({
  ids: ['A'],
  direction: 'out',
  traverse_type: 'bfs'
}).write({
  file: {
      filename: 'result'
  }
})
```

Results: File <i>result</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
F,E
E,B
D,A
C,F
B,A
A,A
