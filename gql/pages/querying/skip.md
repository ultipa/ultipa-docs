# SKIP

## Overview

The `SKIP` statement allows you to discard a specified number of rows from the start of the intermediate result table or output table. `OFFSET` is a synonym to `SKIP`.

<p tit="Syntax"></p>

```
<skip statement> ::= < "SKIP" | "OFFSET" > <non-negative integer>
```

## Example Graph

<div align=center drawio-diagram='16850' drawio-name="draw_48d050d22da344528aa2e26d3ca63913.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_48d050d22da344528aa2e26d3ca63913.jpg?v='1737965734232'"/></div>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack'}),
       (p1)-[:Cites]->(p2),
       (p2)-[:Cites]->(p3)
```

## Skipping N Rows

```gql
MATCH (n:Paper)
RETURN n.title SKIP 1
```

Result:

| n.title |
| -- |
| Efficient Graph Search |
| Path Patterns |

## Skipping N Ordered Rows

```gql
MATCH (n:Paper)
ORDER BY n.score 
SKIP 1
MATCH p = (n)->()
RETURN p
```

Result: `p`

<div align=center drawio-diagram='20316' drawio-name='draw_09a48c48903d47c8a8d5fb3fdac6cb8c.jpg'><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_09a48c48903d47c8a8d5fb3fdac6cb8c.jpg?v='1737965881010'"/></div>
