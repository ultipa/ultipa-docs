# Shortest Paths

## Overview

Shortest paths between two nodes are those with the fewest number of edges. You can select shortest paths from each **partition** of the match results using the following path selectors. A "partition" refers to a group of paths that share the same start and end nodes.

| <div table-width="25">Path Selector</div> | Description |
| -- | -- |
| `ALL SHORTEST` | Selects all shortest paths from each partition. |
| `ANY SHORTEST` | Selects any one shortest path from each partition. |
| `SHORTEST k` | Selects any `k` (non-negative integer) shortest paths from each partition. If a partition has fewer than `k` shortest paths, continue selecting the second shortest, third shortest, and so on, until the required number is reached or no more paths are available. |
| `SHORTEST k GROUP` | Groups the paths in each partition by length, sorts the groups in ascending order, and selects all paths from the first `k` groups in each partition. |

The shortest path selectors are typically used with variable-length <a target="_blank" href="/docs/gql/quantified-paths">quantified paths</a>. When a shortest path selector is used, the path mode defaults to `TRAIL` where repeated edges are not allowed.

## Note on Shortest Path Algorithms

Ultipa’s graph algorithm library includes many shortest path algorithms:

- <a target="_blank" href="/docs/graph-algorithms/dijkstra-shortest-path">Dijkstra's Shortest Path</a>
- <a target="_blank" href="/docs/graph-algorithms/astar">A* Shortest Path</a>
- <a target="_blank" href="/docs/graph-algorithms/yens">Yen's K-Shortest Paths</a>
- <a target="_blank" href="/docs/graph-algorithms/shortest-bfs">Shortest Path (BFS)</a>
- <a target="_blank" href="/docs/graph-algorithms/delta-stepping-sssp">Delta-Stepping SSSP</a>
- <a target="_blank" href="/docs/graph-algorithms/spfa">Shortest Path Faster Algorithm (SPFA)</a>

These algorithms are recommended for computing **weighted shortest paths** (i.e., cheapest paths) or when searching for shortest paths on large graphs.

## Example Graph

<div align=center drawio-diagram='16791' drawio-name="draw_1899538f3dd346f4baf2d998287f7820.jpg"><img src="https://img.ultipa.cn/draw/draw_1899538f3dd346f4baf2d998287f7820.jpg?v='1726757651042'"/></div>

```gql
INSERT (zenith:City {_id: "Zenith"}),
       (arcadia:City {_id: "Arcadia"}),
       (verona:City {_id: "Verona"}),
       (nebula:City {_id: "Nebula"}),
       (mirage:City {_id: "Mirage"}),
       (lunaria:City {_id: "Lunaria"}),
       (solara:City {_id: "Solara"}),
       (eldoria:City {_id: "Eldoria"}),
       (nexis:City {_id: "Nexis"}),
       (arcadia)-[:Links]->(zenith),
       (arcadia)-[:Links]->(verona),
       (arcadia)-[:Links]->(solara),
       (mirage)-[:Links]->(arcadia),
       (nebula)-[:Links]->(verona),
       (mirage)-[:Links]->(nebula),
       (verona)-[:Links]->(mirage),
       (mirage)-[:Links]->(eldoria),
       (solara)-[:Links]->(eldoria),
       (lunaria)-[:Links]->(solara)
```

## ALL SHORTEST

```gql
MATCH p = ALL SHORTEST (a)-[:Links]-+(b)
WHERE a._id = 'Arcadia' AND b._id = 'Eldoria'
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20510' drawio-name='draw_4c08f39f8a8948ceb5c679b6be77704b.jpg'><img src="https://img.ultipa.cn/draw/draw_4c08f39f8a8948ceb5c679b6be77704b.jpg?v='1738831482457'"/></div>

## ANY SHORTEST

```gql
MATCH p = ANY SHORTEST (a)-[:Links]-{1,10}(b)
WHERE a._id = 'Arcadia' AND b._id = 'Eldoria'
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20655' drawio-name='draw_c53037c80cb34a5493e2f65fc1aab702.jpg'><img src="https://img.ultipa.cn/draw/draw_c53037c80cb34a5493e2f65fc1aab702.jpg?v='1739009312358'"/></div>

## SHORTEST k

```gql
MATCH p = SHORTEST 2 (a)-[:Links]-{1,10}(b)
WHERE a._id = 'Arcadia' AND b._id = 'Eldoria'
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20511' drawio-name='draw_f637566d653a4a799b762d349b2a69b0.jpg'><img src="https://img.ultipa.cn/draw/draw_f637566d653a4a799b762d349b2a69b0.jpg?v='1738831594485'"/></div>

```gql
MATCH p = SHORTEST 3 (a)-[:Links]-{1,10}(b)
WHERE a._id = 'Arcadia' AND b._id = 'Eldoria'
RETURN p
```

Since only two paths with the shortest length of `2` exist between `Arcadia` and `Eldoria`, one path with the second shortest length needs to be selected. In this example, there is only one path with the second shortest length of `3`, therefore the following three paths are returned:

<div align=center drawio-diagram='20512' drawio-name='draw_ec2947df63df4b22ba5ee7d17d626be2.jpg'><img src="https://img.ultipa.cn/draw/draw_ec2947df63df4b22ba5ee7d17d626be2.jpg?v='1738831765789'"/></div>

## SHORTEST k GROUP

```gql
MATCH p = SHORTEST 3 GROUP (a)-[:Links]-{1,10}(b)
WHERE a._id = 'Arcadia' AND b._id = 'Eldoria'
RETURN p
```

Two paths with the shortest length of `2`, one path with the second shortest length of `3` and one path with the third shortest length of `4` are returned:

<div align=center drawio-diagram='20513' drawio-name="draw_be26fe25399c444eb88161a7ed9fea5c.jpg"><img src="https://img.ultipa.cn/draw/draw_be26fe25399c444eb88161a7ed9fea5c.jpg?v='1738832019407'"/></div>

## Partitions

When a path pattern matches multiple start and end nodes, the results are conceptually partitioned into distinct pairs of start node and end node. The shortest path selection is performed within each partition, and the result is the union of all shortest paths found for each partition.

In this query, the Cartesian product of `a` and `b` are generated before they are referenced in the path pattern, therefore there are four shortest paths selected from the four partitions:

```gql
MATCH p = SHORTEST 1 (a)-[:Links]-{1,10}(b)
WHERE a._id IN ['Zenith', 'Arcadia'] AND b._id IN ['Eldoria', 'Nebula']
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20514' drawio-name="draw_a37d5483c3074e659e3bc1baa2051c09.jpg"><img src="https://img.ultipa.cn/draw/draw_a37d5483c3074e659e3bc1baa2051c09.jpg?v='1754297984788'"/></div>

This query finds the shortest paths between `Arcadia` and any other city in the graph: 

```gql
MATCH p = SHORTEST 1 ({_id: 'Arcadia'})-{1,10}()
RETURN p
```

There are 8 nodes `Arcadia` can reach in the graph (including itself) except `Nexis`. The following is one of the possible returns:

<div align=center drawio-diagram='20515' drawio-name="draw_cc192c041cb8403d990bcf001a560a2a.jpg"><img src="https://img.ultipa.cn/draw/draw_cc192c041cb8403d990bcf001a560a2a.jpg?v='1752032090890'"/></div>
