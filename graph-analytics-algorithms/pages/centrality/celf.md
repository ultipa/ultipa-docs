# CELF

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕  Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The CELF (Cost Effective Lazy Forward) algorithm is used to select some seed nodes in a network as propagation source to reach as many nodes as possible. This is known as Influence Maximization (IM), where 'influence' represents anything that can be spread across the network, such as contamination, information, disease, etc.

CELF was proposed by Jure Leskovec et al. in 2007, it improves the traditional Greedy algorithm based on the IC model by taking advantage of the submodularity. It only calculates the spread score for all nodes only at the initial stage and does not recalculate for all nodes afterwards, hence cost-effective. 

Related materials of the algorithm:

- J. Leskovec, A. Krause, C. Guestrin, C. Faloutsos, J. VanBriesen, N. Glance, <a target="blank" href="https://www.cs.cmu.edu/~jure/pubs/detect-kdd07.pdf">Cost-effective Outbreak Detection in Networks</a> (2007)
- D. Kempe, J. Kleinberg, E. Tardos, <a target="blank" href="https://www.cs.cornell.edu/home/kleinber/kdd03-inf.pdf">Maximizing the Spread of Influence through a Social Network</a> (2003)

A typical application of the algorithm is to prevent epidemic outbreak by selecting a small group of people to monitor, so that any disease can be detected in an early stage.

## Concepts

### Spread Function - Independent Cascade

This algorithm adopts <b>Independent Cascade (IC)</b> model to simulate the influence spread process in the network. IC is a probabilistic model, it starts with a set of <i>active</i> seed nodes, and in step `k`:

- For each node that becomes <i>active</i> in step `k-1`, it has a single chance to activate each <i>inactive</i> outgoing neighbor with a success probability.
- The process runs until no more activations are possible.

The spread of the given seed set is measured by the number of <i>active</i> nodes in the graph when it ends. This process is repeated for a large number of time (Monte Carlo Simulations) and we calculate it by taking the average.

### Submodularity

The spread function `IC()` is called <b>submodular</b> as the <b>marginal gain</b> of a single node `v` is diminishing as the seed set `S` grows:

<center><img width="450" src="https://img.ultipa.cn/img/2023-03-14-11-41-37-submodular.jpg"></center>

where the seed set <i>|S<sub>k+1</sub>| > |S<sub>k</sub>|</i>, `S ∪ {v}` means to add node `v` into the seed set.

Submodularity of the spread function is the key property exploited by CELF. CELF significantly improves the traditional <a target="blank" href="https://www.cs.cornell.edu/home/kleinber/kdd03-inf.pdf">Greedy algorithm</a> that is used to solve the influence maximization problem, it runs a lot faster while achieving near optimal results.

### Lazy Forward

When CELF begins, like Greedy, it calculates the spread for each node, puts them in a list sorted by the descending spread. As the seed set is empty now, the spread for each node can be viewed as its initial marginal gain.

In the first iteration, the top node is moved from the list to the seed set. 

In the next iteration, only calculate the marginal gain for the current top node. After sorting, if that node remains at top, move it to the seed set; if not, repeat the process for the new top node.

Unlike Greedy, CELF avoids calculating marginal gain for all the rest nodes in each iteration, this is where the submodularity of the spread function is considered - the marginal gain of every node in this round is always lower than the previous round. So if the top node remains at top, we can put it into the seed set directly without calculating for other nodes.

The algorithm stops when the seed set reaches the set size.

## Syntax

- Command: `algo(celf)`
- Parameters:

| <div table-width="24">Name</div> | <div table-width="5">Type</div> | <div table-width="5">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| seedSetSize | int | >0 | `1` | Yes | The size of the seed set |
| monteCarloSimulations | int | >0 | `1000` | Yes | The number of Monte Carlo simulations |
| propagationProbability | float | (0,1) | `0.1` | Yes | The probability that each outgoing neighbor is successfully activated by a node with activation capability in certain round |

## Examples

The example graph is as follows:

<div align=center drawio-diagram='4942' drawio-name="draw_b0e238a2cd6f47179fce311b9d6213a6.jpg"><img src="https://img.ultipa.cn/draw/draw_b0e238a2cd6f47179fce311b9d6213a6.jpg?v='1733880170242'"/></div>

### File Writeback

| Spec | Content | <div table-width="55">Description</div> |
| --- | --- | --- |
| filename | `_id`,`spread` | Node and its marginal gain when it joins the seed set |

```js
algo(celf).params({
  seedSetSize: 3,
  monteCarloSimulations: 1000,
  propagationProbability: 0.5 
}).write({
  file:{
    filename: 'seeds'
  }
})
```

Results: File <i>seeds</i>

<p tit="File"></p>

```js
H,3.608
I,1.647
A,1.345
```

### Direct Return

| Alias Ordinal	| <div table-width="11">Type</div> | <div table-width="40">Description</div> | <div table-width="18">Columns</div> |
| --------- | --- | ----------- | -------- |
| 0 | []perNode | Node and its marginal gain when it joins the seed set | `_uuid`, `spread` |

```js
algo(celf).params({
  seedSetSize: 2,
  monteCarloSimulations: 1000,
  propagationProbability: 0.6 
}) as seeds
return seeds
```

Results: <i>seeds</i>

| \_uuid | spread |
| -- | -- |
| 8	| 4.518 |
| 9	| 1.685 |

### Stream Return

| Alias Ordinal	| <div table-width="11">Type</div> | <div table-width="40">Description</div> | <div table-width="18">Columns</div> |
| --------- | --- | ----------- | -------- |
| 0 | []perNode | Node and its marginal gain when it joins the seed set | `_uuid`, `spread` |

```js
algo(celf).params({
  seedSetSize: 3,
  monteCarloSimulations: 1000,
  propagationProbability: 0.6 
}).stream() as seeds
find().nodes({_uuid == seeds._uuid}) as nodes
return table(nodes._id, nodes.createdOn, seeds.spread)
```

Results: <i>table(nodes._id, nodes.createdOn, seeds.spread)</i>

| nodes.\_id | nodes.createdOn | seeds.spread |
| -- | -- | -- |
| H | 2016-07-11 00:00:00 | 4.518 |
| I | 2018-12-13 00:00:00 | 1.685 |
| D | 2019-01-16 00:00:00 | 1.096 |