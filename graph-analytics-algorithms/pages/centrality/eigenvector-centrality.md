# Eigenvector Centrality

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

Eigenvector centrality quantifies a node's influence within a graph. A node's importance is determined by its neighbors—it is both influenced by them and exerts influence on them. However, not all connections are equal; a node's centrality increases if it is connected to other highly influential nodes.

Eigenvector centrality takes on values between 0 to 1, nodes with higher centralities are more influential in the network.

## Concepts

### Eigenvector Centrality

The influence of a node is computed in a recursive way. Consider the graph below, and assume that nodes receive influence through incoming edges. In the adjacency matrix `A`, element <code>A<sub>ij</sub></code> reflects the number of incoming edges of node `i`. Initially, each node is randomly assigned a centrality value — all set to 1 as an example —represented by the vector <code>c<sup>(0)</sup></code>.

<div align=center drawio-diagram='21603' drawio-name='draw_0d5e31e7737d4bb6bf28675c0f5663fc.jpg'><img src="https://img.ultipa.cn/draw/draw_0d5e31e7737d4bb6bf28675c0f5663fc.jpg?v='1741071873707'"/></div>

In each round of influence propagation, a node's centrality is updated as the sum of centralities of all its incoming neighbors. In the first round, this operation is equivalent to multiplying the vector <code>c<sup>(0)</sup></code> by the matrix `A`, i.e., <code>c<sup>(1)</sup> = Ac<sup>(0)</sup></code>. Afterward, the L2-normalization is applied to rescale the vector <code>c<sup>(1)</sup></code>:

<div align=center drawio-diagram='21604' drawio-name='draw_23738a8ded4b4356a1afa0b769b1a2d6.jpg'><img src="https://img.ultipa.cn/draw/draw_23738a8ded4b4356a1afa0b769b1a2d6.jpg?v='1741071942869'"/></div>

After `k` rounds, <code>c<sup>(k)</sup></code> is computed by <code>c<sup>(k)</sup> = Ac<sup>(k-1)</sup></code>. As `k` grows, <code>c<sup>(k)</sup></code> stabilizes. In this example, stabilization is reached after approximately 20 rounds. The elements in <code>c<sup>(k)</sup></code> represent the centrality of the corresponding nodes.

<div align=center drawio-diagram='21605' drawio-name='draw_7270dddbdf974ea8b14f7557e8a999be.jpg'><img src="https://img.ultipa.cn/draw/draw_7270dddbdf974ea8b14f7557e8a999be.jpg?v='1741072067963'"/></div>

The algorithm continues until the sum of changes of all elements in <code>c<sup>(k)</sup></code> converges to within some tolerance, or the maximum iteration rounds is met.

### Eigenvalue and Eigenvector

Given that `A` is an n x n square matrix, `λ` is a constant, and `x` is a non-zero n x 1 vector. If the equation `Ax = λx` is true, then `λ` is called the <b>eigenvalue</b> of `A`, and `x` is the <b>eigenvector</b> of `A` that corresponds to `λ`.

The above adjacency matrix `A` has four eigenvalues <code>λ<sub>1</sub></code>, <code>λ<sub>2</sub></code>, <code>λ<sub>3</sub></code> and <code>λ<sub>4</sub></code> that correspond to eigenvectors <code>x<sub>1</sub></code>, <code>x<sub>2</sub></code>, <code>x<sub>3</sub></code> and <code>x<sub>4</sub></code>, respectively. <code>x<sub>1</sub></code> is the eigenvector of the eigenvalue <code>λ<sub>1</sub></code> which has the largtest absolute value. <code>λ<sub>1</sub></code> is the **dominant eigenvalue**, and <code>x<sub>1</sub></code> the **dominant eigenvector**.

<div align='center' drawio-diagram='4811' drawio-name="draw_d8ddda94a4a44baba2ad54f2b363ee5a.jpg"><img src="https://img.ultipa.cn/draw/draw_d8ddda94a4a44baba2ad54f2b363ee5a.jpg?v='1678937639519'"/></div>

In fact, as `k` grows, <code>c<sup>(k)</sup></code> always converges to <code>x<sub>1</sub></code>, regardless of how <code>c<sup>(0)</sup></code> is initialized. This phenomenon is explained by the <a target="_blank" href="https://en.wikipedia.org/wiki/Perron%E2%80%93Frobenius_theorem">Perron–Frobenius theorem</a>. Therefore, computing the eigenvector centrality of nodes in a graph is equivalent to finding the dominant eigenvector of the adjacency matrix `A`.

## Considerations

- To solve the influence leak problem in acyclic digraphs, the algorithm adopts the sum of adjacency matrix and unit matrix (i.e., `A = A + I`) rather than the adjacency matrix itself.
- A self-loop counts as one in-link and one out-link.

## Example Graph

<div align=center drawio-diagram='19738' drawio-name='draw_2ed941b377eb4cbc9d841d65e013c117.jpg'><img src="https://img.ultipa.cn/draw/draw_2ed941b377eb4cbc9d841d65e013c117.jpg?v='1733817784894'"/></div>

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

Algorithm name: `eigenvector_centrality`

| <div table-width="18">Name</div> | <div table-width="9">Type</div> | <div table-width="7">Spec</div> | <div table-width="8">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `max_loop_num` | Integer | ≥1 | `20` | Yes | The maximum number of iteration rounds. The algorithm terminates after all iterations are completed. |
| `tolerance` | Float | (0,1) | `0.001` | Yes | The algorithm terminates when the changes in all scores between iterations are less than the specified `tolerance`, indicating that the result is stable. |
| `edge_weight_property` | "`<@schema.?><property>`" | / | / | Yes | A numeric edge property used as weights in the adjacency matrix `A`; edges without this property are ignored. |
| `direction` | String | `in`, `out` | / | Yes | Constructs the adjacency matrix `A` with the in-links (`in`) or out-links (`out`) of each node. |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results. |
| `limit` | Integer | ≥-1 | `-1` | Yes | Limits the number of results returned; `-1` includes all results. |
| `order` | String | `asc`, `desc` | / | Yes | Sorts the results by `eigenvector_centrality`. |

## File Writeback

<div tab="code">
  
```gql  
CALL algo.eigenvector_centrality.write("my_hdc_graph", {
  return_id_uuid: "id",
  max_loop_num: 50,
  tolerance: 0.000001,
  direction: "in",
  order: "desc"
}, {
  file: {
    filename: "eigenvector_centrality"
  }
})
```

```uql
algo(eigenvector_centrality).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  max_loop_num: 50,
  tolerance: 0.000001,
  direction: "in",
  order: "desc"
}).write({
  file: {
    filename: "eigenvector_centrality"
  }
})
```

</div>

Result:

<p tit="File: eigenvector_centrality"></p>

```
_id,eigenvector_centrality
web1,0.573612
web2,0.573612
web3,0.460001
web5,0.255281
web4,0.255281
web6,1.35778e-05
web7,6.32265e-15
```

## DB Writeback

Writes the `eigenvector_centrality` values from the results to the specified node property. The property type is `double`.

<div tab="code">
  
```gql  
CALL algo.eigenvector_centrality.write("my_hdc_graph", {
  edge_weight_property: "@link.value"
}, {
  db: {
    property: "ec"
  }
})
```

```uql
algo(eigenvector_centrality).params({
  projection: "my_hdc_graph",
  edge_weight_property: "@link.value"
}).write({
  db:{ 
    property: 'ec'
  }
})
```

</div>
  
## Full Return

<div tab="code">
  
```gql  
CALL algo.eigenvector_centrality.run("my_hdc_graph", {
  return_id_uuid: "id",    
  max_loop_num: 300,
  tolerance: 0.000001,
  edge_weight_property: "value",
  direction: "in",
  order: "desc"
}) YIELD ec
RETURN ec
```

```uql
exec{
  algo(eigenvector_centrality).params({
    return_id_uuid: "id",    
    max_loop_num: 300,
    tolerance: 0.000001,
    edge_weight_property: "value",
    direction: "in",
    order: "desc"
  }) as ec
  return ec
} on my_hdc_graph
```

</div>

Result:

| \_id | eigenvector_centrality |
| -- | -- |
| web1 | 0.835474799052068 |
| web2 | 0.497522870627321 |
| web3 | 0.198903901628052 |
| web4 | 0.112638313459419 |
| web5 | 0.046932628743156 |
| web6 | 0.000173115768280974 |
| web7 | 3.67918716589409e-105 |

## Stream Return

<div tab="code">
  
```gql  
CALL algo.eigenvector_centrality.stream("my_hdc_graph", {
  return_id_uuid: "id",    
  max_loop_num: 300,
  tolerance: 0.000001,
  edge_weight_property: "value",
  direction: "in",
  order: "desc"
}) YIELD ec
RETURN ec
```

```uql
exec{
  algo(eigenvector_centrality).params({
    return_id_uuid: "id",    
    max_loop_num: 300,
    tolerance: 0.000001,
    edge_weight_property: "value",
    direction: "in",
    order: "desc"
  }).stream() as ec
  return ec
} on my_hdc_graph
```

</div>
  
Result:

| \_id | eigenvector_centrality |
| -- | -- |
| web1 | 0.835474799052068 |
| web2 | 0.497522870627321 |
| web3 | 0.198903901628052 |
| web4 | 0.112638313459419 |
| web5 | 0.046932628743156 |
| web6 | 0.000173115768280974 |
| web7 | 3.67918716589409e-105 |
