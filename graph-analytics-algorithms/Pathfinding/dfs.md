# Depth-First Search (DFS)

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Direct Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

Graph traversal is a search technique used to visit and explore all the nodes of a graph systematically. The primary goal of graph traversal is to uncover and examine the structure and connections of the graph. There are two common strategies for graph traversal: 

- <a href="https://www.ultipa.com/document/ultipa-graph-analytics-algorithms/bfs">Breadth-First Seach (BFS)</a>
- Depth-First Search (DFS)

The Depth-First Search (DFS) algorithm operates based on the backtracking principle and follows these steps:

1. Create a <i>stack</i> (last in, first out) to keep track of visited nodes.
2. Start from a selected node, push it into the stack, and mark it as visited.
3. Push any unvisited neighbor of the node at the top of the stack into the stack, and mark it as visited. If there are multiple unvisited neighbors, choose one arbitrarily or based on a certain order. 
4. Repeat step 3 until there are no more unvisited neighbors to push into the stack. 
5. When there are no new nodes to visit, backtrack to the previous node (the one from which the current node was explored) by popping the top node from the stack.
6. Repeat steps 3, 4 and 5 until the stack is empty.

Below is an example of traversing the graph using the DFS approach, starting from node <i>A</i> and assuming to visit neighbors in alphabetical order (A~Z):

<div align=center drawio-diagram='6527' drawio-name="draw_9649268c928a4549953d069be862a609.jpg"><img src="https://img.ultipa.cn/draw/draw_9649268c928a4549953d069be862a609.jpg?v='1691377192398'"/></div>

## Considerations

- Only nodes that are in the same connected component as the start node can be traversed. Nodes in different connect components will not be included in the traversal results.

## Syntax

- Command: `algo(traverse)`
- Parameters:

| <div table-width="15">Name</div> | <div table-width="8">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | `_id` / `_uuid` | / | / | No | ID/UUID of the start node to traverse the graph |
| direction | string | `in`, `out` | / | Yes | Direction of edges when traversing the graph |
| traverse_type | string | `dfs` | `bfs` | No | To traverse the graph in the DFS approach, keep it as `dfs` |

## Examples

<div align=center drawio-diagram='6706' drawio-name='draw_6bbb8777500c4df6a1f62ee19cfbd821.jpg'><img src="https://img.ultipa.cn/draw/draw_6bbb8777500c4df6a1f62ee19cfbd821.jpg?v='1693899454238'"/></div>

### File Writeback

| <div table-width="15">Spec</div> | <div table-width="15">Content</div> | Description |
| --- | --- | --- |
| filename | `_id,_id` | The visited node (toNode), and the node from which it is visited (fromNode) |

```js
algo(traverse).params({
  ids: ['B'],
  direction: 'in',
  traverse_type: 'dfs'
}).write({
  file: {
      filename: 'result'
  }
})
```

Results: File <i>result</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
F,C
E,F
C,A
B,B
A,B
```
null
