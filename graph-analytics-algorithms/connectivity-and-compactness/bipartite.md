# Bipartite Graph

<div><span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stats</b></span></div>

## Overview

The Bipartite algorithm is used to determine whether a given graph is a bipartite graph. By applying the algorithm, it becomes possible to identify and utilize the inherent structure of bipartite graphs in different scenarios, enabling efficient resource allocation, task assignment, and grouping optimization.

## Concepts

### Bipartite Graph

A <b>bipartite graph</b>, also known as a bigragh, is a graph which the nodes can be divided into two disjoint sets, such that every edge in the graph connects a node from one set to a node from the other set. In other words, there are no edges that connect nodes within the same set.

<div align='center' drawio-diagram='6224' drawio-name='draw_09f0df44a94043b7967dcccf4ea2d334.jpg'><img src="https://img.ultipa.cn/draw/draw_09f0df44a94043b7967dcccf4ea2d334.jpg?v='1687849019862'"/></div>

This example graph is bipartite. The nodes can be partitioned into sets <i>V<sub>1</sub> = {A, D, E}</i> and <i>V<sub>2</sub> = {B, C, F}</i>.

### Coloring Method

To determine if a graph is bipartite, one common approach is to perform a graph traversal and assign each visited node to one of two different sets. This process is often referred to as "coloring" the nodes. During the traversal, if an edge is encountered that connects two nodes within the same set, then the graph is not bipartite. Conversely, if all edges connect nodes from different sets, the graph is bipartite.

<div align='center' drawio-diagram='6225' drawio-name="draw_e29ad8de09194018a02043ce327e0c7a.jpg"><img src="https://img.ultipa.cn/draw/draw_e29ad8de09194018a02043ce327e0c7a.jpg?v='1687852215405'"/></div>

In this example, both graph <i>A</i> and graph <i>B</i> are bipartite. Graph <i>C</i> is not bipartite as it contains an odd cycle. An <b>odd cycle</b> is a cycle that has an odd number of nodes. Bipartite graphs cannot contain odd cycles because it is not possible to color all the nodes of an odd cycle using only two colors while still meeting the requirement of bipartiteness. This property, where bipartite graphs never contain any odd cycles, is a fundamental characteristic of bipartite graphs.

## Considerations

- Two endpoints of a self-loop are the same node, thus graphs that have any self-loop are not bipartite.  
- The Bipartite algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(bipartite)`
- This algorithm has no parameters.

## Examples

The example graph is as follows:

<div align='center' drawio-diagram='2575' drawio-name="draw_b0aa1fe06ff644a586830c3b254cd1e0.jpg"><img src="https://img.ultipa.cn/draw/draw_b0aa1fe06ff644a586830c3b254cd1e0.jpg?v='1657173154014'"/></div>

### Direct Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="8">Type</div> | Description | <div table-width="17">Columns</div> |
| --- | --- | --- | --- |
| 0	| KV | Whether the graph is bipartite, 0 means false, 1 means true | `bipartite_result` |

```uql
algo(bipartite).params() as result 
return result
```

Results: <i>result</i>

| bipartite_result |
| -- |
| 1 |

### Stream Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="8">Type</div> | Description | <div table-width="17">Columns</div> |
| --- | --- | --- | --- |
| 0	| KV | Whether the graph is bipartite, 0 means false, 1 means true | `bipartite_result` |

```uql
algo(bipartite).params().stream() as result 
return result
```

Results: <i>result</i>

| bipartite_result |
| -- |
| 1 |

### Stats Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="8">Type</div> | Description | <div table-width="17">Columns</div> |
| --- | --- | --- | --- |
| 0	| KV | Whether the graph is bipartite, 0 means false, 1 means true | `bipartite_result` |

```uql
algo(bipartite).params().stats() as result 
return result
```

Results: <i>result</i>

| bipartite_result |
| -- |
| 1 |