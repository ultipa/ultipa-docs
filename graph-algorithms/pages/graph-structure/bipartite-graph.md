# Bipartite Graph

## Overview

The Bipartite algorithm determines whether a given graph is a bipartite graph and assigns each node to one of two partitions. The algorithm uses BFS 2-coloring to identify and leverage the structure of bipartite graphs, enabling efficient resource allocation, task assignment, and group optimization.

## Concepts

### Bipartite Graph

A <b>bipartite graph</b>, also known as a bigraph, is a graph in which the nodes can be divided into two disjoint sets such that every edge connects a node from one set to a node in the other. In other words, no edge connects nodes within the same set.

<div align='center' drawio-diagram='6224' drawio-name='draw_09f0df44a94043b7967dcccf4ea2d334.jpg'><img src="https://img.ultipa.cn/draw/draw_09f0df44a94043b7967dcccf4ea2d334.jpg?v='1687849019862'"/></div>

This example graph is bipartite. The nodes can be partitioned into sets <code>>V<sub>1</sub> = {A, D, E}</code> and <code>V<sub>2</sub> = {B, C, F}</code>.

### Coloring Method

To determine if a graph is bipartite, one common approach is to perform a graph traversal and assign each visited node to one of two different sets. This process is often referred to as "coloring" the nodes. During traversal, if an edge is found that connects two nodes within the same set, the graph is not bipartite. Conversely, if all edges connect nodes from different sets, the graph is bipartite.

<div align='center' drawio-diagram='6225' drawio-name="draw_e29ad8de09194018a02043ce327e0c7a.jpg"><img src="https://img.ultipa.cn/draw/draw_e29ad8de09194018a02043ce327e0c7a.jpg?v='1687852215405'"/></div>

In this example, both graph <i>A</i> and graph <i>B</i> are bipartite. Graph <i>C</i> is not bipartite as it contains an odd cycle. An <b>odd cycle</b> is a cycle that has an odd number of nodes. Bipartite graphs cannot contain odd cycles, as it is impossible to color all nodes in an odd cycle using only two colors while satisfying the bipartite condition.

## Considerations

- A self-loop connects a node to itself, meaning both endpoints are the same node. Therefore, any graph containing a self-loop is not bipartite.
- The algorithm treats all edges as undirected.

## Example Graph

<div align='center' drawio-diagram='2575' drawio-name="draw_b0aa1fe06ff644a586830c3b254cd1e0.jpg"><img src="https://img.ultipa.cn/draw/draw_b0aa1fe06ff644a586830c3b254cd1e0.jpg?v='1657173154014'"/></div>

```gql
INSERT (a:default {_id: "a"}), (b:default {_id: "b"}),
       (c:default {_id: "c"}), (d:default {_id: "d"}),
       (e:default {_id: "e"}), (f:default {_id: "f"}),
       (a)-[:default]->(b), (a)-[:default]->(d),
       (c)-[:default]->(b), (d)-[:default]->(c),
       (d)-[:default]->(e), (e)-[:default]->(b),
       (f)-[:default]->(a), (f)-[:default]->(e)
```

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `partition` | `INT` | Partition assignment (0 or 1; -1 if the component is not bipartite) |
| `isBipartite` | `INT` | 1 if the component containing this node is bipartite, 0 otherwise |

```gql
CALL algo.bipartite() YIELD nodeId, partition, isBipartite
```

Result:

| nodeId | partition | isBipartite |
| -- | -- | -- |
| e | 0 | 1 |
| d | 1 | 1 |
| f | 1 | 1 |
| a | 0 | 1 |
| c | 0 | 1 |
| b | 1 | 1 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.bipartite.stream() YIELD nodeId, partition
RETURN partition, COLLECT(nodeId) AS nodes
GROUP BY partition
```

Result:

| partition | nodes |
| -- | -- |
| 0 | ["e", "a", "c"] |
| 1 | ["d", "f", "b"] |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `isBipartite` | `INT` | 1 if the entire graph is bipartite, 0 otherwise |
| `partition0Size` | `INT` | Number of nodes in partition 0 |
| `partition1Size` | `INT` | Number of nodes in partition 1 |
| `componentCount` | `INT` | Number of connected components |

```gql
CALL algo.bipartite.stats() YIELD nodeCount, isBipartite, partition0Size, partition1Size, componentCount
```

Result:

| nodeCount | isBipartite | partition0Size | partition1Size | componentCount |
| -- | -- | -- | -- | -- |
| 6 | 1 | 3 | 3 | 1 |
