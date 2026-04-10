# Result Table and Visualization

Even though GQL operates on graphs, its results are still logically represented as tables composed of rows.

## Intermediate Result Table

The intermediate result table is a conceptual model to understand how queries are processed.

Example graph:

<div align=center drawio-diagram='25643' drawio-name="draw_a08c0407baa0426b840f458d61b271d7.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_a08c0407baa0426b840f458d61b271d7.jpg?v='1751249910591'"/></div>

```gql
INSERT (mochaeach:User {_id: 'U1', name: 'mochaeach', age: 31}),
       (purplechalk:User {_id: 'U2', name: 'purplechalk', age: 45}),
       (brainy:User {_id: 'U3', name: 'Brainy', age: 36}),
       (jody:User {_id: 'U4', name: 'Jody', age: 29}),
       (c1:Club {_id: 'C1', since: 2002}),
       (c2:Club {_id: 'C2', since: 2020}),
       (c3:Club {_id: 'C3', since: 2011}),
       (purplechalk)-[:Follows]->(mochaeach),
       (purplechalk)-[:Follows]->(brainy),
       (jody)-[:Follows]->(brainy),
       (mochaeach)-[:Joins]->(c1),
       (purplechalk)-[:Joins]->(c1),
       (purplechalk)-[:Joins]->(c3),
       (jody)-[:Joins]->(c2)
```

Example query:

```gql
MATCH (u:User) WHERE u.age > 30
MATCH (u)->(c:Club)
FILTER c.since > 2010
RETURN u.name, c._id
```

<table>
<thead>
  <tr>
    <th style="width:25%">Statement</th>
    <th>Intermediate Result Table</th>
  </tr>
</thead>
<tbody style="background: #fff;">
  <tr>
    <td><code>MATCH (u:User)</code><br><code>WHERE u.age > 30</code></td>
    <td>The intermediate table contains one column (variable) <code>u</code> with three rows.<br><br>
      <table>
        <thead>
          <tr>
            <th>u</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><pre>{
  "id": "U1",
  "labels": ["User"],
  "properties": {"name": "mochaeach", "age": 31}
}</pre></td>
          </tr>
          <tr>
            <td><pre>{
  "id": "U2",
  "labels": ["User"],
  "properties": {"name": "purplechalk", "age": 45}
}</pre></td>
          </tr>
          <tr>
            <td><pre>{
  "id": "U3",
  "labels": ["User"],
  "properties": {"name": "Brainy", "age": 36}
}</pre></td>
          </tr>
        </tbody>
      </table>
    </td>
  </tr>
  <tr>
    <td><code>MATCH (u)->(c:Club)</code></td>
    <td>The statement evaluates <code>u</code> row by row and adds a new column <code>c</code> to the intermediate result table:<ul><li>If a record of <code>u</code> yields no result, that record is discarded.</li><li>If it yields a single result, that value is added to column <code>c</code>.</li><li>If it yields multiple results, the record of <code>u</code> is duplicated for each result, and each corresponding <code>c</code> record is added.</li></ul>
      <table>
        <thead>
          <tr>
            <th>u</th>
            <th>c</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><pre>{
  "id": "U1",
  "labels": ["User"],
  "properties": {"name": "mochaeach", "age": 31}
}</pre></td>
            <td><pre>{
  "id": "C1",
  "labels": ["Club"],
  "properties": {"since": 2002}
}</pre></td>
          </tr>
          <tr>
            <td><pre>{
  "id": "U2",
  "labels": ["User"],
  "properties": {"name": "purplechalk", "age": 45}
}</pre></td>
            <td><pre>{
  "id": "C1",
  "labels": ["Club"],
  "properties": {"since": 2002}
}</pre></td>
          </tr>
          <tr>
            <td><pre>{
  "id": "U2",
  "labels": ["User"],
  "properties": {"name": "purplechalk", "age": 45}
}</pre></td>
            <td><pre>{
  "id": "C3",
  "labels": ["Club"],
  "properties": {"since": 2011}
}</pre></td>
          </tr>
        </tbody>
      </table>
    </td>
  </tr>
  <tr>
    <td><code>FILTER c.since > 2010</code></td>
    <td>The statement evaluates <code>c</code> row by row and discards records that don't meet the filtering condition.<br><br>
      <table>
        <thead>
          <tr>
            <th>u</th>
            <th>c</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><pre>{
  "id": "U2",
  "labels": ["User"],
  "properties": {"name": "purplechalk", "age": 45}
}</pre></td>
            <td><pre>{
  "id": "C3",
  "labels": ["Club"],
  "properties": {"since": 2011}
}</pre></td>
          </tr>
        </tbody>
      </table>
    </td>
  </tr>
  <tr style="background-color: #edf2f8;">
    <td><b>Statement</b></td>
    <td><b>Output Table</b></td>
  </tr>
  <tr>
    <td><code>RETURN u.name, c._id</code></td>
    <td>The <code>RETURN</code> statement defines the output table.<br><br>
      <table>
        <thead>
          <tr>
            <th>u.name</th>
            <th>c._id</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>purplechalk</td>
            <td>C3</td>
          </tr>
        </tbody>
      </table>
    </td>
  </tr>
</tbody>
</table>

This example is a linear query, where statements are executed sequentially. In composite queries, each linear query is executed independently and produces its own output table. These output tables are then combined using the specified conjunction method.

## Order of Rows

Without an explicit use of `ORDER BY`, Ultipa is free to return the result rows in any order — and that order may:

- Vary between query runs
- Change after database updates
- Differ across Ultipa versions

## Cartesian Product in Queries

A Cartesian product occurs in GQL when query parts have **no shared variables** or **explicit connections** between them. In such cases, all combinations of the result rows from each part are returned.

Consider the example:

```gql
MATCH (u:User)
MATCH (c:Club)
RETURN u.name, c._id
```

There are 4 `User` nodes and 3 `Club` nodes. Since there’s no relationship between `u` and `c`, the query produces a Cartesian product, yielding `4*3 = 12` records:

| u.name | c._id |
| -- | -- |
| mochaeach | C2 |
| mochaeach | C3 |
| mochaeach | C1 |
| purplechalk | C2 |
| purplechalk | C3 |
| purplechalk | C1 |
| Brainy | C2 |
| Brainy | C3 |
| Brainy | C1 |
| Jody | C2 |
| Jody | C3 |
| Jody | C1 |

While this is a small example, in a real-world graph with large datasets, Cartesian products can lead to huge result sets, consuming significant memory and degrading performance. Therefore, avoid Cartesian products unless they are explicitly intended.

## Result Visualization

While GQL results can be returned in tabular format, one of the defining features of graph databases is the ability to visualize results as graph structures, making it easier for users to see and explore the relationships within their data.

When running GQL queries in Ultipa products such as **Ultipa Manager** and <a target="_blank" href="https://gql.ultipa.com">GQL Playground</a>, query results of nodes and paths can be rendered in **graph view**, offering an intuitive and interactive way to navigate the result graph.

<div align=center><img src="images/result visualization.png"/><span style="color:#999;">Result Visualization in Ultipa Manager</span></div>