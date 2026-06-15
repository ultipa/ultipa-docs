# Jaccard Similarity

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

Jaccard similarity, or Jaccard index, was proposed by Paul Jaccard in 1901. It’s a metric of similarity for two sets of data. In the graph, collecting the neighbors of a node into a set, two nodes are considered similar if their neighborhood sets are similar.

Jaccard similarity ranges from 0 to 1, where 1 indicates that two sets are identical, and 0 indicates that they share no common elements. 

## Concepts

### Jaccard Similarity

Given two sets <i>A</i> and <i>B</i>, the Jaccard similarity between them is computed as:

<center><img width=300 src="https://img.ultipa.cn/2022-01-21-10-44-09-jaccardS-new.png"></center>

In the following example, set A = {b,c,e,f,g}, set B = {a,d,b,g}, their intersection A⋂B = {b,g}, their union A⋃B = {a,b,c,d,e,f,g}, hence the Jaccard similarity between A and B is `2 / 7 = 0.285714`.

<div align=center drawio-diagram='4943' drawio-name='draw_643f71d054c34c9d83cd682b0bd74402.jpg'><img src="https://img.ultipa.cn/draw/draw_643f71d054c34c9d83cd682b0bd74402.jpg?v='1680592080160'"/></div>

When applying Jaccard Similarity to compare two nodes in a graph, we use the 1-hop neighborhood set to represent each target node. The 1-hop neighborhood set:

- contains no repeated nodes;
- excludes the two target nodes.

<div align=center drawio-diagram='14722' drawio-name="draw_86e6115da2be4ebea513a350b03fee51.jpg"><img src="https://img.ultipa.cn/draw/draw_86e6115da2be4ebea513a350b03fee51.jpg?v='1705742284029'"/></div>

In this graph, the 1-hop neighborhood set of nodes *u* and *v* is:

- N<sub>u</sub> = {a,b,c,d,e}
- N<sub>v</sub> = {d,e,f}

Therefore, the Jaccard similarity between nodes *u* and *v* is `2 / 6 = 0.333333`.

> In practice, you may need to convert some node properties into node schemas in order to calculate the similarity index that is based on common neighbors, just as the Jaccard Similarity. For instance, when considering the similarity between two applications, information like phone number, email, device IP, etc. of the application might have been stored as properties of <i>@application</i> node schema; they need to be designed as nodes and incorporated into the graph in order to be used for comparison.

### Weighted Jaccard Similarity

The Weighted Jaccard Similarity is an extension of the classic Jaccard Similarity that takes into account the weights associated with elements in the sets being compared.

The formula for Weighted Jaccard Similarity is given by:

<center><img width=320 src="https://img.ultipa.cn/img/2024-01-20-17-46-10-weighted-jaccard.jpg"></center>

<div align=center drawio-diagram='14724' drawio-name="draw_a59802aecd0449ddab9758f8e705ac49.jpg"><img src="https://img.ultipa.cn/draw/draw_a59802aecd0449ddab9758f8e705ac49.jpg?v='1705740462299'"/></div>

In this weighted graph, the union of the 1-hop neighborhood sets N<sub>u</sub> and N<sub>v</sub> is {a,b,c,d,e,f}. For each element in the union set, assign a value equal to the sum of the edge weights between the target node and the corresponding node; assign 0 if no edge exists between them:

| | a | b | c | d | e | f |
| -- | -- | -- | -- | -- | -- | -- |
| N'<sub>u</sub> | 1 | 1 | 1 | 1 | 0.5 | 0 |
| N'<sub>v</sub> | 0 | 0 | 0 | 0.5 | 1.5 + 0.1 =1.6 | 1 |

Therefore, the Weighted Jaccard Similarity between nodes *u* and *v* is `(0+0+0+0.5+0.5+0) / (1+1+1+1+1.6+1) = 0.151515`.

> Please ensure that the sum of the edge weights between the target node and the neighboring node is greater than or equal to 0.

## Considerations

- The Jaccard Similarity algorithm ignores the direction of edges but calculates them as undirected edges.
- The Jaccard Similarity algorithm ignores any self-loop.

## Example Graph

<div align=center drawio-diagram='19789' drawio-name="draw_88628c848eaf439d9e0ef22c64b336f9.jpg"><img src="https://img.ultipa.cn/draw/draw_88628c848eaf439d9e0ef22c64b336f9.jpg?v='1734417643677'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

<div tab="code">

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  user (),
  sport()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  like ()-[{weight int32}]->()
};
INSERT (userA:user {_id: "userA"}),
       (userB:user {_id: "userB"}),
       (userC:user {_id: "userC"}),
       (userD:user {_id: "userD"}),
       (running:sport {_id: "running"}),
       (tennis:sport {_id: "tennis"}),
       (baseball:sport {_id: "baseball"}),
       (swimming:sport {_id: "swimming"}),
       (badminton:sport {_id: "badminton"}),
       (iceball:sport {_id: "iceball"}),
       (userA)-[:like {weight: 2}]->(tennis),
       (userA)-[:like {weight: 1}]->(baseball),
       (userA)-[:like {weight: 3}]->(swimming),
       (userA)-[:like {weight: 2}]->(badminton),
       (userB)-[:like {weight: 1}]->(running),
       (userB)-[:like {weight: 3}]->(swimming),
       (userC)-[:like {weight: 2}]->(swimming),
       (userD)-[:like {weight: 1}]->(running),
       (userD)-[:like {weight: 2}]->(badminton),
       (userD)-[:like {weight: 2}]->(iceball);
```

```uql
create().node_schema("user").node_schema("sport").edge_schema("like");
create().edge_property(@like, "weight", int32);
insert().into(@user).nodes([{_id:"userA"}, {_id:"userB"}, {_id:"userC"}, {_id:"userD"}]);
insert().into(@sport).nodes([{_id:"running"}, {_id:"tennis"}, {_id:"baseball"}, {_id:"swimming"}, {_id:"badminton"}, {_id:"iceball"}]);
insert().into(@like).edges([{_from:"userA", _to:"tennis", weight:2}, {_from:"userA", _to:"baseball", weight:1}, {_from:"userA", _to:"swimming", weight:3}, {_from:"userA", _to:"badminton", weight:2}, {_from:"userB", _to:"running", weight:1}, {_from:"userB", _to:"swimming", weight:3}, {_from:"userC", _to:"swimming", weight:2}, {_from:"userD", _to:"running", weight:1}, {_from:"userD", _to:"badminton", weight:2}, {_from:"userD", _to:"iceball", weight:2}]);
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
      <td><code>jaccard</code></td>
      <td><code>cosine</code></td>
      <td>No</td>
      <td colspan = "2">Specifies the type of similarity to compute; for Jaccard Similarity, keep it as <code>jaccard</code>.</td>
    </tr>
    <tr>
      <td><code>edge_weight_property</code></td>
      <td>[]"<code>&lt;@schema.?&gt;&lt;property&gt;</code>"</td>
      <td><center>/</center></td>
      <td><center>/</center></td>
      <td>Yes</td>
      <td colspan = "2">Specifies numeric edge properties to be used as edge weights by summing their values; edges without these properties are ignored.</td>
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
  ids: "userC",
  ids2: ["userA", "userB", "userD"],
  type: "jaccard"
}, {
  file: {
    filename: "jaccard"
  }
})
```

```uql
algo(similarity).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id",
  ids: "userC",
  ids2: ["userA", "userB", "userD"],
  type: "jaccard"  
}).write({
  file: {
    filename: "jaccard"
  }
})
```

</div>

Result:

<p tit="File: jaccard"></p>

```
_id1,_id2,similarity
userC,userA,0.25
userC,userB,0.5
userC,userD,0
```

## Full Return

<div tab="code">
  
```gql
CALL algo.similarity.run("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["userA","userB"], 
  ids2: ["userB","userC","userD"],
  type: "jaccard"
}) YIELD jacc
RETURN jacc
```

```uql
exec{
  algo(similarity).params({
    return_id_uuid: "id",
    ids: ["userA","userB"], 
    ids2: ["userB","userC","userD"],
    type: "jaccard"
  }) as jacc
  return jacc
} on my_hdc_graph
```

</div>

Result:

| \_id1 | \_id2 | similarity |
| -- | -- | -- |
| userA | userB | 0.2 |
| userA | userC | 0.25 |
| userA | userD | 0.166667 |
| userB | userC | 0.5 |
| userB | userD | 0.25 |

## Stream Return

<div tab="code">
  
```gql
CALL algo.similarity.stream("my_hdc_graph", {
  return_id_uuid: "id",
  ids: ["userA"], 
  type: "jaccard",
  edge_weight_property: "weight",
  top_limit: 2    
}) YIELD jacc
RETURN jacc
```

```uql
exec{
  algo(similarity).params({
    return_id_uuid: "id",
    ids: ["userA"], 
    type: "jaccard",
    edge_weight_property: "weight",
    top_limit: 2  
  }).stream() as jacc
  return jacc
} on my_hdc_graph
```

</div>

Result: 

| \_id1 | \_id2 | similarity |
| -- | -- | -- |
| userA | userB | 0.333333 |
| userA | userC | 0.25 |
