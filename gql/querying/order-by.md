## ORDER BY

## Overview

The `ORDER BY` statement allows you to sort the intermediate result or output table based on the specified columns.

<p tit="Syntax"></p>

```gql
<order by statement> ::= 
  "ORDER BY" <sort specification> [ { "," <sort specification> }... ]

<sort specification> ::=
  <value expression> [ "ASC" | "DESC" ] [ "NULLS FIRST" | "NULLS LAST" ]
```

**Details**

- `ASC` (ascending) is applied by default. To reverse the order, you can explicitly use the `DESC` (descending) keyword.
- `NULLS FIRST` and `NULLS LAST` can be used to control whether `null` values appear before or after non-null values. When null ordering is not explicitly specified:
    - `NULLS LAST` is applied by default when ordering in the `ASC` order.
    - `NULLS FIRST` is applied by default when ordering in the `DESC` order.

## Example Graph

<div align=center drawio-diagram='16841' drawio-name="draw_0665940066934954aa021f12215db8b1.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_0665940066934954aa021f12215db8b1.jpg?v='1737964169285'"/></div>

<div tab="code">
  
<p tit="Create the graph"></p>

```gql
CREATE GRAPH myGraph { 
  NODE Paper ({title string, score uint32, author string, publisher string}),
  EDGE Cites ()-[{weight uint32}]->()
} PARTITION BY HASH(Crc32) SHARDS [1]
```
  
<p tit="Insert data into the graph"></p>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex', publisher:'PulsePress'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack', publisher:'BrightLeaf'}),
       (p1)-[:Cites {weight:2}]->(p2),
       (p2)-[:Cites {weight:1}]->(p3)
```
  
</div>

## Ordering by Property

```gql
MATCH (n:Paper)
ORDER BY n.score
RETURN n.title, n.score
```

Result:

| n.title | n.score |
| -- | -- |
| Efficient Graph Search | 6 |
| Path Patterns | 7 |
| Optimizing Queries | 9 |

## Ordering by Node or Edge Variable

When a node or edge variable is specified, it is sorted on the `_uuid` of the nodes or edges. 

```gql
MATCH (n:Paper)
RETURN n.title, element_id(n) ORDER BY n
```

Result:

| n.title | element_id(n) |
| -- | -- |
| Optimizing Queries | 8718971077612535810 |
| Efficient Graph Search | 8791028671650463745 |
| Path Patterns | 12033620403357220867 |

## Ordering by Expression

```gql
MATCH p = (:Paper)->{1,2}(:Paper)
RETURN p, path_length(p) AS length ORDER BY length DESC
```

Result:

<table>
  <thead>
    <tr>
      <th>p</th>
      <th style="width:10%;">length</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
<div align=center drawio-diagram='20312' drawio-name='draw_2309806628d74e29bfd5540deb08d32e.jpg'><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_2309806628d74e29bfd5540deb08d32e.jpg?v='1737964214144'"/></div>
      </td>
      <td>2</td>
    </tr>
    <tr>
      <td>
<div align=center drawio-diagram='20313' drawio-name='draw_80c4ffcee72a4579ab79b69aab8766c1.jpg'><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_80c4ffcee72a4579ab79b69aab8766c1.jpg?v='1737964253033'"/></div>
      </td>
      <td>1</td>
    </tr>
    <tr>
      <td>
        <div align=center drawio-diagram='20314' drawio-name='draw_a589acfb233f4b46bb649a1867206709.jpg'><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_a589acfb233f4b46bb649a1867206709.jpg?v='1737964289838'"/></div>
      </td>
      <td>1</td>
    </tr>
  </tbody>
</table>

## Multi-level Ordering

When there are multiple specifications, it is sorted by the first specification listed, and for equals values, go to the next specification, and so on.

```gql
MATCH (n:Paper)
RETURN n.title, n.author, n.score 
ORDER BY n.author DESC, n.score
```

Result:

| n.title | n.author | n.score |
| -- | -- | -- |
| Path Patterns | Zack | 7 |
| Efficient Graph Search | Alex | 6 |
| Optimizing Queries | Alex | 9 |

## Discarding and Retaining Records After Ordering

You may use the `SKIP` or `LIMIT` statement after the `ORDER BY` statement to skip a specified number of records from the top, or to limit the number of records retained.

To return titles of the two papers with the second and third highest scores:

```gql
MATCH (n:Paper)
RETURN n.title, n.score
ORDER BY n.score DESC SKIP 1 LIMIT 2
```

Result: 

| n.title | n.score |
| -- | -- |
| Path Patterns | 7 |
| Efficient Graph Search | 6 |

## Null Ordering

To return titles of the two papers with the second and third highest scores, ensuring `null` values appear at the front if applicable:

```gql
MATCH (n:Paper)
RETURN n.title, n.publisher
ORDER BY n.publisher NULLS FIRST
```

Result: 

| n.title | n.score |
| -- | -- |
| Optimizing Queries | `null` |
| Path Patterns | BrightLeaf |
| Efficient Graph Search | PulsePress |
