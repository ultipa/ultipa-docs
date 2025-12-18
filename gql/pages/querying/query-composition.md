# Querying

## Query Composition

A GQL query is composed of multiple **statements**. Each statement is a unit that can be executed by the database. A typical GQL query begins with a `MATCH` statement to retrieve data from the graph, and ends with a `RETURN` statement to output results to the client.

A **clause** is a component of a statement that performs a specific function, such as `WHERE` for filtering. A clause on its own is not a complete instruction, but must be part of a statement.

GQL supports the following statement for querying the database:

| <div table-width="15">Statement</div> | Description | <div table-width="18">Supported Clauses</div> |
| -- | -- | -- |
| <a href="/docs/gql/match">MATCH</a> | Retrieves nodes, edges, and paths from the graph using <a target="_blank" href="/docs/gql/graph-pattern-matching">patterns</a>. | `WHERE`, `YIELD` |
| <a href="/docs/gql/filter">FILTER</a> | Discards records in the intermediate result table that do not satisfy the specified conditions. |
| <a href="/docs/gql/let">LET</a> | Defines variables and adds corresponding columns to the intermediate result table. |
| <a href="/docs/gql/for">FOR</a> | Unnests a list into individual rows. |
| <a href="/docs/gql/order-by">ORDER BY</a> | Sorts records in the intermediate result or output table. |
| <a href="/docs/gql/limit">LIMIT</a> | Restricts the number of records to be retained in the intermediate result or output table. |
| <a href="/docs/gql/skip">SKIP</a> | Discards a specified number of records from the beginning of the intermediate result or output table. |
| <a href="/docs/gql/call">CALL</a> | Invokes an inline procedure or named procedure. | `YIELD` |
| <a href="/docs/gql/return">RETURN</a> | Specifies the columns to include in the output table. | `GROUP BY` |

## Linear Query

A **linear query** executes sequentially, where each statement is processed one after another without any branching or conditional logic. The result is returned in a straightforward progression.

Every linear query must conclude with a result statement, which can be one of the following:

- `RETURN ...`
- `RETURN ... ORDER BY ...`
- `RETURN ... ORDER BY ... SKIP ...`
- `RETURN ... ORDER BY ... LIMIT ...`
- `RETURN ... ORDER BY ... SKIP ... LIMIT ...`
- `RETURN ... SKIP...`
- `RETURN ... SKIP ... LIMIT ...`
- `RETURN ... LIMIT ...`

The `RETURN` is mandatory. Optional result modifiers - `ORDER BY`, `SKIP`, and `LIMIT` - may follow `RETURN`; however, only the combinations listed above are valid. Unsupported combinations—such as `RETURN ... LIMIT ... SKIP ...` are not permitted.

For example, this is a linear query where the `MATCH`, `FILTER` and `RETURN` statements processed in a linear order:

```gql
MATCH (:User {_id: "U01"})-[:Follows]->(u:User)
FILTER u.city = "New York"
RETURN u
```

## Composite Query

A **composite query** combines the result sets of multiple linear queries with query conjunctions (`UNION`, `EXCEPT`, `INTERSECT`, and `OTHERWISE`).

For example, this is a composite query that uses `UNION ALL` to combine the result sets of two linear queries:

```gql
MATCH (n:Club) RETURN n
UNION
MATCH (n:User) RETURN n
```

<a href="/docs/gql/composite-query">Learn more about composite query →</a>

## Advanced Linear Composition with NEXT

The `NEXT` statement chains multiple linear or composite query statements, enabling more complex queries.

<a href="/docs/gql/next">Learn more about NEXT →</a>
