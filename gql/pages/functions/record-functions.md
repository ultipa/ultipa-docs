# Record Functions

## keys()

Returns a list of all field names in a record.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:30%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>keys(&lt;record&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;record&gt;</code></td>
      <td><code>RECORD</code></td>
      <td>The input record</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN keys({name: 'Alice', age: 30})
```

Result:

| keys({name: 'Alice', age: 30}) |
| -- |
| ["name","age"] |

## recordContains()

Returns `true` if the record contains the specified field.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:30%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>recordContains(&lt;record&gt;, &lt;key&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;record&gt;</code></td>
      <td><code>RECORD</code></td>
      <td>The input record</td>
    </tr>
    <tr>
      <td><code>&lt;key&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The field name to check</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN recordContains({name: 'Alice', age: 30}, 'name')
```

Result:

| recordContains({name: 'Alice', age: 30}, 'name') |
| -- |
| true |

## recordGet()

Returns the value of the specified field in a record.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:30%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>recordGet(&lt;record&gt;, &lt;key&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;record&gt;</code></td>
      <td><code>RECORD</code></td>
      <td>The input record</td>
    </tr>
    <tr>
      <td><code>&lt;key&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The field name to retrieve</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3">Type of the field value</td>
    </tr>
  </tbody>
</table>

```gql
RETURN recordGet({name: 'Alice', age: 30}, 'name')
```

Result:

| recordGet({name: 'Alice', age: 30}, 'name') |
| -- |
| Alice |

## recordRemove()

Returns a new record with the specified field removed.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:30%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>recordRemove(&lt;record&gt;, &lt;key&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;record&gt;</code></td>
      <td><code>RECORD</code></td>
      <td>The input record</td>
    </tr>
    <tr>
      <td><code>&lt;key&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The field name to remove</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>RECORD</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN recordRemove({name: 'Alice', age: 30}, 'age')
```

Result:

| recordRemove({name: 'Alice', age: 30}, 'age') |
| -- |
| {name: "Alice"} |

## recordSet()

Returns a new record with the specified field set to the given value.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:30%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>recordSet(&lt;record&gt;, &lt;key&gt;, &lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;record&gt;</code></td>
      <td><code>RECORD</code></td>
      <td>The input record</td>
    </tr>
    <tr>
      <td><code>&lt;key&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The field name to set</td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Any</td>
      <td>The value to assign to the field</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>RECORD</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN recordSet({name: 'Alice'}, 'age', 30)
```

Result:

| recordSet({name: 'Alice'}, 'age', 30) |
| -- |
| {name: "Alice", age: 30} |
