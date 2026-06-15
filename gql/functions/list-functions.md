# List Functions

## Example Graph

<center><img src="images/paper-example.jpg"/></center>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack'}),
       (p1)-[:Cites {weight:2}]->(p2),
       (p2)-[:Cites {weight:1}]->(p3)
```

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

Result: "a"

## last()

Returns the last element of a list.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>last(&lt;list&gt;)</code></td>
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
      <td>The input list</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3">Type of the last element</td>
    </tr>
  </tbody>
</table>

```gql
RETURN last([1, 2, 3])
```

Result: 3

## tail()

Returns all elements of a list except the first.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>tail(&lt;list&gt;)</code></td>
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
      <td>The input list</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN tail([1, 2, 3, 4])
```

Result: [2, 3, 4]

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

## reverse()

Returns a list with elements in reversed order.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>reverse(&lt;list&gt;)</code></td>
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
      <td>The input list</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN reverse([1, 2, 3])
```

Result: [3, 2, 1]

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

Result: ["a",1,2,"b"]

## range()

Generates a list of integers from `start` to `end` (inclusive), with an optional `step`.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>range(&lt;start&gt;, &lt;end&gt; [, &lt;step&gt;])</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;start&gt;</code></td>
      <td><code>INT</code></td>
      <td>Start value (inclusive)</td>
    </tr>
    <tr>
      <td><code>&lt;end&gt;</code></td>
      <td><code>INT</code></td>
      <td>End value (inclusive)</td>
    </tr>
    <tr>
      <td><code>&lt;step&gt;</code></td>
      <td><code>INT</code></td>
      <td>Step increment (default: 1)</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST&lt;INT&gt;</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN range(1, 5), range(0, 10, 3)
```

Result: [1, 2, 3, 4, 5], [0, 3, 6, 9]

## list_contains()

Returns `true` if a value exists in a specified list.

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
      <td colspan="3"><code>list_contains(&lt;list&gt;, &lt;value&gt;)</code></td>
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
      <td><code>&lt;value&gt;</code></td>
      <td>Any</td>
      <td>The value to look for in <code>&lt;list&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return</b></td>
      <td colspan="3"><code>1</code> or <code>0</code></td>
    </tr>
  </tbody>
</table>

```gql
LET myList = ["a", 1, 2]
RETURN list_contains(myList, "b")
```

Result: false

## list_union()

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
      <td colspan="3"><code>list_union(&lt;list_1&gt;, &lt;list_2&gt;)</code></td>
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
RETURN list_union(l1, l2)
```

Result: [1,2,3,4,5]

## intersection()

Returns the intersection of two lists, producing a new list of elements common to both. Duplicates are removed.

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

Result: [3]

## difference()

Returns the difference between two lists, producing a new list of elements found in the first list but not in the second. Duplicates are removed.

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

Result: [1,2]

## list_sort()

Sorts a list.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>list_sort(&lt;list&gt; [, &lt;order&gt; [, &lt;nullOrder&gt;]])</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>The input list</td>
    </tr>
    <tr>
      <td><code>&lt;order&gt;</code></td>
      <td><code>STRING</code></td>
      <td>"asc" (default) or "desc"</td>
    </tr>
    <tr>
      <td><code>&lt;nullOrder&gt;</code></td>
      <td><code>STRING</code></td>
      <td>"first" or "last"</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN list_sort([3, 1, 4, 1, 5])
```

Result: [1, 1, 3, 4, 5]

## list_filter()

Filters a list of records, nodes, or edges by checking a property against a value using an operator.

<table style="width: 100%;">
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>list_filter(&lt;list&gt;, &lt;propertyName&gt;, &lt;operator&gt;, &lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="5"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;list&gt;</code></td>
      <td><code>LIST</code></td>
      <td>A list of maps, nodes, or edges</td>
    </tr>
    <tr>
      <td><code>&lt;propertyName&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The property name to filter on</td>
    </tr>
    <tr>
      <td><code>&lt;operator&gt;</code></td>
      <td><code>STRING</code></td>
      <td>Comparison operator: `"="`, `">"`, `"<"`, `">="`, `"<="`, `"<>"`</td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Any</td>
      <td>The value to compare against</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
LET papers = VALUE { MATCH (n:Paper) RETURN collect_list(n) }
RETURN list_filter(papers, "score", ">", 7)
```

Result:

```json
[
  {"id": "P2", "labels": ["Paper"], "properties": {"title": "Optimizing Queries", "score": 9, "author": "Alex"}}
]
```

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

Result: 9

```gql
MATCH p = ({_id: "P1"})-[edges]->{2}()
RETURN reduce(total = 0, edge in edges | total + edge.weight)
```

Result: 3

