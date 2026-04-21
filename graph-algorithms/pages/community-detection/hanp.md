# HANP

## Overview

The HANP (Hop Attenuation & Node Preference) algorithm extends the traditional <a target="_blank" href="/docs/graph-analytics-algorithms/label-propagation">Label Propagation algorithm (LPA)</a> by incorporating a label score attenuation mechanism. The goal of HANP is to improve the accuracy and robustness of community detection in networks. It was proposed in 2009:

- I.X.Y. Leung, P. Hui, P. Liò, J. Crowcroft, <a target="_blank" href="https://arxiv.org/pdf/0808.2633.pdf">Towards real-time community detection in large networks</a> (2009)

## Concepts

### Hop Attenuation

HANP associates each label with a <b>score</b> which decreases as it propagates from its origin. Initially, all labels are assigned a score of 1. Each time a node adopts a new label from its neighborhood, the score of that label is attenuated by subtracting a <b>hop attenuation</b> factor <i>δ</i> (0 < <i>δ</i> ≤ 1).

The hop attenuation mechanism helps limit the spread of labels to nearby nodes and prevents any single label from dominating the entire network.

### Node Preference

In the calculation of the new maximal label, HANP incorporates <b>node preference</b> based on node degree. When node <i>j ∈ N<sub>i</sub></i> propagates its label <i>L</i> to node <i>i</i>, the weight of label <i>L</i> is calculated by:

<center><img width=250 src="https://img.ultipa.cn/img/2023-05-29-11-47-33-hanp1.jpg"></center>

where,

- <i>s<sub>j</sub>(L)</i> is the score of label <i>L</i> in <i>j</i>.
- <i>deg<sub>j</sub></i> is the degree of <i>j</i>. When <i>m</i> > 0, more preference is given to nodes with high degree; <i>m</i> < 0, more preference is given to nodes with low degree; <i>m</i> = 0, no node preference is applied.
- <i>w<sub>ij</sub></i> is the sum of edge weights between <i>i</i> and <i>j</i>.

Given the edge weights and label scores shown in the example below, if we set <i>m</i> = 2 and <i>δ</i> = 0.2, the blue node will update its label from `d` to `a`. The score of label `a` in the blue node will be attenuated to 0.6.

<div align='center' drawio-diagram='6049' drawio-name="draw_611cb47526b74a4db1b4c70a7040e6da.jpg"><img src="https://img.ultipa.cn/draw/draw_611cb47526b74a4db1b4c70a7040e6da.jpg?v='1685333790738'"/></div>

## Considerations

- The algorithm treats all edges as undirected.
- Due to factors such as the order of nodes, random selection among labels with equal weights, and parallel computations, the results may vary between runs.

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
| `maxIterations` | `INT` | `10` | Maximum number of propagation iterations. |
| `delta` | `FLOAT` | `0.5` | Hop attenuation factor (0 < δ ≤ 1). Higher values cause labels to decay faster. |
| `m` | `FLOAT` | `0` | Node degree preference exponent. `m` > 0 favors high-degree nodes; `m` < 0 favors low-degree; `m` = 0 no preference. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `community`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `community` | `INT` | Community identifier |

```gql
CALL algo.hanp({
  maxIterations: 10,
  m: 0,
  delta: 0.5
}) YIELD nodeId, community
```

Result:

| nodeId | community |
| -- | -- |
| E | 0 |
| D | 0 |
| G | 1 |
| F | 2 |
| A | 0 |
| C | 0 |
| B | 0 |
| M | 2 |
| L | 0 |
| O | 0 |
| N | 2 |
| I | 1 |
| H | 2 |
| K | 0 |
| J | 1 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.hanp.stream({
  maxIterations: 10,
  m: 0,
  delta: 0.5
}) YIELD nodeId, community
RETURN community, COLLECT(nodeId) AS members
GROUP BY community
```

Result:

| community | members |
| -- | -- |
| 0 | [E, D, A, C, B, L, O, K] |
| 1 | [G, I, J] |
| 2 | [F, M, N, H] |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `communityCount` | `INT` | Number of communities detected |
| `largestCommunitySize` | `INT` | Size of the largest community |
| `smallestCommunitySize` | `INT` | Size of the smallest community |

```gql
CALL algo.hanp.stats({
  delta: 0.2
}) YIELD nodeCount, communityCount, largestCommunitySize, smallestCommunitySize
```

Result:

| nodeCount | communityCount | largestCommunitySize | smallestCommunitySize |
| -- | -- | -- | -- |
| 15 | 3 | 8 | 3 |

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
CALL algo.hanp.write({delta: 0.2}, {
  db: {
    property: "comm_id"                   // String: writes community to one property
    // property: {community: "comm_id"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
