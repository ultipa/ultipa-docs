# GQL vs Other Languages

This page compares GQL with other popular graph query languages to help you understand the differences and similarities.

## GQL vs Cypher

**Cypher** is a query language created by Neo4j. GQL (ISO/IEC 39075) is the international standard that drew inspiration from Cypher but is vendor-neutral and designed for interoperability.

### Syntax Comparison

| Feature | GQL | Cypher |
|---------|-----|--------|
| Create nodes | `INSERT` | `CREATE` |
| Directed edge | `()->()` | `()-->()` |
| Undirected edge | `()-()` | `()-()` |
| Variable-length path | `-{1,5}` | `*1..5` |
| Multi-label (AND) | `(:A&B)` | `(:A:B)` |
| Label OR | `(:A\|B)` | Not supported |
| Any label | `(:%)` | Not supported |
| Variable assignment | `LET x = ...` | `WITH ... AS x` |
| List iteration | `FOR x IN list` | `UNWIND list AS x` |
| Inline filter | `MATCH (n WHERE ...)` | Not supported |
| Standalone filter | `FILTER` | Not available |
| Query chaining | `NEXT` | `WITH` |
| Grouping | Explicit `GROUP BY` | Implicit |

### Example Comparison

**GQL:**

```gql
MATCH (c:Customer)-[:BUYS]->(p:Product)
RETURN c.firstName AS customer,
       sum(p.price) AS totalSpent,
       collect(p.name) AS productsBought
       GROUP BY customer
ORDER BY totalSpent DESC
```

**Cypher:**

```cypher
MATCH (c:Customer)-[:BUYS]->(p:Product)
WITH c.firstName AS customer,
     sum(p.price) AS totalSpent,
     collect(p.name) AS productsBought
RETURN customer,
       totalSpent,
       productsBought
ORDER BY totalSpent DESC
```

**GQL variable-length paths:**

```gql
MATCH (:Person {name: 'Alice'})-[:KNOWS]-{1,3}(b:Person)
RETURN b.name
```

**Cypher equivalent:**

```cypher
MATCH (:Person {name: 'Alice'})-[:KNOWS*1..3]->(b:Person)
RETURN b.name
```

## GQL vs GraphQL

Despite the similar names, **GQL** and **GraphQL** are fundamentally different:

| Aspect | GQL | GraphQL |
|--------|-----|---------|
| Purpose | Query language for graph databases | API query language |
| Data model | Property graph (nodes and edges) | Hierarchical/tree structure |
| Schema | Optional (open graphs) or required (closed graphs) | Always required |
| Operations | Pattern matching, traversal, mutations | Request specific fields from API |
| Execution | Runs directly on database | Runs on API server |
| Relationships | First-class citizens (edges) | Nested fields |
| Traversal | Native path patterns | Must be implemented in resolvers |

### Conceptual Difference

**GQL** is designed for querying graph databases where relationships (edges) are first-class citizens:

```gql
// Find friends of friends in GQL
MATCH (:Person {name: 'Alice'})-[:KNOWS]-{2}(fof:Person)
RETURN fof.name
```

**GraphQL** is designed for APIs where you request specific fields:

```graphql
# Request data from an API in GraphQL
query {
  person(name: "Alice") {
    friends {
      friends {
        name
      }
    }
  }
}
```