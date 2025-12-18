## SKIP

## Overview

The `SKIP` statement allows you to discard a specified number of records from the start of the intermediate result or output table. A non-negative integer must be specified in `SKIP`.

> `OFFSET` can be used as a synonym to `SKIP`.

<p tit="Syntax"></p>

```gql
<skip statement> ::= "SKIP" <non-negative integer>
```

## Example Graph

<div align=center drawio-diagram='16850' drawio-name="draw_48d050d22da344528aa2e26d3ca63913.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_48d050d22da344528aa2e26d3ca63913.jpg?v='1737965734232'"/></div>

<div tab="code">

<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph { 
  NODE Paper ({title string, score uint32, author string}),
  EDGE Cites ()-[{}]->()
} PARTITION BY HASH(Crc32) SHARDS [1]
```

<p tit="Insert data to the graph"></p>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack'}),
       (p1)-[:Cites]->(p2),
       (p2)-[:Cites]->(p3)
```

</div>

## Skipping N Records

```gql
MATCH (n:Paper)
RETURN n.title SKIP 1
```

Result:

| n.title |
| -- |
| Efficient Graph Search |
| Path Patterns |

## Skipping N Ordered Records

```gql
MATCH (n:Paper)
ORDER BY n.score 
SKIP 1
MATCH p = (n)->()
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20316' drawio-name='draw_09a48c48903d47c8a8d5fb3fdac6cb8c.jpg'><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_09a48c48903d47c8a8d5fb3fdac6cb8c.jpg?v='1737965881010'"/></div>
