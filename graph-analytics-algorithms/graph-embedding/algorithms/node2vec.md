# Node2Vec

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

Node2Vec is a semi-supervised algorithm designed for feature learning of nodes in graphs while efficiently preserving their neighborhoods. It introduces a versatile search strategy that can explore both the BFS and DFS neighborhoods of nodes. It also extends the <a href="/docs/graph-analytics-algorithms/skip-gram">Skip-gram</a> model to graphs for training node embeddings. Node2Vec was developed by A. Grover and J. Leskovec at Stanford University in 2016.

- A. Grover, J. Leskovec, <a target="blank" href="https://arxiv.org/pdf/1607.00653.pdf">node2vec: Scalable Feature Learning for Networks</a> (2016)

## Concepts

### Node Similarity

Node2Vec learns a mapping of nodes into a low-dimensional vector space, intending to ensure that similar nodes in the network exhibit close embeddings in the vector space. 

Nodes in network often shuttle between two kinds of similarities:

<div align=center drawio-diagram='6601' drawio-name='draw_191fbd1276da41dab05f275425c7d7cd.jpg'><img src="https://img.ultipa.cn/draw/draw_191fbd1276da41dab05f275425c7d7cd.jpg?v='1692065329499'"/></div>

<b>1. Homophily</b>

Homophily in networks refers to the phenomenon that nodes with similar properties, characteristics, or behaviors are more likely to be connected together or belong to the same or similar communities (nodes <i>u</i> and s<sub>1</sub> in the graph above belong to the same community).

For example, in social networks, individuals with similar backgrounds, interests, or opinions are more likely to form connections.

<b>2. Structural Equivalence</b>

Structural equivalence in networks refers to the concept where nodes are considered equivalent based on their <i>structural roles</i> within the network. Nodes that are structurally equivalent have similar connectivity patterns and relationships to other nodes (i.e., the local topology), even if their individual characteristics are different (nodes <i>u</i> and <i>v</i> in the graph above act as hubs of their corresponding communities).

For example, in social networks, individuals that are structurally equivalent might occupy similar positions in their social groups.

Unlike homophily, structural equivalence does not emphasize connectivity; nodes could be far apart in the network and still have the same structural role.

When discussing structural equivalence, it's important to keep in mind two key points: Firstly, achieving complete structural equivalence in a real network is uncommon, leading us to focus on assessing <i>structural similarity</i> instead. Secondly, as the scope of the neighborhood being analyzed expands, the level of structural similarity between the two nodes tends to decrease.

### Search Strategies

<div align=center drawio-diagram='6603' drawio-name="draw_e5b7335ed3574cb4b734961eed2bfa59.jpg"><img src="https://img.ultipa.cn/draw/draw_e5b7335ed3574cb4b734961eed2bfa59.jpg?v='1692068997088'"/></div>

Generally, there are two extreme search strategies for generating a neighborhood set <i>N<sub>S</sub></i> of <i>k</i> nodes:

- <b>Breadth-first Search (BFS):</b> <i>N<sub>S</sub></i> is restricted to nodes which are immediate neighbors of the start node. E.g., <i>N<sub>S</sub>(u) = s<sub>1</sub>, s<sub>2</sub>, s<sub>3</sub></i> of size k = 3 in the graph above.
- <b>Depth-first Search (DFS):</b> <i>N<sub>S</sub></i> consists of nodes sequentially searched at increasing distances from the start node. E.g., <i>N<sub>S</sub>(u) = s<sub>4</sub>, s<sub>5</sub>, v</i> of size k = 3 in the graph above.

The BFS and DFS strategies play a key role in producing embeddings that reflect homophily or structural equivalence between nodes:

- The neighborhoods sampled by BFS lead to embeddings that correspond closely to structural equivalence. By restricting search to nearby nodes, BFS obtains a microscopic view of the neighborhood which is often sufficient to characterize the local topology.
- The neighborhoods sampled by DFS lead to embeddings that correspond closely to homophily. By moving further away from the start node, DFS obtains a macro-view of the neighborhood which is essential in inferring node-to-node dependencies exist in a community.

### Node2Vec Framework

#### 1. Node2Vec Walk

Node2Vec employs a biased random walk with the <b>return parameter</b> `p` and <b>in-out parameter</b> `q` to guide the walk.

<div align=center drawio-diagram='6604' drawio-name='draw_6d3d0ea24fe04dfcb86fb06f53226fee.jpg'><img src="https://img.ultipa.cn/draw/draw_6d3d0ea24fe04dfcb86fb06f53226fee.jpg?v='1692070550371'"/></div>

Consider the random walk that just traversed edge <i>(t,v)</i> and now arrives at node <i>v</i>, the next step of the walk is determined by the transition probabilities on edges <i>(v,x)</i> originating from <i>v</i>, which are proportional to the edge weights (weights are 1 in unweighted graphs). The weights of edges <i>(v,x)</i> are adjusted by `p` and `q` based on the shortest distance <i>d<sub>tx</sub></i> between nodes <i>t</i> and <i>x</i>:

- If <i>d<sub>tx</sub></i> = 0, the edge weight is scaled by `1/p`. In the provided graph, <i>d<sub>tt</sub></i> = 0. Parameter `p` influences the inclination to revisit the node just left. When `p` < 1, backtracking a step becomes more probable; when `p` > 1, otherwise.
- If <i>d<sub>tx</sub></i> = 1, the edge weight remains unaltered. In the provided graph, <i>d<sub>tx<sub>1</sub></sub></i> = 1.
- If <i>d<sub>tx</sub></i> = 2, the edge weight is scaled by `1/q`. In the provided graph, <i>d<sub>tx<sub>2</sub></sub></i> = 2. Parameter `q` determines whether the walk moves inward (`q` > 1) or outward (`q` < 1).

Note that <i>d<sub>tx</sub></i> must be one of {0, 1, 2}.

Through the two parameters, Node2Vec provides a way of controlling the trade-off between exploration and exploitation during random walk generation, which leads to representations obeying a spectrum of equivalences from homophily to structural equivalence.

#### 2. Node Embeddings

The node sequences obtained from the random walks serve as input to the <a href="/docs/graph-analytics-algorithms/skip-gram">Skip-gram</a> model. <a href="/docs/graph-analytics-algorithms/gradient-descent">SGD</a>  is used to optimize the model's parameters based on the prediction error, and the model is <a href="/docs/graph-analytics-algorithms/skip-gram-optimization">optimized</a> by techniques such as negative sampling and subsampling. 

## Considerations

- The Node2Vec algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command：`algo(node2vec)`
- Parameters:

| <div table-width="20">Name</p> | <div table-width="10">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| ----- | ---- | ---- | ---- | ---- | -- |
| ids / uuids | []`_id` / []`_uuid`	| / | /	| Yes | ID/UUID of nodes to start random walks; start from all nodes if not set |
| walk_length | int	| ≥1 | `1` | Yes | Depth of each walk, i.e., the number of nodes to visit | 
| walk_num | int | ≥1 | `1` | Yes | Number of walks to perform for each specified node |
| edge_schema_property | []`@<schema>?.<property>` | Numeric type, must LTE | / | Yes | Edge property(-ies) to use as edge weight(s), where the values of multiple properties are summed up; nodes only walk along edges with the specified property(-ies) |
| p | float	| >0 | `1` | Yes | The <i>return</i> parameter; a larger value reduces the probability of returning |
| q | float	| >0 | `1` | Yes | The <i>in-out</i> parameter; it tends to walk at the same level when the value is greater than 1, otherwise it tends to walk far away |
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

```uql
algo(node2vec).params({
  walk_length: 10,
  walk_num: 20,
  p: 0.5,
  q: 1000,
  buffer_size: 1000,
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

```uql
algo(node2vec).params({
  walk_length: 10,
  walk_num: 20,
  p: 0.5,
  q: 1000,
  buffer_size: 1000,
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

```uql
algo(node2vec).params({
  walk_length: 10,
  walk_num: 20,
  p: 0.5,
  q: 1000,
  buffer_size: 1000,
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

```uql
algo(node2vec).params({
  walk_length: 10,
  walk_num: 20,
  p: 0.5,
  q: 1000,
  buffer_size: 1000,
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