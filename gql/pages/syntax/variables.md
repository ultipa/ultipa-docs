# Variables

A variable is a unique name (identifier) assigned to represent a collection of records. Variables allow users to reference these data throughout a query, enabling data retrieval, manipulation, and further operations.

## Graph Pattern Variables

Graph pattern variables include:

- <a target="_blank" href="/docs/gql/node-and-edge-patterns#Element-Variable-Declaration">Element Variable</a>: Includes Node Variable and Edge Variable.
- <a target="_blank" href="/docs/gql/path-patterns#Path-Variable-Declaration">Path Variable</a>

These variables can be declared at specific places within path patterns, allowing them to be bound to nodes, edges, or paths that match the pattern.

In this query, `n` is a node variable bound to a list of nodes, `e` is an edge variable bound to a list of edges, `p` is a path variable that holds a path binding:

```gql
MATCH p = (:User {_id: "U01"})<-[e:Follows]-(n:User)
RETURN n, e, p
```

## LET Variable Definition

The <a target="_blank" href="/docs/gql/let">`LET` statement</a> allows you to define variables which effectively adds columns to the intermediate result table.

```gql
LET i = 2
RETURN i + 1
```

## Unreferenced Variables

It is generally a good practice to remove any unreferenced variables from the query. For example,

```gql
MATCH (a)-[e]->(b)
RETURN e
```

If you don't need to reference the nodes bound to `a` and `b`, you can rewrite the query as:

```gql
MATCH ()-[e]->()
RETURN e
```

Unreferenced variables do not cause syntax errors but can lead to inefficiencies and reduced readability. It is best to avoid declaring variables you do not intend to use.