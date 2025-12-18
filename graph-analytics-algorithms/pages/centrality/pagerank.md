# PageRank

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span> <span class="flag" style="background:#014d4e;color:#fff;"><b>Distributed</b></span></div>

## Overview

PageRank was originally proposed in the context of World Wide Web (WWW), it takes advantage of the link structure of WWW to produce a global objective 'importance' ranking of webpages that can be used by search engines. This algorithm was proposed in 1997-1998 by Google co-founders Larry Page and Sergey Brin.

- L. Page, S Brin, R. Motwani, T. Winograd, <a target="_blank" href="https://www.cis.upenn.edu/~mkearns/teaching/NetworkedLife/pagerank.pdf">The PageRank Citation Ranking: Bringing Order to The Web</a> (1998)

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

- The rank of isolated webpages will stay the same as the value of <i>(1 - d)</i>.
- Self-loop is regarded as a forward link and a backlink, a webpage would pass some rank to itself through self-loop. If a network has many self-loops, it will take more iterations to converge. 

## Example Graph

<div align=center drawio-diagram='20046' drawio-name='draw_aa8da8a8cc08406e8037b9474a0d4b9d.jpg'><img src="https://img.ultipa.cn/draw/draw_aa8da8a8cc08406e8037b9474a0d4b9d.jpg?v='1735808851353'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  account ()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  follow ()-[]->()
};
INSERT (A:account {_id: "A"}),
       (B:account {_id: "B"}),
       (C:account {_id: "C"}),
       (D:account {_id: "D"}),
       (E:account {_id: "E"}),
       (F:account {_id: "F"}),
       (G:account {_id: "G"}),
       (H:account {_id: "H"}),
       (I:account {_id: "I"}),
       (J:account {_id: "J"}),
       (K:account {_id: "K"}),
       (L:account {_id: "L"}),
       (M:account {_id: "M"}),
       (N:account {_id: "N"}),
       (A)-[:follow]->(E),
       (B)-[:follow]->(E),
       (C)-[:follow]->(A),
       (C)-[:follow]->(H),
       (D)-[:follow]->(J),
       (E)-[:follow]->(G),
       (E)-[:follow]->(G),
       (E)-[:follow]->(I),
       (E)-[:follow]->(N),
       (F)-[:follow]->(L),
       (F)-[:follow]->(B),
       (H)-[:follow]->(C),
       (H)-[:follow]->(E),
       (I)-[:follow]->(E),
       (J)-[:follow]->(E),
       (K)-[:follow]->(E),
       (K)-[:follow]->(M),
       (L)-[:follow]->(E),
       (L)-[:follow]->(F),
       (L)-[:follow]->(N),
       (M)-[:follow]->(E),
       (N)-[:follow]->(F);
```

```uql
create().node_schema("account").edge_schema("follow");
insert().into(@account).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}, {_id:"G"}, {_id:"H"}, {_id:"I"}, {_id:"J"}, {_id:"K"}, {_id:"L"}, {_id:"M"}, {_id:"N"}]);
insert().into(@follow).edges([{_from:"A", _to:"E"}, {_from:"B", _to:"E"}, {_from:"C", _to:"A"}, {_from:"C", _to:"H"}, {_from:"D", _to:"J"}, {_from:"E", _to:"G"}, {_from:"E", _to:"G"},{_from:"E", _to:"I"}, {_from:"E", _to:"N"}, {_from:"F", _to:"L"}, {_from:"F", _to:"B"}, {_from:"H", _to:"C"}, {_from:"H", _to:"E"}, {_from:"I", _to:"E"}, {_from:"J", _to:"E"}, {_from:"K", _to:"E"}, {_from:"K", _to:"M"}, {_from:"L", _to:"E"}, {_from:"L", _to:"F"}, {_from:"L", _to:"N"}, {_from:"M", _to:"E"}, {_from:"N", _to:"F"}]);
```

</div>

## Running on HDC Graphs

### Creating HDC Graph

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

### Parameters

Algorithm name: `page_rank`

| <div table-width="18">Name</div> | <div table-width="10">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `init_value` | Float | >0 | `0.2` | Yes | The initial rank assigned to all nodes. |
| `loop_num` | Integer | ≥1 | `5` | Yes | The maximum number of iteration rounds. The algorithm terminates after all iterations are completed. |
| `damping` | Float | (0,1) | `0.8` | Yes | The damping factor. |
| `weaken` | Integer | `1`, `2` | `1` | Yes | Keeps it as `1` for PageRank. Sets to `2` will run <a target = "_blank" href="/docs/graph-analytics-algorithms/article-rank">ArticleRank</a>. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both values to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned; `-1` includes all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `rank`. |

### File Writeback

<div tab="code">
  
```gql  
CALL algo.page_rank.write("my_hdc_graph", {
  return_id_uuid: "id",
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 1,
  order: "desc"
}, {
  file: {
    filename: "rank"
  }
})
```

```uql
algo(page_rank).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 1,
  order: "desc"
}).write({
  file: {
    filename: "rank"
  }
})
```

</div>

Result:

<p tit="File: rank"></p>

```
_id,rank
E,2.3906
G,1.15624
F,1.03774
N,0.842146
I,0.67812
B,0.615097
L,0.615097
J,0.36
C,0.333333
A,0.333333
H,0.333333
M,0.28
K,0.2
D,0.2
```

### DB Writeback

Writes the `rank` values from the results to the specified node property. The property type is `float`.

<div tab="code">
  
```gql  
CALL algo.page_rank.write("my_hdc_graph", {
  loop_num: 50,
  weaken: 1
}, {
  db: {
    property: "rank"
  }
})
```

```uql
algo(page_rank).params({
  projection: "my_hdc_graph",
  loop_num: 50,
  weaken: 1
}).write({
  db:{ 
    property: "rank"
  }
})
```
  
</div>

### Full Return

<div tab="code">
  
```gql  
CALL algo.page_rank.run("my_hdc_graph", {
  return_id_uuid: "id",    
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 1,
  order: "desc",
  limit: 5
}) YIELD PR
RETURN PR
```

```uql
exec{
  algo(page_rank).params({
    return_id_uuid: "id",    
    init_value: 1,
    loop_num: 50,
    damping: 0.8,
    weaken: 1,
    order: "desc",
    limit: 5
  }) as PR
  return PR
} on my_hdc_graph
```

</div>

Result:

| \_id | rank |
| -- | -- |
| E | 2.390599 |
| G | 1.15624 |
| F | 1.037742 |
| N | 0.842146 |
| I | 0.67812 |

### Stream Return

<div tab="code">
  
```gql  
CALL algo.page_rank.stream("my_hdc_graph", {
  return_id_uuid: "id",
  loop_num: 50,
  damping: 0.8,
  weaken: 1,
  order: "desc",
  limit: 5
}) YIELD PR
RETURN PR
```

```uql
exec{
  algo(page_rank).params({
    return_id_uuid: "id",
    loop_num: 50,
    damping: 0.8,
    weaken: 1,
    order: "desc",
    limit: 5
  }).stream() as PR
  return PR
} on my_hdc_graph
```

</div>

Result:

| \_id | rank |
| -- | -- |
| E | 2.390599 |
| G | 1.15624 |
| F | 1.037742 |
| N | 0.842146 |
| I | 0.67812 |

## Running on Distributed Projections

### Creating Distributed Projection

To project the entire graph to its shard servers as `myProj`:

<div tab="code">

```gql
CREATE PROJECTION myProj OPTIONS {
  nodes: {"*": ["*"]}, 
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true
}
```
  
```uql
create().projection("myProj", {
  nodes: {"*": ["*"]}, 
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true
})
```

</div>

### Parameters

Algorithm name: `page_rank`

| <div table-width="14">Name</div> | <div table-width="10">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `init_value` | Float | >0 | `0.2` | Yes | The initial rank assigned to all nodes. |
| `loop_num` | Integer | ≥1 | `10` | Yes | The maximum number of iteration rounds. The algorithm will terminate after completing all rounds. |
| `damping` | Float | (0,1) | `0.8` | Yes | The damping factor. |
| `weaken` | Integer | `1`, `2` | `1` | Yes | Keeps it as `1` for PageRank. Sets to `2` will run <a target = "_blank" href="/docs/graph-analytics-algorithms/article-rank">ArticleRank</a>. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned; `-1` includes all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `rank`. |

### File Writeback

<div tab="code">
  
```gql  
CALL algo.page_rank.write("myProj", {
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 1,
  order: "desc"
}, {
  file: {
    filename: "rank"
  }
})
```

```uql
algo(page_rank).params({
  projection: "myProj",
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 1,
  order: "desc"
}).write({
  file: {
    filename: "rank"
  }
})
```

</div>

Result:

<p tit="File: rank"></p>

```
_id,rank
E,2.3906
G,1.15624
F,1.03774
N,0.842146
I,0.67812
B,0.615097
L,0.615097
J,0.36
C,0.333333
A,0.333333
H,0.333333
M,0.28
K,0.2
D,0.2
```

### DB Writeback

Writes the `rank` values from the results to the specified node property. The property type is `double`.

<div tab="code">
  
```gql  
CALL algo.page_rank.write("myProj", {
  loop_num: 50,
  weaken: 1
}, {
  db: {
    property: "rank"
  }
})
```

```uql
algo(page_rank).params({
  projection: "myProj",
  loop_num: 50,
  weaken: 1
}).write({
  db:{ 
    property: "rank"
  }
})
```
  
</div>
