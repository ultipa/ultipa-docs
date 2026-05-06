# Node and Edge Patterns

## Overview

Node patterns and edge patterns are conjunctively referred to as **element patterns**, they serve as building blocks for path patterns.

## Node Patterns

A node pattern is to match nodes in the graph, represented using a pair of parentheses `()`. A node pattern is composed of three optional parts:

- <a href="#Element-Variable-Declaration">Node Variable Declaration</a>
- <a href="#Label-Expression">Label Expression</a>
- <a href="#Property-Specification">Property Specification</a> or <a href="#WHERE-Clause">WHERE Clause</a>

<p tit="Syntax"></p>

```
<node pattern> ::=
  "(" [ <node variable declaration> ] [ <label expression> ]
      [ <property specification> | <where clause> ] ")" 
```
    
The simplest empty node pattern matches any node in the graph:

<p tit="Node Pattern"></p>

```gql
() 
```

Match `Person` nodes and bind them to the variable `n`:

<p tit="Node Pattern"></p>

```gql
(n:Person)
```

Match nodes whose properties `fullname` and `age` with specific values:

<p tit="Node Pattern"></p>

```gql
({fullname: "John Doe", age: 30})
```

Match `Person` nodes where the property `age` is greater than 30, and bind these nodes to the variable `n`:

<p tit="Node Pattern"></p>

```gql
(n:Person WHERE n.age > 30)
```

## Edge Patterns

An edge pattern is to match edges in the graph, typically in conjunction with node patterns on both sides. If a node pattern is not provided on either side of the edge pattern, an implicit empty node pattern is assumed.

An edge pattern is either a **full edge pattern** or an **abbreviated edge pattern**.

### Full Edge Pattern

A full edge pattern is represented using a pair of square brackets `[]` and includes an indication of the edge's direction (left/incoming, right/outgoing, or any). A full edge pattern is composed of three optional parts:

- <a href="#Element-Variable-Declaration">Edge Variable Declaration</a>
- <a href="#Label-Expression">Label Expression</a>
- <a href="#Property-Specification">Property Specification</a> or <a href="#WHERE-Clause">WHERE Clause</a>
  
<p tit="Syntax"></p>

```
<full edge pattern> ::=
  <full edge pointing left> | <full edge pointing right> | <full edge any direction>

<full edge pointing left> ::=
  "<-[" <edge pattern filter> "]-"

<full edge pointing right> ::=
  "-[" <edge pattern filter> "]->"

<full edge any direction> ::=
  "-[" <edge pattern filter> "]-"

<edge pattern filter> ::=
  [ <edge variable declaration> ] [ <label expression> ] 
  [ <property specification> | <where clause> ]
```

Match all edges in the graph and bind them to the variable `e`:

<p tit="Path Pattern"></p>

```gql
()-[e]->()
```

Match `Works_for` edges whose property `role` has a specific value, and bind them to the variable `e`:

<p tit="Path Pattern"></p>

```gql
()-[e:Works_for {role: "Manager"}]->()
```

Match edges where the property `score` is less than 2, and bind them to the variable `e`:

<p tit="Path Pattern"></p>

```gql
()<-[e WHERE e.score < 2]-()
```

### Abbreviated Edge Pattern

An abbreviated edge pattern only indicates the edge direction (left/incoming, right/outgoing, or any) and does not support variable declaration or pattern filtering.

<p tit="Syntax"></p>

```
<abbreviated edge pattern> ::= "<-" | "->" | "-"
```

Match nodes that `User` nodes can reach through an outgoing edge:

<p tit="Path Pattern"></p>

```gql
(:User)->(n)
```

Match all one-step paths in the graph:

<p tit="Path Pattern"></p>

```gql
p = ()->()
```

## Syntactic Elements

### Element Variable Declaration

Node variables and edge variables are collectively referred to as **element variables**. 

A **node variable** is declared in a node pattern, placed before any label or property filters. The value of a node variable represents a list of bound nodes.

The variable `n` is bound to `Person` nodes:

```gql
MATCH (n:Person)
RETURN n.name
```

An **edge variable** is declared in a full edge pattern, placed before any label or property filters. The value of an edge variable represents a list of bound edges.

The variable `e` is bound to edges labeled `Follows`:

```gql
MATCH ()-[e:Follows]->()
RETURN e
```

### Label Expression

A label expression starts with a colon `:` or the keyword `IS`. It can be used in a node or full edge pattern. A label expression specifies one or more labels.

Match `Movie` nodes:

<p tit="Node Pattern"></p>

```gql
(m:Movie)
```

This is equivalent to:

<p tit="Node Pattern"></p>

```gql
(m IS Movie)
```

The label expression supports the following operators:

| Operator | Description |
| -- | -- |
| `!` | Negation (NOT) |
| `&` | Conjunction (AND) |
| `\|` | Disjunction (OR) |
| `%` | Wildcard |

Match nodes with the label `Movie` or `Country`:

<p tit="Node Pattern"></p>

```gql
(n:Movie|Country)
```

Match nodes with labels `Teacher` and `Student`:

<p tit="Node Pattern"></p>

```gql
(n:Teacher&Student)
```

Match edges with labels other than `LIVING_IN`:

<p tit="Path Pattern"></p>

```gql
()-[e:!LIVING_IN]-()
```

Match nodes with any label:

<p tit="Node Pattern"></p>

```gql
(n:%)
```

Match nodes without a label:

<p tit="Node Pattern"></p>

```gql
(n:!%)
```

Parentheses can be used to group sub-expressions and override operator precedence. 

Match nodes that either have both `Person` and `Employee` labels, or have the `Manager` label:

<p tit="Node Pattern"></p>

```gql
(n:(Person&Employee)|Manager)
```

Match `Person` nodes that also have either the `Active` or `VIP` label:

<p tit="Node Pattern"></p>

```gql
(n:Person&(Active|VIP))
```

### Property Specification

Property specification encloses property key-value pairs in a pair of curly braces `{}` inside a node or full edge pattern. This applies **joint equalities** to filter nodes or edges based on the values of their properties.

Match nodes whose properties `type` and `level` with specific values:

<p tit="Node Pattern"></p>

```gql
(n {type: "Gold", level: 5})
```

This is equivalent to the following using the `WHERE` clause:

<p tit="Node Pattern"></p>

```gql
(n WHERE n.type = "Gold" AND n.level = 5)
```

### WHERE Clause

You can use the `WHERE` clause within a node or full edge pattern to apply conditions on properties. It offers more flexible filtering rules compared to the <a href="#Property-Specification">property specification</a>.

Match `Card` nodes where the property `level` is greater than 3:

<p tit="Node Pattern"></p>

```gql
(c:Card WHERE c.level > 3)
```

Filter edges whose properties `amount` and `currency` meet the specified conditions:

<p tit="Path Pattern"></p>

```gql
(:Card)-[t WHERE t.amount > 10000 AND t.currency = 'USD']->()
```

This query throws a syntax error because `amount` is used as if it were a variable. To specify a property in the `WHERE` clause, you must use the dot operator `.` to reference it from a node or edge variable, like `(n:Card WHERE n.amount > 100)`.

<p tit="GQL - Syntax Error"></p>

```gql
MATCH p = (:Card WHERE amount > 100)-[]->()
RETURN p
```

This query throws a syntax error because you cannot use property specification and `WHERE` clause together within an element pattern. Instead, you may write `(n:Paper WHERE n.author = "Alex" AND n.score > 5)`.

<p tit="GQL - Syntax Error"></p>

```gql
MATCH (n:Paper {author: "Alex"} WHERE n.score > 5)
RETURN n
```
