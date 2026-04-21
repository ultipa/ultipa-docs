# Struc2Vec 

## Overview

Struc2Vec, short for "structure to vector", is an algorithm that generates node embeddings while preserving the graph's structural properties. It focuses on capturing topological similarities between nodes, enabling structurally similar nodes to have similar vector representations. 

- L. Ribeiro, P. Saverese, D. Figueiredo, <a target="_blank" href="https://arxiv.org/pdf/1704.03165v3.pdf">struc2vec: Learning Node Representations from Structural Identity</a> (2017)

While <a target="_blank" href="/docs/graph-analytics-algorithms/node2vec">Node2Vec</a> captures a certain degree of structural similarity among nodes, it is limited by the depth of random walks used during the generation process.Struc2Vec, on the other hand, overcomes this limitation by explicitly preserving structural roles, ensuring that nodes with similar topological characteristics are positioned closely in the embedding space.

The choice between Node2Vec and Struc2Vec depends on the nature of downstream tasks:

- Node2Vec is better suited for tasks that emphasize node homophily, capturing similarity in attributes and connections.
- Struc2Vec is ideal for tasks that focus on local topology similarity, preserving the structural relationships among nodes.

## Concepts

### Structural Similarity

In various networks, nodes often exhibit distinct <b>structural identities</b> that reflect their specific functions or roles. Nodes that perform similar functions naturally belong to the same class, signifying a high degree of structural similarity. For instance, in a company's social network, all interns might exhibit similar structural roles.

<b>Structural similarity</b> implies that the neighborhood topologies of such nodes are homogenous or symmetrical. In other words, nodes with similar functions tend to have analogous patterns of connections and relationships with their neighbors.

<div align=center><img width=500 src="https://img.ultipa.cn/2021-12-23-14-50-13-struc2vec-network.png"></div>

As illustrated here, nodes <i>u</i> and <i>v</i> are structurally similar—they have degrees of 5 and 4, are connected to 3 and 2 triangles respectively, and each connects to the rest of the network through 2 nodes. Despite not sharing a direct link or common neighbor, and possibly being far apart in the graph, they still exhibit similar structural roles.

However, when the distance between such nodes exceeds the walk depth, methods like Node2Vec struggle to generate similar representations for them. This limitation is effectively addressed by the Struc2Vec algorithm.

### Struc2Vec Framework

#### 1. Measure structural similarity

Intuitively, two nodes with the same degrees are considered structurally similar. If their neighbors also share the same degrees,  the structural similarity between the two nodes becomes even stronger.

Consider an undirected, unweighted graph `G = (V, E)`, with diameter denoted as <i>k*</i>. Let <i>R<sub>k</sub>(u)</i> represent the set of nodes that are exactly <i>k</i> hops away from node <i>u</i>, where <i>k ∈ [0, k*]</i>. Let <i>s(S)</i> denote the ordered degree sequence of a node set <i>S ⊂ V</i>. Here is an example:

<div align=center drawio-diagram='3107' drawio-name="draw_88cfae112dee41fc92f1109b9d279048.jpg"><img src="https://img.ultipa.cn/draw/draw_88cfae112dee41fc92f1109b9d279048.jpg?v='1693276088404'"/></div>

Let <i>f<sub>k</sub>(u,v)</i> denote the <b>structural distance</b> between nodes <i>u</i> and <i>v</i>, considering their <i>k</i>-hop neighborhoods (all nodes within a distance less than or equal to <i>k</i>):

<center><img width="380" src="https://img.ultipa.cn/2022-08-31-09-45-06-fk.jpg"></center>

where function <i>g() ≥ 0</i> measures the distance between two degree sequences. Note that <i>f<sub>k</sub>(u,v)</i> is non-decreasing in <i>k</i> and is defined only when both <i>u</i> and <i>v</i> have neighbors at distance <i>k</i>.

To measure the distance between the sequences <i>s(R<sub>k</sub>(u))</i> and <i>s(R<sub>k</sub>(v))</i>, which may differ in length, Dynamic Time Wrapping (DTW), or any other appliable function, can be adopted. Note that if the <i>k</i>-hop neighborhoods of nodes <i>u</i> and <i>v</i> are isomorphic, then <i>f<sub>k-1</sub>(u,v) = 0</i>.

#### 2. Construct a multilayer weighted graph

Struc2Vec constructs a multilayer weighted graph <i>M</i> that encodes structural similarity between nodes, where each layer <i>k</i> is defined using the <i>k</i>-hop neighborhoods of the nodes.

Each layer <i>k</i> forms a weighted, undirected complete graph with node set <i>V</i>, containing <math><mfrac><mi>|V|*(|V|-1)</mi><mn>2</mn></mfrac></math> edges. The edge weight between nodes <i>u</i> and <i>v</i> is inversely proportional to their structural distance, as defined as:

<center><img width="200" src="https://img.ultipa.cn/2022-08-31-10-20-44-wk.jpg"></center>

Note that edges are defined only if <i>f<sub>k</sub>(u,v)</i> is defined.

Layers are connected by directed edges. Every node is connected to its corresponding node in the adjacent layers (if such layers exist). The weights of these inter-layer edges are as follows:

<center><img width="250" src="https://img.ultipa.cn/img/2023-01-12-15-54-37-weight.jpg"></center>

where <i>Γ<sub>k</sub>(u)</i> is the number of edges incident to <i>u</i> that have weight larger than the average edge weight of the complete graph in layer <i>k</i>. <i>Γ<sub>k</sub>(u)</i> actually measures the similarity of node <i>u</i> to other nodes in layer k. Note that if node <i>u</i> has many similar nodes in layer <i>k</i>, then it should change to higher layers to obtain a more refined context.

#### 3. Generate context for nodes

Struc2Vec uses random walks to generate sequence of nodes to determine the context of a gievn node.

Consider a biased random walk that operates on graph <i>M</i>. Each node starts the walk in its corresponding node in layer 0. When the walk reaches node <i>u</i> in layer <i>k</i> (denoted as <i>u<sub>k</sub></i>), the random walk first decides if it will <b>(1) stay in the current layer</b>, or <b>(2) change layer</b>:

(1) With probability `q`, the random walk stays in the current layer: the probability of moving to <i>v<sub>k</sub></i> is proportional to <i>w<sub>k</sub>(u,v)</i>. Note that the random walk will prefer to step onto nodes that are structurally more similar to the current node.

(2) With probability `1 − q`, the random walk changes layer: the probabilities of moving to <i>u<sub>k+1</sub></i> or <i>u<sub>k-1</sub></i> are proportional to <i>w<sub>k</sub>(u<sub>k</sub>,u<sub>k+1</sub>)</i> and <i>w<sub>k</sub>(u<sub>k</sub>,u<sub>k-1</sub>)</i>. It's important to note that in this case, the node <i>u</i> is recorded only once in the random walk sequence.

<div align=center drawio-diagram='6666' drawio-name="draw_b8c83622d5104488aa8657ab14e02cfb.jpg"><img src="https://img.ultipa.cn/draw/draw_b8c83622d5104488aa8657ab14e02cfb.jpg?v='1693299298592'"/></div>

The random walks have a fixed and relatively short depth (number of steps), and the process is repeated a certain number of times.

#### 4. Train the model

The node sequences generated from the random walks serve as input to the <a target="_blank" href="/docs/graph-analytics-algorithms/skip-gram">Skip-gram</a> model. <a target="_blank" href="/docs/graph-analytics-algorithms/gradient-descent">SGD</a> is used to optimize the model's parameters based on the prediction error, with <a target="_blank" href="/docs/graph-analytics-algorithms/skip-gram-optimization">optimization</a> techniques such as negative sampling and subsampling applied to enhance efficiency.

## Considerations

- When calculating the degree of a node, each self-loop is counted twice.
- The Struc2Vec algorithm treats all edges as undirected, ignoring their original direction.

## Example Graph

<div align=center drawio-diagram='19960' drawio-name='draw_da519625a8e04b658527c4fe2055a534.jpg'><img src="https://img.ultipa.cn/draw/draw_da519625a8e04b658527c4fe2055a534.jpg?v='1734923193537'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

```gql
INSERT (A:default {_id: "A"}),
       (B:default {_id: "B"}),
       (C:default {_id: "C"}),
       (D:default {_id: "D"}),
       (E:default {_id: "E"}),
       (F:default {_id: "F"}),
       (G:default {_id: "G"}),
       (H:default {_id: "H"}),
       (I:default {_id: "I"}),
       (J:default {_id: "J"}),
       (A)-[:default]->(B),
       (A)-[:default]->(C),
       (D)-[:default]->(C),
       (D)-[:default]->(F),
       (E)-[:default]->(C),
       (E)-[:default]->(F),
       (F)-[:default]->(G),
       (G)-[:default]->(J),
       (H)-[:default]->(G),
       (H)-[:default]->(I);
```

## Parameters

Algorithm name: `struc2vec`

| <div table-width="17">Name</div> | <div table-width="10">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | []`_id` | / | / | Yes | Specifies nodes to start random walk by their `_id`. If unset, computation includes all nodes. |
| `uuids` | []`_uuid` | / | / | Yes | Specifies nodes to start random walk by their `_uuid`. If unset, computation includes all nodes. |
| `walk_length` | Integer | ≥1 | `1` | Yes | Depth of each walk, i.e., the number of nodes to visit. | 
| `walk_num` | Integer | ≥1 | `1` | Yes | Number of walks to perform for each specified node. |
| `k` | Integer | [1, 10] | / | No | Number of layers in the constructed multilayer weighted graph, which should not exceed the diameter of the original graph. |
| `stay_probability` | Float | (0,1] | / | No | The probability of walking in the current level. |
| `window_size` | Integer | ≥1 | / | No | The maximum size of context. |
| `dimension` | Integer | ≥2 | / | No | Dimensionality of the embeddings. |
| `loop_num` | Integer | ≥1 | / | No | Number of training iterations. |
| `learning_rate` | Float | (0,1) | / | No | Learning rate used initially for training the model, which decreases after each training iteration until reaches `min_learning_rate`. |
| `min_learning_rate` | Float | (0,`learning_rate`) | / | No | Minimum threshold for the learning rate as it is gradually reduced during the training. |
| `neg_num` | Integer | ≥1 | `5` | Yes | Number of negative samples to produce for each positive sample, it is suggested to set between 1 to 10. |
| `resolution` | Integer | ≥1 | `1` | Yes | The parameter used to enhance negative sampling efficiency; a higher value offers a better approximation to the original noise distribution; it is suggested to set as 10, 100, etc. |
| `sub_sample_alpha` | Float | / | `0.001` | Yes | The factor affecting the probability of down-sampling frequent nodes; a higher value increases this probability; a value ≤0 means not to apply subsampling |
| `min_frequency` | Integer | / | / | No | Nodes that appear less times than this threshold in the training "corpus" will be excluded from the "vocabulary" and disregarded in the embedding training; a value ≤0 means to keep all nodes. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both values to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results. |

## File Writeback

  
```gql  
CALL algo.struc2vec.write("my_hdc_graph", {
  return_id_uuid: "id",
  walk_length: 10,
  walk_num: 20,
  k: 10,
  stay_probability: 0.4,
  window_size: 5,
  dimension: 5,
  loop_number: 10,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 9,
  resolution: 100,
  sub_sample_alpha: 0.001,
  min_frequency: 3
}, {
  file: {
    filename: "embeddings"
  }
})
```

  
</div>

## DB Writeback

Writes the `embedding_result` values from the results to the specified node property. The property type is `float[]`.

  
```gql  
CALL algo.struc2vec.write("my_hdc_graph", {
  return_id_uuid: "id",
  walk_length: 10,
  walk_num: 20,
  k: 10,
  stay_probability: 0.4,
  window_size: 5,
  dimension: 4,
  loop_number: 10,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 9,
  resolution: 100,
  sub_sample_alpha: 0.001,
  min_frequency: 3
}, {
  db: {
    property: "vector"
  }
})
```

## Full Return

  
```gql  
CALL algo.struc2vec.run("my_hdc_graph", {
  return_id_uuid: "id",
  walk_length: 10,
  walk_num: 20,
  k: 10,
  stay_probability: 0.4,
  window_size: 5,
  dimension: 4,
  loop_number: 10,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 9,
  resolution: 100,
  sub_sample_alpha: 0.001,
  min_frequency: 3
}) YIELD embeddings
RETURN embeddings
```

  
</div>

## Stream Return

  
```gql  
CALL algo.struc2vec.stream("my_hdc_graph", {
  return_id_uuid: "id",
  walk_length: 10,
  walk_num: 20,
  k: 10,
  stay_probability: 0.4,
  window_size: 5,
  dimension: 5,
  loop_number: 10,
  learning_rate: 0.01,
  min_learning_rate: 0.0001,
  neg_number: 9,
  resolution: 100,
  sub_sample_alpha: 0.001,
  min_frequency: 3
}) YIELD embeddings
RETURN embeddings
```

  
</div>
