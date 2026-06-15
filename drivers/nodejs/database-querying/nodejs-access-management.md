# Access Management

This section introduces methods on a `Connection` object for managing access to the instance and graphsets within it, including privileges, policies and users.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Privilege

### showPrivilege()

Retrieves all system privileges and graph privileges, which are actually UQL command names categorized based on their operation scope.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Privilege`: All system privileges and graph privileges.

```ts
// Retrieves all system privileges and graph privileges

let resp = await conn.showPrivilege();
console.log(resp);
```

<p tit="Output"></p> 
 
```
{
  graph_privileges: [
    'TEMPLATE',       'KHOP',            'AB',
    'SPREAD',         'AUTONET',         'FIND',
    'FIND_NODE',      'FIND_EDGE',       'INSERT',
    'EXPORT',         'UPSERT',          'UPDATE',
    'DELETE',         'DELETE_NODE',     'DELETE_EDGE',
    'CREATE_SCHEMA',  'DROP_SCHEMA',     'ALTER_SCHEMA',
    'SHOW_SCHEMA',    'CREATE_TRIGGER',  'DROP_TRIGGER',
    'SHOW_TRIGGER',   'CREATE_BACKUP',   'RESTORE_BACKUP',
    'SHOW_BACKUP',    'CREATE_PROPERTY', 'DROP_PROPERTY',
    'ALTER_PROPERTY', 'SHOW_PROPERTY',   'CREATE_FULLTEXT',
    'DROP_FULLTEXT',  'SHOW_FULLTEXT',   'CREATE_INDEX',
    'DROP_INDEX',     'SHOW_INDEX',      'LTE',
    'UFE',            'CLEAR_TASK',      'STOP_TASK',
    'PAUSE_TASK',     'RESUME_TASK',     'SHOW_TASK',
    'ALGO',           'SHOW_ALGO'
  ],
  system_privileges: [
    'TRUNCATE',      'COMPACT',
    'CREATE_GRAPH',  'SHOW_GRAPH',
    'DROP_GRAPH',    'ALTER_GRAPH',
    'MOUNT_GRAPH',   'UNMOUNT_GRAPH',
    'TOP',           'KILL',
    'STAT',          'SHOW_POLICY',
    'CREATE_POLICY', 'DROP_POLICY',
    'ALTER_POLICY',  'SHOW_USER',
    'CREATE_USER',   'DROP_USER',
    'ALTER_USER',    'GRANT',
    'REVOKE',        'SHOW_PRIVILEGE'
  ]
}
```

## Policy

### showPolicy()

Retrieves all policies from the instance. A policy includes system privileges, graph privileges, property privileges and other policies.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Policy[]`: The list of all policies in the instance.

```ts
// Retrieves all policies and prints their information

let resp = await conn.showPolicy();
for (let i of resp.data) {
  console.log("Policy ", i.name, " includes: "),
    console.log("- System privileges: ", i.system_privileges),
    console.log("- Graph privileges: ", i.graph_privileges),
    console.log("- Property privileges: ", i.property_privileges),
    console.log("- Policies: ", i.policies);
}
```
<p tit="Output"></p> 
 
```
Policy  manager  includes: 
- System privileges:  [ 'DROP_POLICY', 'COMPACT' ]
- Graph privileges:  { '*': [ 'CREATE_INDEX', 'DROP_TRIGGER', 'CREATE_FULLTEXT' ] }
- Property privileges:  {
  node: { read: [], write: [], deny: [] },
  edge: { read: [], write: [], deny: [] }
}
- Policies:  [ 'operator' ]
Policy  operator  includes:
- System privileges:  [ 'MOUNT_GRAPH', 'TRUNCATE', 'SHOW_GRAPH' ]
- Graph privileges:  { miniCircle: [ 'UPDATE', 'INSERT', 'TEMPLATE', 'UPSERT', 'AUTONET' ] }
- Property privileges:  {
  node: { read: [], write: [ [Array] ], deny: [] },
  edge: { read: [], write: [], deny: [] }
}
- Policies:  []
```

### getPolicy()

Retrieves a policy from the instance by its name.

**Parameters:**

- `string`: Name of the policy.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Policy`: The retrieved policy.

```ts
// Retrieves a policy 'operator' and prints its information

let resp = await conn.getPolicy("operator");
console.log("Policy ", resp.data.name, " includes: "),
  console.log("- System privileges: ", resp.data.system_privileges),
  console.log("- Graph privileges: ", resp.data.graph_privileges),
  console.log("- Property privileges: ", resp.data.property_privileges),
  console.log("- Policies: ", resp.data.policies);
```

<p tit="Output"></p> 
 
```
Policy  operator  includes: 
- System privileges:  [ 'MOUNT_GRAPH', 'TRUNCATE', 'SHOW_GRAPH' ]
- Graph privileges:  { miniCircle: [ 'UPDATE', 'INSERT', 'TEMPLATE', 'UPSERT', 'AUTONET' ] }
- Property privileges:  {
  node: { read: [], write: [ [Array] ], deny: [] },
  edge: { read: [], write: [], deny: [] }
}
- Policies:  []
```

### createPolicy()

Creates a policy in the instance.

**Parameters:**

- `Policy`: The policy to be created; the field `name` must be set, `system_privileges`, `graph_privileges`, `property_privileges` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Creates a new policy 'sales' and then retrieves it

let myCreate = await conn.createPolicy({
  name: "sales",
  system_privileges: ["SHOW_GRAPH", "TRUNCATE"],
  graph_privileges: {
    miniCircle: [
      "SHOW_ALGO",
      "ALGO",
      "RESUME_TASK",
      "UFE",
      "CREATE_PROPERTY",
    ],
  },
  property_privileges: {
    node: {
      read: [],
      write: [],
      deny: [],
    },
    edge: {
      read: [],
      write: [],
      deny: [],
    },
  },
  policies: ["manager", "operator"],
});

// Prints the newly created policy 'sales' 

let resp = await conn.getPolicy("sales");
console.log("Policy", resp.data.name, "includes: "),
  console.log("- System privileges: ", resp.data.system_privileges),
  console.log("- Graph privileges: ", resp.data.graph_privileges),
  console.log("- Property privileges: ", resp.data.property_privileges),
  console.log("- Policies: ", resp.data.policies);
```

<p tit="Output"></p> 
 
```
Policy sales includes: 
- System privileges:  [ 'SHOW_GRAPH', 'TRUNCATE' ]
- Graph privileges:  {
  '*': [ 'SHOW_ALGO', 'ALGO', 'RESUME_TASK', 'CREATE_PROPERTY', 'UFE' ]
}
- Property privileges:  {
  node: { read: [ [Array] ], write: [], deny: [] },
  edge: { read: [ [Array] ], write: [], deny: [] }
}
- Policies:  [ 'manager', 'operator' ]
```

### alterPolicy()

Alters the system privileges, graph privileges, property privileges and policies of one existing policy in the instance by its name.

**Parameters:**

- `Policy`: The policy to be altered; the field `name` must be set, `system_privileges`, `graph_privileges`, `property_privileges` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Alters the policy 'sales' and then retrieves it

let myCreate = await conn.alterPolicy({
  name: "sales",
  system_privileges: ["SHOW_GRAPH"],
  graph_privileges: {
    miniCircle: [
      "SHOW_ALGO",
      "ALGO",
      "RESUME_TASK",
      "UFE",
      "CREATE_PROPERTY",
      "FIND",
    ],
    lcc: ["UPDATE"],
  },
  policies: ["operator"],
});

let resp = await conn.getPolicy("sales");
console.log("Policy", resp.data.name, "includes: "),
  console.log("- System privileges: ", resp.data.system_privileges),
  console.log("- Graph privileges: ", resp.data.graph_privileges),
  console.log("- Property privileges: ", resp.data.property_privileges),
  console.log("- Policies: ", resp.data.policies);
```

<p tit="Output"></p> 
 
```
Policy sales includes: 
- System privileges:  [ 'SHOW_GRAPH' ]
- Graph privileges:  {
  miniCircle: [
    'SHOW_ALGO',
    'ALGO',
    'RESUME_TASK',
    'FIND',
    'UFE',
    'CREATE_PROPERTY'
  ],
  lcc: [ 'UPDATE' ]
}
- Property privileges:  {
  node: { read: [ [Array] ], write: [], deny: [] },
  edge: { read: [ [Array] ], write: [], deny: [] }
}
- Policies:  [ 'operator' ]
```

### dropPolicy()

Drops one policy from the instance by its name.

**Parameters:**

- `string`: Name of the policy.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Drops the policy 'sales' and prints error code

let resp = await conn.dropPolicy("sales");
console.log(resp.status.code_desc);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## User

### showUser()

Retrieves all database users from the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `User[]`: The list of all users in the instance.

```ts
// Retrieves all users and prints information of the first returned

let resp = await conn.showUser();
let user1 = resp.data[0];
console.log("Username:", user1.username);
console.log("Creation timestamp:", user1.create.valueOf());
console.log("System privileges:", user1.system_privileges);
console.log("Graph privileges:", user1.graph_privileges);
console.log("Property privileges:", user1.property_privileges);
console.log("Policies:", user1.policies);
```

<p tit="Output"></p> 
 
```
Username: test006
Creation timestamp: 1693550276
System privileges: [
  'SHOW_PRIVILEGE', 'ALTER_USER',
  'DROP_USER',      'CREATE_USER',
  'SHOW_GRAPH',     'ALTER_GRAPH',
  'DROP_GRAPH',     'COMPACT',
  'MOUNT_GRAPH',    'TOP',
  'CREATE_GRAPH',   'STAT',
  'UNMOUNT_GRAPH',  'SHOW_POLICY',
  'TRUNCATE',       'KILL',
  'ALTER_POLICY',   'CREATE_POLICY',
  'DROP_POLICY',    'SHOW_USER'
]
Graph privileges: {}
Property privileges: {
  node: { read: [], write: [], deny: [ [Array] ] },
  edge: { read: [], write: [], deny: [ [Array] ] }
}
Policies: [ 'operator' ]
```

### getUser()

Retrieves a database user from the instance by its username.

**Parameters:**

- `string`: Username.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `User`: The retrieved user.

```ts
// Retrieves user 'test005' and prints its information

let resp = await conn.getUser("test005");
console.log("Username:", resp.data.username);
console.log("Creation timestamp:", resp.data.create.valueOf());
console.log("System privileges:", resp.data.system_privileges);
console.log("Graph privileges:", resp.data.graph_privileges);
console.log("Property privileges:", resp.data.property_privileges);
console.log("Policies:", resp.data.policies);
```

<p tit="Output"></p> 
 
```
Username: test005
Creation timestamp: 1693473359
System privileges: [
  'SHOW_PRIVILEGE', 'ALTER_USER',
  'DROP_USER',      'CREATE_USER',
  'SHOW_GRAPH',     'ALTER_GRAPH',
  'DROP_GRAPH',     'COMPACT',
  'MOUNT_GRAPH',    'TOP',
  'CREATE_GRAPH',   'STAT',
  'UNMOUNT_GRAPH',  'SHOW_POLICY',
  'TRUNCATE',       'KILL',
  'ALTER_POLICY',   'CREATE_POLICY',
  'DROP_POLICY',    'SHOW_USER'
]
Graph privileges: {}
Property privileges: {
  node: { read: [], write: [], deny: [] },
  edge: { read: [], write: [], deny: [] }
}
Policies: [ 'operator' ]
```

### createUser()

Creates a database user in the instance.

**Parameters:**

- `CreateUser`: The user to be created; the fields `username` and `password` must be set, `system_privileges`, `graph_privileges`, `property_privilege` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Creates a new user 'NodeJsUser' and prints error code

let resp = await conn.createUser({
  username: "NodeJsUser",
  password: "Password",
  system_privileges: ["SHOW_GRAPH", "TRUNCATE"],
  graph_privileges: {
    miniCircle: [
      "SHOW_ALGO",
      "ALGO",
      "RESUME_TASK",
      "UFE",
      "CREATE_PROPERTY",
      "FIND",
    ],
  },
  property_privileges: {
    node: {
      read: [],
      write: [],
      deny: [],
    },
    edge: {
      read: [],
      write: [],
      deny: [],
    },
  },
  policies: ["manager"],
});
console.log(resp.status.code_desc);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### alterUser()

Alters the password, system privileges, graph privileges, property privileges and policies of one existing database user in the instance by its username.

**Parameters:**

- `AlterUser`: The user to be altered; the field `username` must be set, `password`, `system_privileges`, `graph_privileges`, `property_privileges` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Alters the user 'NodeJsUser' and prints error code

let resp = await conn.alterUser({
  username: "NodeJsUser",
  system_privileges: ["SHOW_GRAPH"],
  graph_privileges: {
    miniCircle: ["FIND"],
  },

  policies: ["operator"],
});
console.log(resp.status.code_desc);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropUser()

Drops one database user from the instance by its username.

**Parameters:**

- `string`: Username.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Drops the user 'NodeJsUser' and prints error code

let resp = await conn.dropUser("NodeJsUser");
console.log(resp.status.code_desc);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### grantPolicy()

Grants new system privileges, graph privileges, property privileges and policies to a database user in the instance.

**Parameters:**

- `string`: Username.
- `GraphPrivilege`: Graph privileges to grant; sets to `null` to skip granting any graph privileges.
- `string[]`: System privileges to grant; sets to `null` to skip granting any system privileges.
- `string[]`: Policies to grant; sets to `null` to skip granting any policies.
- `PropertyPrivilege`: Property privileges to grant; sets to `null` to skip granting any property privileges.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
// Grants privileges and policies to user 'johndoe' and prints error code

let resp = await conn.grantPolicy(
  "johndoe",
  {
    miniCircle: [
      "SHOW_ALGO",
      "ALGO",
      "RESUME_TASK",
      "UFE",
      "CREATE_PROPERTY",
      "FIND",
    ],
  },
  null,
  ["manager"],
  null
);
console.log(resp.status.code_desc);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### revokePolicy()

Revokes system privileges, graph privileges, property privileges and policies from a database user in the instance.

**Parameters:**

- `string`: Username.
- `GraphPrivilege`: Graph privileges to revoke; sets to `null` to skip revoking any graph privileges.
- `string[]`: System privileges to revoke; sets to `null` to skip revoking any system privileges.
- `string[]`: Policies to revoke; sets to `null` to skip revoking any policies.
- `PropertyPrivilege`: Property privileges to revoke; sets to `null` to skip revoking any property privileges.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```ts
let resp = await conn.revokePolicy(
  "johndoe",
  {
    miniCircle: ["SHOW_ALGO", "ALGO", "RESUME_TASK"],
  },
  null,
  ["manager"],
  null
);
console.log(resp.status.code_desc);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full Example

```ts
import { ConnectionPool, ULTIPA } from "@ultipa-graph/ultipa-node-sdk";
import { GraphExra } from "@ultipa-graph/ultipa-node-sdk/dist/connection/extra/graph.extra";
import { getEdgesPrintInfo } from "@ultipa-graph/ultipa-node-sdk/dist/printers/edge";
import { RequestType } from "@ultipa-graph/ultipa-node-sdk/dist/types";
import { ListFormat } from "typescript";

let sdkUsage = async () => {
  // Connection configurations
  //URI example: hosts="mqj4zouys.us-east-1.cloud.ultipa.com:60010"
  let hosts = [
    "192.168.1.85:60061",
    "192.168.1.86:60061",
    "192.168.1.87:60061",
  ];
  let username = "***";
  let password = "***";
  let connPool = new ConnectionPool(hosts, username, password);

  // Establishes connection to the database
  let conn = await connPool.getActive();
  let isSuccess = await conn.test();
  console.log(isSuccess);

  // Request configurations
  let requestConfig = <RequestType.RequestConfig>{
    useMaster: true,
  };

  // Retrieves all policies and prints their information
  let resp = await conn.showPolicy();
  for (let i of resp.data) {
    console.log("Policy ", i.name, " includes: "),
      console.log("- System privileges: ", i.system_privileges),
      console.log("- Graph privileges: ", i.graph_privileges),
      console.log("- Property privileges: ", i.property_privileges),
      console.log("- Policies: ", i.policies);
  }
};

sdkUsage().then(console.log).catch(console.log);
```
