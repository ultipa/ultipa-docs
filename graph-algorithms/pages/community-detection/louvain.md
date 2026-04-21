# Louvain

## Overview

The Louvain algorithm is a widely used and and well-regarded method for community detection in graphs. It is named after the location of its authors - Vincent D. Blondel et al. from Université catholique de Louvain in Belgium. The algorithm aims to maximize the modularity of the graph, and it has gained popularity due to its efficiency and the quality of its results.

- V.D. Blondel, J. Guillaume, R. Lambiotte, E. Lefebvre, <a target="_blank" href="http://arxiv.org/pdf/0803.0476.pdf">Fast unfolding of communities in large networks</a> (2008)
- H. Lu, <a target="_blank" href="https://arxiv.org/pdf/1410.1237.pdf">Parallel Heuristics for Scalable Community Detection</a> (2014)

## Concepts

### Modularity

The Louvain algorithm is designed to find partitions that maximize <a href="/docs/graph-algorithms/modularity">modularity</a>, a measure of community partition quality that compares the density of edges within communities to what would be expected in a random graph.

### Louvain

The Louvain algorithm begins with a singleton partition, where each node belongs to its own community. It then proceeds iteratively through multiple passes, each consisting of two distinct phases.

#### Phase 1: Modularity Optimization

For each node `i`, the algorithm considers all its neighbors `j` and calculates the <b>gain of modularity</b> (`ΔQ`) that would result from moving `i` from its current community to the community of `j`. 

Node `i` is reassigned to the community that yields the maximum `ΔQ`, provided that this gain exceeds a predefined positive threshold. If no such gain is found, `i` remains in its original community. 

<div align=center drawio-diagram='6403' drawio-name="draw_f14c5c57dd3b40a8a46c4c046c32bdb9.jpg"><img src="https://img.ultipa.cn/draw/draw_f14c5c57dd3b40a8a46c4c046c32bdb9.jpg?v='1690363130608'"/></div>

Take the graph above as an example, where nodes belonging to the same community are denoted with the same color. Now, consider node `d`. The modularity gains from moving it into the community `{a,b}`, `{c}`, and `{e,f}` are:

- ΔQ<sub>d→{a,b}</sub> = Q<sub>{a,b,d}</sub> - (Q<sub>{a,b}</sub> + Q<sub>{d}</sub>) = 52/900
- ΔQ<sub>d→{c}</sub> = Q<sub>{c,d}</sub> - (Q<sub>{c}</sub> + Q<sub>{d}</sub>) = 72/900
- ΔQ<sub>d→{e,f}</sub> = Q<sub>{d,e,f}</sub> - (Q<sub>{e,f}</sub> + Q<sub>{d}</sub>) = 36/900

If <code>ΔQ<sub>d→{c}</sub></code> exceeds the predefined threshold of `ΔQ`, node `d` will be moved to community `{c}`; otherwise, it remains in its original community.

This process is applied sequentially to all nodes and repeated until no further individual move yields an improvement in modularity, or the maximum loop number is reached, completing the first phase. 

#### Phase 2: Community Aggregation

In the second phase, each community is aggregated into a single node. Each of these aggregated nodes has a self-loop whose weight equals the total weight of intra-community edges. The weight of the edge between any two aggregated nodes corresponds to the sum of the weights of all edges between nodes in the respective original communities.

<div align=center drawio-diagram='6398' drawio-name="draw_0634eed944f244749b84757c76f13d57.jpg"><img src="https://img.ultipa.cn/draw/draw_0634eed944f244749b84757c76f13d57.jpg?v='1691655640565'"/></div>

Community aggregation reduces the number of nodes and edges in the graph without altering local or global edge weights. After this compression, nodes within a community are treated as a single unit, allowing modularity optimization to continue at a higher level. This results in a hierarchical (iterative), multi-level community structure.

Once this second phase is completed, the algorithm applies another pass on the aggregated graph. hese passes repeat iteratively until no further modularity gains can be achieved, at which point the final community structure is established.

## Considerations

- If node `i` has any self-loop, when calculating <code>k<sub>i</sub></code>, the weight of self-loop is counted only once.
- The Louvain algorithm treats all edges as undirected, ignoring their original direction.
- The output of the Louvain algorithm may vary across executions due to the order in which nodes are processed. However, this variation typically has little impact on the final modularity value.

## Example Graph

<div align=center drawio-diagram='20030' drawio-name='draw_60a63ca3c6df4dac9f7ffe19ee2519f3.jpg'><img src="https://img.ultipa.cn/draw/draw_60a63ca3c6df4dac9f7ffe19ee2519f3.jpg?v='1735530968114'"/></div>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (I:default {_id: "I"}), (J:default {_id: "J"}),
       (K:default {_id: "K"}), (L:default {_id: "L"}),
       (M:default {_id: "M"}), (N:default {_id: "N"}),
       (A)-[:default {weight: 1}]->(B), (A)-[:default {weight: 1.7}]->(C),
       (A)-[:default {weight: 0.6}]->(D), (A)-[:default {weight: 1}]->(E),
       (B)-[:default {weight: 3}]->(G), (F)-[:default {weight: 1.6}]->(A),
       (F)-[:default {weight: 0.3}]->(H), (F)-[:default {weight: 2}]->(J),
       (F)-[:default {weight: 0.5}]->(K), (G)-[:default {weight: 2}]->(F),
       (I)-[:default {weight: 1}]->(F), (K)-[:default {weight: 0.3}]->(A),
       (K)-[:default {weight: 0.8}]->(L), (K)-[:default {weight: 1.2}]->(M),
       (K)-[:default {weight: 2}]->(N)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `maxLevels` | `INT` | `10` | Maximum hierarchy levels for multi-level optimization. |
| `phase1MaxIterations` | `INT` | `5` | Maximum iterations per Phase 1 optimization pass. |
| `minImprovement` | `FLOAT` | `0.0001` | Minimum modularity improvement to continue optimization. |
| `weight` | `STRING` | / | Numeric edge property to use as weight. If unset, all edges have unit weight. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by community size: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `community` | `INT` | Community identifier |
| `level` | `INT` | Hierarchy level |
| `modularity` | `FLOAT` | Final modularity score |

```gql
CALL algo.louvain({
  phase1MaxIterations: 5,
  minImprovement: 0.1,
  weight: "weight"
}) YIELD nodeId, community, level, modularity
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.louvain.stream({
  weight: "weight"
}) YIELD nodeId, community
RETURN community, COLLECT(nodeId) AS members
GROUP BY community
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `communityCount` | `INT` | Number of communities detected |
| `largestCommunitySize` | `INT` | Size of the largest community |
| `smallestCommunitySize` | `INT` | Size of the smallest community |
| `modularity` | `FLOAT` | Final modularity score |

```gql
CALL algo.louvain.stats({
  weight: "weight"
}) YIELD nodeCount, communityCount, largestCommunitySize, smallestCommunitySize, modularity
```

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `community` column in results to a property. Map: explicit column-to-property mapping (e.g., `{community: 'comm_id', level: 'lvl'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `community` | `INT` | Community identifier |
| `level` | `INT` | Hierarchy level |
| `modularity` | `FLOAT` | Final modularity score |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.louvain.write({weight: "weight"}, {
  db: {
    property: "community_id"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
