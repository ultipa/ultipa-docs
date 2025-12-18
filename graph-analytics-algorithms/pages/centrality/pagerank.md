# PageRank

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

PageRank was originally proposed in the context of World Wide Web (WWW), it takes advantage of the link structure of WWW to produce a global objective 'importance' ranking of webpages that can be used by search engines. This algorithm was proposed in 1997-1998 by Google co-founders Larry Page and Sergey Brin.

- L. Page, S Brin, R. Motwani, T. Winograd, <a target="blank" href="http://www.eecs.harvard.edu/~michaelm/CS222/pagerank.pdf">The PageRank Citation Ranking: Bringing Order to The Web</a> (1998)

With the development of technology and the emergence of enormous correlation data, PageRank has been adopted in many other fields too.

## Concepts

### Link Structure and PageRank

In WWW, hypertexts contained in webpages create links between webpages. Every webpage (node) can have some <b>forward links</b> (via out-edges) and <b>backlinks</b> (via in-edges). In the following graph, A and B are backlinks of C, D is a forward link of C.

<div align='center' drawio-diagram='1401' drawio-name="draw_d6f0d10ef4474654a770555b6336ae8f.jpg"><img src="https://img.ultipa.cn/draw/draw_d6f0d10ef4474654a770555b6336ae8f.jpg?v='1678960967643'"/></div>

Webpages vary greatly in terms of the number of backlinks they have. Naturally, webpages that are more important, authoritative or of high quality are likely to receive more or more important backlinks.

PageRank can be described as this: a page has high rank if the sum of the ranks of its backlinks is high. This covers both the case when a page has many backlinks and when a page has a few highly ranked backlinks. 

### Rank Propagation

The ranks (scores) of all pages are computed in a recursive way by starting with any set of ranks and iterating the computation until it converges. In each iteration, a page gives out its rank to all its forward links evenly to contribute to the ranks of the pages it points to; meanwhile every page receives ranks from its backlinks, so the rank of page <i>u</i> after one iteration is:

<center><img width=250 src="https://img.ultipa.cn/img/2023-03-16-17-56-34-PR.jpg"></center>

where <i>B<sub>u</sub></i> is the backlink set of <i>u</i>. 

Below shows a steady state of a set of pages: 

<div align='center' drawio-diagram='4852' drawio-name='draw_e63020fcb3904d3b9c87b348c49df620.jpg'><img src="https://img.ultipa.cn/draw/draw_e63020fcb3904d3b9c87b348c49df620.jpg?v='1678961307271'"/></div>

### Damping Factor

Consider the following kinds of webpages:

- Webpages with no backlinks. The rank they receive is 0, but they still need to be browsed in the Internet.
- Webpages with no forward links. Their ranks are lost from the system.
- A group of webpages that only point to pages within the group, but not any page outside the group.

To overcome these problems, a <b>damping factor</b>, whose value is between 0 and 1, is introduced. It gives each webpage a base rank while weakening the ranks passed from backlinks. The rank of page <i>u</i> after one iteration becomes:

<center><img width=350 src="https://img.ultipa.cn/img/2023-03-23-11-39-14-pr2.jpg"></center>

where <i>d</i> is the damping factor. For example, when <i>d</i> is 0.7, if a webpage receives 8 ranks in total from backlinks, then the rank of this webpage is updated to `0.7*8 + (1-0.7) = 5.9`.

Damping factor can also be understood as the probability that a web surfer randomly jump to a webpage that is not one of the forward links of the current webpage.

## Considerations

- The rank of isolated webpage will stay the same as the value of <i>(1 - d)</i>.
- Self-loop is regarded as a forward link and a backlink, a webpage would pass some rank to itself through self-loop. If a network has many self-loops, it will take more iterations to converge. 

## Syntax

- Command: `algo(page_rank)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="7">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| init_value | float | >0 | `0.2` | Yes | The same initial rank for all nodes |
| loop_num | int | >=1 | `5` | Yes | Number of iterations |
| damping | float | (0,1) | `0.8` | Yes | Damping factor |
| weaken | int | `1`, `2` | `1` | Yes | For PageRank, keep it as `1`; `2` means to run <a href="/docs/graph-analytics-algorithms/article-rank">ArticleRank </a> |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order | string | `asc`, `desc` | / | Yes | Sort nodes by the rank |
  
## Examples

The example graph is as follows:

<div align=center drawio-diagram='4880' drawio-name="draw_0d0220f4b4e144b99050857de4ca2577.jpg"><img src="https://img.ultipa.cn/draw/draw_0d0220f4b4e144b99050857de4ca2577.jpg?v='1733880448614'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`rank` |

```js
algo(page_rank).params({
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 1,
  order: 'desc'
}).write({
    file: {filename: 'rank'}
})
```

Results: File <i>rank</i>

<p tit="File"></p>

```js
E,2.3906
G,1.15624
F,1.03774
N,0.842146
I,0.67812
B,0.615097
L,0.615097
J,0.36
A,0.333333
C,0.333333
H,0.333333
M,0.28
D,0.2
K,0.2
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `rank` | Node property | `float` |

```js
algo(page_rank).params({
  loop_num: 50,
  weaken: 1
}).write({
  db:{property: 'PR'}
})
```

Results: Rank for each node is written to a new property named <i>PR</i>

### Direct Return

| Alias Ordinal| Type | Description | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its rank | `_uuid`, `rank` |

```js
algo(page_rank).params({
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 1,
  order: 'desc',
  limit: 5
}) as PR 
return PR
```

Results: <i>PR</i>

| \_uuid | rank |
| -- | -- |
| 5 | 2.390599 |
| 7 | 1.15624 |
| 6 | 1.037742 |
| 14 | 0.842146 |
| 9 | 0.67812 |

### Stream Return

| Alias Ordinal| Type | Description | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its rank | `_uuid`, `rank` |

```js
algo(page_rank).params({
  loop_num: 50,
  damping: 0.8,
  weaken: 1,
  order: 'desc',
  limit: 5
}).stream() as PR 
find().nodes({_uuid == PR._uuid}) as nodes
return table(nodes._id, PR.rank)
```

Results: <i>table(nodes._id, PR.rank)</i>

| nodes.\_id | PR.rank |
| -- | -- |
| E | 2.390599 |
| G | 1.15624 |
| F | 1.037742 |
| N | 0.842146 |
| I | 0.67812 |