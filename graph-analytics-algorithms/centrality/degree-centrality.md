# Degree Centrality

<div><span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ File Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Property Writeback</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Direct Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stream Return</b></span> <span class="flag" style="background-color:#014d4e;color: #ffffff;"><b>✓ Stats</b></span></div>

## Overview

The Degree Centrality algorithm is used to find important nodes in the network, it measures the number of incoming and/or outgoing edges incident to the node, or the sum of weights of those edges. Degree is the simplest and most efficient graph algorithm since it only considers the 1-hop neighborhood of nodes. Degree plays a vital role in scientific computing, feature extraction, supernode recognition and other fields.

## Concepts

### In-Degree and Out-Degree

The number of incoming edges a node has is called its <b>in-degree</b>; accordingly, the number of outgoing edges is called <b>out-degree</b>. If ignores edge direction, it is <b>degree</b>.

<div align=center drawio-diagram='1443' drawio-name="draw_c79beb875cd64cdfa0e3cb4647110abb.jpg"><img src="https://img.ultipa.cn/draw/draw_c79beb875cd64cdfa0e3cb4647110abb.jpg?v='1642759847524'"/></div>

In this graph, the red node has in-degree of 4 and out-degree of 3, and its degree is 7. Directed self-loop is regarded as an incoming edge and an outgoing edge.

### Weighted Degree

In many applications, each edge of a graph has an associated numeric value, called <b>weight</b>. In weighted graph, <b>weighted degree</b> of a node is the sum of weights of all its neighbor edges. Unweighted degree is equivalent to when all edge weights are 1.

<div align=center drawio-diagram='1444' drawio-name='draw_bd6ced106a164be3865f9a21d578ede7.jpg'><img src="https://img.ultipa.cn/draw/draw_bd6ced106a164be3865f9a21d578ede7.jpg?v='1642759974332'"/></div>

In this weighted graph, the red node has weighted in-degree of `0.5 + 0.3 + 2 + 1 = 3.8` and weighted out-degree of `1 + 0.2 + 2 = 3.2`, and its weighted degree is `3.2 + 3.8 = 7`.

## Considerations

- Degree of isolated node only depends on its self-loop. If it has no self-loop, degree is 0.
- Every self-loop is counted as 2 edges attaching to its node. Directed self-loop is viewed as an incoming edge and an outgoing edge.

## Syntax

- Command: `algo(degree)`
- Parameters:

| Name | Type | <div table-width="7">Spec</div> | <div table-width="7">Default</div> | <div table-width="8">Optional</div> | <div table-width="30">Description</div> |
| -- | -- | -- |-- | -- | -- |
| ids / uuids | []`_id` / []`_uuid` | / | / | Yes | ID/UUID of the nodes to calculate, calculate for all nodes if not set |
| edge_schema_property | []`@<schema>?.<property>` | Numeric type, must LTE | / | Yes | Edge property(-ies) to use as edge weight(s), where the values of multiple properties are summed up |
| direction | string | `in`, `out` | / | Yes | `in` for in-degree, `out` for out-degree |
| limit | int | ≥-1 | `-1` | Yes | Number of results to return, `-1` to return all results |
| order | string | `asc`, `desc` | / | Yes | Sort nodes by the size of degree |

## Examples

The example is a social network, edge property <i>@follow.score</i> can be used as weights:

<div align='center' drawio-diagram='4936' drawio-name='draw_8b86fa9e21e145d181c9d11dbcb59081.jpg'><img src="https://img.ultipa.cn/draw/draw_8b86fa9e21e145d181c9d11dbcb59081.jpg?v='1680579330133'"/></div>

### File Writeback

| Spec | Content |
| --- | --- |
| filename | `_id`,`degree` |

```uql
algo(degree).params().write({
  file:{ 
    filename: 'degree_all'
  }
})
```

Statistics: total_degree = 20, average_degree = 2.25<br>
Results: File <i>degree_all</i>

<p tit="File"></p>

```
Tim,0
Bill,1
Bob,2
Sam,2
Joe,3
Anna,5
Cathy,4
Mike,3
```

### Property Writeback

| Spec | Content | Write to | Data Type |
| --- | --- | --- | --- |
| property | `degree` | Node property | `double` |

```uql
algo(degree).params({
  edge_schema_property: '@follow.score'
}).write({
  db:{ 
    property: 'degree'
  }
})
```

Statistics: total_degree = 40.4, average_degree = 5.05<br>
Results: Degree for each node is written to a new property named <i>degree</i>, statistics is returned at the same time

### Direct Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="12">Type</div> | Description | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its degree | `_uuid`, `degree` |
| 1 | KV | Total and average degree of all nodes | `total_degree`, `average_degree` |

```uql
algo(degree).params({ 
  edge_schema_property: '@follow.score',
  order: 'desc' 
}) as degree, stats
return degree, stats
```

Results: <i>degree</i> and <i>stats</i>

| \_uuid | degree |
| ------ | ------ |
| 3 | 11.1 |
| 2 | 6.5 |
| 4 | 6.1 |
| 6 | 5.2 |
| 1 | 4.9 |
| 5 | 4.3 |
| 7 | 2.3 |
| 8 | 0 |

| total_degree | average_degree |
| ------------ | -------------- |
| 40.4 | 5.05 |

### Stream Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="12">Type</div> | Description | Columns |
| ------------- | ---- | ----------- | ----------- |
| 0 | []perNode | Node and its degree | `_uuid`, `degree` |

Example: Find 1-hop neighbors of the node with the highest degree, return all information of those neighbors
```uql
algo(degree).params({
  order: 'desc',
  limit: 1 
}).stream() as results
khop().src({_uuid == results._uuid}).depth(1) as neighbors
return neighbors{*}
```

Results: <i>neighbors</i>

| \_id | \_uuid |
| -- | -- |
| Bill | 7 |
| Sam | 5 |
| Joe | 4 |
| Cathy | 2 |
| Mike | 1 |

### Stats Return

| <div table-width="15">Alias Ordinal</div> | <div table-width="6">Type</div> | Description | Columns |
| ----- | ---- | ----------- | ----------- |
| 0 | KV | Total and average degree of all nodes | `total_degree`, `average_degree` |

```uql
algo(degree).params({
  direction: 'out'
}).stats() as stats
return stats
```

Results: <i>stats</i>

| total_degree | average_degree |
| ------------ | -------------- |
| 10 | 1.25 |