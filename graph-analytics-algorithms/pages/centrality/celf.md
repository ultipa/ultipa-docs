# CELF

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

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

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  account ({createdOn datetime})
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  follow ()-[]->()
};
INSERT (A:account {_id:"A", createdOn: "2016-12-3"}),
       (B:account {_id:"B", createdOn:"2022-1-30"}),
       (C:account {_id:"C", createdOn: "2019-11-8"}),
       (D:account {_id:"D", createdOn: "2019-1-16"}),
       (E:account {_id:"E", createdOn: "2016-3-4"}),
       (F:account {_id:"F", createdOn: "2019-11-10"}),
       (G:account {_id:"G", createdOn: "2019-7-26"}),
       (H:account {_id:"H", createdOn: "2016-7-11"}),
       (I:account {_id:"I", createdOn: "2018-12-13"}),
       (J:account {_id:"J", createdOn: "2018-3-21"}),
       (A)-[:follow]->(B),
       (A)-[:follow]->(G),
       (B)-[:follow]->(F),
       (C)-[:follow]->(B),
       (C)-[:follow]->(J),
       (D)-[:follow]->(J),
       (E)-[:follow]->(A),
       (F)-[:follow]->(C),
       (F)-[:follow]->(G),
       (G)-[:follow]->(H),
       (H)-[:follow]->(C),
       (H)-[:follow]->(E),
       (H)-[:follow]->(J),
       (I)-[:follow]->(B);
```

```uql
create().node_schema("account").edge_schema("follow");
create().node_property(@account, "createdOn", datetime);
insert().into(@account).nodes([{_id:"A", createdOn: "2016-12-3"}, {_id:"B", createdOn:"2022-1-30" }, {_id:"C", createdOn: "2019-11-8"}, {_id:"D", createdOn: "2019-1-16"}, {_id:"E", createdOn: "2016-3-4"}, {_id:"F", createdOn: "2019-11-10"}, {_id:"G", createdOn: "2019-7-26"}, {_id:"H", createdOn: "2016-7-11"}, {_id:"I", createdOn: "2018-12-13"},{_id:"J", createdOn: "2018-3-21"}]);
insert().into(@follow).edges([{_from:"A", _to:"B"}, {_from:"A", _to:"G"}, {_from:"B", _to:"F"}, {_from:"C", _to:"J"}, {_from:"D", _to:"J"}, {_from:"E", _to:"A"}, {_from:"F", _to:"C"}, {_from:"F", _to:"G"}, {_from:"G", _to:"H"}, {_from:"H", _to:"C"}, {_from:"H", _to:"E"}, {_from:"H", _to:"J"}, {_from:"I", _to:"B"}, {_from:"C", _to:"B"}]);
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

Algorithm name: `celf`

| <div table-width="18">Name</div> | <div table-width="10">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `seedSetSize` | Integer | >0 | `1` | Yes | The size of the seed set. |
| `monteCarloSimulations` | Integer | >0 | `1000` | Yes | The number of Monte Carlo simulations. |
| `propagationProbability ` | Float | (0,1) | `0.1` | Yes | The probability that a node with activation capability successfully activates each of its outgoing neighbors in a given round. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both values to represent nodes in the results. |

## File Writeback

<div tab="code">
  
```gql  
CALL algo.celf.write("my_hdc_graph", {
  return_id_uuid: "id",
  seedSetSize: 3,
  monteCarloSimulations: 1000,
  propagationProbability: 0.5
}, {
  file: {
    filename: "seeds"
  }
})
```

```uql
algo(celf).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  seedSetSize: 3,
  monteCarloSimulations: 1000,
  propagationProbability: 0.5
}).write({
  file: {
    filename: "seeds"
  }
})
```

</div>

Result:

<p tit="File: seeds" ></p>

```
_id,spread
H,3.613
I,1.646
A,1.34
```

## Full Return

<div tab="code">
  
```gql  
CALL algo.celf.run("my_hdc_graph", {
  return_id_uuid: "id",    
  seedSetSize: 2,
  monteCarloSimulations: 1000,
  propagationProbability: 0.6
}) YIELD seeds
RETURN seeds
```

```uql
exec{
  algo(celf).params({
    return_id_uuid: "id",    
    seedSetSize: 2,
    monteCarloSimulations: 1000,
    propagationProbability: 0.6
  }) as seeds
  return seeds
} on my_hdc_graph
```

</div>

Result:

| \_id | spread |
| -- | -- |
| H | 4.504 |
| I | 1.678 |

## Stream Return

<div tab="code">
  
```gql  
CALL algo.celf.stream("my_hdc_graph", {
  return_id_uuid: "id",
  seedSetSize: 3,
  monteCarloSimulations: 1000,
  propagationProbability: 0.6
}) YIELD seeds
MATCH (nodes WHERE nodes._id = seeds._id)
RETURN nodes._id, nodes.createdOn, seeds.spread
```

```uql
exec{
  algo(celf).params({
    return_id_uuid: "id",
    seedSetSize: 3,
    monteCarloSimulations: 1000,
    propagationProbability: 0.6 
  }).stream() as seeds
  find().nodes({_id == seeds._id}) as nodes
  return nodes._id, nodes.createdOn, seeds.spread
} on my_hdc_graph
```

</div>

Result:

| nodes.\_id | nodes.createdOn | seeds.spread |
| -- | -- | -- |
| H | 2016-07-11 00:00:00 | 4.504 |
| I | 2018-12-13 00:00:00 | 1.678 |
| A | 2016-12-03 00:00:00 | 1.126 |
