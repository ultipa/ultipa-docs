# Access Control

This section introduces methods for controlling access to the database, graphs, and data.

# Privilege

### showPrivilege()

Retrieves all system privileges and graph privileges.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Privilege[]`: The list of retrieved privileges.

```ts
// Retrieves all system privileges and graph privileges

const privileges = await driver.showPrivilege();

const graphPriviledgeNames = privileges
  .filter((p) => p.level === PrivilegeLevel.GraphLevel)
  .map((p) => p.name)
  .join(", ");
console.log("Graph privileges:" + graphPriviledgeNames);

const systemPriviledgeNames = privileges
  .filter((p) => p.level === PrivilegeLevel.SystemLevel)
  .map((p) => p.name)
  .join(", ");
console.log("System privileges:" + systemPriviledgeNames);
```

<p tit="Output"></p> 
 
```
Graph privileges: READ, INSERT, UPSERT, UPDATE, DELETE, CREATE_SCHEMA, DROP_SCHEMA, ALTER_SCHEMA, SHOW_SCHEMA, RELOAD_SCHEMA, CREATE_PROPERTY, DROP_PROPERTY, ALTER_PROPERTY, SHOW_PROPERTY, CREATE_FULLTEXT, DROP_FULLTEXT, SHOW_FULLTEXT, CREATE_INDEX, DROP_INDEX, SHOW_INDEX, LTE, UFE, CLEAR_JOB, STOP_JOB, SHOW_JOB, ALGO, CREATE_PROJECT, SHOW_PROJECT, DROP_PROJECT, CREATE_HDC_GRAPH, SHOW_HDC_GRAPH, DROP_HDC_GRAPH, COMPACT_HDC_GRAPH, SHOW_VECTOR_INDEX, CREATE_VECTOR_INDEX, DROP_VECTOR_INDEX, SHOW_CONSTRAINT, CREATE_CONSTRAINT, DROP_CONSTRAINT
System privileges: TRUNCATE, COMPACT, CREATE_GRAPH, SHOW_GRAPH, DROP_GRAPH, ALTER_GRAPH, CREATE_GRAPH_TYPE, SHOW_GRAPH_TYPE, DROP_GRAPH_TYPE, TOP, KILL, STAT, SHOW_POLICY, CREATE_POLICY, DROP_POLICY, ALTER_POLICY, SHOW_USER, CREATE_USER, DROP_USER, ALTER_USER, SHOW_PRIVILEGE, SHOW_META, SHOW_SHARD, ADD_SHARD, DELETE_SHARD, REPLACE_SHARD, SHOW_HDC_SERVER, ADD_HDC_SERVER, DELETE_HDC_SERVER, LICENSE_UPDATE, LICENSE_DUMP, GRANT, REVOKE, SHOW_BACKUP, CREATE_BACKUP, SHOW_VECTOR_SERVER, ADD_VECTOR_SERVER, DELETE_VECTOR_SERVER
```

## Policy (Role)

### showPolicy()

Retrieves all policies in the database.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `Policy[]`: The list of retrieved policies.

```ts
// Retrieves all policies
const policies = await driver.showPolicy();
for (const policy of policies) {
  console.log(policy.name);
}
```

<p tit="Output"></p> 
 
```
manager
Tester
sales
superADM
```

### getPolicy()

Retrieves a specified policy from the database.

**Parameters**

- `policyName: string`: Name of the policy.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Policy`: The retrieved policy.

```ts
// Retrieves the policy 'Tester'
const policy = await driver.getPolicy("Tester");
console.log("Graph privileges:", policy.graphPrivileges);
console.log("System privileges:", policy.systemPrivileges);
console.log("Property privileges:");
console.log("- Node (Read):", policy.propertyPrivileges?.node?.read);
console.log("- Node (Write):", policy.propertyPrivileges?.node?.write);
console.log("- Node (Deny):", policy.propertyPrivileges?.node?.deny);
console.log("- Edge (Read):", policy.propertyPrivileges?.edge?.read);
console.log("- Edge (Write):", policy.propertyPrivileges?.edge?.write);
console.log("- Edge (Deny):", policy.propertyPrivileges?.edge?.deny);
console.log("Policies:", policy.policies);
```

<p tit="Output"></p> 
 
```
Graph privileges:  Map(3) {
  '*' => [ 'SHOW_PROPERTY', 'READ', 'SHOW_SCHEMA' ],
  'miniCircle' => [ 'SHOW_JOB', 'SHOW_INDEX' ],
  'social' => [ 'SHOW_JOB', 'SHOW_INDEX' ]
}
System privileges:  [ 'ALTER_GRAPH', 'SHOW_GRAPH' ]
Property privileges:
- Node (Read):  [ [ '*', '*', '*' ] ]
- Node (Write):  []
- Node (Deny):  []
- Edge (Read):  [ [ 'miniCircle', '*', 'notes' ] ]
- Edge (Write):  [
  [ 'miniCircle', 'agree', 'timestamp' ],
  [ 'miniCircle', 'response', 'value' ]
]
- Edge (Deny):  []
Policies:  [ 'manager' ]
```

### createPolicy()

Creates a policy in the database.

**Parameters**

- `policy: Policy`: The policy to be created; the field `name` is mandatory, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` are optional.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

```ts
// Creates a new policy 'operator'

const graphPrivileges = new Map<string, string[]>();
graphPrivileges.set("social", ["UPDATE", "INSERT", "DELETE", "UPSERT"]);

const propertyPrivilege = {
  node: {
    read: [
      ["miniCircle", "account", "*"],
      ["miniCircle", "movie", "name"]
    ],
    write: [["social", "*", "*"]]
  },
  edge: { 
    read: [["*", "*", "*"]], 
    deny: [["miniCircle", "*", "*"]] 
  }
};

const policy: Policy = {
  name: "operator",
  systemPrivileges: ["SHOW_GRAPH", "TRUNCATE"],
  graphPrivileges: graphPrivileges,
  propertyPrivileges: propertyPrivilege,
  policies: ["manager", "Tester"]
};

const response = await driver.createPolicy(policy);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### alterPolicy()

Alters the privileges and policies included in a policy. Note that only the mentioned fields will be updated, others remain unchanged.

**Parameters**

- `policy: Policy`: A `Policy` object used to set the new `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` of an existing policy identified by the `name` field.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

```ts
// Alters the policy 'operator'
const policy: Policy = {
  name: "operator",
  systemPrivileges: ["CREATE_GRAPH","SHOW_GRAPH","SHOW_GRAPH","TRUNCATE"],
  policies: ["manager"]
};

const response = await driver.alterPolicy(policy);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropPolicy()

Drops a specified policy from the database.

**Parameters**

- `policyName: string`: Name of the policy.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

```ts
// Drops the policy 'operator'
const response = await driver.dropPolicy("operator");
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## User

### showUser()

Retrieves all database users.

**Parameters**

- `config?: RequestConfig`: Request configuration.

**Returns**

- `User[]`: The list of retrieved users.

```ts
// Retrieves all database users
const users = await driver.showUser();
for(const user of users){
  console.log(user.username);
}
```

<p tit="Output"></p> 
 
```
johndoe
root
admin
```

### getUser()

Retrieves a specified database user.

**Parameters**

- `username: string`: Username.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `User`: The retrieved user.

```ts
// Retrieves the database user 'johndoe'
const user = await driver.getUser("johndoe");
console.log("CreatedTime:", user.createdTime);
console.log("Graph privileges:", user.graphPrivileges);
console.log("System privileges:", user.systemPrivileges);
console.log("Property privileges:");
console.log("- Node (Read):", user.propertyPrivileges?.node?.read);
console.log("- Node (Write):", user.propertyPrivileges?.node?.write);
console.log("- Node (Deny):", user.propertyPrivileges?.node?.deny);
console.log("- Edge (Read):", user.propertyPrivileges?.edge?.read);
console.log("- Edge (Write):", user.propertyPrivileges?.edge?.write);
console.log("- Edge (Deny):", user.propertyPrivileges?.edge?.deny);
console.log("Policies:", user.policies);
```

<p tit="Output"></p> 
 
```
CreatedTime:  1759052987
Graph privileges:  Map(3) {
  '*' => [ 'SHOW_PROPERTY', 'READ', 'SHOW_SCHEMA' ],
  'miniCircle' => [ 'SHOW_JOB', 'SHOW_INDEX' ],
  'social' => [ 'SHOW_JOB', 'SHOW_INDEX' ]
}
System privileges:  [ 'ALTER_GRAPH', 'SHOW_GRAPH' ]
Property privileges:
- Node (Read):  [ [ '*', '*', '*' ] ]
- Node (Write):  []
- Node (Deny):  []
- Edge (Read):  [ [ 'miniCircle', '*', 'notes' ] ]
- Edge (Write):  [
  [ 'miniCircle', 'agree', 'timestamp' ],
  [ 'miniCircle', 'response', 'value' ]
]
- Edge (Deny):  []
Policies:  [ 'manager' ]
```

### createUser()

Creates a database user.

**Parameters**

- `user: User`: The user to be created; the fields `username` and `password` are mandatory, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` are optional.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

```ts
// Creates a new user 'user01'

const graphPrivileges = new Map<string, string[]>();
graphPrivileges.set("social", ["UPDATE", "INSERT", "DELETE", "UPSERT"]);
const propertyPrivilege = {
  node: {
    read: [
      ["miniCircle", "account", "*"],
      ["miniCircle", "movie", "name"]
    ],
    write: [["social", "*", "*"]]
  },
  edge: { 
    read: [["*", "*", "*"]], 
    deny: [["miniCircle", "*", "*"]]
  },
};
const user: User = {
  username: "user01",
  password: "U7MRDBFXd2Ab",
  systemPrivileges:["CREATE_GRAPH","SHOW_GRAPH","SHOW_GRAPH","TRUNCATE"],
  graphPrivileges:graphPrivileges,
  propertyPrivileges: propertyPrivilege,
  policies:["manager", "Tester"]
}

const response = await driver.createUser(user);
console.log(response.status?.message);
```

<p tit="Output"></p>

```
SUCCESS
```

### alterUser()

Alters the password, privileges and policies of a user. Note that only the mentioned fields will be updated, others remain unchanged.

**Parameters**

- `user: User`: A `User` object used to set the new `password`, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` of an existing user identified by the `username` field.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

```ts
// Alters the user 'user01'
const user: User = {
  username: "user01",
  systemPrivileges: ["CREATE_GRAPH", "SHOW_GRAPH", "SHOW_GRAPH", "TRUNCATE"],
  policies: ["manager"]
};
const response = await driver.alterUser(user);
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropUser()

Drops a specified database user.

**Parameters**

- `username: string`: Username.
- `config?: RequestConfig`: Request configuration.

**Returns**

- `Response`: Response of the request.

```ts
// Drops the user 'user01'
const response = await driver.dropUser("user01");
console.log(response.status?.message);
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full Example

<p tit="Example.ts"></p> 

```ts
import { UltipaDriver } from "@ultipa-graph/ultipa-driver";
import { ULTIPA } from "@ultipa-graph/ultipa-driver/dist/types/index.js";
import { Policy } from "@ultipa-graph/ultipa-driver/dist/types/types.js";

let sdkUsage = async () => {
  const ultipaConfig: ULTIPA.UltipaConfig = {
    // URI example: hosts: ["xxxx.us-east-1.cloud.ultipa.com:60010"]
    hosts: ["10.xx.xx.xx:60010"],
    username: "<username>",
    password: "<password>"
  };

  const driver = new UltipaDriver(ultipaConfig);

  // Creates a new policy 'operator'

  const graphPrivileges = new Map<string, string[]>();
  graphPrivileges.set("social", ["UPDATE", "INSERT", "DELETE", "UPSERT"]);

  const propertyPrivilege = {
    node: {
      read: [
        ["miniCircle", "account", "*"],
        ["miniCircle", "movie", "name"]
      ],
      write: [["social", "*", "*"]]
    },
    edge: {
      read: [["*", "*", "*"]],
      deny: [["miniCircle", "*", "*"]]
    }
  };

  const policy: Policy = {
    name: "operator",
    systemPrivileges: ["SHOW_GRAPH", "TRUNCATE"],
    graphPrivileges: graphPrivileges,
    propertyPrivileges: propertyPrivilege,
    policies: ["manager", "Tester"]
  };

  const response = await driver.createPolicy(policy);
  console.log(response.status?.message);

};

sdkUsage().catch(console.error);
```
