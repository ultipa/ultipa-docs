# p-Cohesion

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Direct Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stream Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stats</b></span></div>

## Overview

The p-Cohesion algorithm identifies groups of network players (nodes) that are highly connected with each other, represented by cohesive subgraphs. It provides valuable insights into the level of connectivity and interdependence within these groups, enabling in-depth analysis of the graph structure and its implications. 

The concept of p-cohesion was first proposed by S. Morris in a contagion model of the interaction among large populations:

- S. Morris, <a target='blank' href="http://snap.stanford.edu/class/cs224w-readings/morris98contagion.pdf">Contagion</a>. The Review of Economic Studies, 67(1), 57–78 (2000)

## Concepts

### p-Cohesion

One natural measure of the 'cohesion' of a group is the relative frequency of ties among group members compared to non-members. Let the cohesion be a constant <i>p</i> ∈ (0,1), a <b>p-cohesion</b> is a connected subgraph in which every node has, at least, a proportion <i>p</i> of its neighbors within the subgraph, i.e., at most, a proportion <i>(1 − p)</i> of its neighbors outside. 

The p-Cohesion model offers two distinct advantages compared to other cohesive subgraph models:
- With a large <i>p</i> value, a p-cohesion ensures not only inner-cohesiveness, but also outer-sparseness. 
- In many scenarios, considering the percentage of neighbors rather than a fixed number of neighbors (such as the <i>k</i> value in <a href="/docs/graph-analytics-algorithms/k-core">k-Core</a>) is more appropriate due to variations in node degrees. 

Below shows an example graph. Suppose <i>p</i> = 0.6, a grey label is put next to each node indicating the smallest number of neighbors required for the node to stay in a p-cohesion.

<div align='center' drawio-diagram='6166' drawio-name="draw_ffcc9719bb274bcfbf8e12a701061851.jpg"><img src="https://img.ultipa.cn/draw/draw_ffcc9719bb274bcfbf8e12a701061851.jpg?v='1686797368509'"/></div>

Below are the minimal (in terms of the number of nodes) p-cohesion subgraphs including node <i>a</i> and node <i>j</i> respectively.

<div align='center' drawio-diagram='6168' drawio-name="draw_78908f02c70f425bacaa4146c8f0687d.jpg"><img src="https://img.ultipa.cn/draw/draw_78908f02c70f425bacaa4146c8f0687d.jpg?v='1687921148878'"/></div>

Ultipa's p-Cohesion algorithm finds the approximate minimal p-cohesion subgraph for each query node, and returns each subgraph in the form of its node set.

## Considerations

- The p-Cohesion algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(p_cohesion)`
- Parameters:

| <div table-width="11">Name</div> | <div table-width="8">Type</div> | <div table-width="6">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | Yes | ID/UUID of the query nodes; find the approximate minimal p-cohesions that include each query node respectively; query all nodes if not set |
| p | float | (0,1) | / | No | Each node in a p-cohesion has at least a proportion <i>p</i> of its neighbors within the p-cohesion, and at most a proportion <i>(1 − p)</i> of its neighbors outside |

## Examples

The example graph is as follows:

<div align='center' drawio-diagram='6236' drawio-name='draw_8154c0855e72495cb96b11dc28dd52c1.jpg'><img src="https://img.ultipa.cn/draw/draw_8154c0855e72495cb96b11dc28dd52c1.jpg?v='1687920551178'"/></div>

### File Writeback

| <div table-width="11">Spec</div> | <div table-width="26">Content</div> | Description |
| --- | --- | --- |
| filename | subgraph`N`: `_id`,`_id`,... | Nodes that are contained in each p-cohesion subgraph |

```js
algo(p_cohesion).params({
  ids: ['A', 'I'],
  p: 0.7
}).write({
  file: {
    filename: "cohesion"
  }
})
```

Statistics: num of subgraphs = 2<br>
Results: File <i>cohesion</i>

<p tit="File"></p>

```js
subgraph0:D,C,B,F,A,E,
subgraph1:D,C,F,B,H,E,A,I,
```