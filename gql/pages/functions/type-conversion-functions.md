# Type Conversion Functions

## Overview

Type conversion functions convert values between different data types.

## TOINTEGER()

Converts a value to an integer.

**Syntax:**

```
TOINTEGER(value) -> int
```

**Example:**

```gql
RETURN TOINTEGER('42') AS str_to_int,
       TOINTEGER(3.7) AS float_to_int
```

Result:

| str_to_int | float_to_int |
| -- | -- |
| 42 | 3 |

## TOFLOAT()

Converts a value to a float.

**Syntax:**

```
TOFLOAT(value) -> float
```

**Example:**

```gql
RETURN TOFLOAT('3.14') AS str_to_float,
       TOFLOAT(42) AS int_to_float
```

Result:

| str_to_float | int_to_float |
| -- | -- |
| 3.14 | 42.0 |

## TOSTRING()

Converts a value to a string.

**Syntax:**

```
TOSTRING(value) -> string
```

**Example:**

```gql
RETURN TOSTRING(42) AS int_to_str,
       TOSTRING(3.14) AS float_to_str,
       TOSTRING(true) AS bool_to_str
```

Result:

| int_to_str | float_to_str | bool_to_str |
| -- | -- | -- |
| "42" | "3.14" | "true" |

## TOBOOLEAN()

Converts a value to a boolean.

**Syntax:**

```
TOBOOLEAN(value) -> boolean
```

**Example:**

```gql
RETURN TOBOOLEAN('true') AS str_to_bool,
       TOBOOLEAN(1) AS int_to_bool
```

Result:

| str_to_bool | int_to_bool |
| -- | -- |
| true | true |

## TOLIST()

Converts a value to a list.

**Syntax:**

```
TOLIST(value) -> list
```

**Example:**

```gql
RETURN TOLIST('hello') AS str_to_list
```

Result:

| str_to_list |
| -- |
| ["h", "e", "l", "l", "o"] |
