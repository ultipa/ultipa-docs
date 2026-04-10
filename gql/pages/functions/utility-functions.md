# Utility Functions

## Example Graph

<div align=center drawio-diagram='17191' drawio-name="draw_5fb3914b116b4a06ac12fbf6c9d30f68.jpg"><img src="https://img.ultipa.cn/draw/draw_5fb3914b116b4a06ac12fbf6c9d30f68.jpg?v='1733369467835'"/></div>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack'}),
       (p1)-[:Cites {weight:2}]->(p2),
       (p2)-[:Cites {weight:1}]->(p3)
```

## cardinality()

Returns the size of a path, list, or record.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>cardinality(&lt;expr&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;expr&gt;</code></td>
      <td><code>PATH</code>, <code>LIST</code>, <code>RECORD</code></td>
      <td>The input expression</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH p = ()->() LIMIT 1
RETURN cardinality(p)
```

Result: 3

```gql
LET myList = [1, 2, null, 3]
RETURN cardinality(myList)
```

Result: 4

```gql
RETURN cardinality({x: 1, y: 3, z: 34})
```

Result: 3

## typeof()

Returns the type name of a value as a string.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>typeof(&lt;expr&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;expr&gt;</code></td>
      <td>Any</td>
      <td>The input expression</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n:Paper) LIMIT 1
RETURN typeof(n.author)
```

Result: 

| typeof |
| -- | 
| STRING |

```gql
RETURN typeof(42), typeof("hello"), typeof([1,2,3])
```

Result: 

| typeof | typeof | typeof |
| -- | -- | -- |
| INTEGER | STRING | LIST<INTEGER> |

## all_different()

Returns `true` if all arguments are different graph elements (compared by `_id`).

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>all_different(&lt;elem1&gt;, &lt;elem2&gt; [, ...])</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;elem&gt;</code></td>
      <td><code>NODE</code>, <code>EDGE</code></td>
      <td>Two or more element variable references</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (a), (b), (c)
WHERE a._id = "P1" AND b._id = "P2" AND c._id = "P3"
RETURN all_different(a, b, c)
```

Result: true
