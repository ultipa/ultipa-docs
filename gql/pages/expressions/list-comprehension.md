# List Comprehension

A list comprehension creates a new list by iterating over an existing list, optionally filtering elements and transforming them.

<p tit="Syntax"></p>

```
<list comprehension> ::=
  "[" <variable> "IN" <list> [ < "WHERE" | "FILTER" > <condition> ] [ "|" <expr> ] "]"
```

**Details**

- `<variable>`: the iteration variable, bound to each element in `<list>` in turn.
- `WHERE|FILTER <condition>`: optional filter; only elements that meet the condition are included.
- `<expr>` transforms each element. If omitted, returns the original element.

## Examples

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