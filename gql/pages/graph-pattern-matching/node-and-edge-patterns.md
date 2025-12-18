# Node and Edge Patterns

## Overview

Node patterns and edge patterns are conjunctively referred to as **element patterns**, they serve as building blocks for path patterns.

## Node Patterns

A node pattern is to match nodes in the graph, represented using a pair of parentheses `()`. A node pattern is composed of three optional parts:

- <a href="#Element-Variable-Declaration">Node Variable Declaration</a>
- <a href="#Label/Schema-Expression">Label/Schema Expression</a>
- <a href="#Property-Specification">Property Specification</a> or <a href="#WHERE-Clause">WHERE Clause</a>

<p tit="Syntax"></p>

```gql
<node pattern> ::=
  "(" [ <node variable declaration> ]
      [ <label or schema expression> ]
      [ <property specification> | <where clause> ] ")" 
```
    
The simplest empty node pattern matches any node in the graph:

<p tit="Node Pattern"></p>

```gql
() 
```

To match `Person` nodes and bind them to the variable `n`:

<p tit="Node Pattern"></p>

```gql
(n:Person)
```

To match nodes whose properties `fullname` and `age` with specific values:

<p tit="Node Pattern"></p>

```gql
({fullname: "John Doe", age: 30})
```

To match `Person` nodes where the property `age` is greater than 30, and bind these nodes to the variable `n`:

<p tit="Node Pattern"></p>

```gql
(n:Person WHERE n.age > 30)
```

## Edge Patterns

An edge pattern is to match edges in the graph, typically in conjunction with node patterns on both sides. If a node pattern is not provided on either side of the edge pattern, an implicit empty node pattern is assumed.

An edge pattern is either a **full edge pattern** or an **abbreviated edge pattern**.

### Full Edge Pattern

A full edge pattern is represented using a pair of suqare brackets `[]` and includes an indication of the edge's direction (left/incoming, right/outgoing, or any). A full edge pattern is composed of three optional parts:

- <a href="#Element-Variable-Declaration">Edge Variable Declaration</a>
- <a href="#Label/Schema-Expression">Label/Schema Expression</a>
- <a href="#Property-Specification">Property Specification</a> or <a href="#WHERE-Clause">WHERE Clause</a>
  
<p tit="Syntax"></p>

```gql
<full edge pattern> ::=
  <full edge pointing left> | <full edge pointing right> | <full edge any direction>

<full edge pointing left> ::=
  "<-[" <edge pattern filter> "]-"

<full edge pointing right> ::=
  "-[" <edge pattern filter> "]->"

<full edge any direction> ::=
  "-[" <edge pattern filter> "]-"

<edge pattern filter> ::=
  [ <edge variable declaration> ] 
  [ <label or schema expression> ] 
  [ <property specification> | <where clause> ]
```

To match all edges in the graph and bind them to the variable `e`:

<p tit="Path Pattern"></p>

```gql
()-[e]->()
```

To match `Works_for` edges whose property `role` has a specific value, and bind them to the variable `e`:

<p tit="Path Pattern"></p>

```gql
()-[e:Works_for {role: "Manager"}]->()
```

To match edges where the property `score` is less than 2, and bind them to the variable `e`:

<p tit="Path Pattern"></p>

```gql
()<-[e WHERE e.score < 2]-()
```

### Abbreviated Edge Pattern

An abbreviated edge pattern only indicates the edge direction (left/incoming, right/outgoing, or any) and does not support variable declaration or pattern filtering.

<p tit="Syntax"></p>

```gql
<abbreviated edge pattern> ::= "<-" | "->" | "-"
```

To match nodes that `User` nodes can reach through an outgoing edge:

<p tit="Path Pattern"></p>

```gql
(:User)->(n)
```

To match all one-step paths in the graph:

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

### Label/Schema Expression

A label/schema expression starts with a colon `:` or the keyword `IS`. It can be used in a node or full edge pattern. A label/schema expression specifies one or more labels/schemas.

To match `Movie` nodes:

<p tit="Node Pattern"></p>

```gql
(m:Movie)
```

This is equivalent to:

<p tit="Node Pattern"></p>

```gql
(m IS Movie)
```

The label/schema expression supports the following operators:

| Operator | Description |
| -- | -- |
| `!` | Negation (NOT) |
| `&` | Conjunction (AND) |
| `\|` | Disjunction (OR) |
| `%` | Wildcard |

To match nodes with the label/schema `Movie` or `Country`:

<p tit="Node Pattern"></p>

```gql
(n:Movie|Country)
```

To match nodes with labels/schemas `Teacher` and `Student`:

<p tit="Node Pattern"></p>

```gql
(n:Teacher&Student)
```

To match edges with labels/schemas other than `LIVING_IN`:

<p tit="Path Pattern"></p>

```gql
()-[e:!LIVING_IN]-()
```

To match nodes with any label/schema:

<p tit="Node Pattern"></p>

```gql
(n:%)
```

To match nodes without a label/schema:

<p tit="Node Pattern"></p>

```gql
(n:!%)
```

### Property Specification

Property specification encloses property key-value pairs in a pair of curly braces `{}` inside a node or full edge pattern. This applies **joint equalities** to filter nodes or edges based on the values of their properties.

To match nodes whose properties `type` and `level` with specific values:

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

To match `Card` nodes where the property `level` is greater than 3:

<p tit="Node Pattern"></p>

```gql
(c:Card WHERE c.level > 3)
```

To filter edges whose properties `amount` and `currency` meet the specified conditions:

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
