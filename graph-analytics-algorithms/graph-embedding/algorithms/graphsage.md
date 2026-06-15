# GraphSAGE

<div><span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Direct Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

GraphSAGE (SAmple and aggreGatE) is a versatile inductive framework. Instead of training distinct embeddings for each node, it learns functions that generate embeddings by sampling and aggregating features from a node’s local neighborhood. This enables efficient generation of node embeddings for new data. GraphSAGE was proposed by W.H Hamilton et al. of Stanford University in 2017:

- W.L. Hamilton, R. Ying, J. Leskovec, <a target="blank" href="https://arxiv.org/pdf/1706.02216.pdf">Inductive Representation Learning on Large Graphs</a> (2017)

The GraphSAGE algorithm is to produce node embeddings using a trained GraphSAGE model. The training process is outlined in <a href="/docs/graph-analytics-algorithms/graphsage-train">GraphSAGE Train</a>.

## Concepts

### Transductive and Inductive Framework

Most conventional graph embedding methods learn node embeddings by utilizing information from all nodes throughout the iterations. When new nodes are introduced to the network, the model must be retrained using the entire dataset. These <b>transductive frameworks</b> don't naturally extend to generalize.

GraphSAGE, on the other hand, acts as an <b>inductive framework</b>. It trains a collection of aggregator functions rather than creating individual embeddings for each node. This allows embeddings for newly added nodes to be derived based on the features and structural details of existing nodes, eliminating the need to reiterate the entire training procedure. This inductive capacity is crucial for high-throughput, operational machine learning systems.

### GraphSAGE: Embedding Generation

Assume that we have already trained the parameters of <i>K</i> aggregator functions (denoted as <i>AGGREGATE<sub>k</sub></i>) and <i>K</i> weight matrices (denoted as <i>W<sup>k</sup></i>). Let's now delve into the process of generating GraphSAGE embeddings (i.e., the forward propagation).

#### 1. Neighborhood Sampling

In graph <i>G = (V, E)</i>, for each target node to generate the embedding, sample some nodes from its 1st layer of neighborhood to the <i>K</i>-th layer of neighborhood:

- The number of nodes sampled at each layer is fixed as <i>S<sub>k</sub></i> (<i>k = 1,2,...,K</i>).
- Sampling proceeds from layer 1 to layer <i>K</i>, obtaining node sets <i>B<sup>k</sup></i> (<i>k = K,...,1,0</i>). 
  - Initialize <i>B<sup>K</sup></i> with all target nodes.
  - During sampling at the <i>k</i>-th layer, obtain set <i>B<sup>K-k</sup></i> by taking the union of <i>B<sup>K-k+1</sup></i> and the collection of nodes sampled at layer <i>k</i>.
- The sampling is typically performed uniformly. If the number of neighbors at one layer is smaller than the set number, perform repeated sampling until the desired number of nodes is attained.

> The creators of GraphSAGE observed that the value of <i>K</i> need not be large; practical success can be achieved even with modest values, such as <i>K = 2</i>, given that <i>S<sub>1</sub>·S<sub>2</sub></i> is below 500.

<div align=center drawio-diagram='3288' drawio-name="draw_6b63cf131803401188238aa30a205f75.jpg"><img src="https://img.ultipa.cn/draw/draw_6b63cf131803401188238aa30a205f75.jpg?v='1693809400446'"/></div>

For the target node <i>a</i> in the above graph, considering the settings <i>K = 2</i>, <i>S<sub>1</sub> = 3</i>, and <i>S<sub>2</sub> = 5</i>. <i>B<sup>2</sup></i> is initialized as <i>{a}</i>.

- Sampling starts at the 1st layer: 3 immediate neighbors are selected, resulting <i>N(a) = {b, c, d}</i>, then <i>B<sup>1</sup> = B<sup>2</sup> ⋃ N(a) = {a, b, c, d}</i>.
- Next, sampling is performed at the 2nd layer: 5 neighbors are selcted based on nodes in <i>N(a)</i>, resulting <i>N(b) = {i, h}</i>, <i>N(c) = {f}</i>, <i>N(d) = {g, j}</i>, this yields <i>B<sup>0</sup> = B<sup>1</sup> ⋃ N(b) ⋃ N(c) ⋃ N(d) = {a, b, c, d, f,  g, h, i, j}</i>.

#### 2. Feature Aggregation

For each node <i>v ∈ B<sup>0</sup></i>, initialize their embedding vectors as their feature vectors:

<center><img width="100" src="https://img.ultipa.cn/2022-10-17-10-45-19-h0.jpg"></center>

where each <b>feature vector</b> <i>X<sub>v</sub></i> is composed of several specified numeric property values of the node.

The final embeddings of the target nodes are computed through <i>K</i> iterations. In the <i>k</i>-th (<i>k = 1,2,...,K</i>) iteration, for each node <i>v ∈ B<sup>k</sup></i>:

1. Aggregate the <i>(k-1)</i>-th vectors of its sampled neighbors into a neighborhood vector, using the <a href="/docs/graph-analytics-algorithms/graphsage-train#Aggregator-Functions">aggregator function</a> <i>AGGREGATE<sub>k</sub></i>.

<center><img width="370" src="https://img.ultipa.cn/img/2023-09-04-14-56-25-agg.jpg"></center>

2. Concatenate its <i>(k-1)</i>-th vector with the aggregated neighborhood vector. This concatenated vector is then refined by going through a fully connected layer weighted by matrix <i>W<sup>k</sup></i>, followed by a non-linear <a href="/docs/graph-analytics-algorithms/backpropagation#Activation-Function">activation function</a> <i>σ</i> (e.g., <i>Sigmoid</i>, <i>ReLu</i>).
     
<center><img width="350" src="https://img.ultipa.cn/img/2023-08-31-16-59-16-concat.jpg"></center>

<div align=center drawio-diagram='6698' drawio-name='draw_8fc5e9fd2675413986fb5785a6bd73f8.jpg'><img src="https://img.ultipa.cn/draw/draw_8fc5e9fd2675413986fb5785a6bd73f8.jpg?v='1693882303016'"/></div>
    
3. Normalize <math><msubsup><mi>h</mi><mi>v</mi><mi>k</mi></msubsup></math>:
  
<center><img width="170" src="https://img.ultipa.cn/img/2023-08-31-17-04-15-norm.jpg"></center>

The process of feature aggregation of our example can be illustrated as below:

<div align=center drawio-diagram='6692' drawio-name="draw_465283f472ef402bb57ca05399f5f170.jpg"><img src="https://img.ultipa.cn/draw/draw_465283f472ef402bb57ca05399f5f170.jpg?v='1693817377358'"/></div>

<table>
<thead>
<tr>
<th>1st Iteration</th>
<th>2nd Iteration</th>
</tr>
</thead>
<tbody style="background: #ffffff;">
<tr>
<td><center><img src="https://img.ultipa.cn/img/2023-09-04-16-50-24-t.jpg"></center></td>
<td><center><img src="https://img.ultipa.cn/img/2023-09-04-16-51-38-t2.jpg"></center></td>
</tr>
</tbody>
</table>

## Considerations

- The GraphSAGE algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command：`algo(graph_sage)`
- Parameters:

| <div table-width="15">Name</p> | <div table-width="14">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| ----- | ---- | ---- | ---- | ---- | -- |
| model_task_id	| int | / | / | No | Task ID of the <a href="/docs/graph-analytics-algorithms/graphsage-train">GraphSAGE Train</a> algorithm that trained the model |
| ids | []`_id` | / | / | Yes | ID of the nodes to generate embeddings; generate for all nodes if not set |
| node_property_names | []`<property>` | Numeric type, must LTE | Read from the model | Yes | Node properties to form the feature vectors |
| edge_property_name | `<property>` | Numeric type, must LTE | Read from the model | Yes | Edge property to use as edge weight; edges are unweighted if not set |
| sample_size | []int | / | Read from the model | Yes | Elements in the list are the number of nodes sampled at layer <i>K</i> to layer 1 respectively; the size of the list is the number of layers |

## Examples

### Property Writeback

| Spec | Content | Write to | Data Type |
| ---- | ---- | ---- | ---- |
| property_name | Node embedding | Node property | `string` |

```uql
algo(graph_sage).params({
  model_task_id: 4785,
  ids: ['ULTIPA8000000000000001', 'ULTIPA8000000000000002']
}).write({
  db:{
    property_name: 'embedding_graphSage'
  }
})
```

Results: Embedding for each node is written to a new property named <i>embedding_graphSage</i>