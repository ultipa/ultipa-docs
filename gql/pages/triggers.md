# Triggers

A trigger automatically executes predefined operations in response to specific data events on nodes. Triggers can run **before or after** an **insert** operation, allowing you to enforce business rules, maintain data integrity, or perform auxiliary operations without manual intervention.

## CREATE TRIGGER

<p tit="Syntax"></p>

```gql
CREATE TRIGGER "triggerName" ON NODE "labelName"
  [COMMENT 'description']
  BEFORE|AFTER INSERT
  CALL " $entity call { ... } "
```

- `triggerName`: The identifier for the trigger, must be unique within the graph.
- `labelName`: The node label the trigger is associated with. The label does not need to exist at creation time; the trigger will not fire until the label is created.
- `COMMENT`: An optional description of what the trigger does.
- `BEFORE|AFTER INSERT`: When the trigger fires relative to the insert operation.
- `CALL`: The callable body that defines the trigger logic.

### Timing

- **BEFORE INSERT**: Fires before the node is inserted. Can modify entity properties. If the trigger returns an error, the insert is aborted.
- **AFTER INSERT**: Fires after the node is inserted. Executes for side effects only. Errors are logged but do not roll back the already-committed insert.

### Callable Body

The trigger body uses the format `$entity call { ... }` and supports `let` assignments to modify entity properties. The `let` keyword must be lowercase.

<p tit="Single Assignment"></p>

```
$entity call { let entity.propertyName = expression }
```

Multiple assignments can be separated by semicolons:

<p tit="Multiple Assignments"></p>

```
$entity call { 
  let entity.name = upper(entity.name); 
  let entity.role = 'employee' 
}
```

### Supported Expressions

| Expression Type | Example | Description |
| -- | -- | -- |
| String literal | `'active'`, `"active"` | A quoted string value. |
| Numeric literal | `18`, `3.14` | An integer or float value. |
| Property access | `entity.name` | Reads a property from the current entity. |
| Function call | `upper(entity.name)` | Applies a built-in function to an expression. |

### Built-in Functions

| <div table-width="30">Function</div> | Description |
| -- | -- |
| `upper(value)` | Converts a string to uppercase. |
| `lower(value)` | Converts a string to lowercase. |
| `trim(value)` | Removes leading and trailing whitespace from a string. |
| `len(value)` / `length(value)` | Returns the length of a string. |

### Examples

Create a trigger that converts the `name` property to uppercase before insertion:

```gql
CREATE TRIGGER "AutoUpperCase" ON NODE "Student"
  COMMENT 'Converts name to uppercase before insertion'
  BEFORE INSERT
  CALL " $entity call { let entity.name = upper(entity.name) } "
```

Now inserting a `Student` node will automatically uppercase the `name`:

```gql
INSERT (n:Student {name: "John Doe"}) RETURN n.name
```

| n.name |
| -- |
| JOHN DOE |

Create a trigger that sets a default property value:

```gql
CREATE TRIGGER "DefaultRole" ON NODE "Employee"
  COMMENT 'Sets default role to intern'
  BEFORE INSERT
  CALL " $entity call { let entity.role = 'intern' } "
```

## DROP TRIGGER

<p tit="Syntax"></p>

```gql
-- Drop a trigger (error if not found)
DROP TRIGGER "triggerName"

-- Drop only if it exists (no error if not found)
DROP TRIGGER IF EXISTS "triggerName"
```

> Dropping a node label will also remove any triggers associated with that label.

## SHOW TRIGGERS

<p tit="Syntax"></p>

```gql
-- List all triggers in the current graph
SHOW TRIGGERS

-- Filter by node label
SHOW TRIGGERS ON NODE "labelName"

-- Filter by edge label
SHOW TRIGGERS ON EDGE "labelName"
```

Returns a table with the following columns:

| <div table-width="15">Field</div> | Description |
| -- | -- |
| `name` | The name of the trigger. |
| `entity_type` | The entity type: `NODE`. |
| `label` | The node label the trigger is associated with. |
| `event` | The trigger event, such as `BEFORE_INSERT` or `AFTER_INSERT`. |
| `enabled` | Whether the trigger is active. |
| `comment` | The optional description of the trigger. |

## Execution Behavior

- When multiple triggers match the same event, they execute sequentially. Each trigger receives the modified properties from the previous trigger.
- **BEFORE INSERT** triggers can modify entity properties. If a `BEFORE` trigger fails, the insert is aborted.
- **AFTER INSERT** triggers execute for side effects. If an `AFTER` trigger fails, the error is logged but the insert is not rolled back.
- When a node has multiple labels, triggers execute for each label independently.