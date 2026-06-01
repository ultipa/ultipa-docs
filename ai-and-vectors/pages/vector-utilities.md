# Vector Utilities

Inspect, transform, and perform arithmetic operations on vectors, and manage vector indexes.

## Inspection

### ai.dimension()

Returns the number of dimensions in a vector.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.dimension(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>INT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.dimension(ai.vector([3.0, 4.0]))
```

Result: 2

### ai.magnitude()

Returns the magnitude (L2 norm) of a vector. `ai.norm()` is a synonym.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.magnitude(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>FLOAT</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.magnitude(ai.vector([3.0, 4.0]))
```

Result: 5

### ai.normalize()

Normalizes a vector to a unit vector (magnitude of 1).

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.normalize(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.normalize(ai.vector([3.0, 4.0]))
```

Result:

```json
{
  "values": [
    0.6000000238418579,
    0.800000011920929
  ]
}
```

### ai.toList()

Converts a vector to a list of numbers.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.toList(&lt;vector&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>LIST</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.toList(ai.embed("Introduction to graph databases"))
```

Result: [-0.0258026123046875, -0.0126800537109375, …, 0.0162200927734375, -0.017486572265625]

## Vector Arithmetic

### ai.add()

Adds two vectors element-wise.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.add(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.toList(ai.add(ai.vector([1.0, 2.0]), ai.vector([3.0, 4.0])))
```

Result: [4, 6]

### ai.subtract()

Subtracts the second vector from the first element-wise.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.subtract(&lt;vector1&gt;, &lt;vector2&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector1&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The first vector</td>
    </tr>
    <tr>
      <td><code>&lt;vector2&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>The second vector; must have the same dimension as <code>&lt;vector1&gt;</code></td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.toList(ai.subtract(ai.vector([5.0, 3.0]), ai.vector([1.0, 2.0])))
```

Result: [4, 1]

### ai.scale()

Multiplies a vector by a scalar value.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.scale(&lt;vector&gt;, &lt;scalar&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;vector&gt;</code></td>
      <td><code>VECTOR</code></td>
      <td>A vector value</td>
    </tr>
    <tr>
      <td><code>&lt;scalar&gt;</code></td>
      <td>Numeric</td>
      <td>The scalar multiplier</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>VECTOR</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.toList(ai.scale(ai.vector([1.0, 2.0, 3.0]), 2))
```

Result: [2, 4, 6]

## Vector Index Management

### ai.rebuild_index()

Rebuilds an HNSW vector index from the underlying data. Use this to recover a `STALE` index (e.g., after a crash) or to apply new `m`/`efConstruction` parameters.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.rebuild_index(&lt;indexName&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;indexName&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The name of the vector index to rebuild</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.rebuild_index('summary_embedding')
```

### ai.set_index_option()

Updates a runtime-mutable vector index option. Currently only `efSearch` can be changed at runtime; changing `m` or `efConstruction` requires a rebuild.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:15%;">
    <col style="width:17%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>ai.set_index_option(&lt;indexName&gt;, &lt;key&gt;, &lt;value&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="4"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;indexName&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The name of the vector index</td>
    </tr>
    <tr>
      <td><code>&lt;key&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The option to set (e.g., <code>"efSearch"</code>)</td>
    </tr>
    <tr>
      <td><code>&lt;value&gt;</code></td>
      <td>Numeric</td>
      <td>The new value</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
RETURN ai.set_index_option('summary_embedding', 'efSearch', 200)
```