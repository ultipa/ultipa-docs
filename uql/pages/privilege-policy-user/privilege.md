# Privilege

Privileges are the basic content of user authentication. Privileges are categorized into Command Privileges and Property Privileges.

<b>Command Privileges</b> allow users to execute particular UQL commands. According to the scope of the UQL command, they are divided into: 

- Graph privilege:
  -  Allow users to execute UQLs related to the schema, property, index, metadata, path, algorithm and backend task of a specific GraphSet
  -  GraphSet name should be appointed when granting graph privileges
- System privilege:
  -  Allow users to execute UQLs related to the privilege, policy, user, GraphSet and UQL process of an Ultipa Graph database

> Refer to the Table of Privileges at the end of this article for all the command privileges and their corresponding UQL commands.

<b>Property Privileges</b> allow or refuse users to read (query and return) and write (insert, update and delete) particular custom properties. GraphSet and schema should be appointed:

- READ: Allow users to read particular custom properties
- WRITE：Allow users to read and write particular custom properties
- DENY：Do NOT allow users to read or write particular custom properties

> DENY has a higher priority than READ and WRITE. If a user or a policy is granted with DENY and READ (or WRITE) at the same time, the effective one is DENY.

## Show Privilege

Returned table name: `_privilege`
<br>
Returned table header: `graphPrivileges` | `systemPrivileges` (graph privileges, system privileges)

Syntax:
<p tit="Syntax"></p>

```uql
// To list all command privileges supported by Ultipa system
show().privilege()
```

## Grant Privilege

### Grant Property Privilege

Syntax:
<p tit="Syntax"></p>

```uql
// To grant node and edge property privileges to a user/policy
grant().privilege(["READ" | "WRITE" | "DENY"]).on(
  "<graph>", 
  <@schema?>, 
  "<property?>"
).<user|policy>("<name>")

// To grant node property privileges to a user/policy
grant().node_privilege(["READ" | "WRITE" | "DENY"]).on(
  "<graph>", 
  <@schema?>, 
  "<property?>"
).<user|policy>("<name>")
        
// To grant edge property privileges to a user/policy
grant().edge_privilege(["READ" | "WRITE" | "DENY"]).on(
  "<graph>", 
  <@schema?>, 
  "<property?>"
).<user|policy>("<name>")
```

Example: Grant READ of property <i>@product.price</i> of GraphSet <i>supplychain</i> to policy <i>sales</i>
```uql
grant().node_privilege(["READ"]).on(
  "supplychain",
  @product,
  "price"
).policy("sales")
```

Example: Grant WRITE of all properties of all GraphSets to user <i>admin002</i>
```uql
grant().privilege(["WRITE"]).on(
  "*",
  @*,
  "*"
).user("admin002")
```
Analysis: The parameter `on()` in this example can be shortened as `on("*")`


### Grant System Privilege

Syntax：
<p tit="Syntax"></p>

```uql
// To grant system privileges to a user/policy
grant().system().privilege(<[]system_privileges>).<user|policy>("<name>")
```

Example: Grant system privileges TOP and KILL to user <i>admin002</i>
```uql
grant().system().privilege(["TOP","KILL"]).user("admin002")
```

### Grant Multi-type Privilege

Syntax：
<p tit="Syntax"></p>

```uql
// To grant privileges of different types to a user/policy
grant().user("<username>").params({
  graph_privileges: <{}graph_privileges?>, 
  system_privileges: <[]system_privileges?>, 
  property_privileges: <{}property_privileges?>, 
  policies: <[]policies?>
})
```

Where the data structures are:
<p tit="Syntax"></p>

```uql
// <{}graph_privileges>
{
  "<graph1>":["<graph_privilege>", "<graph_privilege>", ...],
  "<graph2>":["<graph_privilege>", "<graph_privilege>", ...],
  ...
}

// <{}property_privileges>
{
  "node": {
    "read": [
      ["<graph>", "<@schema?>", "<property?>"],
      ["<graph>", "<@schema?>", "<property?>"],
      ...
    ],
    "write": [
      ["<graph>", "<@schema?>", "<property?>"],
      ["<graph>", "<@schema?>", "<property?>"],
      ...
    ],
    "deny": [
      ["<graph>", "<@schema?>", "<property?>"],
      ["<graph>", "<@schema?>", "<property?>"],
      ...
    ],
  },
  "edge": {
    "read": [
      ["<graph>", "<@schema?>", "<property?>"],
      ["<graph>", "<@schema?>", "<property?>"],
      ...
    ],
    "write": [
      ["<graph>", "<@schema?>", "<property?>"],
      ["<graph>", "<@schema?>", "<property?>"],
      ...
    ],
    "deny": [
      ["<graph>", "<@schema?>", "<property?>"],
      ["<graph>", "<@schema?>", "<property?>"],
      ...
    ],
  }
}
```


Example: Grant UPDATE of all GraphSets, system privilege STAT, WRITE of all properties of all GraphSets, and policy <i>management</i> to user <i>Ultipa</i>
```uql
grant().user("Ultipa").params({
  graph_privileges: {"*": ["UPDATE"]}, 
  system_privileges: ["STAT"],
  property_privileges: {
    "node": {
      "write": [["*", "*", "*"]]
    },
    "edge": {
      "write": [["*", "*", "*"]]
    }
  },
  policies: ["management"]
})
```


## Revoke Privilege

### Revoke Property Privilege

Syntax:
<p tit="Syntax"></p>

```uql
// To revoke node and edge property privileges from a user/policy
revoke().privilege(["READ" | "WRITE" | "DENY"]).on(
  "<graph>", 
  <@schema?>, 
  "<property?>"
).<user|policy>("<name>")

// To revoke node property privileges from a user/policy
revoke().node_privilege(["READ" | "WRITE" | "DENY"]).on(
  "<graph>", 
  <@schema?>, 
  "<property?>"
).<user|policy>("<name>")
        
// To revoke edge property privileges from a user/policy
revoke().edge_privilege(["READ" | "WRITE" | "DENY"]).on(
  "<graph>", 
  <@schema?>, 
  "<property?>"
).<user|policy>("<name>")
```

Example: Revoke READ of property <i>@product.price</i> of GraphSet <i>supplychain</i> from policy <i>sales</i>
```uql
revoke().node_privilege(["READ"]).on(
  "supplychain",
  @product,
  "price"
).policy("sales")
```

Example: Revoke WRITE of all properties of all GraphSets from user <i>admin002</i>
```uql
revoke().privilege(["WRITE"]).on(
  "*",
  @*,
  "*"
).user("admin002")
```
Analysis: The parameter `on()` in this example can be shortened as `on("*")`


### Revoke System Privilege

Syntax：
<p tit="Syntax"></p>

```uql
// To revoke system privileges from a user/policy
revoke().system().privilege(<[]system_privileges>).<user|policy>("<name>")
```

Example: Revoke system privileges TOP and KILL from user <i>admin002</i>
```uql
revoke().system().privilege(["TOP","KILL"]).user("admin002")
```

### Revoke Multi-type Privilege

Syntax：
<p tit="Syntax"></p>

```uql
// To revoke privileges of different types from a user/policy
revoke().user("<username>").params({
  graph_privileges: <{}graph_privileges?>, 
  system_privileges: <[]system_privileges?>, 
  property_privileges: <{}property_privileges?>, 
  policies: <[]policies?>
})
```

Where the data structures `<{}graph_privileges>` and `<{}property_privileges>` are same as those in command `grant()`.



Example: Revoke UPDATE of all GraphSets, system privilege STAT, WRITE of all properties of all GraphSets, and policy <i>management</i> from user <i>Ultipa</i>
```uql
revoke().user("Ultipa").params({
  graph_privileges: {"*": ["UPDATE"]}, 
  system_privileges: ["STAT"],
  property_privileges: {
    "node": {
      "write": [["*", "*", "*"]]
    },
    "edge": {
      "write": [["*", "*", "*"]]
    }
  },
  policies: ["management"]
})
```


## Table of Privileges

### User Related Privileges

| Privilege      | Level  | Legal Command        |
| -------------- | ------ | -------------------- |
| SHOW_PRIVILEGE | system | `show().privilege()` |
| SHOW_POLICY	 | system | `show().policy()`    |
| CREATE_POLICY	 | system | `create().policy()`  |
| ALTER_POLICY	 | system | `alter().policy()`   |
| DROP_POLICY    | system | `drop().policy()`    |
| SHOW_USER		 | system | `show().user()`      |
| CREATE_USER	 | system | `create().user()`    |
| ALTER_USER	 | system | `alter().user()`     |
| DROP_USER		|  system | `drop().user()`		|
| GRANT			|  system | `grant()`			|
| REVOKE		|  system | `revoke()`			|

Note: Command `show().self()` can be legally used by any user without authorization.

### Graph Model Related Privileges

| Privilege       | Level  | Legal Command  |
| --------------- | ------ | -------------- |
| STAT            | system | `stats()` |
| SHOW_GRAPH	  | system | `show().graph()` |
| CREATE_GRAPH	  | system | `create().graph()` |
| ALTER_GRAPH	  | system | `alter().graph()` |
| DROP_GRAPH	  | system | `drop().graph()` |
| MOUNT_GRAPH     | system | `mount()` |
| UNMOUNT_GRAPH   | system | `unmount()` |
| SHOW_SCHEMA	  | graph  | `show().schema()`, `show().node_schema()`, `show().edge_schema()` |
| CREATE_SCHEMA	  | graph  | `create().node_schema()`, `create().edge_schema()` |
| ALTER_SCHEMA	  | graph  | `alter().node_schema()`, `alter().edge_schema()` |
| DROP_SCHEMA     | graph  | `drop().node_schema()`, `drop().edge_schema()` |
| SHOW_PROPERTY	  | graph  | `show().property()`, `show().node_property()`, `show().edge_property()` |
| CREATE_PROPERTY | graph  | `create().node_property()`, `create().edge_property()` |
| ALTER_PROPERTY  | graph  | `alter().node_property()`, `alter().edge_property()` |
| DROP_PROPERTY	  | graph  | `drop().node_property()`, `drop().edge_property()` |
| SHOW_FULLTEXT	  | graph  | `show().fulltext()`, `show().node_fulltext()`, `show().edge_fulltext()` |
| CREATE_FULLTEXT | graph  | `create().node_fulltext()`, `create().edge_fulltext()` |
| DROP_FULLTEXT	  | graph  | `drop().node_fulltext()`, `drop().edge_fulltext()` |
| SHOW_INDEX      | graph  | `show().index()`, `show().node_index()`, `show().edge_index()` |
| CREATE_INDEX    | graph  | `create().node_index()`, `create().edge_index()` |
| DROP_INDEX      | graph  | `drop().node_index()`, `drop().edge_index()` |
| LTE             | graph  | `LTE()` |
| UFE             | graph  | `UFE()` |
| TRUNCATE        | system | `truncate()` |
| COMPACT		  | system | `compact()` |

### Graph Data Related Privileges

| Privilege | Level | Legal Command |
| --------- | ----- | ------------- |
| INSERT    | graph | `insert()`, `insert().overwrite()` |
| UPSERT    | graph | `upsert()`    |
| UPDATE    | graph | `update()`    |
| DELETE    | graph | `delete()`    |
| DELETE_NODE | graph  | `delete().nodes()`
| DELETE_EDGE | graph  | `delete().edges()`
| TEMPLATE  | graph | `n()`, `e()`, `re()`, `le()`, `nf()`, `graph()` |
| KHOP		| graph | `khop()`      |
| AB		| graph | `ab()`        |
| SPREAD	| graph | `spread()`    |
| AUTONET	| graph | `autonet()`   |
| FIND		| graph | `find()`      |
| FIND_NODE	| graph | `find().nodes()`
| FIND_EDGE	| graph | `find().edges()`

### Advanced Privileges

| Privilege  | Level  | Legal Command   |
| ---------- | ------ | --------------- |
| ALGO 		 | graph  | `algo()`        |
| SHOW_ALGO  | graph  | `show().algo()` |
| SHOW_TASK  | graph  | `show().task()` |
| CLEAR_TASK | graph  | `clear()`       |
| STOP_TASK	 | graph  | `stop()`        |
| SHOW_BACKUP  		| graph  | `db.backup.show() `		|
| CREATE_BACKUP 	| graph  | `db.backup.create()`     |
| RESTORE_BACKUP	| graph  | `db.backup.restore()`    |
| TOP        | system | `top()`         |
| KILL       | system | `kill()`        |
| SHOW_TRIGGER 	| graph  | `show().trigger()`, `show().node_trigger()`, `show().edge_trigger()`
| CREATE_TRIGGER | graph  | `create().node_trigger()`, `create().edge_trigger()`
| DROP_TRIGGER 	| graph  | `drop().node_trigger()`, `drop().edge_trigger()`

