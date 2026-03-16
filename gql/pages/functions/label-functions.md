# Label Functions

## labelContains()

Checks whether an entity has a specific label.

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
      <td colspan="3"><code>labelContains(&lt;element&gt;, &lt;label&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="3"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;element&gt;</code></td>
      <td><code>NODE</code>, <code>EDGE</code></td>
      <td>Element variable reference</td>
    </tr>
    <tr>
      <td><code>&lt;label&gt;</code></td>
      <td><code>STRING</code></td>
      <td>The label name to check</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n) WHERE labelContains(n, 'Person') RETURN n._id
```

## labelHasAny()

Checks whether an entity has at least one label.

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
      <td colspan="3"><code>labelHasAny(&lt;element&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;element&gt;</code></td>
      <td><code>NODE</code>, <code>EDGE</code></td>
      <td>Element variable reference</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>BOOL</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n) WHERE labelHasAny(n) RETURN n._id
```

## labels()

Returns a list of all labels on an entity.

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
      <td colspan="3"><code>labels(&lt;element&gt;)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;element&gt;</code></td>
      <td><code>NODE</code>, <code>EDGE</code></td>
      <td>Element variable reference</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>STRING</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n {_id: 'p3'}) RETURN labels(n)
```
