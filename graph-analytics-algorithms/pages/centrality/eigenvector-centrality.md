# Eigenvector Centrality

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

Eigenvector centrality measures the power or influence of a node. In a directed network, the power of a node comes from its incoming neighbors. Thus, the eigenvector centrality score of a node depends not only on how many in-links it has, but also on how powerful its incoming neighbors are. Connections from high-scoring nodes contribute more to the score of the node than connections from low-scoring nodes. In the disease spreading  scenario, a node with higher eigenvector centrality is more likely to be close to the source of infection, which needs special precautions.

The well-known <a href="/docs/graph-analytics-algorithms/pagerank-articlerank">PageRank</a> is a variant of eigenvector centrality.

Eigenvector centrality takes on values between 0 to 1, nodes with higher scores are more influential in the network.

## Concepts

### Eigenvector Centrality

The power (score) of each node can be computed in a recursive way. Take the graph below as as example, adjacent matrix <i>A</i> reflects the in-links of each node. Initialzing that each node has score of 1 and it is represented by vector <i>s<sup>(0)</sup></i>.

<div align='center' drawio-diagram='4804' drawio-name="draw_208487f47ddb41f9a1b34ce9d2fa3cf9.jpg"><img src="https://img.ultipa.cn/draw/draw_208487f47ddb41f9a1b34ce9d2fa3cf9.jpg?v='1678936654378'"/></div>

In each round of power transition, update the score of each node by the sum of scores of all its incoming neighbors. After one round, vector <i>s<sup>(1)</sup> = As<sup>(0)</sup></i> is as follows, L2-normalization is applied to rescale:

<div align='center' drawio-diagram='4815' drawio-name="draw_17a857457591418caa239b28d635624b.jpg"><img src="https://img.ultipa.cn/draw/draw_17a857457591418caa239b28d635624b.jpg?v='1678936701338'"/></div>

After <i>k</i> iterations, <i>s<sup>(k)</sup> = As<sup>(k-1)</sup> = A<sup>k</sup>s<sup>(0)</sup></i>. As <i>k</i> grows, <i>s<sup>(k)</sup></i> stabilizes. In this example, the stablization is reached after ~20 rounds.

<div align='center' drawio-diagram='4849' drawio-name="draw_5eab57fb02c247c2aab160ef7818c3d1.jpg"><img src="https://img.ultipa.cn/draw/draw_5eab57fb02c247c2aab160ef7818c3d1.jpg?v='1678936747670'"/></div>

In fact, <i>s<sup>(k)</sup></i> converges to the <b>eigenvector</b> of matrix <i>A</i> that corresponds to the largest absolute eigenvalue, hence elements in <i>s<sup>(k)</sup></i> is referred to as <b>eigenvector centrality</b>.

### Eigenvalue and Eigenvector

Given <i>A</i> is an <i>n x n</i> square matrix, <i>λ</i> is a constant, <i>x</i> is an non-zero <i>n x 1</i> vector. If the equation <i>Ax = λx</i> is true, then <i>λ</i> is called the <b>eigenvalue</b> of <i>A</i>, and <i>x</i> is the <b>eigenvector</b> of <i>A</i> that corresponds to the eigenvalue <i>λ</i>.

<div align='center' drawio-diagram='4811' drawio-name="draw_d8ddda94a4a44baba2ad54f2b363ee5a.jpg"><img src="https://img.ultipa.cn/draw/draw_d8ddda94a4a44baba2ad54f2b363ee5a.jpg?v='1678937639519'"/></div>

The above matrix <i>A</i> has 4 eigenvalues <i>λ<sub>1</sub></i>, <i>λ<sub>2</sub></i>, <i>λ<sub>3</sub></i> and <i>λ<sub>4</sub></i> that correspond to eigenvectors <i>x<sub>1</sub></i>, <i>x<sub>2</sub></i>, <i>x<sub>3</sub></i> and <i>x<sub>4</sub></i> respectively. <i>x<sub>1</sub></i> is the eigenvector corresponding to the <b>dominate eigenvalue</b> <i>λ<sub>1</sub></i> that has the largtest absolute value.

According to the <a target="blank" href="https://en.wikipedia.org/wiki/Perron%E2%80%93Frobenius_theorem">Perron-Forbenius theorem</a>, if matrix <i>A</i> has eigenvalues <i>|λ<sub>1</sub>| > |λ<sub>2</sub>| ≥ |λ<sub>3</sub>| ≥ ... ≥ |λ<sub>n</sub>|</i>, as <i>k → ∞</i>, the direction of <i>s<sup>(k)</sup> = A<sup>k</sup>s<sup>(0)</sup></i> converges to <i>x<sub>1</sub></i>, and <i>s<sup>(0)</sup></i> can be any nonzero vector.

### Power Iteration

For the best computation efficiency and accuracy, this algorithm adopts the <b>power iteration</b> approach to compute the dominate eigenvector (<i>x<sub>1</sub></i>) of matrix <i>A</i>：

- s<sup>(1)</sup> = As<sup>(0)</sup>
- s<sup>(2)</sup> = As<sup>(1)</sup> = A<sup>2</sup>s<sup>(0)</sup>
- ...
- s<sup>(k)</sup> = As<sup>(k-1)</sup> = A<sup>k</sup>s<sup>(0)</sup>

The algorithm continues until <i>s<sup>(k)</sup></i> converges to within some tolerance, or the maximum iteration rounds is met.

## Considerations

- The algorithm uses the sum of adjacency matrix and unit matrix (i.e., <b><i>A = A + I</i></b>) rather than the adjacency matrix only in order to guarantee the covergence.
- The eigenvector centrality score of nodes with no in-link converges to 0.
- Self-loop is counted as one in-link, its weight counted only once (weighted graph).

## Syntax

- Command: `algo(eigenvector_centrality)`
- Parameters:

| <div table-width="16">Name</div> | <div table-width="7">Type</div> | <div table-width="9">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| max_loop_num | int | ≥1 | `20` | Yes | Maximum rounds of iterations; the algorithm ends after running for all rounds, even though the condition of `tolerance` is not met |
| tolerance | float | (0,1) | `0.001` | Yes | When all scores change less than the tolerance between iterations, the result is considered stable and the algorithm ends |
| edge_weight_property | `@<schema>?.<property>` | Numeric type, must LTE | / | Yes | Edge property(-ies) to use as edge weight(s), where the values of multiple properties are summed up |
| direction | string | `in`, `out` | / | Yes |	Constructs the adjacent matrix A with the in-links (`in`) or our-links (`out`) of each node |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order | string | `asc`, `desc` | / | Yes | Sort nodes by the centrality score |

## Examples

The example is a web network, edge property <i>@link.value</i> can be used as weights:

<div align=center drawio-diagram='4812' drawio-name="draw_4d40d5a1a26b48ceb17f2d2d31ea4b8d.jpg"><img src="https://img.ultipa.cn/draw/draw_4d40d5a1a26b48ceb17f2d2d31ea4b8d.jpg?v='1733826309356'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`rank` |

```js
algo(eigenvector_centrality).params({
  max_loop_num: 15,
  tolerance: 0.01,
  direction: "in"
}).write({
    file: {
      filename: 'rank'
    }
})
```

Results: File <i>rank</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
web7,4.63007e-06
web6,0.0198426
web5,0.255212
web3,0.459901
web4,0.255214
web2,0.573512
web1,0.573511
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `rank` | Node property | `float` |

```js
algo(eigenvector_centrality).params({
  edge_weight_property: 'value'  
}).write({
    db: {
      property: 'ec'
    }
})
```
Results: Centrality score for each node is written to a new property named <i>ec</i>

### Direct Return

| Alias Ordinal | Type | <div table-width="30">Description</div> | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its centrality | `_uuid`, `rank` |

```js
algo(eigenvector_centrality).params({
  max_loop_num: 20,
  tolerance: 0.01,
  edge_weight_property: '@link.value',
  direction: "in",
  order: 'desc'
}) as ec 
return ec
```

Results: <i>ec</i>

| \_uuid | rank |
| -- | -- |
| 1	| 0.73133802 |
| 6	| 0.48346400 |
| 2	| 0.43551901 |
| 3	| 0.17412201 |
| 4	| 0.098612003 |
| 5	| 0.041088000 |
| 7	| 0.0000000 |

### Stream Return

| Alias Ordinal | Type | <div table-width="30">Description</div> | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its centrality | `_uuid`, `rank` |

Example: Calculate weighted eigenvector centrality for all nodes, count the number of nodes with score above 0.4 or otherwise respectively
```js
algo(eigenvector_centrality).params({
  edge_weight_property: '@link.value',
  direction: "in"
}).stream() as ec
with case
when ec.rank > 0.4 then 'attention'
when ec.rank <= 0.4 then 'normal'
END as r
group by r
return table(r, count(r))
```

Results: <i>table(r, count(r))</i>

| r | count(r) |
| -- | -- |
| attention	| 3 |
