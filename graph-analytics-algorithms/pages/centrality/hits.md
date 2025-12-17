# HITS

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The HITS (Hyperlink-Induced Topic Search) algorithm was developed by L.M. Kleinberg in 1999 with the purpose of improving the quality of search methods on the World Wide Web (WWW). HITS makes use of the mutual reinforcing relationship between <i>authorities</i> and <i>hubs</i> to evaluate and rank a set of linked entities.

- L.M. Kleinberg, <a target="blank" href="https://www.cs.cornell.edu/home/kleinber/auth.pdf">Authoritative Sources in a Hyperlinked Environment</a> (1999)

## Concepts

### Authority and Hub

In WWW, hyperlinks represent some latent human judgment: the creator of page <i>p</i>, by including a link to page <i>q</i>, has in some measure conferred authority on <i>q</i>. Instructively, a node with large in-degree is viewed as an <b>authority</b>.

If a node points to considerable number of authoritative nodes, it is referred to as a <b>hub</b>. 

As illustrated in the graph below, red nodes are good authorities, green nodes are good hubs.

<div align="center" drawio-diagram='3907' drawio-name='draw_2ed110856aed4603a573d6aeaa79610b.jpg'><img src="https://img.ultipa.cn/draw/draw_2ed110856aed4603a573d6aeaa79610b.jpg?v='1672217278797'"/></div>

Hubs and authorities exhibit what could be called a mutually reinforcing relationship: a good hub points to many good authorities; a good authority is pointed to by many good hubs.

### Compute Authorities and Hubs

HITS algorithm operates on the whole graph iteratively to compute the <b>authority weight</b> (denoted as <i>x</i>) and <b>hub weight</b> (denoted as <i>y</i>) for each node through the link structure. Nodes with larger <i>x</i>-values and <i>y</i>-values are viewed as better authorities and hubs respectively.

In a directed graph <i>G = (V, E)</i>, all nodes are initialized with <i>x = 1</i> and <i>y = 1</i>. In each iteration, for each node <i>p ∈ V</i>, update its <i>x</i> and <i>y</i> values as follows:

<center><img width="180" src="https://img.ultipa.cn/img/2023-02-01-18-01-37-xy.jpg" /></center>

Here is an example:

<div align='center' drawio-diagram='4899' drawio-name='draw_43b88a2290b64a76ac72baf583da2007.jpg'><img src="https://img.ultipa.cn/draw/draw_43b88a2290b64a76ac72baf583da2007.jpg?v='1680058951390'"/></div>

At the end of one iteration, normalize all <i>x</i> values and all <i>y</i> values to meet the invariant below:

<center><img width="250" src="https://img.ultipa.cn/img/2023-03-29-11-11-42-norm.jpg" /></center>

The algorithm continues until the change of all <i>x</i> values and <i>y</i> values converges to within some tolerance, or the maximum iteration rounds is met. In the experiments of the original author, the convergence is quite rapid, 20 iterations are normally sufficient.

## Considerations

- In HITS algorithm, self-loops are ignored.
- Authority weight of nodes with no in-links is 0, hub weight of nodes with out-links is 0.

## Syntax

- Command: `algo(hits_centrality)`
- Parameters:

| <div table-width="16">Name</div> | <div table-width="7">Type</div> | <div table-width="9">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| max_loop_num | int | >=1 | `20` | Yes | Maximum rounds of iterations; the algorithm ends after running for all rounds, even though the condition of `tolerance` is not met |
| tolerance | float | (0,1) | `0.001` | Yes | When all authority weights and hub weights change less than the tolerance between iterations, the result is considered stable and the algorithm ends |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
  
## Examples

The example graph is as follows:

<div align=center drawio-diagram='4900' drawio-name="draw_533f96d36b594838b20d4ff9666bd730.jpg"><img src="https://img.ultipa.cn/draw/draw_533f96d36b594838b20d4ff9666bd730.jpg?v='1733880862334'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`authority`,`hub` |

```js
algo(hits_centrality).params({}).write({
  file: {
    filename: 'rank'
  }
})
```

Results: File <i>rank</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
H,0.000000,0.000000
G,0.213196,0.190701
F,0.426420,0.000000
E,0.000000,0.476726
D,0.000000,0.572083
C,0.000000,0.476726
B,0.213196,0.381382
A,0.852796,0.190701
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| authority | `authority` | Node property | `double` |
| hub | `hub` | Node property | `double` |

```js
algo(hits_centrality).params({
  max_loop_num: 20,
  tolerance: 0.0001
}).write({
  db: {
    authority: 'auth',
    hub: 'hub'
  }
})
```

Results: Authority weight for each node is written to a new property named <i>auth</i>, hub weight for each node is written to a new property named <i>hub</i>

### Direct Return

| <div table-width="15">Alias Ordinal</div>| <div table-width="11">Type</div> | Description | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its authority and hub weight | `_uuid`, `authority`, `hub` |

```js
algo(hits_centrality).params() as rank
return rank
```

Results: <i>rank</i>

| \_uuid | authority | hub |
| -- | -- | -- |
| 8	| 3.20199049138017e-11 | 0 |
| 7	| 0.213196444093741 | 0.190700611234451 |
| 6	| 0.426419530029166 | 1.43197368054726e-11 |
| 5	| 0 | 0.476726292571473 |
| 4	| 0 | 0.572082555485605 |
| 3 | 0 | 0.476726292571473 |
| 2	| 0.213196444093741 | 0.381381944251153 |
| 1	| 0.852795952652963 | 0.190700611234451 |

### Stream Return

| <div table-width="15">Alias Ordinal</div>| <div table-width="11">Type</div> | Description | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its authority and hub weight | `_uuid`, `authority`, `hub` |

```js
algo(hits_centrality).params({
  max_loop_num: 20,
  tolerance: 0.0001
}).stream() as rank
find().nodes({_uuid == rank._uuid}) as nodes
order by rank.hub desc
return table(nodes._id, rank.hub)
```

Results: <i>table(nodes._id, rank.hub)</i>

| nodes.\_id | rank.hub |
| -- | -- |
| D | 0.572082555485605 |
| E | 0.476726292571473 |
| C | 0.476726292571473 |
| B | 0.381381944251153 |
| G | 0.190700611234451 |
| A | 0.190700611234451 |
| F | 1.43197368054726e-11 |
| H | 0 |