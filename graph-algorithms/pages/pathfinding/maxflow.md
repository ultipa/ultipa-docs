# Maximum Flow

## Overview

The Maximum Flow algorithm finds the maximum amount of flow that can be sent from a source node to a sink node through a network, respecting edge capacities. Unlike <a href="/docs/graph-algorithms/mincostflow">Minimum Cost Flow</a> which also minimizes cost, this algorithm only maximizes flow.

Applications:

- **Network bandwidth**: Finding the maximum data throughput between two servers.
- **Transportation**: Maximum number of vehicles that can travel from origin to destination.
- **Bipartite matching**: Maximum matching can be reduced to a max-flow problem.

## Concepts

### Maximum Flow

In a flow network, each edge has a **capacity** (the maximum flow it can carry). The **maximum flow** is the largest total flow that can be routed from source to sink without exceeding any edge's capacity.

This implementation uses the **Push-Relabel** algorithm:

1. **Flood**: Push the maximum possible flow from the source to all its neighbors, filling each edge to capacity. Like <a href="/docs/graph-algorithms/mincostflow">Minimum Cost Flow</a>, whenever flow is sent through an edge, the forward edge's remaining capacity decreases (remove edge if remaining capacity is 0) and a **reverse edge** is created with capacity equal to the flow sent. For example, sending 5 units through an edge with capacity 5 leaves the forward edge at 0 (edge removed) and creates a reverse edge with capacity 5.
2. **Push**: Each node with excess flow tries to push it toward the sink through available edges (including reverse edges).
3. **Drain back**: Flow that can't reach the sink gets pushed back to the source through reverse edges.

Using this network with capacity and cost on each edge:

<center><img src="images/maxflow-1.drawio.svg"/></center>

**Step 1 (Flood):** Push maximum flow from `S` to neighbors: 10 units to `A`, 8 units to `B`. Now `A` has 10 excess, `B` has 8 excess.

<center><img src="images/maxflow-2.drawio.svg"/></center>

**Step 2 (Push toward sink):** Each node pushes excess greedily to its outgoing edges in no particular order — the algorithm doesn't know the optimal split in advance. For example, 

- `A` now has 10 excess, it might split as 5 to `B` and 5 to `C`, or 3 to `B` and 7 to `C`. Suppose `A` pushes 5 to `B` and 5 to `C`. 
- `B` now has 13 excess (8 from `S` + 5 from `A`). Pushes 6 to `T`. `B`'s excess = 7.
- `C` has 5 excess. Pushes 5 to `T`. T receives 11 total.

<center><img src="images/maxflow-3.drawio.svg"/></center>

**Step 3 (Redistribute):** Using reverse edges, `B` pushes 2 units back to `A`. `A` redirects these 2 units to `C` (A→C still has 2 remaining capacity). `C` pushes 2 more to `T`. The remaining 5 excess at `B` drains back to `S`.

<center><img src="images/maxflow-4.drawio.svg"/></center>

**Result:** Maximum flow = 13. Final flow per edge:

| Edge | Capacity | Flow |
| -- | -- | -- |
| S→A | 10 | 7 |
| S→B | 8 | 6 |
| A→B | 5 | 0 |
| A→C | 7 | 7 |
| B→T | 6 | 6 |
| C→T | 10 | 7 |

> The actual flow distribution per edge may vary depending on the order nodes push their excess, but the maximum flow value is always the same.

## Considerations

- The algorithm follows outgoing edges only.
- If `capacityProperty` is not specified, all edges have unit capacity (1.0).

## Example Graph

<center><img src="images/maxflow-example.drawio.svg"/></center>

```gql
INSERT (S:default {_id: "S"}), (A:default {_id: "A"}),
       (B:default {_id: "B"}), (C:default {_id: "C"}),
       (D:default {_id: "D"}), (T:default {_id: "T"}),
       (S)-[:default {cap: 8}]->(A),
       (S)-[:default {cap: 6}]->(B),
       (A)-[:default {cap: 4}]->(C),
       (A)-[:default {cap: 5}]->(D),
       (B)-[:default {cap: 3}]->(C),
       (B)-[:default {cap: 5}]->(D),
       (C)-[:default {cap: 7}]->(T),
       (D)-[:default {cap: 6}]->(T)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `source` | `STRING` | / | **Required.** Source node `_id`. |
| `sink` | `STRING` | / | **Required.** Sink node `_id`. |
| `capacityProperty` | `STRING` | / | Edge property to use as capacity. If unset, all edges have unit capacity. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `maxFlow` | `FLOAT` | Total maximum flow value |
| `sourceId` | `STRING` | Source node of the edge |
| `targetId` | `STRING` | Target node of the edge |
| `flow` | `FLOAT` | Flow through this edge |
| `capacity` | `FLOAT` | Capacity of this edge |

```gql
CALL algo.maxflow({
  source: "S",
  sink: "T",
  capacityProperty: "cap"
}) YIELD maxFlow, sourceId, targetId, flow, capacity
```

Result:

| maxFlow | sourceId | targetId | flow | capacity |
| -- | -- | -- | -- | -- |
| 13 | S | T | 13 | 0 |
| 13 | S | A | 7 | 8 |
| 13 | S | B | 6 | 6 |
| 13 | A | C | 4 | 4 |
| 13 | A | D | 3 | 5 |
| 13 | B | C | 3 | 3 |
| 13 | B | D | 3 | 5 |
| 13 | C | T | 7 | 7 |
| 13 | D | T | 6 | 6 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.maxflow.stream({
  source: "S",
  sink: "T",
  capacityProperty: "cap"
}) YIELD sourceId, targetId, flow
FILTER sourceId = "S" AND targetId = "T"
RETURN sourceId, targetId, flow
```

Result:

| sourceId | targetId | flow |
| -- | -- | -- |
| S | T | 13 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `maxFlow` | `FLOAT` | Total maximum flow value |
| `edgeCount` | `INT` | Number of edges carrying flow |

```gql
CALL algo.maxflow.stats({
  source: "S",
  sink: "T",
  capacityProperty: "cap"
}) YIELD maxFlow, edgeCount
```

Result:

| maxFlow | edgeCount |
| -- | -- |
| 13 | 8 |
