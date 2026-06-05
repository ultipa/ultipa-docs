# List Expressions

GQL has two expression forms that iterate over a list. They share the `<variable> IN <list>` shape but produce different things:

| Form | Returns |
| -- | -- |
| <a href="#List-Comprehension">List comprehension</a> | A new list |
| <a href="#List-Quantifiers">List quantifier</a> | A single boolean |

## List Comprehension

A list comprehension creates a new list by iterating over an existing list, optionally filtering elements and transforming them.

```syntax
<list comprehension> ::=
  "[" <variable> "IN" <list> [ < "WHERE" | "FILTER" > <condition> ] [ "|" <expr> ] "]"
```

**Details**

- `<variable>`: the iteration variable, bound to each element of `<list>` in turn.
- `WHERE|FILTER <condition>`: optional filter; only elements that meet the condition are included.
- `<expr>`: optional transformation. if omitted, the original element is emitted.

Transform each element:

```gql
RETURN [x IN [1, 2, 3, 4, 5] | x * 10]
```

Result: [10, 20, 30, 40, 50]

Filter elements:

```gql
RETURN [x IN [1, 2, 3, 4, 5] WHERE x > 2]
```

Result: [3, 4, 5]

Filter and transform:

```gql
RETURN [x IN [1, 2, 3, 4, 5] WHERE x > 2 | x * 10]
```

Result: [30, 40, 50]

## List Quantifiers

Quantifiers reduce a list to a single boolean by testing a condition against its elements.

```syntax
<list quantifier> ::=
  < "ANY" | "ALL" | "NONE" | "SINGLE" > "(" <variable> "IN" <list> "WHERE" <condition> ")"
```

| Quantifier | Returns `true` when … |
| -- | -- |
| `ANY` | The condition holds for at least one element |
| `ALL` | The condition holds for every element |
| `NONE` | The condition holds for no element |
| `SINGLE` | The condition holds for exactly one element |

```gql
RETURN ANY(x IN [1, 2, 3] WHERE x > 2),   // true
       ALL(x IN [1, 2, 3] WHERE x > 2),   // false
       NONE(x IN [1, 2, 3] WHERE x > 5),  // true
       SINGLE(x IN [1, 2, 2] WHERE x = 2) // false
```