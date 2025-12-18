# Predicates

A predicate specifies a condition that can be evaluated to give a boolean value (`true` or `false`).

## All Predicates

| <div table-width="30">Category</div> | Predicates |
| -- | -- |
| <a href="#Comparison-Predicates">Comparison Predicates</a> | `=`, `<>` (or `!=`), `>`, `<`, `>=`, `<=`, `=~` |
| <a href="#Exists-Predicate">Exists Predicate</a> | `EXISTS` |
| <a href="#None-Predicate">None Predicate</a> | `NONE` |
| <a href="#Null-Predicates">Null Predicates</a> | `IS NULL`, `IS NOT NULL` |
| <a href="#Normalized-Predicates">Normalized Predicates</a> | `IS NORMALIZED`, `IS NOT NORMALIZED` |
| <a href="#Labeled-Predicates">Labeled Predicates</a> | `IS LABELED`, `IS NOT LABELED`, `:` |
| <a href="#Property-Exists-Predicate">Property Exists Predicate</a> | `PROPERTY_EXISTS` |
| <a href="#Value-Type-Predicates">Value Type Predicates</a> | `IS TYPED`, `IS NOT TYPED` |
| <a href="#Boolean-Value-Predicates">Boolean Value Predicates</a> | `IS TRUE`, `IS FALSE` |
| <a href="#All-Different-Predicate">All Different Predicate</a> | `ALL_DIFFERENT` |
| <a href="#Same-Predicate">Same Predicate</a> | `SAME` |
| <a href="#Source/Destination-Predicates">Source/Destination Predicates</a> | `IS SOURCE OF`, `IS NOT SOURCE OF`, `IS DESTINATION OF`, `IS NOT DESTINATION OF` |
| <a href="#Directed-Predicates">Directed Predicates</a> | `IS DIRECTED`, `IS NOT DIRECTED` |

## Comparison Predicates

Compares two values or expressions and returns true or false. GQL supports the following comparison operators:

- Equal to: `=`
- Not equal to: `<>` (or `!=`)
- Greater than: `>`
- Less than: `<`
- Greater than or equal to: `>=`
- Less than or equal to: `<=`
- Regular match: `=~`

The `>`, `<`, `>=`, and `<=` can be used only with numeric, textual, temporal, boolean, and `null` values.

### Comparable Values

In GQL, two values are considered comparable if they can be meaningfully evaluated using comparison operators. There are two kinds of comparable values:

- **Essentially Comparable Values:** These are values of the same type (e.g., two strings, two dates) or closely related types within the same category (e.g., an integer and a float). They can be directly compared.
- **Universally Comparable Values:** These include values from different categories that can still be compared by implicitly converting one value’s type to match the other. For example, comparing the integer `12` with the string `"13ab"` attempts a conversion before evaluation.

### Comparing Numeric Values 

```gql
RETURN 30.1 > 30 // true
```

### Comparing Textual Values

The first differing character (from left to right) determines the result of the comparison. The characters are compared based on their Unicode values.

```gql
RETURN "campus" < "camera" // false
```

This query returns `false` because the first differing character, `p`, has a higher Unicode value than `e` (Unicode of `p` is `112`, while `e` is `101`).

```gql
LET email = "johndoe@gmail.com"
RETURN email =~ "[a-zA-Z0-9_.-]+@[a-zA-Z0-9]+\.(com|cn)" // true
```

This query returns `true` because the `email` matches the specified email address pattern.

### Comparing Temporal Values

Temporal values are treated like numeric values, as time is measured in units such as seconds, hours, days, and years. In GQL, the comparison between two temporal values is based on their duration—the difference between the two points in time. If the duration is 0, the values are equal; if negative, the left value is smaller; otherwise, the left value is greater.

```gql
// p1.birthday is 1987-10-01, p2.birthday is 1987-10-02
MATCH (p1 {name: "Alex"}), (p2 {name: "Joy"})
RETURN p1.birthday < p2.birthday // true
```

### Comparing List Values

Two lists are considered equal if they contain the same elements in the exact same order.

```gql
RETURN [1,2,3] = [1,2,3] // true
```

```gql
RETURN [] = [] // true
```

```gql
RETURN [1,2,3] = [1,3,2] // false
```

### Comparing Records

Two records are considered equal if they have the same fields with identical values.

```gql
RETURN {a:1, b:2} = {a:1, b:2} // true
```

```gql
RETURN {a:1, b:2} = {a:2, b:2} // false
```

```gql
RETURN {a:1} = {b:1} // false
```

### Comparing Paths

Paths are similar to lists, as they consist of sequences of nodes and edges.

```gql
MATCH p1 = (:User {name: "mochaeach"})-[:Joins]->(:Club {_id: "C02"})
MATCH p2 = (:User {name: "mochaeach"})-[:Joins]->(:Club {_id: "C02"})
RETURN p1 = p2 // true
```

```gql
MATCH p1 = (:User {name: "mochaeach"})-[:Joins]->(:Club {_id: "C02"}) 
MATCH p2 = (:Club {_id: "C02"})<-[:Joins]-(:User {name: "mochaeach"})
RETURN p1 = p2 // false
```

### Comparing Nodes/Edges

Nodes and edges can be treated like records, where property names act as keys and their corresponding property values serve as values.

```gql
MATCH  (n1:User {name: "mochaeach"}), (n2:Club {_id: "C02"})
RETURN n1 = n2 // false
```

### Comparing String and Numeric Values

GQL attempts to convert an entire string to a numeric value when it is compared with a numeric operand. The conversion succeeds only if the string is in a valid numeric format. For example:

- `" 123 "` → `123`
- `"-2"` → `-2`
- `"+2.3"` → `2.3`

If the string is not in a valid numeric format, it is interpreted as `0`.

```gql
RETURN "-2.9" > -3 // true; converts "-2.9" to 2.9
```

```gql
RETURN "11a" > 10 // false; converts "11a" to 0
```

### Comparing String and Temporal Values

In GQL, strings can be compared with temporal values by implicitly converting the string to a temporal type. This behavior is similar to string-numeric comparisons. For a string to be successfully compared to a temporal value, it must:

- Follow the <a target="_blank" href="https://en.wikipedia.org/wiki/ISO_8601">ISO 8601 standard</a> format for date, datetime, or duration values.
- Be interpreted as a temporal value matching the type of the other operand.

```gql
// p.birthday is 1987-10-01
MATCH (p1 {name: "Alex"}), (p2 {name: "Joy"})
RETURN p1.birthday < "1987-10-02" // true
```

### Comparing Boolean Values and Others

Boolean values can be compared with other data types, such as numeric or textual values, through implicit type conversion.

```gql
RETURN true = 1 // true
```

```gql
RETURN false = 0 // true
```

```gql
RETURN true = "true" // false
```

## Exists Predicate

The `EXISTS` predicate evaluates whether a specified graph pattern or query returns any results. If it finds matching data, the predicate evaluates to true; otherwise, it evaluates to false.

<p tit="Syntax"></p>

```gql
<exists predicate> ::=
  "EXISTS" {
      "{" <graph pattern> "}"
    | "(" <graph pattern> ")"
    | "{" { <match statement>... } "}"
    | "(" { <match statement>... } ")"
    | "{" <query specification> "}"
  }
```

This query checks whether there is any path originating from node `A` exists in the graph:

```gql
RETURN EXISTS {
  MATCH ({_id: "A"})->()
}
```

The `MATCH` keyword can be omitted when `EXISTS` contains only a graph pattern. Additionally, a `WHERE` clause can be used with the pattern to apply conditions:

```gql
RETURN EXISTS {
  (n)->() WHERE n._id = "A"
}
```

`EXISTS` can also be used in the `WHERE` clause of a `MATCH` statement:

```gql
MATCH (n:movie)
WHERE n.rating > 7.5 AND EXISTS {
  MATCH (n)<-[:direct]-(m)
  WHERE m.name = "Ang Lee"
}
RETURN n.name
```

This query checks whether any element in a list is greater than 3:

```gql
RETURN EXISTS {
  FOR item in [1,2,3]
  FILTER item > 3
  RETURN item
}
```

This query checks whether the retrieved node has the property `name`; note that it returns true even if the `name` value is `null`:

```gql
MATCH (n:Paper {_id: "book92"}) LIMIT 1
RETURN EXISTS(n.name)
```

## None Predicate

The `NONE` predicate evaluates whether a specified graph pattern or query returns no results. If it doesn't find any matching data, the predicate evaluates to true; otherwise, it evaluates to false.

<p tit="Syntax"></p>

```gql
<none predicate> ::=
  "NONE" {
      "{" <graph pattern> "}"
    | "(" <graph pattern> ")"
    | "{" { <match statement>... } "}"
    | "(" { <match statement>... } ")"
    | "{" <query specification> "}"
  }
```

This query checks whether there is no path originating from node `A` in the graph:

```gql
RETURN NONE {
  MATCH ({_id: "A"})->()
}
```

The `MATCH` keyword can be omitted when `NONE` contains only a graph pattern. Additionally, a `WHERE` clause can be used with the pattern to apply conditions:

```gql
RETURN NONE {
  (n)->() WHERE n._id = "A"
}
```

`NONE` can also be used in the `WHERE` clause of a `MATCH` statement:

```gql
MATCH (n:movie)
WHERE n.rating > 7.5 AND NONE {
  MATCH (n)<-[:direct]-(m)
  WHERE m.name = "Ang Lee"
}
RETURN n.name
```

This query checks whether there is no element in a list is greater than 3:

```gql
RETURN NONE {
  FOR item in [1,2,3]
  FILTER item > 3
  RETURN item
}
```

## Null Predicates

Specifies a test for a `null` value. GQL supports the following null predicates:

- `IS NULL`
- `IS NOT NULL`

This query retrieves the `title` of each `Paper` node if the value is not null; otherwise, it returns the message `TITLE NOT FOUND`:

```gql
MATCH (n:Paper)
RETURN CASE 
  WHEN n.title IS NOT NULL THEN n.title
  ELSE "TITLE NOT FOUND"
END
```

## Normalized Predicates

Determines whether a character string value is normalized. GQL supports the following normalized predicates:

- `IS [ <normal form> ] NORMALIZED`
- `IS NOT [ <normal form> ] NORMALIZED`

**Details**

- The `<normal form>` defaults to `NFC`. Other available <a href="/docs/gql/character-string-functions#normalize()">normalization forms</a> are `NFD`, `NFKC` and `NFKD`.

```gql
RETURN "Å" IS NORMALIZED AS normRes
```

Result:

| normRes |
| -- |
| 1 |

```gql
RETURN "Å" IS NFD NORMALIZED AS normRes
```

Result:

| normRes |
| -- |
| 0 |

## Labeled Predicates

Determines whether a graph element satisfies a label expression. GQL supports the following labeled predicates:

- `IS LABELED`
- `IS NOT LABELED`
- `:`

```gql
MATCH (n) WHERE n IS NOT LABELED Paper
RETURN n
```

```gql
MATCH (n) WHERE n:Paper
RETURN n
```

## Property Exists Predicate

The `PROPERTY_EXISTS` predicate evaluates whether a referenced graph element contains a property, regardless of its value. This means it returns true even if the property's value is `null`.

```gql
MATCH (n:Paper) LIMIT 1
RETURN PROPERTY_EXISTS(n, "name")
```

## Value Type Predicates

Determines whether a value conforms to a specific type. GQL supports the following value type predicates:

- `IS TYPED <value type>`
- `IS NOT TYPED <value type>`

**Details**

- Currently, the `<value type>` supports the following data type keywords: `STRING`, `BOOL`.

```gql
RETURN "a" IS TYPED BOOL AS typeCheck
```

Result:

| typeCheck |
| -- |
| false |

## Boolean Value Predicates

Evaluates the truthiness of a boolean expression or variable, determining whether it is true or false. GQL supports the following boolean value predicates:

- `IS TRUE`
- `IS FALSE`

```gql
RETURN 1 > 2 IS TRUE
```

Result:

| 1 > 2 IS TRUE |
| -- |
| 0 |

## All Different Predicate

The `ALL_DIFFERENT` predicate evaluates whether all graph elements bound to a list of element variables are pairwise different from one another.

```gql
MATCH (n1 {_id:"P1"})
MATCH ({_id:"P1"})-(n2)
MATCH ({_id:"P3"})-(n3)
RETURN table(n1._id, n2._id, n3._id, ALL_DIFFERENT(n1, n2, n3))
```

Result:

| n1.\_id | n2.\_id | n3.\_id | <div table-width="40">ALL_DIFFERENT(n1, n2, n3)</div> |
| -- | -- | -- | -- |
| P1 | P2 | P2 | 0 |

## Same Predicate

The `SAME` predicate evaluates whether all element variables bind to the same graph element.

```gql
MATCH ({_id:"P1"})-(n1)
MATCH ({_id:"P3"})-(n2)
RETURN table(n1._id, n2._id, SAME(n1, n2))
```

Result:

| n1.\_id | n2.\_id | SAME(n1, n2) |
| -- | -- | -- |
| P2 | P2 | 1 |

## Source/Destination Predicates

Determines whether a node is the source or destination of an edge. GQL supports the following source/destination predicates:

- `<node reference> IS SOURCE OF <edge reference>`
- `<node reference> IS NOT SOURCE OF <edge reference>`
- `<node reference> IS DESTINATION OF <edge reference>`
- `<node reference> IS NOT DESTINATION OF <edge reference>`

```gql
MATCH (n {_id: "P1"}), ()-[e:Cites]->() WHERE n IS SOURCE OF e
RETURN e
```

## Directed Predicates

Directed predicates determine whether an edge variable is bound to a directed edge. GQL supports the following directed predicates:

- `IS DIRECTED`
- `IS NOT DIRECTED`

**Details**

- All edges created in Ultipa Graph Database are directed.

```gql
MATCH ()-[e]-()
RETURN e IS DIRECTED
```

Result:

| e IS DIRECTED |
| -- |
| 1 |
