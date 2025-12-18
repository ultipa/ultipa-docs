# Result Table and Visualization

Even though GQL operates on graphs, its results are still logically represented as tables composed of records (rows).

## Intermediate Result Table

The intermediate result table is a conceptual model to understand how queries are processed.

Here is the example graph and query:

<div align=center drawio-diagram='25643' drawio-name="draw_a08c0407baa0426b840f458d61b271d7.jpg"><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/draw/draw_a08c0407baa0426b840f458d61b271d7.jpg?v='1751249910591'"/></div>

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
    <td>The intermediate table contains one column (variable) <code>u</code> with three records (rows).
      <table>
        <thead>
          <tr>
            <th><code>u</code></th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>(:User {_id: "U1", name: "mochaeach", age: 31})</td>
          </tr>
          <tr>
            <td>(:User {_id: "U2", name: "purplechalk", age: 45})</td>
          </tr>
          <tr>
            <td>(:User {_id: "U3", name: "Brainy", age: 36})</td>
          </tr>
        </tbody>
      </table>
    </td>
  </tr>
  <tr>
    <td><code>MATCH (u)->(c:Club)</code></td>
    <td>The statement evaluates <code>u</code> row by row and adds a new column <code>c</code> to the intermediate result table:<ul><li>If a record of <code>u</code> yields no result, that record is discarded.</li><li>If it yields a single result, that value is added to column <code>c</code>.</li><li>If it yields multiple results, the record of <code>v</code> is duplicated for each result, and each corresponding <code>c</code> record is added.</li></ul>
      <table>
        <thead>
          <tr>
            <th><code>u</code></th>
            <th><code>c</code></th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>(:User {_id: "U1", name: "mochaeach", age: 31})</td>
            <td>(:Club {_id: "C1", since: 2002})</td>
          </tr>
          <tr>
            <td>(:User {_id: "U2", name: "purplechalk", age: 31})</td>
            <td>(:Club {_id: "C1", since: 2002})</td>
          </tr>
          <tr>
            <td>(:User {_id: "U2", name: "purplechalk", age: 31}</td>
            <td>(:Club {_id: "C3", since: 2011})</td>
          </tr>
        </tbody>
      </table>
    </td>
  </tr>
  <tr>
    <td><code>FILTER c.since > 2010</code></td>
    <td>The statement evaluates <code>c</code> row by row and discards records that don't meet the filtering condition.
      <table>
        <thead>
          <tr>
            <th><code>u</code></th>
            <th><code>c</code></th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>(:User {_id: "U2", name: "purplechalk", age: 31}</td>
            <td>(:Club {_id: "C3", since: 2011})</td>
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
    <td>The <code>RETURN</code> statement defines the output table.
      <table>
        <thead>
          <tr>
            <th><code>u.name</code></th>
            <th><code>c._id</code></th>
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

| `u.name` | `c._id` |
| -- | -- |
| Jody | C1 | 
| purplechalk | C1 |
| mochaeach | C1 |
| Brainy | C1 |
| Jody | C3 |
| purplechalk | C3 |
| mochaeach | C3| 
| Brainy | C3 |
| Jody | C2 |
| purplechalk | C2 |
| mochaeach | C2 |
| Brainy | C2 |

While this is a small example, in a real-world graph with large datasets, Cartesian products can lead to huge result sets, consuming significant memory and degrading performance. Therefore, avoid Cartesian products unless they are explicitly intended.

## Result Visualization

While GQL results can be returned in tabular format, one of the defining features of graph databases is the ability to visualize results as graph structures, making it easier for users to see and explore the relationships within their data.

When running GQL queries in Ultipa products such as <a target="_blank" href="/docs/manager-user-guide">Ultipa Manager</a> and <a target="_blank" href="https://www.ultipa.com/gql-playground">GQL Playground</a>, query results of nodes and paths can be rendered in **graph view**, offering an intuitive and interactive way to navigate the result graph.

<center><img src="https://www-test-data.oss-cn-hangzhou.aliyuncs.com/img/2025-06-30-12-23-11-result-visualization.jpg"><span style="color:#999;">Result Visualization in Ultipa Manager</span></center>
