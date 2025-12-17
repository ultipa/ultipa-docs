# Betweenness Centrality

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

Betweenness centrality measures the probability that a node lies in the shortest paths between any other two nodes. Proposed by Linton C. Freeman in 1977, this algorithm effectively detects the 'bridge' or 'medium' nodes between multiple parts of the graph. 

Betweenness centrality takes on values between 0 to 1, nodes with larger scores have stronger impact on the flow or connectivity of the network.

Related materials are as below:

- L.C. Freeman, <a href="https://www.researchgate.net/profile/Linton-Freeman-2/publication/216637282_A_Set_of_Measures_of_Centrality_Based_on_Betweenness/links/54415c660cf2a76a3cc7e199/A-Set-of-Measures-of-Centrality-Based-on-Betweenness.pdf" target="_blank">A Set of Measures of Centrality Based on Betweenness</a> (1977)
- L.C. Freeman, <a href="https://www.albany.edu/~ravi/pdfs/freeman_1978.pdf" target="_blank">Centrality in Social Networks Conceptual Clarification</a> (1978)

## Concepts

### Shortest Path

For every pair of nodes in a connected graph, there exists at least one shortest path between the two nodes such that either the number of edges that the path passes through (for unweighted graphs) or the sum of the weights of the edges (for weighted graphs) is minimized. 

<div align='center' drawio-diagram='1465' drawio-name="draw_5c95ee7a59464081af24a920c65ab070.jpg"><img src="https://img.ultipa.cn/draw/draw_5c95ee7a59464081af24a920c65ab070.jpg?v='1686813915142'"/></div>

In the unweighted graph above, we can find three shortest paths between the red and green nodes, and two of them contain the yellow node, so the probability that the yellow node lies in the shortest paths of the red-green node pair is `2 / 3 = 0.6667`.

### Betweenness Centrality

Betweenness centrality score of a node is defined by this formula:

<div align=center><img width=300 src="https://img.ultipa.cn/img/2023-03-07-14-12-39-bc.jpg"></div>

where `x` is the target node, `i` and `j` are two distinct nodes in the graph (`x` itself is excluded), `σ` is the number of shortest paths of pair `ij`, `σ(x)` is the number of shortest paths of pair `ij` that pass through `x`, `σ(x)/σ` is the probability that `x` lies in the shortest paths of pair `ij` (which is 0 if `i` and `j` are not connected), `k` is the number of nodes in the graph, `(k-1)(k-2)/2` is the number of `ij` node pairs.

<div align=center drawio-diagram='1467' drawio-name="draw_7ee226215cd64f2f987e8bb4bf76d4b7.jpg"><img src="https://img.ultipa.cn/draw/draw_7ee226215cd64f2f987e8bb4bf76d4b7.jpg?v='1643281463997'"/></div>

Calculate betweenness centrality of the red node in this graph. There are 5 nodes in total, thus `(5-1)*(5-2)/2 = 6` node pairs except the red node, the probabilities that the red node lies in the shortest paths between all node pairs are 0, 1/2, 2/2, 0, 2/3 and 0 respectively, so its betweenness centrality score is `(0 + 1/2 + 2/2 + 0 + 2/3 + 0) / 6 = 0.3611`.

> Betweenness Centrality algorithm consumes considerable computing resources. For a graph with <i>V</i> nodes, it is recommended to perform (uniform) sampling when <i>V</i> > 10,000, and the suggested number of samples is the base-10 logarithm of the number of nodes (`log(V)`).<br><br>For each execution of the algorithm, sampling is performed only once, centrality scores of all nodes are computed based on the shortest paths between all sample nodes.

## Considerations

- The betweenness centrality score of isolated nodes is 0.
- The Betweenness Centrality algorithm ignores the direction of edges but calculates them as undirected edges. In undirected graph of `k` nodes, there are `(k-1)(k-2)/2` node pairs for each target node.

## Syntax

- Command: `algo(betweenness_centrality)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="7">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | >Description |
| -- | -- | -- |-- | -- | -- |
| sample_size | int | `-1`, `-2`, [1, V] | `-2` | Yes | Number of samples to compute centrality scores; `-1` means to sample `log(V)` nodes; `-2` means not to perform sampling; a number within [1, V] means to sample the set number of nodes |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order | string | `asc`, `desc` | / | Yes | Sort nodes by the centrality score |

## Examples

The example graph is a small social network, nodes represent users, and edges represent the relationship of know:

<div align=center drawio-diagram='4941' drawio-name="draw_1740726ba6764a969783089016141bbe.jpg"><img src="https://img.ultipa.cn/draw/draw_1740726ba6764a969783089016141bbe.jpg?v='1733825691907'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`centrality` |

```js
algo(betweenness_centrality).params().write({
  file:{ 
    filename: 'centrality'
  }
})
```

Results: File <i>centrality</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
Billy,0
Jay,0.0666667
May,0.0666667
Mark,0.133333
Ann,0.133333
Dave,0.333333
Sue,0
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `centrality` | Node property | `float` |

```js
algo(betweenness_centrality).params().write({
  db:{ 
    property: 'bc'
  }
})
```

Results: Centrality score for each node is written to a new property named <i>bc</i>

### Direct Return

| Alias Ordinal | Type | <div table-width="30">Description</div> | Column Name |
| --- | --- | --- | --- |
| 0 | []perNode | Node and its centrality | `_uuid`, `centrality` |

```js
algo(betweenness_centrality).params({
  order: 'desc',
  limit: 3
}) as bc
return bc
```

Results: <i>bc</i>

| \_uuid | centrality |
| -- | -- |
| 2	| 0.33333299 |
| 4	| 0.13333300 |
| 3	| 0.13333300 |

### Stream Return

| Alias Ordinal | Type | <div table-width="30">Description</div> | Column Name |
| --- | --- | --- | --- |
| 0 | []perNode | Node and its centrality | `_uuid`, `centrality` |

```js
algo(betweenness_centrality).params().stream() as bc
where bc.centrality == 0
return count(bc)
```

Results: 2