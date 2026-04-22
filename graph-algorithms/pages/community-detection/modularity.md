# Modularity

## Overview

The Modularity algorithm evaluates the quality of an existing community partition by computing its modularity score. Unlike community detection algorithms that find communities, this algorithm measures how good a given partition is.

It is typically used after running a community detection algorithm (such as <a href="/docs/graph-algorithms/louvain">Louvain</a> and <a href="/docs/graph-algorithms/leiden">Leiden</a>) to assess the quality of the detected communities.

## Concepts

### Modularity

In many networks, nodes tend to naturally form groups or communities, characterized by dense connections within a community and relatively sparse connections between communities.

<center><img src="images/modularity-1.jpg"/></center>

Consider an equivalent network `G'` to `G`, where `G'` remains the same community partition and the same number of edges as in `G`, but the edges are placed randomly. If `G` has a strong community structure, the ratio of intra-community edges to the total number of edges in `G` should be higher than the expected ratio in `G'`. A greater disparity between the actual ratio and expected ratios indicates a more prominent community structure in `G`. This concept forms the basis of <b>modularity</b>. The modularity is one of the widely used methods to evaluate the quality of a community partition. The Louvain algorithm is designed to find partitions that maximize modularity.

Modularity is a value that ranges from -1 to 1. A value close to 1 indicates a strong community structure, while negative values imply that the partitioning is likely not meaningful. For a connected graph, the modularity generally falls within the range of -0.5 to 1. 

Considering the weights of edges in the graph, the modularity (`Q`) is defined as

<center><img width=320 src="images/modularity-2.png"></center>

where,

- `m` is the total sum of edge weights in the graph;
- <code>A<sub>ij</sub></code> is the sum of edge weights between nodes `i` and `j`, and <code>2m = ∑<sub>ij</sub>A<sub>ij</sub></code>;
- <code>k<sub>i</sub></code> is the sum of weights of all edges attached to node `i`;
- <code>C<sub>i</sub></code> represents the community to which node iis assigned, <code>δ(C<sub>i</sub>,C<sub>j</sub>)</code> is 1 if <code>C<sub>i</sub>= C<sub>j</sub></code>, and 0 otherwise.

Note, <code><math><mfrac><mn><math><msub><mi>k</mi><mn>i</mn></msub><msub><mi>k</mi><mn>j</mn></msub></math></mn><mi>2m</mi></mfrac></math></code> is the expected sum of weights of edges between nodes i and j if edges are placed at random. Both <code>A<sub>ij</sub></code> and <code><math><mfrac><mn><math><msub><mi>k</mi><mn>i</mn></msub><msub><mi>k</mi><mn>j</mn></msub></math></mn><mi>2m</mi></mfrac></math></code> are divided by 2m because each pair of distinct nodes in a community is considered twice, such as <code>A<sub>ab</sub> = A<sub>ba</sub></code>, <code><math><mfrac><mn><math><msub><mi>k</mi><mn>a</mn></msub><msub><mi>k</mi><mn>b</mn></msub></math></mn><mi>2m</mi></mfrac></math> = <math><mfrac><mn><math><msub><mi>k</mi><mn>b</mn></msub><msub><mi>k</mi><mn>a</mn></msub></math></mn><mi>2m</mi></mfrac></math></code>.

We can also write the above formula as the following:

<center><img width=260 src="images/modularity-3.png"></center>

where,

- <code><math><mmultiscripts><mi>∑</mi><mi>in</mi><mi>c</mi></mmultiscripts></math></code> is the sum of weights of edges inside community `C`, i.e., the <b>intra-community weight</b>;
- <code><math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi>c</mi></mmultiscripts></math></code> is the sum of weights of edges incident to nodes in community `C`, i.e, the <b>total-community weight</b>;
- `m` has the same meaning as above, and <code>2m = ∑<sub>c</sub><math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi>c</mi></mmultiscripts></math></code>.

<center><img src="images/modularity-4.jpg"/></center>

Nodes in this graph are assigned into 3 communities, take community <code>C<sub>1</sub></code> as example:

- <math><mmultiscripts><mi>∑</mi><mi>in</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math> = A<sub>aa</sub> + A<sub>ab</sub> + A<sub>ac</sub> + A<sub>ad</sub> + A<sub>ba</sub> + A<sub>ca</sub> + A<sub>da</sub> = 1.5 + 1 + 0.5 + 3 + 1 + 0.5 + 3 = 10.5
- (<math><mmultiscripts><mi>∑</mi><mi>tot</mi><mi><math><msub><mi>C</mi><mn>1</mn></msub></math></mi></mmultiscripts></math>)<sup>2</sup> = k<sub>a</sub>k<sub>a</sub> + k<sub>a</sub>k<sub>b</sub> + k<sub>a</sub>k<sub>c</sub> + k<sub>a</sub>k<sub>d</sub> + k<sub>b</sub>k<sub>a</sub> + k<sub>b</sub>k<sub>b</sub> + k<sub>b</sub>k<sub>c</sub> + k<sub>b</sub>k<sub>d</sub> + k<sub>c</sub>k<sub>a</sub> + k<sub>c</sub>k<sub>b</sub> + k<sub>c</sub>k<sub>c</sub> + k<sub>c</sub>k<sub>d</sub> + k<sub>d</sub>k<sub>a</sub> + k<sub>d</sub>k<sub>b</sub> + k<sub>d</sub>k<sub>c</sub> + k<sub>d</sub>k<sub>d</sub> + = (k<sub>a</sub> + k<sub>b</sub> + k<sub>c</sub> + k<sub>d</sub>)<sup>2</sup> = (6 + 2.7 + 2.8 + 3)<sup>2</sup> = 14.5<sup>2</sup>

## Considerations

- The algorithm treats all edges as undirected.
- Community assignments are read from a node property specified by `communityProperty`. If not specified, each node is treated as its own community.

## Example Graph

<center><img src="images/modularity-example.drawio.svg"/></center>

```gql
INSERT (A:default {_id: "A", comm_id: 0}), (B:default {_id: "B", comm_id: 0}),
       (C:default {_id: "C", comm_id: 0}), (D:default {_id: "D", comm_id: 1}),
       (E:default {_id: "E", comm_id: 1}), (F:default {_id: "F", comm_id: 1}),
       (G:default {_id: "G", comm_id: 2}), (H:default {_id: "H", comm_id: 2}),
       (A)-[:default]->(B), (A)-[:default]->(C),
       (B)-[:default]->(C), (A)-[:default]->(D),
       (D)-[:default]->(E), (D)-[:default]->(F),
       (E)-[:default]->(F), (G)-[:default]->(D),
       (G)-[:default]->(H)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `communityProperty` | `STRING` | / | Node property storing community assignments. If not specified, each node is treated as its own community. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `modularity` | `FLOAT` | Overall modularity score Q |
| `communityCount` | `INT` | Number of communities |

```gql
CALL algo.modularity({
  communityProperty: "comm_id"
}) YIELD modularity, communityCount
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.modularity.stream({
  communityProperty: "comm_id"
}) YIELD modularity, communityCount
RETURN modularity, communityCount
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `modularity` | `FLOAT` | Overall modularity score Q |
| `communityCount` | `INT` | Number of communities |

```gql
CALL algo.modularity.stats({
  communityProperty: "comm_id"
}) YIELD nodeCount, modularity, communityCount
```
