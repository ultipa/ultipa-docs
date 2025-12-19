# Access Control

This section introduces methods for controlling access to the database, graphs, and data.

# Privilege

### showPrivilege()

Retrieves all system privileges and graph privileges.

**Parameters**

- None.

**Returns**

- `List<Privilege>`: The list of retrieved privileges.

```java
// Retrieves all running processes in the database

List<Privilege> privileges = driver.showPrivilege();

String graphPrivilegeNames = privileges.stream()
		.filter(p -> p.getLevel() == PrivilegeLevel.GRAPH_LEVEL)
		.map(Privilege::getName)
		.collect(Collectors.joining(", "));
System.out.println("Graph privileges: " + graphPrivilegeNames);

String systemPrivilegeNames = privileges.stream()
		.filter(p -> p.getLevel() == PrivilegeLevel.SYSTEM_LEVEL)
		.map(Privilege::getName)
		.collect(Collectors.joining(", "));
System.out.println("System privileges: " + systemPrivilegeNames);
```

<p tit="Output"></p> 
 
```
Graph privileges: READ, INSERT, UPSERT, UPDATE, DELETE, CREATE_SCHEMA, DROP_SCHEMA, ALTER_SCHEMA, SHOW_SCHEMA, RELOAD_SCHEMA, CREATE_PROPERTY, DROP_PROPERTY, ALTER_PROPERTY, SHOW_PROPERTY, CREATE_FULLTEXT, DROP_FULLTEXT, SHOW_FULLTEXT, CREATE_INDEX, DROP_INDEX, SHOW_INDEX, LTE, UFE, CLEAR_JOB, STOP_JOB, SHOW_JOB, ALGO, CREATE_PROJECT, SHOW_PROJECT, DROP_PROJECT, CREATE_HDC_GRAPH, SHOW_HDC_GRAPH, DROP_HDC_GRAPH, COMPACT_HDC_GRAPH, SHOW_VECTOR_INDEX, CREATE_VECTOR_INDEX, DROP_VECTOR_INDEX, SHOW_CONSTRAINT, CREATE_CONSTRAINT, DROP_CONSTRAINT
System privileges: TRUNCATE, COMPACT, CREATE_GRAPH, SHOW_GRAPH, DROP_GRAPH, ALTER_GRAPH, TOP, KILL, STAT, SHOW_POLICY, CREATE_POLICY, DROP_POLICY, ALTER_POLICY, SHOW_USER, CREATE_USER, DROP_USER, ALTER_USER, SHOW_PRIVILEGE, SHOW_META, SHOW_SHARD, ADD_SHARD, DELETE_SHARD, REPLACE_SHARD, SHOW_HDC_SERVER, ADD_HDC_SERVER, DELETE_HDC_SERVER, LICENSE_UPDATE, LICENSE_DUMP, GRANT, REVOKE, SHOW_BACKUP, CREATE_BACKUP, SHOW_VECTOR_SERVER, ADD_VECTOR_SERVER, DELETE_VECTOR_SERVER
```

## Policy (Role)

### showPolicy()

Retrieves all policies in the database.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Policy>`: The list of retrieved policies.

```java
// Retrieves all policies

List<Policy> policies = driver.showPolicy();
for (Policy policy : policies) {
  	System.out.println(policy.getName());
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

- `policyName: String`: Name of the policy.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Policy`: The retrieved policy.

```java
// Retrieves the policy 'Tester'

Policy policy = driver.getPolicy("Tester");
System.out.println("Graph privileges: " + policy.getGraphPrivileges());
System.out.println("System privileges: " + policy.getSystemPrivileges());
System.out.println("Property privileges:");
System.out.println("- Node (Read): " + policy.getPropertyPrivileges().getNode().getRead());
System.out.println("- Node (Write): " + policy.getPropertyPrivileges().getNode().getWrite());
System.out.println("- Node (Deny): " + policy.getPropertyPrivileges().getNode().getDeny());
System.out.println("- Edge (Read): " + policy.getPropertyPrivileges().getEdge().getRead());
System.out.println("- Edge (Write): " + policy.getPropertyPrivileges().getEdge().getWrite());
System.out.println("- Edge (Deny): " + policy.getPropertyPrivileges().getEdge().getDeny());
System.out.println("Policies: " + policy.getPolicies());
```

<p tit="Output"></p> 
 
```
Graph privileges: {amz=[ALGO, DROP_FULLTEXT, INSERT, DELETE, UPSERT], StoryGraph=[UPDATE, READ]}
System privileges: [TRUNCATE, KILL, TOP]
Property privileges:
- Node (Read): [[*, *, *]]
- Node (Write): []
- Node (Deny): []
- Edge (Read): []
- Edge (Write): [[amz, *, *], [alimama, *, *]]
- Edge (Deny): [[miniCircle, review, value, timestamp]]
Policies: [manager, sales]
```

### createPolicy()

Creates a policy in the database.

**Parameters**

- `policy: Policy`: The policy to be created; the attribute `name` is mandatory, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Creates a new policy 'operator'
Policy policy = new Policy();

// Set the name of the policy
policy.setName("operator");

// Set system privileges for the policy
policy.setSystemPrivileges(Lists.newArrayList("SHOW_GRAPH","TRUNCATE"));

// Create and set graph privileges for the policy
Map<String,List<String>> graphPrivileges = new HashMap<>();
graphPrivileges.put("lcc", Lists.newArrayList("UPDATE","INSERT","DELETE","UPSERT"));
policy.setGraphPrivileges(graphPrivileges);

// Create and set property privileges for the policy
PropertyPrivilege propertyPrivilege = new PropertyPrivilege();
PropertyPrivilegeElement node = new PropertyPrivilegeElement();
node.setRead(Lists.newArrayList(
		Lists.newArrayList("miniCircle", "account", "*"),
		Lists.newArrayList("miniCircle", "movie", "name")));
node.setWrite(Lists.newArrayList(
		Collections.singleton(Lists.newArrayList("lcc", "*", "*"))));
PropertyPrivilegeElement edge = new PropertyPrivilegeElement();
edge.setRead(Lists.newArrayList(
		Collections.singleton(Lists.newArrayList("*", "*", "*"))));
edge.setDeny(Lists.newArrayList(
		Collections.singleton(Lists.newArrayList("miniCircle", "*", "*"))));
propertyPrivilege.setNode(node);
propertyPrivilege.setEdge(edge);
policy.setGraphPrivileges(graphPrivileges);

// Set policies for the policy
policy.setPolicies(Lists.newArrayList("manager", "sales"));

Response response = driver.createPolicy(policy);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### alterPolicy()

Alters the privileges and policies included in a policy. Note that only the mentioned attributes will be updated, others remain unchanged.

**Parameters**

- `policy: Policy`: A `Policy` object used to set the new `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` of an existing policy identified by the `name` atttibute.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Alters the policy 'operator'

Policy policy = new Policy();
policy.setName("operator");
policy.setSystemPrivileges(Lists.newArrayList("CREATE_GRAPH","SHOW_GRAPH","SHOW_GRAPH","TRUNCATE"));
policy.setPolicies(Lists.newArrayList("manager"));

Response response = driver.alterPolicy(policy);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropPolicy()

Drops a specified policy from the database.

**Parameters**

- `policyName: String`: Name of the policy.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Drops the policy 'operator'

Response response = driver.dropPolicy("operator");
System.out.println(response.getStatus().getCode());
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

- `List<User>`: The list of retrieved users.

```java
// Retrieves all database users

List<User> users = driver.showUser();
for (User user : users) {
    System.out.println(user.getUsername());
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

- `username: String`: Username.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `User`: The retrieved user.

```java
// Retrieves the database user 'johndoe'

User user = driver.getUser("johndoe");
System.out.println("CreatedTime: " + user.getCreatedTime());
System.out.println("Graph privileges: " + user.getGraphPrivileges());
System.out.println("System privileges: " + user.getSystemPrivileges());
System.out.println("Property privileges:");
System.out.println("- Node (Read): " + user.getPropertyPrivileges().getNode().getRead());
System.out.println("- Node (Write): " + user.getPropertyPrivileges().getNode().getWrite());
System.out.println("- Node (Deny): " + user.getPropertyPrivileges().getNode().getDeny());
System.out.println("- Edge (Read): " + user.getPropertyPrivileges().getEdge().getRead());
System.out.println("- Edge (Write): " + user.getPropertyPrivileges().getEdge().getWrite());
System.out.println("- Edge (Deny): " + user.getPropertyPrivileges().getEdge().getDeny());
System.out.println("Policies: " + user.getPolicies());
```

<p tit="Output"></p> 
 
```
CreatedTime: Wed Apr 02 11:08:38 CST 2025
Graph privileges: {amz=[ALGO, INSERT, DELETE, UPSERT], StoryGraph=[UPDATE, READ]}
System privileges: [TRUNCATE, KILL, TOP]
Property privileges:
- Node (Read): [[*, *, *]]
- Node (Write): []
- Node (Deny): []
- Edge (Read): []
- Edge (Write): [[amz, *, *], [alimama, *, *]]
- Edge (Deny): []
Policies: [sales, manager]
```

### createUser()

Creates a database user.

**Parameters**

- `user: User`: The user to be created; the attributes `username` and `password` are mandatory, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Creates a new user 'user01'
User user = new User();

// Set the username and password of the user
user.setUsername("user01");
user.setPassword("U7MRDBFXd2Ab");

// Set system privileges for the user
user.setSystemPrivileges(Lists.newArrayList("SHOW_GRAPH","TRUNCATE"));

// Create and set graph privileges for the user
Map<String,List<String>> graphPrivileges = new HashMap<>();
graphPrivileges.put("lcc", Lists.newArrayList("UPDATE","INSERT","DELETE","UPSERT"));
user.setGraphPrivileges(graphPrivileges);

// Create and set property privileges for the user
PropertyPrivilege propertyPrivilege = new PropertyPrivilege();
PropertyPrivilegeElement node = new PropertyPrivilegeElement();
node.setRead(Lists.newArrayList(
		Lists.newArrayList("miniCircle", "account", "*"),
		Lists.newArrayList("miniCircle", "movie", "name")));
node.setWrite(Lists.newArrayList(
		Collections.singleton(Lists.newArrayList("lcc", "*", "*"))));
PropertyPrivilegeElement edge = new PropertyPrivilegeElement();
edge.setRead(Lists.newArrayList(
		Collections.singleton(Lists.newArrayList("*", "*", "*"))));
edge.setDeny(Lists.newArrayList(
		Collections.singleton(Lists.newArrayList("miniCircle", "*", "*"))));
propertyPrivilege.setNode(node);
propertyPrivilege.setEdge(edge);
user.setGraphPrivileges(graphPrivileges);

// Set policies for the user
user.setPolicies(Lists.newArrayList("manager", "sales"));

Response response = driver.createUser(user);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p>

```
SUCCESS
```

### alterUser()

Alters the password, privileges and policies of a user. Note that only the mentioned attributes will be updated, others remain unchanged.

**Parameters**

- `user: User`: A `User` object used to set the new `password`, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege`, and `policies` of an existing user identified by the `username` atttibute.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Alters the user 'user01'

User user = new User();
user.setUsername("user01");
user.setSystemPrivileges(Lists.newArrayList("CREATE_GRAPH","SHOW_GRAPH","SHOW_GRAPH","TRUNCATE"));
user.setPolicies(Lists.newArrayList("manager"));

Response response = driver.alterUser(user);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropUser()

Drops a specified database user.

**Parameters**

- `username: String`: Username.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Drops the user 'user01'

Response response = driver.dropUser("user01");
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full Example

<p tit="Main.java"></p> 

```java
package com.ultipa.www.sdk.api;

import com.google.common.collect.Lists;
import com.ultipa.sdk.UltipaDriver;
import com.ultipa.sdk.connect.conf.UltipaConfig;
import com.ultipa.sdk.operate.entity.*;
import com.ultipa.sdk.operate.response.Response;

import java.util.*;

public class Main {
    public static void main(String[] args) {
        UltipaConfig ultipaConfig = UltipaConfig.config()
               // URI example: .hosts(Lists.newArrayList("d3026ac361964633986849ec43b84877s.eu-south-1.cloud.ultipa.com:8443"))
                .hosts(Lists.newArrayList("192.168.1.85:60061","192.168.1.88:60061","192.168.1.87:60061"))
                .username("<username>")
                .password("<password>");

        UltipaDriver driver = null;

        try {
            driver = new UltipaDriver(ultipaConfig);

            // Creates a new policy 'operator'
            Policy policy = new Policy();

            // Set the name of the policy
            policy.setName("operator");

            // Set system privileges for the policy
            policy.setSystemPrivileges(Lists.newArrayList("SHOW_GRAPH","TRUNCATE"));

            // Create and set graph privileges for the policy
            Map<String,List<String>> graphPrivileges = new HashMap<>();
            graphPrivileges.put("lcc", Lists.newArrayList("UPDATE","INSERT","DELETE","UPSERT"));
            policy.setGraphPrivileges(graphPrivileges);

            // Create and set property privileges for the policy
            PropertyPrivilege propertyPrivilege = new PropertyPrivilege();
            PropertyPrivilegeElement node = new PropertyPrivilegeElement();
            node.setRead(Lists.newArrayList(
                    Lists.newArrayList("miniCircle", "account", "*"),
                    Lists.newArrayList("miniCircle", "movie", "name")));
            node.setWrite(Lists.newArrayList(
                    Collections.singleton(Lists.newArrayList("lcc", "*", "*"))));
            PropertyPrivilegeElement edge = new PropertyPrivilegeElement();
            edge.setRead(Lists.newArrayList(
                    Collections.singleton(Lists.newArrayList("*", "*", "*"))));
            edge.setDeny(Lists.newArrayList(
                    Collections.singleton(Lists.newArrayList("miniCircle", "*", "*"))));
            propertyPrivilege.setNode(node);
            propertyPrivilege.setEdge(edge);
            policy.setGraphPrivileges(graphPrivileges);

            // Set policies for the policy
            policy.setPolicies(Lists.newArrayList("manager", "sales"));

            Response response = driver.createPolicy(policy);
            System.out.println(response.getStatus().getCode());
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```
