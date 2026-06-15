# Katz Centrality

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

Katz Centrality measures the influence of a node by considering not only its immediate connections but also its indirect connections at various distances while diminishing importance to more distant nodes.

Katz centrality values range from 0 to 1, with higher scores indicating nodes that exert greater influence over the flow and connectivity of the network.

References:

-  L. Katz, <a href="https://cse.iitkgp.ac.in/~bivasm/cnt_notes/katz-1953.pdf" target="_blank">A New Status Index Derived from Sociometric Analysis</a> (1953)

## Concepts

### Katz Centrality

The Katz centrality is an extension of the <a target="_blank" href="/docs/graph-analytics-algorithms/eigenvector-centrality">eigenvector centrality</a>. In the `k`-th round of influence propagation in eigenvector centrality, the centrality vector is simply updated as <code>c<sup>(k)</sup> = Ac<sup>(k-1)</sup></code>, where `A` is the adjacency matrix. Katz centrality modifies this computation by introducing two additional parameters, leading to the following update formula (which should be rescaled afterward):

<center><img width="260" src="https://img.ultipa.cn/img/2025-03-04-15-35-16-katz.jpg"></center>

where,

- `α` (alpha) is an **attenuation factor** that controls how influence decays during each propagation round. In the `k`-th round, the influences from indirect neighbors that are `k` steps away are considered, with their contributions cumulatively attenuated by a factor of <code>α<sup>k</sup></code>. **To ensure the convergence of <code>c<sup>(k)</sup></code>, `α` must be smaller than <code>1/λ<sub>max</sub></code>**, where <code>λ<sub>max</sub></code> is the dominant eigenvalue of the adjacency matrix `A`.
- `β` (beta) is a **baseline centrality** constant that ensures each node has a nonzero centrality score, even when it receives no influence. The common choice for `β` is 1.
- `1` is an n × 1 column vector of ones, where n is the number of nodes in the graph.

<div align=center drawio-diagram='21606' drawio-name="draw_bf6d495919d24ecbb7ec9be125d30e70.jpg"><img src="https://img.ultipa.cn/draw/draw_bf6d495919d24ecbb7ec9be125d30e70.jpg?v='1741074327474'"/></div>

## Example Graph

<div align=center drawio-diagram='21593' drawio-name='draw_451e265340654f6f83bac28f0a95d09e.jpg'><img src="https://img.ultipa.cn/draw/draw_451e265340654f6f83bac28f0a95d09e.jpg?v='1741052078802'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  web ()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  link ()-[{value float}]->()
};
INSERT (web1:web {_id: "web1"}),
       (web2:web {_id: "web2"}),
       (web3:web {_id: "web3"}),
       (web4:web {_id: "web4"}),
       (web5:web {_id: "web5"}),
       (web6:web {_id: "web6"}),
       (web7:web {_id: "web7"}),
       (web1)-[:link {value: 2}]->(web1),
       (web1)-[:link {value: 1}]->(web2),
       (web2)-[:link {value: 0.8}]->(web3),
       (web3)-[:link {value: 0.5}]->(web1),
       (web3)-[:link {value: 1.1}]->(web2),
       (web3)-[:link {value: 1.2}]->(web4),
       (web3)-[:link {value: 0.5}]->(web5),
       (web5)-[:link {value: 0.5}]->(web3),
       (web6)-[:link {value: 2}]->(web6);
```

```uql
create().node_schema("web").edge_schema("link");
create().edge_property(@link, "value", float);
insert().into(@web).nodes([{_id:"web1"}, {_id:"web2"}, {_id:"web3"}, {_id:"web4"}, {_id:"web5"}, {_id:"web6"}, {_id:"web7"}]);
insert().into(@link).edges([{_from:"web1", _to:"web1",value:2}, {_from:"web1", _to:"web2",value:1}, {_from:"web2", _to:"web3",value:0.8}, {_from:"web3", _to:"web1",value:0.5}, {_from:"web3", _to:"web2",value:1.1}, {_from:"web3", _to:"web4",value:1.2}, {_from:"web3", _to:"web5",value:0.5}, {_from:"web5", _to:"web3",value:0.5}, {_from:"web6", _to:"web6",value:2}]);
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

Algorithm name: `katz_centrality`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="7">Spec</div> | <div table-width="8">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `max_loop_num` | Integer | ≥1 | `20` | Yes | The maximum number of iteration rounds. The algorithm terminates after all iterations are completed. |
| `tolerance` | Float | (0,1) | `0.001` | Yes | The algorithm terminates when the changes in all scores between iterations are less than the specified `tolerance`, indicating that the result is stable. |
| `edge_weight_property` | "`<@schema.?><property>`" | / | / | Yes | A numeric edge property used as weights in the adjacency matrix `A`; edges without this property are ignored. |
| `direction` | String | `in`, `out` | / | Yes | Constructs the adjacency matrix `A` with the in-links (`in`) or out-links (`out`) of each node. |
| `alpha` | Float | (0, 1/λ<sub>max</sub>) | `0.25` | Yes | The attenuation factor, which must be less than the inverse of dominant eigenvalue (λ<sub>max</sub>) of the adjacency matrix `A`. |
| `beta` | Float | >0 | `1` | Yes | The baseline centrality constant that ensures every node has a nonzero centrality score. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned; `-1` includes all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `katz_centrality`. |

## File Writeback

<div tab="code">
  
```gql  
CALL algo.katz_centrality.write("my_hdc_graph", {
  return_id_uuid: "id",
  max_loop_num: 50,
  tolerance: 0.00001,
  direction: "in",
  alpha: 0.4
}, {
  file: {
    filename: "katz_centrality"
  }
})
```

```uql
algo(katz_centrality).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  max_loop_num: 50,
  tolerance: 0.00001,
  direction: "in",
  alpha: 0.4
}).write({
  file: {
    filename: "katz_centrality"
  }
})
```

</div>

Result:

<p tit="File: katz_centrality"></p>

```
_id,katz_centrality
web3,0.458447
web7,0.127183
web1,0.517601
web5,0.310561
web6,0.211972
web2,0.517601
web4,0.310561
```

## DB Writeback

Writes the `katz_centrality` values from the results to the specified node property. The property type is `double`.

<div tab="code">
  
```gql  
CALL algo.katz_centrality.write("my_hdc_graph", {
  edge_weight_property: "@link.value"
}, {
  db: {
    property: "kc"
  }
})
```

```uql
algo(katz_centrality).params({
  projection: "my_hdc_graph",
  edge_weight_property: "@link.value"
}).write({
  db:{ 
    property: 'kc'
  }
})
```

</div>
  
## Full Return

<div tab="code">
  
```gql 
CALL algo.katz_centrality.run("my_hdc_graph", {
  return_id_uuid: "id",    
  max_loop_num: 100,
  tolerance: 0.00001,
  edge_weight_property: "value",
  direction: "in",
  alpha: 0.4,
  beta: 1,
  order: "desc"
}) YIELD r
RETURN r
```

```uql
exec{
  algo(katz_centrality).params({
    return_id_uuid: "id",    
    max_loop_num: 100,
    tolerance: 0.00001,
    edge_weight_property: "value",
    direction: "in",
    alpha: 0.4,
    beta: 1,
    order: "desc"
  }) as kc
  return kc
} on my_hdc_graph
```

</div>

Result:

| \_id | katz_centrality |
| -- | -- |
| web1 | 0.681081665151973 |
| web2 | 0.471519549878494 |
| web6 | 0.419136320993772 |
| web3 | 0.261956715748936 |
| web4 | 0.20956622151173 |
| web5 | 0.136218518184715 |
| web7 | 0.0838273050914304 |

## Stream Return

<div tab="code">
  
```gql  
CALL algo.katz_centrality.stream("my_hdc_graph", {
  return_id_uuid: "id",    
  max_loop_num: 100,
  tolerance: 0.00001,
  edge_weight_property: "value",
  direction: "in",
  alpha: 0.4,
  beta: 1,
  order: "desc"
}) YIELD kc
RETURN kc
```

```uql
exec{
  algo(katz_centrality).params({
    return_id_uuid: "id",    
    max_loop_num: 100,
    tolerance: 0.00001,
    edge_weight_property: "value",
    direction: "in",
    alpha: 0.4,
    beta: 1,
    order: "desc"
  }).stream() as kc
  return kc
} on my_hdc_graph
```

</div>
  
Result:

| \_id | katz_centrality |
| -- | -- |
| web1 | 0.681081665151973 |
| web2 | 0.471519549878494 |
| web6 | 0.419136320993772 |
| web3 | 0.261956715748936 |
| web4 | 0.20956622151173 |
| web5 | 0.136218518184715 |
| web7 | 0.0838273050914304 |
