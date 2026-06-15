# Access Control

This section introduces methods for controlling access to the database, graphs, and data.

## Privilege

### showPrivilege()

Retrieves all system privileges and graph privileges.

**Parameters**

- None.

**Returns**

- `List[Privilege]`: The list of retrieved privileges.

```python
# Retrieves all system privileges and graph privileges

privileges = Conn.showPrivilege()
graphPrivileges = [privilege.name for privilege in privileges if privilege.level.name == "GRAPH"]
print("Graph privileges:", graphPrivileges)
systemPrivileges = [privilege.name for privilege in privileges if privilege.level.name == "SYSTEM"]
print("System privileges:", systemPrivileges)
```

<p tit="Output"></p> 
 
```
Graph privileges: ['READ', 'INSERT', 'UPSERT', 'UPDATE', 'DELETE', 'CREATE_SCHEMA', 'DROP_SCHEMA', 'ALTER_SCHEMA', 'SHOW_SCHEMA', 'RELOAD_SCHEMA', 'CREATE_PROPERTY', 'DROP_PROPERTY', 'ALTER_PROPERTY', 'SHOW_PROPERTY', 'CREATE_FULLTEXT', 'DROP_FULLTEXT', 'SHOW_FULLTEXT', 'CREATE_INDEX', 'DROP_INDEX', 'SHOW_INDEX', 'LTE', 'UFE', 'CLEAR_JOB', 'STOP_JOB', 'SHOW_JOB', 'ALGO', 'CREATE_PROJECT', 'SHOW_PROJECT', 'DROP_PROJECT', 'CREATE_HDC_GRAPH', 'SHOW_HDC_GRAPH', 'DROP_HDC_GRAPH', 'COMPACT_HDC_GRAPH', 'SHOW_VECTOR_INDEX', 'CREATE_VECTOR_INDEX', 'DROP_VECTOR_INDEX', 'SHOW_CONSTRAINT', 'CREATE_CONSTRAINT', 'DROP_CONSTRAINT']
System privileges: ['TRUNCATE', 'COMPACT', 'CREATE_GRAPH', 'SHOW_GRAPH', 'DROP_GRAPH', 'ALTER_GRAPH', 'TOP', 'KILL', 'STAT', 'SHOW_POLICY', 'CREATE_POLICY', 'DROP_POLICY', 'ALTER_POLICY', 'SHOW_USER', 'CREATE_USER', 'DROP_USER', 'ALTER_USER', 'SHOW_PRIVILEGE', 'SHOW_META', 'SHOW_SHARD', 'ADD_SHARD', 'DELETE_SHARD', 'REPLACE_SHARD', 'SHOW_HDC_SERVER', 'ADD_HDC_SERVER', 'DELETE_HDC_SERVER', 'LICENSE_UPDATE', 'LICENSE_DUMP', 'GRANT', 'REVOKE', 'SHOW_BACKUP', 'CREATE_BACKUP', 'SHOW_VECTOR_SERVER', 'ADD_VECTOR_SERVER', 'DELETE_VECTOR_SERVER']
```

## Policy (Role)

### showPolicy()

Retrieves all policies in the database.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Policy]`: The list of retrieved policies.

```python
# Retrieves all policies

policies = Conn.showPolicy()
for policy in policies:
    print(policy.name)
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

- `policyName: str`: Name of the policy.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Policy`: The retrieved policy.

```python
# Retrieves the policy 'Tester'

policy = Conn.getPolicy("Tester")
print("Graph Privileges:", policy.graphPrivileges)
print("System Privileges:", policy.systemPrivileges)
print("Property Privileges:")
print("- Node (Read):", policy.propertyPrivileges.node.read)
print("- Node (Write):", policy.propertyPrivileges.node.write)
print("- Node (Deny):", policy.propertyPrivileges.node.deny)
print("- Edge (Read):", policy.propertyPrivileges.edge.read)
print("- Edge (Write):", policy.propertyPrivileges.edge.write)
print("- Edge (Deny):", policy.propertyPrivileges.edge.deny)
print("Policies:", policy.policies)
```

<p tit="Output"></p> 
 
```
Graph Privileges: {'amz': ['ALGO', 'DROP_FULLTEXT', 'INSERT', 'DELETE', 'UPSERT'], 'StoryGraph': ['UPDATE', 'READ']}
System Privileges: ['TRUNCATE', 'KILL', 'TOP']
Property Privileges:
- Node (Read): [['*', '*', '*']]
- Node (Write): []
- Node (Deny): []
- Edge (Read): []
- Edge (Write): [['amz', '*', '*'], ['alimama', '*', '*']]
- Edge (Deny): [['miniCircle', 'review', 'value, timestamp']]
Policies: ['sales', 'manager']
```

### createPolicy()

Creates a policy in the database.

**Parameters**

- `policy: Policy`: The policy to be created; the attribute `name` is mandatory, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Creates a new policy 'operator'

policy = Policy(
    name="operator",
    systemPrivileges=["SHOW_GRAPH","TRUNCATE"],
    graphPrivileges={
        "lcc": ["UPDATE","INSERT","DELETE","UPSERT"]
    },
    propertyPrivileges=PropertyPrivilege(
        node=PropertyPrivilegeElement(
            read=[["miniCircle", "account", "*"], ["miniCircle", "movie", "name"]],
            write=[["lcc", "*", "*"]]
        ),
        edge=PropertyPrivilegeElement(
            read=[["*", "*", "*"]],
            deny=[["miniCircle", "*", "*"]]
        )
    ),
    policies=['manager', "sales"]
)

response = Conn.createPolicy(policy)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCEED
```

### alterPolicy()

Alters the privileges and policies included in a policy. Note that only the mentioned attributes will be updated, others remain unchanged.

**Parameters**

- `policy: Policy`: A `Policy` object used to set the new `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` of an existing policy identified by the `name` attribute.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Alters the policy 'operator'

policy = Policy(
    name="operator",
    systemPrivileges=["CREATE_GRAPH","SHOW_GRAPH","SHOW_GRAPH","TRUNCATE"],
    policies=['manager']
)

response = Conn.alterPolicy(policy)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropPolicy()

Drops a specified policy from the database.

**Parameters**

- `policyName: str`: Name of the policy.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Drops the policy 'operator'

response = Conn.dropPolicy("operator")
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## User

### showUser()

Retrieves all database users.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[User]`: The list of retrieved users.

```python
# Retrieves all database users

users = Conn.showUser()
for user in users:
    print(user.username)
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

- `username: str`: Username.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `User`: The retrieved user.

```python
# Retrieves the database user 'johndoe'

user = Conn.getUser("johndoe")
print("Created Time:", user.createdTime)
print("Graph Privileges:", user.graphPrivileges)
print("System Privileges:", user.systemPrivileges)
print("Property Privileges:")
print("- Node (Read):", user.propertyPrivileges.node.read)
print("- Node (Write):", user.propertyPrivileges.node.write)
print("- Node (Deny):", user.propertyPrivileges.node.deny)
print("- Edge (Read):", user.propertyPrivileges.edge.read)
print("- Edge (Write):", user.propertyPrivileges.edge.write)
print("- Edge (Deny):", user.propertyPrivileges.edge.deny)
print("Policies:", user.policies)
```

<p tit="Output"></p> 
 
```
Created Time: 2025-04-02 11:08:38
Graph Privileges: {'amz': ['ALGO', 'INSERT', 'DELETE', 'UPSERT'], 'StoryGraph': ['UPDATE', 'READ']}
System Privileges: ['TRUNCATE', 'KILL', 'TOP']
Property Privileges:
- Node (Read): [['*', '*', '*']]
- Node (Write): []
- Node (Deny): []
- Edge (Read): []
- Edge (Write): [['amz', '*', '*'], ['alimama', '*', '*']]
- Edge (Deny): [['miniCircle', 'review', 'value, timestamp']]
Policies: ['sales', 'manager']
```

### createUser()

Creates a database user.

**Parameters**

- `user: User`: The user to be created; the attributes `username` and `password` are mandatory, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Creates a new user 'user01'

user = User(
    username="user01",
    password="U7MRDBFXd2Ab",
    systemPrivileges=["SHOW_GRAPH","TRUNCATE"],
    graphPrivileges={
        "lcc": ["UPDATE","INSERT","DELETE","UPSERT"]
    },
    propertyPrivileges=PropertyPrivilege(
        node=PropertyPrivilegeElement(
            read=[["miniCircle", "account", "*"], ["miniCircle", "movie", "name"]],
            write=[["lcc", "*", "*"]]
        ),
        edge=PropertyPrivilegeElement(
            read=[["*", "*", "*"]],
            deny=[["miniCircle", "*", "*"]]
        )
    ),
    policies=['manager', "sales"]
)

response = Conn.createUser(user)
print(response.status.code.name)
```

<p tit="Output"></p>

```
SUCCEED
```

### alterUser()

Alters the password, privileges and policies of a user. Note that only the mentioned attributes will be updated, others remain unchanged.

**Parameters**

- `user: User`: A `User` object used to set the new `password`, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` of an existing user identified by the `username` attribute.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Alters the user 'user01'

user = User(
    username="user01",
    systemPrivileges=["CREATE_GRAPH","SHOW_GRAPH","SHOW_GRAPH","TRUNCATE"],
    policies=['manager']
)

response = Conn.alterUser(user)
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCEED
```

### dropUser()

Drops a specified database user.

**Parameters**

- `username: str`: Username.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Drops the user 'user01'

response = Conn.dropUser("user01")
print(response.status.code.name)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

