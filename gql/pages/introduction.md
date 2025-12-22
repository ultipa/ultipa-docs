# Introduction

**GQL** (Graph Query Language) is a database language designed for modeling, querying and modifying data in graph database.

As the first standardized database language since SQL's introduction in 1987, GQL marks a major milestone in data management. The first version of the GQL standard was officially released by the ISO/IEC in April 2024. See Ultipa's <a target="_blank" href="/docs/gql/gql-conformance">GQL Conformance</a>.

To get started with GQL, check out our <a target="_blank" href="/docs/quick-start/what-is-gql">Quick Start</a>. You can also explore and practice GQL for free in our <a target="_blank" href="/gql-playground">GQL Playground</a>.

## GQL Execution Context

While administrative GQL statements affect the database overall, most GQL queries apply to a specific graph in the database. A database may contain multiple graphs, and you need to explicitly select the graph before executing a GQL query.

## Transactions and ACID Compliance

Ultipa is ACID compliant, which means:

- **Atomicity:** Each transaction is executed as a single unit of work. Either all its operations succeed, or none do.
- **Consistency:** A transaction must bring the database from one valid state to another.
- **Isolation:** Multiple transactions executing simultaneously must not affect one another.
- **Durability:** Once a transaction is committed, its results are permanently recorded and remain intact even in the event of a system failure.
