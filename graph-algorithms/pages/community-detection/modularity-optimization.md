# Modularity Optimization

## Overview

The Modularity Optimization algorithm detects communities by directly maximizing the modularity score using simulated annealing. Starting with each node in its own community, it iteratively moves nodes between communities, accepting moves that improve modularity and occasionally accepting worse moves to escape local optima.

For larger graphs where speed is prioritized, consider using <a href="/docs/graph-algorithms/louvain">Louvain</a> or <a href="/docs/graph-algorithms/leiden">Leiden</a> instead. Modularity Optimization is better suited for smaller graphs where partition quality is critical.

## Concepts

### Modularity

<a href="/docs/graph-algorithms/modularity">Modularity**</a> is a measure of community partition quality that compares the density of edges within communities to what would be expected in a random graph.

### Simulated Annealing

The algorithm uses **simulated annealing** to explore the solution space. Each iteration:

1. Pick a random node                                     
2. Pick a random neighbor of that node                        
3. Try moving the node to that neighbor's community  

If the move improves modularity, it is accepted. If not, it may still be accepted with a probability that decreases over time (controlled by the `coolingRate`). This allows the algorithm to escape local optima early in the process while converging to a stable solution.

For example, consider a graph with communities `{A, B, C}` and `{D, E}`. At some iteration, node `C` is randomly selected and considered for moving to `{D, E}`:

- If the move **increases** modularity (e.g., `C` has more connections to `D` and `E` than to `A` and `B`), the move is always accepted.
- If the move **decreases** modularity, the move may still be accepted depending on the current **temperature**. 

The **temperature** starts at 1 and multiplies by `coolingRate` each iteration. If the move decreases modularity, compares a random number (0 to 1) against the temperature and accepts if it is below the temperature. Early in the process (high temperature), the acceptance probability is high, allowing the algorithm to explore broadly. After 100 iterations with `coolingRate` 0.95, the temporature becomes `0.95^100 ≈ 0.006`, so only ~0.6% chance of accepting a bad move.

This balance between exploration and exploitation helps avoid getting stuck in poor local optima — for instance, a partition where one node is misplaced but no single move improves modularity, yet a sequence of moves through a temporarily worse state leads to a better overall partition.

## Considerations

- The algorithm treats all edges as undirected.
- Results may vary between runs due to the randomized simulated annealing process.

## Example Graph

<div align=center><img src="images/modularityopt-example.drawio.svg"/></div>


```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (A)-[:default]->(B), (A)-[:default]->(C),
       (B)-[:default]->(C), (A)-[:default]->(D),
       (D)-[:default]->(E), (D)-[:default]->(F),
       (E)-[:default]->(F), (G)-[:default]->(D),
       (G)-[:default]->(H)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `iterations` | `INT` | `100` | Number of simulated annealing iterations. |
| `coolingRate` | `FLOAT` | `0.95` | Cooling rate for simulated annealing (0 < coolingRate < 1). Lower values cool faster. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `community`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `community` | `INT` | Community identifier |
| `modularity` | `FLOAT` | Final modularity score |

```gql
CALL algo.modularityopt() YIELD nodeId, community, modularity
```

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.modularityopt.stream() YIELD nodeId, community
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
CALL algo.modularityopt.stats() YIELD nodeCount, communityCount, largestCommunitySize, smallestCommunitySize, modularity
```

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `community` column in results to a property. Map: explicit column-to-property mapping (e.g., `{community: 'mod_comm'}`). |

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
CALL algo.modularityopt.write({}, {
  db: {
    property: "mod_comm"                        // String: writes community to one property
    // property: {community: "mod_comm"}        // Map: explicit column-to-property
  }
}) YIELD task_id, status
```
