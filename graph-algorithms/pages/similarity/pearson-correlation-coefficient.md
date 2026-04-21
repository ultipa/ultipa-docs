# Pearson Correlation Coefficient

## Overview

The Pearson correlation coefficient is the most common way of measuring the strength and direction of the linear relationship between two quantitative variables. In the graph, nodes are quantified by <i>N</i> numeric properties (features) of them.

For two variables <i>X= (x<sub>1</sub>, x<sub>2</sub>, ..., x<sub>n</sub>)</i> and <i>Y = (y<sub>1</sub>, y<sub>2</sub>, ..., y<sub>n</sub>)</i> , Pearson correlation coefficient (<i>r</i>) is defined as the ratio of the covariance of them to the product of their standard deviations:

<center><img width=400 src="https://img.ultipa.cn/img/2023-05-30-10-05-44-pearson.jpg"></center>

The Pearson correlation coefficient ranges from -1 to 1:

| <div table-width="23">Pearson correlation coefficient</div> | <div table-width="20">Correlation type</div> | Interpretation |
| -- | -- | -- |
| 0 < <i>r</i> ≤ 1 | Positive correlation | As one variable becomes larger, the other variable becomes larger |
| <i>r</i> = 0 | No linear correlation | (May exist some other types of correlation) |
| -1 ≤ <i>r</i> < 0 | Negative correlation | As one variable becomes larger, the other variable becomes smaller |

## Considerations

- Theoretically, the calculation of Pearson correlation coefficient between two nodes is independent of their connectivity.

## Example Graph

<div align=center drawio-diagram='19793' drawio-name='draw_98317bd8658e4657868a30973dd5ab0a.jpg'><img src="https://img.ultipa.cn/draw/draw_98317bd8658e4657868a30973dd5ab0a.jpg?v='1733994356512'"/></div>

Run the following statements on an empty graph to define its structure and insert data:


```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  product ({price int32, weight int32, width int32, height int32})
};
INSERT (:product {_id:"product1", price:50, weight:160, width:20, height:152}),
       (:product {_id:"product2", price:42, weight:90, width:30, height:90}),
       (:product {_id:"product3", price:24, weight:50, width:55, height:70}),
       (:product {_id:"product4", price:38, weight:20, width:32, height:66});
```



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
      <td><code>pearson</code></td>
      <td><code>cosine</code></td>
      <td>No</td>
      <td colspan = "2">Specifies the type of similarity to compute; for Pearson Correlation Coefficient, keep it as <code>pearson</code>.</td>
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

  
```gql
CALL algo.similarity.write("my_hdc_graph", {
  return_id_uuid: "id",
  ids: "product1",
  ids2: ["product2", "product3", "product4"],
  node_schema_property: ["price", "weight", "width", "height"],
  type: "pearson"
}, {
  file: {
    filename: "pearson"
  }
})
```



Result:

<p tit="File: pearson"></p>

```
_id1,_id2,similarity
product1,product2,0.998785
product1,product3,0.474384
product1,product4,0.210494
```

## Full Return

  
```gql
CALL algo.similarity.run("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["product1","product2"], 
  ids2: ["product2","product3","product4"],
  node_schema_property: ["price", "weight", "width", "height"],
  type: "pearson"
}) YIELD p
RETURN p
```



Result:

| \_id1 | \_id2 | similarity |
| -- | -- | -- |
| product1 | product2 | 0.998785 |
| product1 | product3 | 0.474384 |
| product1 | product4 | 0.210494 |
| product2 | product3 | 0.507838 |
| product2 | product4 | 0.253573 |

## Stream Return

  
```gql
CALL algo.similarity.stream("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["product1", "product3"], 
  node_schema_property: ["price", "weight", "width", "height"],
  type: "pearson",
  top_limit: 1    
}) YIELD top
RETURN top
```



Result: 

| \_id1 | \_id2 | similarity |
| -- | -- | -- |
| product1 | product2 | 0.998785 |
| product3 | product2 | 0.507838 |
