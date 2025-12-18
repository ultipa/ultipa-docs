## HDC Graph Queries

## Overview

To execute a query on an HDC graph, use the syntax:

<p tit="Syntax"></p>

```gql
EXEC{
  <query>
} ON <hdcGraphName>
```

HDC graphs support queries that retrieve data from the database with enhanced efficiency, but do not allow operations that modify the graph structure or data.

## Example Graph

<div align=center drawio-diagram='24577' drawio-name='draw_270ab88b903241dcbed9f61001833407.jpg'><img src="https://img.ultipa.cn/draw/draw_270ab88b903241dcbed9f61001833407.jpg?v='1749708660218'"/></div>

Run the following statements on an empty graph to define its structure and insert data:

```gql
ALTER GRAPH CURRENT_GRAPH ADD NODE {
  entity ()
};
ALTER GRAPH CURRENT_GRAPH ADD EDGE {
  link ()-[{weight float}]->()
};
INSERT (A:entity {_id: "A"}),
       (B:entity {_id: "B"}),
       (C:entity {_id: "C"}),
       (D:entity {_id: "D"}),
       (A)-[:link {weight: 1}]->(B),
       (A)-[:link {weight: 1.5}]->(C),
       (A)-[:link {weight: 0.5}]->(D),
       (B)-[:link {weight: 2}]->(C),
       (C)-[:link {weight: 0.5}]->(D);
```

## Queries on HDC Graphs

To create an HDC graph `hdcGraph` of the entire graph:

```gql
CREATE HDC GRAPH hdcGraph ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: true,
  update: "static"
}
```

To run a query on `hdcGraph`:

```gql
EXEC{
  MATCH p = ({_id: "A"})-[]-{2}({_id: "C"})
  RETURN p
} ON hdcGraph
```

Result: `p`

<div align=center drawio-diagram='24578' drawio-name='draw_7b72482abeb741819dd5e0e5badd941b.jpg'><img src="https://img.ultipa.cn/draw/draw_7b72482abeb741819dd5e0e5badd941b.jpg?v='1749708679480'"/></div>

## Limited Graph Traversal Direction

If an HDC graph is created with the `direction` option set to `in` or `out`, graph traversal is restricted to incoming or outgoing edges, respectively. Queries attempting to traverse in the missing direction throw errors or yield empty results.

To create an HDC graph `hdcGraph_in_edges` of the graph with nodes and incoming edges:

```gql
CREATE HDC GRAPH hdcGraph_in_edges ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "in",
  load_id: true,
  update: "static"
}
```

This query attempts to traverse the outgoing edges from node `A` on `hdcGraph_in_edges`, but no result will be returned:

```gql
EXEC{
  MATCH p = ({_id: "A"})-[]->()
  RETURN p
} ON hdcGraph_in_edges
```

## Exclusion of Node IDs

If an HDC graph is created with the `load_id` option set to `false`, it does not contain the `_id` values for nodes. Queries referencing `_id` throw errors or yield empty results.

```gql
CREATE HDC GRAPH hdcGraph_no_id ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"*": ["*"]},
  direction: "undirected",
  load_id: false,
  update: "static"
}
```

This query utilizes `_id` to filter nodes on `hdcGraph_no_id`, error occurs as the HDC graph lacks nodes' `_id`:

```gql
EXEC{
  MATCH p = ({_id: "A"})-[]-{2}({_id: "C"})
  RETURN p
} ON hdcGraph_no_id
```

## Exclusion of Properties

If an HDC graph is created without certain properties, queries referencing these properties throw errors or yield empty results.

To create an HDC graph `hdcGraph_no_weight` of the graph, which includes all node properties but only the system properties of `link` edges:

```gql
CREATE HDC GRAPH hdcGraph_no_weight ON "hdc-server-1" OPTIONS {
  nodes: {"*": ["*"]},
  edges: {"link": []},
  direction: "undirected",
  load_id: true,
  update: "static"
}
```

This query utilizes the `weight` property to filter edges on `hdcGraph_no_weight`, but no result will be returned since the HDC graph doesn't have the `weight` property:

```gql
EXEC{
  MATCH p = ({_id: "A"})-[e]-() WHERE e.weight > 1
  RETURN p
} ON hdcGraph_no_weight
```
null
