# Minimum Cost Flow

## Overview

The Minimum Cost Flow algorithm finds the maximum flow from a source node to a sink node while minimizing the total cost. It combines two classic optimization problems — maximum flow and shortest path — to find the most cost-efficient way to route flow through a network.

Common applications include transportation logistics, network routing, and resource allocation.

## Concepts

### Network Flow

In a flow network, each edge has a **capacity** (maximum flow it can carry) and a **cost** (cost per unit of flow). The goal is to send as much flow as possible from source to sink while minimizing the total cost.

### Minimum Cost Flow

The algorithm uses the **successive shortest paths** approach. In each iteration:

1. Find the cheapest path from source to sink (by total edge cost).
2. Send as much flow as possible along this path, limited by the minimum capacity among the path's edges.
3. Update the **residual graph**: decrease the forward edge's remaining capacity (remove edge if remaining capacity is 0), and create a **reverse edge** with capacity equal to the flow sent and negative cost (representing the ability to undo this flow).

Each iteration searches the residual graph (both forward and reverse edges) for the next cheapest path. Reverse edges allow the algorithm to redistribute previously committed flow to find a better overall solution. The algorithm stops when no more paths exist from source to sink.

Using this network with capacity and cost on each edge:

<center><img src="images/mincostflow-1.drawio.svg"/></center>

**Iteration 1:** Find two cheapest paths `S→A→B→T` and `S→B→T` (cost 6 per unit flow), pick `S→A→B→T` to continue. In this path, `A→B` has the smallest capacity 5, so we send 5 units of flow through this path: `total flow = 5`, `total cost = 5*6 = 30`. Update the graph:

<center><img src="images/mincostflow-2.drawio.svg"/></center>

**Iteration 2:** Find the cheapest path `S→B→T` (cost 6 per unit flow), `B→T` has 1 remaining. Send 1 unit: `total flow = 5 + 1 = 6`, `total cost = 30 + 1*6 = 36`. Update the graph:

<center><img src="images/mincostflow-3.drawio.svg"/></center>

**Iteration 3:** Find two cheapest paths `S→A→C→T` and `S→B→A→C→T` (cost 8 per unit flow), pick `S→A→C→T` to continue, `S→A` has 5 remaining. Send 5 units: `total flow = 6 + 5 = 11`, `total cost = 36 + 5*8 = 76`. Update the graph:

<center><img src="images/mincostflow-4.drawio.svg"/></center>

**Iteration 4:** Find the cheapest path `S→B→A→C→T` (cost 8 per unit flow), `A→C` and `C→T` has 2 remaining. Send 2 units: `total flow = 11 + 2 = 13`, `total cost = 76 + 2*8 = 92`. Update the graph:

<center><img src="images/mincostflow-5.drawio.svg"/></center>

**Iteration 5:** No more paths exist, algorithm ends.

**Result:** Maximum flow = 13, minimum cost = 92. Final flow per edge:

| Edge | Capacity | Flow |
| -- | -- | -- |
| S→A | 10 | 10 |
| S→B | 8 | 3 |
| A→B | 5 | 3 |
| A→C | 7 | 7 |
| B→T | 6 | 6 |
| C→T | 10 | 7 |

> The actual flow distribution per edge may vary due to tie-breaking when multiple paths have equal cost, but the maximum flow and minimum cost are always the same.

## Considerations

- The algorithm follows outgoing edges only.

## Example Graph

<center><img src="images/mincostflow-example.drawio.svg"/></center>

```gql
INSERT (S:default {_id: "S"}), (A:default {_id: "A"}),
       (B:default {_id: "B"}), (C:default {_id: "C"}),
       (D:default {_id: "D"}), (T:default {_id: "T"}),
       (S)-[:default {cap: 8, cost: 1}]->(A),
       (S)-[:default {cap: 6, cost: 3}]->(B),
       (A)-[:default {cap: 4, cost: 2}]->(C),
       (A)-[:default {cap: 5, cost: 4}]->(D),
       (B)-[:default {cap: 3, cost: 2}]->(C),
       (B)-[:default {cap: 5, cost: 1}]->(D),
       (C)-[:default {cap: 7, cost: 3}]->(T),
       (D)-[:default {cap: 6, cost: 2}]->(T)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `sourceNode` | `STRING` | / | **Required.** Source node `_id`. |
| `sinkNode` | `STRING` | / | **Required.** Sink node `_id`. |
| `capacityProperty` | `STRING` | / | Edge property to use as capacity. If unset, all edges have unit capacity. |
| `costProperty` | `STRING` | / | Edge property to use as cost per unit of flow. If unset, all edges have unit cost. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `maxFlow` | `FLOAT` | Total maximum flow value |
| `minCost` | `FLOAT` | Total minimum cost of the flow |
| `sourceId` | `STRING` | Source node of the edge |
| `targetId` | `STRING` | Target node of the edge |
| `flow` | `FLOAT` | Flow through this edge |
| `cost` | `FLOAT` | Cost per unit flow of this edge |

```gql
CALL algo.mincostflow({
  sourceNode: "S",
  sinkNode: "T",
  capacityProperty: "cap",
  costProperty: "cost"
}) YIELD maxFlow, minCost, sourceId, targetId, flow, cost
```

Result:

| maxFlow | minCost | sourceId | targetId | flow | cost |
| -- | -- | -- | -- | -- | -- |
| 13 | 87 | S | T | 13 | 87 |
| 13 | 87 | S | A | 7 | 1 |
| 13 | 87 | S | B | 6 | 3 |
| 13 | 87 | A | C | 4 | 2 |
| 13 | 87 | A | D | 3 | 4 |
| 13 | 87 | B | C | 3 | 2 |
| 13 | 87 | B | D | 3 | 1 |
| 13 | 87 | C | T | 7 | 3 |
| 13 | 87 | D | T | 6 | 2 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.mincostflow.stream({
  sourceNode: "S",
  sinkNode: "T",
  capacityProperty: "cap",
  costProperty: "cost"
}) YIELD sourceId, targetId, maxFlow, minCost
FILTER sourceId = "S" AND targetId = "T"
RETURN sourceId, targetId, maxFlow, minCost
```

Result:

| sourceId | targetId | maxFlow | minCost |
| -- | -- | -- | -- |
| S | T | 13 | 87 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `maxFlow` | `FLOAT` | Total maximum flow value |
| `minCost` | `FLOAT` | Total minimum cost of the flow |

```gql
CALL algo.mincostflow.stats({
  sourceNode: "S",
  sinkNode: "T",
  capacityProperty: "cap",
  costProperty: "cost"
}) YIELD maxFlow, minCost
```

Result:

| maxFlow | minCost |
| -- | -- |
| 13 | 87 |
