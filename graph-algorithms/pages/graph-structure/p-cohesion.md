# p-Cohesion

## Overview

The p-Cohesion algorithm identifies groups of nodes that are highly connected with each other, represented by cohesive subgraphs. It reveals the level of connectivity and interdependence within these groups, supporting in-depth analysis of graph structure and behavior.

The concept of p-cohesion was first proposed by S. Morris in a contagion model describing interactions within large populations:

- S. Morris, <a target='blank' href="http://snap.stanford.edu/class/cs224w-readings/morris98contagion.pdf">Contagion</a>. The Review of Economic Studies, 67(1), 57–78 (2000)

## Concepts

### p-Cohesion

One natural measure of the **cohesion** of a group is the relative frequency of ties among its members compared to non-members. Let cohesion be a constant `p` ∈ (0,1). A <b>p-Cohesion</b> is a connected subgraph in which every node has, at least, a proportion `p` of its neighbors within the subgraph. In other words, each node has at most, a proportion `(1 − p)` of its neighbors outside the subgraph.

The p-Cohesion model offers two key advantages over other cohesive subgraph models:

- With a high `p` value, p-Cohesion ensures both strong internal cohesiveness and sparse connections to outside nodes.
- It considers the proportion of neighbors within the group rather than a fixed number (such as the `k` value in <a href="/docs/graph-algorithms/k-core">k-Core</a>), making it better suited for graphs with varying node degrees.

The example graph below illustrates this. Suppose `p = 0.6`. A grey label next to each node shows the minimum number of internal neighbors required for the node to remain in a p-Cohesion.

<div align='center' drawio-diagram='6166' drawio-name="draw_ffcc9719bb274bcfbf8e12a701061851.jpg"><img src="https://img.ultipa.cn/draw/draw_ffcc9719bb274bcfbf8e12a701061851.jpg?v='1686797368509'"/></div>

Below are the minimal p-Cohesion subgraphs, in terms of node count, that include node `a` and node `j`, respectively.

<div align='center' drawio-diagram='6168' drawio-name="draw_78908f02c70f425bacaa4146c8f0687d.jpg"><img src="https://img.ultipa.cn/draw/draw_78908f02c70f425bacaa4146c8f0687d.jpg?v='1687921148878'"/></div>

## Considerations

- The algorithm treats all edges as undirected.

## Example Graph

<div align='center' drawio-diagram='6236' drawio-name='draw_8154c0855e72495cb96b11dc28dd52c1.jpg'><img src="https://img.ultipa.cn/draw/draw_8154c0855e72495cb96b11dc28dd52c1.jpg?v='1687920551178'"/></div>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (I:default {_id: "I"}), (J:default {_id: "J"}),
       (K:default {_id: "K"}), (L:default {_id: "L"}),
       (K)-[:default]->(J), (K)-[:default]->(L),
       (J)-[:default]->(L), (L)-[:default]->(C),
       (C)-[:default]->(A), (A)-[:default]->(B),
       (C)-[:default]->(B), (A)-[:default]->(D),
       (B)-[:default]->(G), (B)-[:default]->(D),
       (D)-[:default]->(C), (C)-[:default]->(E),
       (C)-[:default]->(F), (D)-[:default]->(E),
       (E)-[:default]->(F), (D)-[:default]->(F),
       (D)-[:default]->(H), (I)-[:default]->(H),
       (F)-[:default]->(I)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `p` | `FLOAT` | / | **Required.** Cohesion threshold (0 < p ≤ 1). Each node in the p-cohesive set must have at least a proportion `p` of its neighbors also in the set. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `inCohesiveSet` | `INT` | 1 if the node is in the p-cohesive set, 0 otherwise |

```gql
CALL algo.pcohesion({
  p: 0.7
}) YIELD nodeId, inCohesiveSet
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.pcohesion.stream({
  p: 0.7
}) YIELD nodeId, inCohesiveSet
FILTER inCohesiveSet = 1
RETURN nodeId
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `cohesiveSetSize` | `INT` | Number of nodes in the p-cohesive set |
| `cohesionRatio` | `FLOAT` | Ratio of cohesive set size to total nodes |

```gql
CALL algo.pcohesion.stats({
  p: 0.7
}) YIELD nodeCount, cohesiveSetSize, cohesionRatio
```

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `inCohesiveSet` column in results to a property. Map: explicit column-to-property mapping (e.g., `{inCohesiveSet: 'cohesive'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `inCohesiveSet` | `INT` | 1 if in cohesive set, 0 otherwise |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.pcohesion.write({p: 0.7}, {
  db: {
    property: "cohesive"                          // String: writes inCohesiveSet to one property
    // property: {inCohesiveSet: "cohesive"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
