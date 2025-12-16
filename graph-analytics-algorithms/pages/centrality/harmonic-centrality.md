# Harmonic Centrality

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span><div>

## Overview

Harmonic Centrality is a variant of <a href="https://ultipa.com/docs/graph-analytics-algorithms/closeness-centrality">Closeness Centrality</a>. The average shortest distance measurement proposed by harmonic centrality is compatible with infinite values which would occur in disconnected graph. Harmonic centrality was first proposed by M. Marchiori and V. Latora in 2000, and then by A. Dekker and Y. Rochat in 2005 and 2009:

- M. Marchiori, V. Latora, <a target="blank" href="https://arxiv.org/pdf/cond-mat/0008357.pdf">Harmony in the Small-World</a> (2000)
- A. Dekker, <a target="blank" href="https://www.cmu.edu/joss/content/articles/volume6/dekker/">Conceptual Distance in Social Network Analysis</a> (2005)
- Y. Rochat, <a target="blank" href="https://docslib.org/doc/524811/closeness-centrality-extended-to-unconnected-graphs-the-harmonic-centrality-index">Closeness Centrality Extended to Unconnected Graphs: The Harmonic Centrality Index</a> (2009)

Harmonic centrality takes on values between 0 to 1, nodes with higher scores have shorter distances to all other nodes. 

## Concepts

### Shortest Distance

The shortest distance of two nodes is the number of edges contained in the shortest path between them. Please refer to <a href="https://ultipa.com/docs/graph-analytics-algorithms/closeness-centrality">Closeness Centrality</a> for more details.

### Harmonic Mean

Harmonic mean is the inverse of the arithmetic mean of the inverses of the variables. The formula for calculating the arithmetic mean `A` and the harmonic mean `H` is as follows:

<center><img width="300" src="https://img.ultipa.cn/2022-08-08-11-08-40-mean.jpg"></center>

A classic application of harmonic mean is to calculate the average speed when traveling back and forth at different speeds. Suppose there is a round trip, the forward and backward speeds are 30 km/h and 10 km/h respectively. What is the average speed for the entire trip?

The arithmetic mean `A = (30+10)/2 = 20 km/h` does not seem reasonable in this case. Since the backward journey takes three times as long as the forward, during most time of the entire trip the speed stays at 10 km/h, so we expect the average speed to be closer to 10 km/h. 

Assuming that one-way distance is 1, then the average speed that takes travel time into consideration is `2/(1/30+1/10) = 15 km/h`, and this is the harmonic mean, it is adjusted by the time spent during each journey.

### Harmonic Centrality

Harmonic centrality score of a node defined by this algorithm is the inverse of the harmonic mean of the shortest distances from the node to all other nodes. The formula is:

<div align=center><img width=160 src="https://img.ultipa.cn/img/2023-03-07-14-09-45-hc.jpg"></div>

where `x` is the target node,  `y` is any node in the graph other than `x`, `k-1` is the number of `y`, `d(x,y)` is the shortest distance between `x` and `y`, `d(x,y) = +∞` when `x` and `y` are not reachable to each other, in this case `1/d(x,y) = 0`.

<div align='center' drawio-diagram='2849' drawio-name='draw_f26abcc1ee494ff5a8f1c4286f20f31a.jpg'><img src="https://img.ultipa.cn/draw/draw_f26abcc1ee494ff5a8f1c4286f20f31a.jpg?v='1659930545560'"/></div>

The harmonic centrality of node <i>a</i> in the above graph is `(1 + 1/2 + 1/+∞ + 1/+∞) / 4 = 0.375`, and the harmonic centrality of node <i>d</i> is `(1/+∞ + 1/+∞ + 1/+∞ + 1) / 4 = 0.25`.

> Harmonic Centrality algorithm consumes considerable computing resources. For a graph with <i>V</i> nodes, it is recommended to perform (uniform) sampling when <i>V</i> > 10,000, and the suggested number of samples is the base-10 logarithm of the number of nodes (`log(V)`).<br><br>For each execution of the algorithm, sampling is performed only once, centrality score of each node is computed based on the shortest distance between the node and all sample nodes.

## Considerations

- The harmonic centrality score of isolated nodes is 0. 

## Syntax

- Command: `algo(harmonic_centrality)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="8">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | Yes | ID/UUID of the nodes to calculate, calculate for all nodes if not set |
| direction | string | `in`, `out` | / | Yes | Direction of all edges in each shortest path, `in` for incoming direction, `out` for outgoing direction |
| sample_size | int | `-1`, `-2`, [1, V] | `-2` | Yes | Number of samples to compute centrality scores; `-1` means to sample `log(V)` nodes; `-2` means not to perform sampling; a number within [1, V] means to sample the set number of nodes; `sample_size` is only valid when `ids` (`uuids`) is ignored or when it specifies all nodes |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order | string | `asc`, `desc` | / | Yes | Sort nodes by the centrality score |

## Examples

The example graph is as follows:

<div align=center drawio-diagram='4938' drawio-name="draw_176185fd18ce40dab6984017fa7fe258.jpg"><img src="https://img.ultipa.cn/draw/draw_176185fd18ce40dab6984017fa7fe258.jpg?v='1733824393469'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`centrality` |

```js 
algo(harmonic_centrality).params().write({
  file:{ 
    filename: 'centrality'
  }
})
```

Results: File <i>centrality</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
LH,0
LG,0.142857
LF,0.142857
LE,0.357143
LD,0.357143
LC,0.428571
LB,0.428571
LA,0.571429
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `centrality` | Node property | `float` |

```js
algo(harmonic_centrality).params().write({
  db:{ 
    property: 'hc'
  }
})
```

Results: Centrality score for each node is written to a new property named <i>hc</i>

### Direct Return

| Alias Ordinal | Type | <div table-width="30">Description</div> | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its centrality | `_uuid`, `centrality` |

```js
algo(harmonic_centrality).params({
  direction: 'out',
  order: 'desc',
  limit: 3
}) as hc
return hc
```

Results: <i>hc</i>

| \_uuid | centrality |
| -- | -- |
| 1	| 0.35714301 |
| 4	| 0.33333299 |
| 3	| 0.28571400 |

### Stream Return

| Alias Ordinal | Type | <div table-width="30">Description</div> | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its centrality | `_uuid`, `centrality` |

```js
algo(harmonic_centrality).params({
  direction: 'in'
}).stream() as hc
where hc.centrality == 0
return hc
```

Results: <i>hc</i>

| \_uuid | centrality |
| -- | -- |
| 8	| 0.0000000 |
| 6	| 0.0000000 |
