# Graph Analytics for Insights

**Graph analytics**, or **Graph algorithms**, is designed to derive insights from interconnected data represented as a graph. While traditional analytics focuses more on individual data points, graph analytics places significant emphasis on the connections between data, uncovering insights that are not immediately apparent.

> This page covers the basics of graph analytics. For the complete guide, refer to <a target="_blank" href="/docs/graph-analytics-algorithms">Ultipa Graph Analytics & Algorithms</a>.

## Graph Algorithm Library

Ultipa offers a rich collection of graph algorithms spanning the following categories:

### Centrality

Ranks nodes within a graph based on various measures of importance.

For example, the <a target="_blank" href="/docs/graph-analytics-algorithms/degree-centrality">Degree Centrality</a> algorithm evaluates a node's significance by the number of edges connected to it (i.e., degree), indicating its level of direct interaction with other nodes in the graph.

<div align=center drawio-diagram='20120' drawio-name='draw_cb0f14bbe64440c4bb3031ea60e9bdd6.jpg'><img src="https://img.ultipa.cn/draw/draw_cb0f14bbe64440c4bb3031ea60e9bdd6.jpg?v='1736924948297'"/></div>
<center><span style="color:#999;">Ranks nodes by degree</span></center>

### Similarity

Measures the degree of similarity between two nodes within a graph using various metrics.

For example, the <a target="_blank" href="/docs/graph-analytics-algorithms/jaccard-similarity">Jaccard Similarity</a> algorithm computes the similarity between two nodes by comparing the intersection and union of their neighbors, reflecting how similar their neighborhoods are.

<div align=center drawio-diagram='20122' drawio-name='draw_0927bd701da54dc2a1bdf6887919ec18.jpg'><img src="https://img.ultipa.cn/draw/draw_0927bd701da54dc2a1bdf6887919ec18.jpg?v='1736925981074'"/></div>
<center><span style="color:#999;">Measures the Jaccard similarity between nodes A and D</span></center>

### Connectivity & Compactness

Explores the overall or local connectivity or density of a graph.

For example, the <a target="_blank" href="/docs/graph-analytics-algorithms/connected-component">Connected Component</a> algorithm identifies the connected components in a graph. A connected component is a maximal subset of nodes that are all connected to each other. If only one connected component is detected, it means that the graph is fully connected.

<div align=center drawio-diagram='20123' drawio-name="draw_b7f68260d3b24882acbd285910f5dc50.jpg"><img src="https://img.ultipa.cn/draw/draw_b7f68260d3b24882acbd285910f5dc50.jpg?v='1736927014860'"/></div>
<center><span style="color:#999;">Detects connected components in graphs</span></center>

### Pathfinding

Finds the shortest or cheapest paths between nodes in a graph, or visits all nodes systematically.

For example, the <a target="_blank" href="/docs/graph-analytics-algorithms/mst">Minimum Spanning Tree</a> algorithm searches for the spanning tree with the minimum sum of edge weights in a graph, resulting in the lowest possible cost.

<div align=center drawio-diagram='20124' drawio-name="draw_b65ab7864cdb48b5a0ec75307d11779d.jpg"><img src="https://img.ultipa.cn/draw/draw_b65ab7864cdb48b5a0ec75307d11779d.jpg?v='1736927730146'"/></div>
<center><span style="color:#999;">The thick red edges connect all nodes in the graph with the minimum sum of edge weights</span></center>

### Topological Link Predication

Predicts the likelihood of an edge (link) forming between two nodes that are not yet connected, based on the existing structure of the graph.

For example, the <a target="_blank" href="/docs/graph-analytics-algorithms/common-neighbors">Common Neighbors</a> algorithm counts the common neighbors between two nodes as the predication score. The intuition is that nodes with many shared neighbors are likely to form a connection in the future.

<div align=center drawio-diagram='20125' drawio-name="draw_32dd8dc27f384f6eb26ca8601bd4cfe1.jpg"><img src="https://img.ultipa.cn/draw/draw_32dd8dc27f384f6eb26ca8601bd4cfe1.jpg?v='1736928307121'"/></div>
<center><span style="color:#999;">A and D are more likely to connect in the future compared to A and F, based on the number of common neighbors they share</span></center>

### Community Detection & Classification

Identifies groups of nodes in a graph that are more densely connected to each other than to the rest of the graph.

For example, the <a target="_blank" href="/docs/graph-analytics-algorithms/louvain">Louvain</a> algorithm detects communities in the graph while maximizing its modularity, where modularity is one of the widely used methods to evaluate the quality of a community partition.

<div align=center drawio-diagram='20126' drawio-name="draw_4ab2dfa7e0484c8db6ea577bc9585a56.jpg"><img src="https://img.ultipa.cn/draw/draw_4ab2dfa7e0484c8db6ea577bc9585a56.jpg?v='1736928534811'"/></div>
<center><span style="color:#999;">A graph with three communities</span></center>

### Graph Embedding

Maps nodes into continuous vector spaces while preserving the structure and attributes (node and edge properties) within the graph. The purpose of graph embedding is to transform graph data into vectors that can be used for downstream machine learning tasks.

For example, below shows the results of running an embedding algorithm to a graph. In the graph, the colors of the nodes indicate their communities. Once all nodes are transformed into two-dimensional vectors, it's evident that nodes within the same community are positioned relatively closer to each other, meaning the graph structure is well retained.

<center><img src="https://img.ultipa.cn/img/2023-05-22-10-46-40-deepwalk.jpg"><span style="color:#999999;">Source: B. Perozzi, et al., DeepWalk: Online Learning of Social Representations (2014)</span></center>

## How to Run Algorithms

Use GQL to run algorithms in Ultipa. To achieve optimal performance, you should create either an <a target="_blank" href="/docs/graph-analytics-algorithms/managing-hdc-graphs">HDC graph</a> or a <a target="_blank" href="/docs/graph-analytics-algorithms/managing-distributed-projections">distributed projection</a> for your graph, on which the algorithms will run.

To create an HDC graph `my_hdc_graph` on the HDC server `hdc-server-1` while loading your entire graph:

```gql
CREATE HDC GRAPH my_hdc_graph ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}
```

To run the Degree Centrality algorithm on `my_hdc_graph` and return the top 10 nodes with the highest degrees:

```gql
CALL algo.degree.run("my_hdc_graph", {
  return_id_uuid: "id",
  limit: 10,
  order: 'desc'
}) YIELD r
RETURN r
```

Ultipa graph algorithms support six <a target="_blank" href="/docs/graph-analytics-algorithms/running-algorithms#Execution-Modes">execution modes</a>: **File Writeback**, **DB Writeback**, **Stats Writeback**, **Full Return**, **Stream Return**, and **Stats Return**. These modes allow you to choose whether to return the results directly to the client or save them to a file or database, depending on your specific needs and use case.
