# Count Query Expression

The count query expression derives a single integer—the number of rows returned by a nested query specification.

```syntax
<count query expression> ::= "COUNT {" <query> "}"
```

**Details**

- The `<query>` is executed as a complete query, and `COUNT { ... }` returns the number of rows it produces. The body must therefore end with a `RETURN`.
- Because the count is over returned rows, the `RETURN` should project the matched rows (e.g. `RETURN c`), not an aggregate. A body like `RETURN count(c)` produces a single row, so `COUNT { ... }` would always return `1`.

> **Non-standard extension.** `COUNT { ... }` is not part of the GQL standard (ISO/IEC 39075). GQLDB accepts it for convenience, but queries using it run with an advisory warning. Prefer the standard <a target="_blank" href="/docs/gql/value-query-expression">Value Query Expression</a> in new queries.

## Example Graph

<center><img src="images/value-query-expression-example.jpg"/></center>

```gql
INSERT (p1:Paper {_id:'P1', title:'Efficient Graph Search', score:6}),
       (p2:Paper {_id:'P2', title:'Optimizing Queries', score:9}),
       (p3:Paper {_id:'P3', title:'Path Patterns', score:7}),
       (p1)-[:Cites]->(p2),
       (p2)-[:Cites]->(p3)
```

## Examples

Count the papers each paper cites:

```gql
MATCH (p:Paper)
LET citations = COUNT { MATCH (p)-[:Cites]->(c:Paper) RETURN c }
RETURN p.title, citations
```

Result:

| p.title | citations |
| -- | -- |
| Efficient Graph Search | 1 |
| Optimizing Queries | 1 |
| Path Patterns | 0 |

The standard equivalent, which does not emit a warning:

```gql
MATCH (p:Paper)
LET citations = VALUE { MATCH (p)-[:Cites]->(c:Paper) RETURN count(c) }
RETURN p.title, citations
```
