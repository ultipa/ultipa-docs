# Introduction

**GQL** (Graph Query Language) is a database language designed for modeling, querying and modifying data in graph databases.

As the first standardized database language since SQL's introduction in 1987, GQL marks a major milestone in data management. The first version of the GQL standard was officially released by the ISO/IEC in April 2024. See Ultipa's <a target="_blank" href="/docs/gql/gql-conformance">GQL Conformance</a>.

## Key Concepts

Before diving into GQL, understand these fundamental concepts:

**Nodes** (also called vertices)
- Represent entities in your data (people, products, places)
- Can have zero, one, or more labels that categorize them
- Can have properties (key-value pairs)

**Edges** (also called relationships)
- Connect nodes together
- Have a direction (from one node to another)
- Can have zero, one, or more labels that describe the relationship
- Can have properties (key-value pairs)

**Labels**
- Categorize nodes and edges (like `:Person`, `:KNOWS`, `:WORKS_AT`)
- Both nodes and edges can have multiple labels

**Properties**
- Key-value pairs attached to nodes or edges
- Store data like names, ages, dates, etc.

**Open Graphs**
- Flexible schema that allows any labels and properties
- Nodes and edges can be inserted without predefined types
- Suitable for exploratory data or rapid prototyping

**Closed Graphs**
- Strict schema with predefined node types and edge types
- All nodes and edges must conform to defined types
- Provides data validation and consistency

## GQL Execution Context

While administrative GQL statements affect the database overall, most GQL queries apply to a specific graph in the database. A database may contain multiple graphs, and you can explicitly select a graph as the current with the GQL query `USE <graphName>`.

## Transactions and ACID Compliance

Ultipa is ACID compliant, which means:

- **Atomicity:** Each transaction is executed as a single unit of work. Either all its operations succeed, or none do.
- **Consistency:** A transaction must bring the database from one valid state to another.
- **Isolation:** Multiple transactions executing simultaneously must not affect one another.
- **Durability:** Once a transaction is committed, its results are permanently recorded and remain intact even in the event of a system failure.
