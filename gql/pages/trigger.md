# Triggers

## Overview

A trigger is a mechanism that automatically executes predefined operations in response to specific events on nodes or edges. Triggers can be set to run **before or after** events such as **insertion, update, or deletion of data**. They allow you to enforce business rules, maintain data integrity, or perform auxiliary operations without manual intervention, ensuring that logic tied to DML operations is executed consistently and automatically.

## Showing Triggers

To show triggers in the current graph:

```gql
SHOW TRIGGER
```

To show node triggers in the current graph:

```gql
SHOW NODE TRIGGER
```

To show edge triggers in the current graph:

```gql
SHOW EDGE TRIGGER
```

Each trigger provides the following essential metadata:

| <div table-width="17">Field</div> | Description |
| -- | -- |
| `name` | The name of the trigger. |
| `schema` | The name of node or edge schema to which the trigger applies. |
| `description` | The comment given to the trigger. |
| `timing` | When the trigger takes effect — either `before` or `after` the event. |
| `event` | The type of event that activates the trigger, including `insert`, `update`, and `delete`. |
| `call` | The operation or logic executed by the trigger. |

## Creating Trigger

To create a trigger `AutoUpperCase` for `Student` nodes that converts the `name` property to uppercase before insertion:

```gql
CREATE TRIGGER "AutoUpperCase" ON NODE "Student" 
COMMENT "Converts name to uppercases before insertion" 
BEFORE INSERT CALL "
  $entity CALL {
    LET entity.name = upper(entity.name)
  }
"
```

This trigger automatically converts the `name` property of a `Student` node to uppercase before insertion:

```gql
INSERT (n:Student {name: "John Doe"}) RETURN n.name
```

Result:

| n.name |
| -- |
| JOHN DOE |

To create a trigger `AutoStaus` for `ENROLLED_IN` edges, automatically setting the `status` property to "active" before insertion:

```gql
CREATE TRIGGER "AutoStaus" ON EDGE "ENROLLED_IN"
COMMENT "Sets status to true"
BEFORE INSERT CALL "
  $entity CALL {
    LET entity.status = 'active'
  }
"
```

This trigger automatically sets the `status` property of an `ENROLLED_IN` edge to "active" before insertion:

```gql
MATCH (s:Student {name: "JOHN DOE"}), (c:Course {name: "Science"})
INSERT (s)-[e:ENROLLED_IN]->(c)
RETURN e.status
```

Result:

| e.status |
| -- |
| active |

## Dropping Trigger

To drop the node trigger `AutoUpperCase`:

```gql
DROP NODE TRIGGER AutoUpperCase
```

To drop the edge trigger `AutoStaus`:

```gql
DROP EDGE TRIGGER AutoStaus
```

**Note:** Dropping a node or edge schema will also remove any triggers associated with that schema.
