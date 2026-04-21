# CELF

## Overview

The CELF (Cost Effective Lazy Forward) algorithm selects seed nodes in a network to act as propagation sources and maximize the number of influenced nodes. This is known as Influence Maximization (IM), where 'influence' represents anything that can be spread across the network, such as contamination, information, disease, etc.

CELF was proposed by Jure Leskovec et al. in 2007, it improves the traditional Greedy algorithm based on the IC model by taking advantage of the submodularity. It only calculates the spread score for all nodes only at the initial stage and does not recalculate for all nodes afterwards, hence cost-effective.

Related materials of the algorithm:

- J. Leskovec, A. Krause, C. Guestrin, C. Faloutsos, J. VanBriesen, N. Glance, <a target="_blank" href="https://www.cs.cmu.edu/~jure/pubs/detect-kdd07.pdf">Cost-effective Outbreak Detection in Networks</a> (2007)
- D. Kempe, J. Kleinberg, E. Tardos, <a target="_blank" href="https://www.cs.cornell.edu/home/kleinber/kdd03-inf.pdf">Maximizing the Spread of Influence through a Social Network</a> (2003)

A typical application of the algorithm is to prevent epidemic outbreak by selecting a small group of people to monitor, so that any disease can be detected in an early stage.

## Concepts

### Spread Function - Independent Cascade

This algorithm uses the <b>Independent Cascade (IC)</b> model to simulate influence propagation in the network. IC is a probabilistic model, it starts with a set of <i>active</i> seed nodes, and in step `k`:

- For each node that becomes <i>active</i> in step `k-1`, it has a single chance to activate each <i>inactive</i> outgoing neighbor with a success probability.
- The process runs until no more activations are possible.

The spread of a given seed set is measured by the number of <i>active</i> nodes in the graph at the end of the process. This process is repeated many times (using Monte Carlo simulations), and the average spread is calculated.

### Submodularity

The spread function `IC()` is called <b>submodular</b> as the <b>marginal gain</b> of a single node `v` is diminishing as the seed set `S` grows:

<center><img width="450" src="https://img.ultipa.cn/img/2023-03-14-11-41-37-submodular.jpg"></center>

where the seed set <i>|S<sub>k+1</sub>| > |S<sub>k</sub>|</i>, `S ∪ {v}` means to add node `v` into the seed set.

Submodularity of the spread function is the key property exploited by CELF. CELF significantly improves the traditional <a target="_blank" href="https://www.cs.cornell.edu/home/kleinber/kdd03-inf.pdf">Greedy algorithm</a> that is used to solve the influence maximization problem, it runs a lot faster while achieving near optimal results.

### Lazy Forward

At initialization, CELF, like the Greedy algorithm, computes the spread for each node and stores them in a list sorted by descending spread. As the seed set is empty now, the spread for each node can be viewed as its initial marginal gain.

In the first iteration, the top node is moved from the list to the seed set.

In the next iteration, only the marginal gain of the current top-ranked node is recalculated. After sorting, if that node remains at top, move it to the seed set; if not, repeat the process for the new top node.

Unlike Greedy, CELF avoids calculating marginal gain for all the rest nodes in each iteration, this is where the submodularity of the spread function is considered - the marginal gain of every node in this round is always lower than the previous round. So if the top node remains at top, we can put it into the seed set directly without calculating for other nodes.

The algorithm terminates when the seed set reaches the specified size.

## Example Graph

<div align=center drawio-diagram='19732' drawio-name="draw_8cca7f592c8f4b47987786ab0cb84b5e.jpg"><img src="https://img.ultipa.cn/draw/draw_8cca7f592c8f4b47987786ab0cb84b5e.jpg?v='1733803290117'"/></div>

```gql
INSERT (A:account {_id: "A"}), (B:account {_id: "B"}),
       (C:account {_id: "C"}), (D:account {_id: "D"}),
       (E:account {_id: "E"}), (F:account {_id: "F"}),
       (G:account {_id: "G"}), (H:account {_id: "H"}),
       (I:account {_id: "I"}), (J:account {_id: "J"}),
       (A)-[:follow]->(B), (A)-[:follow]->(G),
       (B)-[:follow]->(F), (C)-[:follow]->(B),
       (C)-[:follow]->(J), (D)-[:follow]->(J),
       (E)-[:follow]->(A), (F)-[:follow]->(C),
       (F)-[:follow]->(G), (G)-[:follow]->(H),
       (H)-[:follow]->(C), (H)-[:follow]->(E),
       (H)-[:follow]->(J), (I)-[:follow]->(B)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `seedSetSize` | `INT` | `10` | Number of seed nodes to select. |
| `monteCarloRuns` | `INT` | `100` | Number of Monte Carlo simulations. |
| `probability` | `FLOAT` | `0.1` | Edge activation probability. |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `spread`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `spread` | `FLOAT` | Expected influence spread |
| `rank` | `INT` | Seed selection order (1 = first selected) |

Select top 3 seed nodes:

```gql
CALL algo.celf({
  seedSetSize: 3,
  monteCarloRuns: 1000,
  probability: 0.5
}) YIELD nodeId, spread, rank
```

Result:

| nodeId | spread | rank |
| -- | -- | -- |
| H | 3.633 | 1 |
| I | 5.279 | 2 |
| A | 6.589 | 3 |

> CELF uses Monte Carlo simulations, so results may vary slightly between runs.

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.celf.stream({
  seedSetSize: 2,
  monteCarloRuns: 1000,
  probability: 0.6
}) YIELD nodeId, spread
RETURN nodeId, spread
```

Result:

| nodeId | spread |
| -- | -- |
| H | 4.45 |
| I | 6.206 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `minSpread` | `FLOAT` | Minimum influence spread |
| `maxSpread` | `FLOAT` | Maximum influence spread |
| `avgSpread` | `FLOAT` | Average influence spread |

```gql
CALL algo.celf.stats({
  seedSetSize: 3,
  probability: 0.5
}) YIELD nodeCount, minSpread, maxSpread, avgSpread
```

Result:

| nodeCount | minSpread | maxSpread | avgSpread |
| -- | -- | -- | -- |
| 10 | 3.43 | 6.5 | 5.033333333333333 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `spread` column in results to a property. Map: explicit column-to-property mapping (e.g., `{spread: 'celf_spread', rank: 'celf_rank'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `spread` | `FLOAT` | Expected influence spread |
| `rank` | `INT` | Seed selection order |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.celf.write({seedSetSize: 3, probability: 0.5}, {
  db: {
    property: "celf_spread"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
