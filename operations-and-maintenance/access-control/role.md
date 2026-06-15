# Role (Policy)

## Overview

A role (or policy) aggregates multiple privileges and can also include other roles, enabling hierarchical and modular access control. When designed and applied effectively, roles support robust role-based access control (RBAC), simplifying permission management and enhancing security.

Ultipa supports both GQL and UQL to manage roles in the database.

## Naming Conventions

All role names in the database must be unique and adhere to the following rules:

- Must be between 2 and 64 characters in length.
- Must begin with a letter (A–Z or a–z).
- May contain letters, numbers (0–9), and underscores (`_`) only.

## Using GQL

### Showing Roles

To list all roles defined in the database:

```gql
SHOW ROLE
```

### Creating a Role

To create a role named `Tester`:

```gql
CREATE ROLE Tester
```

### Renaming a Role

To rename the role `Tester` to `sales`:

```gql
ALTER ROLE Tester RENAME TO sales
```

### Granting to a Role

You can grant privileges and roles to a role. Note that the existing privileges and roles assigned to the role remain unchanged.

#### System Privileges

To grant system privileges `SHOW_GRAPH` and `ALTER_GRAPH` to the role `Tester`:

```gql
GRANT ["SHOW_GRAPH", "ALTER_GRAPH"] TO ROLE Tester
```

To grant all system privileges to the role `superADM`:

```gql
GRANT * TO ROLE superADM
```

#### Graph Privileges

To grant graph privilege `READ` for all graphs to the role `Tester`:

```gql
GRANT ["READ"] ON * TO ROLE Tester
```

To grant graph privileges `SHOW_INDEX` and `SHOW_JOB` for the graph `amz` to the role `Tester`:

```gql
GRANT ["SHOW_INDEX","SHOW_JOB"] ON amz TO ROLE Tester
```

To grant all graph privileges for all graphs to the role `superADM`:

```gql
GRANT * ON * TO ROLE superADM
```

#### Property Privileges

To grant property privileges `READ` to properties `name` and `age` of the `Person` nodes in the current graph to the role `Tester`:

```gql
GRANT ['READ','WRITE'] ON NODE Person (name, age) TO ROLE Tester
```

To grant the privilege `DENY` to all properties of all edges in the current graph to the role `sales`:

```gql
GRANT ["DENY"] ON EDGE * * TO ROLE sales
```

#### Roles

To grant the role `manager` to the role `Tester`:

```gql
GRANT ROLE manager TO ROLE Tester
```

### Revoking from a Role

You can revoke privileges and roles from a role.

#### System Privileges

To revoke system privileges `SHOW_POLICY` and `ALTER_GRAPH` from the role `Tester`:

```gql
REVOKE ["SHOW_POLICY", "ALTER_GRAPH"] FROM ROLE Tester
```

To revoke all system privileges from the role `sales`:

```gql
REVOKE * FROM ROLE sales
```

#### Graph Privileges

To revoke graph privileges `READ` and `UPDATE` on the graph `amz` from the role `Tester`:

```gql
REVOKE ["READ", "UPDATE"] ON amz FROM ROLE Tester
```

To revoke all graph privileges on all graphs from the role `sales`:

```gql
REVOKE * ON * FROM ROLE sales
```

#### Property Privileges

To revoke the privileges `READ` and `WRITE` to properties `name` and `age` of the `Person` nodes in the current graph from the role `Tester`:

```gql
REVOKE ['READ','WRITE'] ON NODE Person (name, age) FROM ROLE Tester
```

To revoke the privilege `DENY` to all properties of all edges in the current graph from the role `sales`:

```gql
REVOKE ["DENY"] ON EDGE * * FROM ROLE sales
```

#### Roles

To revoke the role `manager` from the role `Tester`:

```gql
REVOKE ROLE manager FROM ROLE Tester
```

### Dropping a Role

To drop the role `Tester`:

```gql
DROP ROLE Tester
```

## Using UQL

### Showing Roles

To list all roles defined in the database:

```uql
show().policy()
```

Or retrieves a specific policy, such as the one named `manager`:

```uql
show().policy("manager")
```

### Creating a Role

You can create a role and assign it privileges and other roles at the same time:

<p tit="Syntax"></p>

```uql
create().policy("<name>").params({
  system_privileges: ["<systemPriv>", "<systemPriv>", ...],
  // Set <graph> as * to specify all graphs
  graph_privileges: {
    "<graph>": ["<graphPriv>", "<graphPriv>", ...],
    "<graph>": ["<graphPriv>", "<graphPriv>", ...],
    ...
  },
  // Set <graph>/<schema>/<property> as * to specify all graphs/schemas/properties
  property_privileges: {
    "node": {
      "read": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "write": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "deny": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...]
    },
    "edge": {
      "read": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "write": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "deny": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...]
    }
  },
  policies: ["<policy>", "<policy>", ...]
})
```

To create a role `superADM` with all graph and system privileges:

```uql
create().policy("superADM").params({
  graph_privileges: {"*":["READ","INSERT","UPSERT","UPDATE","DELETE","CREATE_SCHEMA","DROP_SCHEMA","ALTER_SCHEMA","SHOW_SCHEMA","RELOAD_SCHEMA","CREATE_PROPERTY","DROP_PROPERTY","ALTER_PROPERTY","SHOW_PROPERTY","CREATE_FULLTEXT","DROP_FULLTEXT","SHOW_FULLTEXT","CREATE_INDEX","DROP_INDEX","SHOW_INDEX","LTE","UFE","CLEAR_JOB","STOP_JOB","SHOW_JOB","ALGO","CREATE_PROJECT","SHOW_PROJECT","DROP_PROJECT","CREATE_HDC_GRAPH","SHOW_HDC_GRAPH","DROP_HDC_GRAPH","COMPACT_HDC_GRAPH","SHOW_VECTOR_INDEX","CREATE_VECTOR_INDEX","DROP_VECTOR_INDEX","SHOW_CONSTRAINT","CREATE_CONSTRAINT","DROP_CONSTRAINT"]},
  system_privileges: ["TRUNCATE","COMPACT","CREATE_GRAPH","SHOW_GRAPH","DROP_GRAPH","ALTER_GRAPH","TOP","KILL","STAT","SHOW_POLICY","CREATE_POLICY","DROP_POLICY","ALTER_POLICY","SHOW_USER","CREATE_USER","DROP_USER","ALTER_USER","SHOW_PRIVILEGE","SHOW_META","SHOW_SHARD","ADD_SHARD","DELETE_SHARD","REPLACE_SHARD","SHOW_HDC_SERVER","ADD_HDC_SERVER","DELETE_HDC_SERVER","LICENSE_UPDATE","LICENSE_DUMP","GRANT","REVOKE","SHOW_BACKUP","CREATE_BACKUP","SHOW_VECTOR_SERVER","ADD_VECTOR_SERVER","DELETE_VECTOR_SERVER"]
})
```

To create a role `Tester` with:

- System privileges: `SHOW_GRAPH`, `ALTER_GRAPH`
- Graph privileges: `READ` for all graphs, `SHOW_INDEX` and `SHOW_JOB` for graphs `amz` and `trans`.
- Property privileges:
   - Node: `read` all node properties
   - Edge: `write` properties `rank` and `asset` for `edgx` edges and `read` property `mark` for all edges in the graph `amz`
- Roles: `manager`

```uql
create().policy("Tester").params({
  system_privileges: ["SHOW_GRAPH", "ALTER_GRAPH"],
  graph_privileges: {
    "*": ["READ", "SHOW_SCHEMA", "SHOW_PROPERTY"],
    "amz": ["SHOW_INDEX", "SHOW_JOB"],
    "trans": ["SHOW_INDEX", "SHOW_JOB"]
  },
  property_privileges: {
    "node": {
      "read": [["*", "*", "*"]]
    },
    "edge": {
      "read": [["amz", "*", "mark"]],
      "write": [
        ["amz", "edgx", "rank"],
        ["amz", "edgx", "asset"]
      ]
    }
  },
  policies: ["manager"]
})
```

### Granting to a Role

You can grant privileges and roles to a role. Note that the existing privileges and roles assigned to the role remain unchanged.

<p tit="Syntax"></p>

```uql
grant().policy("<name>").params({
  system_privileges: ["<systemPriv>", "<systemPriv>", ...],
  // Set <graph> as * to specify all graphs
  graph_privileges: {
    "<graph>": ["<graphPriv>", "<graphPriv>", ...],
    "<graph>": ["<graphPriv>", "<graphPriv>", ...],
    ...
  },
  // Set <graph>/<schema>/<property> as * to specify all graphs/schemas/properties
  property_privileges: {
    "node": {
      "read": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "write": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "deny": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...]
    },
    "edge": {
      "read": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "write": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "deny": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...]
    }
  },
  policies: ["<policy>", "<policy>", ...]
})
```

To grant the graph privileges `CREATE_SCHEMA` and `DROP_SCHEMA` of the graphset `Tax`, and system privilege `ADD_HDC_SERVER` to the role `Tester`:

```uql
grant().policy("Tester").params({
  graph_privileges: {"Tax": ["CREATE_SCHEMA", "DROP_SCHEMA"]},
  system_privileges: ["ADD_HDC_SERVER"]
})
```

### Revoking from a Role

You can revoke privileges and roles from a role.

<p tit="Syntax"></p>

```uql
revoke().policy("<name>").params({
  system_privileges: ["<systemPriv>", "<systemPriv>", ...],
  // Set <graph> as * to specify all graphs
  graph_privileges: {
    "<graph>": ["<graphPriv>", "<graphPriv>", ...],
    "<graph>": ["<graphPriv>", "<graphPriv>", ...],
    ...
  },
  // Set <graph>/<schema>/<property> as * to specify all graphs/schemas/properties
  property_privileges: {
    "node": {
      "read": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "write": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "deny": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...]
    },
    "edge": {
      "read": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "write": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "deny": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...]
    }
  },
  policies: ["<policy>", "<policy>", ...]
})
```
To revoke the graph privileges `CREATE_SCHEMA` and `DROP_SCHEMA` of the graph `Tax`, and system privilege `ADD_HDC_SERVER` from the role `Tester`:

```uql
revoke().policy("Tester").params({
  graph_privileges: {"Tax": ["CREATE_SCHEMA", "DROP_SCHEMA"]},
  system_privileges: ["ADD_HDC_SERVER"]
})
```

### Altering a Role

You can alter privileges and roles assigned to a role. Note that only the specified items will be updated, others remain unchanged.

<p tit="Syntax"></p>

```uql
alter().policy("<name>").set({
  system_privileges: ["<systemPriv>", "<systemPriv>", ...],
  // Set <graph> as * to specify all graphs
  graph_privileges: {
    "<graph>": ["<graphPriv>", "<graphPriv>", ...],
    "<graph>": ["<graphPriv>", "<graphPriv>", ...],
    ...
  },
  // Set <graph>/<schema>/<property> as * to specify all graphs/schemas/properties
  property_privileges: {
    "node": {
      "read": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "write": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "deny": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...]
    },
    "edge": {
      "read": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "write": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...],
      "deny": [["<graph>", "<schema>", "<property>"],["<graph>", "<schema>", "<property>"],...]
    }
  },
  policies: ["<policy>", "<policy>", ...]
})
```

To modify only the graph privileges assigned to the role `Tester`:

```uql
alter().policy("Tester").set({graph_privileges: {"Tax": ["UPDATE"]}})
```

To modify the graph and property privileges, and roles included in the policy `Tester`:

```uql
alter().policy("Tester").set({
  graph_privileges: {"*": ["UPDATE", "DELETE"]},
  property_privileges: {
    "node": {
      "write": [["miniCircle","*","*"]]
    },
    "edge": {
      "write": [["miniCircle","*","*"]]
    }
  },
  policies: ["sales"]
})
```

### Dropping a Role

To drop the role `Tester`:

```uql
drop().policy("Tester")
```
