# Table Functions

## Example Graph

<center><img src="images/paper-example.jpg"/></center>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6, author:'Alex'}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9, author:'Alex'}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7, author:'Zack'}),
       (p1)-[:Cites {weight:2}]->(p2),
       (p2)-[:Cites {weight:1}]->(p3)
```

## table()

Constructs a table in the `RETURN` statement. Each argument becomes a column in the output table. Column names default to the expression text or can be set using `AS`.

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
      <td colspan="3"><code>table(&lt;column1&gt; [, &lt;column2&gt;, ...])</code></td>
    </tr>
    <tr>
      <td rowspan="2"><b>Arguments</b></td>
      <td><b>Name</b></td>
      <td><b>Type</b></td>
      <td><b>Description</b></td>
    </tr>
    <tr>
      <td><code>&lt;column&gt;</code></td>
      <td>Any</td>
      <td>One or more expressions as columns; use <code>AS</code> to set column names</td>
    </tr>
    <tr>
      <td><b>Return Type</b></td>
      <td colspan="3"><code>TABLE</code></td>
    </tr>
  </tbody>
</table>

```gql
MATCH (n:Paper)-[e:Cites]->()
RETURN table(n._id AS id, n.title, e.weight AS weight)
```

Result:

| id | n.title | weight |
| -- | -- | -- |
| P1 | Efficient Graph Search | 2 |
| P2 | Optimizing Queries | 1 |