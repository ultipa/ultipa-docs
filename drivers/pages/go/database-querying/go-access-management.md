# Access Management

This section introduces methods on a `Connection` object for managing access to the instance and graphsets within it, including privileges, policies and users.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Privilege

### ShowPrivilege()

Retrieves all system privileges and graph privileges, which are actually UQL command names categorized based on their operation scope.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Privilege`: All system privileges and graph privileges.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all system privileges and graph privileges

myPri, err := conn.ShowPrivilege(nil)
if err != nil {
  println(err)
}

PGraph := ""
for i, gp := range myPri[0].GraphPrivileges {
  if i > 0 {
    PGraph += ", "
  }
  PGraph += gp
}
println("GraphPrivileges:", "\n", PGraph)

SGraph := ""
for i, sp := range myPri[0].SystemPrivileges {
  if i > 0 {
    SGraph += ", "
  }
  SGraph += sp
}
println("SystemPrivileges:", "\n", SGraph)
```

<p tit="Output"></p> 
 
```java
GraphPrivileges: 
 TEMPLATE, KHOP, AB, SPREAD, AUTONET, FIND, FIND_NODE, FIND_EDGE, INSERT, EXPORT, UPSERT, UPDATE, DELETE, DELETE_NODE, DELETE_EDGE, CREATE_SCHEMA, DROP_SCHEMA, ALTER_SCHEMA, SHOW_SCHEMA, CREATE_TRIGGER, DROP_TRIGGER, SHOW_TRIGGER, CREATE_BACKUP, RESTORE_BACKUP, SHOW_BACKUP, CREATE_PROPERTY, DROP_PROPERTY, ALTER_PROPERTY, SHOW_PROPERTY, CREATE_FULLTEXT, DROP_FULLTEXT, SHOW_FULLTEXT, CREATE_INDEX, DROP_INDEX, SHOW_INDEX, LTE, UFE, CLEAR_TASK, STOP_TASK, PAUSE_TASK, RESUME_TASK, SHOW_TASK, ALGO, SHOW_ALGO
SystemPrivileges: 
 TRUNCATE, COMPACT, CREATE_GRAPH, SHOW_GRAPH, DROP_GRAPH, ALTER_GRAPH, MOUNT_GRAPH, UNMOUNT_GRAPH, TOP, KILL, STAT, SHOW_POLICY, CREATE_POLICY, DROP_POLICY, ALTER_POLICY, SHOW_USER, CREATE_USER, DROP_USER, ALTER_USER, GRANT, REVOKE, SHOW_PRIVILEGE
```

## Policy

### ShowPolicy()

Retrieves all policies from the instance. A policy includes system privileges, graph privileges, property privileges and other policies.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]Policy`: The list of all policies in the instance.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all policies and prints their information

myPol, err := conn.ShowPolicy(nil)
if err != nil {
  println(err)
}

for i := 0; i < len(myPol); i++ {
  println("Policy name:", myPol[i].Name)
  println("Graph privileges include:", "\n", utils.JSONString(myPol[i].GraphPrivileges))
  println("System privileges include:", "\n", utils.JSONString(myPol[i].SystemPrivileges))
  println("Property privlileges include:", "\n", utils.JSONString(myPol[i].PropertyPrivileges))
  println("Policies include:", utils.JSONString(myPol[i].Policies), "\n")
}
```
<p tit="Output"></p> 
 
```java
Policy name: operator
Graph privileges include: 
 {"miniCircle":["UPDATE","INSERT","TEMPLATE","UPSERT","AUTONET"]}
System privileges include: 
 ["MOUNT_GRAPH","TRUNCATE","SHOW_GRAPH"]
Property privlileges include: 
 {"edge":{"deny":[],"read":[],"write":[]},"node":{"deny":[],"read":[],"write":[["miniCircle","account","*"]]}}
Policies include: [] 

Policy name: manager
Graph privileges include: 
 {"*":["CREATE_INDEX","DROP_TRIGGER","CREATE_FULLTEXT"]}
System privileges include: 
 ["DROP_POLICY","COMPACT"]
Property privlileges include: 
 {"edge":{"deny":[],"read":[],"write":[]},"node":{"deny":[],"read":[],"write":[]}}
Policies include: ["operator"] 
```

### GetPolicy()

Retrieves a policy from the instance by its name.

**Parameters:**

- `string`: Name of the policy.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Policy`: The retrieved policy.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves a policy 'operator' and prints its information

myPol, err := conn.GetPolicy("operator", nil)
if err != nil {
  println(err)
}

println("Policy", myPol.Name, "includes:")
println("- System privileges:", utils.JSONString(myPol.SystemPrivileges))
println("- Graph privileges:", utils.JSONString(myPol.GraphPrivileges))
println("- Proverty privileges:", utils.JSONString(myPol.PropertyPrivileges))
println("- Policies:", utils.JSONString(myPol.Policies))
```

<p tit="Output"></p> 
 
```java
Policy operator includes:
- System privileges: ["MOUNT_GRAPH","TRUNCATE","SHOW_GRAPH"]
- Graph privileges: {"miniCircle":["UPDATE","INSERT","TEMPLATE","UPSERT","AUTONET"]}
- Proverty privileges: {"edge":{"deny":[],"read":[],"write":[]},"node":{"deny":[],"read":[],"write":[["miniCircle","account","*"]]}}
- Policies: []
```

### CreatePolicy()

Creates a policy in the instance.

**Parameters:**

- `Policy`: The policy to be altered;the field `Name` must be set, `SystemPrivileges`, `GraphPrivileges`, `PropertyPrivileges` and `Policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Creates a new policy 'sales' and then retrieves it

graphPrivileges := structs.GraphPrivileges{
  "miniCircle": []string{"FIND", "SPREAD", "AUTONET", "AB", "TEMPLATE", "KHOP"},
  "lcc":        []string{"UPDATE", "INSERT", "DELETE", "UPSERT"},
}
propertyPrivileges := structs.PropertyPrivileges{
  "node": {
    "read":  {{"miniCircle", "account", "*"}, {"miniCircle", "movie", "name"}},
    "write": {{"lcc", "*", "*"}},
    "deny":  {},
  },
  "edge": {
    "read":  {{"*", "*", "*"}},
    "write": {{"*", "*", "*"}},
    "deny":  {},
  },
}

var policy = structs.Policy{
  Name:               "sales",
  GraphPrivileges:    graphPrivileges,
  SystemPrivileges:   []string{"SHOW_GRAPH", "TRUNCATE"},
  PropertyPrivileges: propertyPrivileges,
  Policies:           []string{"manager", "operator"},
}

newPol, err := conn.CreatePolicy(&policy, nil)
if err != nil {
  println(utils.JSONString(err.Error()))
}

println("Policy is created:", newPol.IsSuccess())

// Prints the newly created policy 'sales' 

myPol, err := conn.GetPolicy("sales", nil)
if err != nil {
  println(err)
}

println("Policy", myPol.Name, "includes:")
println("- System privileges:", utils.JSONString(myPol.SystemPrivileges))
println("- Graph privileges:", utils.JSONString(myPol.GraphPrivileges))
println("- Proverty privileges:", utils.JSONString(myPol.PropertyPrivileges))
println("- Policies:", utils.JSONString(myPol.Policies))
```

<p tit="Output"></p> 
 
```java
Policy is created: true
Policy sales includes:
- System privileges: ["SHOW_GRAPH","TRUNCATE"]
- Graph privileges: {"lcc":["UPDATE","INSERT","DELETE","UPSERT"],"miniCircle":["FIND","SPREAD","AUTONET","AB","TEMPLATE","KHOP"]}
- Proverty privileges: {"edge":{"deny":[],"read":[["*","*","*"]],"write":[["*","*","*"]]},"node":{"deny":[],"read":[["miniCircle","account","*"],["miniCircle","movie","name"]],"write":[["lcc","*","*"]]}}
- Policies: ["manager","operator"]
```

### AlterPolicy()

Alters the system privileges, graph privileges, property privileges and policies of one existing policy in the instance by its name.

**Parameters:**

- `Policy`: The policy to be altered;the field `Name` must be set, `SystemPrivileges`, `GraphPrivileges`, `PropertyPrivileges` and `Policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Alters the policy 'sales' and then retrieves it

graphPrivileges := structs.GraphPrivileges{
  "miniCircle": []string{"FIND"},
  "lcc":        []string{"UPDATE"},
}

var policy = structs.Policy{
  Name:             "sales",
  GraphPrivileges:  graphPrivileges,
  SystemPrivileges: []string{"SHOW_GRAPH"},
  Policies:         []string{"operator"},
}

newPol, err := conn.AlterPolicy(&policy, nil)
if err != nil {
  println(utils.JSONString(err.Error()))
}

println("Policy is altered:", newPol.IsSuccess())

time.Sleep(2 * time.Second)

myPol, err := conn.GetPolicy("sales", nil)
if err != nil {
  println(err)
}

println("Policy", myPol.Name, "includes:")
println("- System privileges:", utils.JSONString(myPol.SystemPrivileges))
println("- Graph privileges:", utils.JSONString(myPol.GraphPrivileges))
println("- Proverty privileges:", utils.JSONString(myPol.PropertyPrivileges))
println("- Policies:", utils.JSONString(myPol.Policies))
```

<p tit="Output"></p> 
 
```java
Policy is altered: true
Policy sales includes:
- System privileges: ["SHOW_GRAPH"]
- Graph privileges: {"lcc":["UPDATE"],"miniCircle":["FIND"]}
- Proverty privileges: {"edge":{"deny":[],"read":[["*","*","*"]],"write":[["*","*","*"]]},"node":{"deny":[],"read":[["miniCircle","account","*"],["miniCircle","movie","name"]],"write":[["lcc","*","*"]]}}
- Policies: ["operator"]
```

### DropPolicy()

Drops one policy from the instance by its name.

**Parameters:**

- `string`: Name of the policy.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Drops the policy 'sales' and prints error code

myPol, err := conn.DropPolicy("sales", nil)
if err != nil {
  println(utils.JSONString(err.Error()))
}

println("Policy is deleted:", myPol.IsSuccess())
```

<p tit="Output"></p> 
 
```java
Policy is deleted: true
```

## User

### ShowUser()

Retrieves all database users from the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `[]User`: The list of all users in the instance.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves all users and prints information of the first returned

userList, err := conn.ShowUser(nil)

if err != nil {
  println(utils.JSONString(err.Error()))
}

println("Username:", userList[0].UserName)
println("Created at:", userList[0].Create)
println("System privileges:", "\n", utils.JSONString(userList[0].SystemPrivileges))
println("Graph privileges:", "\n", utils.JSONString(userList[0].GraphPrivileges))
println("Property privileges:", "\n", utils.JSONString(userList[0].PropertyPrivileges))
println("Policies:", "\n", utils.JSONString(userList[0].Policies))
```

<p tit="Output"></p> 
 
```java
Username: test006
Created at: 1970-01-01 08:00:00
System privileges: 
 ["SHOW_PRIVILEGE","ALTER_USER","DROP_USER","CREATE_USER","SHOW_GRAPH","ALTER_GRAPH","DROP_GRAPH","COMPACT","MOUNT_GRAPH","TOP","CREATE_GRAPH","STAT","UNMOUNT_GRAPH","SHOW_POLICY","TRUNCATE","KILL","ALTER_POLICY","CREATE_POLICY","DROP_POLICY","SHOW_USER"]
Graph privileges: 
 {}
Property privileges: 
 {"edge":{"deny":[["*","*","*"]],"read":[],"write":[]},"node":{"deny":[["*","*","*"]],"read":[],"write":[]}}
Policies: 
 ["operator"]
```

### GetUser()

Retrieves a database user from the instance by its username.

**Parameters:**

- `string`: Username.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `User`: The retrieved user.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Retrieves user 'test005' and prints its information

myUser, err := conn.GetUser("test005", nil)

if err != nil {
  println(utils.JSONString(err.Error()))
}

println("Username:", myUser.UserName)
println("Created at:", myUser.Create)
println("System privileges:", "\n", utils.JSONString(myUser.SystemPrivileges))
println("Graph privileges:", "\n", utils.JSONString(myUser.GraphPrivileges))
println("Property privileges:", "\n", utils.JSONString(myUser.PropertyPrivileges))
println("Policies:", "\n", utils.JSONString(myUser.Policies))
```

<p tit="Output"></p> 
 
```java
Username: test005
Created at: 1970-01-01 08:00:00
System privileges: 
 ["SHOW_PRIVILEGE","ALTER_USER","DROP_USER","CREATE_USER","SHOW_GRAPH","ALTER_GRAPH","DROP_GRAPH","COMPACT","MOUNT_GRAPH","TOP","CREATE_GRAPH","STAT","UNMOUNT_GRAPH","SHOW_POLICY","TRUNCATE","KILL","ALTER_POLICY","CREATE_POLICY","DROP_POLICY","SHOW_USER"]
Graph privileges: 
 {}
Property privileges: 
 {"edge":{"deny":[],"read":[],"write":[]},"node":{"deny":[],"read":[],"write":[]}}
Policies: 
 ["operator"]
```

### CreateUser()

Creates a database user in the instance.

**Parameters:**

- `CreateUser`: The user to be created; the fields `UserName` and `PassWord` must be set, `SystemPrivilegess`, `GraphPrivileges`, `PropertyPrivileges` and `Policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Creates a new user 'GoUser' and prints error code

graphPrivileges := structs.GraphPrivileges{
  "miniCircle": []string{"FIND", "SPREAD", "AUTONET", "AB", "TEMPLATE", "KHOP"},
  "lcc":        []string{"UPDATE", "INSERT", "DELETE", "UPSERT"},
}

var user = structs.CreateUser{
  UserName:         "GoUser",
  PassWord:         "Password",
  SystemPrivileges: []string{"SHOW_GRAPH", "TRUNCATE"},
  GraphPrivileges:  graphPrivileges,
  Policies:         []string{"manager", "operator"},
}

myUser, err := conn.CreateUser(&user, nil)

if err != nil {
  println(utils.JSONString(err.Error()))
}

println("User is created:", myUser.IsSuccess())
```

<p tit="Output"></p> 
 
```java
User is created: true
```

### AlterUser()

Alters the password, system privileges, graph privileges, property privileges and policies of one existing database user in the instance by its username.

**Parameters:**

- `AlterUser`: The user to be altered; the field `UserName` must be set, `PassWord`, `SystemPrivilegess`, `GraphPrivileges`, `PropertyPrivileges` and `Policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Alters the user 'GoUser' and prints error code

graphPrivileges := structs.GraphPrivileges{
  "miniCircle": []string{"FIND"},
}

var user = structs.AlterUser{
  UserName:         "GoUser",
  SystemPrivileges: []string{"SHOW_GRAPH"},
  GraphPrivileges:  graphPrivileges,
  Policies:         []string{"operator"},
}

myUser, err := conn.AlterUser(&user, nil)

if err != nil {
  println(utils.JSONString(err.Error()))
}

println("User is altered:", myUser.IsSuccess())
```

<p tit="Output"></p> 
 
```java
User is altered: true
```

### DropUser()

Drops one database user from the instance by its username.

**Parameters:**

- `string`: Username.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Drops the user 'GoUser' and prints error code

myUser, err := conn.DropUser("GoUser", nil)

if err != nil {
  println(utils.JSONString(err.Error()))
}

println("User is deleted:", myUser.IsSuccess())
```

<p tit="Output"></p> 
 
```java
User is deleted: true
```

### GrantPolicy()

Grants new system privileges, graph privileges, property privileges and policies to a database user in the instance.

**Parameters:**

- `string`: Username.
- `GraphPrivileges`: Graph privileges to grant; sets to `nil` to skip granting any graph privileges.
- `[]string`: System privileges to grant; sets to `[]string{}` to skip granting any system privileges.
- `PropertyPrivileges`: Property privileges to grant; sets to `nil` to skip granting any property privileges.
- `[]string`: Policies to grant; sets to `[]string{}` to skip granting any policies.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
// Grants privileges and policies to user 'johndoe' and prints error code

graphPrivileges := structs.GraphPrivileges{
  "miniCircle": []string{"FIND", "SPREAD", "AUTONET", "AB", "TEMPLATE", "KHOP"},
  "lcc":        []string{"UPDATE", "INSERT", "DELETE", "UPSERT"},
}

myPol, err := conn.GrantPolicy("johndoe", &graphPrivileges, []string{"SHOW_GRAPH", "TRUNCATE"}, nil, []string{"manager", "operator"}, nil)

if err != nil {
  println(utils.JSONString(err.Error()))
}

println("Policy is granted:", myPol.IsSuccess())
```

<p tit="Output"></p> 
 
```java
Policy is granted: true
```

### RevokePolicy()

Revokes system privileges, graph privileges, property privileges and policies from a database user in the instance.

**Parameters:**

- `string`: Username.
- `GraphPrivileges`: Graph privileges to revoke; sets to `nil` to skip revoking any graph privileges.
- `[]string`: System privileges to revoke; sets to `[]string{}` to skip revoking any system privileges.
- `PropertyPrivileges`: Property privileges to revoke; sets to `nil` to skip revoking any property privileges.
- `[]string`: Policies to revoke; sets to `[]string{}` to skip revoking any policies.
- `RequestConfig` (Optional): Configuration settings for the request. If `nil` is provided, the function will use default configuration settings.

**Returns:**

- `Response`: Result of the request.
- `error`: An error object containing details about any issues that occurred. `nil` is returned if the operation is successful.

<p tit="Go"></p> 
 
```go
graphPrivileges := structs.GraphPrivileges{
  "miniCircle": []string{"FIND", "SPREAD", "AUTONET", "AB", "TEMPLATE", "KHOP"},
  "default":    []string{"UPDATE", "INSERT", "DELETE", "UPSERT"},
}

propertyPrivileges := structs.PropertyPrivileges{
  "node": {
    "read":  {{"miniCircle", "account", "*"}, {"miniCircle", "movie", "name"}},
    "write": {{"default", "*", "*"}},
    "deny":  {},
  },
  "edge": {
    "read":  {{"*", "*", "*"}},
    "write": {{"miniCircle", "*", "*"}},
    "deny":  {},
  },
}

myPol1, err := conn.RevokePolicy("johndoe", &graphPrivileges, []string{}, nil, []string{}, nil)
if err != nil {
  println(utils.JSONString(err.Error()))
}
println("Policy is revoked:", myPol1.IsSuccess())

myPol2, err := conn.RevokePolicy("Tester", &graphPrivileges, []string{"SHOW_GRAPH", "TRUNCATE"}, &propertyPrivileges, []string{"manager", "operator"}, nil)
if err != nil {
  println(utils.JSONString(err.Error()))
}
println("Policy is revoked:", myPol2.IsSuccess())
```

<p tit="Output"></p> 
 
```java
Policy is revoked: true
Policy is revoked: true
```


## Full Example

<p tit="Go"></p> 

```go
package main

import (
  "github.com/ultipa/ultipa-go-sdk/sdk"
  "github.com/ultipa/ultipa-go-sdk/sdk/configuration"
  "github.com/ultipa/ultipa-go-sdk/utils"
)

func main() {

  // Connection configurations
  //URI example: Hosts:=[]string{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"}
    config, _ := configuration.NewUltipaConfig(&configuration.UltipaConfig{
    Hosts:    []string{"192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061"},
    Username: "***",
    Password: "***",
  })

  // Establishes connection to the database
  conn, _ := sdk.NewUltipa(config)
  
  // Retrieves all policies and prints their information
  myPol, err := conn.ShowPolicy(nil)
  if err != nil {
    println(err)
  }


  for i := 0; i < len(myPol); i++ {
    println("Policy name:", myPol[i].Name)
    println("Graph privileges include:", "\n", utils.JSONString(myPol[i].GraphPrivileges))
    println("System privileges include:", "\n", utils.JSONString(myPol[i].SystemPrivileges))
    println("Property privlileges include:", "\n", utils.JSONString(myPol[i].PropertyPrivileges))
    println("Policies include:", utils.JSONString(myPol[i].Policies), "\n")
  }
  println(utils.JSONString(newNodeSchema))

}
```
