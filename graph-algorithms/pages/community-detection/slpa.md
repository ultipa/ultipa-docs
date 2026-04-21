# SLPA

## Overview

The SLPA (Speaker-Listener Label Propagation Algorithm) detects overlapping communities, where nodes can belong to multiple communities simultaneously. Unlike standard <a href="/docs/graph-algorithms/label-propagation">Label Propagation</a> which assigns each node to exactly one community, SLPA maintains a memory of labels each node has received, allowing it to identify multiple community memberships.

References:

- J. Xie, B.K. Szymanski, X. Liu, <a href="https://arxiv.org/pdf/1109.5720" target="_blank">SLPA: Uncovering Overlapping Communities in Social Networks via a Speaker-listener Interaction Dynamic Process</a> (2011)

## Concepts

### Overlapping Communities

In many real-world networks, nodes naturally belong to multiple communities. For example, a person may belong to a work group, a family group, and a hobby group simultaneously.

Standard community detection algorithms assign each node to exactly one community. SLPA addresses this limitation by allowing nodes to have multiple community memberships.

### Speaker-Listener Propagation

The algorithm works through an iterative process where nodes exchange labels:

1. **Initialization**: Each node starts with its own unique label in its memory.
2. **Iterations**: In each iteration, all nodes are processed in random order. For each **listener** node:
   - Each neighbor (**speaker**) sends a random label from its memory.
   - The listener selects the most frequently received label and adds it to its memory. If there is a tie, one is chosen randomly.
3. **Post-processing**: After all iterations, each node's memory contains a history of labels. A label is kept as a community membership only if its frequency in memory meets the `threshold`.

<div align=center><img src="images/slpa-1.drawio.svg"/></div>

For example, in this graph:

- **Initialization**: Memory: `A=[0]`, `B=[1]`, `C=[2]`, `D=[3]`
- **Iteration 1**: Node `B` is selected as the listener. Its neighbors `A`, `C`, `D` each send a random label from their memory. Suppose they send `0`, `2`, `3`. The most frequent label is a tie — say `0` wins. `B`'s memory becomes `[1, 0]`. Then the algorithm selects another node as the listenser.
- **After 20 iterations**: `B`'s memory might be `[1, 0, 0, 2, 0, 2, 0, 2, ...]`, accumulating different labels from its neighbors over time. If both label `0` and label `2` each appear ≥ 10% of the time (e.g., `threshold: 0.1`), node `B` is assigned to both community `0` and community `2` — it is an **overlapping** node.

A lower `threshold` allows more overlapping memberships; a higher threshold produces fewer, more confident assignments.

## Considerations

- The algorithm treats all edges as undirected.
- Results may vary between runs due to random label selection and processing order.
- Each node belongs to at least one community.

## Example Graph

<div align=center><img src="images/slpa-example.drawio.svg"/></div>

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
| `iterations` | `INT` | `20` | Number of propagation iterations. |
| `threshold` | `FLOAT` | `0.1` | Label frequency threshold for community membership (0 < threshold ≤ 1). A label is kept only if its proportion in a node's memory is ≥ `threshold`. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `communities`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `communities` | `LIST` | List of community IDs the node belongs to |

```gql
CALL algo.slpa({
  iterations: 20,
  threshold: 0.1
}) YIELD nodeId, communities
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.slpa.stream({
  iterations: 20,
  threshold: 0.1
}) YIELD nodeId, communities
RETURN nodeId, communities
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `communityCount` | `INT` | Number of unique communities detected |

```gql
CALL algo.slpa.stats() YIELD nodeCount, communityCount
```

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `communities` column in results to a property. Map: explicit column-to-property mapping (e.g., `{communities: 'comm_list'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `communities` | `LIST` | List of community IDs |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.slpa.write({iterations: 20, threshold: 0.1}, {
  db: {
    property: "comm_list"                          // String: writes communities to one property
    // property: {communities: "comm_list"}         // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
