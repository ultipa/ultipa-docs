# Null Functions

# Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='19687' drawio-name='draw_781448aac6eb4077b8597909eb08ddcb.jpg'><img src="https://img.ultipa.cn/draw/draw_781448aac6eb4077b8597909eb08ddcb.jpg?v='1733371729705'"/></div>

# coalesce()

Returns the first non-`null` value from a list of provided values. It returns `null` if all values are `null`.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:25%;">
    <col style="width:15%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>coalesce(&lt;value1&gt;, &lt;value2&gt;, ...)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;value1&gt;</code>,<br><code>&lt;value2&gt;</code>,<br>...</td>
      <td>Any</td>
      <td>The input values; at least two are required</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3">Any</td>
    </tr>
  </tbody>
</table>

```uql
find().nodes() as n
with coalesce(n.score, "N/A") as score
return table(n.title, score)
```

Result:

| n.title | score |
| -- | -- |
| Optimizing Queries | 9 |
| Efficient Graph Search | 6 |
| Path Patterns | N/A |
