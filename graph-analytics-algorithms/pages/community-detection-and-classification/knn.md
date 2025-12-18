# kNN (k-Nearest Neighbors)

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#eff1f5;color: #000000;"><b>✕ Stats</b></span></div>

## Overview

The k-Nearest Neighbors (kNN) algorithm is a classification technique that classifies the target node based on the classifications of its <i>k</i> nearest (most similar) nodes. kNN was proposed by T.M. Cover and P.E. Hart in 1967 and has since become one of the simplest and widely used classification algorithms:

- T.M. Cover, P.E. Hart, <a href="https://isl.stanford.edu/people/cover/papers/transIT/0021cove.pdf" target="blank">Nearest Neighbor Pattern Classification</a> (1967)

Although containing the word <i>neighbor</i> in its name, kNN does not explicitly consider the edges between nodes when calculating similarity. Instead, it focuses solely on node properties.

## Concepts

### Similarity Metric

Ultipa's kNN algorithm computes pair-wise <a href="/docs/graph-analytics-algorithms/cosine-similarity">cosine similarity</a> between the target node and all other nodes in the graph, then selects the <i>k</i> nodes with the highest similarity to the target node.

### Vote on Classification

One node property is selected as the class label. After finding the nearest <i>k</i> nodes for the target node, assign the majority label among the <i>k</i> nodes to the target node.

If multiple labels occur with the highest frequency, the label of the node with the highest similarity will be selected.

## Syntax

- Command: `algo(knn)`
- Parameters:

| <div table-width="16">Name</div> | <div table-width="18">Type</div> | <div table-width="16">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| node_id | `_uuid`	| / | / | No | UUID of the target node |
| node_schema_property | []`@<schema>?.<property>` | Numeric type, must LTE, must be of the same schema as the target node | / | No | Two or more node properties to compute the <a href="/docs/graph-analytics-algorithms/cosine-similarity">cosine similarity</a> |
| top_k | int | >0 | / | No | The number of the nearest nodes to select |
| target_schema_property | `@<schema>?.<property>` | Numeric/String type, must LTE, must be of the same schema as the target node | / | No | Node property to use as the class label |

## Examples

The example graph has 6 image nodes (edges are ignored), and each node has properties <i>d1</i>, <i>d2</i>, <i>d3</i>, <i>d4</i> and <i>type</i>:

<div align='center' drawio-diagram='6074' drawio-name="draw_952b35f286754b7196537fdea929e5bc.jpg"><img src="https://img.ultipa.cn/draw/draw_952b35f286754b7196537fdea929e5bc.jpg?v='1685523842708'"/></div>

### File Writeback

| <div table-width="11">Spec</div> | <div table-width="28">Content</div> | Description |
| --- | --- | ---  |
| filename | First row: `attribute_value`<br>Second row and later: `_id`,`similarity` | First row: The elected class label<br>Second row and later: ID of the nearest node and its cosine similarity with the target node |

```uql
algo(knn).params({
  node_id: 1,
  node_schema_property: ['d1', 'd2', 'd3', 'd4'],
  top_k: 4,
  target_schema_property: @image.type
}).write({
  file:{
    filename: "knn"
    }
})
```

Results: File <i>knn</i>

<p tit="File"></p>

```
Gold
top k : image4,0.538975
image3,0.705072
image6,0.841922
image2,0.85516
```

### Direct Return

| <div table-width='10'>Alias Ordinal</div> | <div table-width='12'>Type</div> | Description | <div table-width='20'>Columns</div> |
| --- | --- | --- | --- |
| 0 | KV | The elected class label and its number of occurrences among the <i>k</i> nearest neighbors | `attribute_value`, `count` |
| 1 | []perNode | The nearest node and its cosine similarity with the target node | `node`, `similarity` |

```uql
algo(knn).params({
  node_id: 1,
  node_schema_property: ['d1', 'd2', 'd3', 'd4'],
  top_k: 4,
  target_schema_property: @image.type
}) as a1, a2 
return a1, a2
```

Results: <i>a1</i> and <i>a2</i>

| attribute_value | count |
| -- | -- |
| Gold | 2 |

| node | similarity |
| -- | -- |
| 4 | 0.538974677919475 |
| 3 | 0.705071517140301 |
| 6 | 0.841922130134788 |
| 2 | 0.855159652306166 |

### Stream Return

| <div table-width='10'>Alias Ordinal</div> | <div table-width='12'>Type</div> | Description | <div table-width='20'>Columns</div> |
| --- | --- | --- | --- |
| 0 | KV | The elected class label and its number of occurrences among the <i>k</i> nearest neighbors | `attribute_value`, `count` |

```uql
algo(knn).params({
  node_id: 2,
  node_schema_property: ['@image.d1', '@image.d2', '@image.d3', '@image.d4'],
  top_k: 5,
  target_schema_property: @image.type
}).stream() as label
find().nodes({_uuid == 2}) as target
return case
  when target.type == label.attribute_value then 'True'
  else 'false'
end
```

Results: false

```uql
find().nodes({@image}) as images
call {
    with images._uuid as target
    algo(knn).params({
      node_id: target,
      node_schema_property: ['d1', 'd2', 'd3', 'd4'],
      top_k: 3,
      target_schema_property: 'type'
    }).stream() as label
    return label
}
return table(images._id, label.attribute_value)
```

Results: <i>table(images._id, label.attribute_value)</i>

| images.\_id | label.attribute_value |
| -- | -- |
| image1 | Silver |
| image2 | Silver |
| image3 | Gold |
| image4 | Silver |
| image5 | Gold |
| image6 | Gold |