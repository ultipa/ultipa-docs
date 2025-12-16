# HyperANF

<div><span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stats</b></span></div>

## Overview

The HyperANF (Hyper-Approximate Neighborhood Function) algorithm is used to evaluate the average graph distance. It offers a trade-off between accuracy and computational efficiency, making it suitable for large-scale graphs where computing the exact average distance may be infeasible or time-consuming.

Related material of the algorithm:

- P. Boldi, M. Rosa, S. Vigna, <a href="https://arxiv.org/pdf/1011.5599.pdf" target="blank">HyperANF: Approximating the Neighbourhood Function of Very Large Graphs on a Budget</a> (2011)

## Concepts

### Average Graph Distance

The <b>average graph distance</b> is a metric used to measure the average number of steps or edges required to traverse between any two nodes in a graph. It quantifies the overall connectivity or closeness of the nodes in the graph.

<div align='center' drawio-diagram='6237' drawio-name="draw_61eb25160e0e47b1925b40c3eec6b35c.jpg"><img src="https://img.ultipa.cn/draw/draw_61eb25160e0e47b1925b40c3eec6b35c.jpg?v='1688011148835'"/></div>

As is shown above, the average graph distance is typically computed by performing a graph traversal to calculate the shortest path distance between every pair of nodes, then summing up the distances and dividing by the total number of node pairs to get the average.

### Approximate Neighborhood Function (ANF)

Graph traversals can be computationally expensive and memory-intensive, especially for large-scale graphs. In such cases, <b>approximate neighborhood function (ANF)</b> algorithms are commonly used to estimate the average graph distance more efficiently.

ANF algorithms aim to estimate the neighborhood function (NF):

- The <b>neighborhood function</b> (NF) of a graph, denoted as `N(t)`, returns the number of node pairs such that the two nodes can reach each other with <i>t</i> or fewer steps. 
- The <b>individual neighborhood function</b> (INF) of a node <i>x</i> in a graph, denoted as `N(x,t)`, returns the number of nodes that can be reached from <i>x</i> with <i>t</i> or fewer steps.
- In an undirect graph <i>G = (V, E)</i>, the relationship between NF and INF is: 

<center><img width="160" src="https://img.ultipa.cn/img/2023-06-28-17-51-55-NF.jpg"/></center>

The NF can help to reveal some features of graphs, including the average graph distance:

<center><img width="360" src="https://img.ultipa.cn/img/2023-06-29-18-06-37-avg-dis.jpg"/></center>

The calculation of the above example graph is shown below:

<div align='center' drawio-diagram='6245' drawio-name="draw_88d9b2f6feed4f549b17f7ad44ea18de.jpg"><img src="https://img.ultipa.cn/draw/draw_88d9b2f6feed4f549b17f7ad44ea18de.jpg?v='1688026415395'"/></div>

However, it is very expensive to compute the NF exactly on large graphs. By approximating the neighborhood function, ANF algorithms can estimate the average graph distance without traversing the entire graph.

### HyperLogLog Counter

<b>HyperLogLog counter</b> is used to count approximately the number of distinct elements (i.e., the <i>cardinality</i>) in a large set or stream of elements. Calculating the exact cardinality often requires an amount of memory proportional to the cardinality, which is impractical for very large data sets. HyperLoglog takes a significantly less memory, with the space complexity as <i>O(log(log n))</i> (this is the reason why these counters are called <i>HyperLogLog</i>).

A HyperLogLog counter can be viewed as an array of <i>m = 2<sup>b</sup></i> <b>registers</b>, and each register is initialized to -∞. For example, <i>b = 3</i>, then <i>M[0] = M[1] = ... = M[7] = -∞</i>.

> The number of registers depends on the desired precision of the estimation. More registers can provide a more accurate estimation, but also require more memory.

First, each element <i>x</i> in the set is mapped into a fixed-size binary sequence by a <i>hash function h()</i>. For example, <i>h(x) = 0100001110101...</i>.

Then, update the registers. For each element <i>x</i> in the set:

<div align='center' drawio-diagram='6276' drawio-name="draw_b3d5ebdfa7cb4bfea9026b8fd4b6b30b.jpg"><img src="https://img.ultipa.cn/draw/draw_b3d5ebdfa7cb4bfea9026b8fd4b6b30b.jpg?v='1688393426711'"/></div>

- Calculate the index <i>i</i> of the register by the integer value of the leftmost <i>b</i> bits of <i>h(x)</i>, i.e., <i>h<sub>b</sub>(x)</i>. In the example, <i>i = h<sub>b</sub>(x) = 010 = 0\*2<sup>2</sup> + 1\*2<sup>1</sup> + 0\*2<sup>0</sup> = 2</i>.
- Let <i>h<sup>b</sup>(x)</i> be the sequence of remaining bits of <i>h(x)</i>, and <i>ρ(h<sup>b</sup>(x))</i> be the position of the leftmost 1 of <i>h<sup>b</sup>(x)</i>. In the example, <i>ρ(h<sup>b</sup>(x)) = ρ(0001110101...) = 4</i>.
- Update register <i>M[i] = max(M[i], ρ(h<sup>b</sup>(x)))</i>. In the example, <i>M[2] = max(-∞, 4) = 4</i>.

After reading all elements, the cardinality is calculated by the HyperLogLog counter as:

<center><img width='310' src="https://img.ultipa.cn/img/2024-06-07-12-00-08-cardinality.png"></center>

It is actually a normalized version of the harmonic mean of the <i>2<sup>M[i]</sup></i>, where <i>α<sub>m</sub></i> is a constant calculated by <i>m</i> as:

<center><img width=270 src="https://img.ultipa.cn/2022-02-18-11-24-09-hyperANF-alfa.png"></center>

### HyperANF

HyperANF is one popular ANF algorithm, it is a breakthrough improvement in terms of speed and scalability. 

The algorithm is based on the observation that `B(x,t)`, the set of reachable nodes from node <i>x</i> with distance <i>t</i> or less, satisfies 

<center><img width="210" src="https://img.ultipa.cn/img/2023-06-28-17-18-39-Nset.jpg"/></center>

In the example graph below, node <i>a</i> has 3 adjacent edges <i>(a,b)</i>, <i>(a,c)</i> and <i>(a,d)</i>, so `B(a,3) = B(b,2) ∪ B(c,2) ∪ B(d,2)`. 

<div align='center' drawio-diagram='6249' drawio-name="draw_c0b9c2469fbe49b2a3dd24e1ce3c82bd.jpg"><img src="https://img.ultipa.cn/draw/draw_c0b9c2469fbe49b2a3dd24e1ce3c82bd.jpg?v='1687944672547'"/></div>

Instead of keeping tracking of `B(x,t)`, the HyperANF algorithm employes HyperLogLog counters to simplify the computation process, as explained below with the above example graph:

- Each node <i>x</i> is mapped to a binary representation <i>h(x)</i>, and is assigned a HyperLogLog counter <i>C<sub>x</sub>(t)</i>. Set <i>b = 2</i>, so each counter has <i>m = 2<sup>b</sup> = 4</i> registers. 
- <i>C<sub>x</sub>(0)</i> is then computed by the value of <i>i</i> and <i>ρ</i>. Note: we use 0 instead of -∞ for the calculation, the result is the same.
- In the <i>t</i>-th iteration, for each node <i>x</i>, the union of `B(y,t-1)` (<i>(x,y)∈E</i>) is implemented by combining the counters of all neighbors of node <i>x</i>, that is, maximizing the values of the counter of node <i>x</i> register by register.
- The value of all counters stay unchanged after 6 iterations, the reason is the diameter of the graph is 6.
- `|B(x,t)|` is computed in each iteration by the cardinality equation with the constant <i>α<sub>m</sub> = 0.53243</i>.

<center><img src="https://img.ultipa.cn/img/2023-07-03-16-58-42-it.jpg"></center>

Since `B(x,0) = {x}`, then `|N(x,t)| = |B(x,t)| - 1`. In this example, the average graph distance computed by the algorithm is 3.2041. The exact average graph distance of this example is 3.

## Considerations

- The HyperANF algorithm is typically best suited for connected graphs. For disconnected graphs, the algorithm may not provide accurate results. 
- The HyperANF algorithm ignores the direction of edges but calculates them as undirected edges.

## Syntax

- Command: `algo(hyperANF)`
- Parameters:

| <div table-width="12">Name</div> | <div table-width="7">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| loop_num | int | >=1 | / | No | The maximum number of iterations |
| register_num | int | [4,30] | / | No | The value of <i>b</i> which decides the number of registers (<i>m = 2<sup>b</sup></i>) in the HyperLogLog counters |

## Examples

The example graph is as below:

<div align='center' drawio-diagram='6251' drawio-name='draw_6253a72674424056ba8f91bd227a7486.jpg'><img src="https://img.ultipa.cn/draw/draw_6253a72674424056ba8f91bd227a7486.jpg?v='1688032658578'"/></div>

### Direct Return

| Alias Ordinal | <div table-width="8">Type</div>| <div table-width="40">Description</div> | <div table-width="20">Columns</div> |
| --- | --- | --- | --- |
| 0 | KV | The estimated Average graph distance | `hyperANF_result` |

```js
algo(hyperANF).params({
  loop_num: 5,
  register_num: 4
}) as distance 
return distance
```

Results: <i>distance</i>

| hyperANF_result |
| -- |
| 2.50702004427638 |

### Stream Return

| Alias Ordinal | <div table-width="8">Type</div>| <div table-width="40">Description</div> | <div table-width="20">Columns</div> |
| --- | --- | --- | --- |
| 0 | KV | The estimated Average graph distance | `hyperANF_result` |

```js
algo(hyperANF).params({
  loop_num: 7,
  register_num: 5
}).stream() as distance 
return round(distance.hyperANF_result)
```

Results: 3

### Stats Return

| Alias Ordinal | <div table-width="8">Type</div>| <div table-width="40">Description</div> | <div table-width="20">Columns</div> |
| --- | --- | --- | --- |
| 0 | KV | The estimated Average graph distance | `hyperANF_result` |

```js
algo(hyperANF).params({
  loop_num: 7,
  register_num: 10
}).stats() as distance 
return distance
```

Results: <i>distance</i>

| hyperANF_result |
| -- |
