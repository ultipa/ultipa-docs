# Operators

## All Operators

| <div table-width="30">Category</div> | Operators |
| -- | -- |
| <a href="#Schema-Reference">Schema Reference</a> | `@` |
| <a href="#Property-Reference">Property Reference</a> | `.` |
| <a href="#Logical-Operators">Logical Operators</a> | `&&`, `||`, `xor`, `!` |
| <a href="#Arithmetic-Operators">Arithmetic Operators</a> | `+`, `-`, `*`, `/`, `%` |
| <a href="#Comparison-Operators">Comparison Operators</a> | `=`, `!=`, `>`, `<`, `>=`, `<=`, `<>`, `<=>`, `=~` |
| <a href="#String-Operators">String Operators</a> | <a href="#String-Concatenation">String Concatenation</a>: `+`<br><a href="#String-Matching">String Matching</a>: `contains` |
| <a href="#List-Operators">List Operators</a> | <a href="#List-Construction">List Construction</a>: `[]`<br><a href="#Elements-Accessing">Elements Accessing</a>: `[]`<br><a href="#Membership-Checking">Membership Checking</a>: `in`, `nin` |
| <a href="#Deduplication">Deduplication</a> | `DISTINCT` |
| <a href="#Null-Predicates">Null Predicates</a> | `is null`, `is not null` |
| Precedence Control | `()` |

## Schema Reference

The `@` allows you to reference the schema of a node or an edge.

```uql
find().nodes() as n
return n.@ limit 10
```

```uql
find().edges({@links}) as e
return e
```

## Property Reference

The `.` (period) allows you to reference a property of a node or an edge.

```uql
find().nodes() as n
return n._id limit 10
```

```uql
n({@account.level > 3}).e().n() as p
return p
```

## Logical Operators

### And

Combines two or more conditions in a way that all of them must be true for the entire expression to evaluate to true.

Truth table for the `&&` (and) operator:

| `&&` | True | False |
| -- | -- | -- |
| <b>True</b> | True | False |
| <b>False</b> | False | False |

This query returns users whose `age` exceeds 30 and `incomeGroup` equals to 4:

```uql
find().nodes({@User}) as n
where n.age > 30 && n.incomeGroup == 4
return n
```

### Or

Combines two or more conditions where only one of them needs to be true for the entire expression to evaluate to true.

Truth table for the `||` (or) operator:

| <code>\|\|</code> | True | False |
| -- | -- | -- |
| <b>True</b> | True | True |
| <b>False</b> | True | False |

This query returns users whose `age` exceeds 30, or `incomeGroup` equals to 4:

```uql
find().nodes({@User}) as n
where n.age > 30 || n.incomeGroup == 4
return n
```

### Xor

Combines two or more conditions by evaluating two conditions at a time. For two conditions, the result is true only if exactly one of the conditions is true. If both are true or both are false, the result is false. When applied to multiple conditions, `xor` first evaluates the result of the first two conditions, then compares that result with the next condition, continuing this process until all conditions are checked.

Truth table for the `xor` operator:

| `xor` | True | False |
| -- | -- | -- |
| <b>True</b> | False | True |
| <b>False</b> | True | False |

This query returns users whose `age` exceeds 30, or `incomeGroup` equals to 4, but excludes users who meet both criteria:

```uql
find().nodes({@User}) as n
where n.age > 30 xor n.incomeGroup == 4
return n
```

### Not

Negates a condition, returning true if the specified condition is false and vice versa.

Truth table for the `!` (not) operator:

| <div table-width='10'>`!`</div> | True | False |
| -- | -- | -- |
|  | False | True |

This query returns users whose `age` is not 30:

```uql
find().nodes({@User}) as n
where !(n.age == 30)
return n
```

## Arithmetic Operators

Performs mathematical operations on numerical values. UQL supports the following arithmetic operators:

- Addition: `+`
- Subtraction: `-`
- Multiplication: `*`
- Division: `/`
- Modulus: `%`

```uql
return (2+8)%3
```

Result:

| (2+8)%3 |
| -- |
| 1 |

## Comparison Operators

Compares two values or expressions and returns true or false. UQL supports the following comparison operators:

- Equal to: `==`
- Not equal to: `!=`
- Greater than: `>`
- Less than: `<`
- Greater than or equal to: `>=`
- Less than or equal to: `<=`
- Between: `<>`
- Between or equal to: `<=>`
- Regular match: `=~`

This query returns users whose `age` is not 30:

```uql
find().nodes({@User}) as n
where n.age != 30
return n
```

This query returns users whose `age` is between 25 to 35, exclusive of both endpoints (25 and 35):

```uql
find().nodes({@User.age <> [25, 35]}) as n
return n
```

This query returns users whose `age` is between 25 to 35, inclusive of both endpoints (25 and 35):

```uql
find().nodes({@User.age <=> [25, 35]}) as n
return n
```

This query returns users whose `email` is in the format of `xxx@xxx.com` or `xxx@xxx.cn`:

```uql
find().nodes({@User.email =~ "^[a-zA-Z0-9_.-]+@[a-zA-Z0-9]+\.(com|cn)$"}) as n
return n
```

## String Operators

### String Concatenation

The `+` combines multiple strings into a single string by merging the characters of each string in order.

```uql
return "data" + "base"
```

Result:

| "data" + "base" |
| -- |
| database |

### String Matching

The `contains` operator checks if one string contains another (case-sensitive).

This query returns `user` nodes whose `aboutMe` contains "graph database":

```uql
find().nodes({@user.aboutMe contains "graph database"}) as n
return n
```

You can transform all letters to upper or lower cases for case-insensitive matching:

```uql
find().nodes({lower(@user.aboutMe) contains "graph database"}) as n
return n
```

The `contains` operator is also used to match the specified keywords with tokens of a full-text index (precise or fuzzy match). See <a target="_blank" href="/docs/uqlfull-text-index#Using-Full-text-Indexes">Using Full-text Indexes</a>.

This query finds nodes using the full-text index `prodDesc` where their tokens include "graph" and "database":

```uql
find().nodes({~prodDesc contains "graph database"}) as n
return n
```

## List Operators

### List Construction

The `[]` can create a list by placing comma-separated elements inside.

```uql
with [1,2,3] as items
return items
```

Result:

| items |
| -- |
| [1,2,3] |

The `[]` can also construct a **nested list**:

```uql
with [[1,2],[2,3]] as items
return items
```

Result:

| items |
| -- |
| [[1,2],[2,3]] |

### Elements Accessing

The `[]` can access elements within a list by their indexes. Lists use 0-based indexing, meaning the first element is at index `0`.

```uql
with ["a", 1, "b"] as items
return items[0]
```

Result:

| items[0] |
| -- |
| a |

### Membership Checking

The `in` checks whether a specified element exists within a list. Conversely, the `nin` checks whether a specified element does not exist within a list.

This query returns nodes whose `_id` can be found in the list of `["U01", "U02"]`:

```uql
find().nodes({_id in ["U01", "U02"]}) as n
return n
```

This query returns nodes whose `_id` cannot be found in the list of `["U01", "U02"]`:

```uql
find().nodes({_id nin ["U01", "U02"]}) as n
return n
```

## Deduplication

The `distinct` ensures that only unique values are included.

This query returns distinct `age` values of users:

```uql
find().nodes({@User}) as n
return distinct n.age
```

## Null Predicates

Specifies a test for a null value. UQL supports the following null predicates:

- `is null`
- `is not null`

This query retrieves the `title` of each `@Paper` node if the value is not null; otherwise, it returns the message `TITLE NOT FOUND`.

```uql
find().nodes({@Paper}) as n
return case
  when n.title is not null then n.title
  else "TITLE NOT FOUND"
end
```
