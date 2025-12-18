# List Functions

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='17191' drawio-name="draw_5fb3914b116b4a06ac12fbf6c9d30f68.jpg"><img src="https://img.ultipa.cn/draw/draw_5fb3914b116b4a06ac12fbf6c9d30f68.jpg?v='1733369467835'"/></div>

## append()

Adds an element to the end of a list and returns the new list. 

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:18%;">
    <col style="width:18%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>append(&lt;list&gt;, &lt;elem&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The target list</td>
    </tr>
    <tr>
      <td><code>&lt;elem&gt;</code></td>
      <td>Any</td>
      <td>The element to be added</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
LET myList = ["a", 1, 2]
RETURN append(myList, "b")
```

Result: 

| append(myList, "b") |
| -- |
| ["a",1,2,"b"] |

## difference()

Returns the difference between two lists, producing a new list of elements found in the first input list but not in the second. Duplicates are included.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>difference(&lt;list_1&gt;, &lt;list_2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list_1&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The first list</td>
    </tr>
    <tr>
      <td><code>&lt;list_2&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The second list</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
LET l1 = [1,2,2,3], l2 = [3,4,5]
RETURN difference(l1, l2)
```

Result: 

| difference(l1, l2) |
| -- |
| [1,2,2] |

## elements()

Returns a list containing the nodes and edges that make up a path.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:30%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>elements(&lt;path&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;path&gt;</code></td>
      <td><code>PATH</code></td>
      <td>The target path</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH p = ()->()
LET items = elements(p)
FOR item IN items WITH ORDINALITY index
FILTER index %2 = 1
RETURN item
```

Result: `item`

| <div table-width="5">_id</div> | \_uuid | schema | <div table-width="60">values</div> |
| -- | -- | -- | -- |
| P2 | <span style="color: #999;">Sys-gen</span> | Course | {title: "Optimizing Queries", author: "Alex", score: 9} |
| P3 | <span style="color: #999;">Sys-gen</span> | Course | {title: "Path Patterns", author: "Zack", score: 7} |
| P1 | <span style="color: #999;">Sys-gen</span> | Course | {title: "Efficient Graph Search", author: "Alex", score: 6} |
| P2 | <span style="color: #999;">Sys-gen</span> | Course | {title: "Optimizing Queries", author: "Alex", score: 9} |

## head()

Returns the first element in a list.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>head(&lt;list&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The target list</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
LET myList = ["a", 1, 2]
RETURN head(myList)
```

Result: 

| head(myList) |
| -- |
| a |

## intersection()

Returns the intersection of two lists, producing a new list of elements common to both. Duplicates are included.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>intersection(&lt;list_1&gt;, &lt;list_2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list_1&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The first list</td>
    </tr>
    <tr>
      <td><code>&lt;list_2&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The second list</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
LET l1 = [1,2,3,3], l2 = [3,3,4,5]
RETURN intersection(l1, l2)
```

Result: 

| intersection(l1, l2) |
| -- |
| [3,3] |

## listContains()

Checks whether a specified element exists in a list, returning `1` for true and `0` for false. 

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:50%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>listContains(&lt;list&gt;, &lt;elem&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The list to be checked</td>
    </tr>
    <tr>
      <td><code>&lt;elem&gt;</code></td>
      <td>Any</td>
      <td>The element to look for in <code>&lt;list&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return</b></td>
      <td colspan="3"><code>1</code> or <code>0</code></td>
    </tr>
  </tbody>
</table>

```gql
LET myList = ["a", 1, 2]
RETURN listContains(myList, "b")
```

Result: 

| listContains(myList, "b") |
| -- |
| 0 |

## listUnion()

Returns the union of two lists, producing a new list of elements from either input list. Duplicates are removed.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>listUnion(&lt;list_1&gt;, &lt;list_2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list_1&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The first list</td>
    </tr>
    <tr>
      <td><code>&lt;list_2&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The second list</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
LET l1 = [1,2,2,3], l2 = [3,4,5]
RETURN listUnion(l1, l2)
```

Result: 

| listUnion(l1, l2) |
| -- |
| [1,2,3,4,5] |

## reduce()

Performs a calculation iteratively using  each element in a list. With a specified intital value, the defined calculation takes the first element in the list as input.  

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col>
    <col style="width:50%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>reduce(&lt;resAlias&gt; = &lt;initVal&gt;, &lt;elemAlias&gt; in &lt;list&gt; | &lt;calcExp&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="6"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;resAlias&gt;</code></td>
      <td>/</td>
      <td>The alias representing the initial, intermediate and final calculation result</td>
    </tr>
    <tr>
      <td><code>&lt;initVal&gt;</code></td>
      <td>/</td>
      <td>The initial value assigned to <code>&lt;resAlias&gt;</code></td>
    </tr>
    <tr>
      <td><code>&lt;elemAlias&gt;</code></td>
      <td>/</td>
      <td>The alias representing each element in the list</td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The target list</td>
    </tr>
        <tr>
      <td><code>&lt;calcExp&gt;</code></td>
      <td>/</td>
      <td>The calculation expression</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
LET myList = [1,3,5]
RETURN reduce(_sum = 0, item in myList | _sum + item) AS listSum
```

Result: 

| listSum |
| -- |
| 9 |

```gql
MATCH p = ({_id: "P1"})-[edges]->{2}()
RETURN reduce(total = 0, edge in edges | total + edge.weight) as totalWeights
```

Result: 

| totalWeights |
| -- |
| 3 |

## size()

Returns the number of elements in a list.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:30%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>size(&lt;list&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The target list</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>UINT</code></td>
    </tr>
  </tbody>
</table>

```gql
LET myList = [1, 2, null, 3]
RETURN size(myList)
```

Result: 

| size(myList) |
| -- |
| 4 |

## trim()

Removes a specified number of elements from the right end of the list.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col>
    <col>
    <col style="width:55%;">
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>trim(&lt;list&gt;, &lt;num&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The list to be trimmed</td>
    </tr>
    <tr>
      <td><code>&lt;num&gt;</code></td>
      <td><code>UINT</code></td>
      <td>An integer specifying the number of elements to be removed from the list</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
LET myList = [1, 2, null, 3]
RETURN trim(myList, 2)
```

Result: 

| TRIM(myList, 2) |
| -- |
| [1,2] |
