# Node2Vec Walk

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

Diverging from the classic <a href="/docs/graph-analytics-algorithms/random-walk">random walk</a>, the Node2Vec Walk is a biased random walk which can explore neighborhoods in a BFS as well as DFS fashion. Please refer to the <a href="/docs/graph-analytics-algorithms/node2vec">Node2Vec</a> algorithm for details.

## Considerations

- Self-loops are also eligible to be traversed during the random walk.
- If the walk starts from an isolated node without any self-loop, the walk halts after the first step as there are no adjacent edges to proceed to. 
- The Node2Vec Walk algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command：`algo(random_walk_node2vec)`
- Parameters:

| <div table-width="15">Name</p> | <div table-width="10">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| ----- | ---- | ---- | ---- | ---- | -- |
| ids / uuids | []`_id` / []`_uuid`	| / | /	| Yes | ID/UUID of nodes to start random walks; start from all nodes if not set |
| walk_length | int	| ≧1 | `1` | Yes | Depth of each walk, i.e., the number of nodes to visit | 
| walk_num | int | ≧1 | `1` | Yes | Number of walks to perform for each specified node |
| edge_schema_property | []`@<schema>?.<property>` | Numeric type, must LTE | / | Yes | Edge property(-ies) to use as edge weight(s), where the values of multiple properties are summed up; nodes only walk along edges with the specified property(-ies) |
| p | float	| >0 | `1` | Yes | The <i>return</i> parameter; a larger value reduces the probability of returning |
| q | float	| >0 | `1` | Yes | The <i>in-out</i> parameter; it tends to walk at the same level when the value is greater than 1, otherwise it tends to walk far away |
| limit | int | ≧-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Example

The example graph is as follows, numbers on edges are the values of edge property <i>score</i>:

<div align=center drawio-diagram='6596' drawio-name="draw_e1128a2ca74c4ff59cd23ca296f8121a.jpg"><img src="https://img.ultipa.cn/draw/draw_e1128a2ca74c4ff59cd23ca296f8121a.jpg?v='1692003100535'"/></div>

### File Writeback

| <div table-width="20">Spec</div> | <div table-width="20">Content</div> | Description |
| --- | --- | --- |
| filename | `_id`,`_id`,... | IDs of visited nodes |

```js
algo(random_walk_node2vec).params({
  walk_length: 6,
  walk_num: 2,
  p: 10000, 
  q: 0.0001
}).write({
  file:{
    filename: 'walks'
}})
```

Results: File <i>walks</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
J,G,H,I,H,G,
I,H,G,F,E,C,
H,G,H,G,F,E,
G,H,G,H,I,H,
F,G,E,C,D,F,
E,F,E,F,G,H,
D,C,D,C,E,F,
C,D,A,B,A,C,
B,A,C,D,F,E,
A,B,A,B,A,C,
J,G,F,D,C,A,
I,H,G,F,E,C,
H,I,H,I,H,G,
G,F,D,C,E,F,
F,E,C,A,B,A,
E,F,E,F,D,C,
D,F,D,F,E,C,
C,D,A,B,A,C,
B,A,C,E,F,G,
A,C,A,C,E,F,
```

### Direct Return

| Alias Ordinal	| Type | <div table-width="35">Description</div> | <div table-width="23">Columns</div> |
| --------- | --- | ----------- | -------- |
| 0 | []perWalk | Array of UUIDs of visited nodes | `[_uuid, _uuid, ...]` |

```js
algo(random_walk_node2vec).params({
  ids: ['J'],
  walk_length: 6,
  walk_num: 3,
  p: 2000,
  q: 0.001
}) as walks
return walks
```

Results: <i>walks</i>

<table>
<tr><td>[10, 7, 6, 5, 3, 1]</td></tr>
<tr><td>[10, 7, 6, 5, 3, 1]</td></tr>
<tr><td>[10, 7, 8, 9, 8, 7]</td></tr>
</table>

### Stream Return

| Alias Ordinal	| Type | <div table-width="35">Description</div> | <div table-width="23">Columns</div> |
| --------- | --- | ----------- | -------- |
| 0 | []perWalk | Array of UUIDs of visited nodes | `[_uuid, _uuid, ...]` |

```js
algo(random_walk_node2vec).params({
  ids: ['A'],
  walk_length: 5,
  walk_num: 10,
  p: 1000,
  q: 1,
  edge_schema_property: 'score'
}).stream() as walks
return walks
```

Results: <i>walks</i>

<table>
<tr><td>[1, 3, 4, 6, 5]</td></tr>
<tr><td>[1, 2, 1, 3, 5]</td></tr>
<tr><td>[1, 2, 1, 3, 4]</td></tr>
<tr><td>[1, 3, 4, 6, 7]</td></tr>
<tr><td>[1, 3, 4, 6, 7]</td></tr>
<tr><td>[1, 3, 5, 6, 7]</td></tr>
<tr><td>[1, 3, 5, 6, 4]</td></tr>
<tr><td>[1, 2, 1, 3, 5]</td></tr>
<tr><td>[1, 3, 4, 6, 7]</td></tr>
<tr><td>[1, 3, 4, 6, 5]</td></tr>
<table>