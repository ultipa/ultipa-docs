# HDBSCAN

## Overview

HDBSCAN (Hierarchical Density-Based Spatial Clustering of Applications with Noise) is a density-based clustering algorithm that finds clusters of varying density and identifies outlier (noise) nodes.

- R.J.G.B. Campello, D. Moulavi, J. Sander, <a target="_blank" href="https://link.springer.com/chapter/10.1007/978-3-642-37456-2_14">Density-Based Clustering Based on Hierarchical Density Estimates</a> (2013)

## Concepts

### Density-Based Clustering

Unlike algorithms like k-Means that partition all nodes into clusters, HDBSCAN finds clusters based on **density**: tightly connected regions of the graph form clusters, while loosely connected nodes are treated as **noise** (outliers). This means HDBSCAN can discover clusters of different sizes and shapes, and it doesn't require specifying the number of clusters.

In the HDBSCAN algorithm, **distance** between two nodes is the shortest-path length (hop count) between them. The **core distance** of a node answers the question: "How far does a node need to reach to find **at least** k nearby neighbors?"

<div align=center><img src="images/hdbscan-1.drawio.svg"/></div>

For example, to find at least 3 neighbors:

- Node `A` needs 2 hops (1 hop reaches `B` and `F`, 2 hops reaches `C` or `G`) → <code>dist<sub>core</sub>(A) = 2</code>
- Node `B` only needs 1 hop (reaches `A`, `C`, and `G`) → <code>dist<sub>core</sub>(B) = 1</code>
- Node `E` needs 3 hops (1 hop reaches `D`, 2 hops reaches `C`, 3 hops reaches `B` or `G`) → <code>dist<sub>core</sub>(E) = 3</code>

A node in a dense region has a small core distance, while a node in a sparse region has a large core distance.

The **mutual reachability distance** between two nodes `A` and `B` is:

<div align=center><img width="250" src="images/hdbscan-2.png"/></div>

This smooths out density differences — connections between dense and sparse regions are penalized, which helps prevent sparse nodes from being pulled into dense clusters.

Consider the graph above with minimum 3 neighbors to find:

- <code>mreach(A,B) = max(2,1,1) = 2</code>
- <code>mreach(A,E) = max(2,3,4) = 4</code>
- <code>mreach(B,E) = max(1,3,3) = 3</code>

The mutual reachability distance between `A` and `B` is smaller than each of them with `E`. This makes sparse-region connections weaker.

### Hierarchical Clustering and Cluster Extraction

**Step 1: Build a <a href="/docs/graph-algorithms/minimum-spanning-tree">minimum spanning tree (MST)</a>** using mutual reachability distances as edge weights.

<div align=center><img width="250" src="images/hdbscan-3.drawio.svg"/></div>

**Step 2: Build and condense the cluster hierarchy.** Sort MST edges from longest to shortest and remove them one at a time. Each removal splits a component. If a split produces a child smaller than `minClusterSize`, those nodes "fall out" of the parent rather than forming a new cluster.

| Edge removed | Weight | Split | Result |
| -- | -- | -- | -- |
| `D-E` | 3 | `{A,B,C,D,F,G}` and `{E}` | `{E}` size < 3, falls out of parent |
| `A-F` | 3 | `{A,B,C,D,G}` and `{F}` | `{F}` size < 3, falls out of parent |
| `C-D` | 2 | `{A,B,G}` and `{D}` | `{D}` size < 3, falls out of parent |
| `B-G` | 2 | `{A,B}` and `{G}` | Both size < 3, cluster dissolves |

This produces a hierarchy of candidate clusters: the full group `{A,B,C,D,E,F,G}` (exists from the start until weight 3) and the sub-cluster `{A,B,C,D,G}` (exists from weight 3 to weight 2).

**Step 3: Extract the most stable clusters.** The algorithm compares the **stability** of each cluster — how long it persists before splitting. A parent cluster is selected if its own stability exceeds the combined stability of its children.

In this example:
- `{A,B,C,D,E,F,G}` persists from the maximum distance down to weight 3 (wide range)
- `{A,B,C,D,G}` persists only from weight 3 to weight 2 (narrow range)

The parent cluster has higher stability, so the algorithm keeps all 7 nodes in **one cluster** — no node is labeled as noise.

### Outlier Detection

Each node receives an **outlier score** between 0 and 1, computed from its core distance on the original graph:

- Noise nodes: outlier score = `1.0`
- Clustered nodes: outlier score = `coreDist / (coreDist + 1)`

Nodes in denser regions (smaller core distance) get lower outlier scores. In this example, all nodes are in one cluster, but their outlier scores still differ:

| Node | Cluster | Core distance | Outlier score |
| -- | -- | -- | -- |
| `B` | 0 | 1 | 1/(1+1) = 0.5 |
| `C` | 0 | 1 | 1/(1+1) = 0.5 |
| `A` | 0 | 2 | 2/(2+1) ≈ 0.667 |
| `D` | 0 | 2 | 2/(2+1) ≈ 0.667 |
| `G` | 0 | 2 | 2/(2+1) ≈ 0.667 |
| `E` | 0 | 3 | 3/(3+1) = 0.75 |
| `F` | 0 | 3 | 3/(3+1) = 0.75 |

Even within the same cluster, `E` and `F` have higher outlier scores because they are in sparser regions of the graph.

## Considerations

- The algorithm treats edges as undirected for distance computation.
- The minimum cluster size (`minClusterSize`) and the number of neighbors (`minSamples`) used to compute core distance both significantly affect results — smaller values produce more, smaller clusters; larger values produce fewer, denser clusters.

## Example Graph

Run the following statements on an empty graph to insert data:

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (I:default {_id: "I"}), (J:default {_id: "J"}),
       (A)-[:default]->(B), (A)-[:default]->(C),
       (B)-[:default]->(C), (B)-[:default]->(D),
       (C)-[:default]->(D), (D)-[:default]->(E),
       (E)-[:default]->(F), (F)-[:default]->(G),
       (G)-[:default]->(H), (H)-[:default]->(I),
       (I)-[:default]->(J), (J)-[:default]->(H)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `minClusterSize` | `INT` | `5` | Minimum number of nodes to form a cluster. |
| `minSamples` | `INT` | `5` | Minimum samples used to compute core distance. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `cluster`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `cluster` | `INT` | Cluster assignment (-1 = noise) |
| `outlierScore` | `FLOAT` | Outlier score (higher = more likely outlier) |

```gql
CALL algo.hdbscan({
  minClusterSize: 3,
  minSamples: 2
}) YIELD nodeId, cluster, outlierScore
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.hdbscan.stream({
  minClusterSize: 3,
  minSamples: 2
}) YIELD nodeId, cluster
RETURN cluster, COLLECT(nodeId) AS members, COUNT(nodeId) AS size
GROUP BY cluster
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `clusterCount` | `INT` | Number of clusters (excluding noise) |
| `noiseCount` | `INT` | Number of noise points |
| `avgOutlierScore` | `FLOAT` | Average outlier score |

```gql
CALL algo.hdbscan.stats({
  minClusterSize: 3,
  minSamples: 2
}) YIELD nodeCount, clusterCount, noiseCount, avgOutlierScore
```

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `cluster` column in results to a property. Map: explicit column-to-property mapping (e.g., `{cluster: 'hdb_cluster', outlierScore: 'hdb_outlier'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `cluster` | `INT` | Cluster assignment |
| `outlierScore` | `FLOAT` | Outlier score |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier |
| `status` | `STRING` | Task status (`running`) |

The write executes asynchronously in the background. Use `SHOW TASKS` with the `task_id` to check progress and results.

```gql
CALL algo.hdbscan.write({minClusterSize: 3, minSamples: 2}, {
  db: {
    property: "hdb_cluster"                                              // String: writes cluster to one property
    // property: {cluster: "hdb_cluster", outlierScore: "hdb_outlier"}   // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
