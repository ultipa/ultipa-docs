# Cosine Similarity

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

In cosine similarity, data objects in a dataset are treated as vectors, and it uses the cosine value of the angle between two vectors to indicate the similarity between them. In the graph, <i>N</i> numeric node properties (features) are specified to form N-dimensional vectors; two nodes are considered similar if their vectors are similar.

Cosine similarity ranges from -1 to 1, where 1 indicates that the two vectors point in the same direction, and -1 indicates they point in opposite directions.
 
<div align=center drawio-diagram='4963' drawio-name="draw_3f64dd50cd0a4e6695fae0cacda3892c.jpg"><img src="https://img.ultipa.cn/draw/draw_3f64dd50cd0a4e6695fae0cacda3892c.jpg?v='1681111944016'"/></div>

In 2-dimensional space, the cosine similarity between vectors A(a<sub>1</sub>, a<sub>2</sub>) and B(b<sub>1</sub>, b<sub>2</sub>) is computed as:

<center><img width=350 src="https://img.ultipa.cn/2022-08-09-14-00-10-cos2.jpg"></center>

In 3-dimensional space, the cosine similarity between vectors A(a<sub>1</sub>, a<sub>2</sub>, a<sub>3</sub>) and B(b<sub>1</sub>, b<sub>2</sub>, b<sub>3</sub>) is computed as:

<center><img width=480 src="https://img.ultipa.cn/2022-08-09-14-00-13-cos3.jpg"></center>

The following diagram shows the relationship between vectors A and B in 2D and 3D spaces, as well as the angle θ between them:

<div align=center drawio-diagram='4946' drawio-name="draw_16853a553f024f75b352985ae55be8c9.jpg"><img src="https://img.ultipa.cn/draw/draw_16853a553f024f75b352985ae55be8c9.jpg?v='1680746413239'"/></div>

Generalized to N-dimensional space, cosine similarity is computed as:

<center><img width=420 src="https://img.ultipa.cn/2022-03-16-15-04-04-cosineS.png"></center>

## Considerations

- Theoretically, the calculation of cosine similarity between two nodes is independent of their connectivity in the graph.
- The value of cosine similarity is independent of the length of the vectors, but only the direction of the vectors.

## Example Graph

<div align=center drawio-diagram='19792' drawio-name='draw_bc765c50cae2418590031a17fdcb6fe4.jpg'><img src="https://img.ultipa.cn/draw/draw_bc765c50cae2418590031a17fdcb6fe4.jpg?v='1733988639804'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  product ({price int32, weight int32, width int32, height int32})
};
INSERT (:product {_id:"product1", price:50, weight:160, width:20, height:152}),
       (:product {_id:"product2", price:42, weight:90, width:30, height:90}),
       (:product {_id:"product3", price:24, weight:50, width:55, height:70}),
       (:product {_id:"product4", price:38, weight:20, width:32, height:66});
```

```uql
create().node_schema("product");
create().node_property(@product, "price", int32).node_property(@product, "weight", int32).node_property(@product, "width", int32).node_property(@product, "height", int32);
insert().into(@product).nodes([{_id:"product1", price:50, weight:160, width:20, height:152}, {_id:"product2", price:42, weight:90, width:30, height:90}, {_id:"product3", price:24, weight:50, width:55, height:70}, {_id:"product4", price:38, weight:20, width:32, height:66}]);
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

Algorithm name: `similarity`

<table>
  <colgroup>
    <col style="width:12%">
    <col style="width:10%">
    <col style="width:10%">
    <col style="width:8%">
    <col style="width:8%">
    <col style="width:25%">
  </colgroup>
  <thead>
    <tr>
      <th>Name</th>
      <th>Type</th>
      <th>Spec</th>
      <th>Default</th>
      <th>Optional</th>
      <th style = "text-align: center" colspan=2;>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>ids</code>/<code>uuids</code></td>
      <td><code>_id</code>/<code>_uuid</code></td>
      <td><center>/</center></td>
      <td><center>/</center></td>
      <td>Yes</td>
      <td>Specifies the first group of nodes by their <code>_id</code> or <code>_uuid</code>. If unset, all nodes in the graph are used as the first group of nodes.</td>
      <td rowspan = "2">
      The algorithm supports two calculation modes: <br><br><ul><li><b>Pairing mode:</b> When both <code>ids</code>/<code>uuids</code> and <code>ids2</code>/<code>uuids2</code> are set, each node in <code>ids</code>/<code>uuids</code> is paired with each node in <code>ids2</code>/<code>uuids2</code> (excluding self-pairs), and their pairwise similarities are computed.</li><li><b>Selection mode:</b> When only <code>ids</code>/<code>uuids</code> is set, the algorithm computes similarities between each specified node and all other nodes in the graph. Results include all (or a limited number of) nodes with a similarity > 0, sorted in descending order.</li></ul>
      </td>
    </tr>
    <tr>
      <td><code>ids2</code>/<code>uuids2</code></td>
      <td><code>_id</code>/<code>_uuid</code></td>
      <td><center>/</center></td>
      <td><center>/</center></td>
      <td>Yes</td>
      <td>Specifies the second group of nodes for pairwise similarity by their <code>_id</code> or <code>_uuid</code>. If only <code>ids2</code>/<code>uuids2</code> is set (and <code>ids</code>/<code>uuids</code> is not), the algorithm returns no result.</td>
    </tr>
    <tr>
      <td><code>type</code></td>
      <td>String</td>
      <td><code>cosine</code></td>
      <td><code>cosine</code></td>
      <td>No</td>
      <td colspan = "2">Specifies the type of similarity to compute; for Cosine Similarity, keep it as <code>cosine</code>.</td>
    </tr>
    <tr>
      <td><code>node_schema_property</code></td>
      <td>[]"<code>&lt;@schema.?&gt;&lt;property&gt;</code>"</td>
      <td><center>/</center></td>
      <td><center>/</center></td>
      <td>No</td>
      <td colspan = "2">Specifies numeric node properties to form a vector for each node; all specified properties must belong to the same label (schema).</td>
    </tr>
    <tr>
      <td><code>return_id_uuid</code></td>
      <td>String</td>
      <td><code>uuid</code>,<code>id</code>,<code>both</code></td>
      <td><code>uuid</code></td>
      <td>Yes</td>
      <td colspan = "2">Includes <code>_uuid</code>, <code>_id</code>, or both to represent nodes in the results.</td>
    </tr>
    <tr>
      <td><code>order</code></td>
      <td>String</td>
      <td><code>asc</code>,<code>desc</code></td>
      <td><center>/</center></td>
      <td>Yes</td>
      <td colspan = "2">Sorts the results by <code>similarity</code>.</td>
    </tr>
    <tr>
      <td><code>limit</code></td>
      <td>Integer</td>
      <td>≥-1</td>
      <td><code>-1</code></td>
      <td>Yes</td>
      <td colspan = "2">Limits the number of results returned. Set to <code>-1</code> to include all results.</td>
    </tr>
    <tr>
      <td><code>top_limit</code></td>
      <td>Integer</td>
      <td>≥-1</td>
      <td><code>-1</code></td>
      <td>Yes</td>
      <td colspan = "2">Limits the number of results returned for each node specified with <code>ids</code>/<code>uuids</code> in selection mode. Set to <code>-1</code> to include all results with a similarity greater than 0. This parameter is invalid in pairing mode.</td>
    </tr>
  </tbody>      
</table>

## File Writeback

<div tab="code">
  
```gql
CALL algo.similarity.write("my_hdc_graph", {
  return_id_uuid: "id",
  ids: "product1",
  ids2: ["product2", "product3", "product4"],
  node_schema_property: ["price", "weight", "width", "height"],
  type: "cosine"
}, {
  file: {
    filename: "cosine"
  }
})
```

```uql
algo(similarity).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  ids: "product1",
  ids2: ["product2", "product3", "product4"],
  node_schema_property: ["price", "weight", "width", "height"],
  type: "cosine"
}).write({
  file: {
    filename: "cosine"
  }
})
```

</div>

Result:

<p tit="File: cosine"></p>

```
_id1,_id2,similarity
product1,product2,0.986529
product1,product3,0.878858
product1,product4,0.816876
```

## Full Return

<div tab="code">
  
```gql
CALL algo.similarity.run("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["product1","product2"], 
  ids2: ["product2","product3","product4"],
  node_schema_property: ["price", "weight", "width", "height"],
  type: "cosine"
}) YIELD cs
RETURN cs
```

```uql
exec{
  algo(similarity).params({
    return_id_uuid: "id",
    ids: ["product1","product2"], 
    ids2: ["product2","product3","product4"],
    node_schema_property: ["price", "weight", "width", "height"],
    type: "cosine"
  }) as cs
  return cs
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | similarity |
| -- | -- | -- |
| product1 | product2 | 0.986529 |
| product1 | product3 | 0.878858 |
| product1 | product4 | 0.816876 |
| product2 | product3 | 0.934217 |
| product2 | product4 | 0.881988 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.similarity.stream("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["product1", "product3"], 
  node_schema_property: ["price", "weight", "width", "height"],
  type: "cosine",
  top_limit: 1    
}) YIELD top
RETURN top
```

```uql
exec{
  algo(similarity).params({
    return_id_uuid: "id",
    ids: ["product1", "product3"], 
    node_schema_property: ["price", "weight", "width", "height"],
    type: "cosine",
    top_limit: 1        
  }).stream() as cs
  return cs
} on my_hdc_graph
```

</div>

Result: 

| \_id1 | \_id2 | similarity |
| -- | -- | -- |
| product1 | product2 | 0.986529 |
| product3 | product2 | 0.934217 |
