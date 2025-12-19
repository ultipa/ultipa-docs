# User

## Overview

A database user can access the database system and perform querying and administrative operations based on their assigned privileges.

Ultipa supports both GQL and UQL to manage users in the database.

## Naming Conventions

All usernames in the database must be unique and adhere to the following rules:

- Must be between 2 and 64 characters in length.
- Must begin with a letter (A–Z or a–z).
- May contain letters, numbers (0–9), and underscores (`_`) only.

## Using GQL

### Showing Users

To list all database users:

```gql
SHOW USER
```

### Creating a User

To create a user `johndoe` with a password:

```gql
CREATE USER johndoe WITH PASSWORD 'mHMUUjQWG46z'
```

The password of the user must be between 6 to 64 characters in length.

### Altering a User

You can alter the username and password of a user.

To rename user `johndoe` to `johndoe_1`:

```gql
ALTER USER johndoe RENAME TO johndoe_1
```

To update the password for user `admin`:

```gql
ALTER USER admin SET PASSWORD 'zdcsQ7QFaCCE'
```

### Granting to a User

You can grant privileges and roles to a user. Note that the existing privileges and roles assigned to the user remain unchanged.

#### System Privileges

To grant system privileges `SHOW_POLICY` and `ALTER_GRAPH` to the user `johndoe`:

```gql
GRANT ["SHOW_POLICY", "ALTER_GRAPH"] TO johndoe
```

To grant all system privileges to the user `johndoe`:

```gql
GRANT * TO johndoe
```

#### Graph Privileges

To grant graph privileges `READ` and `UPDATE` on the graph `amz` to the user `johndoe`:

```gql
GRANT ["READ", "UPDATE"] ON amz TO johndoe
```

To grant all graph privileges on all graphs to the user `johndoe`:

```gql
GRANT * ON * TO johndoe
```

#### Property Privileges

To grant the privileges `READ` and `WRITE` to properties `name` and `age` of the `Person` nodes in the current graph to the user `johndoe`:

```gql
GRANT ['READ','WRITE'] ON NODE Person (name, age) TO johndoe
```

To grant the privilege `DENY` to all properties of all edges in the current graph to the user `johndoe`:

```gql
GRANT ["DENY"] ON EDGE * * TO johndoe
```

#### Roles

To grant the role `manager` to the user `johndoe`:

```gql
GRANT ROLE manager TO johndoe
```

### Revoking from a User

You can revoke privileges and roles from a user.

#### System Privileges

To revoke system privileges `SHOW_POLICY` and `ALTER_GRAPH` from the user `johndoe`:

```gql
REVOKE ["SHOW_POLICY", "ALTER_GRAPH"] FROM johndoe
```

To revoke all system privileges from the user `johndoe`:

```gql
REVOKE * FROM johndoe
```

#### Graph Privileges

To revoke graph privileges `READ` and `UPDATE` on the graph `amz` from the user `johndoe`:

```gql
REVOKE ["READ", "UPDATE"] ON amz FROM johndoe
```

To revoke all graph privileges on all graphs from the user `johndoe`:

```gql
REVOKE * ON * FROM johndoe
```

#### Property Privileges

To revoke the privileges `READ` and `WRITE` to properties `name` and `age` of the `Person` nodes in the current graph from the user `johndoe`:

```gql
REVOKE ['READ','WRITE'] ON NODE Person (name, age) FROM johndoe
```

To revoke the privilege `DENY` to all properties of all edges in the current graph from the user `johndoe`:

```gql
REVOKE ["DENY"] ON EDGE * * FROM johndoe
```

#### Roles

To revoke the role `manager` from the user `johndoe`:

```gql
REVOKE ROLE manager FROM johndoe
```

### Dropping a User

To drop the user `johndoe`:

```gql
DROP USER johndoe
```

## Using UQL

### Showing Users

To list all database users:

```uql
show().user()
```

Or retrieves a specific user, such as the one named `root`:

```uql
show().user("root")
```

Or retrieves the current logged-in user:

```uql
show().self()
```

### Creating a User

You can create a user and assign it privileges and roles at the same time:

<p tit="Syntax"></p>

```uql
create().user("<username>", "<password>").params({
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

To create a user `admin` with all graph and system privileges:

```uql
create().user("admin", "U7MRDBFXd2Ab").params({
  graph_privileges: {"*":["READ","INSERT","UPSERT","UPDATE","DELETE","CREATE_SCHEMA","DROP_SCHEMA","ALTER_SCHEMA","SHOW_SCHEMA","RELOAD_SCHEMA","CREATE_PROPERTY","DROP_PROPERTY","ALTER_PROPERTY","SHOW_PROPERTY","CREATE_FULLTEXT","DROP_FULLTEXT","SHOW_FULLTEXT","CREATE_INDEX","DROP_INDEX","SHOW_INDEX","LTE","UFE","CLEAR_JOB","STOP_JOB","SHOW_JOB","ALGO","CREATE_PROJECT","SHOW_PROJECT","DROP_PROJECT","CREATE_HDC_GRAPH","SHOW_HDC_GRAPH","DROP_HDC_GRAPH","COMPACT_HDC_GRAPH","SHOW_VECTOR_INDEX","CREATE_VECTOR_INDEX","DROP_VECTOR_INDEX","SHOW_CONSTRAINT","CREATE_CONSTRAINT","DROP_CONSTRAINT"]},
  system_privileges: ["TRUNCATE","COMPACT","CREATE_GRAPH","SHOW_GRAPH","DROP_GRAPH","ALTER_GRAPH","TOP","KILL","STAT","SHOW_POLICY","CREATE_POLICY","DROP_POLICY","ALTER_POLICY","SHOW_USER","CREATE_USER","DROP_USER","ALTER_USER","SHOW_PRIVILEGE","SHOW_META","SHOW_SHARD","ADD_SHARD","DELETE_SHARD","REPLACE_SHARD","SHOW_HDC_SERVER","ADD_HDC_SERVER","DELETE_HDC_SERVER","LICENSE_UPDATE","LICENSE_DUMP","GRANT","REVOKE","SHOW_BACKUP","CREATE_BACKUP","SHOW_VECTOR_SERVER","ADD_VECTOR_SERVER","DELETE_VECTOR_SERVER"]
})
```

To create a user `johndoe` with:

- System privileges: `SHOW_GRAPH`, `ALTER_GRAPH`
- Graph privileges: `READ` for all graphs, `SHOW_INDEX` and `SHOW_JOB` for graphs `amz` and `trans`.
- Property privileges:
   - Node: `read` all node properties
   - Edge: `write` properties `rank` and `asset` for `edgx` edges and `read` property `mark` for all edges in the graph `amz`
- Roles: `manager`

```uql
create().user("johndoe", "mHMUUjQWG46z").params({
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



### Granting to a User

You can grant privileges and roles to a user. Note that the existing privileges and roles assigned to the user remain unchanged.


<p tit="Syntax"></p>

```uql
grant().user("<userName>").params({
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

To grant the graph privileges `CREATE_SCHEMA` and `DROP_SCHEMA` of the graphset `Tax`, and system privilege `ADD_HDC_SERVER` to the user `ultipaUsr`:

```uql
grant().user("ultipaUsr").params({
  graph_privileges: {"Tax": ["CREATE_SCHEMA", "DROP_SCHEMA"]},
  system_privileges: ["ADD_HDC_SERVER"]
})
```

### Revoking from a User

You can revoke privileges and roles from a user.

<p tit="Syntax"></p>

```uql
revoke().user("<userName>").params({
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

To revoke the graph privileges `CREATE_SCHEMA` and `DROP_SCHEMA` of the graphset `Tax`, and system privilege `ADD_HDC_SERVER` from the user `ultipaUsr`:

```uql
revoke().user("ultipaUsr").params({
  graph_privileges: {"Tax": ["CREATE_SCHEMA", "DROP_SCHEMA"]},
  system_privileges: ["ADD_HDC_SERVER"]
})
```

### Altering a User

You can alter privileges and roles assigned to a user. Note that only the specified items will be updated, others remain unchanged.

<p tit="Syntax"></p>

```uql
alter().user("<username>").set({
  password: "<password>",
  graph_privileges: {
    "<graph>": ["<graphPriv>", "<graphPriv>", ...],
    ...
  },
  system_privileges: ["<systemPriv>", "<systemPriv>", ...],
  property_privileges: {
    "node": {
      "<propertyPriv>": [
        ["<graph>", "<schema>", "<property>"],
        ...
      ],
      ...
    },
    "edge": {
      "<propertyPriv>": [
        ["<graph>", "<schema>", "<property>"],
        ...
      ],
      ...
    }
  },
  policies: ["<policyName>", "<policyName>", ...]
})
```

To modify user `admin`'s password while keeping all privileges and policies unchanged:

```uql
alter().user("admin").set({password: "zdcsQ7QFaCCE"})
```

To modify user `johndoe`'s graph and property privileges, and policies, while keeping password and system privileges unchanged:

```uql
alter().user("johndoe").set({
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

### Dropping a User

To drop the user `johndoe`:

```uql
drop().user("johndoe")
```
