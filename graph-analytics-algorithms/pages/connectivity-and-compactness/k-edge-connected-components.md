# k-Edge Connected Components

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Direct Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The k-Edge Connected Components algorithm aims to find groups of nodes that have strong interconnections based on their edges. By considering the connectivity of edges rather than just the nodes themselves, the algorithm can reveal clusters or communities within the graph where nodes are tightly linked to each other. This information can be valuable for various applications, including social network analysis, web graph analysis, biological network analysis, and more.

Related material of the algorithm:

- T. Wang, Y. Zhang, F.Y.L. Chin, H. Ting, Y.H. Tsin, S. Poon, <a target='blank' href="https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0136264#abstract0">A Simple Algorithm for Finding All k-Edge-Connected Components</a> (2015)

## Concepts

### Edge Connectivity

The <b>edge connectivity</b> of a graph is a measure that quantifies the minimum number of edges that need to be removed in order to disconnect the graph or reduce its connectivity. It represents the resilience of a graph against edge failures. Given a graph <i>G = (V, E)</i>, <i>G</i> is <b>k-edge connected</b> if it remains connected after the removal of any <i>k-1</i> or fewer edges from <i>G</i>. 

The edge connectivity can also be interpreted as the maximum number of edge-disjoint paths between any two nodes in the graph. If the edge connectivity of a graph is <i>k</i>, it means that there are <i>k</i> edge-disjoint paths between any pair of nodes in the graph.

Below shows a 3-edge connected graph and the edge-disjoint paths between each node pair.

<div align='center' drawio-diagram='6176' drawio-name="draw_516ca76c533f42d59c83973efe95125e.jpg"><img src="https://img.ultipa.cn/draw/draw_516ca76c533f42d59c83973efe95125e.jpg?v='1687142427889'"/></div>

> <b>Edge-disjoint</b> paths are paths that do not have any edge in common.

### k-Edge Connected Components

Instead of determining whether the entire graph <i>G</i> is k-edge connected, the k-Edge Connected Components algorithm is interested in finding the maximal subsets of nodes <i>V<sub>i</sub> ⊆ V</i>, where the subgraphs induced by <i>V<sub>i</sub></i> are k-edge connected. 

For example, in social networks, finding a group of people who are strongly connected is more important than computing the connectivity of the entire social network.

## Considerations

- For <i>k</i> = 1, this problem is equivalent to finding the connected components of <i>G</i>.
- The k-Edge Connected Component algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(kcc)`
- Parameters:

| <div table-width="7">Name</div> | <div table-width="7">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| k | int | >1 | / | No | There are <i>k</i> edge-disjoint paths between any pair of nodes in the k-edge connected components |

## Examples

The example graph is as follows:

<div align='center' drawio-diagram='6177' drawio-name="draw_350441442b224f7bad64fb8983024db2.jpg"><img src="https://img.ultipa.cn/draw/draw_350441442b224f7bad64fb8983024db2.jpg?v='1687145644126'"/></div>

### File Writeback

| <div table-width="11">Spec</div> | <div table-width="15">Content</div> | Description |
| --- | --- | --- |
| filename | `_id`,`_id`,... | The IDs of nodes that are contained in each k-edge connected component |

```js
algo(kcc).params({
  k: 3
}).write({
  file:{
    filename: 'result'
  }
})
```

Results: File <i>result</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
F,G,I,H,
J,K,M,L,
```