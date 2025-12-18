# Comments

##  Single-Line Comments

In GQL, single-line comments are written using either two forward slashes `//` or two minus signs `--`. Everything following `//` or `--` on the same line is treated as a comment and ignored during query execution.

```gql
MATCH (:User {name: "rowlock"})-[:Follows]->(n:User) // Retrieves users followed by rowlock
RETURN n.name
```

A path expression should not juxtapose a token that exposes a minus sign on the right  (`]-`, `<-`, `-`) followed by a token that exposes a minus sign on the left (`-[`, `->`, `-`), as this combination introduces the comment symbol `--`.

This query throws syntax error since it concatenates `<-` and `-` without any separators:

<p tit="GQL - Syntax Error"></p>

```gql
MATCH (:User {name: "rowlock"})<--(n:User)
RETURN n
```

Instead, you can use a space between the two abbreviated edge patterns:

```gql
MATCH (:User {name: "rowlock"})<- -(n:User)
RETURN n
```

## Multi-Line Comments

Multi-line comments begin with a forward slash and asterisk (`/*`) and end with an asterisk and forward slash (`*/`), allowing for comments that span multiple lines.

```gql
/* This query retrieves users followed by rowlock,
and returns all their names */
MATCH (:User {name: "rowlock"})-[:Follows]->(n:User)
RETURN n.name
```