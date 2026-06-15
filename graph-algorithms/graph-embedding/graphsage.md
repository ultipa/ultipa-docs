# GraphSAGE

## Overview

GraphSAGE (SAmple and aggreGatE) is an inductive framework for learning node representations by sampling and aggregating features from a node's local neighborhood. Unlike transductive methods that must be retrained when new nodes join the graph, GraphSAGE learns aggregation functions that can generalize to unseen nodes.

GraphSAGE was proposed by W.L. Hamilton et al. of Stanford University in 2017:

- W.L. Hamilton, R. Ying, J. Leskovec, <a target="_blank" href="https://arxiv.org/pdf/1706.02216.pdf">Inductive Representation Learning on Large Graphs</a> (2017)

## Concepts

### Transductive and Inductive Framework

Most conventional graph embedding methods learn node embeddings by utilizing information from all nodes throughout the iterations. When new nodes are introduced to the network, the model must be retrained using the entire dataset. These **transductive frameworks** don't naturally generalize to unseen nodes.

GraphSAGE acts as an **inductive framework**. It trains aggregator functions rather than creating individual embeddings for each node. This allows embeddings for newly added nodes to be derived based on the features and structural details of existing nodes, eliminating the need to retrain.

### GraphSAGE Process

This implementation uses a simplified version of GraphSAGE with random weight matrices. The number of layers is determined by the length of the `sampleSizes` list.

1. **Initialize**: Assign each node a random unit vector of size `dimensions`.
2. **For each layer**: For each node,
   - **Sample**: Randomly select `sampleSizes[layer]` of the node's direct neighbors (a neighbor may be selected more than once). Isolated nodes produce a zero aggregation vector.
   - **Aggregate**: Compute the element-wise mean of the sampled neighbors' current embeddings.
   - **Concatenate**: Concatenate the node's own embedding with the aggregated neighbor embedding, producing a vector of size `2 × dimensions`.
   - **Transform**: Multiply the concatenated vector by a random weight matrix to project back to `dimensions`, then apply ReLU activation (sets all negative values to 0, keeps positive values unchanged).
   - **Normalize**: L2-normalize the resulting embedding.

Multi-hop neighborhood information propagates implicitly through the layers: after layer 0, each node's embedding already encodes its direct neighbors' information, so when layer 1 aggregates neighbors, it effectively captures 2-hop structure.

> The original paper trains the weight matrices and aggregator functions using SGD with a loss function that encourages nearby nodes to have similar embeddings. This simplified implementation uses random weight matrices instead, making it training-free while still capturing neighborhood structure through the sample-and-aggregate mechanism.

## Considerations

- The GraphSAGE algorithm treats all edges as undirected, ignoring their original direction.

## Example Graph

<center><img src="images/node2vec-struc2vec-graphsage-hashgnn-example.drawio.svg"/></center>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (I:default {_id: "I"}), (J:default {_id: "J"}),
       (K:default {_id: "K"}),
       (A)-[:default]->(B), (A)-[:default]->(C),
       (C)-[:default]->(D), (D)-[:default]->(C),
       (D)-[:default]->(F), (E)-[:default]->(C),
       (E)-[:default]->(F), (F)-[:default]->(G),
       (G)-[:default]->(J), (H)-[:default]->(G),
       (H)-[:default]->(I), (I)-[:default]->(I),
       (J)-[:default]->(G)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `dimensions` | `INT` | `64` | Embedding dimensionality. |
| `sampleSizes` | `LIST` | `[25, 10]` | Number of neighbors to sample at each layer. The length of the list determines the number of layers. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `embedding` | `LIST` | Embedding vector as list of floats |

```gql
CALL algo.graphsage({
  dimensions: 10,
  sampleSizes: [5, 3]
}) YIELD nodeId, embedding
```

Result:

| nodeId | embedding |
| -- | -- |
| E | [0.046, 0.372, 0.432, 0.457, 0.521, 0, 0, 0.266, 0.252, 0.242] |
| D | [0.621, 0.099, 0, 0.119, 0.346, 0.022, 0, 0.195, 0.428, 0.498] |
| G | [0, 0.670, 0, 0.416, 0.110, 0.031, 0.067, 0.600, 0, 0] |
| F | [0, 0, 0, 0.673, 0.314, 0.322, 0.161, 0, 0.565, 0] |
| A | [0.089, 0.362, 0.265, 0.553, 0.328, 0.409, 0.241, 0.390, 0, 0.020] |
| C | [0, 0.094, 0.073, 0.470, 0.554, 0.377, 0.414, 0.381, 0, 0] |
| B | [0.002, 0, 0, 0.320, 0.350, 0.436, 0.214, 0.011, 0.734, 0] |
| I | [0, 0.162, 0.070, 0.156, 0.366, 0, 0, 0.579, 0.645, 0.244] |
| H | [0, 0, 0, 0.621, 0, 0.312, 0, 0.360, 0.623, 0.011] |
| K | [0.734, 0, 0, 0, 0.274, 0, 0, 0.171, 0.417, 0.428] |
| J | [0, 0, 0, 0.718, 0.126, 0.663, 0.114, 0.125, 0, 0] |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.graphsage.stream({
  dimensions: 10,
  sampleSizes: [5, 3, 2]
}) YIELD nodeId, embedding
RETURN nodeId, embedding
```

Result:

| nodeId | embedding |
| -- | -- |
| E | [0.390, 0.463, 0, 0, 0.376, 0, 0, 0, 0.634, 0.299] |
| D | [0, 0.067, 0, 0, 0.410, 0, 0, 0, 0.910, 0] |
| G | [0.305, 0.388, 0, 0, 0.400, 0, 0.125, 0, 0.723, 0.241] |
| F | [0.294, 0.063, 0, 0, 0.724, 0, 0.282, 0.386, 0.391, 0.064] |
| A | [0.562, 0.318, 0, 0, 0.354, 0, 0.192, 0, 0.575, 0.300] |
| C | [0.483, 0.314, 0, 0, 0.504, 0, 0.384, 0.053, 0.434, 0.274] |
| B | [0.246, 0, 0, 0, 0.553, 0, 0.032, 0.399, 0.465, 0.508] |
| I | [0, 0.114, 0, 0, 0.508, 0, 0, 0, 0.851, 0.068] |
| H | [0.354, 0.126, 0, 0, 0.521, 0, 0.189, 0.403, 0.618, 0.087] |
| K | [0, 0, 0.154, 0, 0.431, 0, 0, 0, 0.889, 0] |
| J | [0.512, 0.228, 0, 0, 0.516, 0, 0.332, 0.306, 0.458, 0.070] |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes processed |
| `dimensions` | `INT` | Embedding dimensionality |

```gql
CALL algo.graphsage.stats({
  dimensions: 10,
  sampleSizes: [5, 3, 2]
}) YIELD nodeCount, dimensions
```

Result:

| nodeCount | dimensions |
| -- | -- |
| 11 | 10 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `embedding` | `LIST` | Embedding vector |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.graphsage.write({dimensions: 4}, {
  db: {
    property: "embedding"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
