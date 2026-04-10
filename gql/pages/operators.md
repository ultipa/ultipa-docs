# Operators

Operators are symbols or keywords used to perform operations on data.

## All Operators

| <div table-width="30">Category</div> | Operators |
| -- | -- |
| <a href="#Property-Accessor">Property Accessor</a> | `.` |
| <a href="#Logical-Operators">Logical Operators</a> | `AND`, `OR`, `XOR`, `NOT` |
| <a href="#Arithmetic-Operators">Arithmetic Operators</a> | `+`, `-`, `*`, `/`, `%`, `^` |
| <a href="#Assignment-Operators">Assignment Operators</a> | `=` |
| <a href="#String-Operators">String Operators</a> | <a href="#String-Concatenation">String Concatenation</a>: `\|\|`, `+`<br><a href="#String-Matching">String Matching</a>: `CONTAINS`, `STARTS WITH`, `ENDS WITH` |
| <a href="#List-Operators">List Operators</a> | <a href="#List-Construction">List Construction</a>: `[]` or `LIST[]` or `ARRAY[]`<br><a href="#Elements-Accessing">Elements Accessing</a>: `[]`<br><a href="#Membership-Checking">Membership Checking</a>: `IN`, `NOT IN`<br><a href="#List-Concatenation">List Concatenation</a>: `\|\|` |
| <a href="#Path-Operators">Path Operators</a> | <a href="#Path-Construction">Path Construction</a>: `PATH[]`<br><a href="#Path-Concatenation">Path Concatenation</a>: `\|\|` |
| <a href="#Record-Operators">Record Operators</a> | <a href="#Record-Construction">Record Construction</a>: `{}` or `RECORD{}`<br><a href="#Field-Reference">Field Reference</a>: `.` |
| <a href="#Deduplication">Deduplication</a> | `DISTINCT` |

## Property Accessor

The `.` (dot) operator allows you to access a property of a graph element.

```gql
MATCH (n)
RETURN n._id LIMIT 10
```

## Logical Operators

### AND

Combines two or more conditions in a way that all of them must be true for the entire expression to evaluate to true.

Truth table for the `AND` operator:

| `AND` | True | False |
| -- | -- | -- |
| <b>True</b> | True | False |
| <b>False</b> | False | False |

This query returns users whose `age` exceeds 30 and `incomeGroup` equals to 4:

```gql
MATCH (n:User)
WHERE n.age > 30 AND n.incomeGroup = 4
RETURN n
```

### OR

Combines two or more conditions where only one of them needs to be true for the entire expression to evaluate to true.

Truth table for the `OR` operator:

| `OR` | True | False |
| -- | -- | -- |
| <b>True</b> | True | True |
| <b>False</b> | True | False |

This query returns users whose `age` exceeds 30, or `incomeGroup` equals to 4:

```gql
MATCH (n:User)
WHERE n.age > 30 OR n.incomeGroup = 4
RETURN n
```

### XOR

Combines two or more conditions by evaluating two conditions at a time. For two conditions, the result is true only if exactly one of the conditions is true. If both are true or both are false, the result is false. When applied to multiple conditions, `XOR` first evaluates the result of the first two conditions, then compares that result with the next condition, continuing this process until all conditions are checked.

Truth table for the `XOR` operator:

| `XOR` | True | False |
| -- | -- | -- |
| <b>True</b> | False | True |
| <b>False</b> | True | False |

This query returns users whose `age` exceeds 30, or `incomeGroup` equals to 4, but excludes users who meet both criteria:

```gql
MATCH (n:Person)
WHERE n.age > 30 XOR n.incomeGroup = 4
RETURN n
```

### NOT

Negates a condition, returning true if the specified condition is false and vice versa.

Truth table for the `NOT` operator:

| <div table-width='10'>`NOT`</div> | True | False |
| -- | -- | -- |
|  | False | True |

This query returns users whose `age` is not 30:

```gql
MATCH (n:Person)
WHERE NOT n.age = 30
RETURN n
```

## Arithmetic Operators

Performs mathematical operations on numerical values. GQL supports the following arithmetic operators:

- Addition: `+`
- Subtraction: `-`
- Multiplication: `*`
- Division: `/`
- Modulus: `%`
- Power: `^`

```gql
RETURN 2 + 8
```

## Assignment Operators

The `=` operator is used to assign values in statements like `LET` and `SET`, and to declare path variables within `MATCH` statements.

```gql
LET a = 1 RETURN a
```

```gql
MATCH (n:Person WHERE n.name = "John Doe")
SET n.gender = "male"
```

```gql
MATCH p = ()->() RETURN p
```

## String Operators

### String Concatenation

The `||` or `+` operators combines multiple strings into a single string by merging the characters of each string in order.

```gql
RETURN "data" || "base",   // "database"
       "data" + "base"     // "database"
```

### String Matching

The `CONTAINS` operator checks if one string contains another (case-sensitive).

This query returns `user` nodes whose `aboutMe` contains "graph database":

```gql
MATCH (n:user WHERE n.aboutMe CONTAINS "graph database")
RETURN n
```

You can transform all letters to upper or lower cases for case-insensitive matching:

```gql
MATCH (n:user WHERE lower(n.aboutMe) CONTAINS "graph database")
RETURN n
```

The `CONTAINS` operator is also used to match the specified keywords with tokens of a full-text index (precise or fuzzy match). See <a target="_blank" href="/docs/gql/fulltext-index">Full-text Index</a>.

This query finds nodes using the full-text index `prodDesc` where their tokens include "graph" and "database":

```gql
MATCH (n WHERE ~prodDesc CONTAINS "graph database")
RETURN n
```

The `STARTS WITH` operator checks if a string starts with a given prefix (case-sensitive):

```gql
MATCH (n:Paper WHERE n.title STARTS WITH "Efficient")
RETURN n
```

The `ENDS WITH` operator checks if a string ends with a given suffix (case-sensitive):

```gql
MATCH (n:Paper WHERE n.title ENDS WITH "Search")
RETURN n
```

## List Operators

### List Construction

The `[]` or `LIST[]` or `ARRAY[]` can create a list by placing comma-separated elements inside. 

```gql
LET items = [1,2,3]
RETURN items          // [1, 2, 3]
```

The `[]` can also construct a **nested list**:

```gql
LET items = [[1,2],[2,3]]
RETURN items          // [[1,2],[2,3]]
```

### Elements Accessing

The `[]` can access elements within a list by their indexes. Lists use 0-based indexing, meaning the first element is at index `0`.

| <div table-width="10">Format</div> | Elements Accessed |
| -- | -- |
| `[m]` | The element with the index of `m`. |
| `[-m]` | The `m`-th element to the bottom. |
| `[m:]` | From the element with the index of `m` to the last element. |
| `[:n]` | From first element to the element with the index of `n-1`. |
| `[m:n]` | From the element with the index of `m` to the element with the index of `n-1`. |

*Note: `m` and `n` are both positive integers and `n > m`.*

```gql
LET items = ["a", 1, "b", 34]
RETURN items[0], items[1], items[-1], items[-2], items[1:], items[:2], items[1:3]
```

Result:

| items[0] | items[1] | items[-1] | items[-2] | items[1:] | items[:2] | items[1:3] |
| -- | -- | -- | -- | -- | -- | -- |
| a | 1 | 34 | b | [1, "b", 34] | ["a", 1] | [1, "b"] |

### Membership Checking

The `IN` checks whether a specified element exists within a list. `NOT IN` checks that it does not. Both evaluate to `1` for true and `0` for false.

```gql
MATCH (n) WHERE n._id IN ["U01", "U02"]
RETURN n
```

```gql
MATCH (n) WHERE n._id NOT IN ["U01", "U02"]
RETURN n
```

### List Concatenation

The concatenation operator `||` combines multiple lists into a single list by merging the elements of each list in order.

```gql
RETURN [1,2,3] || [3,4,5]     // [1, 2, 3, 3, 4, 5]
```

## Path Operators

### Path Construction

The `PATH[]` creates a path by enumerating node and edge references in order.

```gql
MATCH (a {_id: "P1"})-[e]->(b)
RETURN PATH[a, e, b]
```

### Path Concatenation

The concatenation operator `||` joins multiple paths into a continuous single path, merging the last node of the first path with the first node of the second path when they are identical.

```gql
MATCH p1 = ({_id: "P1"})->(n), p2 = (n)->()
RETURN p1 || p2
```

## Record Operators

### Record Construction

The `{}` or `RECORD{}` creates a record. You can define its fields and corresponding values.

```gql
LET rec = {length: 20, width: 59, height: 10}
RETURN rec.length    // 20
```

### Field Reference

The `.` (period) operator allows you to reference a field of a record.

```gql
LET rec = RECORD{length: 20, width: 59, height: 10}
RETURN rec.length * rec.width * rec.height     // 11800
```

## Deduplication

The `DISTINCT` ensures that only unique values are included.

This query returns distinct `age` values of users:

```gql
MATCH (n:User)
RETURN DISTINCT n.age
```