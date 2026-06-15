# Same Community

## Overview

The Same Community algorithm checks whether two nodes belong to the same <a target="_blank" href="/docs/graph-algorithms/wcc">weakly connected component</a>. It is a simple link prediction indicator — nodes in the same component are more likely to be connected or have a relationship.

## Considerations

- The algorithm treats all edges as undirected (weakly connected components).

## Example Graph

<center><img src="images/linkprediction-example.drawio.svg"/></center>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (A)-[:default]->(B),
       (B)-[:default]->(E), (C)-[:default]->(B),
       (C)-[:default]->(D), (C)-[:default]->(F),
       (D)-[:default]->(B), (D)-[:default]->(E),
       (F)-[:default]->(D)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `node1` | `STRING` | / | **Required.** First node `_id`. |
| `node2` | `STRING` | / | **Required.** Second node `_id`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `node1` | `STRING` | First node identifier (`_id`) |
| `node2` | `STRING` | Second node identifier (`_id`) |
| `sameCommunity` | `BOOL` | Whether the two nodes are in the same community |

```gql
CALL algo.samecommunity({
  node1: "A",
  node2: "G"
}) YIELD node1, node2, sameCommunity
```

Result:

| node1	| node2	| sameCommunity |
| -- | -- | -- |
| A | G | false |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.samecommunity.stream({
  node1: "A",
  node2: "G"
}) YIELD node1, node2, sameCommunity
RETURN node1, node2, sameCommunity
```

Result:

| node1	| node2	| sameCommunity |
| -- | -- | -- |
| A | G | false |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `sameCommunity` | `BOOL` | Whether the two nodes are in the same community |

```gql
CALL algo.samecommunity.stats({
  node1: "A",
  node2: "G"
}) YIELD sameCommunity
```

Result:

| sameCommunity |
| -- |
| false |