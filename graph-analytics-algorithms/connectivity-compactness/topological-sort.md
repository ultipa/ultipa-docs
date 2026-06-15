# Topological Sort

<div><span class="flag" style="background:#014d4e;color:#fff;"><b>HDC</b></span></div>

## Overview

A topological sorting of a directed graph is an ordering of its nodes into a sequence, where the start node of every edge appears before its end node. Topological sorting is applicable only to <b>directed acyclic graphs (DAGs)</b> that do not contain any cycles. 

Topological sorting has various applications in computer science and related fields. In project management and job scheduling, it plays a crucial role in determining the optimal order of task execution based on dependencies. It is also  valuable in software development for resolving dependencies between modules, libraries, or components. By applying topological sorting, dependencies can be handled in the correct sequence, reducing the risk of conflicts and potential errors.

## Concepts

### Directed Acyclic Graph (DAG)

A <b>directed acyclic graph (DAG)</b> is a type of directed graph with no directed cycles. That is, it is not possible to start at any node <i>v</i> and follow a directed path to return back to <i>v</i> in a DAG.

As shown here, the first and second graphs are DAGs, while the third graph does contain a directed cycle (<i>B→C→D→B</i>) and therefore does not qualify as a DAG.

<div align=center drawio-diagram='6220' drawio-name="draw_3799bff640704bfe8c6e77082d686039.jpg"><img src="https://img.ultipa.cn/draw/draw_3799bff640704bfe8c6e77082d686039.jpg?v='1694508666156'"/></div>

A directed graph is a DAG if and only if it can be topologically sorted.

### Topological Sort

Every DAG has at least one topological sorting.

In the above examples, nodes in the first graph has 3 possible sortings:
- <i>A, E, B, D, C</i>
- <i>A, B, E, D, C</i>
- <i>A, B, D, E, C</i>

A DAG has a unique topological sorting if and only if it has a directed path containing all the nodes, in which case the sorting is the same as the order in which the nodes appear in the path.

In the following example, the nodes have only 1 possible topological sorting: <i>A, B, D, C, E, F</i>.

<div align=center drawio-diagram='6729' drawio-name="draw_cb16d5b2e3b34c83a1226e5cd28cb6b5.jpg"><img src="https://img.ultipa.cn/draw/draw_cb16d5b2e3b34c83a1226e5cd28cb6b5.jpg?v='1694510516466'"/></div>

## Considerations

Running the Topological Sort algorithm on a graph with cycles may result in some nodes being omitted. The omitted nodes are:

- Nodes that are part of a cycle (including self-cycles).
- Nodes that are reachable from the above nodes through outgoing edges.

In the given example, first is to omit nodes <i>C</i>, <i>D</i> and <i>G</i>, which form the cycle. Then, nodes <i>F</i>, <i>J</i> and <i>H</i> which are reachable from them are also omitted. As a result, the topological sorting result is <i>A, I, B, E</i>.

<div align=center drawio-diagram='6730' drawio-name="draw_58ebedc9c2204b159f51ebbc396c566c.jpg"><img src="https://img.ultipa.cn/draw/draw_58ebedc9c2204b159f51ebbc396c566c.jpg?v='1694511117733'"/></div>

If a graph is disconnected, or becomes disconnected after omitting nodes that form the cycle and nodes influenced by them, topological sorting is performed within each connected component. The sorting results are then consistently returned for all components. Isolated nodes are also included and are not overlooked.

## Example Graph

<div align=center drawio-diagram='19966' drawio-name='draw_59f5a7a6c51d4f7c94944cfe471649a7.jpg'><img src="https://img.ultipa.cn/draw/draw_59f5a7a6c51d4f7c94944cfe471649a7.jpg?v='1734935445562'"/></div>

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
       (A)-[:default]->(B),
       (A)-[:default]->(C),
       (A)-[:default]->(D),
       (A)-[:default]->(E),
       (E)-[:default]->(G),
       (F)-[:default]->(D),
       (F)-[:default]->(E),
       (H)-[:default]->(G);
```

```uql
insert().into(@default).nodes([{_id:"A"}, {_id:"B"}, {_id:"C"}, {_id:"D"}, {_id:"E"}, {_id:"F"}, {_id:"G"}, {_id:"H"}]);
insert().into(@default).edges([{_from:"A", _to:"B"}, {_from:"A", _to:"C"}, {_from:"A", _to:"D"}, {_from:"A", _to:"E"}, {_from:"E", _to:"G"}, {_from:"F", _to:"D"}, {_from:"F", _to:"E"}, {_from:"H", _to:"G"}]);
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

Algorithm name: `topological_sort`

| <div table-width="17">Name</div> | <div table-width="9">Type</div> | <div table-width="8">Spec</div> | <div table-width="7">Default</div> | <div table-width="9">Optional</div> | Description |
| -- | -- | -- |-- | -- | -- |
| `return_id_uuid` | String | `uuid`, `id`, `both` | `uuid` | Yes | Includes `_uuid`, `_id`, or both to represent nodes in the results; this option is only valid in <a href="#File-Writeback">File Writeback</a>. |

## File Writeback

<div tab="code">
  
```gql
CALL algo.topological_sort.write("my_hdc_graph", {
  return_id_uuid: "id"
}, {
  file: {
    filename: "sort"
  }
})
```

```uql
algo(topological_sort).params({
  projection: "my_hdc_graph",
  return_id_uuid: "id"
}).write({
  file: {
    filename: "sort"
  }
})
```

</div>

Result:

<p tit="File: sort"></p>

```
_id
F
H
A
B
C
D
E
G
```

## Full Return

<div tab="code">
  
```gql
CALL algo.topological_sort.run("my_hdc_graph", {}) YIELD r
RETURN r
```

```uql
exec{
  algo(topological_sort).params() as result
  return result
} on my_hdc_graph
```

</div>

<p tit="Result"></p>

```
[{"id":"F","uuid":"2882304861028745219","schema":"default","values":{}}]
[{"id":"H","uuid":"3386708019294240772","schema":"default","values":{}}]
[{"id":"A","uuid":"10016006670783610881","schema":"default","values":{}}]
[{"id":"B","uuid":"3530823207370096641","schema":"default","values":{}}]
[{"id":"C","uuid":"12033619303845593090","schema":"default","values":{}}]
[{"id":"D","uuid":"288231475663339522","schema":"default","values":{}}]
[{"id":"E","uuid":"10520409829049106435","schema":"default","values":{}}]
[{"id":"G","uuid":"13690943966717935617","schema":"default","values":{}}]
```

## Stream Return

<div tab="code">
  
```gql
CALL algo.topological_sort.stream("my_hdc_graph", {}) YIELD r
FOR node IN r 
RETURN node._id
```

```uql
exec{
  algo(topological_sort).params({}).stream() as r
  uncollect r as node
  return node._id
} on my_hdc_graph
```

</div>

Result: 

| node.\_id |
| -- |
| F |
| H |
| A |
| B |
| C |
| D |
| E |
| G |
