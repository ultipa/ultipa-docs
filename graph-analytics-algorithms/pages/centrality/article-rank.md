# ArticleRank

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

ArticleRank has been derived from <a href="/docs/graph-analytics-algorithms/pagerank">PageRank</a> to measure the influence of journal articles.

- J. Li, P. Willett, <a target="blank" href="https://eprints.whiterose.ac.uk/10323/1/Willett_10323.pdf">ArticleRank: a PageRank-based Alternative to Numbers of Citations for Analysing Citation Networks</a> (2009)

## Concepts

### ArticleRank

Similar to links between webpages, citations between articles (books, reports, etc.) represent authoritativeness and high quality. It is normally assumed that the greater the number of citations that an article receives, the greater impact that article has within its particular research area. 

However, not all articles are equally important. Hence, this approach based on <a href="/docs/graph-analytics-algorithms/pagerank">PageRank</a> was proposed to rank articles.

ArticleRank retains the basic PageRank methodology while making some modifications. When an article passes its rank among its forward links, it does not divide the rank equally by the out-degree of that article, but by the sum of the out-degree of that article and the average out-degree of all articles. The rank of article <i>u</i> after one iteration is:

<center><img width=450 src="https://img.ultipa.cn/img/2023-03-23-17-47-45-ar.jpg"></center>

where <i>B<sub>u</sub></i> is the backlink set of <i>u</i>, <i>d</i> is the damping factor. This change of the denominator reduces the bias that an article with very small out-degree makes a greater contribution to its forward links.

> The denominator of Ultipa's ArticleRank is different from the original paper while the core idea is the same.

## Considerations

In comparison with WWW, some features have to be considered for citation networks, such as:

- An article cannot cite itself, i.e., there is no self-loop in the network.
- Two articles cannot cite each other, i.e., an article cannot be both the forward link and the backlink of another article.
- The citations in a published article will not change, i.e., the forward links of an article is fixed.

## Syntax

- Command: `algo(page_rank)`
- Parameters:

| <div table-width="13">Name</div> | <div table-width="7">Type</div> | <div table-width="10">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| init_value | float | >0 | `0.2` | Yes | The same initial rank for all nodes |
| loop_num | int | >=1 | `5` | Yes | Number of iterations |
| damping | float | (0,1) | `0.8` | Yes | Damping factor |
| weaken | int | `1`, `2` | `1` | No | For ArticleRank, keep it as `2`; `1` means to run <a href="/docs/graph-analytics-algorithms/pagerank">PageRank</a> |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order | string | `asc`, `desc` | / | Yes | Sort nodes by the rank |
  
## Examples

The example graph is as follows:

<div align=center drawio-diagram='4882' drawio-name="draw_3567da410d274c708999de9375e546cb.jpg"><img src="https://img.ultipa.cn/draw/draw_3567da410d274c708999de9375e546cb.jpg?v='1733880744652'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`rank` |

```js
algo(page_rank).params({
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 2,
  order: 'desc'
}).write({
    file: {filename: 'rank'}
})
```

Results: File <i>rank</i>

<p run-tag="false" graph="" tit="File" ></p>

```js
book4,0.428308
book5,0.375926
book6,0.319926
book7,0.2
book3,0.2
book2,0.2
book1,0.2
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `rank` | Node property | `float` |

```js
algo(page_rank).params({
  loop_num: 50,
  weaken: 2
}).write({
  db:{property: 'AR'}
})
```

Results: Rank for each node is written to a new property named <i>AR</i>

### Direct Return

| Alias Ordinal| Type | Description | Columns |
| --------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its rank | `_uuid`, `rank` |

```js
algo(page_rank).params({
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 2,
  order: 'desc',
  limit: 3
}) as AR 
return AR
```

Results: <i>PR</i>

| \_uuid | rank |
| -- | -- |
| 4 | 0.42830801 |
| 5 | 0.37592599 |
| 6 | 0.31992599 |

### Stream Return

| Alias Ordinal| Type | Description | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its rank | `_uuid`, `rank` |

```js
algo(page_rank).params({
  loop_num: 50,
  damping: 0.8,
  weaken: 2,
  order: 'desc',
  limit: 3
}).stream() as AR 
find().nodes({_uuid == AR._uuid}) as nodes
return table(nodes._id, AR.rank)
```

Results: <i>table(nodes._id, AR.rank)</i>

| nodes.\_id | AR.rank |
| -- | -- |
| book4 | 0.42830801 |
| book5 | 0.37592599 |
| book6 | 0.31992599 |