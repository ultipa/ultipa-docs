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

<p tit="Python"></p> 
 
```python
# Retrieves all system privileges and graph privileges

privilege = Conn.showPrivilege()
print("System privileges:", privilege.systemPrivileges)
print("Graph privileges:", privilege.graphPrivileges)
```

<p tit="Output"></p> 
 
```python
System privileges: ['TRUNCATE', 'COMPACT', 'CREATE_GRAPH', 'SHOW_GRAPH', 'DROP_GRAPH', 'ALTER_GRAPH', 'MOUNT_GRAPH', 'UNMOUNT_GRAPH', 'TOP', 'KILL', 'STAT', 'SHOW_POLICY', 'CREATE_POLICY', 'DROP_POLICY', 'ALTER_POLICY', 'SHOW_USER', 'CREATE_USER', 'DROP_USER', 'ALTER_USER', 'GRANT', 'REVOKE', 'SHOW_PRIVILEGE']
Graph privileges: ['TEMPLATE', 'KHOP', 'AB', 'SPREAD', 'AUTONET', 'FIND', 'FIND_NODE', 'FIND_EDGE', 'INSERT', 'EXPORT', 'UPSERT', 'UPDATE', 'DELETE', 'DELETE_NODE', 'DELETE_EDGE', 'CREATE_SCHEMA', 'DROP_SCHEMA', 'ALTER_SCHEMA', 'SHOW_SCHEMA', 'CREATE_TRIGGER', 'DROP_TRIGGER', 'SHOW_TRIGGER', 'CREATE_BACKUP', 'RESTORE_BACKUP', 'SHOW_BACKUP', 'CREATE_PROPERTY', 'DROP_PROPERTY', 'ALTER_PROPERTY', 'SHOW_PROPERTY', 'CREATE_FULLTEXT', 'DROP_FULLTEXT', 'SHOW_FULLTEXT', 'CREATE_INDEX', 'DROP_INDEX', 'SHOW_INDEX', 'LTE', 'UFE', 'CLEAR_TASK', 'STOP_TASK', 'PAUSE_TASK', 'RESUME_TASK', 'SHOW_TASK', 'ALGO', 'SHOW_ALGO']
```

## Policy

### showPolicy()

Retrieves all policies from the instance. A policy includes system privileges, graph privileges, property privileges and other policies.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Policy]`: The list of all policies in the instance.

<p tit="Python"></p> 
 
```python
# Retrieves all policies and prints their information

policyList = Conn.showPolicy()
for policy in policyList:
    print("Policy", policy.name, "include:")
    print("- System privileges:", policy.systemPrivileges)
    print("- Graph privileges:", policy.graphPrivileges)
    print("- Property privileges:", policy.propertyPrivileges)
    print("- Policies:", policy.policies)
```

<p tit="Output"></p> 
 
```python
Policy operator include:
- System privileges: ['MOUNT_GRAPH', 'TRUNCATE', 'SHOW_GRAPH']
- Graph privileges: {'miniCircle': ['UPDATE', 'INSERT', 'TEMPLATE', 'UPSERT', 'AUTONET']}
- Property privileges: {"node":{"read":[],"write":[["miniCircle","account","*"]],"deny":[]},"edge":{"read":[],"write":[],"deny":[]}}
- Policies: []
Policy manager include:
- System privileges: ['DROP_POLICY', 'COMPACT']
- Graph privileges: {'*': ['CREATE_INDEX', 'DROP_TRIGGER', 'CREATE_FULLTEXT']}
- Property privileges: {"node":{"read":[],"write":[],"deny":[]},"edge":{"read":[],"write":[],"deny":[]}}
- Policies: ['operator']
```

### getPolicy()

Retrieves a policy from the instance by its name.

**Parameters:**

- `str`: Name of the policy.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Policy`: The retrieved policy.

<p tit="Python"></p> 
 
```python
# Retrieves a policy 'operator' and prints its information

policy = Conn.getPolicy("operator")
print("Policy", policy.name, "include:")
print("- System privileges:", policy.systemPrivileges)
print("- Graph privileges:", policy.graphPrivileges)
print("- Property privileges:", policy.propertyPrivileges)
print("- Policies:", policy.policies)
```

<p tit="Output"></p> 
 
```python
Policy operator include:
- System privileges: ['MOUNT_GRAPH', 'TRUNCATE', 'SHOW_GRAPH']
- Graph privileges: {'miniCircle': ['UPDATE', 'INSERT', 'TEMPLATE', 'UPSERT', 'AUTONET']}
- Property privileges: {"node":{"read":[],"write":[["miniCircle","account","*"]],"deny":[]},"edge":{"read":[],"write":[],"deny":[]}}
- Policies: []
```

### createPolicy()

Creates a policy in the instance.

**Parameters:**

- `Policy`: The policy to be created; the field `name` must be set, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Creates a new policy 'sales' and then retrieves it

policy = Policy(
    name="sales",
    systemPrivileges=["SHOW_GRAPH","TRUNCATE"],
    graphPrivileges={
        "lcc": ["UPDATE","INSERT","DELETE","UPSERT"]
    },
    propertyPrivileges={
        "node": {
            "read": [
                ["miniCircle", "account", "*"],
                ["miniCircle", "movie", "name"]
            ],
            "write": [
                ["lcc", "*", "*"]
            ]
        },
        "edge": {
            "read": [
                ["*", "*", "*"]
            ],
            "write": [
                ["miniCircle", "*", "*"]
            ]
        }
    },
    policies=['manager', "operator"]
)

response = Conn.createPolicy(policy)
print(response.status.code)

time.sleep(3)

createdPolicy = Conn.getPolicy("sales")
print("Policy", createdPolicy.name, "include:")
print("- System privileges:", createdPolicy.systemPrivileges)
print("- Graph privileges:", createdPolicy.graphPrivileges)
print("- Property privileges:", createdPolicy.propertyPrivileges)
print("- Policies:", createdPolicy.policies)
```

<p tit="Output"></p> 
 
```python
0
Policy sales include:
- System privileges: ['SHOW_GRAPH', 'TRUNCATE']
- Graph privileges: {'lcc': ['UPDATE', 'INSERT', 'DELETE', 'UPSERT']}
- Property privileges: {"node":{"read":[["miniCircle","account","*"],["miniCircle","movie","name"]],"write":[["lcc","*","*"]],"deny":[]},"edge":{"read":[["*","*","*"]],"write":[["miniCircle","*","*"]],"deny":[]}}
- Policies: ['manager', 'operator']
```

### alterPolicy()

Alters the system privileges, graph privileges, property privileges and policies of one existing policy in the instance by its name.

**Parameters:**

- `Policy`: The policy to be altered; the field `name` must be set, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Alters the policy 'sales' and then retrieves it

policy = Policy(
    name="sales",
    systemPrivileges=["SHOW_GRAPH"],
    graphPrivileges={
        "miniCircle": ["FIND"],
        "lcc": ["UPDATE"]
    },
    policies=["operator"]
)

response = Conn.alterPolicy(policy)
print(response.status.code)

time.sleep(3)

alteredPolicy = Conn.getPolicy("sales")
print("Policy", alteredPolicy.name, "include:")
print("- System privileges:", alteredPolicy.systemPrivileges)
print("- Graph privileges:", alteredPolicy.graphPrivileges)
print("- Property privileges:", alteredPolicy.propertyPrivileges)
print("- Policies:", alteredPolicy.policies)
```

<p tit="Output"></p> 
 
```python
0
Policy sales include:
- System privileges: ['SHOW_GRAPH']
- Graph privileges: {'miniCircle': ['FIND'], 'lcc': ['UPDATE']}
- Property privileges: {"node":{"read":[["miniCircle","account","*"],["miniCircle","movie","name"]],"write":[["lcc","*","*"]],"deny":[]},"edge":{"read":[["*","*","*"]],"write":[["miniCircle","*","*"]],"deny":[]}}
- Policies: ['operator']
```

### dropPolicy()

Drops one policy from the instance by its name.

**Parameters:**

- `str`: Name of the policy.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Drops the policy 'sales' and prints error code

response = Conn.dropPolicy("sales")
print(response.status.code)
```

<p tit="Output"></p> 
 
```python
0
```

## User

### showUser()

Retrieves all database users from the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[User]`: The list of all users in the instance.

<p tit="Python"></p> 
 
```python
# Retrieves all users and prints information of the first returned

userList = Conn.showUser()
print("Username:", userList[0].username)
print("Created On:", userList[0].create)
print("System privileges:", userList[0].systemPrivileges)
print("Graph privileges:", userList[0].graphPrivileges)
print("Property privileges:", userList[0].propertyPrivileges)
print("Policies:", userList[0].policies)
```

<p tit="Output"></p> 
 
```python
Username: test006
Created On: 1693550276
System privileges: ['SHOW_PRIVILEGE', 'ALTER_USER', 'DROP_USER', 'CREATE_USER', 'SHOW_GRAPH', 'ALTER_GRAPH', 'DROP_GRAPH', 'COMPACT', 'MOUNT_GRAPH', 'TOP', 'CREATE_GRAPH', 'STAT', 'UNMOUNT_GRAPH', 'SHOW_POLICY', 'TRUNCATE', 'KILL', 'ALTER_POLICY', 'CREATE_POLICY', 'DROP_POLICY', 'SHOW_USER']
Graph privileges: {}
Property privileges: {"node":{"read":[],"write":[],"deny":[["*","*","*"]]},"edge":{"read":[],"write":[],"deny":[["*","*","*"]]}}
Policies: ['operator']
```

### getUser()

Retrieves a database user from the instance by its username.

**Parameters:**

- `str`: Username.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `User`: The retrieved user.

<p tit="Python"></p> 
 
```python
# Retrieves user 'test005' and prints its information

user = Conn.getUser("test005")
print("Username:", user.username)
print("Created On:", user.create)
print("System privileges:", user.systemPrivileges)
print("Graph privileges:", user.graphPrivileges)
print("Property privileges:", user.propertyPrivileges)
print("Policies:", user.policies)
```

<p tit="Output"></p> 
 
```python
Username: test005
Created On: 1693473359
System privileges: ['SHOW_PRIVILEGE', 'ALTER_USER', 'DROP_USER', 'CREATE_USER', 'SHOW_GRAPH', 'ALTER_GRAPH', 'DROP_GRAPH', 'COMPACT', 'MOUNT_GRAPH', 'TOP', 'CREATE_GRAPH', 'STAT', 'UNMOUNT_GRAPH', 'SHOW_POLICY', 'TRUNCATE', 'KILL', 'ALTER_POLICY', 'CREATE_POLICY', 'DROP_POLICY', 'SHOW_USER']
Graph privileges: {}
Property privileges: {"node":{"read":[],"write":[],"deny":[]},"edge":{"read":[],"write":[],"deny":[]}}
Policies: ['operator']
```

### createUser()

Creates a database user in the instance.

**Parameters:**

- `CreateUser`: The user to be created; the fields `username` and `password` must be set, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Creates a new user 'pythonUser' and prints error code

createUser = CreateUser(
    username="pythonUser",
    password="@#pythonUser",
    systemPrivileges=["SHOW_GRAPH", "TRUNCATE"],
    graphPrivileges={
        "miniCircle": ["FIND", "SPREAD", "AUTONET", "AB", "TEMPLATE", "KHOP"],
        "lcc": ["UPDATE", "INSERT", "DELETE", "UPSERT"]
    },
    propertyPrivileges={
        "node": {
            "read": [
                ["miniCircle", "account", "*"],
                ["miniCircle", "movie", "name"]
            ],
            "write": [
                ["lcc", "*", "*"]
            ]
        },
        "edge": {
            "read": [
                ["*", "*", "*"]
            ],
            "write": [
                ["miniCircle", "*", "*"]
            ]
        }
    },
    policies=["manager"]
)

response = Conn.createUser(createUser)
print(response.status.code)
```

<p tit="Output"></p>

```js
0
```

### alterUser()

Alters the password, system privileges, graph privileges, property privileges and policies of one existing database user in the instance by its username.

**Parameters:**

- `AlterUser`: The user to be altered; the fields `username` and `password` must be set, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Alters the user 'pythonUser' and prints error code

user = AlterUser(
    username="pythonUser",
    password="!!@#pythonUser",
    systemPrivileges=["SHOW_GRAPH"],
    graphPrivileges={
        "miniCircle": ["FIND"],
        "lcc": ["UPDATE"]
    },
    policies=["operator"]
)

response = Conn.alterUser(user)
print(response.status.code)
```

<p tit="Output"></p> 
 
```python
0
```

### dropUser()

Drops one database user from the instance by its username.

**Parameters:**

- `str`: Username.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
# Drops the user 'javaUser' and prints error code

response = Conn.dropUser("pythonUser")
print(response.status.code)
```

<p tit="Output"></p> 
 
```python
0
```

### grantPolicy()

Grants new system privileges, graph privileges, property privileges and policies to a database user in the instance.

**Parameters:**

- `str`: Username.
- `dict`: Graph privileges to grant; sets to `null` to skip granting any graph privileges.
- `List[str]`: System privileges to grant; sets to `null` to skip granting any system privileges.
- `List[str]`: Policies to grant; sets to `null` to skip granting any policies.
- `dict`: Property privileges to grant; sets to `null` to skip granting any property privileges.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
graphPrivileges = {
    "miniCircle": ["FIND", "SPREAD", "AUTONET", "AB", "TEMPLATE", "KHOP"],
    "default": ["UPDATE", "INSERT", "DELETE", "UPSERT"]
}
systemPrivileges = ["SHOW_GRAPH", "TRUNCATE"]
propertyPrivileges = {
    "node": {
        "read": [
            ["miniCircle", "account", "*"],
            ["miniCircle", "movie", "name"]
        ],
        "write": [
            ["lcc", "*", "*"]
        ]
    },
    "edge": {
        "read": [
            ["*", "*", "*"]
        ],
        "write": [
            ["miniCircle", "*", "*"]
        ]
    }
}
policies = ["operator", "manager"]

response1 = Conn.grantPolicy("johndoe", graphPrivileges)
print(response1.status.code)

response2 = Conn.grantPolicy("Tester", graphPrivileges, systemPrivileges, policies, propertyPrivileges)
print(response2.status.code)
```

<p tit="Output"></p> 
 
```python
0
0
```

### revokePolicy()

Revokes system privileges, graph privileges, property privileges and policies from a database user in the instance.

**Parameters:**

- `str`: Username.
- `dict`: Graph privileges to revoke; sets to `null` to skip revoking any graph privileges.
- `List[str]`: System privileges to revoke; sets to `null` to skip revoking any system privileges.
- `List[str]`: Policies to revoke; sets to `null` to skip revoking any policies.
- `dict`: Property privileges to revoke; sets to `null` to skip revoking any property privileges.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

<p tit="Python"></p> 
 
```python
graphPrivileges = {
    "miniCircle": ["FIND", "SPREAD", "AUTONET", "AB", "TEMPLATE", "KHOP"],
    "default": ["UPDATE", "INSERT", "DELETE", "UPSERT"]
}
systemPrivileges = ["SHOW_GRAPH", "TRUNCATE"]
propertyPrivileges = {
    "node": {
        "read": [
            ["miniCircle", "account", "*"],
            ["miniCircle", "movie", "name"]
        ],
        "write": [
            ["lcc", "*", "*"]
        ]
    },
    "edge": {
        "read": [
            ["*", "*", "*"]
        ],
        "write": [
            ["miniCircle", "*", "*"]
        ]
    }
}
policies = ["operator", "manager"]

response1 = Conn.revokePolicy("johndoe", graphPrivileges)
print(response1.status.code)

response2 = Conn.revokePolicy("Tester", graphPrivileges, systemPrivileges, policies, propertyPrivileges)
print(response2.status.code)
```

<p tit="Output"></p> 
 
```python
0
0
```

## Full Example

<p tit="example.py" ></p> 

```python
from ultipa import Connection, UltipaConfig

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)
          
# Retrieves all policies and prints their information

policyList = Conn.showPolicy()
for policy in policyList:
    print("Policy", policy.name, "include:")
    print("- System privileges:", policy.systemPrivileges)
    print("- Graph privileges:", policy.graphPrivileges)
    print("- Property privileges:", policy.propertyPrivileges)
    print("- Policies:", policy.policies)
```
