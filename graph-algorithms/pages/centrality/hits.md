# HITS

## Overview

The HITS (Hyperlink-Induced Topic Search) algorithm was developed by L.M. Kleinberg in 1999 with the purpose of improving the quality of search methods on the World Wide Web (WWW). HITS makes use of the mutual reinforcing relationship between <i>authorities</i> and <i>hubs</i> to evaluate and rank a set of linked entities.

- L.M. Kleinberg, <a target="_blank" href="https://www.cs.cornell.edu/home/kleinber/auth.pdf">Authoritative Sources in a Hyperlinked Environment</a> (1999)

## Concepts

### Authority and Hub

In WWW, hyperlinks represent some latent human judgment: the creator of page `p`, by including a link to page `q`, has in some measure conferred authority on `q`. Instructively, a node with large in-degree is viewed as an <b>authority</b>.

If a node points to a considerable number of authoritative nodes, it is referred to as a <b>hub</b>.

As illustrated in the graph below, red nodes represent good authorities, while green nodes represent good hubs.

<div align="center" drawio-diagram='3907' drawio-name='draw_2ed110856aed4603a573d6aeaa79610b.jpg'><img src="https://img.ultipa.cn/draw/draw_2ed110856aed4603a573d6aeaa79610b.jpg?v='1672217278797'"/></div>

Hubs and authorities exhibit a mutually reinforcing relationship: a good hub points to many good authorities; a good authority is pointed to by many good hubs.

### Compute Authorities and Hubs

HITS algorithm operates on the whole graph iteratively to compute the <b>authority weight</b> (denoted as `x`) and <b>hub weight</b> (denoted as `y`) for each node through the link structure. Nodes with larger `x`-values and `y`-values are viewed as better authorities and hubs respectively.

In a directed graph `G = (V, E)`, all nodes are initialized with `x = 1` and `y = 1`. In each iteration, for each node `p ∈ V`, update its `x` and `y` values as follows:

<center><img width="180" src="https://img.ultipa.cn/img/2023-02-01-18-01-37-xy.jpg" /></center>

Here is an example:

<div align='center' drawio-diagram='4899' drawio-name='draw_43b88a2290b64a76ac72baf583da2007.jpg'><img src="https://img.ultipa.cn/draw/draw_43b88a2290b64a76ac72baf583da2007.jpg?v='1680058951390'"/></div>

At the end of one iteration, normalize all `x` values and all `y` values to meet the invariant below:

<center><img width="250" src="https://img.ultipa.cn/img/2023-03-29-11-11-42-norm.jpg" /></center>

The algorithm iterates until the changes in all <i>x</i> and <i>y</i> values converge within a specific tolerance, or until the maximum number of iterations is reached. In the experiments of the original author, the convergence is quite rapid, 20 iterations are normally sufficient.

## Considerations

- In HITS algorithm, self-loops are ignored.
- Nodes with no in-links are assigned an authority weight of 0, while nodes with no out-links are assigned a hub weight of 0.

## Example Graph

<div align=center drawio-diagram='19742' drawio-name='draw_1afd6d26761942feba61b9b39ca0b412.jpg'><img src="https://img.ultipa.cn/draw/draw_1afd6d26761942feba61b9b39ca0b412.jpg?v='1733821758235'"/></div>

```gql
INSERT (A:default {_id: "A"}), (B:default {_id: "B"}),
       (C:default {_id: "C"}), (D:default {_id: "D"}),
       (E:default {_id: "E"}), (F:default {_id: "F"}),
       (G:default {_id: "G"}), (H:default {_id: "H"}),
       (A)-[:default]->(F), (B)-[:default]->(A),
       (C)-[:default]->(A), (C)-[:default]->(B),
       (D)-[:default]->(A), (D)-[:default]->(F),
       (E)-[:default]->(A), (E)-[:default]->(G),
       (F)-[:default]->(H), (G)-[:default]->(F)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `maxIterations` | `INT` | `20` | Maximum number of iterations. |
| `tolerance` | `FLOAT` | `0.000001` | Convergence tolerance. The algorithm terminates when changes in all authority and hub weights between iterations are less than this value. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `authScore`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `hubScore` | `FLOAT` | Hub score |
| `authScore` | `FLOAT` | Authority score |

HITS for all nodes:

```gql
CALL algo.hits({
  maxIterations: 50,
  tolerance: 0.001,
  order: "desc"
}) YIELD nodeId, hubScore, authScore
```

Result:

| nodeId | hubScore | authScore |
| -- | -- | -- |
| A | 0.19108520439369922 | 0.8524670163199872 |
| F | 2.2374583080847388e-7 | 0.42727940782846513 |
| G | 0.19108520439369922 | 0.21299330239705236 |
| B | 0.38123492746878823 | 0.21299330239705236 |
| H | 0 | 5.003107718113052e-7 |
| E | 0.4764884500522332 | 0 |
| D | 0.5723201318624874 | 0 |
| C | 0.4764884500522332 | 0 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.hits.stream({
  order: "desc"
}) YIELD nodeId, hubScore
RETURN nodeId, hubScore
ORDER BY hubScore DESC
```

Result:

| nodeId | hubScore |
| -- | -- |
| D | 0.5720777504129628 |
| E | 0.4767310977570136 |
| C | 0.4767310977570136 |
| B | 0.38138491402847763 |
| A | 0.19069283638448514 |
| G | 0.19069283638448514 |
| F | 4.5823157782445074e-15 |
| H | 0 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `minHubScore` | `FLOAT` | Minimum hub score |
| `maxHubScore` | `FLOAT` | Maximum hub score |
| `minAuthScore` | `FLOAT` | Minimum authority score |
| `maxAuthScore` | `FLOAT` | Maximum authority score |

```gql
CALL algo.hits.stats() YIELD nodeCount, minHubScore, maxHubScore, minAuthScore, maxAuthScore
```

Result:

| nodeCount | minHubScore | maxHubScore | minAuthScore | maxAuthScore |
| -- | -- | -- | -- | -- |
| 8 | 0 | 0.5720777504129628 | 0 | 0.8528025933604596 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `authScore` column in results to a property. Map: explicit column-to-property mapping (e.g., `{hubScore: 'hub', authScore: 'auth'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `hubScore` | `FLOAT` | Hub score |
| `authScore` | `FLOAT` | Authority score |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.hits.write({}, {
  db: {
    property: {hubScore: "hub", authScore: "auth"}
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
