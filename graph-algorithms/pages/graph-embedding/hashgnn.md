# HashGNN

## Overview

HashGNN (Hash-based Graph Neural Network) is an efficient algorithm that produces node embeddings using locality-sensitive hashing and iterative message passing. Instead of learning continuous weight matrices like traditional GNNs, HashGNN uses random hash functions to aggregate neighborhood information into compact binary signatures, then converts them to dense embeddings.

HashGNN is inspired by the MinHash/SimHash family of locality-sensitive hashing techniques applied to graph-structured data.

## Concepts

### Binary Embeddings via Hashing

Traditional graph neural networks use learned weight matrices and floating-point arithmetic, which can be computationally expensive. HashGNN replaces these with binary features `({-1, +1})` and random sign hashing, making it significantly faster while still capturing neighborhood structure.

The key insight is that nodes with similar neighborhoods will tend to produce similar hash signatures — the majority vote aggregation preserves common patterns among neighbors, and random sign hashing creates independent hash dimensions.

### HashGNN Process

1. **Initialize**:
   - Assign each node a random binary feature vector of size `dimensions`, with entries randomly set to `+1` or `-1`.
2. **Message passing**: For each iteration, update each node's feature vector:
   - For each dimension, sum the node's own feature value with all its neighbors' feature values.
   - Generate random sign vectors: for each iteration, dimension, and node, pre-generate a random `+1` or `-1` value. Multiply the sum by the node's pre-generated random sign value for this iteration and dimension.
   - Take the sign of the result: non-negative → `+1`, negative → `-1`.
3. **Normalize**: After all iterations, L2-normalize the final binary feature vector to produce the embedding.

Since all entries are `±1` before normalization, the L2 norm is always `√dimensions`, so each entry in the final embedding is `±1/√dimensions`.

<center><img src="images/hashgnn-1.drawio.svg"></center>

Consider this graph with `dimensions = 4`, and `iterations = 3`.

**Initialize**: Each node gets a random binary vector:

| Node | Initial Features |
| -- | -- |
| A | [+1, -1, +1, +1] |
| B | [-1, +1, +1, -1] |
| C | [+1, +1, -1, +1] |
| D | [-1, -1, +1, -1] |
| E | [+1, +1, -1, +1] |

Pre-generated random sign vectors for iteration 1:

| | A | B | C | D | E |
| -- | -- | -- | -- | -- | -- |
| d=0 | -1 | +1 | +1 | -1 | +1 |
| d=1 | +1 | -1 | +1 | +1 | -1 |
| d=2 | -1 | +1 | -1 | +1 | -1 |
| d=3 | +1 | -1 | +1 | -1 | +1 |

**Iteration 1**: for each node, sum self + neighbors per dimension, multiply by random sign.

- **A** (neighbors `B`, `C`):
  - d=0: sum = 1+(-1)+1 = 1, × (-1) = -1 → **-1**
  - d=1: sum = -1+1+1 = 1, × (+1) = 1 → **+1**
  - d=2: sum = 1+1+(-1) = 1, × (-1) = -1 → **-1**
  - d=3: sum = 1+(-1)+1 = 1, × (+1) = 1 → **+1**
- **B** (neighbors `A`, `C`):
  - d=0: sum = -1+1+1 = 1, × (+1) = 1 → **+1**
  - d=1: sum = 1+(-1)+1 = 1, × (-1) = -1 → **-1**
  - d=2: sum = 1+1+(-1) = 1, × (+1) = 1 → **+1**
  - d=3: sum = -1+1+1 = 1, × (-1) = -1 → **-1**
- **C** (neighbors `A`, `B`, `D`):
  - d=0: sum = 1+1+(-1)+(-1) = 0, × (+1) = 0 → **+1**
  - d=1: sum = 1+(-1)+1+(-1) = 0, × (+1) = 0 → **+1**
  - d=2: sum = -1+1+1+1 = 2, × (-1) = -2 → **-1**
  - d=3: sum = 1+1+(-1)+(-1) = 0, × (+1) = 0 → **+1**
- **D** (neighbors `C`, `E`):
  - d=0: sum = -1+1+1 = 1, × (-1) = -1 → **-1**
  - d=1: sum = -1+1+1 = 1, × (+1) = 1 → **+1**
  - d=2: sum = 1+(-1)+(-1) = -1, × (+1) = -1 → **-1**
  - d=3: sum = -1+1+1 = 1, × (-1) = -1 → **-1**
- **E** (neighbor `D`):
  - d=0: sum = 1+(-1) = 0, × (+1) = 0 → **+1**
  - d=1: sum = 1+(-1) = 0, × (-1) = 0 → **+1**
  - d=2: sum = -1+1 = 0, × (-1) = 0 → **+1**
  - d=3: sum = 1+(-1) = 0, × (+1) = 0 → **+1**

| Node | After Iteration 1 |
| -- | -- |
| A | [-1, +1, -1, +1] |
| B | [+1, -1, +1, -1] |
| C | [+1, +1, -1, +1] |
| D | [-1, +1, -1, -1] |
| E | [+1, +1, +1, +1] |

**Iteration 2**: using new random sign vectors, aggregate and hash again.

| | A | B | C | D | E |
| -- | -- | -- | -- | -- | -- |
| d=0 | +1 | +1 | -1 | +1 | -1 |
| d=1 | -1 | -1 | +1 | -1 | +1 |
| d=2 | +1 | -1 | +1 | -1 | +1 |
| d=3 | -1 | +1 | -1 | +1 | -1 |

| Node | After Iteration 2 |
| -- | -- |
| A | [+1, -1, -1, -1] |
| B | [+1, -1, +1, +1] |
| C | [+1, +1, -1, +1] |
| D | [+1, -1, +1, +1] |
| E | [+1, +1, +1, +1] |

**Iteration 3**: using new random sign vectors.

| | A | B | C | D | E |
| -- | -- | -- | -- | -- | -- |
| d=0 | -1 | +1 | -1 | +1 | -1 |
| d=1 | +1 | -1 | +1 | -1 | +1 |
| d=2 | -1 | +1 | +1 | -1 | -1 |
| d=3 | +1 | -1 | -1 | +1 | +1 |

**Normalize**: L2 norm = √4 = 2, so each entry becomes ±0.5.

| Node | After Iteration 3 | After L2 Normalization |
| -- | -- | -- |
| A | [-1, -1, +1, +1] | [-0.5, -0.5, 0.5, 0.5] |
| B | [+1, +1, -1, -1] | [0.5, 0.5, -0.5, -0.5] |
| C | [-1, -1, +1, -1] | [-0.5, -0.5, 0.5, -0.5] |
| D | [+1, -1, -1, +1] | [0.5, -0.5, -0.5, 0.5] |
| E | [-1, +1, -1, +1] | [-0.5, 0.5, -0.5, 0.5] |

`A` and `B` have opposite embeddings: they are structurally equivalent (both degree-2 in the triangle) but the random sign vectors assigned them opposite hash values. `C` is close to `A` (differ only in `d = 3`). `D` and `E` each have distinct signatures reflecting their different positions in the graph.

## Considerations

- The HashGNN algorithm treats all edges as undirected, ignoring their original direction.
- Embedding values are always `±1/√dimensions` (binary after normalization). This is by design — HashGNN produces structural hash signatures, not continuous embeddings.

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
| `dimensions` | `INT` | `64` | Embedding dimensionality (number of hash functions). |
| `iterations` | `INT` | `3` | Number of message-passing iterations. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `embedding` | `LIST` | Embedding vector as list of floats |

```gql
CALL algo.hashgnn({
  dimensions: 4,
  iterations: 3
}) YIELD nodeId, embedding
```

Result:

| nodeId | embedding |
| -- | -- |
| E | [-0.5, 0.5, 0.5, -0.5] |
| D | [0.5, -0.5, -0.5, 0.5] |
| G | [-0.5, -0.5, 0.5, 0.5] |
| F | [0.5, -0.5, 0.5, 0.5] |
| A | [0.5, -0.5, 0.5, -0.5] |
| C | [-0.5, 0.5, 0.5, 0.5] |
| B | [0.5, 0.5, -0.5, 0.5] |
| I | [-0.5, 0.5, -0.5, -0.5] |
| H | [-0.5, -0.5, -0.5, 0.5] |
| K | [-0.5, 0.5, 0.5, -0.5] |
| J | [-0.5, 0.5, 0.5, -0.5] |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.hashgnn.stream({
  dimensions: 4,
  iterations: 5
}) YIELD nodeId, embedding
RETURN nodeId, embedding
```

Result:

| nodeId | embedding |
| -- | -- |
| E | [-0.5, -0.5, 0.5, 0.5] |
| D | [-0.5, -0.5, 0.5, 0.5] |
| G | [-0.5, 0.5, 0.5, -0.5] |
| F | [0.5, 0.5, -0.5, 0.5] |
| A | [0.5, -0.5, -0.5, 0.5] |
| C | [0.5, -0.5, 0.5, -0.5] |
| B | [0.5, -0.5, 0.5, -0.5] |
| I | [0.5, -0.5, 0.5, -0.5] |
| H | [0.5, -0.5, -0.5, 0.5] |
| K | [-0.5, -0.5, 0.5, 0.5] |
| J | [0.5, 0.5, 0.5, -0.5] |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes processed |
| `dimensions` | `INT` | Embedding dimensionality |

```gql
CALL algo.hashgnn.stats({
  dimensions: 4
}) YIELD nodeCount, dimensions
```

Result:

| nodeCount | dimensions |
| -- | -- |
| 11 | 4 |

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
CALL algo.hashgnn.write({dimensions: 4}, {
  db: {
    property: "embedding"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
