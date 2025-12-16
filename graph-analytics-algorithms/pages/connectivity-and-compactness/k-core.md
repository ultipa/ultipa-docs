# k-Core

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The k-Core algorithm identifies the maximal connected subgraph where all nodes have a minimum degree of <i>k</i>. It is commonly employed to extract closely connected groups in a graph for further analysis. The algorithm is widely utilized in various research domains including financial risk control, social network analysis, and biology. One of the key advantages of the k-Core algorithm is its low time complexity (linear), making it efficient for large-scale graph processing. Additionally, the resulting subgraphs have good intuitive interpretability, aiding in the understanding of the graph's structural patterns and relationships.

The commonly accepted concept of k-core was first proposed by Seidman: 

- S.B. Seidman, <a target="blank" href="https://www.researchgate.net/publication/222151359_Network_Structure_And_Minimum_DegreeSoc_Netw_5269-287">Network Structure And Minimum Degree</a>. Soc Netw 5:269-287 (1983)

## Concepts

### k-Core

The k-core of a graph is obtained through an iterative pruning process. Starting with the original graph, nodes with a degree less than <i>k</i> are successively removed until only nodes with degrees greater than or equal to <i>k</i> remain.

Below is the pruning process to get the 3-core of the graph. In the first round, nodes <i>{a, d, f}</i> with degree less than 3 are removed , which then affects the removal of node <i>b</i> in the second round. After the second round, all remaining nodes have a degree of at least 3. Therefore, the pruning process ends, and the 3-core of this graph is induced by nodes <i>{c, e, g, h}</i>.

<div drawio-diagram='6170' drawio-name='draw_945f428bf6ac4959a1f7ff5b1890f8df.jpg'><img src="https://img.ultipa.cn/draw/draw_945f428bf6ac4959a1f7ff5b1890f8df.jpg?v='1686816943849'"/></div>

Ultipa's k-Core algorithm identifies the k-core in each connected component.

## Considerations

- The k-Core algorithm ignores self-loops in the graph. Any self-loop present is not considered when calculating the degree of the respective node.
- The k-Core algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(k_core)`
- Parameters:

| <div table-width="8">Name</div> | <div table-width="7">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| k | int | ≥1 | / | No | Each node in the k-core has a degree that is equal to or greater than <i>k</i> |

## Examples

The example graph is as follows:

<div align='center' drawio-diagram='6171' drawio-name='draw_40fdd2140e024de2826234d82a135d6d.jpg'><img src="https://img.ultipa.cn/draw/draw_40fdd2140e024de2826234d82a135d6d.jpg?v='1686818515694'"/></div>

### File Writeback

| <div table-width="13">Spec</div> | <div table-width="18">Content</div> | Description |
| --- | --- | --- |
| filename | `_id` | ID of node in the k-core |

```js
algo(k_core).params({
  k: 3
}).write({
  file:{
    filename: '3-core'
  }
})
```

Results: File <i>3-core</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
G
F
E
D
```

### Direct Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="15">Type</div> | Description |
| --- | --- | --- |
| 0	| []perNode	| UUIDs of nodes in the k-core |

```js
algo(k_core).params({
  k: 2
}) as k2 
return k2
```

Results: <i>k2</i>

<table>
<tr><td>7</td></tr>
<tr><td>6</td></tr>
<tr><td>5</td></tr>
<tr><td>4</td></tr>
<tr><td>2</td></tr>
<tr><td>3</td></tr>
</table>

### Stream Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="15">Type</div> | Description |
| --- | --- | --- |
| 0	| []perNode	| UUIDs of nodes in the k-core |

```js
algo(k_core).params({
  k: 2
}).stream() as k2 
find().nodes(k2) as nodes
return nodes{*}
```

Results: <i>nodes</i>

| \_id | \_uuid |
| -- | -- |
| G | 7 |
| F | 6 |
| E | 5 |
| D | 4 |
| C | 2 |
