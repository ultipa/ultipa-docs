# SybilRank

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

The SybilRank algorithm ranks the trust of nodes by early-terminated random walks in the network, typically Online Social Network (OSN). The surge in popularity of OSNs has accompanied by the a rise in Sybil attacks, in which a malicious attacker creates multiple fake accounts (Sybils) to send spam, distribute malware, manipulate votes, inflate view counts for niche content, and so on. 

SybilRank was proposed by Qiang Cao et al. in 2012, it is computationally efficient and can scale to large graphs.

- Q. Cao, M. Sirivianos, X. Yang, T. Pregueiro, <a target="_blank" href="https://www.researchgate.net/publication/262412815_Aiding_the_detection_of_fake_accounts_in_large_scale_social_online_services">Aiding the Detection of Fake Accounts in Large Scale Social Online Services</a> (2012)

## Concepts

### Threat Model and Trust Seeds

SybilRank models an OSN as an undirected graph, where each node represents a user in the network, and each edge represents a mutual social relationship.

In the <b>threat model</b> of SybilRank, all nodes are divided into two disjoint sets: non-Sybils <i><b>H</b></i>, and Sybils <i><b>S</b></i>. Denote the non-Sybil region <i><b>G<sub>H</sub></b></i> as the subgraph induced by the set <i>H</i>, which includes all non-Sybils and edges among them. Similarly, the Sybil region <i><b>G<sub>S</sub></b></i> is the subgraph induced by <i>S</i>. <i>G<sub>H</sub></i> and <i>G<sub>S</sub></i> are connected by <b><i>attack edges</i></b> between Sybils and non-Sybils.

Some nodes identified as non-Sybils are designated as <b>trust seeds</b> for the operation of SybilRank. Seeding trust on multiple nodes makes SybilRank robust to seed selection errors, as incorrectly designating a node that is Sybil or close to Sybils as a seed causes only a small fraction of the total trust to be initialized and propagated in the Sybil region.

Below is an example of the threat model with trust seeds:

<div align=center drawio-diagram='4909' drawio-name="draw_b569d6200ff34944a42bb85312717f24.jpg"><img src="https://img.ultipa.cn/draw/draw_b569d6200ff34944a42bb85312717f24.jpg?v='1680502575577'"/></div>

> An important assumption of SybilRank is that the number of attack edges is limited. Since SybilRank is designed for large scale attacks, where fake accounts are crafted and maintained at a low cost, and are thus unable to befriend many real users. It results in a sparse cut between <i>G<sub>H</sub></i> and <i>G<sub>S</sub></i>.

### Early-Terminated Random Walk

In an undirected graph, if a <a target="_blank" href="/docs/graph-analytics-algorithms/random-walk">random walk</a>'s transition probability to a neighbor node is uniformly distributed, when the number of steps is sufficient, the probability of landing at each node would converge to be proportional to its degree. The number of steps that a random walk needs to reach the stationary distribution is called the graph's <i>mixing time</i>.

SybilRank relies on the observation that an <i>early-terminated random walk</i> starting from a non-Sybil node (trust seed) has higher landing probability to land at a non-Sybil node than a Sybil node, as the walk is unlikely to traverse one of the relatively few attack edges. That is to say, there is a significant difference between the mixing time of the non-Sybil region <i>G<sub>H</sub></i> and the entire graph.

SybilRank refers to the landing probability of each node as the node’s <i>trust</i>. <b>SybilRank ranks nodes according to their trust scores; nodes with low trust scores are ranked higher, indicating they are potential Sybil (fake) users.</b>

### Trust Propagation via Power Iteration

SybilRank uses the technique of <b>power iteration</b> to efficiently calculate the landing probability of random walks in large graphs. Power iteration involves successive matrix multiplications where each element of the matrix represents the random walk transition probability from one node to a neighbor node. Each iteration computes the landing probability distribution over all nodes as the random walk proceeds by one step.

In an undirected graph <i>G = (V, E)</i>, initially a total trust <i>T<sub>G</sub></i> is evenly distributed among all trust seeds. During each power iteration, a node first evenly distributes its trust to its neighbors; it then collects trust distributed by its neighbors and updates its own trust accordingly. The trust of node <i>v</i> in the <i>i</i>-th iteration is:

<center><img width=200 src="https://img.ultipa.cn/img/2023-04-03-15-47-59-sybilrank.jpg"></center>

where node <i>u</i> belongs to the neighbor set of node <i>v</i>, <i>deg(u)</i> is the degree of node <i>u</i>. The total amount of trust <i>T<sub>G</sub></i> remains unchanged all the time. 

With sufficient power iterations, the trust of all nodes would converge to the stationary distribution:

<center><img width=210 src="https://img.ultipa.cn/img/2023-04-03-15-54-17-sybilrank2.jpg"></center>

However, SybilRank terminates the power iteration after a fixed number of steps, without waiting for full convergence, and it is suggested to be set as <code>log<sub>2</sub>(|V|)</code>. This number of iterations is sufficient to reach an approximately stationary distribution of trust over the fast-mixing non-Sybil region <i>G<sub>H</sub></i>, but limits the trust escaping to the Sybil region <i>G<sub>S</sub></i>, thus non-Sybils will be ranked higher than Sybils.

> In practice, the mixing time of <i>G<sub>H</sub></i> is affected by many factors, so <code>log<sub>2</sub>(|V|)</code> is only a reference, but it must be less than the mixing time of the whole graph.

## Considerations

- Each self-loop adds two degrees to its subject node.
- The SybilRank algorithm ignores the direction of edges but calculates them as undirected edges.
- SybilRank’s computational cost is <i>O(n log n)</i>. This is because each power iteration costs <i>O(n)</i>, and it iterates <i>O(log n)</i> times. It is not related with the number of trust seeds.

## Example Graph

<div align=center drawio-diagram='19743' drawio-name='draw_0293d7806a1a4e718f1a3c5311f36df0.jpg'><img src="https://img.ultipa.cn/draw/draw_0293d7806a1a4e718f1a3c5311f36df0.jpg?v='1733823372452'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  user ()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  link ()-[]->()
};
INSERT (H1:user {_id: "H1"}),
       (H2:user {_id: "H2"}),
       (H3:user {_id: "H3"}),
       (H4:user {_id: "H4"}),
       (H5:user {_id: "H5"}),
       (H6:user {_id: "H6"}),
       (H7:user {_id: "H7"}),
       (H8:user {_id: "H8"}),
       (H9:user {_id: "H9"}),
       (H10:user {_id: "H10"}),
       (S1:user {_id: "S1"}),
       (S2:user {_id: "S2"}),
       (S3:user {_id: "S3"}),
       (S4:user {_id: "S4"}),
       (S2)-[:link]->(H4),
       (S3)-[:link]->(H6),
       (S4)-[:link]->(S2),
       (S4)-[:link]->(S3),
       (S4)-[:link]->(H9),
       (H1)-[:link]->(H9),
       (H2)-[:link]->(H7),
       (H2)-[:link]->(H10),
       (H3)-[:link]->(H1),
       (H3)-[:link]->(H5),
       (H4)-[:link]->(H3),
       (H4)-[:link]->(H6),
       (H5)-[:link]->(H1),
       (H6)-[:link]->(H1),
       (H6)-[:link]->(H3),
       (H6)-[:link]->(H5),
       (H7)-[:link]->(H10),
       (H8)-[:link]->(H7);
```

```uql
create().node_schema("user").edge_schema("link");
insert().into(@user).nodes([{_id:"H1"}, {_id:"H2"}, {_id:"H3"}, {_id:"H4"}, {_id:"H5"}, {_id:"H6"}, {_id:"H7"}, {_id:"H8"}, {_id:"H9"}, {_id:"H10"}, {_id:"S1"}, {_id:"S2"}, {_id:"S3"}, {_id:"S4"}]);
insert().into(@link).edges([{_from:"S2", _to:"H4"}, {_from:"S3", _to:"H6"}, {_from:"S4", _to:"S2"}, {_from:"S4", _to:"S3"}, {_from:"S4", _to:"H9"}, {_from:"H1", _to:"H9"}, {_from:"H2", _to:"H7"}, {_from:"H2", _to:"H10"}, {_from:"H3", _to:"H1"}, {_from:"H3", _to:"H5"}, {_from:"H4", _to:"H3"}, {_from:"H4", _to:"H6"}, {_from:"H5", _to:"H1"}, {_from:"H6", _to:"H1"}, {_from:"H6", _to:"H3"}, {_from:"H6", _to:"H5"}, {_from:"H7", _to:"H10"}, {_from:"H8", _to:"H7"}]);
```

</div>

## Creating HDC Graph

To load the entire graph to the HDC server `hdc-server-1` as `my_hdc_graph`:

<div tab="code">
  
```gql
CREATE HDC GRAPH my_hdc_graph ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}
```

```uql
hdc.graph.create("my_hdc_graph", {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}).to("hdc-server-1")
```

</div>

## Parameters

Algorithm name: `sybil_rank`

| <div table-width="18">Name</div> | <div table-width="10">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `total_trust` | Float | >0 | / | No | Total trust assigned across all trust seeds. |
| `trust_seeds` | []`_uuid` | / | / | Yes | Specifies the nodes selected as trust seeds by their `_uuid`. It is recommended to assign trust seeds for each community. If unset, all nodes are treated as trust seeds by default. |
| `loop_num` | Integer | >0 | `5` | Yes | The maximum number of iteration rounds. The algorithm will terminate after completing all rounds. It is recommended to set this value as <code>log<sub>2</sub>(\|V\|)</code>, where `\|V\|` is the number of nodes. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both values to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned; set to `-1` to include all results. |

## File Writeback

<div tab="code">
  
```gql  
CALL algo.sybil_rank.write("my_hdc_graph", {
  return_id_uuid: "id",
  total_trust: 100,
  // Assigns H2, H3, and H5 as trust seeds
  trust_seeds: [8214567919347040353, 16429133639670825060, 15060039352950194277],
  loop_num: 4
}, {
  file: {
    filename: "sybil_rank"
  }
})
```

```uql
algo(sybil_rank).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  total_trust: 100,
  // Assigns H2, H3, and H5 as trust seeds
  trust_seeds: [8214567919347040353, 16429133639670825060, 15060039352950194277],
  loop_num: 4
}).write({
  file: {
    filename: "sybil_rank"
  }
})
```

</div>

Result:

<p tit="File: sybil_rank"></p>

```
_id,sybil_rank
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

## DB Writeback

Writes the `sybil_rank` values from the results to the specified node property. The property type is `float`.

<div tab="code">
  
```gql  
CALL algo.sybil_rank.write("my_hdc_graph", {
  return_id_uuid: "id",
  total_trust: 100,
  // Assigns H2, H3, and H5 as trust seeds
  trust_seeds: [8214567919347040353, 16429133639670825060, 15060039352950194277],
  loop_num: 4
}, {
  db: {
    property: "trust"
  }
})
```

```uql
algo(sybil_rank).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  total_trust: 100,
  // Assigns H2, H3, and H5 as trust seeds
  trust_seeds: [8214567919347040353, 16429133639670825060, 15060039352950194277],
  loop_num: 4
}).write({
  db:{ 
    property: 'trust'
  }
})
```

</div>

## Full Return 

<div tab="code">
  
```gql  
CALL algo.sybil_rank.run("my_hdc_graph", {
  return_id_uuid: "id",
  total_trust: 100,
  // Assigns H2, H3, and H5 as trust seeds
  trust_seeds: [8214567919347040353, 16429133639670825060, 15060039352950194277],
  loop_num: 4
}) YIELD trust
RETURN trust
```

```uql
exec{
  algo(sybil_rank).params({
    return_id_uuid: "id",
    total_trust: 100,
    // Assigns H2, H3, and H5 as trust seeds
    trust_seeds: [8214567919347040353, 16429133639670825060, 15060039352950194277],
    loop_num: 4
  }) as trust
  return trust
} on my_hdc_graph
```

</div>

Result:

| \_id | sybil_rank |
| -- | -- |
| S1 | 0 |
| S4 | 3.611111 |
| S2 | 4.456018 |
| S3 | 4.710648 |
| H9 | 5.043402 |
| H8 | 5.092593 |
| H4 | 6.666666 |
| H10 | 7.87037 |
| H5 | 8.677661 |
| H1 | 9.594906 |
| H2 | 9.953703 |
| H7 | 10.41667 |
| H3 | 11.30498 |
| H6 | 12.60127 |

## Stream Return

<div tab="code">
  
```gql  
CALL algo.sybil_rank.stream("my_hdc_graph", {
  return_id_uuid: "id",
  total_trust: 100,
  // Assigns H2, H3, and H5 as trust seeds
  trust_seeds: [8214567919347040353, 16429133639670825060, 15060039352950194277],
  loop_num: 4,
  limit: 4
}) YIELD trust
RETURN trust
```

```uql
exec{
  algo(sybil_rank).params({
    return_id_uuid: "id",
    total_trust: 100,
    // Assigns H2, H3, and H5 as trust seeds
    trust_seeds: [8214567919347040353, 16429133639670825060, 15060039352950194277],
    loop_num: 4,
    limit: 4
  }).stream() as trust
  return trust
} on my_hdc_graph
````

</div>

Result:

| \_id | sybil_rank |
| -- | -- |
| S1 | 0 |
| S4 | 3.611111 |
| S2 | 4.456018 |
| S3 | 4.710648 |