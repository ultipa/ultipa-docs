# Access Management

This section introduces methods on a `Connection` object for managing access to the instance and graphsets within it, including privileges, policies and users.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Privilege

### ShowPrivilege()

Retrieves all system privileges and graph privileges, which are actually UQL command names categorized based on their operation scope.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Privilege>`: All system privileges and graph privileges.

<p tit= "C#" ></p> 
 
```c#
// Retrieves all system privileges and graph privileges

var res = await ultipa.ShowPrivilege();
var graphL = new List<string>();
var systemL = new List<string>();
foreach (var item in res)
{
    if (item.Level == 0)
    {
        graphL.Add(item.Name);
    }
    else
    {
        systemL.Add(item.Name);
    }
}
Console.WriteLine("Graph privileges: ");
Console.WriteLine(JsonConvert.SerializeObject(graphL));
Console.WriteLine("System privileges: ");
Console.WriteLine(JsonConvert.SerializeObject(systemL));
```

<p tit= "Output" ></p> 
 
```java
Graph privileges:
["TEMPLATE","KHOP","AB","SPREAD","AUTONET","FIND","FIND_NODE","FIND_EDGE","INSERT","EXPORT","UPSERT","UPDATE","DELETE","DELETE_NODE","DELETE_EDGE","CREATE_SCHEMA","DROP_SCHEMA","ALTER_SCHEMA","SHOW_SCHEMA","CREATE_TRIGGER","DROP_TRIGGER","SHOW_TRIGGER","CREATE_BACKUP","RESTORE_BACKUP","SHOW_BACKUP","CREATE_PROPERTY","DROP_PROPERTY","ALTER_PROPERTY","SHOW_PROPERTY","CREATE_FULLTEXT","DROP_FULLTEXT","SHOW_FULLTEXT","CREATE_INDEX","DROP_INDEX","SHOW_INDEX","LTE","UFE","CLEAR_TASK","STOP_TASK","PAUSE_TASK","RESUME_TASK","SHOW_TASK","ALGO","SHOW_ALGO"]
System privileges:
["TRUNCATE","COMPACT","CREATE_GRAPH","SHOW_GRAPH","DROP_GRAPH","ALTER_GRAPH","MOUNT_GRAPH","UNMOUNT_GRAPH","TOP","KILL","STAT","SHOW_POLICY","CREATE_POLICY","DROP_POLICY","ALTER_POLICY","SHOW_USER","CREATE_USER","DROP_USER","ALTER_USER","GRANT","REVOKE","SHOW_PRIVILEGE"]
```

## Policy

### ShowPolicy()

Retrieves all policies from the instance. A policy includes system privileges, graph privileges, property privileges and other policies.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Policy>`: The list of all policies in the instance.

<p tit= "C#" ></p> 
 
```c#
// Retrieves all policies and prints their information

var res = await ultipa.ShowPolicy();
foreach (var item in res)
{
    Console.WriteLine($"Policy '{item.Name}' include:");
    Console.WriteLine(
        "- System privileges: " + JsonConvert.SerializeObject(item.SystemPrivileges)
    );
    Console.WriteLine(
        "- Graph privileges: " + JsonConvert.SerializeObject(item.GraphPrivileges)
    );
    Console.WriteLine(
        "- Property privileges:" + JsonConvert.SerializeObject(item.PropertyPrivileges)
    );
    Console.WriteLine("- Policies:" + JsonConvert.SerializeObject(item.SubPolicies));
}
```
<p tit= "Output" ></p> 
 
```java
Policy 'operator' include:
- System privileges: ["MOUNT_GRAPH","TRUNCATE","SHOW_GRAPH"]
- Graph privileges: {"miniCircle":["UPDATE","INSERT","TEMPLATE","UPSERT","AUTONET"]}
- Property privileges:{"node":{"read":[["*","*","*"]],"write":[["*","*","*"],["miniCircle","account","*"]],"deny":[]},"edge":{"read":[["*","*","*"]],"write":[["*","*","*"]],"deny":[]}}
- Policies:[]
Policy 'manager' include:
- System privileges: ["DROP_POLICY","COMPACT"]
- Graph privileges: {"*":["CREATE_INDEX","DROP_TRIGGER","CREATE_FULLTEXT"]}
- Property privileges:{"node":{"read":[["*","*","*"]],"write":[["*","*","*"]],"deny":[]},"edge":{"read":[["*","*","*"]],"write":[["*","*","*"]],"deny":[]}}
- Policies:["operator"]
```

### GetPolicy()

Retrieves a policy from the instance by its name.

**Parameters:**

- `string`: Name of the policy.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Policy`: The retrieved policy.

<p tit= "C#" ></p> 
 
```c#
// Retrieves a policy 'operator' and prints its information

var res = await ultipa.GetPolicy("operator");
Console.WriteLine("Policy 'operator' includes:");
Console.WriteLine(
    "- System privileges: " + JsonConvert.SerializeObject(res.SystemPrivileges)
);
Console.WriteLine(
    "- Graph privileges: " + JsonConvert.SerializeObject(res.GraphPrivileges)
);
Console.WriteLine(
    "- Property privileges: " + JsonConvert.SerializeObject(res.PropertyPrivileges)
);
Console.WriteLine("- Policies: " + JsonConvert.SerializeObject(res.SubPolicies));
```

<p tit= "Output" ></p> 
 
```java
Policy 'operator' includes:
- System privileges: ["MOUNT_GRAPH","TRUNCATE","SHOW_GRAPH"]
- Graph privileges: {"miniCircle":["UPDATE","INSERT","TEMPLATE","UPSERT","AUTONET"]}
- Property privileges: {"node":{"read":[["*","*","*"]],"write":[["*","*","*"],["miniCircle","account","*"]],"deny":[]},"edge":{"read":[["*","*","*"]],"write":[["*","*","*"]],"deny":[]}}
- Policies: []
```

### CreatePolicy()

Creates a policy in the instance.

**Parameters:**

- `Policy`: The policy to be altered;the field `Name` must be set, `SystemPrivileges`, `GraphPrivileges`, `PropertyPrivileges` and `Policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
// Creates a new policy 'sales' and then retrieves it

Policy policy = new Policy()
{
    Name = "sales",
    
    // System privileges
    SystemPrivileges = new List<string> { "SHOW_GRAPH", "TRUNCATE" },
    
    // Graph privileges
    GraphPrivileges = new()
    {
        {
            "miniCircle",
            new List<string>
            {
                "SHOW_ALGO",
                "ALGO",
                "RESUME_TASK",
                "UFE",
                "CREATE_PROPERTY",
            }
        },
        {
            "lcc",
            new List<string> { "UPDATE", "INSERT", "DELETE", "UPSERT" }
        },
    },

    //Property privileges
    PropertyPrivileges = new PropertyPrivilegeMap()
    {
        NodePrivileges = new PropertyPrivilegeMapItem()
        {
            Read = new List<List<string>>()
            {
                new() { "miniCircle", "account", "*" },
                new() { "miniCircle", "movie", "name" },
            },
            Write = new List<List<string>>()
            {
                new() { "lcc", "*", "*" },
            },
            Deny = new List<List<string>>(),
        },
    },

    // Policies
    SubPolicies = new List<string> { "manager", "operator" },
};

var newPol = await ultipa.CreatePolicy(policy);

// Prints the newly created policy 'sales' 

var res = await ultipa.GetPolicy("sales");
Console.WriteLine($"Policy '{res.Name}' includes:");
Console.WriteLine(
    "- System privileges: " + JsonConvert.SerializeObject(res.SystemPrivileges)
);
Console.WriteLine(
    "- Graph privileges: " + JsonConvert.SerializeObject(res.GraphPrivileges)
);
Console.WriteLine(
    "- Property privileges: " + JsonConvert.SerializeObject(res.PropertyPrivileges)
);
Console.WriteLine("- Policies: " + JsonConvert.SerializeObject(res.SubPolicies));
```

<p tit= "Output" ></p> 
 
```java
Policy 'sales' includes:
- System privileges: ["SHOW_GRAPH","TRUNCATE"]
- Graph privileges: {"miniCircle":["SHOW_ALGO","ALGO","RESUME_TASK","CREATE_PROPERTY","UFE"],"lcc":["UPDATE","INSERT","DELETE","UPSERT"]}
- Property privileges: {"node":{"read":[["*","*","*"],["miniCircle","account","*"],["miniCircle","movie","name"]],"write":[["*","*","*"],["lcc","*","*"]],"deny":[]},"edge":{"read":[["*","*","*"],["*","*","*"]],"write":[["*","*","*"],["*","*","*"]],"deny":[]}}
- Policies: ["manager","operator"]
```

### AlterPolicy()

Alters the system privileges, graph privileges, property privileges and policies of one existing policy in the instance by its name.

**Parameters:**

- `Policy`: The policy to be altered;the field `Name` must be set, `SystemPrivileges`, `GraphPrivileges`, `PropertyPrivileges` and `Policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
// Alters the policy 'sales' and then retrieves it

Policy policy = new Policy()
{
    Name = "sales",
    SystemPrivileges = new List<string> { "SHOW_GRAPH" },
    GraphPrivileges = new()
    {
        {
            "miniCircle",
            new List<string> { "FIND" }
        },
        {
            "lcc",
            new List<string> { "UPDATE" }
        },
    },
    SubPolicies = new List<string> { "operator" },
}

var alterPol = await ultipa.AlterPolicy(policy);
Console.WriteLine(alterPol.Status.ErrorCode);

var res = await ultipa.GetPolicy("sales");
Console.WriteLine($"Policy '{res.Name}' includes:");
Console.WriteLine(
    "- System privileges: " + JsonConvert.SerializeObject(res.SystemPrivileges)
);
Console.WriteLine(
    "- Graph privileges: " + JsonConvert.SerializeObject(res.GraphPrivileges)
);
Console.WriteLine(
    "- Property privileges: " + JsonConvert.SerializeObject(res.PropertyPrivileges)
);
Console.WriteLine("- Policies: " + JsonConvert.SerializeObject(res.SubPolicies));
```

<p tit= "Output" ></p> 
 
```java
Success
Policy 'sales' includes:
- System privileges: ["SHOW_GRAPH"]
- Graph privileges: {"miniCircle":["FIND"],"lcc":["UPDATE"]}
- Property privileges: {"node":{"read":[["*","*","*"],["*","*","*"]],"write":[["*","*","*"],["*","*","*"]],"deny":[]},"edge":{"read":[["*","*","*"],["*","*","*"]],"write":[["*","*","*"],["*","*","*"]],"deny":[]}}
- Policies: ["operator"]
```

### DropPolicy()

Drops one policy from the instance by its name.

**Parameters:**

- `string`: Name of the policy.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
// Drops the policy 'sales' and prints error code

var res = await ultipa.DropPolicy("sales");
Console.WriteLine(res.Status.ErrorCode);
```

<p tit= "Output" ></p> 
 
```java
Success
```

## User

### ShowUser()

Retrieves all database users from the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<User>`: The list of all users in the instance.

<p tit= "C#" ></p> 
 
```c#
// Retrieves all users and prints information of the first returned

var res = await ultipa.ShowUser();
Console.WriteLine("Username: " + res[0].Username);
Console.WriteLine("Created on: " + res[0].CreatedTime);
Console.WriteLine(
    "System privileges: " + JsonConvert.SerializeObject(res[0].SystemPrivileges)
);
Console.WriteLine(
    "Graph privileges: " + JsonConvert.SerializeObject(res[0].GraphPrivileges)
);
Console.WriteLine(
    "Property privileges: " + JsonConvert.SerializeObject(res[0].GraphPrivileges)
);
Console.WriteLine("Policies: " + JsonConvert.SerializeObject(res[0].Policies));
```

<p tit= "Output" ></p> 
 
```java
Username: test006
Created on: 9/1/2023 6:37:56 AM
System privileges: ["SHOW_PRIVILEGE","ALTER_USER","DROP_USER","CREATE_USER","SHOW_GRAPH","ALTER_GRAPH","DROP_GRAPH","COMPACT","MOUNT_GRAPH","TOP","CREATE_GRAPH","STAT","UNMOUNT_GRAPH","SHOW_POLICY","TRUNCATE","KILL","ALTER_POLICY","CREATE_POLICY","DROP_POLICY","SHOW_USER"]
Graph privileges: {}
Property privileges: {}
Policies: ["operator"]
```

### GetUser()

Retrieves a database user from the instance by its username.

**Parameters:**

- `string`: Username.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `User`: The retrieved user.

<p tit= "C#" ></p> 
 
```c#
// Retrieves user 'test005' and prints its information

var res = await ultipa.GetUser("test005");
Console.WriteLine("Username: " + res.Username);
Console.WriteLine("Created on: " + res.CreatedTime);
Console.WriteLine(
    "System privileges: " + JsonConvert.SerializeObject(res.SystemPrivileges)
);
Console.WriteLine("Graph privileges: " + JsonConvert.SerializeObject(res.GraphPrivileges));
Console.WriteLine(
    "Property privileges: " + JsonConvert.SerializeObject(res.GraphPrivileges)
);
Console.WriteLine("Policies: " + JsonConvert.SerializeObject(res.Policies));
```

<p tit= "Output" ></p> 
 
```java
Username: test005
Created on: 8/31/2023 9:15:59 AM
System privileges: ["SHOW_PRIVILEGE","ALTER_USER","DROP_USER","CREATE_USER","SHOW_GRAPH","ALTER_GRAPH","DROP_GRAPH","COMPACT","MOUNT_GRAPH","TOP","CREATE_GRAPH","STAT","UNMOUNT_GRAPH","SHOW_POLICY","TRUNCATE","KILL","ALTER_POLICY","CREATE_POLICY","DROP_POLICY","SHOW_USER"]
Graph privileges: {}
Property privileges: {}
Policies: ["operator"]
```

### CreateUser()

Creates a database user in the instance.

**Parameters:**

- `User`: The user to be created; the fields `Username` and `Password` must be set, `SystemPrivilegess`, `GraphPrivileges`, `PropertyPrivileges` and `Policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
// Creates a new user 'CSharpUser' and prints error code
User newUser = new User()
{
    Username = "CSharpUser",
    Password = "Password",
    Privileges = new Policy()
    {
        GraphPrivileges = new()
        {
            {
                "miniCircle",
                new List<string>
                {
                    "SHOW_ALGO",
                    "ALGO",
                    "RESUME_TASK",
                    "UFE",
                    "CREATE_PROPERTY",
                }
            },
        },
        SystemPrivileges = new() { "SHOW_GRAPH", "TRUNCATE" },
        PropertyPrivileges = new PropertyPrivilegeMap()
        {
            NodePrivileges = new PropertyPrivilegeMapItem()
            {
                Read = new List<List<string>>()
                {
                    new() { "miniCircle", "account", "*" },
                    new() { "miniCircle", "movie", "name" },
                },
                Write = new List<List<string>>()
                {
                    new() { "lcc", "*", "*" },
                },
                Deny = new List<List<string>>(),
            },
        },
        SubPolicies = new() { "manager", "operator" },
    },
};
```

<p tit= "Output" ></p> 
 
```java
Success
```

### AlterUser()

Alters the password, system privileges, graph privileges, property privileges and policies of one existing database user in the instance by its username.

**Parameters:**

- `User`: The user to be altered; the field `Username` must be set, `Password`, `SystemPrivilegess`, `GraphPrivileges`, `PropertyPrivileges` and `Policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
// Alters the user 'CSharpUser' and prints error code
User newUser = new User()
{
    Username = "CSharpUser",
    Password = "Password123",
    Privileges = new Policy()
    {
        GraphPrivileges = new()
        {
            {
                "miniCircle",
                new() { "FIND" }
            },
            {
                "lcc",
                new() { "UPDATE" }
            },
        },
        SystemPrivileges = new() { "SHOW_GRAPH" },
        SubPolicies = new() { "operator" },
    },
};

var res = await ultipa.AlterUser(newUser);
Console.WriteLine(res.Status.ErrorCode);
```

<p tit= "Output" ></p> 
 
```java
Success
```

### DropUser()

Drops one database user from the instance by its username.

**Parameters:**

- `string`: Username.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
// Drops the user 'CSharpUser' and prints error code

var res = await ultipa.DropUser("CSharpUser");
Console.WriteLine(res.Status.ErrorCode);
```

<p tit= "Output" ></p> 
 
```java
Success
```

### GrantPolicy()

Grants policies to a database user in the instance.

**Parameters:**

- `string`: Username.
- `List<string>`: Policies to grant.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
// Grants policies 'operator' and 'manager' to user 'johndoe' and prints error code
var res = await ultipa.GrantPolicy("johndoe", policies: new() { "operator", "manager" });
Console.WriteLine(res.Status.ErrorCode);
```

<p tit= "Output" ></p> 
 
```java
Success
```

### RevokePolicy()

Revokes policies from a database user in the instance.

**Parameters:**

- `string`: Username.
- `List<string>`: Policies to revoke.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.RevokePolicy("johndoe", policies: new() { "operator", "manager" });
Console.WriteLine(res.Status.ErrorCode);
```

<p tit= "Output" ></p> 
 
```java
Success
```

## Full Example

<p tit= "C#" ></p> 

```c#
using System.Data;
using System.Security.Cryptography.X509Certificates;
using System.Xml.Linq;
using Google.Protobuf.WellKnownTypes;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using UltipaService;
using UltipaSharp;
using UltipaSharp.api;
using UltipaSharp.configuration;
using UltipaSharp.connection;
using UltipaSharp.exceptions;
using UltipaSharp.structs;
using UltipaSharp.utils;
using Logger = UltipaSharp.utils.Logger;
using Property = UltipaSharp.structs.Property;
using Schema = UltipaSharp.structs.Schema;

class Program
{
    static async Task Main(string[] args)
    {
        // Connection configurations
        //URI example: Hosts=new[]{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"}
        var myconfig = new UltipaConfig()
        {
            Hosts = new[] { "192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061" },
            Username = "***",
            Password = "***",
        };

        // Establishes connection to the database
        var ultipa = new Ultipa(myconfig);
        var isSuccess = ultipa.Test();
        Console.WriteLine(isSuccess);

        // Request configurations
        RequestConfig requestConfig = new RequestConfig()
        {
            UseMaster = true,
            Graph = "miniCircle",
        };


        // Retrieves all policies and prints their information
        var res = await ultipa.ShowPolicy();
        foreach (var item in res)
        {
            Console.WriteLine($"Policy '{item.Name}' include:");
            Console.WriteLine(
                "- System privileges: " + JsonConvert.SerializeObject(item.SystemPrivileges)
            );
            Console.WriteLine(
                "- Graph privileges: " + JsonConvert.SerializeObject(item.GraphPrivileges)
            );
            Console.WriteLine(
                "- Property privileges:" + JsonConvert.SerializeObject(item.PropertyPrivileges)
            );
            Console.WriteLine("- Policies:" + JsonConvert.SerializeObject(item.SubPolicies));
        }
      
    }
}
```
