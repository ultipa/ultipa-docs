# Trigger

Triggers of pre-defined UQL operations can be executed at different occasions such as before or after a modification of metadata of a specifed schema, hereby achieving automatic execution of business logic bound to DML operations.


## Naming Conventions

Trigger is named by developers. A same name can be shared between a node trigger and an edge trigger, but not between node triggers, or edge triggers.

- 2 ~ 64 characters
- Must start with letters
- Allow to use letters, underscore and numbers ( _ , A-Z, a-z, 0-9)

## Show Trigger

Returned table name: `_nodeTrigger`、`_edgeTrigger`
<br>
Returned table header: `id`|`name`|`schema`|`description`|`when`|`operation`|`uqls`(The ID, name, schema, description, timming [before|after], modification type [insert|upsert|update|delete] and UQL content of the trigger)

Syntax:
<p tit="Syntax"></p>

```uql
// To show all triggers in the current graphset (node triggers and edge triggers in separate tables)
show().trigger() 

// To show all node triggers in the current graphset
show().node_trigger()

// To show all edge triggers in the current graphset
show().edge_trigger()
```

## Create Trigger

Syntax:
<p tit="Syntax"></p>

```uql
// To create trigger for a certain node schema in the current graphset
create().node_trigger("<name>", @<schema>, "<desc?>")
  .<before|after>("<insert|update|upsert|delete>")
  .on("with node <subUQLs>") 

// To create trigger for a certain edge schema in the current graphset
create().edge_trigger("<name>", @<schema>, "<desc?>")
  .<before|after>("<insert|update|upsert|delete>")
  .on("with edge <subUQLs>") 
```

Example: Create trigger for nodes of @student, converting value of property <i>name</i> to uppercase before insert operation
```uql
create().node_trigger("AutoUpperCase", @student).before("insert").on(
  "
  with node
  let node.name = upper(node.name) 
  "
)
```

## Drop Trigger

Deleting a schema will also delete its trigger.

Syntax:
<p tit="Syntax"></p>

```uql
// To delete a certain node trigger
drop().node_trigger("<name>")


// To delete a certain edge trigger
drop().edge_trigger("<name>")
```

Example: Delete node trigger 'AutoUpperCase' 
```uql
drop().node_trigger("AutoUpperCase")
```

Example: Delete edge trigger 'AutoFloor' 
```uql
drop().edge_trigger("AutoFloor")
```

## Use of Trigger

After creating a trigger, compose and execute UQL based on the specified schema and operation type.

Example: Use trigger to automatically abstract the year from a <i>datetime</i> edge property and insert as another edge proeprty
```uql
// Create edge trigger 'AbstractYear'
create().edge_trigger("AbstractYear", @studyAt).before("insert").on(
  "
  with edge
  let edge.graduateYear = year(edge.graduateDate) 
  "
)
```

```uql
// Insert an edge of @studyAt and return this edge
insert().into(@studyAt).edges([{GPA: 4.3, graduateDate: "2022-06-03", _from: "STU001", _to: "UNV003"}]) as n
return n{*}
```
<p tit="Result"></p>

```
|------------------------------ @studyAt ----------------------------|
| _uuid | _from  |  _to   | GPA |     graduateDate    | graduateYear |
|-------|--------|--------|-----|---------------------|--------------|
|   34  | STU001 | UNV003 | 4.3 | 2022-06-03 00:00:00 |     2022     |
```
