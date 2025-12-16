# Topological Sort

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

A topological sorting of a directed graph is an ordering of its nodes into a sequence, where the start node of every edge appears before its end node. Topological sorting is applicable only to <b>directed acyclic graphs (DAGs)</b> that do not contain any cycles. 

Topological sorting have various applications in computer science and other fields. In project management and job scheduling, topological sorting plays a crucial role in determining the optimal order of task execution based on their dependencies. It is also useful for resolving dependencies between modules, libraries, or components in software development. By utilizing this algorithm, dependencies can be resolved in the correct sequence, mitigating conflicts and potential errors.

## Concepts

### Directed Acyclic Graph (DAG)

A <b>directed acyclic graph (DAG)</b> is a type of directed graph with no directed cycles. That is, it is not possible to start at any node <i>v</i> and follow a directed path to return back to <i>v</i> in a DAG.

As shown here, the first and second graphs are DAGs, while the third graph does contain a directed cycle (<i>B→C→D→B</i>) and therefore does not qualify as a DAG.

<div align=center drawio-diagram='6220' drawio-name="draw_3799bff640704bfe8c6e77082d686039.jpg"><img src="https://img.ultipa.cn/draw/draw_3799bff640704bfe8c6e77082d686039.jpg?v='1694508666156'"/></div>

A directed graph is a DAG if and only if it can be topologically sorted.

### Topological Sort

Every DAG has at least one topological sorting.

In the above examples, nodes in the first graph has 3 possible sortings:
- <i>A, E, B, D, C</i>
- <i>A, B, E, D, C</i>
- <i>A, B, D, E, C</i>

A DAG has a unique topological sorting if and only if it has a directed path containing all the nodes, in which case the sorting is the same as the order in which the nodes appear in the path.

In the following example, nodes only has 1 possible sorting: <i>A, B, D, C, E, F</i>.

<div align=center drawio-diagram='6729' drawio-name="draw_cb16d5b2e3b34c83a1226e5cd28cb6b5.jpg"><img src="https://img.ultipa.cn/draw/draw_cb16d5b2e3b34c83a1226e5cd28cb6b5.jpg?v='1694510516466'"/></div>

## Considerations

Running the Topogical Sort algorithm on a graph with cycles will cause the omitting of some nodes. The omitted nodes are:

- Nodes that are part of a cycle (including self-cycles).
- Nodes that are reachable from the above nodes through outgoing edges.

In the given example, first is to omit nodes <i>C</i>, <i>D</i> and <i>G</i>, which form the cycle. Then, nodes <i>F</i>, <i>J</i> and <i>H</i> which are reachable from them are also omitted. As a result, the topological sorting result is <i>A, I, B, E</i>.

<div align=center drawio-diagram='6730' drawio-name="draw_58ebedc9c2204b159f51ebbc396c566c.jpg"><img src="https://img.ultipa.cn/draw/draw_58ebedc9c2204b159f51ebbc396c566c.jpg?v='1694511117733'"/></div>

If a graph is disconnected, or becomes disconnected after omiting nodes that form the cycle and nodes influenced by them, the topological sorting is performed within each connected component. The sorting results are then returned consistently across all components. Isolated nodes are also included in the results and are not overlooked.

## Syntax

- Command: `algo(topological_sort)`
- This algorithm has no parameters.

## Examples

The example graph is as follows:

<div align=center drawio-diagram='6558' drawio-name="draw_7085c79fd10c47bea513f7df41e7a737.jpg"><img src="https://img.ultipa.cn/draw/draw_7085c79fd10c47bea513f7df41e7a737.jpg?v='1691565753201'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`_id`,... |

```js
algo(topological_sort).params().write({
  file: {
    filename: 'sort'
  }
})
```

Results: File <i>sort</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
H
F
A
B
C
D
E
G
```

### Direct Return

| <div table-width="20">Alias Ordinal</div> | <div table-width="20">Type</div> | Description |
| --- | --- | --- |
| 0 | []`nodes` | Array of sorted nodes |

```js
algo(topological_sort).params() as nodes
return nodes
```

Results: <i>nodes</i>

<table>
<tr><td>8</td></tr>
<tr><td>6</td></tr>
<tr><td>1</td></tr>
<tr><td>2</td></tr>
<tr><td>3</td></tr>
<tr><td>4</td></tr>
<tr><td>5</td></tr>
<tr><td>7</td></tr>
</table>

### Stream Return

| <div table-width="20">Alias Ordinal</div> | <div table-width="20">Type</div> | Description |
| --- | --- | --- |
| 0 | []`nodes` | Array of sorted nodes |

```js
algo(topological_sort).params().stream() as n
find().nodes(n) as nodes
return nodes{*}
```

Results: <i>nodes</i>

| \_id | \_uuid |
| -- | -- |
| H | 8 |
| F | 6 |
| A | 1 |
| B | 2 |
| C | 3 |
| D | 4 |
| E | 5 |
