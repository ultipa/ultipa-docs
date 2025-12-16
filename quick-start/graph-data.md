# Graph Data

> This page explains what graph data looks like and how they are described in UQL. This must be mastered before leanring and using Ultipa Graph System.

## Graph Data

<div align=center drawio-diagram='5064' drawio-name="draw_ec834306826e42d79424e0111c47b201.jpg"><img src="https://img.ultipa.cn/draw/draw_ec834306826e42d79424e0111c47b201.jpg?v='1682058312972'"/></div>
<i><center>Chart1: Areith works as Waiter</center></i>

### Node

The two <u>circles</u> <i>Areith</i> and <i>Waiter</i> shown in Chart1 are nodes.
<br>
Nodes represent entities in the world.

### Edge

The black <u>arrow</u> <i>workAs</i> in Chart1 is an edge, it points from <i>Areith</i> to <i>Waiter</i>.
<br>
Edges represent relations between entities.

### Schema

The <i>Person</i>, <i>Job</i> and <i>workAs</i> in the code in Chart1 are schemas.
<br>
Schemas represent different types of node or edge.

### Property

The <i>name</i> and <i>title</i> in the code in Chart1 are properties.
<br>
Properties are the components of a schema to describe in detail the type of node or edge this schema represents.

### Path

<div align=center drawio-diagram='5071' drawio-name="draw_26ffcd310d324cea9097907e266e6d55.jpg"><img src="https://img.ultipa.cn/draw/draw_26ffcd310d324cea9097907e266e6d55.jpg?v=''"/></div>
<i><center>Chart2: A graph of 3 node schemas and 2 edge schemas</center></i>

The <u>sequence of connected and alternating nodes and edges</u> <i>Areith</i>, <i>workAs</i> and <i>Waiter</i> in Chart2 is a path. Another sequence <i>Waiter</i>, <i>workAs</i>, <i>Areith</i>, <i>studyAt</i>, <i>Oxford</i> is also a path.
<br>
A path starts from and ends with node, contains at least one edge. It represents multi-step correlations of entities, which makes it the most queried in graph computing.

## Describe Nodes

<div align=center drawio-diagram='5073' drawio-name="draw_e6964d85044448aeb73c82484503564f.jpg"><img src="https://img.ultipa.cn/draw/draw_e6964d85044448aeb73c82484503564f.jpg?v='1682061028416'"/></div>
<i><center>Chart3: Describing nodes</center></i>

There are a bunch of parameters that can describe node(s) in UQL. Take parameter `n()` as an example:
```js
n()									// any node in the graph
n({@Student})						// nodes of schema 'Student'
n({name == "Jason"})				// nodes whose property 'name' is 'Jason'
n({@Student.name == "Jason"})		// nodes of schema 'Student' whose property 'name' is 'Jason'
n(as a)								// any node in the graph, and give these nodes an alias 'a'
n({@Student} as a)					// ...
...
```

Features of describing nodes using `n()`:
- An `n()` without `{}` or with emplty curly braces `{}` sets no particular requirements on nodes
- Filtering schema requires symbol `@`
- Schema and property can be filtered in combinition or separately
- Assigning alias to the found nodes requires keyword `as` to be following `{}` (if has)

All parameters that can describe node(s) in UQL:
- `nodes()`: used in query, update and deletion of nodes
- `n()`: used in template query to denote one node in the path
- `nf()`: used in template query to denote consecutive nodes in the path
- `src()`: used in non-template path query to denote the initial node of the path
- `dest()`: used in non-template path query to denote the terminal node of the path
- `node_filter()`: used in non-template path query to denote all nodes other than `src()` and `dest()`

## Describe Edges

<div align=center drawio-diagram='5075' drawio-name="draw_9fb4725d7c5746eeae6afce6f4c06a9f.jpg"><img src="https://img.ultipa.cn/draw/draw_9fb4725d7c5746eeae6afce6f4c06a9f.jpg?v='1682062498964'"/></div>
<i><center>Chart4: Describing edges</center></i>

Take `e()` as an example to see how edges can be described:
```js
e()									// any edge in the graph
e({@workAs})						// edges of schema 'workAs'
e({since == 2012})					// edges whose property 'since' is '2012'
e({@workAs.since == 2012})			// edges of schema 'workAs' whose property 'since' is '2012'
e(as b)								// any edge in the graph, and give these edges an alias 'b'
e({@workAs} as b)					// ...
...
```

Similar with describing nodes using `n()`, describing edges using `e()` has below features:
- An `e()` without `{}` or with emplty curly braces `{}` sets no particular requirements on edges
- Filtering schema requires symbol `@`
- Schema and property can be filtered in combination or separately
- Assigning alias to the found edges requires keyword `as` to be following `{}` (if has), and an `e()` representing consecutive edges does not supports defining alias

All parameters that can describe edge(s) in UQL:
- `edges()`: used in query, update and deletion of edges
- `e()`: used in template query to denote one or consecutive edges in the path
- `le()`: used in template query, similar to `e()` but pointing to the left
- `re()`: used in template query, similar to `e()` but pointing to the right
- `edge_filter()`: used in non-template path query to denote all edges in the path

## Describe Paths (Template)

<div align=center drawio-diagram='5076' drawio-name="draw_dbd003a004c84d8b8029db969158ee07.jpg"><img src="https://img.ultipa.cn/draw/draw_dbd003a004c84d8b8029db969158ee07.jpg?v='1682063327734'"/></div>
<i><center>Chart5: Describing paths</center></i>

Paths described using `n()` and `e()` are template:
```js
// any 1-hop path in the graph
n().e().n()

// any 2-hop path in the graph
n().e().n().e().n()
n().e()[2].n()

// 1-hop paths 'Person-workAs-waiter'
// give these Person an alias 'individual', give these paths an alias 'career'
n({@Person} as individual).e({@workAs}).n({@Job.title == "Waiter"}) as career

// 2-hop paths 'Areith-workAs-Job-workAs-Person'
// give these Job an alias 'job', give these Person at the end an alias 'other'
n({@Person.name == "Areith"}).e({@workAs}).n({@Job} as job).e({@workAs}).n({@Person} as other)

...
```

Features of path template:
- Path templates are as intuitive as how they are visualized in a graph
- Alias can be assigned for a single node, edge, as well as the whole path

<div align=center drawio-diagram='5070' drawio-name="draw_a6bfa82ec2de4326afc90d9e40c7a583.jpg"><img src="https://img.ultipa.cn/draw/draw_a6bfa82ec2de4326afc90d9e40c7a583.jpg?v=''"/></div>
<i><center>Chart6: Same graph data described as different templates</center></i>

> Are the two paths described in Chart6 the same? As paths in Ultipa are composed and parsed from left to right, the two templates are not the same, but they do describe the same graph data.
