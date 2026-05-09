# Naming Conventions

Names in Ultipa GQL for graphs, graph types, node/edge types, labels, properties, constraints, indexes, triggers, and variables share the same basic rules.

## Identifier Rules

- Use only English letters (`A-Z`, `a-z`), digits (`0-9`), and underscores (`_`).
- Must start with a letter. Names that start with `__` (two underscores) are reserved for system use; do not use them.
- Other characters (such as Chinese or accented letters) are not allowed.
- Do not use <a target="_blank" href="/docs/gql/reserved-words">reserved words</a>. For node/edge types, labels, properties, and constraints, you can wrap the name in backticks (for example, <code>\`match\`</code>) to bypass this restriction. Graph names and graph type names do **not** support backtick escaping — pick a different name.

## Per-Object Rules

Beyond the base rules, each kind of object has its own length limit and uniqueness scope:

| Object | Length | Uniqueness |
| -- | -- | -- |
| Graph | Up to 127 characters | Unique within the database |
| Graph Type | Up to 127 characters | Unique within the database |
| Node/Edge Type | — | Unique among node/edge types in the same graph; a node type and an edge type can share the same name |
| Label | — | — |
| Property | — | Unique within each node type or edge type (in closed graphs) |
| Constraint | — | Unique within the graph |
| Index | — | Unique within the graph |
| Trigger | — | Unique within the graph |

## Backtick Escaping

Backticks help the parser accept a name that conflicts with a reserved word, but a separate validation step still applies for most identifiers. The result depends on the kind of name:

- **Constraint, index, and trigger names**: backticks fully unlock non-standard characters like hyphens or spaces (e.g., <code>\`pk-user\`</code>, <code>\`unique email idx\`</code>). These names skip the post-parse identifier check.
- **Node/edge type, label, and property names**: backticks let you write a reserved word (e.g., <code>\`match\`</code>), but the post-parse validator still requires the name body to be `A-Z`, `a-z`, `0-9`, or `_`. Hyphens, spaces, and non-ASCII characters are rejected even inside backticks.
- **Graph names and graph type names**: backticks are not supported at all. <code>CREATE GRAPH \`match\`</code> produces a syntax error. Choose a name that is a valid bare identifier and not a reserved word.

The backticks are not part of the stored name, they are only a parsing aid.

Examples:

```gql
-- ✓ Constraint name with a hyphen
CREATE CONSTRAINT `pk-user` FOR (n:User) REQUIRE n.id IS KEY

-- ✓ Reserved word as a label
MATCH (n:`match`) RETURN n
```

Not supported:

```gql
-- ✗ Hyphen in a label
CREATE GRAPH g { NODE `my-label` ({name STRING}) }

-- ✗ Backticks not accepted on graph names at all
CREATE GRAPH `match`
```
