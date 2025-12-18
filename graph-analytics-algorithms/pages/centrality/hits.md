# HITS

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

The HITS (Hyperlink-Induced Topic Search) algorithm was developed by L.M. Kleinberg in 1999 with the purpose of improving the quality of search methods on the World Wide Web (WWW). HITS makes use of the mutual reinforcing relationship between <i>authorities</i> and <i>hubs</i> to evaluate and rank a set of linked entities.

- L.M. Kleinberg, <a target="_blank" href="https://www.cs.cornell.edu/home/kleinber/auth.pdf">Authoritative Sources in a Hyperlinked Environment</a> (1999)

## Concepts

### Authority and Hub

In WWW, hyperlinks represent some latent human judgment: the creator of page <i>p</i>, by including a link to page <i>q</i>, has in some measure conferred authority on <i>q</i>. Instructively, a node with large in-degree is viewed as an <b>authority</b>.

If a node points to a considerable number of authoritative nodes, it is referred to as a <b>hub</b>. 

As illustrated in the graph below, red nodes represent good authorities, while green nodes represent good hubs.

<div align="center" drawio-diagram='3907' drawio-name='draw_2ed110856aed4603a573d6aeaa79610b.jpg'><img src="https://img.ultipa.cn/draw/draw_2ed110856aed4603a573d6aeaa79610b.jpg?v='1672217278797'"/></div>

Hubs and authorities exhibit a mutually reinforcing relationship: a good hub points to many good authorities; a good authority is pointed to by many good hubs.

### Compute Authorities and Hubs

HITS algorithm operates on the whole graph iteratively to compute the <b>authority weight</b> (denoted as <i>x</i>) and <b>hub weight</b> (denoted as <i>y</i>) for each node through the link structure. Nodes with larger <i>x</i>-values and <i>y</i>-values are viewed as better authorities and hubs respectively.

In a directed graph <i>G = (V, E)</i>, all nodes are initialized with <i>x = 1</i> and <i>y = 1</i>. In each iteration, for each node <i>p ∈ V</i>, update its <i>x</i> and <i>y</i> values as follows:

<center><img width="180" src="https://img.ultipa.cn/img/2023-02-01-18-01-37-xy.jpg" /></center>

Here is an example:

<div align='center' drawio-diagram='4899' drawio-name='draw_43b88a2290b64a76ac72baf583da2007.jpg'><img src="https://img.ultipa.cn/draw/draw_43b88a2290b64a76ac72baf583da2007.jpg?v='1680058951390'"/></div>

At the end of one iteration, normalize all <i>x</i> values and all <i>y</i> values to meet the invariant below:

<center><img width="250" src="https://img.ultipa.cn/img/2023-03-29-11-11-42-norm.jpg" /></center>

The algorithm iterates until the changes in all <i>x</i> and <i>y</i> values converge within a specific tolerance, or until the maximum number of iterations is reached. In the experiments of the original author, the convergence is quite rapid, 20 iterations are normally sufficient.

## Considerations

- In HITS algorithm, self-loops are ignored.
- Nodes with no in-links are assigned an authority weight of 0, while nodes with no out-links are assigned a hub weight of 0.

## Example Graph

<div align=center drawio-diagram='19742' drawio-name='draw_1afd6d26761942feba61b9b39ca0b412.jpg'><img src="https://img.ultipa.cn/draw/draw_1afd6d26761942feba61b9b39ca0b412.jpg?v='1733821758235'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
INSERT (A:default {_id: "A"}),
       (B:default {_id: "B"}),
       (C:default {_id: "C"}),
       (D:default {_id: "D"}),
       (E:default {_id: "E"}),
       (F:default {_id: "F"}),
       (G:default {_id: "G"}),
       (H:default {_id: "H"}),
       (A)-[:default]->(F),
       (B)-[:default]->(A),
       (C)-[:default]->(A),
       (C)-[:default]->(B),
       (D)-[:default]->(A),
       (D)-[:default]->(F),
       (E)-[:default]->(A),
       (E)-[:default]->(G),
       (F)-[:default]->(H),
       (G)-[:default]->(F);
```

```uql
insert().into(@default).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}, {_id:"G"}, {_id:"H"}]);
insert().into(@default).edges([{_from:"C", _to:"A"}, {_from:"C", _to:"B"}, {_from:"B", _to:"A"}, {_from:"E", _to:"A"}, {_from:"E", _to:"G"}, {_from:"A", _to:"F"}, {_from:"D", _to:"A"}, {_from:"D", _to:"F"}, {_from:"F", _to:"H"}, {_from:"G", _to:"F"}]);
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

Algorithm name: `hits_centrality`

| <div table-width="19">Name</div> | <div table-width="9">Type</div> | <div table-width="7">Spec</div> | <div table-width="8">Default</div> | <div table-width="5">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `max_loop_num` | Integer | ≥1 | `20` | Yes | The maximum number of iteration rounds. The algorithm will terminate after completing all rounds. |
| `tolerance` | Float | (0,1) | `0.001` | Yes | The algorithm terminates when the changes in all authority and hub weights between iterations are less than the specified `tolerance`, indicating that the result is stable. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both values to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned. Set to `-1` to include all results. |

## File Writeback

<div tab="code">
  
```gql  
CALL algo.hits_centrality.write("my_hdc_graph", {
  return_id_uuid: "id"
}, {
  file: {
    filename: "ranks"
  }
})
```

```uql
algo(hits_centrality).params({
  return_id_uuid: "id",
  projection: "my_hdc_graph"
}).write({
  file: {
    filename: "ranks"
  }
})
```

</div>

Result:

<p tit="File: ranks"></p>

```
_id,authority,hub
D,0,0.572083
F,0.42642,1.43197e-11
H,3.20199e-11,0
B,0.213196,0.381382
A,0.852796,0.190701
E,0,0.476726
C,0,0.476726
G,0.213196,0.190701
```

## DB Writeback

Writes the `authority` and `hub` values from the results to the specified node property. The property types are both `double`.

<div tab="code">
  
```gql  
CALL algo.hits_centrality.write("my_hdc_graph", {
  max_loop_num: 20,
  tolerance: 0.0001
}, {
  db: {
    authority: 'auth',
    hub: 'hub'
  }
})
```

```uql
algo(hits_centrality).params({
  projection: "my_hdc_graph",
  max_loop_num: 20,
  tolerance: 0.0001
}).write({
  db: {
    authority: 'auth',
    hub: 'hub'
  }
})
```
  
</div>

## Full Return 

<div tab="code">
  
```gql  
CALL algo.hits_centrality.run("my_hdc_graph", {
  return_id_uuid: "id"
}) YIELD r
RETURN r
```

```uql
exec{
  algo(hits_centrality).params({
    return_id_uuid: "id"
  }) as r
  return r
} on my_hdc_graph
```

</div>

Result:

| \_id | authority | hub |
| -- | -- | -- |
| D | 0 | 0.572083 |
| F | 0.42642 | 0 |
| H | 0 | 0 |
| B | 0.213196 | 0.381382 |
| A | 0.852796 | 0.190701 |
| E | 0 | 0.476726 |
| C | 0 | 0.476726 |
| G | 0.213196 | 0.190701 |

## Stream Return

<div tab="code">
  
```gql  
CALL algo.hits_centrality.stream("my_hdc_graph", {
  return_id_uuid: "id",
  max_loop_num: 20,
  tolerance: 0.0001
}) YIELD r
RETURN r._id, r.hub ORDER BY r.hub DESC
```

```uql
exec{
  algo(hits_centrality).params({
    return_id_uuid: "id",
    max_loop_num: 20,
    tolerance: 0.0001
  }).stream() as r
  return r._id, r.hub order by r.hub
} on my_hdc_graph
```

</div>

Result:

| r.\_id | r.hub |
| -- | -- |
| D | 0.572083 |
| E | 0.476726 |
| C | 0.476726 |
| B | 0.381382 |
| A | 0.190701 |
| G | 0.190701 |
| F | 0 |
| H | 0 |
