# Table Functions

## Example Graph

The following examples run against this graph:

<div align=center drawio-diagram='21358' drawio-name='draw_28424c8ce51340aaac7248ce592e57d5.jpg'><img src="https://img.ultipa.cn/draw/draw_28424c8ce51340aaac7248ce592e57d5.jpg?v='1740038097443'"/></div>

## table()

Constructs a table in the `RETURN` statement.

<table style="width: 100%;">
  <colgroup>
    <col style="width:20%;">
    <col style="width:20%;">
    <col style="width:25%;">
    <col>
  </colgroup>
  <tbody>
    <tr>
      <td><b>Syntax</b></td>
      <td colspan="3"><code>table(&lt;column1&gt;, &lt;column2&gt;, ...)</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;column1&gt;</code>,<br><code>&lt;column2&gt;</code>,<br>...</td>
      <td>Any type</td>
      <td>Columns in the table</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>RESULT_TYPE_TABLE</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n)-[e]->()
RETURN table(n, n.title, e, e.weight AS weight) 
```

Result: 

| n | <div table-width="30">n.title</div> | e | weight |
| -- | -- | -- | -- |
| <span style="color:#999;">UUID of node</span> | Optimizing Queries | <span style="color:#999;">UUID of edge</span> | 1 |
| <span style="color:#999;">UUID of node</span> | Efficient Graph Search | <span style="color:#999;">UUID of edge</span> | 2 |