# Triggers

A trigger automatically executes predefined operations in response to specific data events. Triggers run **before** an **insert** or **update** operation, allowing you to enforce business rules, maintain data integrity, or perform auxiliary operations without manual intervention.

## Showing Triggers

Show triggers in the current graph:

```gql
SHOW TRIGGERS

-- Filter by node label
SHOW TRIGGERS ON NODE Student

-- Filter by edge label
SHOW TRIGGERS ON EDGE "ATTENDS"
```

Returns a table with the following columns:

| Field | Description |
| -- | -- |
| `name` | The name of the trigger. |
| `entity_type` | The entity type: `NODE` or `EDGE`. |
| `label` | The label the trigger is associated with. |
| `event` | The trigger event: `BEFORE_INSERT` or `BEFORE_UPDATE`. |
| `enabled` | Whether the trigger is currently active. |
| `comment` | The optional description of the trigger. |

## Creating Triggers

<p tit="Syntax"></p>

```
<create trigger statement> ::=
  "CREATE TRIGGER" [ "IF NOT EXISTS" ] <trigger name> "ON" < "NODE" | "EDGE" > <label name> 
  [ "COMMENT" <comment> ]
  "BEFORE" < "INSERT" | "UPDATE" >
  "CALL" <callable body string>
```

**Details**

- `BEFORE INSERT` only fires for nodes. `BEFORE UPDATE` fires normally on both nodes and edges.

### Callable Body

The `<callable body>` uses the format `$entity call { ... }` and supports `let` assignments to modify entity properties. The `let` keyword must be lowercase.

<p tit="Syntax"></p>

```
<callable body> ::=
  "$entity call {" <let assignment>, { ";" <let assignment> }... "}"

<let assignment> ::=
  "let entity." <property name> "=" <value expression>
```

**Supported value expressions:**

| Expression Type | Example | Description |
| -- | -- | -- |
| String literal | `'active'`, `"active"` | A quoted string value. |
| Numeric literal | `18`, `3.14` | An integer or float value. |
| Property access | `entity.name` | Reads a property from the current entity. |
| Function call | `upper(entity.name)` | Applies a built-in function to an expression. |

**Built-in functions:**

| <div table-width="30">Function</div> | Description |
| -- | -- |
| `upper(value)` | Converts a string to uppercase. |
| `lower(value)` | Converts a string to lowercase. |
| `trim(value)` | Removes leading and trailing whitespace from a string. |
| `len(value)` / `length(value)` | Returns the length of a string. |

**Limitations of the callable body**

The body language is intentionally narrow. Be aware of the following:

- Only `let entity.<property> = <expression>` assignments are supported. There are no statements for conditionals, loops, explicit `REJECT`/`ABORT`, logging, or calls to user-defined procedures.
- Only the properties of the triggering entity are reachable via `entity.<property>`. Other nodes, edges, parameters, and graph state cannot be queried from inside the body.

### Examples

```gql
-- BEFORE INSERT node trigger: normalize student name and set default status
CREATE TRIGGER "InitStudent" ON NODE "Student"
  COMMENT 'Normalize name and set default status'
  BEFORE INSERT
  CALL " $entity call { let entity.name = upper(trim(entity.name)); let entity.status = 'active' } "

-- Now inserting a Student node will uppercase the name and set status
INSERT (n:Student {name: "John Doe"})
RETURN n.name, n.status   // "JOHN DOE", "active"
```

```gql
-- BEFORE UPDATE node trigger: normalize user email
CREATE TRIGGER "NormalizeEmail" ON NODE "User"
  COMMENT 'Normalize email on update'
  BEFORE UPDATE
  CALL " $entity call { let entity.email = lower(trim(entity.email)) } "

-- Now updating a User's email will trim whitespace and lowercase it
MATCH (u:User {_id: 'u1'})
SET u.email = "  Alice@Example.COM  "
RETURN u.email   // "alice@example.com"
```

## Dropping Triggers

Drop the trigger `InitStudent`:

```gql
DROP TRIGGER "InitStudent"
```

The `IF EXISTS` clause is used to prevent errors when attempting to delete a trigger that does not exist. It allows the statement to be safely executed.

```gql
DROP TRIGGER IF EXISTS "InitStudent"
```

This deletes the trigger `InitStudent` only if a trigger with that name does exist. If `InitStudent` does not exist, the statement is ignored without throwing an error.

> Dropping a label will also remove any triggers associated with that label.

## Execution Behavior

- When multiple triggers are defined on the same label and event, they execute in **creation order**. Each trigger receives the modified properties from the previous trigger.
- When an entity has multiple labels, triggers execute in the **order the labels appear in the query**. For example, `INSERT (:Student&Person {...})` fires `Student` triggers first, then `Person` triggers. The modified properties from one label's triggers are passed to the next label's triggers.
- There is no practical way to conditionally veto an operation. The built-in functions (`upper`, `lower`, `trim`, `len`/`length`) silently pass through non-string inputs without raising an error, and the body language has no conditional or reject keyword.
- If the body itself errors (for example, calling an undefined function), the operation is aborted and the error is returned to the client.