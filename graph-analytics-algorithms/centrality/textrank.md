# TextRank

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

TextRank, derived from <a target="_blank" href="/docs/graph-analytics-algorithms/pagerank">PageRank</a>, is a graph-based ranking model for text processing. It can be used for various natural language processing tasks, including keyword extraction, keyphrase extraction, and text summarization.

- R. Mihalcea, P. Tarau, <a href="https://web.eecs.umich.edu/~mihalcea/papers/mihalcea.emnlp04.pdf" target="_blank">TextRank: Bringing Order Into Texts</a> (2004)

## Concepts

### Text as a Graph

To apply the TextRank algorithm, the text must first be represented as a graph .The structure of the graph depends on the specific application:

- **Nodes:** Text units that best fit the task, such as words, collocations, or sentences, are added as nodes in the graph.
- **Edges:** Relationships between text units, such as semantic similarity, co-occurrence, or contextual overlap, are used to connect nodes with edges.

<center><img width=500 src="https://img.ultipa.cn/img/2024-07-29-10-26-14-keyword-extraction.jpg"><br><span style="color:#999;">Sample graph build for keyphrase extraction: nodes are selected lexical units from the text, and edges are established based on co-occurrence within a defined window of words (Source: <a href="https://web.eecs.umich.edu/~mihalcea/papers/mihalcea.emnlp04.pdf" target="_blank">Original paper</a>)</span></center><br>

### TextRank Model

TextRank computes the ranks of all text units recursively using a "recommendation" mechanism, similar to the <a target="_blank" href="/docs/graph-analytics-algorithms/pagerank">PageRank</a> algorithm. It incorporates edge weights through a modified formula that integrates them effectively:

<center><img width=380 src="https://img.ultipa.cn/img/2024-07-26-10-51-41-TextRank-formula.png"></center>

where,
- <i>Out(v)</i> is the set of nodes that node <i>v</i> points to;
- <i>w<sub>vu</sub></i> is the edge weight between nodes <i>v</i> and <i>u</i>;
- <i>d</i> is the damping factor.
  
## Considerations

- The rank of isolated text unit will stay the same as the value of *(1 - d)*.
- A self-loop acts as both a successor and a predecessor, meaning a node can pass some rank to itself. If a network has many self-loops, it will take more iterations to converge.

## Example Graph

<div align=center drawio-diagram='19735' drawio-name="draw_7b9329b5de7346e280b9fc31e203a8fa.jpg"><img src="https://img.ultipa.cn/draw/draw_7b9329b5de7346e280b9fc31e203a8fa.jpg?v='1733816740161'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER EDGE default ADD PROPERTY {
  weight int32
};
INSERT (A:default {_id: "A"}),
       (B:default {_id: "B"}),
       (C:default {_id: "C"}),
       (D:default {_id: "D"}),
       (E:default {_id: "E"}),
       (F:default {_id: "F"}),
       (G:default {_id: "G"}),       
       (A)-[:default {weight: 3}]->(E),
       (B)-[:default {weight: 3}]->(A),
       (B)-[:default {weight: 2}]->(E),
       (C)-[:default {weight: 1}]->(A),
       (C)-[:default {weight: 4}]->(D),
       (D)-[:default {weight: 5}]->(E),
       (E)-[:default {weight: 2}]->(G),
       (F)-[:default {weight: 1}]->(B),
       (F)-[:default {weight: 3}]->(G);
```

```uql
create().edge_property(@default, "weight", int32);
insert().into(@default).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}, {_id:"G"}]);
insert().into(@default).edges([{_from:"A", _to:"E", weight:3}, {_from:"B", _to:"A", weight:3}, {_from:"B", _to:"E", weight:2}, {_from:"C", _to:"A", weight:1}, {_from:"C", _to:"D", weight:4}, {_from:"D", _to:"E", weight:5}, {_from:"E", _to:"G", weight:2}, {_from:"F", _to:"B", weight:1}, {_from:"F", _to:"G", weight:3}]);
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

Algorithm name: `text_rank`

| <div table-width="18">Name</div> | <div table-width="10">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `init_value` | Float | >0 | `0.2` | Yes | The initial rank assigned to all nodes. |
| `loop_num` | Integer | ≥1 | `5` | Yes | The maximum number of iteration rounds. The algorithm terminates after all iterations are completed. |
| `damping` | Float | (0,1) | `0.8` | Yes | The damping factor. |
| `max_change` | Float | ≥0 | `0` | Yes | The algorithm terminates when the changes in all ranks between iterations are less than the specified `max_change`, indicating that the result is stable. Sets to `0` to disable this criterion. |
| `edge_schema_property` | []"`<@schema.?><property>`" | / | / | No | Numeric edge properties as weights, summing values across the specified properties; edges without the specified properties are ignored. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both values to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned; `-1` includes all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `rank`. |

## File Writeback

<div tab="code">
  
```gql  
CALL algo.text_rank.write("my_hdc_graph", {
  return_id_uuid: "id",
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  edge_schema_property: "weight",
  order: "desc"
}, {
  file: {
    filename: "textrank"
  }
})
```

```uql
algo(text_rank).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  edge_schema_property: "weight",
  order: 'desc'
}).write({
  file: {
    filename: "textrank"
  }
})
```

</div>

Result:

<p tit="File: textrank"></p>

```
_id,text_rank
G,0.973568
E,0.81696
A,0.3472
D,0.328
B,0.24
F,0.2
C,0.2
```
  
## DB Writeback

Writes the `text_rank` values from the results to the specified node property. The property type is `double`.

<div tab="code">
  
```gql  
CALL algo.text_rank.write("my_hdc_graph", {
  loop_num: 50,
  edge_schema_property: "@default.weight"
}, {
  db: {
    property: "rank"
  }
})
```

```uql
algo(text_rank).params({
  projection: "my_hdc_graph",
  loop_num: 50,
  edge_schema_property: "@default.weight"
}).write({
  db:{ 
    property: "rank"
  }
})
```
  
</div>

## Full Return 

<div tab="code">
  
```gql  
CALL algo.text_rank.run("my_hdc_graph", {
  return_id_uuid: "id",    
  init_value: 1,
  loop_num: 50,
  damping: 0.8,
  edge_schema_property: "weight",
  order: "desc",
  limit: 5
}) YIELD TR
RETURN TR
```

```uql
exec{
  algo(text_rank).params({
    return_id_uuid: "id",    
    init_value: 1,
    loop_num: 50,
    damping: 0.8,
    edge_schema_property: "weight",
    order: "desc",
    limit: 5
  }) as TR
  return TR
} on my_hdc_graph
```

</div>

Result:

| \_id | text_rank |
| -- | -- |
| G | 0.973568 |
| E | 0.81696 |
| A | 0.3472 |
| D | 0.328 |
| B | 0.24 |

## Stream Return

<div tab="code">
  
```gql  
CALL algo.text_rank.stream("my_hdc_graph", {
  return_id_uuid: "id",
  loop_num: 50,
  damping: 0.8,
  edge_schema_property: "weight",
  order: "desc",
  limit: 5
}) YIELD TR
RETURN TR
```

```uql
exec{
  algo(text_rank).params({
    return_id_uuid: "id",
    loop_num: 50,
    damping: 0.8,
    edge_schema_property: "weight",
    order: "desc",
    limit: 5
  }).stream() as TR
  return TR
} on my_hdc_graph
```

</div>

Result:

| \_id | text_rank |
| -- | -- |
| G | 0.973568 |
| E | 0.81696 |
| A | 0.3472 |
| D | 0.328 |
| B | 0.24 |
