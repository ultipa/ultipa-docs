# Node2Vec Walk

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

Diverging from the classic <a target="_blank" href="/docs/graph-analytics-algorithms/random-walk">random walk</a>, the Node2Vec Walk introduces a biased strategy that allows the exploration of node neighborhoods in both BFS and DFS manners. For more information, please refer to the <a target="_blank" href="/docs/graph-analytics-algorithms/node2vec">Node2Vec</a> algorithm.

## Considerations

- Self-loops can also be traversed during a random walk.
- The Node2Vec Walk algorithm treats all edges as undirected, ignoring their original direction.

## Example Graph

<div align=center drawio-diagram='19942' drawio-name='draw_451c6c9dd27843b1aeaa1fff7c117ab2.jpg'><img src="https://img.ultipa.cn/draw/draw_451c6c9dd27843b1aeaa1fff7c117ab2.jpg?v='1734602301917'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER EDGE default ADD PROPERTY {
  score float
};
INSERT (A:default {_id: "A"}),
       (B:default {_id: "B"}),
       (C:default {_id: "C"}),
       (D:default {_id: "D"}),
       (E:default {_id: "E"}),
       (F:default {_id: "F"}),
       (G:default {_id: "G"}),
       (H:default {_id: "H"}),
       (I:default {_id: "I"}),
       (J:default {_id: "J"}),
       (K:default {_id: "K"}),
       (A)-[:default {score: 1}]->(B),
       (A)-[:default {score: 3}]->(C),
       (C)-[:default {score: 1.5}]->(D),
       (D)-[:default {score: 2.4}]->(C),
       (D)-[:default {score: 5}]->(F),
       (E)-[:default {score: 2.2}]->(C),
       (E)-[:default {score: 0.6}]->(F),
       (F)-[:default {score: 1.5}]->(G),
       (G)-[:default {score: 2}]->(J),
       (H)-[:default {score: 2.5}]->(G),
       (H)-[:default {score: 1}]->(I),
       (I)-[:default {score: 3.1}]->(I),
       (J)-[:default {score: 2.6}]->(G);
```

```uql
create().edge_property(@default, "score", float);
insert().into(@default).nodes([{_id:"A"},{_id:"B"},{_id:"C"},{_id:"D"},{_id:"E"},{_id:"F"},{_id:"G"},{_id:"H"},{_id:"I"},{_id:"J"},{_id:"K"}]);
insert().into(@default).edges([{_from:"A", _to:"B", score:1}, {_from:"A", _to:"C", score:3}, {_from:"C", _to:"D", score:1.5}, {_from:"D", _to:"C", score:2.4}, {_from:"D", _to:"F", score:5}, {_from:"E", _to:"C", score:2.2}, {_from:"E", _to:"F", score:0.6}, {_from:"F", _to:"G", score:1.5}, {_from:"G", _to:"J", score:2}, {_from:"H", _to:"G", score:2.5}, {_from:"H", _to:"I", score:1}, {_from:"I", _to:"I", score:3.1}, {_from:"J", _to:"G", score:2.6}]);
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

Algorithm name: `random_walk_node2vec`

| <div table-width="17">Name</div> | <div table-width="10">Type</div> | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `ids` | []`_id` | / | / | Yes | Specifies nodes to start random walk by their `_id`. If unset, computation includes all nodes. |
| `uuids` | []`_uuid` | / | / | Yes | Specifies nodes to start random walk by their `_uuid`. If unset, computation includes all nodes. |
| `walk_length` | Integer | ≥1 | `1` | Yes | Depth of each walk, i.e., the number of nodes to visit. | 
| `walk_num` | Integer | ≥1 | `1` | Yes | Number of walks to perform for each specified node. |
| `p` | Float | >0 | `1` | Yes | The <i>return</i> parameter; a larger value reduces the probability of returning. |
| `q` | Float | >0 | `1` | Yes | The <i>in-out</i> parameter; it tends to walk at the same level when the value is greater than 1, otherwise it tends to walk far away. |
| `edge_schema_property` | []"`<@schema.?><property>`" | / | / | Yes | Numeric edge properties used as edge weights, summing values across the specified properties; edges without the specified properties are ignored. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both values to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results. |

## File Writeback

<div tab="code">
  
```gql  
CALL algo.random_walk_node2vec.write("my_hdc_graph", {
  return_id_uuid: "id",
  walk_length: 6,
  walk_num: 2,
  p: 10000, 
  q: 0.0001
}, {
  file: {
    filename: "walks"
  }
})
```

```uql
algo(random_walk_node2vec).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  walk_length: 6,
  walk_num: 2,
  p: 10000, 
  q: 0.0001
}).write({
  file:{
    filename: 'walks'
}})
```

</div>

Result:

<p tit="File: walk"></p>

```
_ids
J,G,F,D,C,E,
D,C,A,B,A,C,
F,G,E,C,A,B,
H,I,I,H,G,F,
B,A,C,D,F,G,
A,B,A,B,A,C,
E,C,E,C,A,B,
K,
C,E,F,G,J,G,
I,I,H,G,F,E,
G,H,I,I,H,G,
J,G,F,D,C,E,
D,C,A,B,A,C,
F,E,C,D,F,E,
H,G,H,G,J,G,
B,A,C,D,F,G,
A,C,D,F,E,C,
E,C,E,C,A,B,
K,
C,A,B,A,C,D,
I,H,G,J,G,H,
G,H,I,I,H,G,
```

## Full Return

<div tab="code">
  
```gql  
CALL algo.random_walk_node2vec.run("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ['J'],
  walk_length: 6,
  walk_num: 3,
  p: 2000,
  q: 0.001
}) YIELD walks
RETURN walks
```

```uql
exec{
  algo(random_walk_node2vec).params({
    return_id_uuid: "id",
    ids: ['J'],
    walk_length: 6,
    walk_num: 3,
    p: 2000,
    q: 0.001
  }) as walks
  return walks
} on my_hdc_graph
```

</div>

Result:

| \_ids |
| -- |
| ["J","G","F","D","C","E"] |
| ["J","G","J","G","F","D"] |
| ["J","G","J","G","H","I"] |

## Stream Return

<div tab="code">
  
```gql  
CALL algo.random_walk_node2vec.stream("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ['A'],
  walk_length: 5,
  walk_num: 10,
  p: 1000,
  q: 1,
  edge_schema_property: 'score'
}) YIELD walks
RETURN walks
```

```uql
exec{
  algo(random_walk_node2vec).params({
    return_id_uuid: "id",
    ids: ['A'],
    walk_length: 5,
    walk_num: 10,
    p: 1000,
    q: 1,
    edge_schema_property: 'score'
  }).stream() as walks
  return walks
} on my_hdc_graph
```

</div>

Result:

| \_ids |
| -- |
| ["A","C","A","D","C"] |
| ["A","C","A","C","A"] |
| ["A","C","A","D","A"] |
| ["A","C","A","C","A"] |
| ["A","C","A","D","E"] |
| ["A","C","A","D","E"] |
| ["A","C","A","B","A"] |
| ["A","C","A","D","A"] |
| ["A","C","A","C","D"] |
| ["A","C","A","C","A"] |
