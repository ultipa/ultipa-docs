## LET

## Overview

The `LET` statement allows you to define new variables and adds corresponding columns to the intermediate result table. Each variable is assigned a value using the `=` operator.

<p tit="Syntax"></p>

```gql
<let statement> ::= 
  "LET" <let variable definition> [ { "," <let variable definition> }... ]

<let variable definition> ::= 
    <binding variable> "=" <value expression>
  | <value variable definition>
    
<value variable definition> ::=
  "VALUE" <binding variable> [ "TYPED" ] <value type> "=" <value expression>
```

**Details**

- `LET` does not change the number of records in the intermediate result table.
- `LET` does not modify existing columns in the intermediate result table unless you re-define existing variables within `LET`.
- You cannot define a new variable and reference it within the same `LET`.

## Example Graph

<div align=center drawio-diagram='16853' drawio-name="draw_dd777413fbf94d6a89ffd0f4c331c0ef.jpg"><img src="https://img.ultipa.cn/draw/draw_dd777413fbf94d6a89ffd0f4c331c0ef.jpg?v='1726105322854'"/></div>

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
INSERT (p1:Paper {_id:"P1", title:'Efficient Graph Search', score:6, author:'Alex'}),
       (p2:Paper {_id:"P2", title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:"P3", title:'Path Patterns', score:6, author:'Zack'}),
       (p1)-[:Cites]->(p2),
       (p2)-[:Cites]->(p3)
```

</div>

## Defining Variables

```gql
LET threshold = 6
MATCH (p:Paper) WHERE p.score > threshold
RETURN p.title, p.score - threshold
```

Result:

| p.title | p.score - threshold |
| -- | -- |
| Optimizing Queries | 3 |

## Defining Value Variables

You can define a value varible with a specified type. The engine will then validate whether the assigned value is either already of that type or can be safely cast to it. If the value cannot be cast to the specified type, an exception will be thrown at runtime.

```gql
LET VALUE x TYPED INT = 28
RETURN 28
```

Result:

| x |
| -- |
| 28 |

This approach ensures type safety in your queries and helps catch incorrect data types early during execution.

## Referencing Variables in LET

If any variable is referenced within `LET`, it will evaluate row by row over the records of that variable.

This query references `x` in `LET` and determines whether its `score` property is greater than 7:

```gql
MATCH (x:Paper)
LET recommended = x.score > 7
RETURN x.title, recommended
```

It is equivalent to:

```gql
MATCH (x:Paper)
CALL (x) {
  LET recommended = x.score > 7
  RETURN x, recommended
}
RETURN x.title, recommended
```

Result:

| x.title | recommended |
| -- | -- |
| Optimizing Queries | true |
| Efficient Graph Search | false |
| Path Patterns | false |

This query references `p` in `LET` to compute the length of each path:

```gql
MATCH p = ()->{1,2}()
LET length = path_length(p)
RETURN p, length
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
<div align=center drawio-diagram='20308' drawio-name="draw_98b8404cc0c64921838de596f6748561.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_98b8404cc0c64921838de596f6748561.jpg?v='1737951249570'"/></div>
      </td>
      <td>1</td>
    </tr>
    <tr>
      <td>
<div align=center drawio-diagram='20309' drawio-name="draw_71dd69b3eae94aff83ddb7ec906e3a33.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_71dd69b3eae94aff83ddb7ec906e3a33.jpg?v='1737951235527'"/></div>
      </td>
      <td>1</td>
    </tr>
    <tr>
      <td>
<div align=center drawio-diagram='20310' drawio-name="draw_33de3817f7304428833fb618824728e5.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_33de3817f7304428833fb618824728e5.jpg?v='1737951207122'"/></div>
      </td>
      <td>2</td>
    </tr>
  </tbody>
</table>
