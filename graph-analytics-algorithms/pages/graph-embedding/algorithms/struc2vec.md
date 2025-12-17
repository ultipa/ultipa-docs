# Struc2Vec 

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

Struc2Vec stands for "structure to vector". This algorithm revolutionizes graph embeddings by generating node vectors while retaining the inherent graph structure, focusing on preserving topological similarities.

- L. Ribeiro, P. Saverese, D. Figueiredo, <a target="blank" href="https://arxiv.org/pdf/1704.03165v3.pdf">struc2vec: Learning Node Representations from Structural Identity</a> (2017)

While <a href="/docs/graph-analytics-algorithms/node2vec">Node2Vec</a> captures a certain degree of structural similarity among nodes, it is limited by the depth of random walks used during the generation process. On the other hand, Struc2Vec overcomes this limitation in its framework. It ensures that nodes with similar structural characteristics are represented close to each other in the embedding space.

The choice between Node2Vec and Struc2Vec depends on the nature of downstream tasks:

- Node2Vec suits tasks prioritizing node homophily, capturing similarity in attributes and connections.
- Struc2Vec excels when tasks demand a focus on local topology similarity, preserving the structural relationships among nodes.

## Concepts

### Structural Similarity

In various networks, nodes often possess distinct <b>structural identities</b> shaped by their specific functions or roles. Nodes performing similar functions are naturally belong to the same class, signifying their structural similarity. For instance, in a company's social network, all interns might exhibit similar roles.

<b>Structural similarity</b> among nodes implies that their neighborhood topologies are homogenous or symmetrical. This indicates that nodes with similar functions have analogous connections and relationships with their neighboring nodes.

<div align=center><img width=500 src="https://img.ultipa.cn/2021-12-23-14-50-13-struc2vec-network.png"></div>

As illustrated here, nodes <i>u</i> and <i>v</i> are structurally similar (degrees 5 and 4, connected to 3 and 2 triangles, connected to the rest of the network by 2 nodes). Although they lack a direct link or shared neighbor, and they can be very far apart in the network. 

When the distance between nodes exceeds the depth of random walks, it becomes challenging to generate similar representations for them using methods like Node2Vec. This limitation is effectively addressed by the Struc2Vec algorithm.

### Struc2Vec Framework

#### 1. Measure structural similarity

Intuitively, two nodes that have the same degrees are considered structurally similar, but if their neighbors also have the same degree, then they are even more structurally similar.

Consider an undirected, unweighted graph <i>G = (V, E)</i>, its diameter is denoted as <i>k*</i>. Let <i>R<sub>k</sub>(u)</i> denote the set of nodes located at an exact distance (hop count) of <i>k ∈ [0, k*]</i> from node <i>u</i> within <i>G</i>. Let <i>s(S)</i> denote the ordered degree sequence of a node set <i>S ⊂ V</i>. Here is an example:

<div align=center drawio-diagram='3107' drawio-name="draw_88cfae112dee41fc92f1109b9d279048.jpg"><img src="https://img.ultipa.cn/draw/draw_88cfae112dee41fc92f1109b9d279048.jpg?v='1693276088404'"/></div>

Let <i>f<sub>k</sub>(u,v)</i> denote the <b>structural distance</b> between <i>u</i> and <i>v</i> when considering their <i>k</i>-hop neighborhoods (all nodes at distance less than or equal to <i>k</i>):

<center><img width="380" src="https://img.ultipa.cn/2022-08-31-09-45-06-fk.jpg"></center>

where function <i>g() ≥ 0</i> measures the distance between two degree sequences. Note that <i>f<sub>k</sub>(u,v)</i> is non-decreasing in <i>k</i> and is defined only when both <i>u</i> and <i>v</i> have neighbors at distance <i>k</i>.

To assess distance between sequences <i>s(R<sub>k</sub>(u))</i> and <i>s(R<sub>k</sub>(v))</i>, which can be of different sizes, Dynamic Time Wrapping (DTW), or any other appliable function, can be adopted. Note that if the <i>k</i>-hop neighborhoods of node <i>u</i> and <i>v</i> are isomorphic, then <i>f<sub>k-1</sub>(u,v) = 0</i>.

#### 2. Construct a multilayer weighted graph

Struc2Vec constructs a multilayer weighted graph <i>M</i> that encodes the structural similarity between nodes, where layer <i>k</i> is defined using the <i>k</i>-hop neighborhoods of the nodes.

Each layer <i>k</i> is formed by a weighted undirected complete graph with node set <i>V</i>, and thus <math><mfrac><mi>|V|*(|V|-1)</mi><mn>2</mn></mfrac></math> edges. The edge weight between nodes <i>u</i> and <i>v</i> is inversely proportional to their structural distance, as given by:

<center><img width="200" src="https://img.ultipa.cn/2022-08-31-10-20-44-wk.jpg"></center>

Note that edges are defined only if <i>f<sub>k</sub>(u,v)</i> is defined.

Layers are connected by directed edges. Every node is connected to its corresponding node in the layer above and below (layer permitting), and the edge weight between layers are as follows:

<center><img width="250" src="https://img.ultipa.cn/img/2023-01-12-15-54-37-weight.jpg"></center>

where <i>Γ<sub>k</sub>(u)</i> is the number of edges incident to <i>u</i> that have weight larger than the average edge weight of the complete graph in layer <i>k</i>. <i>Γ<sub>k</sub>(u)</i> actually measures the similarity of node <i>u</i> to other nodes in layer k. Note that if node <i>u</i> has many similar nodes in layer <i>k</i>, then it should change to higher layers to obtain a more refined context.

#### 3. Generate context for nodes

Struc2Vec uses random walks to generate sequence of nodes to determine the context of a gievn node.

Consider a biased random walk that moves in graph <i>M</i>. Each node starts the walk in its corresponding node in layer 0, and when it reaches node <i>u</i> in layer <i>k</i> (denoted as <i>u<sub>k</sub></i>), the random walk first decides if it will <b>(1) stay in the current layer</b>, or <b>(2) change layer</b>:

(1) With probability `q` the random walk stays in the current layer: the probability of moving to <i>v<sub>k</sub></i> is proportional to <i>w<sub>k</sub>(u,v)</i>. Note that the random walk will prefer to step onto nodes that are structurally more similar to the current node.

(2) With probability `1 − q`, the random walk changes layer: the probabilities of moving to <i>u<sub>k+1</sub></i> or <i>u<sub>k-1</sub></i> are proportional to <i>w<sub>k</sub>(u<sub>k</sub>,u<sub>k+1</sub>)</i> and <i>w<sub>k</sub>(u<sub>k</sub>,u<sub>k-1</sub>)</i>. It's important to note that in this case, the node <i>u</i> is recorded only once in the random walk sequence.

<div align=center drawio-diagram='6666' drawio-name="draw_b8c83622d5104488aa8657ab14e02cfb.jpg"><img src="https://img.ultipa.cn/draw/draw_b8c83622d5104488aa8657ab14e02cfb.jpg?v='1693299298592'"/></div>

The random walks have a fixed and relatively short depth (number of steps), and the process is repeated a certain number of times.

#### 4. Train the model

The node sequences obtained from the random walks serve as input to the <a href="/docs/graph-analytics-algorithms/skip-gram">Skip-gram</a> model. <a href="/docs/graph-analytics-algorithms/gradient-descent">SGD</a>  is used to optimize the model's parameters based on the prediction error, and the model is <a href="/docs/graph-analytics-algorithms/skip-gram-optimization">optimized</a> by techniques such as negative sampling and subsampling.

## Considerations

- When considering the degree of a node, any self-loop is counted twice.
- The Struc2Vec algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command：`algo(struc2vec)`
- Parameter:

| <div table-width="20">Name</p> | <div table-width="10">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| ----- | ---- | ---- | ---- | ---- | -- |
| ids / uuids | []`_id` / []`_uuid`	| / | /	| Yes | ID/UUID of nodes to start random walks; start from all nodes if not set |
| walk_length | int	| ≧1 | `1` | Yes | Depth of each walk, i.e., the number of nodes to visit | 
| walk_num | int | ≧1 | `1` | Yes | Number of walks to perform for each specified node |
| k | int | [1, 10] | / | No | Number of layers of the constructed multilayer weighted graph, which should not exceed the diameter of the original graph |
| stay_probability | float | (0,1] | / | No | The probability of walking in the current level |
| window_size | int | ≥1 | / | No | The maximum size of context |
| dimension | int | ≥2 | / | No	| Dimensionality of the embeddings |
| loop_num | int | ≥1 | / | No | Number of training iterations |
| learning_rate | float | (0,1) | / | No | Learning rate used initially for training the model, which decreases after each training iteration until reaches `min_learning_rate` |
| min_learning_rate | float | (0,`learning_rate`) | / | No | Minimum threshold for the learning rate as it is gradually reduced during the training |
| neg_num | int | ≥0 | / | No | Number of negative samples to produce for each positive sample, it is suggested to set between 0 to 10 |
| resolution | int | ≥1 | `1` | Yes | The parameter used to enhance negative sampling efficiency; a higher value offers a better approximation to the original noise distribution; it is suggested to set as 10, 100, etc. |
| sub_sample_alpha | float | / | `0.001` | Yes | The factor affecting the probability of down-sampling frequent nodes; a higher value increases this probability; a value ≤0 means not to apply subsampling |
| min_frequency | int | / | / | No | Nodes that appear less times than this threshold in the training "corpus" will be excluded from the "vocabulary" and disregarded in the embedding training; a value ≤0 means to keep all nodes |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Example

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`embedding_result` |

```js
algo(struc2vec).params({
  walk_length: 10,
  walk_num: 20,
  k: 10,
  stay_probability: 0.4,
  window_size: 5,
  dimension: 20,
  loop_number: 10,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 9,
  resolution: 100,
  sub_sample_alpha: 0.001,
  min_frequency: 3
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
algo(struc2vec).params({
  walk_length: 10,
  walk_num: 20,
  k: 10,
  stay_probability: 0.4,
  window_size: 5,
  dimension: 20,
  loop_number: 10,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 9,
  resolution: 100,
  sub_sample_alpha: 0.001,
  min_frequency: 3
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
algo(struc2vec).params({
  walk_length: 10,
  walk_num: 20,
  k: 10,
  stay_probability: 0.4,
  window_size: 5,
  dimension: 20,
  loop_number: 10,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 9,
  resolution: 100,
  sub_sample_alpha: 0.001,
  min_frequency: 3
}) as embeddings
return embeddings
```

### Stream Return

| Alias Ordinal	| <div table-width="12">Type</div> | <div table-width="28">Description</div> | <div table-width="30">Columns</div> |
| ---- | --- | --- | ---- |
| 0 | []perNode | Node and its embeddings | `_uuid`, `embedding_result` |

```js
algo(struc2vec).params({
  walk_length: 10,
  walk_num: 20,
  k: 10,
  stay_probability: 0.4,
  window_size: 5,
  dimension: 20,
  loop_number: 10,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 9,
  resolution: 100,
  sub_sample_alpha: 0.001,
  min_frequency: 3
}).stream() as embeddings
return embeddings
```