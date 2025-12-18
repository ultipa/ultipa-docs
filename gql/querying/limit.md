## LIMIT

## Overview

The `LIMIT` statement restricts the maximum number of records to be retained in the intermediate result or output table. A non-negative integer must be specified in the `LIMIT` statement.

<p tit="Syntax"></p>

```gql
<limit statement> ::= "LIMIT" <non-negative integer>
```

## Example Graph

<div align=center drawio-diagram='16847' drawio-name="draw_9c29a4c8e44e459c88db4c719d6442c8.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_9c29a4c8e44e459c88db4c719d6442c8.jpg?v='1737965665438'"/></div>

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

## Limiting Records Returned

```gql
MATCH (n:Paper)
RETURN n.title LIMIT 2
```

Result:

| n.title |
| -- |
| Efficient Graph Search |
| Optimizing Queries |

## Limiting Records Passed Forward

```gql
MATCH (n:Paper) LIMIT 1
MATCH p = (n)->()
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20315' drawio-name="draw_8a9270b99dea443ab1893d48e2bbd5b2.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_8a9270b99dea443ab1893d48e2bbd5b2.jpg?v='1737965642303'"/></div>

## Limiting Ordered Records

```gql
MATCH (n:Paper)
ORDER BY n.title DESC 
LIMIT 1
RETURN n.title
```

Result:

| n.title |
| -- |
| Path Patterns |
