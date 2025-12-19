# List Functions

## append()

Appends an element to the end of the list and returns the updated list.

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

```uql
with ["a", 1, 2] as myList
return append(myList, "b")
```

Result:

| append(myList, "b") |
| -- |
| ["a",1,2,"b"] |

## difference()

Returns the difference between two lists, generating a new list of elements found in the first list but not in the second. Duplicates are preserved.

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

```uql
with [1,2,2,3] as l1, [3,4,5] as l2
return difference(l1, l2)
```

Result:

| difference(l1, l2) |
| -- |
| [1,2,2] |

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

```uql
with ["a", 1, 2] as myList
return head(myList)
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

```uql
with [1,2,3,3] as l1, [3,3,4,5] as l2
return intersection(l1, l2)
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

```uql
with ["a", 1, 2] as myList
return listContains(myList, "b")
```

Result:

| listContains(myList, "b") |
| -- |
| 0 |

## listUnion()

Returns the union of two lists as a new list containing elements from either input. Duplicates are removed.

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

```uql
with [1,2,2,3] as l1, [3,4,5] as l2
return listUnion(l1, l2)
```

Result:

| listUnion(l1, l2) |
| -- |
| [1,2,3,4,5] |

## reduce()

Performs a calculation iteratively using  each element in a list. With a specified initial value, the defined calculation takes the first element of the list as input.

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

```uql
with [1,3,5] as myList
return reduce(_sum = 0, item in myList | _sum + item) AS listSum
```

Result:

| listSum |
| -- |
| 9 |

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

```uql
with [1, 2, null, 3] as myList
return size(myList)
```

Result:

| size(myList) |
| -- |
| 4 |
