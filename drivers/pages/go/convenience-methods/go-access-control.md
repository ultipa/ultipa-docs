## Access Control

This section introduces methods for controlling access to the database, graphs, and data.

## Privilege

### ShowPrivilege()

Retrieves all system privileges and graph privileges.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Privilege`: A slice of pointers to the retrieved privileges.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all system privileges and graph privileges

response, _ := driver.Uql("show().privilege()", nil)
privileges, _ := response.Alias("_privilege").AsPrivileges()

var graphPrivileges []string
var systemPrivileges []string

for _, privilege := range privileges {
    if privilege.Level == structs.GraphPrivilege {
    	graphPrivileges = append(graphPrivileges, privilege.Name)
  	} else {
    	systemPrivileges = append(systemPrivileges, privilege.Name)
  	}
}

fmt.Println("Graph Privileges:", graphPrivileges)
fmt.Println("System Privileges:", systemPrivileges)
```

<p tit="Output"></p> 
 
```
Graph Privileges: [READ INSERT UPSERT UPDATE DELETE CREATE_SCHEMA DROP_SCHEMA ALTER_SCHEMA SHOW_SCHEMA RELOAD_SCHEMA CREATE_PROPERTY DROP_PROPERTY ALTER_PROPERTY SHOW_PROPERTY CREATE_FULLTEXT DROP_FULLTEXT SHOW_FULLTEXT CREATE_INDEX DROP_INDEX SHOW_INDEX LTE UFE CLEAR_JOB STOP_JOB SHOW_JOB ALGO CREATE_PROJECT SHOW_PROJECT DROP_PROJECT CREATE_HDC_GRAPH SHOW_HDC_GRAPH DROP_HDC_GRAPH COMPACT_HDC_GRAPH SHOW_VECTOR_INDEX CREATE_VECTOR_INDEX DROP_VECTOR_INDEX SHOW_CONSTRAINT CREATE_CONSTRAINT DROP_CONSTRAINT]
System Privileges: [TRUNCATE COMPACT CREATE_GRAPH SHOW_GRAPH DROP_GRAPH ALTER_GRAPH CREATE_GRAPH_TYPE SHOW_GRAPH_TYPE DROP_GRAPH_TYPE TOP KILL STAT SHOW_POLICY CREATE_POLICY DROP_POLICY ALTER_POLICY SHOW_USER CREATE_USER DROP_USER ALTER_USER SHOW_PRIVILEGE SHOW_META SHOW_SHARD ADD_SHARD DELETE_SHARD REPLACE_SHARD SHOW_HDC_SERVER ADD_HDC_SERVER DELETE_HDC_SERVER LICENSE_UPDATE LICENSE_DUMP GRANT REVOKE SHOW_BACKUP CREATE_BACKUP SHOW_VECTOR_SERVER ADD_VECTOR_SERVER DELETE_VECTOR_SERVER]
```

## Policy (Role)

### ShowPolicy()

Retrieves all policies in the database.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Policy`: A slice of pointers to the retrieved policies.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all policies

policies, _ := driver.ShowPolicy(nil)

for _, policy := range policies {
    fmt.Println(policy.Name)
}
```
<p tit="Output"></p> 
 
```
manager
Tester
sales
superADM 
```

### GetPolicy()

Retrieves a specified policy from the database.

**Parameters**

- `policyName: string`: Name of the policy.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `*structs.Policy`: The retrieved policy.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves the policy 'Tester'

policy, _ := driver.GetPolicy("Tester", nil)

fmt.Println("Graph Privileges:", policy.GraphPrivileges)
fmt.Println("System Privileges:", policy.SystemPrivileges)
fmt.Println("Property Privileges:")
fmt.Println("- Node (Read):", policy.PropertyPrivileges.Node.Read)
fmt.Println("- Node (Write):", policy.PropertyPrivileges.Node.Write)
fmt.Println("- Node (Deny):", policy.PropertyPrivileges.Node.Deny)
fmt.Println("- Edge (Read):", policy.PropertyPrivileges.Edge.Read)
fmt.Println("- Edge (Write):", policy.PropertyPrivileges.Edge.Write)
fmt.Println("- Edge (Deny):", policy.PropertyPrivileges.Edge.Deny)
fmt.Println("Policies:", policy.Policies)
```

<p tit="Output"></p> 
 
```
Graph Privileges: map[*:[SHOW_PROPERTY READ SHOW_SCHEMA] alimama:[SHOW_JOB SHOW_INDEX] trans:[SHOW_JOB SHOW_INDEX]]
System Privileges: [ALTER_GRAPH SHOW_GRAPH]
Property Privileges:
- Node (Read): [[* * *]]
- Node (Write): []
- Node (Deny): []
- Edge (Read): [[alimama * timestamp]]
- Edge (Write): [[alimama edgx behavior] [alimama edgx timestamp]]
- Edge (Deny): []
Policies: [manager]
```

### CreatePolicy()

Creates a policy in the database.

**Parameters**

- `policy: Policy`: The policy to be created; the field `Name` is mandatory, `SystemPrivileges`, `GraphPrivileges`, `PropertyPrivilege`, and `Policies` are optional.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Result of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Creates a new policy 'operator'

response, _ := driver.CreatePolicy(&structs.Policy{
  	Name:             "operator",
  	SystemPrivileges: []string{"SHOW_GRAPH", "TRUNCATE"},
  	GraphPrivileges: structs.GraphPrivileges{
    	"lcc": []string{"UPDATE", "INSERT", "DELETE", "UPSERT"},
  	},
  	PropertyPrivileges: structs.PropertyPrivileges{
    	Node: structs.PropertyPrivilegeElement{
      		Read: [][]string{
        		{"miniCircle", "account", "*"},
        		{"miniCircle", "movie", "name"},
      		},
      		Write: [][]string{
        		{"lcc", "*", "*"},
      		},
    	},
    	Edge: structs.PropertyPrivilegeElement{
      		Read: [][]string{
        		{"*", "*", "*"},
      		},
      		Deny: [][]string{
        		{"miniCircle", "*", "*"},
      		},
    	},
  	},
  	Policies: []string{"manager", "sales"},
}, nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### AlterPolicy()

Alters the privileges and policies included in a policy. Note that only the mentioned attributes will be updated, others remain unchanged.

**Parameters**

- `policy: *structs.Policy`: A pointer to the `Policy` struct used to set new `SystemPrivileges`, `GraphPrivileges`, `PropertyPrivilege`, and `Policies` of an existing policy identified by the `Name` field.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Result of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Alters the policy 'operator'

response, _ := driver.AlterPolicy(&structs.Policy{
    Name:             "operator",
    SystemPrivileges: []string{"CREATE_GRAPH", "SHOW_GRAPH", "SHOW_GRAPH", "TRUNCATE"},
    Policies:         []string{"manager"},
}, nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### DropPolicy()

Drops a specified policy from the database.

**Parameters**

- `policyName: string`: Name of the policy.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Result of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Drops the policy 'operator'

response, _ := driver.DropPolicy("operator", nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## User

### ShowUser()

Retrieves all database users.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.User`: A slice of pointers to the retrieved users.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all database users

users, _ := driver.ShowUser(nil)
for _, user := range users {
    fmt.Println(user.UserName)
}
```

<p tit="Output"></p> 
 
```
johndoe
root
admin
```

### GetUser()

Retrieves a specified database user.

**Parameters**

- `username: string`: Username.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `*structs.User`: The retrieved user.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves the database user 'johndoe'

user, _ := driver.GetUser("johndoe", nil)

fmt.Println("Created Time:", user.CreatedTime)
fmt.Println("Graph Privileges:", user.GraphPrivileges)
fmt.Println("System Privileges:", user.SystemPrivileges)
fmt.Println("Property Privileges:")
fmt.Println("- Node (Read):", user.PropertyPrivileges.Node.Read)
fmt.Println("- Node (Write):", user.PropertyPrivileges.Node.Write)
fmt.Println("- Node (Deny):", user.PropertyPrivileges.Node.Deny)
fmt.Println("- Edge (Read):", user.PropertyPrivileges.Edge.Read)
fmt.Println("- Edge (Write):", user.PropertyPrivileges.Edge.Write)
fmt.Println("- Edge (Deny):", user.PropertyPrivileges.Edge.Deny)
fmt.Println("Policies:", user.Policies)
```

<p tit="Output"></p> 
 
```
Created Time: 2025-04-02T11:08:38.000+08:00
Graph Privileges: map[*:[SHOW_PROPERTY READ SHOW_SCHEMA] alimama:[SHOW_JOB SHOW_INDEX] trans:[SHOW_JOB SHOW_INDEX]]
System Privileges: [ALTER_GRAPH SHOW_GRAPH]
Property Privileges:
- Node (Read): [[* * *]]
- Node (Write): []
- Node (Deny): []
- Edge (Read): [[alimama * timestamp]]
- Edge (Write): [[alimama edgx behavior] [alimama edgx timestamp]]
- Edge (Deny): []
Policies: [manager]
```

### CreateUser()

Creates a database user.

**Parameters**

- `user: *structs.User`: The user to be created; the fields `Username` and `Password` are mandatory, `SystemPrivileges`, `GraphPrivileges`, `PropertyPrivilege`, and `Policies` are optional.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Result of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Creates a new user 'user01'

response, _ := driver.CreateUser(&structs.User{
  	UserName:         "user01",
  	PassWord:         "U7MRDBFXd2Ab",
  	SystemPrivileges: []string{"SHOW_GRAPH", "TRUNCATE"},
  	GraphPrivileges: structs.GraphPrivileges{
    	"lcc": []string{"UPDATE", "INSERT", "DELETE", "UPSERT"},
  	},
  	PropertyPrivileges: structs.PropertyPrivileges{
        Node: structs.PropertyPrivilegeElement{
            Read: [][]string{
              	{"miniCircle", "account", "*"},
              	{"miniCircle", "movie", "name"},
            },
            Write: [][]string{
              	{"lcc", "*", "*"},
            },
        },
        Edge: structs.PropertyPrivilegeElement{
            Read: [][]string{
              	{"*", "*", "*"},
            },
            Deny: [][]string{
              	{"miniCircle", "*", "*"},
            },
        },
  	},
  	Policies: []string{"manager", "sales"},
}, nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### AlterUser()

Alters the password, privileges and policies of a user. Note that only the mentioned attributes will be updated, others remain unchanged.

**Parameters**

- `user:  *structs.User`: A pointer to the `User` struct used to set new `Password`, `SystemPrivileges`, `GraphPrivileges`, `PropertyPrivilege`, and `Policies` of an existing user identified by the `Username` field.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Result of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Alters the user 'user01'

response, _ := driver.AlterUser(&structs.User{
    UserName:         "user01",
    SystemPrivileges: []string{"CREATE_GRAPH", "SHOW_GRAPH", "SHOW_GRAPH", "TRUNCATE"},
    Policies:         []string{"manager"},
}, nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### DropUser()

Drops a specified database user.

**Parameters**

- `username: string`: Username.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Result of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Drops the user 'user01'

response, _ := driver.DropUser("user01", nil)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full Example

```go
package main

import (
	"fmt"
	"log"

	"github.com/ultipa/ultipa-go-driver/v5/sdk"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/configuration"
	"github.com/ultipa/ultipa-go-driver/v5/sdk/structs"
)

func main() {
	config := &configuration.UltipaConfig{
		// URI example:	Hosts: []string{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"},
		Hosts:    []string{"192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"},
		Username: "<usernmae>",
		Password: "<password>",
	}

	driver, err := sdk.NewUltipaDriver(config)
	if err != nil {
		log.Fatalln("Failed to connect to Ultipa:", err)
	}

	// Creates a new policy 'operator'

	response, _ := driver.CreatePolicy(&structs.Policy{
		Name:             "operator",
		SystemPrivileges: []string{"SHOW_GRAPH", "TRUNCATE"},
		GraphPrivileges: structs.GraphPrivileges{
			"lcc": []string{"UPDATE", "INSERT", "DELETE", "UPSERT"},
		},
		PropertyPrivileges: structs.PropertyPrivileges{
			Node: structs.PropertyPrivilegeElement{
				Read: [][]string{
					{"miniCircle", "account", "*"},
					{"miniCircle", "movie", "name"},
				},
				Write: [][]string{
					{"lcc", "*", "*"},
				},
			},
			Edge: structs.PropertyPrivilegeElement{
				Read: [][]string{
					{"*", "*", "*"},
				},
				Deny: [][]string{
					{"miniCircle", "*", "*"},
				},
			},
		},
		Policies: []string{"manager", "sales"},
	}, nil)
	fmt.Println(response.Status.Code)

}
```
