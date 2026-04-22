# Clique Count

## Overview

The Clique Count algorithm finds all maximal cliques in a graph using the <a href="https://en.wikipedia.org/wiki/Bron%E2%80%93Kerbosch_algorithm" target="_blank">Bron-Kerbosch algorithm</a>, and reports per-node clique participation. A clique is a subset of nodes where every pair is directly connected. A maximal clique is a clique that cannot be extended by adding any adjacent node.

## Concepts

### Clique

A **clique** is a complete subgraph — a set of nodes where every pair is connected by an edge. The size of a clique is the number of nodes it contains:

- A **2-clique** is a single edge between two nodes.
- A **3-clique** (triangle) is three mutually connected nodes.
- A **k-clique** is a set of k nodes where all `k*(k-1)/2` possible edges exist.

<center><img src="images/cliquecount-1.drawio.svg"/></center>

For example, in the following graph, `{A, B, C}` form a 3-clique and `{B, C, D}` form another 3-clique. Together `{A, B, C, D}` do not form a 4-clique because there is no edge between `A` and `D`.

<center><img src="images/cliquecount-2.drawio.svg"/></center>

### Maximal Clique

A **maximal clique** is a clique that cannot grow any larger — there is no node outside the clique that is connected to every node inside it.

In the graph above:
- `{A, B, C}` is a maximal clique
- `{B, C, D}` is a maximal clique
- `{B, C}` is a clique but **not** maximal
- `{D, E}` is a maximal clique because `E` is only connected to `D`

## Considerations

- The algorithm treats all edges as undirected.
- Complexity is exponential in clique size — practical for cliques up to size 3-5 on large graphs.
- Self-loops are ignored.

## Example Graph

<center><img src="images/cliquecount-example.drawio.svg"/></center>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}),
       (A)-[:default]->(B), (A)-[:default]->(C),
       (A)-[:default]->(D), (B)-[:default]->(C),
       (B)-[:default]->(D), (C)-[:default]->(D),
       (D)-[:default]->(E), (E)-[:default]->(F),
       (E)-[:default]->(G), (F)-[:default]->(G)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `maxCliqueSize` | `INT` | `0` | Maximum clique size to find (0 = no limit). |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `cliqueCount` | `INT` | Number of maximal cliques containing this node |
| `maxCliqueSize` | `INT` | Size of the largest clique containing this node |

```gql
CALL algo.cliquecount() YIELD nodeId, cliqueCount, maxCliqueSize
```

Result:

| nodeId | cliqueCount | maxCliqueSize |
| -- | -- | -- |
| E | 2 | 3 |
| D | 2 | 4 |
| G | 1 | 3 |
| F | 1 | 3 |
| A | 1 | 4 |
| C | 1 | 4 |
| B | 1 | 4 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.cliquecount.stream({
    maxCliqueSize: 3
}) YIELD nodeId, cliqueCount, maxCliqueSize
RETURN nodeId, cliqueCount, maxCliqueSize
```

Result:

| nodeId | cliqueCount | maxCliqueSize |
| -- | -- | -- |
| E | 2 | 3 |
| D | 1 | 2 |
| G | 1 | 3 |
| F | 1 | 3 |
| A | 0 | 0 |
| C | 0 | 0 |
| B | 0 | 0 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `totalCliques` | `INT` | Total number of maximal cliques found |
| `maxCliqueSize` | `INT` | Size of the largest clique |

```gql
CALL algo.cliquecount.stats() YIELD nodeCount, totalCliques, maxCliqueSize
```

Result:

| nodeCount | totalCliques | maxCliqueSize |
| -- | -- | -- |
| 7 | 3 | 4 |
