# Property

## Overview

Properties are associated with a schema to describe different attributes of the schema. For example, a node schema `@card` may have properties such as *balance* and *openedOn*, while an edge schema `@transfersTo` may have properties like *amount* and *time*.

The expression `@<schema>.<property>` specifies a certain property of a schema, such as `@company.name`.

### System Property

Each node or edge schema comes with several system properties, which are created automatically with the schema and cannot have their names or types altered. They cannot be deleted either.

<table>
<thead>
<tr>
<th style="width: 7%;"></th>
<th style="width: 20%;">System Property</th>
<th style="width: 14%;">Data Type</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td rowspan="2"><b>Node</b></td>
<td><code>_id</code></td>
<td>String, with a maximum length of 128 bytes</td>
<td>String unique identifier of a node</td>
</tr>
<tr>
<td><code>_uuid</code></td>
<td>Uint64</td>
<td>Numeric unique identifier of a node</td>
</tr>
<tr>
<td rowspan="5"><b>Edge</b></td>
<td><code>_uuid</code></td>
<td>Uint64</td>
<td>Numeric unique identifier of an edge</td>
</tr>
<tr>
<td><code>_from</code></td>
<td>String</td>
<td><code>_id</code> of the start node of an edge</td>
</tr>
<tr>
<td><code>_to</code></td>
<td>String</td>
<td><code>_id</code> of the end node of an edge</td>
</tr>
<tr>
<td><code>_from_uuid</code></td>
<td>Uint64</td>
<td><code>_uuid</code> of the start node of an edge</td>
</tr>
<tr>
<td><code>_to_uuid</code></td>
<td>Uint64</td>
<td><code>_uuid</code> of the end node of an edge</td>
</tr>
</tbody>
</table>

#### Unique Identfier (UID)

Each **node** has two system properties, `_id` and `_uuid`, serving as its unique identifiers. The values of `_id` for all nodes are distinct, as are the values of `_uuid`. Additionally, there exists one-to-one correspondence between `_id` and `_uuid`.

Each **edge** has one system property, `_uuid`, as its unqiue identifer. The values of `_uuid` for all edges are distinct.

A node and an edge are allowed to have the same value of `_uuid`.

### Custom Property

You can create custom properties for each schema, such as *name*, *type*, and *time*. For more details, please refer to <a href="#Create-Property">Create Property</a>.

## Show Property

```js
// Show properties of all schemas in the graphset
show().property()

// Show properties of all node schemas in the graphset
show().node_property()

// Show properties of all edge schemas in the graphset
show().edge_property()

// Show properties of @user nodes in the graphset
show().node_property(@user)

// Show properties of @like edges in the graphset
show().edge_property(@like)
```

Example result:

`_nodeProperty`

| <div table-width=6>name</div> | <div table-width=6>type</div> | <div table-width=6>lte</div> | <div table-width=6>read</div> | <div table-width=6>write</div> | <div table-width=8>schema</div> | <div table-width=13>description</div> | extra | <div table-width=9>encrypt</div> | 
| -- | -- | -- | -- | -- | -- | -- | -- | -- |
| name | string | true | 1 | 1 | user | | {} | AES128 |
| rate | decimal | false | 1 | 1 | user | Average user rating | {"precision":65,"scale":30} | |

`_edgeProperty`

| <div table-width=6>name</div> | <div table-width=6>type</div> | <div table-width=6>lte</div> | <div table-width=6>read</div> | <div table-width=6>write</div> | <div table-width=8>schema</div> | <div table-width=13>description</div> | extra | <div table-width=9>encrypt</div> | 
| -- | -- | -- | -- | -- | -- | -- | -- | -- |
| time | timestamp | false | 1 | 0 | like | | {} | |

The returned result only contains custom properties; system properties are not included.

## Create Property

### Syntax

<p tit="Syntax"></p> 

```js
// Create a property for one node schema in the graphset
create().node_property(@<schema>, "<name>", <type?>, "<desc?>").encrypt()

// Create a property for all node schemas in the graphset
create().node_property(@*, "<name>", <type?>, "<desc?>").encrypt()

// Create a property for one edge schema in the graphset
create().edge_property(@<schema>, "<name>", <type?>, "<desc?>").encrypt()

// Create a property for all edge schemas in the graphset
create().edge_property(@*, "<name>", <type?>, "<desc?>").encrypt()

// Create multiple node/edge properties at one time
create()
  .node_property(@<schema>, "<name>", <type?>, "<desc?>").encrypt()
  .edge_property(@<schema>, "<name>", <type?>, "<desc?>").encrypt()
```

- Parameters for the `node_property()` or `edge_property()` method:
  - `@<schema>`: Specify the node or edge schema; `@*` denotes all node or edge schemas.
  - `<name>`: Name of the property.
  - `<type?>`: Data type of the property; when it is omitted, the type *string* is used by default.
  - `<desc?>`: Description of the property, it's optional.
- Chaining the `encrypt()` method when you want to encrypt the values of this property:
  - The encryption method is AES128.
  - Only textual-type (*string* or *text*) properties allow encryption.

### Naming Conventions

Here are the naming conventions for properties:

- Contains 2 to 64 characters.
- Not allowed to start with a tilde symbol `~`.
- Not allowed to contain backquote symbol `` ` ``.
- Not allowed to use any <a href="/docs/uql/reserved-words">reserved words</a>.

All properties under one schema must have distinct names. Different schemas may contain properties with the same name.

When the property name contains characters other than letters (A-Z, a-z), numbers (0-9) and underscores (`_`), the property name must be wrapped with a pair of backquotes (`` ` ``) when being used.

```js
find().nodes({`Last-name` == "White"}) as n
return n
```

### Create Integer Property

Supported interger data types include `int32`, `uint32`, `int64` and `uint64`.

```js
create().node_property(@course, "credits", int32, "Credits of the course")
```

### Create Decimal Property

Supported decimal data types include `float`, `double` and `decimal`.

```js
create()
  .node_property(@record, "score", float, "Score of the record")
  .edge_property(@connects, "weight",  "decimal(25,10)", "Weight of the relation")
```

The `decimal(25,10)` specifies a decimal type with a *precision* of 25 digits (total digits) and a *scale* of 10 digits (digits after the decimal point). You may set the precision between 1 to 65, and the scale between 0 to 30.

Specifically, the type of `decimal(<precision>, <scale>)` must be declared within two quotes when creating the property.

### Create Texual Property

Supported textual data types include `string` and `text`.

```js
create()
  .node_property(@post, "title")
  .node_property(@post, "content", text, "Main content of the post").encrypt()
```

*String* is used by default if no type is specified. The `encrypt()` method only applies to properties with the string or text type.

### Create Temporal Property

Supported temporal data types include `timestamp` and `datetime`.

```js
create()
  .node_property(@post, "createdOn", timestamp, "When the post is first created")
  .node_property(@post, "publishedOn", datetime, "When the post is published")
```

### Create Point Property

Supported point data type is `point`.

```js
create().node_property(@city, "position", point, "City location: latitude and longitude")
```

### Create Blob Property

Supported blob data type is `blob`.

```js
create()
  .node_property(@user, "profileImg", blob, "Store user profile image as binary large object")
```

### Create List Property

Supported list data types include `int32[]`, `int64[]`, `uint32[]`, `uint64[]`, `float[]`, `double[]`, `string[]`, `text[]`, `datetime[]` and `timestamp[]`.

```js
create()
  .node_property(@user, "interests", "string[]", "Store user interest tags as a list of strings")
```

Specifically, the type of list `<element_type>[]` must be declared within two quotes when creating the property.

### Create Set Property

Supported set data types include `set(int32)`, `set(int64)`, `set(uint32)`, `set(uint64)`, `set(float)`, `set(double)`, `set(string)`, `set(text)`, `set(datetime)` and `set(timestamp)`.

```js
create()
  .node_property(@user, "heights", "set(float)", "Store user heights history as a set")
```

Specifically, the type of set `set(<element_type>)` must be declared within two quotes when creating the property.

### Create a Property for All Schemas

```js
create().edge_property(@*, "time", datetime)
```

Instead of specifying one specific schema name, use `@*` to denote all node or edge schemas.

### Use TRY

Create three edge properties at the same time, but one of the names (*time*) is duplicated with an existing property.

```js
create()
  .edge_property(@default, "weight", int32)
  .edge_property(@default, "time", datetime)
  .edge_property(@default, "status", string)
```

The creation of the property *weight*, which was specified before the duplicated property, succeeds. However, the one (*status*) specified after the duplicated property fails, with the error message `Property exists!` returned.

```js
TRY create()
  .edge_property(@default, "weight", int32)
  .edge_property(@default, "time", datetime)
  .edge_property(@default, "status", string)
```

The creation of the properties is the same as above, though the error message is shielded by the `TRY` prefix, while returning the message `SUCCEED`.

## Alter Property

```js
// Alter name and description of the node property @user.status in the graphset
alter().node_property(@user.status).set({name: "Status", description: "Active or Inactive"})

// Alter name of the property status of all node schemas (if has) in the graphset
alter().node_property(@*.status).set({name: "state"})

// Modify name and description of the edge property @registers.time in the graphset
alter().node_property(@registers.time)
  .set({name: "createdOn", description: "Time for creation"})

// Modify description of the property time of all edge schemas (if has) in the graphset
alter().edge_property(@*.time).set({description: "Time for creation"})
```

The data type is not subject to change once a property is created.

## Drop Property

Dropping a property entails deleting the property along with all associated property values, LTE-ed values saved in memory, and indexes and full-text indexes created on disk for that property.

```js
// Drop the node property @card.branch from the graphset
drop().node_property(@card.branch)

// Drop the property branch of all node schemas (if has) from the graphset
drop().node_property(@*.branch)

// Drop the edge property @flows.time from the graphset
drop().edge_property(@flows.time)

// Drop the property time of all edge schemas (if has) from the graphset
drop().edge_property(@*.time)

// Drop multiple node/edge properties at one time
drop()
  .node_property(@card.branch)
  .edge_property(@*.time)
```
null
