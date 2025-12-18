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

```java
// Retrieves all system privileges and graph privileges

Privilege privilege = client.showPrivilege();
System.out.println("System privileges: " + privilege.getSystemPrivileges());
System.out.println("Graph privileges: " + privilege.getGraphPrivileges());
```

<p tit="Output"></p> 
 
```
System privileges: [TRUNCATE, COMPACT, CREATE_GRAPH, SHOW_GRAPH, DROP_GRAPH, ALTER_GRAPH, MOUNT_GRAPH, UNMOUNT_GRAPH, TOP, KILL, STAT, SHOW_POLICY, CREATE_POLICY, DROP_POLICY, ALTER_POLICY, SHOW_USER, CREATE_USER, DROP_USER, ALTER_USER, GRANT, REVOKE, SHOW_PRIVILEGE]
Graph privileges: [TEMPLATE, KHOP, AB, SPREAD, AUTONET, FIND, FIND_NODE, FIND_EDGE, INSERT, EXPORT, UPSERT, UPDATE, DELETE, DELETE_NODE, DELETE_EDGE, CREATE_SCHEMA, DROP_SCHEMA, ALTER_SCHEMA, SHOW_SCHEMA, CREATE_TRIGGER, DROP_TRIGGER, SHOW_TRIGGER, CREATE_BACKUP, RESTORE_BACKUP, SHOW_BACKUP, CREATE_PROPERTY, DROP_PROPERTY, ALTER_PROPERTY, SHOW_PROPERTY, CREATE_FULLTEXT, DROP_FULLTEXT, SHOW_FULLTEXT, CREATE_INDEX, DROP_INDEX, SHOW_INDEX, LTE, UFE, CLEAR_TASK, STOP_TASK, PAUSE_TASK, RESUME_TASK, SHOW_TASK, ALGO, SHOW_ALGO]
```

## Policy

### showPolicy()

Retrieves all policies from the instance. A policy includes system privileges, graph privileges, property privileges and other policies.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Policy>`: The list of all policies in the instance.

```java
// Retrieves all policies and prints their information

List<Policy> policyList = client.showPolicy();
for (Policy policy : policyList) {
    System.out.println("Policy '" + policy.getName() + "' include:");
    System.out.println("- System privileges: " + policy.getSystemPrivileges());
    System.out.println("- Graph privileges: " + policy.getGraphPrivileges());
    System.out.println("- Property privileges: " + policy.getPropertyPrivileges());
    System.out.println("- Policies: " + policy.getPolicies());
}
```

<p tit="Output"></p> 
 
```
Policy 'manager' include:
- System privileges: [DROP_POLICY, COMPACT]
- Graph privileges: {*=[CREATE_INDEX, DROP_TRIGGER, CREATE_FULLTEXT]}
- Property privileges: PropertyPrivilege(node=PropertyPrivilegeElement(read=[], write=[], deny=[]), edge=PropertyPrivilegeElement(read=[], write=[], deny=[]))
- Policies: [operator]
Policy 'operator' include:
- System privileges: [MOUNT_GRAPH, TRUNCATE, SHOW_GRAPH]
- Graph privileges: {miniCircle=[UPDATE, INSERT, TEMPLATE, UPSERT, AUTONET]}
- Property privileges: PropertyPrivilege(node=PropertyPrivilegeElement(read=[], write=[PropertyPrivilegeValue(graphName=miniCircle, schemaName=account, propertyName=*)], deny=[]), edge=PropertyPrivilegeElement(read=[], write=[], deny=[]))
- Policies: []
```

### getPolicy()

Retrieves a policy from the instance by its name.

**Parameters:**

- `String`: Name of the policy.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Policy`: The retrieved policy.

```java
// Retrieves a policy 'operator' and prints its information

Policy policy = client.getPolicy("operator");
System.out.println("Policy '" + policy.getName() + "' include:");
System.out.println("- System privileges: " + policy.getSystemPrivileges());
System.out.println("- Graph privileges: " + policy.getGraphPrivileges());
System.out.println("- Property privileges: " + policy.getPropertyPrivileges());
System.out.println("- Policies: " + policy.getPolicies());
```

<p tit="Output"></p> 
 
```
Policy 'operator' include:
- System privileges: [MOUNT_GRAPH, TRUNCATE, SHOW_GRAPH]
- Graph privileges: {miniCircle=[UPDATE, INSERT, TEMPLATE, UPSERT, AUTONET]}
- Property privileges: PropertyPrivilege(node=PropertyPrivilegeElement(read=[], write=[PropertyPrivilegeValue(graphName=miniCircle, schemaName=account, propertyName=*)], deny=[]), edge=PropertyPrivilegeElement(read=[], write=[], deny=[]))
- Policies: []
```

### createPolicy()

Creates a policy in the instance.

**Parameters:**

- `Policy`: The policy to be created; the field `name` must be set, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Creates a new policy 'sales' and then retrieves it

Policy policy = new Policy();
policy.setName("sales");

// System privileges
policy.setSystemPrivileges(Lists.newArrayList("SHOW_GRAPH","TRUNCATE"));

// Graph privileges
Map<String,List<String>> graphPrivileges = new HashMap<>();
graphPrivileges.put("miniCircle", Lists.newArrayList("FIND","SPREAD","AUTONET","AB","TEMPLATE","KHOP"));
graphPrivileges.put("lcc", Lists.newArrayList("UPDATE","INSERT","DELETE","UPSERT"));
policy.setGraphPrivileges(graphPrivileges);

// Property privileges
PropertyPrivilege propertyPrivilege = new PropertyPrivilege();

PropertyPrivilegeElement node = new PropertyPrivilegeElement();
PropertyPrivilegeValue nodeValue1 = new PropertyPrivilegeValue();
nodeValue1.setGraphName("miniCircle");
nodeValue1.setSchemaName("account");
PropertyPrivilegeValue nodeValue2 = new PropertyPrivilegeValue();
nodeValue2.setGraphName("miniCircle");
nodeValue2.setSchemaName("movie");
nodeValue2.setPropertyName("name");
PropertyPrivilegeValue nodeValue3 = new PropertyPrivilegeValue();
nodeValue3.setGraphName("lcc");
nodeValue3.setSchemaName("*");
nodeValue3.setPropertyName("*");
node.setRead(Lists.newArrayList(nodeValue1,nodeValue2));
node.setWrite(Lists.newArrayList(nodeValue3));
propertyPrivilege.setNode(node);

PropertyPrivilegeElement edge = new PropertyPrivilegeElement();
PropertyPrivilegeValue edgeValue1 = new PropertyPrivilegeValue();
edgeValue1.setGraphName("*");
PropertyPrivilegeValue edgeValue2 = new PropertyPrivilegeValue();
edgeValue2.setGraphName("miniCircle");
edgeValue2.setSchemaName("*");
edgeValue2.setPropertyName("*");
edge.setRead(Lists.newArrayList(edgeValue1));
edge.setWrite(Lists.newArrayList(edgeValue2));
propertyPrivilege.setEdge(edge);

policy.setPropertyPrivileges(propertyPrivilege);

// Policies
policy.setPolicies(Lists.newArrayList("manager", "operator"));

Response response = client.createPolicy(policy);
System.out.println(response.getStatus().getErrorCode());

Thread.sleep(3000);

Policy policy1 = client.getPolicy("sales");
System.out.println("Policy '" + policy1.getName() + "' include:");
System.out.println("- System privileges: " + policy1.getSystemPrivileges());
System.out.println("- Graph privileges: " + policy1.getGraphPrivileges());
System.out.println("- Property privileges: " + policy1.getPropertyPrivileges());
System.out.println("- Policies: " + policy1.getPolicies());
```

<p tit="Output"></p> 
 
```
SUCCESS
Policy 'sales' include:
- System privileges: [SHOW_GRAPH, TRUNCATE]
- Graph privileges: {miniCircle=[FIND, SPREAD, AUTONET, AB, TEMPLATE, KHOP], lcc=[UPDATE, INSERT, DELETE, UPSERT]}
- Property privileges: PropertyPrivilege(node=PropertyPrivilegeElement(read=[PropertyPrivilegeValue(graphName=miniCircle, schemaName=account, propertyName=*), PropertyPrivilegeValue(graphName=miniCircle, schemaName=movie, propertyName=name)], write=[PropertyPrivilegeValue(graphName=lcc, schemaName=*, propertyName=*)], deny=[]), edge=PropertyPrivilegeElement(read=[PropertyPrivilegeValue(graphName=*, schemaName=*, propertyName=*)], write=[PropertyPrivilegeValue(graphName=miniCircle, schemaName=*, propertyName=*)], deny=[]))
- Policies: [manager, operator]
```

### alterPolicy()

Alters the system privileges, graph privileges, property privileges and policies of one existing policy in the instance by its name.

**Parameters:**

- `Policy`: The policy to be altered; the field `name` must be set, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Alters the policy 'sales' and then retrieves it

Policy policy = new Policy();
policy.setName("sales");

// System privileges
policy.setSystemPrivileges(Lists.newArrayList("SHOW_GRAPH"));

// Graph privileges
Map<String,List<String>> graphPrivileges = new HashMap<>();
graphPrivileges.put("miniCircle", Lists.newArrayList("FIND"));
graphPrivileges.put("lcc", Lists.newArrayList("UPDATE"));
policy.setGraphPrivileges(graphPrivileges);

// Policies
policy.setPolicies(Lists.newArrayList("operator"));

Response response = client.alterPolicy(policy);
System.out.println(response.getStatus().getErrorCode());

Thread.sleep(3000);

Policy policy1 = client.getPolicy("sales");
System.out.println("Policy '" + policy1.getName() + "' include:");
System.out.println("- System privileges: " + policy1.getSystemPrivileges());
System.out.println("- Graph privileges: " + policy1.getGraphPrivileges());
System.out.println("- Property privileges: " + policy1.getPropertyPrivileges());
System.out.println("- Policies: " + policy1.getPolicies());
```

<p tit="Output"></p> 
 
```
SUCCESS
Policy 'sales' include:
- System privileges: [SHOW_GRAPH]
- Graph privileges: {miniCircle=[FIND], lcc=[UPDATE]}
- Property privileges: PropertyPrivilege(node=PropertyPrivilegeElement(read=[PropertyPrivilegeValue(graphName=miniCircle, schemaName=account, propertyName=*), PropertyPrivilegeValue(graphName=miniCircle, schemaName=movie, propertyName=name)], write=[PropertyPrivilegeValue(graphName=lcc, schemaName=*, propertyName=*)], deny=[]), edge=PropertyPrivilegeElement(read=[PropertyPrivilegeValue(graphName=*, schemaName=*, propertyName=*)], write=[PropertyPrivilegeValue(graphName=miniCircle, schemaName=*, propertyName=*)], deny=[]))
- Policies: [operator]
```

### dropPolicy()

Drops one policy from the instance by its name.

**Parameters:**

- `String`: Name of the policy.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Drops the policy 'sales' and prints error code

Response response = client.dropPolicy("sales");
System.out.println(response.getStatus().getErrorCode());
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

- `List<User>`: The list of all users in the instance.

```java
// Retrieves all users and prints information of the first returned

List<User> userList = client.showUser();
System.out.println("Username: " + userList.get(0).getUsername());
System.out.println("Created on: " + userList.get(0).getCreate());
System.out.println("System privileges: " + userList.get(0).getSystemPrivileges());
System.out.println("Graph privileges: " + userList.get(0).getGraphPrivileges());
System.out.println("Property privileges: " + userList.get(0).getPropertyPrivileges());
System.out.println("Policies: " + userList.get(0).getPolicies());
```

<p tit="Output"></p> 
 
```
Username: test006
Created on: Fri Sep 01 14:37:56 CST 2023
System privileges: [SHOW_PRIVILEGE, ALTER_USER, DROP_USER, CREATE_USER, SHOW_GRAPH, ALTER_GRAPH, DROP_GRAPH, COMPACT, MOUNT_GRAPH, TOP, CREATE_GRAPH, STAT, UNMOUNT_GRAPH, SHOW_POLICY, TRUNCATE, KILL, ALTER_POLICY, CREATE_POLICY, DROP_POLICY, SHOW_USER]
Graph privileges: {miniCircle831=[SHOW_ALGO, DROP_SCHEMA, ALTER_PROPERTY, ALGO, CREATE_PROPERTY, SHOW_SCHEMA, FIND, DROP_PROPERTY, RESUME_TASK, UPDATE, EXPORT, KHOP, SHOW_INDEX, TEMPLATE, CREATE_SCHEMA, SHOW_TASK, ALTER_SCHEMA, AUTONET, SHOW_TRIGGER, LTE, CREATE_TRIGGER, UFE, DROP_TRIGGER, UPSERT, SHOW_PROPERTY, DELETE, CREATE_FULLTEXT, SPREAD, DROP_FULLTEXT, INSERT, CREATE_INDEX, DROP_INDEX, CLEAR_TASK, SHOW_FULLTEXT, STOP_TASK, AB, PAUSE_TASK]}
Property privileges: PropertyPrivilege(node=PropertyPrivilegeElement(read=[], write=[], deny=[PropertyPrivilegeValue(graphName=*, schemaName=*, propertyName=*)]), edge=PropertyPrivilegeElement(read=[], write=[], deny=[PropertyPrivilegeValue(graphName=*, schemaName=*, propertyName=*)]))
Policies: [operator]
```

### getUser()

Retrieves a database user from the instance by its username.

**Parameters:**

- `String`: Username.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `User`: The retrieved user.

```java
// Retrieves user 'test005' and prints its information

User user = client.getUser("test005");
System.out.println("Username: " + user.getUsername());
System.out.println("Created on: " + user.getCreate());
System.out.println("System privileges: " + user.getSystemPrivileges());
System.out.println("Graph privileges: " + user.getGraphPrivileges());
System.out.println("Property privileges: " + user.getPropertyPrivileges());
System.out.println("Policies: " + user.getPolicies());
```

<p tit="Output"></p> 
 
```
Username: test005
Created on: Thu Aug 31 17:15:59 CST 2023
System privileges: [SHOW_PRIVILEGE, ALTER_USER, DROP_USER, CREATE_USER, SHOW_GRAPH, ALTER_GRAPH, DROP_GRAPH, COMPACT, MOUNT_GRAPH, TOP, CREATE_GRAPH, STAT, UNMOUNT_GRAPH, SHOW_POLICY, TRUNCATE, KILL, ALTER_POLICY, CREATE_POLICY, DROP_POLICY, SHOW_USER]
Graph privileges: {miniCircle831=[SHOW_ALGO, DROP_SCHEMA, ALTER_PROPERTY, ALGO, CREATE_PROPERTY, SHOW_SCHEMA, FIND, DROP_PROPERTY, RESUME_TASK, UPDATE, EXPORT, KHOP, SHOW_INDEX, TEMPLATE, CREATE_SCHEMA, SHOW_TASK, ALTER_SCHEMA, AUTONET, SHOW_TRIGGER, LTE, CREATE_TRIGGER, UFE, DROP_TRIGGER, UPSERT, SHOW_PROPERTY, DELETE, CREATE_FULLTEXT, SPREAD, DROP_FULLTEXT, INSERT, CREATE_INDEX, DROP_INDEX, CLEAR_TASK, SHOW_FULLTEXT, STOP_TASK, AB, PAUSE_TASK]}
Property privileges: PropertyPrivilege(node=PropertyPrivilegeElement(read=[], write=[], deny=[]), edge=PropertyPrivilegeElement(read=[], write=[], deny=[]))
Policies: [operator]
```

### createUser()

Creates a database user in the instance.

**Parameters:**

- `CreateUser`: The user to be created; the fields `username` and `password` must be set, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Creates a new user 'javaUser' and prints error code

CreateUser createUser = new CreateUser();
createUser.setUsername("javaUser");
createUser.setPassword("@#javaUser");
// System privileges
createUser.setSystemPrivileges(Lists.newArrayList(SystemPrivilege.SHOW_GRAPH, SystemPrivilege.TRUNCATE));
// Graph privileges
Map<String,List<GraphPrivilege>> graphPrivileges = new HashMap<>();
graphPrivileges.put("miniCircle", Lists.newArrayList(GraphPrivilege.FIND, GraphPrivilege.SPREAD, GraphPrivilege.AUTONET, GraphPrivilege.AB, GraphPrivilege.TEMPLATE, GraphPrivilege.KHOP));
graphPrivileges.put("lcc", Lists.newArrayList(GraphPrivilege.UPDATE, GraphPrivilege.INSERT, GraphPrivilege.DELETE, GraphPrivilege.UPSERT));
createUser.setGraphPrivileges(graphPrivileges);
// Property privileges
PropertyPrivilege propertyPrivilege = new PropertyPrivilege();
PropertyPrivilegeElement node = new PropertyPrivilegeElement();
PropertyPrivilegeValue nodeValue1 = new PropertyPrivilegeValue();
nodeValue1.setGraphName("miniCircle");
nodeValue1.setSchemaName("account");
PropertyPrivilegeValue nodeValue2 = new PropertyPrivilegeValue();
nodeValue2.setGraphName("miniCircle");
nodeValue2.setSchemaName("movie");
nodeValue2.setPropertyName("name");
PropertyPrivilegeValue nodeValue3 = new PropertyPrivilegeValue();
nodeValue3.setGraphName("lcc");
nodeValue3.setSchemaName("*");
nodeValue3.setPropertyName("*");
node.setRead(Lists.newArrayList(nodeValue1,nodeValue2));
node.setWrite(Lists.newArrayList(nodeValue3));
propertyPrivilege.setNode(node);
PropertyPrivilegeElement edge = new PropertyPrivilegeElement();
PropertyPrivilegeValue edgeValue1 = new PropertyPrivilegeValue();
edgeValue1.setGraphName("*");
PropertyPrivilegeValue edgeValue2 = new PropertyPrivilegeValue();
edgeValue2.setGraphName("miniCircle");
edgeValue2.setSchemaName("*");
edgeValue2.setPropertyName("*");
edge.setRead(Lists.newArrayList(edgeValue1));
edge.setWrite(Lists.newArrayList(edgeValue2));
propertyPrivilege.setEdge(edge);
createUser.setPropertyPrivileges(propertyPrivilege);
// Policies
createUser.setPolicies(Lists.newArrayList("manager"));

Response response = client.createUser(createUser);
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p>

```
SUCCESS
```

### alterUser()

Alters the password, system privileges, graph privileges, property privileges and policies of one existing database user in the instance by its username.

**Parameters:**

- `AlterUser`: The user to be altered; the fields `username` and `password` must be set, `systemPrivileges`, `graphPrivileges`, `propertyPrivilege` and `policies` are optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Alters the user 'javaUser' and prints error code

AlterUser alterUser = new AlterUser();
alterUser.setUsername("javaUser");
alterUser.setPassword("!!@#javaUser");
// System privileges
alterUser.setSystemPrivileges(Lists.newArrayList(SystemPrivilege.SHOW_GRAPH));
// Graph privileges
Map<String,List<GraphPrivilege>> graphPrivileges = new HashMap<>();
graphPrivileges.put("miniCircle", Lists.newArrayList(GraphPrivilege.FIND));
graphPrivileges.put("lcc", Lists.newArrayList(GraphPrivilege.UPDATE));
alterUser.setGraphPrivileges(graphPrivileges);
// Policies
alterUser.setPolicies(Lists.newArrayList("operator"));

Response response = client.alterUser(alterUser);
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropUser()

Drops one database user from the instance by its username.

**Parameters:**

- `String`: Username.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Drops the user 'javaUser' and prints error code

Response response = client.dropUser("javaUser");
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### grantPolicy()

Grants new system privileges, graph privileges, property privileges and policies to a database user in the instance.

**Parameters:**

- `String`: Username.
- `Map<String,List<GraphPrivilege>>`: Graph privileges to grant; sets to `null` to skip granting any graph privileges.
- `List<SystemPrivilege>`: System privileges to grant; sets to `null` to skip granting any system privileges.
- `PropertyPrivilege`: Property privileges to grant; sets to `null` to skip granting any property privileges.
- `List<String>`: Policies to grant; sets to `null` to skip granting any policies.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Graph privileges
Map<String,List<GraphPrivilege>> graphPrivileges = new HashMap<>();
graphPrivileges.put("miniCircle", Lists.newArrayList(GraphPrivilege.FIND,GraphPrivilege.SPREAD,GraphPrivilege.AUTONET,GraphPrivilege.AB,GraphPrivilege.TEMPLATE,GraphPrivilege.KHOP));
graphPrivileges.put("default", Lists.newArrayList(GraphPrivilege.UPDATE,GraphPrivilege.INSERT,GraphPrivilege.DELETE,GraphPrivilege.UPSERT));

// System privileges
List<SystemPrivilege> systemPrivileges = Lists.newArrayList(SystemPrivilege.SHOW_GRAPH,SystemPrivilege.TRUNCATE);

// Property privileges
PropertyPrivilege propertyPrivilege = new PropertyPrivilege();
PropertyPrivilegeElement node = new PropertyPrivilegeElement();
PropertyPrivilegeValue nodeValue1 = new PropertyPrivilegeValue();
nodeValue1.setGraphName("miniCircle");
nodeValue1.setSchemaName("account");
PropertyPrivilegeValue nodeValue2 = new PropertyPrivilegeValue();
nodeValue2.setGraphName("miniCircle");
nodeValue2.setSchemaName("movie");
nodeValue2.setPropertyName("name");
PropertyPrivilegeValue nodeValue3 = new PropertyPrivilegeValue();
nodeValue3.setGraphName("default");
nodeValue3.setSchemaName("*");
nodeValue3.setPropertyName("*");
node.setRead(Lists.newArrayList(nodeValue1, nodeValue2));
node.setWrite(Lists.newArrayList(nodeValue3));
propertyPrivilege.setNode(node);
PropertyPrivilegeElement edge = new PropertyPrivilegeElement();
PropertyPrivilegeValue edgeValue1 = new PropertyPrivilegeValue();
edgeValue1.setGraphName("*");
PropertyPrivilegeValue edgeValue2 = new PropertyPrivilegeValue();
edgeValue2.setGraphName("miniCircle");
edgeValue2.setSchemaName("*");
edgeValue2.setPropertyName("*");
edge.setRead(Lists.newArrayList(edgeValue1));
edge.setWrite(Lists.newArrayList(edgeValue2));
propertyPrivilege.setEdge(edge);

// Policies
List<String> policyList = Arrays.asList("operator", "manager");

Response response1 = client.grantPolicy("johndoe", graphPrivileges,null,null,null);
System.out.println(response1.getStatus().getErrorCode());

Response response2 = client.grantPolicy("Tester", null,systemPrivileges,propertyPrivilege,policyList);
System.out.println(response2.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
```

### revokePolicy()

Revokes system privileges, graph privileges, property privileges and policies from a database user in the instance.

**Parameters:**

- `String`: Username.
- `Map<String,List<GraphPrivilege>>`: Graph privileges to revoke; sets to `null` to skip revoking any graph privileges.
- `List<SystemPrivilege>`: System privileges to revoke; sets to `null` to skip revoking any system privileges.
- `PropertyPrivilege`: Property privileges to revoke; sets to `null` to skip revoking any property privileges.
- `List<String>`: Policies to revoke; sets to `null` to skip revoking any policies.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Graph privileges
Map<String,List<GraphPrivilege>> graphPrivileges = new HashMap<>();
graphPrivileges.put("miniCircle", Lists.newArrayList(GraphPrivilege.FIND,GraphPrivilege.SPREAD,GraphPrivilege.AUTONET,GraphPrivilege.AB,GraphPrivilege.TEMPLATE,GraphPrivilege.KHOP));
graphPrivileges.put("default", Lists.newArrayList(GraphPrivilege.UPDATE,GraphPrivilege.INSERT,GraphPrivilege.DELETE,GraphPrivilege.UPSERT));

// System privileges
List<SystemPrivilege> systemPrivileges = Lists.newArrayList(SystemPrivilege.SHOW_GRAPH,SystemPrivilege.TRUNCATE);

// Property privileges
PropertyPrivilege propertyPrivilege = new PropertyPrivilege();
PropertyPrivilegeElement node = new PropertyPrivilegeElement();
PropertyPrivilegeValue nodeValue1 = new PropertyPrivilegeValue();
nodeValue1.setGraphName("miniCircle");
nodeValue1.setSchemaName("account");
PropertyPrivilegeValue nodeValue2 = new PropertyPrivilegeValue();
nodeValue2.setGraphName("miniCircle");
nodeValue2.setSchemaName("movie");
nodeValue2.setPropertyName("name");
PropertyPrivilegeValue nodeValue3 = new PropertyPrivilegeValue();
nodeValue3.setGraphName("default");
nodeValue3.setSchemaName("*");
nodeValue3.setPropertyName("*");
node.setRead(Lists.newArrayList(nodeValue1, nodeValue2));
node.setWrite(Lists.newArrayList(nodeValue3));
propertyPrivilege.setNode(node);
PropertyPrivilegeElement edge = new PropertyPrivilegeElement();
PropertyPrivilegeValue edgeValue1 = new PropertyPrivilegeValue();
edgeValue1.setGraphName("*");
PropertyPrivilegeValue edgeValue2 = new PropertyPrivilegeValue();
edgeValue2.setGraphName("miniCircle");
edgeValue2.setSchemaName("*");
edgeValue2.setPropertyName("*");
edge.setRead(Lists.newArrayList(edgeValue1));
edge.setWrite(Lists.newArrayList(edgeValue2));
propertyPrivilege.setEdge(edge);

// Policies
List<String> policyList = Arrays.asList("operator", "manager");

Response response1 = client.revokePolicy("johndoe", graphPrivileges,null,null,null);
System.out.println(response1.getStatus().getErrorCode());

Response response2 = client.revokePolicy("Tester", null,systemPrivileges,propertyPrivilege,policyList);
System.out.println(response2.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
```

## Full Example

<p tit="Main.java" ></p> 

```js
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;
import com.ultipa.sdk.operate.entity.*;
import java.util.*;

public class Main {
    public static void main(String[] args) {
        // Connection configurations
        UltipaConfiguration myConfig = UltipaConfiguration.config()
            // URI example: .hosts("mqj4zouys.us-east-1.cloud.ultipa.com:60010")
            .hosts("192.168.1.85:60611,192.168.1.87:60611,192.168.1.88:60611")
            .username("<username>")
            .password("<password>");

        UltipaClientDriver driver = null;
        try {
            // Establishes connection to the database
            driver = new UltipaClientDriver(myConfig);
            Connection client = driver.getConnection();

            Thread.sleep(3000);
          
            // Request configurations
            RequestConfig requestConfig = new RequestConfig();
            requestConfig.setUseMaster(true);

            // Retrieves all policies and prints their information

            List<Policy> policyList = client.showPolicy(requestConfig);
            for (Policy policy : policyList) {
                System.out.println("Policy '" + policy.getName() + "' include:");
                System.out.println("- System privileges: " + policy.getSystemPrivileges());
                System.out.println("- Graph privileges: " + policy.getGraphPrivileges());
                System.out.println("- Property privileges: " + policy.getPropertyPrivileges());
                System.out.println("- Policies: " + policy.getPolicies());
            }                      
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
