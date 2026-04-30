# Introduction

Ultipa provides a rich set of built-in graph algorithms for analytical insights from graph data. All algorithms are compiled into the database and available immediately, no separate installation is required.

## Running Algorithms

Algorithms are executed as streaming procedures using `CALL algo.<name>()`:

```gql
CALL algo.pagerank() YIELD nodeId, score
RETURN nodeId, score
ORDER BY score DESC LIMIT 10
```

<a href="/docs/graph-algorithms/running-algorithms">Learn more about running algorithms →</a>

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

- <b>Centrality</b>
  - <a href="/docs/graph-algorithms/degree-centrality">Degree Centrality</a>
  - <a href="/docs/graph-algorithms/closeness-centrality">Closeness Centrality</a>
  - <a href="/docs/graph-algorithms/harmonic-centrality">Harmonic Centrality</a>
  - <a href="/docs/graph-algorithms/eccentricity-centrality">Eccentricity Centrality</a>
  - <a href="/docs/graph-algorithms/betweenness-centrality">Betweenness Centrality</a>
  - <a href="/docs/graph-algorithms/bridges">Bridges</a>
  - <a href="/docs/graph-algorithms/articulation-points">Articulation Points</a>
  - <a href="/docs/graph-algorithms/eigenvector-centrality">Eigenvector Centrality</a>
  - <a href="/docs/graph-algorithms/katz-centrality">Katz Centrality</a>
  - <a href="/docs/graph-algorithms/celf">CELF</a>
  - <a href="/docs/graph-algorithms/pagerank">PageRank</a>
  - <a href="/docs/graph-algorithms/articlerank">ArticleRank</a>
  - <a href="/docs/graph-algorithms/textrank">TextRank</a>
  - <a href="/docs/graph-algorithms/hits">HITS</a>
  - <a href="/docs/graph-algorithms/sybil-rank">SybilRank</a>
- <b>Similarity</b>
  - <a href="/docs/graph-algorithms/jaccard-similarity">Jaccard Similarity</a>
  - <a href="/docs/graph-algorithms/overlap-similarity">Overlap Similarity</a>
  - <a href="/docs/graph-algorithms/cosine-similarity">Cosine Similarity</a>
  - <a href="/docs/graph-algorithms/pearson-correlation-coefficient">Pearson Correlation Coefficient</a>
  - <a href="/docs/graph-algorithms/euclidean-distance">Euclidean Distance</a>
  - <a href="/docs/graph-algorithms/knn">KNN</a>
  - <a href="/docs/graph-algorithms/vector-similarity">Vector Similarity</a>
- <b>Graph Structure</b>
  - <a href="/docs/graph-algorithms/bipartite-graph">Bipartite Graph</a>
  - <a href="/docs/graph-algorithms/hyperanf">HyperANF</a>
  - <a href="/docs/graph-algorithms/wcc">Weakly Connected Components (WCC)</a>
  - <a href="/docs/graph-algorithms/scc">Strongly Connected Components (SCC)</a>
  - <a href="/docs/graph-algorithms/k-edge-connected-components">k-Edge Connected Components</a>
  - <a href="/docs/graph-algorithms/local-clustering-coefficient">Local Clustering Coefficient</a>
  - <a href="/docs/graph-algorithms/triangle-count">Triangle Count</a>
  - <a href="/docs/graph-algorithms/clique-count">Clique Count</a>
  - <a href="/docs/graph-algorithms/k-core">k-Core</a>
  - <a href="/docs/graph-algorithms/k-truss">k-Truss</a>
  - <a href="/docs/graph-algorithms/p-cohesion">p-Cohesion</a>
  - <a href="/docs/graph-algorithms/induced-subgraph">Induced Subgraph</a>
- <b>DAG</b>
  - <a href="/docs/graph-algorithms/topological-sort">Topological Sort</a>
- <b>Pathfinding</b>
  - <a href="/docs/graph-algorithms/bfs">Breadth-First Search (BFS)</a>
  - <a href="/docs/graph-algorithms/dfs">Depth-First Search (DFS)</a>
  - <a href="/docs/graph-algorithms/dijkstra-shortest-path">Dijkstra's Shortest Path</a>
  - <a href="/docs/graph-algorithms/astar">A* Shortest Path</a>
  - <a href="/docs/graph-algorithms/yens">Yen's K-Shortest Paths</a>
  - <a href="/docs/graph-algorithms/shortest-bfs">Shortest Path (BFS)</a>
  - <a href="/docs/graph-algorithms/delta-stepping-sssp">Delta-Stepping SSSP</a>
  - <a href="/docs/graph-algorithms/spfa">Shortest Path Faster Algorithm (SPFA)</a>
  - <a href="/docs/graph-algorithms/apsp">All-Pairs Shortest Path (APSP)</a>
  - <a href="/docs/graph-algorithms/mst">Minimum Spanning Tree (MST)</a>
  - <a href="/docs/graph-algorithms/kspanningtree">K-Spanning Tree</a>
  - <a href="/docs/graph-algorithms/steiner">Steiner Tree</a>
  - <a href="/docs/graph-algorithms/pcst">Prize-Collecting Steiner Tree (PCST)</a>
  - <a href="/docs/graph-algorithms/mincostflow">Minimum Cost Flow</a>
  - <a href="/docs/graph-algorithms/maxflow">Maximum Flow</a>
  - <a href="/docs/graph-algorithms/khop-fast">K-Hop Fast</a>
  - <a href="/docs/graph-algorithms/longest-path-dag">Longest Path (DAG)</a>
  - <a href="/docs/graph-algorithms/random-walk">Random Walk</a>
- <b>Link Prediction</b>
  - <a href="/docs/graph-algorithms/adamic-adar">Adamic-Adar Index</a>
  - <a href="/docs/graph-algorithms/common-neighbors">Common Neighbors</a>
  - <a href="/docs/graph-algorithms/preferential-attachment">Preferential Attachment</a>
  - <a href="/docs/graph-algorithms/resource-allocation">Resource Allocation</a>
  - <a href="/docs/graph-algorithms/total-neighbors">Total Neighbors</a>
  - <a href="/docs/graph-algorithms/same-community">Same Community</a>
- <b>Community Detection</b>
  - <a href="/docs/graph-algorithms/louvain">Louvain</a>
  - <a href="/docs/graph-algorithms/leiden">Leiden</a>
  - <a href="/docs/graph-algorithms/modularity-optimization">Modularity Optimization</a>
  - <a href="/docs/graph-algorithms/label-propagation">Label Propagation</a>
  - <a href="/docs/graph-algorithms/hanp">HANP</a>
  - <a href="/docs/graph-algorithms/slpa">SLPA</a>
  - <a href="/docs/graph-algorithms/k-means">k-Means</a>
  - <a href="/docs/graph-algorithms/hdbscan">HDBSCAN</a>
  - <a href="/docs/graph-algorithms/k1-coloring">K-1 Coloring</a>
  - <a href="/docs/graph-algorithms/modularity">Modularity</a>
  - <a href="/docs/graph-algorithms/conductance">Conductance</a>
  - <a href="/docs/graph-algorithms/max-k-cut">Max k-Cut</a>
- <b>Graph Embedding</b>
  - <a href="/docs/graph-algorithms/node2vec">Node2Vec</a>
  - <a href="/docs/graph-algorithms/struc2vec">Struc2Vec</a>
  - <a href="/docs/graph-algorithms/line">LINE</a>
  - <a href="/docs/graph-algorithms/fastrp">FastRP</a>
  - <a href="/docs/graph-algorithms/graphsage">GraphSAGE</a>
  - <a href="/docs/graph-algorithms/hashgnn">HashGNN</a>