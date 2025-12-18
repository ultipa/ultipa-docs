# Random Walk

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

A random walk begins at a particular node in graph and proceeds by randomly moving to one of its neighboring nodes; this process is often repeated for a defined number of steps. This concept was introduced by the British mathematician and biostatistician Karl Pearson in 1905, and it has since become a cornerstone in the study of various systems, both within and beyond graph theory.

- K. Pearson, <a target="blank" href="https://www.nature.com/articles/072294b0/">The Problem of the Random Walk</a> (1905)

## Concepts

### Random Walk

Random walk is a mathematical model employed to simulate a series of steps taken in a stochastic or unpredictable manner, like the erratic path of a drunken person. 

The basic random walk is performed in a one-dimensional space: a node initiates from the origin of a number line and moves up or down by one unit at a time with equal likelihood. An example of a 10-step random walk is as follows:

<div align='center' drawio-diagram='3090' drawio-name="draw_39cd2d9439484a909677ce843f6efd9b.jpg"><img src="https://img.ultipa.cn/draw/draw_39cd2d9439484a909677ce843f6efd9b.jpg?v='1661417101846'"/></div>

Here is an example of performing this random walk multiple times, with each walk consisting of 100 steps:

<center><img width="420" src="https://img.ultipa.cn/2022-08-25-17-00-09-1920px-Random-Walk-example.png"></center>

### Random Walk in Graph

In a graph, a random walk is a process where a path is formed by starting from a node and moving sequentially through neighboring nodes. This process is controlled by the walk depth, which determines the number of nodes to be visited.

Ultipa's Random Walk algorithm implements the classical form of random walk. By default, each edge is assigned the same weight (equal to 1), resulting in equal probabilities of traversal. When edge weights are specified, the likelihood of traversing those edges becomes proportional to their weights. It's important to note that various variations of random walk exist, such as <a href="/docs/graph-analytics-algorithms/node2vec-walk">Node2Vec Walk</a> and <a href="/docs/graph-analytics-algorithms/struc2vec-walk">Struc2Vec Walk</a>.

## Considerations

- Self-loops are also eligible to be traversed during the random walk.
- If the walk starts from an isolated node without any self-loop, the walk halts after the first step as there are no adjacent edges to proceed to. 
- The Random Walk algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command：`algo(random_walk)`
- Parameters:

| Name | <div table-width="15">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| ----- | ---- | ---- | ---- | ---- | -- |
| ids / uuids | []`_id` / []`_uuid`	| / | /	| Yes | ID/UUID of nodes to start random walks; start from all nodes if not set |
| walk_length | int	| ≧1 | `1` | Yes | Depth of each walk, i.e., the number of nodes to visit | 
| walk_num | int | ≧1 | `1` | Yes | Number of walks to perform for each specified node |
| edge_schema_property | []`@<schema>?.<property>` | Numeric type, must LTE | / | Yes | Edge property(-ies) to use as edge weight(s), where the values of multiple properties are summed up; nodes only walk along edges with the specified property(-ies) |
| limit | int | ≧-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Example

The example graph is as follows, numbers on edges are the values of edge property <i>score</i>:

<div align=center drawio-diagram='6595' drawio-name="draw_85be99bb5cee487c99836baf9d60c9ef.jpg"><img src="https://img.ultipa.cn/draw/draw_85be99bb5cee487c99836baf9d60c9ef.jpg?v='1691996334002'"/></div>

### File Writeback

| <div table-width="20">Spec</div> | <div table-width="20">Content</div> | Description |
| --- | --- | --- |
| filename | `_id`,`_id`,... | IDs of visited nodes |

```uql
algo(random_walk).params({
  walk_length: 6,
  walk_num: 2
}).write({
  file:{
    filename: 'walks'
}})
```

Results: File <i>walks</i>

<p tit="File"></p>

```
K,
J,G,J,G,F,D,
I,I,I,H,I,I,
H,I,I,I,I,I,
G,J,G,J,G,H,
F,D,C,A,B,A,
E,F,D,C,D,C,
D,F,G,H,G,H,
C,D,F,E,F,D,
B,A,B,A,C,A,
A,C,A,C,D,F,
K,
J,G,J,G,J,G,
I,I,I,H,I,I,
H,I,H,G,J,G,
G,H,I,I,H,G,
F,D,C,D,F,E,
E,C,D,F,G,J,
D,C,D,C,E,F,
C,E,C,A,B,A,
B,A,B,A,C,A,
A,B,A,C,D,C,
```

### Direct Return

| Alias Ordinal	| Type | <div table-width="35">Description</div> | <div table-width="23">Columns</div> |
| --------- | --- | ----------- | -------- |
| 0 | []perWalk | Array of UUIDs of visited nodes | `[_uuid, _uuid, ...]` |

```uql
algo(random_walk).params({
  walk_length: 6,
  walk_num: 2,
  edge_schema_property: 'score'
}) as walks
return walks
```

Results: <i>walks</i>

<table>
<tr><td>[11]</td></tr>
<tr><td>[10, 7, 10, 7, 10]</td></tr>
<tr><td>[9, 9, 9, 9, 9]</td></tr>
<tr><td>[8, 9, 9, 9, 9]</td></tr>
<tr><td>[7, 10, 7, 10, 7]</td></tr>
<tr><td>[6, 4, 3, 4, 3]</td></tr>
<tr><td>[5, 6, 7, 6, 4]</td></tr>
<tr><td>[4, 6, 7, 10, 7]</td></tr>
<tr><td>[3, 1, 3, 1, 3]</td></tr>
<tr><td>[2, 1, 3, 1, 3]</td></tr>
<tr><td>[1, 3, 4, 3, 5]</td></tr>
<tr><td>[11]</td></tr>
<tr><td>[10, 7, 10, 7, 10]</td></tr>
<tr><td>[9, 9, 9, 8, 7]</td></tr>
<tr><td>[8, 9, 8, 7, 8]</td></tr>
<tr><td>[7, 6, 4, 6, 4]</td></tr>
<tr><td>[6, 5, 6, 4, 6]</td></tr>
<tr><td>[5, 3, 4, 6, 4]</td></tr>
<tr><td>[4, 6, 4, 6, 7]</td></tr>
<tr><td>[3, 4, 3, 4, 6]</td></tr>
<tr><td>[2, 1, 3, 1, 3]</td></tr>
<tr><td>[1, 2, 1, 3, 1]</td></tr>
</table>

### Stream Return

| Alias Ordinal	| Type | <div table-width="35">Description</div> | <div table-width="23">Columns</div> |
| --------- | --- | ----------- | -------- |
| 0 | []perWalk | Array of UUIDs of visited nodes | `[_uuid, _uuid, ...]` |

```uql
algo(random_walk).params({
  walk_length: 5,
  walk_num: 1,
  edge_schema_property: '@default.score'
}).stream() as walks
where size(walks) == 5
return walks
```

Results: <i>walks</i>

<table>
<tr><td>[10, 7, 10, 7, 6]</td></tr>
<tr><td>[9, 9, 9, 9, 9]</td></tr>
<tr><td>[8, 9, 9, 9, 9]</td></tr>
<tr><td>[7, 10, 7, 6, 4]</td></tr>
<tr><td>[6, 4, 3, 4, 6]</td></tr>
<tr><td>[5, 6, 4, 6, 4]</td></tr>
<tr><td>[4, 3, 4, 6, 4]</td></tr>
<tr><td>[3, 1, 3, 5, 3]</td></tr>
<tr><td>[2, 1, 3, 4, 6]</td></tr>
<tr><td>[1, 2, 1, 2, 1]</td></tr>
</table>