# Policy

A policy is a combination of multiple privileges packed for a specific user role, it often comprises multiple privileges and sub policies. User privileges can be more conveniently and better managed with a proper design and usage of policy.

## Naming Conventions

Policies are named by developers. A same name cannot be shared between policies in an Ultipa instance.

- 2 ~ 64 characters
- Must start with letters
- Allow to use letters, underscore and numbers ( _ , A-Z, a-z, 0-9)

## Show Policy

Returned table name: `_policy`
<br>
Returned table header: `name` | `graphPrivileges` | `systemPrivileges` | `propertyPrivileges` | `policies` (the name, graph privileges, system privileges, property privileges and sub policies of the policy)

Syntax:
<p tit="Syntax"></p>

```js
// To show all policies in the current Ultipa instance
show().policy()

// To show a certain policy in the current Ultipa instance
show().policy("<name>")
```

## Create Policy

Syntax:
<p tit="Syntax"></p>

```js
// To create a policy in the current Ultipa instance
create().policy(
  "<name>", 
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
Note 2: When top items of parameter `policy()` are not to be declared, their slots still need to be held by empty braces if the items that come later are to be declared.


Example: Create policy "sales" that has privilege UPDATE against GraphSet "default" and "client", system privilege STAT, and READ for all properties
```js
create().policy(
  "sales", 
  {"default": ["UPDATE"], "client":["UPDATE"]}, 
  ["STAT"],
  [],
  {
    "node": {"read":[["*","*","*"]]},
    "edge": {"read":[["*","*","*"]]}
  }
)
```


## Alter Policy

Syntax:
<p tit="Syntax"></p>

```js
// To modify a certain policy in the current Ultipa instance
alter().policy("<name>").set({ 
  graph_privileges: <{}graph_privileges?>, 
  system_privileges: <[]system_privileges?>, 
  policies: <[]policies?>,
  property_privileges: <{}property_privileges?>
})
```

Where the data structures `<{}graph_privileges>` and `<{}property_privileges>` are same as those in command `create().policy()`.

Example: Modify policy "sales", make it only has UPDATE against graphset "default"

```js
alter().policy("sales")
  .set({graph_privileges: {"default": ["UPDATE"]}})
```

Example: Modify policy "management", let it has UPDATE and DELETE against all graphsets, sub policy "sales", and all related property privileges.

```js
alter().policy("management").set({
  graph_privileges: {"*": ["UPDATE", "DELETE"]},
  policies: ["sales"],
  property_privileges: {
    "node": {
      "write": [["default","*","*"]]
    },
    "edge": {
      "write": [["default","*","*"]]
    }
  }  
})
```

## Drop Policy

Syntax:
<p tit="Syntax"></p>

```js
// To delete a certain policy from the current Ultipa instance
drop().policy("<name>")
```

