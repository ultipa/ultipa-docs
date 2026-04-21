# Induced Subgraph

## Overview

The Induced Subgraph algorithm extracts the subgraph formed by a given set of nodes and all edges between them. This enables focused analysis on a subset of the graph, revealing local structure and connectivity patterns among selected nodes.

## Concepts

### Induced Subgraph

An induced subgraph includes only the nodes from the given set and all edges that have both endpoints in that set.

<div align='center' drawio-diagram='6063' drawio-name="draw_2044bf57a80e4696a943ed9e77ce416c.jpg"><img src="https://img.ultipa.cn/draw/draw_2044bf57a80e4696a943ed9e77ce416c.jpg?v='1685497373767'"/></div>

As this example shows, when specifying node set `S = {A, B, I, K, L, M, N}`, the induced subgraph is the graph whose node set is `S` and whose edge set contains all edges that have both endpoints in `S`.

## Considerations

- The algorithm respects edge direction.
- Multi-edges between the same pair of nodes are preserved.
- Self-loops are included if the node is in the specified set.

## Example Graph

<div align=center><img src="images/inducedsubgraph-example.drawio.svg"/></div>

Run the following statements on an empty graph to insert data:

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (I:default {_id: "I"}),
       (A)-[:default]->(B), (C)-[:default]->(A),
       (E)-[:default]->(C), (E)-[:default]->(A),
       (C)-[:default]->(D), (D)-[:default]->(A),
       (D)-[:default]->(A), (F)-[:default]->(G),
       (G)-[:default]->(G), (F)-[:default]->(I),
       (H)-[:default]->(G)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `nodes` | `STRING` | / | **Required.** Comma-separated node `_id` values specifying the node set for the induced subgraph. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `sourceId` | `STRING` | Source node identifier (`_id`) |
| `targetId` | `STRING` | Target node identifier (`_id`) |
| `edgeExists` | `INT` | Edge existence indicator (always 1) |

```gql
CALL algo.inducedsubgraph({
  nodes: "A,C,D,G"
}) YIELD sourceId, targetId, edgeExists
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.inducedsubgraph.stream({
  nodes: "A,C,D,G"
}) YIELD sourceId, targetId
RETURN sourceId, targetId
```

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Number of nodes in the induced subgraph |
| `edgeCount` | `INT` | Number of edges in the induced subgraph |
| `density` | `FLOAT` | Graph density: `edgeCount / (nodeCount * (nodeCount - 1))` for directed graphs |

```gql
CALL algo.inducedsubgraph.stats({
  nodes: "A,C,D,G"
}) YIELD nodeCount, edgeCount, density
```