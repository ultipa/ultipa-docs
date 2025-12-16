# Terminologies

### GQL

GQL stands for Graph Query Language. It is a database language designed for modeling structured data as a graph, and for storing, querying, and modifying that data in a graph database. GQL addresses the Property Graph model. 

GQL is the only standard database language since the introduction of SQL in 1987. It was released in April 2024 by the ISO/IEC.  

### UQL

Developed by Ultipa in 2019, UQL is a powerful database language specifically designed for Ultipa Graph.

### Graph

Graph is a collection of nodes connected by edges.

### Property Graph

Property graph extends the basic graph model by allowing properties to be associated with both nodes and edges. Ultipa Graph is property graph.

### Directed Graph

In directed graph, every edge is directed. Ultipa Graph is directed graph.

### Multigraph

Multigraph allows more than one edge connecting two nodes. Ultipa Graph is multigraph.

### Node

Node is the fundamental unit of which a graph is formed. Nodes (or vertices) are used to represent entities. Examples include people in a social network, cities in a map, or web pages on the internet.

### Edge

Edge is the fundamental unit of which a graph is formed. Edges are used to represent relationships or connections between entities. Examples include friendships between people, roads connecting cities, or hyperlinks between web pages.

Each edge has two (possibly identical) endpoints, which are nodes contained in the same graph.

### Directed Edge

Directed edge has an orientation, going from a source node to a destination node, which is often depicted by using an arrow. All edges in Ultipa Graph are directed.

### Undirected Edge

Undirected edges do not have a specific direction, implying a bidirectional or mutual relationship between the nodes.

### Edge Weight

An edge weight is a numerical value assigned to an edge in a graph. Edge weights are used to represent the cost, distance, capacity, or any other quantitative measure associated with the connection between two nodes in the graph.

### Metadata 

The general term for nodes and edges. They are also called graph elements.

### Path

A path starts and ends with a node, alternating between nodes and edges.  Edges in a path can have different directions. A path may contain only one node.

In Ultipa Graph, nodes in path can repeat while edges cannot.

### Intermediate Nodes

Nodes in a path other than the first and last nodes are considered as intermediate nodes.

### Circle

When a path has repeated node(s), it is viewed as having circle(s). Here are some examples of paths with circles:

<div align=center drawio-diagram='15698' drawio-name='draw_ca415f61db6a4e6088581602eb37928f.jpg'><img src="https://img.ultipa.cn/draw/draw_ca415f61db6a4e6088581602eb37928f.jpg?v='1719483542796'"/></div>

If no node appears more than once in a path, then the path is called acyclic.

### Shortest Path

The shortest path between two nodes that has the fewest edges (in an unweighted graph) or the smallest sum of weights (in a weighted graph).

### Self-loop

A self-loop in a graph is an edge that connects a node to itself.

### Subgraph

A subgraph is a portion of a graph that consists of a subset of the nodes and edges. 

### GraphSet

A graphset includes not only the graph model (definition of schemas and properties) and graph data (nodes and edges), but also the property indexes, tasks and processes and so on created on the graph.

### Instance

An Ultipa Graph instance is a running application on Ultipa Server. Each instance generally runs on one virtual or physical host, multiple instances can form a cluster environment.

### Graph Model

The definition of schemas and properties of a graph, representing the application scenario a graph describes.

### Schema

A node schema or an edge schema is a type of nodes or edges. A schema includes a set of properties that describes the attributes of the nodes or edges. Each node or edge belongs to one and only one schema.

### Property

A property belongs to a schema and is used to describe an attribute of a node or edge. There are system properties and custom properties.

### Unique Identifier (UID)

System properties that are used as the unique identifiers of nodes and edges, including the `_id` and `_uuid` of nodes, and `_uuid` of edges.
# Syntax
