# User

A user is a combination of multiple privileges and policies, it has similar composition with a policy. 


## Naming Conventions

Username cannot be shared between users in an Ultipa instance.

- 2 ~ 64 characters
- Must start with letters
- Allow to use letters, underscore and numbers ( _ , A-Z, a-z, 0-9)
- Length of password is 6~64 and no constraint on characters used

## Show User

Returned table name: `_user`
<br>
Returned table header: `username` | `create` | `graphPrivileges` | `systemPrivileges` | `propertyPrivileges` | `policies` (username, creation time, graph privileges, system privileges, property privileges, sub policies)

Syntax:
<p tit="Syntax"></p>

```js
// To show all users in the current Ultipa instance
show().user()

// To show a certain user in the current Ultipa instance
show().user("<name>")

// To show the current logged-on user
show().self()
```

## Create User

Syntax:
<p tit="Syntax"></p>

```js
// To create a user in the current Ultipa instance
create().user(
  "<username>", 
  "<password>", 
  <{}graph_privileges?>, 
  <[]system_privileges?>, 
  <[]policies?>, 
  <{}property_privileges?>
)
```

Where the data structures are:
<p tit="Syntax"></p>

```js
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

Note 1: When using asterisk `*` to replace the GraphSet name `<graphSet>`, the `"*"` means all GraphSets in the current Ultipa instance. Similarly, the `"*"` in replace of `"<@schema>"` or `"<property>"` represents all the schemas or all properties.
<br>
Note 2: When top tiems of parameter `user()` are not to be declared, their slots still need to be held by empty braces if the items that come later are to be declared.

Example: Create user "Ultipa" with password "ultipaABC123", grant graph privileges UPDATE, ALGO, LTE and UFE for all GraphSets, system privileges STAT, TOP and KILL, and property privilege WRITE to all properties of all GraphSets

```js
create().user(
  "Ultipa",   
  "ultipaABC123",
  {"*": ["UPDATE","ALGO","LTE","UFE"]},  
  ["STAT","TOP","KILL"], 
  [],
  {
    "node": {
      "write": [["*","*","*"]]
    },
    "edge": {
      "write": [["*","*","*"]]
    }
  }
)
```

## Alter User

Syntax:
<p tit="Syntax"></p>

```js
// To modify the a certain user in the current Ultipa instance
alter().user("<username>").set({
  password:"<new?>", 
  graph_privileges: <{}graph_privileges?>, 
  system_privileges: <[]system_privileges?>, 
  policies: <[]policies?>,
  property_privileges: <{}property_privileges?>
})
```

Where the data structures `<{}graph_privileges>` and `<{}property_privileges>` are same as those in command `create().user()`.

Example：Modify user <i>Ultipa</i>'s password to "ultipaFast"

```js
alter().user("Ultipa")
  .set({password: "ultipaFast"})
```

Example：Modify user <i>Ultipa</i>, make it only able to acquire metadata of GraphSet "default"

```js
alter().user("Ultipa").set({
  graph_privileges: {"default": ["FIND"]},
  property_privileges: {
    "node": {
      "read": [["default","*","*"]]
    },
    "edge": {
      "read": [["default","*","*"]]
    }
  }
})
```
Analysis: Users can query and return metadata of 'default' only when both FIND and READ are granted for 'default' and its metadata.

## Drop User

Syntax:
<p tit="Syntax"></p>

```js
// To delete a certain user from the current Ultipa instance
drop().user("<name>")
```

## Reset Admin User

Resetting admin user needs to be done on Ultipa Server with `ultipa-reset-user` tool, which is not in the scope of UQL operation.
