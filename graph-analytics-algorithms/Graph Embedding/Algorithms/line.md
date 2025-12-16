# LINE

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

LINE (Large-scale Information Network Embedding) is a network embedding model that preserves the local or global network structures. LINE is able to scale to very large, arbitrary types of networks, it was originally proposed in 2015:

- J. Tang, M. Qu, M. Wang, M. Zhang, J. Yan, Q. Zhu, <a target="blank" href="https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/frp0228-Tang.pdf">LINE: Large-scale Information Network Embedding</a> (2015)

## Concepts

### First-order Proximity and Second-order Proximity

<b>First-order proximity</b> in a network shows the local proximity between two nodes, and it is contingent upon connectivity. The existence of a link or a link with a larger weight (negative weight is not considered here) signifies greater first-order proximity among two nodes; if no link exist in-between, their first-order proximity is 0.

On the other hand, <b>second-order proximity</b> between a pair of nodes is the similarity between their neighborhood structure, which is determined through the shared neighbors. In case two nodes lack common neighbors, their second-order proximity is 0.

<center><img width="300" src="https://img.ultipa.cn/2022-09-13-15-14-24-info-network.jpg"></center>

This is an illustrative example, where the edge thickness signifies its weight. 

- A substantial weight on the edge between nodes 6 and 7 indicates a high <i>first-order</i> proximity. They shall have close representations in the embedding space. 
- Though nodes 5 and 6 are not directly connected, their considerable common neighbors establish a notable <i>second-order</i> proximity. They are expected to be represented closely to each other in the embedding space as well.

### LINE Model

The LINE model is designed to embed nodes in graph <i>G = (V,E)</i> into low-dimensional vectors, preserving the first- or second-order proximity between nodes.

#### LINE with First-order Proximity

To capture the first-order proximity, LINE defines the joint probability for each edge <i>(i,j)∈E</i> connecting nodes <i>v<sub>i</sub></i> and <i>v<sub>j</sub></i> as follows:

<center><img width="250" src="https://img.ultipa.cn/2022-09-13-16-45-04-f1.jpg"></center>

where <i>u<sub>i</sub></i> is the low-dimensional vector representation of node <i>v<sub>i</sub></i>. The joint probability <i>p<sub>1</sub></i> ranges from 0 to 1, with two closer vectors resulting in a higher dot product and, consequently a higher joint probability.

Empirically, the joint probability between node <i>v<sub>i</sub></i> and <i>v<sub>j</sub></i> can be defined as

<center><img width="130" src="https://img.ultipa.cn/img/2023-11-22-15-35-00-e-p1.jpg"></center>

where <i>w<sub>ij</sub></i> denotes the edge weight between nodes <i>v<sub>i</sub></i> and <i>v<sub>j</sub></i>, <i>W</i> is the sum of all edge weights in the graph.

The <a href="https://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence" target="blank">KL-divergence</a> is adopted to measure the difference between two distributions:

<center><img width="260" src="https://img.ultipa.cn/2022-09-13-16-56-53-f3.jpg"></center>

This serves as the objective function that needs to be minimized during training when preserving the first-order proximity.

#### LINE with Second-order Proximity

To model the second-order proximity, LINE defines two roles for each node - one as the node itself, another as "context" for other nodes (this concept originates from the <a href="https://www.ultipa.com/document/ultipa-graph-analytics-algorithms/skip-gram">Skip-gram</a> model). Accordingly, two vector representations are introduced for each node.

For each edge <i>(i,j)∈E</i>, LINE defines the probability of "context" <i>v<sub>j</sub></i> be observed by node <i>v<sub>i</sub></i> as

<center><img width="280" src="https://img.ultipa.cn/2022-09-13-16-48-02-f4.jpg"></center>

where <i>u'<sub>j</sub></i> is the representation of node <i>v<sub>j</sub></i> when it is regarded as the "context". Importantly, the denominator involves the whole "context" in the graph. 

The corresponding empirical probability can be defined as

<center><img width="140" src="https://img.ultipa.cn/img/2023-11-22-17-57-12-e-p2.jpg"></center>

where <i>w<sub>ij</sub></i> is weight of edge <i>(i,j)</i>, <i>d<sub>i</sub></i> is the <a href="https://www.ultipa.com/document/ultipa-graph-analytics-algorithms/degree-centrality#Weighted-Degree">weighted degree</a> of node <i>v<sub>i</sub></i>.

Similarly, the <a href="https://en.wikipedia.org/wiki/Kullback%E2%80%93Leibler_divergence" target="blank">KL-divergence</a> is adopted to measure the difference between two distributions:

<center><img width="260" src="https://img.ultipa.cn/2022-09-13-16-57-00-f5.jpg"></center>

This serves as the objective function that needs to be minimized during training when preserving the second-order proximity.

### Model Optimization

#### Negative Sampling

To improve the computation efficiency, LINE adopts the <a href="https://www.ultipa.com/document/ultipa-graph-analytics-algorithms/skip-gram-optimization#Negative-Sampling">negative sampling</a> approach which samples multiple negative edges according to some noisy distribution for each edge <i>(i,j)</i>. Specifically, the two objective functions are adjusted as:

<center><img width="430" src="https://img.ultipa.cn/img/2023-11-23-15-36-55-ng.jpg"></center>

where <i>σ</i> is the <a href="https://www.ultipa.com/document/ultipa-graph-analytics-algorithms/backpropagation#Activation-Function">sigmoid function</a>, <i>K</i> is the number of negative edges drawn from the noise distribution <i>P<sub>n</sub>(v) ∝ d<sub>v</sub><sup>3/4</sup></i>, <i>d<sub>v</sub></i> is the weighted degree of node <i>v</i>.

#### Edge-Sampling

Since the edge weights are included in both objectives, these weights will be multiplied into gradients, resulting in the explosion of the gradients and thus compromise the performance. To address this, LINE samples the edges with the probabilities proportional to their weights, and then treat the sampled edges as binary edges for model updating.

## Considerations

- The LINE algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command：`algo(line)`
- Parameters:

| <div table-width="20">Name</p> | <div table-width="10">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| ----- | ---- | ---- | ---- | ---- | -- |
| edge_schema_property | []`@<schema>?.<property>` | Numeric type, must LTE | / | No | Edge property(-ies) to be used as edge weight(s), where the values of multiple properties are summed up |
| dimension | int | ≥2 | / | No	| Dimensionality of the embeddings |
| train_total_num | int | ≥1 | / | No | Total number of training iterations |
| train_order | int | `1`, `2` | `1` | Yes | Type of proximity to preserve, `1` means first-order proximity, `2` means second-order proximity |
| learning_rate | float | (0,1) | / | No | Learning rate used initially for training the model, which decreases after each training iteration until reaches `min_learning_rate` |
| min_learning_rate | float | (0,`learning_rate`) | / | No | Minimum threshold for the learning rate as it is gradually reduced during the training |
| neg_num | int | ≥0 | / | No | Number of negative samples to produce for each positive sample, it is suggested to set between 0 to 10 |
| resolution | int | ≥1 | `1` | Yes | The parameter used to enhance negative sampling efficiency; a higher value offers a better approximation to the original noise distribution; it is suggested to set as 10, 100, etc. |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Example

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`embedding_result` |

```js
algo(line).params({
  dimension: 20,
  train_total_num: 10,
  train_order: 1,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 5,
  resolution: 100,
  limit: 100
}).write({
  file:{
    filename: 'embeddings'
}})
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| -- | -- | -- | -- |
| property | `embedding_result` | Node Property | `string` |

```js
algo(line).params({
  edge_schema_property: '@branch.distance',
  dimension: 20,
  train_total_num: 10,
  train_order: 1,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 5,
  limit: 100
}).write({
  db:{
    property: 'vector'
}})
```

### Direct Return

| Alias Ordinal	| <div table-width="12">Type</div> | <div table-width="28">Description</div> | <div table-width="30">Columns</div> |
| ---- | --- | --- | ---- |
| 0 | []perNode | Node and its embeddings | `_uuid`, `embedding_result` |

```js
algo(line).params({
  edge_schema_property: '@branch.distance',
  dimension: 20,
  train_total_num: 10,
  train_order: 1,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 5,
  limit: 100
}) as embeddings
return embeddings
```

### Stream Return

| Alias Ordinal	| <div table-width="12">Type</div> | <div table-width="28">Description</div> | <div table-width="30">Columns</div> |
| ---- | --- | --- | ---- |
| 0 | []perNode | Node and its embeddings | `_uuid`, `embedding_result` |

```js
algo(line).params({
  edge_schema_property: '@branch.distance',
  dimension: 20,
  train_total_num: 10,
  train_order: 2,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 5,
  limit: 100
}).stream() as embeddings
return embeddings
