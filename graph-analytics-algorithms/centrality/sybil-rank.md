# SybilRank

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓  Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The SybilRank algorithm ranks the trust of nodes by early-terminated random walks in the network, typically Online Social Network (OSN). The surge in popularity of OSNs has accompanied by the increasing Sybil attacks, under which a malicious attacker creates multiple fake accounts (Sybils), with the purposes of spamming, distributing malware, manipulating votes or view counts for niche content, and so on. 

SybilRank was proposed by Qiang Cao et al. in 2012, it is computationally efficient and can scale to large graphs.

- Q. Cao, M. Sirivianos, X. Yang, T. Pregueiro, <a target="blank" href="https://www.researchgate.net/publication/262412815_Aiding_the_detection_of_fake_accounts_in_large_scale_social_online_services">Aiding the Detection of Fake Accounts in Large Scale Social Online Services</a> (2012)

## Concepts

### Threat Model and Trust Seeds

SybilRank considers an OSN as an undirected graph, where each node corresponds to a user in the network, and each edge corresponds to a bilateral social relationship.

In the <b>threat model</b> of SybilRank, all nodes are divided into two disjoint sets: non-Sybils <i><b>H</b></i>, and Sybils <i><b>S</b></i>. Denote the non-Sybil region <i><b>G<sub>H</sub></b></i> as the subgraph induced by the set <i>H</i>, which includes all non-Sybils and edges among them. Similarly, the Sybil region <i><b>G<sub>S</sub></b></i> is the subgraph induced by <i>S</i>. <i>G<sub>H</sub></i> and <i>G<sub>S</sub></i> are connected by <b><i>attacks edges</i></b> between Sybils and non-Sybils.

Some nodes that are considered as non-Sybils are specified as <b>trust seeds</b> for the operation of SybilRank. Seeding trust on multiple nodes makes SybilRank robust to seed selection errors, as incorrectly designating a node that is Sybil or close to Sybils as a seed causes only a small fraction of the total trust to be initialized and propagated in the Sybil region.

Below is an example of the threat model with trust seeds:

<div align=center drawio-diagram='4909' drawio-name="draw_b569d6200ff34944a42bb85312717f24.jpg"><img src="https://img.ultipa.cn/draw/draw_b569d6200ff34944a42bb85312717f24.jpg?v='1680502575577'"/></div>

> An important assumption of SybilRank is that the number of attack edges is limited. Since SybilRank is designed for large scale attacks, where fake accounts are crafted and maintained at a low cost, and are thus unable to befriend many real users. It results in a sparse cut between <i>G<sub>H</sub></i> and <i>G<sub>S</sub></i>.

### Early-Terminated Random Walk

In an undirected graph, if a <a href="/docs/graph-analytics-algorithms/random-walk">random walk</a>'s transition probability to a neighbor node is uniformly distributed, when the number of steps is sufficient, the probability of landing at each node would converge to be proportional to its degree. The number of steps that a random walk needs to reach the stationary distribution is called the graph's <i>mixing time</i>.

SybilRank relies on the observation that an <i>early-terminated random walk</i> starting from a non-Sybil node (trust seed) has higher landing probability to land at a non-Sybil node than a Sybil node, as the walk is unlikely to traverse one of the relatively few attack edges. That is to say, there is a significant difference between the mixing time of the non-Sybil region <i>G<sub>H</sub></i> and the entire graph.

SybilRank refers to the landing probability of each node as the node’s <i>trust</i>. <b>SybilRank ranks nodes according to their trust scores; nodes with low trust scores are ranked higher, and they are potential faker users.</b>

### Trust Propagation via Power Iteration

SybilRank uses the technique of <b>power iteration</b> to efficiently calculate the landing probability of random walks in large graphs. Power iteration involves successive matrix multiplications where each element of the matrix represents the random walk transition probability from one node to a neighbor node. Each iteration computes the landing probability distribution over all nodes as the random walk proceeds by one step.

In an undirected graph <i>G = (V, E)</i>, initially a total trust <i>T<sub>G</sub></i> is evenly distributed among all trust seeds. During each power iteration, a node first evenly distributes its trust to its neighbors; it then collects trust distributed by its neighbors and updates its own trust accordingly. The trust of node <i>v</i> in the <i>i</i>-th iteration is:

<center><img width=200 src="https://img.ultipa.cn/img/2023-04-03-15-47-59-sybilrank.jpg"></center>

where node <i>u</i> belongs to the neighbor set of node <i>v</i>, <i>deg(u)</i> is the degree of node <i>u</i>. The total amount of trust <i>T<sub>G</sub></i> remains unchanged all the time. 

With sufficient power iterations, the trust of all nodes would converge to the stationary distribution:

<center><img width=210 src="https://img.ultipa.cn/img/2023-04-03-15-54-17-sybilrank2.jpg"></center>

However, SybilRank terminates the power iteration after a number of steps before convergence, and it is suggested to be set as `log(|V|)`. This number of iterations is sufficient to reach an approximately stationary distribution of trust over the fast-mixing non-Sybil region <i>G<sub>H</sub></i>, but limits the trust escaping to the Sybil region <i>G<sub>S</sub></i>, thus non-Sybils will be ranked higher than Sybils.

> In practice, the mixing time of <i>G<sub>H</sub></i> is affected by many factors, so `log(|V|)` is only a reference, but it must be less than the mixing time of the whole graph.

## Considerations

- Each self-loop adds two degrees to its subject node.
- The SybilRank algorithm ignores the direction of edges but calculates them as undirected edges.
- SybilRank’s computational cost is <i>O(n log n)</i>. This is because each power iteration costs <i>O(n)</i>, and it iterates <i>O(log n)</i> times. It is not related with the number of trust seeds.

## Syntax

- Command: `algo(sybil_rank)`
- Parameters:

| <div table-width="14">Name</div> | <div table-width="9">Type</div> | <div table-width="5">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| total_trust | float | >0 | / | No | Total trust of the graph |
| trust_seeds | []`_uuid` | / | / | Yes | UUID of trust seeds, it is suggested to assign trust seeds for every community; all nodes are specified as trust seeds if not set |
| loop_num | int | >0 | `5` | Yes | Number of iterations, it is suggested to set as `log(\|V\|)` (base-2) |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |

## Examples

The example graph is as follows:

<div align=center drawio-diagram='4934' drawio-name="draw_350e2e5cc758406e998d8eab1b42dc13.jpg"><img src="https://img.ultipa.cn/draw/draw_350e2e5cc758406e998d8eab1b42dc13.jpg?v='1733881211787'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`rank` |

```uql
algo(sybil_rank).params({
  total_trust: 100,
  trust_seeds: [2,3,5],
  loop_num: 4
}).write({
  file:{
    filename: 'sybilRank'
  }
})
```

Results: File <i>sybilRank</i>

<p tit="File"></p>

```
S1,0
S4,3.61111
S2,4.45602
S3,4.71065
H9,5.0434
H8,5.09259
H4,6.66667
H10,7.87037
H5,8.67766
H1,9.59491
H2,9.9537
H7,10.4167
H3,11.305
H6,12.6013
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `rank` | Node property | `float` |

```uql
algo(sybil_rank).params({
  total_trust: 100,
  trust_seeds: [2,3,5],
  loop_num: 4
}).write({
  db:{
    property: 'trust'
  }
})
```

Results: Trust score for each node is written to a new property named <i>trust</i>

### Direct Return

| Alias Ordinal | Type | <div table-width="30">Description</div> | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its trust | `_uuid`, `rank` |

```uql
algo(sybil_rank).params({
  total_trust: 100,
  trust_seeds: [2,3,5],
  loop_num: 4
}) as trust 
return trust
```

Results: <i>trust</i>

| \_uuid | rank |
| -- | -- |
| 11 | 0.0000000 |
| 14 | 3.6111109 |
| 12 | 4.4560180 |
| 13 | 4.7106481 |
| 9 | 5.0434031 |
| 8 | 5.0925918 |
| 4 | 6.6666660 |
| 10 | 7.8703699 |
| 5 | 8.6776609 |
| 1 | 9.5949059 |
| 2 | 9.9537029 |
| 7 | 10.416666 |
| 3 | 11.304976 |
| 6 | 12.601272 |

### Stream Return

| Alias Ordinal | Type | <div table-width="30">Description</div> | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its trust | `_uuid`, `rank` |

```uql
algo(sybil_rank).params({
  total_trust: 100,
  trust_seeds: [2,3,5],
  loop_num: 4,
  limit: 4
}).stream() as trust
find().nodes({_uuid == trust._uuid}) as nodes
return table(nodes._id, trust.rank)
```

Results: <i>table(nodes._id, trust.rank)</i>

| nodes.\_id | trust.rank |
| -- | -- |
| S1 | 0.0000000 |
| S4 | 3.6111109 |
| S2 | 4.4560180 |
| S3 | 4.7106481 |