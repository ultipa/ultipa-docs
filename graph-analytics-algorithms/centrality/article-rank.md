# ArticleRank

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

ArticleRank has been derived from <a target = "_blank" href="/docs/graph-analytics-algorithms/pagerank">PageRank</a> to measure the influence of journal articles.

- J. Li, P. Willett, <a target="_blank" href="https://www.emerald.com/insight/content/doi/10.1108/00012530911005544/full/html">ArticleRank: a PageRank-based Alternative to Numbers of Citations for Analysing Citation Networks</a> (2009)

## Concepts

### ArticleRank

Like links between webpages, citations between articles (e.g., books or reports) indicate authority and quality. It is generally assumed that the more citations an article receives, the greater its perceived impact within its research domain. 

However, not all articles are equally important. Hence, this approach based on <a target="_blank" href="/docs/graph-analytics-algorithms/pagerank">PageRank</a> was proposed to rank articles.

ArticleRank retains the basic PageRank methodology while making some modifications. When an article passes its rank among its forward links, it does not divide the rank equally by the out-degree of that article, but by the sum of the out-degree of that article and the average out-degree of all articles. The rank of article <i>u</i> after one iteration is:

<center><img width=450 src="https://img.ultipa.cn/img/2023-03-23-17-47-45-ar.jpg"></center>

where <i>B<sub>u</sub></i> is the backlink set of <i>u</i>, <i>d</i> is the damping factor. This change in the denominator reduces the bias that makes articles with few out-links seem to contribute more to their forward links.

> The denominator of Ultipa's ArticleRank is different from the original paper while the core idea is the same.

## Considerations

In comparison with WWW, some features have to be considered for citation networks, such as:

- An article cannot cite itself, i.e., there is no self-loop in the network.
- Mutual citations are not allowed; an article cannot be both a forward link and a backlink at the same time.
- Citations in a published article are fixed, meaning its forward links remain static.

## Example Graph

<div align=center drawio-diagram='19741' drawio-name='draw_6c32787d5acc41c6bff6286aa0316ee7.jpg'><img src="https://img.ultipa.cn/draw/draw_6c32787d5acc41c6bff6286aa0316ee7.jpg?v='1733821155263'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  book ()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  cite ()-[]->()
};
INSERT (book1:book {_id: "book1"}),
       (book2:book {_id: "book2"}),
       (book3:book {_id: "book3"}),
       (book4:book {_id: "book4"}),
       (book5:book {_id: "book5"}),
       (book6:book {_id: "book6"}),
       (book7:book {_id: "book7"}),       
       (book1)-[:cite]->(book4),
       (book1)-[:cite]->(book5),
       (book2)-[:cite]->(book4),
       (book3)-[:cite]->(book4),
       (book4)-[:cite]->(book5),
       (book4)-[:cite]->(book6);
```

```uql
create().node_schema("book").edge_schema("cite");
insert().into(@book).nodes([{_id:"book1"}, {_id:"book2"}, {_id:"book3"}, {_id:"book4"}, {_id:"book5"}, {_id:"book6"}, {_id:"book7"}]);
insert().into(@cite).edges([{_from:"book1", _to:"book4"}, {_from:"book1", _to:"book5"}, {_from:"book2", _to:"book4"}, {_from:"book3", _to:"book4"}, {_from:"book4", _to:"book5"}, {_from:"book4", _to:"book6"}]);
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

Algorithm name: `page_rank`

| <div table-width="18">Name</div> | <div table-width="10">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `init_value` | Float | >0 | `0.2` | Yes | The initial rank assigned to all nodes. |
| `loop_num` | Integer | ≥1 | `5` | Yes | The maximum number of iteration rounds. The algorithm terminates after all iterations are completed. |
| `damping` | Float | (0,1) | `0.8` | Yes | The damping factor. |
| `weaken` | Integer | `1`, `2` | `1` | Yes | Keeps it as `2` for ArticleRank. Sets to `1` will run <a target = "_blank" href="/docs/graph-analytics-algorithms/pagerank">PageRank</a>. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both values to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned; `-1` includes all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `rank`. |

## File Writeback

<div tab="code">
  
```gql  
CALL algo.page_rank.write("my_hdc_graph", {
  return_id_uuid: "id",
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 2,
  order: "desc"
}, {
  file: {
    filename: "article_rank"
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
  weaken: 2,
  order: "desc"
}).write({
  file: {
    filename: "article_rank"
  }
})
```

</div>

Result:

<p tit="File: article_rank" ></p>

```
_id,rank
book4,0.428308
book5,0.375926
book6,0.319926
book2,0.2
book3,0.2
book7,0.2
book1,0.2
```

## DB Writeback

Writes the `rank` values from the results to the specified node property. The property type is `float`.

<div tab="code">
  
```gql  
CALL algo.page_rank.write("my_hdc_graph", {
  loop_num: 50,
  weaken: 2 
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
  weaken: 2  
}).write({
  db:{ 
    property: 'rank'
  }
})
```

</div>

## Full Return

<div tab="code">
  
```gql  
CALL algo.page_rank.run("my_hdc_graph", {
  return_id_uuid: "id",
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  weaken: 2,
  order: "desc",
  limit: 3
}) YIELD AR
RETURN AR
```

```uql
exec{
  algo(page_rank).params({
    return_id_uuid: "id",
    init_value: 1,
    loop_num: 50,
    damping: 0.8,
    weaken: 2,
    order: "desc",
    limit: 3
  }) as AR
  return AR
} on my_hdc_graph
```
  
</div>

Result:

| \_id | rank |
| -- | -- |
| book4 | 0.428308 |
| book5 | 0.375926 |
| book6 | 0.319926 |

## Stream Return

<div tab="code">
  
```gql  
CALL algo.page_rank.stream("my_hdc_graph", {
  return_id_uuid: "id",
  loop_num: 50,
  damping: 0.8,
  weaken: 2,
  order: "desc",
  limit: 3
}) YIELD AR
RETURN AR
```

```uql
exec{
  algo(page_rank).params({
    return_id_uuid: "id",
    loop_num: 50,
    damping: 0.8,
    weaken: 2,
    order: "desc",
    limit: 3
  }).stream() as AR
  return AR
} on my_hdc_graph
````

</div>

Result:

| \_id | rank |
| -- | -- |
| book4 | 0.428308 |
| book5 | 0.375926 |
| book6 | 0.319926 |
