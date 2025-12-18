# Euclidean Distance

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

In mathematics, the Euclidean distance between two points in Euclidean space is the length of a line segment between the two points. In the graph, <i>N</i> numeric node properties (features) are specified to represent each node's position in an N-dimensional Euclidean space.

## Concepts

### Euclidean Distance

In 2-dimensional space, the formula to compute the Euclidean distance between points A(x<sub>1</sub>, y<sub>1</sub>) and B(x<sub>2</sub>, y<sub>2</sub>) is:

<center><img width=270 src="https://img.ultipa.cn/2022-08-09-15-15-45-d2.jpg"></center>

In 3-dimensional space, the formula to compute the Euclidean distance between points A(x<sub>1</sub>, y<sub>1</sub>, z<sub>1</sub>) and B(x<sub>2</sub>, y<sub>2</sub>, z<sub>2</sub>) is:

<center><img width=360 src="https://img.ultipa.cn/2022-08-09-15-15-47-d3.jpg"></center>

Generalized to N-dimensional space, the formula to compute the Euclidean distance is:

<center><img width=210 src="https://img.ultipa.cn/2022-08-09-15-15-49-dn.jpg"></center>

where <i>xi<sub>1</sub></i> represents the <i>i</i>-th dimensional coordinates of the first point, and <i>xi<sub>2</sub></i> represents the <i>i</i>-th dimensional coordinates of the second point.

Euclidean distance ranges from 0 to +∞; smaller values indicate greater similarity between the two nodes.

### Normalized Euclidean Distance

Normalized Euclidean distance scales the Euclidean distance into range from 0 to 1; the closer to 1, the more similar the two nodes.

Ultipa adopts the following formula to normalize the Euclidean distance:

<center><img width=270 src="https://img.ultipa.cn/2022-08-09-15-23-53-dnorm.jpg"></center>

## Considerations

- Theoretically, the calculation of Euclidean distance between two nodes  is independent of their connectivity. 

## Example Graph

<div align=center drawio-diagram='19795' drawio-name='draw_977329a8246f44c5b1792416e52b7f61.jpg'><img src="https://img.ultipa.cn/draw/draw_977329a8246f44c5b1792416e52b7f61.jpg?v='1733998496314'"/></div>

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
      <td><code>euclideanDistance</code>,<code>euclidean</code></td>
      <td><code>cosine</code></td>
      <td>No</td>
      <td colspan = "2">Specifies the type of similarity to compute; use <code>euclideanDistance</code> to compute Euclidean Distance, and use <code>euclidean</code> to compute Normalized Euclidean Distance.</td>
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

Computes similarities in **pairing** mode:

<div tab="code">
  
```gql
CALL algo.similarity.write("my_hdc_graph", {
  return_id_uuid: "id",
  ids: "product1",
  ids2: ["product2", "product3", "product4"],
  node_schema_property: ["price", "weight", "width", "height"],
  type: "euclideanDistance"
}, {
  file: {
    filename: "euclideanDistance"
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
  type: "euclideanDistance"
}).write({
  file: {
    filename: "euclideanDistance"
  }
})
```

</div>

Result:

<p tit="File: euclideanDistance"></p>

```
_id1,_id2,similarity
product1,product2,94.3822
product1,product3,143.962
product1,product4,165.179
```

## Full Return

<div tab="code">
  
```gql
CALL algo.similarity.run("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["product1","product2"], 
  ids2: ["product2","product3","product4"],
  node_schema_property: ["price", "weight", "width", "height"],
  type: "euclideanDistance"
}) YIELD distance
RETURN distance
```

```uql
exec{
  algo(similarity).params({
    return_id_uuid: "id",
    ids: ["product1","product2"], 
    ids2: ["product2","product3","product4"],
    node_schema_property: ["price", "weight", "width", "height"],
    type: "euclideanDistance"
  }) as distance
  return distance
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | similarity |
| -- | -- | -- |
| product1 | product2 | 94.382202 |
| product1 | product3 | 143.961807 |
| product1 | product4 | 165.178696 |
| product2 | product3 | 54.304695 |
| product2 | product4 | 74.135010 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.similarity.stream("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["product1", "product3"], 
  node_schema_property: ["price", "weight", "width", "height"],
  type: "euclideanDistance",
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
    type: "euclideanDistance",
    top_limit: 1        
  }).stream() as top
  return top
} on my_hdc_graph
```

</div>

Result: 

| \_id1 | \_id2 | similarity |
| -- | -- | -- |
| product1 | product4 | 165.178696 |
| product3 | product1 | 143.961807 |