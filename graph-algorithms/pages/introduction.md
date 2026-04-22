# Introduction

Ultipa provides a rich set of built-in graph algorithms for analytical insights from graph data. All algorithms are compiled into the database and available immediately — no separate installation is required.

## Running Algorithms

Algorithms are executed as streaming procedures using `CALL algo.<name>()`:

```gql
CALL algo.pagerank() YIELD nodeId, score
RETURN nodeId, score
ORDER BY score DESC LIMIT 10
```

## Discovering Algorithms

List all available algorithms:

```gql
SHOW ALGOS
```

Filter by category:

```gql
SHOW ALGOS CATEGORY centrality
```

View details for a specific algorithm:

```gql
DESCRIBE ALGOS pagerank
```

## All Algorithms

The algorithms Ultipa provides are classified into the following categories:

- <b>Centrality Algorithms</b>
  - <a href="/docs/graph-algorithms/degree-centrality">Degree Centrality</a>
  - <a href="/docs/graph-algorithms/closeness-centrality">Closeness Centrality</a>
  - <a href="/docs/graph-algorithms/harmonic-centrality">Harmonic Centrality</a>
  - <a href="/docs/graph-algorithms/graph-centrality">Graph Centrality</a>
  - <a href="/docs/graph-algorithms/betweenness-centrality">Betweenness Centrality</a>
  - <a href="/docs/graph-algorithms/eigenvector-centrality">Eigenvector Centrality</a>
  - <a href="/docs/graph-algorithms/katz-centrality">Katz Centrality</a>
  - <a href="/docs/graph-algorithms/celf">CELF</a>
  - <a href="/docs/graph-algorithms/pagerank">PageRank</a>
  - <a href="/docs/graph-algorithms/article-rank">ArticleRank</a>
  - <a href="/docs/graph-algorithms/textrank">TextRank</a>
  - <a href="/docs/graph-algorithms/hits">HITS</a>
  - <a href="/docs/graph-algorithms/sybil-rank">SybilRank</a>
- <b>Similarity algorithms</b>
  - <a href="/docs/graph-algorithms/jaccard-similarity">Jaccard Similarity</a>
  - <a href="/docs/graph-algorithms/overlap-similarity">Overlap Similarity</a> 
  - <a href="/docs/graph-algorithms/cosine-similarity">Cosine Similarity</a> 
  - <a href="/docs/graph-algorithms/pearson-correlation-coefficient">Pearson Correlation Coefficient</a> 
  - <a href="/docs/graph-algorithms/euclidean-distance">Euclidean Distance</a> 
- <b>Connectivity & Compactness Algorithms</b>
  - <a href="/docs/graph-algorithms/khop-all">K-Hop All</a>
  - <a href="/docs/graph-algorithms/bipartite">Bipartite Graph</a>
  - <a href="/docs/graph-algorithms/hyperanf">HyperANF</a>
  - <a href="/docs/graph-algorithms/connected-component">Connected Component</a>
  - <a href="/docs/graph-algorithms/triangle-counting">Triangle Counting</a>
  - <a href="/docs/graph-algorithms/induced-subgraph">Induced Subgraph</a>
  - <a href="/docs/graph-algorithms/k-core">k-Core</a>
  - <a href="/docs/graph-algorithms/k-truss">k-Truss</a>
  - <a href="/docs/graph-algorithms/p-cohesion">p-Cohesion</a>
  - <a href="/docs/graph-algorithms/k-edge-connected-components">k-Edge Connected Components</a>
  - <a href="/docs/graph-algorithms/clustering-coefficient">Local Clustering Coefficient</a>
  - <a href="/docs/graph-algorithms/topological-sort">Topological Sort</a>
  - <a href="/docs/graph-algorithms/schema-overview">Schema Overview</a>
- <b>Pathfinding</b>
  - <a href="/docs/graph-algorithms/dijkstra-sssp">Dijkstra's Single-Source Shortest Path</a>
  - <a href="/docs/graph-algorithms/delta-stepping-sssp">Delta-Stepping Single-Source Shortest Path</a>
  - <a href="/docs/graph-algorithms/spfa">Shortest Path Faster Algorithm (SPFA)</a>
  - <a href="/docs/graph-algorithms/mst">Minimum Spanning Tree</a>
  - <a href="/docs/graph-algorithms/bfs">Breadth-First Search (BFS)</a>
  - <a href="/docs/graph-algorithms/dfs">Depth First Search (DFS)</a>
- <b>Topological Link Prediction</b>
  - <a href="/docs/graph-algorithms/adamic-adar">AA Index</a>
  - <a href="/docs/graph-algorithms/common-neighbors">Common Neighbors</a>
  - <a href="/docs/graph-algorithms/preferential-attachment">Preferential Attachment</a>
  - <a href="/docs/graph-algorithms/resource-allocation">Resource Allocation</a>
  - <a href="/docs/graph-algorithms/total-neighbors">Total Neighbors</a>  
- <b>Community Detection & Classification Algorithms</b>
  - <a href="/docs/graph-algorithms/louvain">Louvain</a>
  - <a href="/docs/graph-algorithms/leiden">Leiden</a>
  - <a href="/docs/graph-algorithms/lpa">Label Propagation</a>
  - <a href="/docs/graph-algorithms/hanp">HANP</a>
  - <a href="/docs/graph-algorithms/kmeans">k-Means</a>
  - <a href="/docs/graph-algorithms/knn">kNN (k-Nearest Neighbors)</a>
  - <a href="/docs/graph-algorithms/k1-coloring">K-1 Coloring</a>
  - <a href="/docs/graph-algorithms/conductance">Conductance</a>
- <b>Graph Embedding Algorithms</b>
  - Algorithms
    - <a href="/docs/graph-algorithms/random-walk">Random Walk</a>
    - <a href="/docs/graph-algorithms/node2vec-walk">Node2Vec Walk</a>
    - <a href="/docs/graph-algorithms/node2vec">Node2Vec</a>
    - <a href="/docs/graph-algorithms/struc2vec-walk">Struc2Vec Walk</a>
    - <a href="/docs/graph-algorithms/struc2vec">Struc2Vec</a>
    - <a href="/docs/graph-algorithms/line">LINE</a>
    - <a href="/docs/graph-algorithms/fastrp">Fast Random Projection</a>
  - Background Knowledge
    - <a href="/docs/graph-algorithms/summary-of-graph-embedding">Summary of Graph Embedding</a>
    - <a href="/docs/graph-algorithms/gradient-descent">Gradient Descent</a>
    - <a href="/docs/graph-algorithms/backpropagation">Backpropagation</a>
    - <a href="/docs/graph-algorithms/skip-gram">Skip-gram</a>
    - <a href="/docs/graph-algorithms/skip-gram-optimization">Skip-gram Optimization</a>