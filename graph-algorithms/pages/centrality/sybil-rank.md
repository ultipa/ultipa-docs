# SybilRank

## Overview

The SybilRank algorithm ranks the trust of nodes by early-terminated random walks in the network, typically Online Social Network (OSN). The surge in popularity of OSNs has accompanied by the a rise in Sybil attacks, in which a malicious attacker creates multiple fake accounts (Sybils) to send spam, distribute malware, manipulate votes, inflate view counts for niche content, and so on.

SybilRank was proposed by Qiang Cao et al. in 2012, it is computationally efficient and can scale to large graphs.

- Q. Cao, M. Sirivianos, X. Yang, T. Pregueiro, <a target="_blank" href="https://www.researchgate.net/publication/262412815_Aiding_the_detection_of_fake_accounts_in_large_scale_social_online_services">Aiding the Detection of Fake Accounts in Large Scale Social Online Services</a> (2012)

## Concepts

### Threat Model and Trust Seeds

SybilRank models an OSN as an undirected graph, where each node represents a user in the network, and each edge represents a mutual social relationship.

In the <b>threat model</b> of SybilRank, all nodes are divided into two disjoint sets: non-Sybils `H`, and Sybils `S`. Denote the non-Sybil region <code>G<sub>H</sub></code> as the subgraph induced by the set `H`, which includes all non-Sybils and edges among them. Similarly, the Sybil region <code>G<sub>S</sub></code> is the subgraph induced by `S`. <code>G<sub>H</sub></code> and <code>G<sub>S</sub></code> are connected by <b>attack edges</b> between Sybils and non-Sybils.

Some nodes identified as non-Sybils are designated as <b>trust seeds</b> for the operation of SybilRank. Seeding trust on multiple nodes makes SybilRank robust to seed selection errors, as incorrectly designating a node that is Sybil or close to Sybils as a seed causes only a small fraction of the total trust to be initialized and propagated in the Sybil region.

Below is an example of the threat model with trust seeds:

<div align=center drawio-diagram='4909' drawio-name="draw_b569d6200ff34944a42bb85312717f24.jpg"><img src="https://img.ultipa.cn/draw/draw_b569d6200ff34944a42bb85312717f24.jpg?v='1680502575577'"/></div>

> An important assumption of SybilRank is that the number of attack edges is limited. Since SybilRank is designed for large scale attacks, where fake accounts are crafted and maintained at a low cost, and are thus unable to befriend many real users. It results in a sparse cut between <code>G<sub>H</sub></code> and <code>G<sub>S</sub></code>.

### Early-Terminated Random Walk

In an undirected graph, if a random walk's transition probability to a neighbor node is uniformly distributed, when the number of steps is sufficient, the probability of landing at each node would converge to be proportional to its degree. The number of steps that a random walk needs to reach the stationary distribution is called the graph's <b>mixing time</b>.

SybilRank relies on the observation that an <b>early-terminated random walk</b> starting from a non-Sybil node (trust seed) has higher landing probability to land at a non-Sybil node than a Sybil node, as the walk is unlikely to traverse one of the relatively few attack edges. That is to say, there is a significant difference between the mixing time of the non-Sybil region <code>G<sub>H</sub></code> and the entire graph.

SybilRank refers to the landing probability of each node as the node's <b>trust</b>. <b>SybilRank ranks nodes according to their trust scores; nodes with low trust scores are ranked higher, indicating they are potential Sybil (fake) users.</b>

### Trust Propagation via Power Iteration

SybilRank uses the technique of <b>power iteration</b> to efficiently calculate the landing probability of random walks in large graphs. Power iteration involves successive matrix multiplications where each element of the matrix represents the random walk transition probability from one node to a neighbor node. Each iteration computes the landing probability distribution over all nodes as the random walk proceeds by one step.

In an undirected graph <i>G = (V, E)</i>, initially a total trust <code>T<sub>G</sub></code> is evenly distributed among all trust seeds. During each power iteration, a node first evenly distributes its trust to its neighbors; it then collects trust distributed by its neighbors and updates its own trust accordingly. The trust of node `v` in the `i`-th iteration is:

<center><img width=200 src="https://img.ultipa.cn/img/2023-04-03-15-47-59-sybilrank.jpg"></center>

where node `u` belongs to the neighbor set of node `v`, `deg(u)` is the degree of node `u`. The total amount of trust <code>T<sub>G</sub></code> remains unchanged all the time.

With sufficient power iterations, the trust of all nodes would converge to the stationary distribution:

<center><img width=210 src="https://img.ultipa.cn/img/2023-04-03-15-54-17-sybilrank2.jpg"></center>

However, SybilRank terminates the power iteration after a fixed number of steps, without waiting for full convergence, and it is suggested to be set as <code>log<sub>2</sub>(|V|)</code>. This number of iterations is sufficient to reach an approximately stationary distribution of trust over the fast-mixing non-Sybil region <code>G<sub>H</sub></code>, but limits the trust escaping to the Sybil region <code>G<sub>S</sub></code>, thus non-Sybils will be ranked higher than Sybils.

> In practice, the mixing time of <code>G<sub>H</sub></code> is affected by many factors, so <code>log<sub>2</sub>(|V|)</code> is only a reference, but it must be less than the mixing time of the whole graph.

## Considerations

- Each self-loop adds two degrees to its subject node.
- The algorithm treats edges as undirected.
- SybilRank's computational cost is <code>O(n log n)</code>. This is because each power iteration costs <code>O(n)</code>, and it iterates <code>O(log n)</code> times.

## Example Graph

<div align=center drawio-diagram='19743' drawio-name='draw_0293d7806a1a4e718f1a3c5311f36df0.jpg'><img src="https://img.ultipa.cn/draw/draw_0293d7806a1a4e718f1a3c5311f36df0.jpg?v='1733823372452'"/></div>

```gql
INSERT (H1:user {_id: "H1"}), (H2:user {_id: "H2"}),
       (H3:user {_id: "H3"}), (H4:user {_id: "H4"}),
       (H5:user {_id: "H5"}), (H6:user {_id: "H6"}),
       (H7:user {_id: "H7"}), (H8:user {_id: "H8"}),
       (H9:user {_id: "H9"}), (H10:user {_id: "H10"}),
       (S1:user {_id: "S1"}), (S2:user {_id: "S2"}),
       (S3:user {_id: "S3"}), (S4:user {_id: "S4"}),
       (S2)-[:link]->(H4), (S3)-[:link]->(H6),
       (S4)-[:link]->(S2), (S4)-[:link]->(S3),
       (S4)-[:link]->(H9), (H1)-[:link]->(H9),
       (H2)-[:link]->(H7), (H2)-[:link]->(H10),
       (H3)-[:link]->(H1), (H3)-[:link]->(H5),
       (H4)-[:link]->(H3), (H4)-[:link]->(H6),
       (H5)-[:link]->(H1), (H6)-[:link]->(H1),
       (H6)-[:link]->(H3), (H6)-[:link]->(H5),
       (H7)-[:link]->(H10), (H8)-[:link]->(H7)
```

## Parameters

| Name | Type | Default | Description |
| -- | -- | -- | -- |
| `trustedNodes` | `STRING` | / | Comma-separated `_id`s of trusted seed nodes. **Required.** |
| `iterations` | `INT` | `0` | Number of iterations. `0` = auto (<code>ceil(log<sub>2</sub>(n))</code>). |
| `limit` | `INT` | `-1` | Limits the number of results returned (-1 = all). |
| `order` | `STRING` | / | Sorts the results by `trust`: `asc` or `desc`. |

## Run Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeId` | `STRING` | Node identifier (`_id`) |
| `trust` | `FLOAT` | Trust score (lower = more likely sybil) |
| `rank` | `INT` | Rank position (1 = most trusted) |

SybilRank with H2, H3, and H5 as trust seeds:

```gql
CALL algo.sybilrank({
  trustedNodes: "H2,H3,H5",
  order: "desc"
}) YIELD nodeId, trust, rank
```

Result:

| nodeId | trust | rank |
| -- | -- | -- |
| H6 | 0.14872685185185186 | 1 |
| H3 | 0.1335648148148148 | 2 |
| H1 | 0.11107253086419752 | 3 |
| H5 | 0.09965277777777778 | 4 |
| H4 | 0.07534722222222223 | 5 |
| H7 | 0.06944444444444445 | 6 |
| H2 | 0.06635802469135801 | 7 |
| H9 | 0.059182098765432095 | 8 |
| S3 | 0.05478395061728395 | 9 |
| S2 | 0.054012345679012336 | 10 |
| H10 | 0.05246913580246913 | 11 |
| S4 | 0.041435185185185186 | 12 |
| H8 | 0.033950617283950615 | 13 |
| S1 | 0 | 14 |

## Stream Mode

Returns the same columns as run mode, streamed for memory efficiency.

```gql
CALL algo.sybilrank.stream({
  trustedNodes: "H2,H3,H5",
  order: "asc",
  limit: 4
}) YIELD nodeId, trust
RETURN nodeId, trust
```

Result:

| nodeId | trust |
| -- | -- |
| S1 | 0 |
| H8 | 0.033950617283950615 |
| S4 | 0.041435185185185186 |
| H10 | 0.05246913580246913 |

## Stats Mode

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `nodeCount` | `INT` | Total number of nodes |
| `trustedCount` | `INT` | Number of trusted seed nodes |
| `minTrust` | `FLOAT` | Minimum trust score |
| `maxTrust` | `FLOAT` | Maximum trust score |
| `avgTrust` | `FLOAT` | Average trust score |

```gql
CALL algo.sybilrank.stats({
  trustedNodes: "H2,H3,H5"
}) YIELD nodeCount, trustedCount, minTrust, maxTrust, avgTrust
```

Result:

| nodeCount | trustedCount | minTrust | maxTrust | avgTrust |
| -- | -- | -- | -- | -- |
| 14 | 3 | 0 | 0.14872685185185183 | 0.07142857142857142 |

## Write Mode

Computes results and writes them back to node properties. The write configuration is passed as a second argument map.

**Write parameters:**

| Name | Type | Description |
| -- | -- | -- |
| `db.property` | `STRING` or `MAP` | Node property to write results to. String: writes the `trust` column in results to a property. Map: explicit column-to-property mapping (e.g., `{trust: 'trust_score', rank: 'trust_rank'}`). |

**Writable columns:**

| Column | Type | Description |
| -- | -- | -- |
| `trust` | `FLOAT` | Trust score |
| `rank` | `INT` | Rank position |

**Returns:**

| Column | Type | Description |
| -- | -- | -- |
| `task_id` | `STRING` | Task identifier for tracking via `SHOW TASKS` |
| `nodesWritten` | `INT` | Number of nodes with properties written |
| `computeTimeMs` | `INT` | Time spent computing the algorithm (milliseconds) |
| `writeTimeMs` | `INT` | Time spent writing properties to storage (milliseconds) |

```gql
CALL algo.sybilrank.write({trustedNodes: "H2,H3,H5"}, {
  db: {
    property: "trust_score"
  }
}) YIELD task_id, nodesWritten, computeTimeMs, writeTimeMs
```
