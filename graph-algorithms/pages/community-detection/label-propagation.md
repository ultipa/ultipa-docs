# Label Propagation

## Overview

The Label Propagation algorithm (LPA) is a community detection method based on label propagation. Initially, each node is assigned a unique label. During each iteration, every node updates its label to the one most common among its neighbors. Through this iterative process, densely connected groups of nodes tend to reach a consensus on a shared label, with nodes sharing the same label ultimately forming a community.

LPA does not optimize any specific predefined measure of community quality, nor does it require the number of communities to be specified in advance. Instead, it relies purely on the network's structure to guide the progression. Its simplicity makes LPA highly efficient for analyzing large and complex networks.

Related material of the algorithm:

- U.N. Raghavan, R. Albert, S. Kumara, <a target="_blank" href="https://arxiv.org/pdf/0709.2938.pdf">Near linear time algorithm to detect community structures in large-scale networks</a> (2007)

## Concepts

### Label

Each node is initialized with a unique label (based on its internal ID). Nodes sharing the same label at the end of the algorithm are considered members of the same community.

### Label Propagation

At each propagation iteration, a node updates its label to the one held by the largest number of its neighbors.

For example, in the diagram below, the blue node's label will change from `d` to `c`.

<div align='center' drawio-diagram='6032' drawio-name="draw_d7f7a10b38974c9ea9559b8b3c22294b.jpg"><img src="https://img.ultipa.cn/draw/draw_d7f7a10b38974c9ea9559b8b3c22294b.jpg?v='1684995025103'"/></div>

## Considerations

- The algorithm treats all edges as undirected.
- A node with self-loops propagates its current label to itself, with each self-loop counted twice.
- LPA follows a synchronous update principle, where all nodes update their labels simultaneously based on their neighbors' current labels. However, in some cases—especially in bipartite graphs—label oscillations may occur.
- Due to factors such as the order of nodes, random tie-breaking when multiple labels have equal counts, and parallel computations, the results may vary between runs. Use the `seed` parameter for reproducibility.

## Example Graph

<div align=center><img src="images/lpa-example.drawio.svg"/></div>

Run the following statements on an empty graph to insert data:

```gql
INSERT (A:user {_id: "A"}), (B:user {_id: "B"}),
       (C:user {_id: "C"}), (D:user {_id: "D"}),
       (E:user {_id: "E"}), (F:user {_id: "F"}),
       (G:user {_id: "G"}), (H:user {_id: "H"}),
       (I:user {_id: "I"}), (J:user {_id: "J"}),
       (K:user {_id: "K"}), (L:user {_id: "L"}),
       (M:user {_id: "M"}), (N:user {_id: "N"}),
       (O:user {_id: "O"}),
       (A)-[:connect]->(B), (A)-[:connect]->(C),
       (A)-[:connect]->(F), (A)-[:connect]->(K),
       (B)-[:connect]->(C), (C)-[:connect]->(D),
       (D)-[:connect]->(A), (D)-[:connect]->(E),
       (E)-[:connect]->(A), (F)-[:connect]->(G),
       (F)-[:connect]->(J), (G)-[:connect]->(H),
       (H)-[:connect]->(F), (I)-[:connect]->(F),
       (I)-[:connect]->(H), (J)-[:connect]->(I),
       (K)-[:connect]->(F), (K)-[:connect]->(N),
       (L)-[:connect]->(M), (L)-[:connect]->(N),
       (M)-[:connect]->(K), (M)-[:connect]->(N),
       (N)-[:connect]->(M), (O)-[:connect]->(N)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `maxIterations` | `INT` | `100` | Maximum number of propagation iterations. |
| `seed` | `INT` | `0` | Random seed. `0` uses a time-based seed (non-deterministic). Any non-zero value produces reproducible results. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `community`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `community` | `INT` | Community identifier |
| `iterations` | `INT` | Number of iterations until convergence |

```gql
CALL algo.lpa({}) YIELD nodeId, community, iterations
```

Result:

| nodeId | community | iterations |
| -- | -- | -- |
| E | 0 | 3 |
| D | 0 | 3 |
| G | 1 | 3 |
| F | 1 | 3 |
| A | 0 | 3 |
| C | 0 | 3 |
| B | 0 | 3 |
| M | 2 | 3 |
| L | 2 | 3 |
| O | 2 | 3 |
| N | 2 | 3 |
| I | 1 | 3 |
| H | 1 | 3 |
| K | 2 | 3 |
| J | 1 | 3 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.lpa.stream() YIELD nodeId, community
RETURN community, COLLECT(nodeId) AS members, COUNT(nodeId) AS size
GROUP BY community
```

Result:

| community | members | size |
| -- | -- | -- |
| 0 | [E, D, A, C, B] | 5 |
| 1 | [G, F, I, H, J] | 5 |
| 2 | [M, L, O, N, K] | 5 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `communityCount` | `INT` | Number of communities detected |
| `largestCommunitySize` | `INT` | Size of the largest community |
| `smallestCommunitySize` | `INT` | Size of the smallest community |

```gql
CALL algo.lpa.stats() YIELD nodeCount, communityCount, largestCommunitySize, smallestCommunitySize
```

Result:

| nodeCount | communityCount | largestCommunitySize | smallestCommunitySize |
| -- | -- | -- | -- |
| 15 | 3 | 5 | 5 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `community` column in results to a property. Map: explicit column-to-property mapping (e.g., `{community: 'comm_id'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `community` | `INT` | Community identifier |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.lpa.write({}, {
  db: {
    property: "comm_id"                   // String: writes community to one property
    // property: {community: "comm_id"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
