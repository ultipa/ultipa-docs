# Schema and Property Management

This section introduces methods on a `Connection` object for managing schemas and properties of nodes and edges in a graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Schema

### showSchema()

Retrieves all nodes and edge schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Schema>`: The list of all schemas in the current graphset.

```java
// Retrieves all schemas in graphset 'UltipaTeam' and prints their types and names

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

List<Schema> schemas = client.showSchema(requestConfig);
Assert.assertTrue(schemas.size() > 0);
for (Schema schema : schemas) {
    System.out.println(schema.getDbType() + ": " + schema.getName());
}
```

<p tit="Output"></p> 
 
```
DBNODE: default
DBNODE: member
DBNODE: organization
DBEDGE: default
DBEDGE: reportsTo
DBEDGE: relatesTo
```

### getSchema()

Retrieves a node or edge schema from the current graphset.

**Parameters:**

- `String`: Name of the schema.
- `DBtype`: Type of the schema (node or edge).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved schema.

```java
// Retrieves node schema 'member' and edge schema 'connectsTo' in graphset 'UltipaTeam', and prints all their information

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Schema schema1 = client.getSchema("member", Ultipa.DBType.DBNODE, requestConfig);
System.out.println("schema1: " + new Gson().toJson(schema1));

Schema schema2 = client.getSchema("connectsTo", Ultipa.DBType.DBEDGE, requestConfig);
System.out.println("schema2: " + new Gson().toJson(schema2));
```

<p tit="Output"></p> 
 
```
schema1: {"name":"member","description":"","properties":[{"name":"name","propertyType":"STRING","type":"string","lte":false,"description":"","ignored":false,"extra":"{}"},{"name":"title","propertyType":"STRING","type":"string","lte":false,"description":"","ignored":false,"extra":"{}"},{"name":"profile","propertyType":"STRING","type":"string","lte":false,"description":"","ignored":false,"extra":"{}"}],"dbType":"DBNODE","total":7}
schema2: null
```

### showNodeSchema()

Retrieves all node schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Schema>`: The list of all node schemas in the current graphset.

```java
// Retrieves all node schemas in graphset 'UltipaTeam' and prints their names

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

List<Schema> schemas = client.showNodeSchema(requestConfig);
Assert.assertTrue(schemas.size() > 0);
for (Schema schema : schemas) {
    System.out.println(schema.getName());
}
```

<p tit="Output"></p> 
 
```
default
member
organization
```

### showEdgeSchema()

Retrieves all edge schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Schema>`: The list of all edge schemas in the current graphset.

```java
// Retrieves all edge schemas in graphset 'UltipaTeam' and prints their names

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

List<Schema> schemas = client.showEdgeSchema(requestConfig);
Assert.assertTrue(schemas.size() > 0);
for (Schema schema : schemas) {
    System.out.println(schema.getName());
}
```

<p tit="Output"></p> 
 
```
default
reportsTo
relatesTo
```

### getNodeSchema()

Retrieves a node schema from the current graphset.

**Parameters:**

- `String`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved node schema.

```java
// Retrieves node schema 'member' in graphset 'UltipaTeam' and prints its properties

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Schema schema = client.getNodeSchema("member", requestConfig);
System.out.println(schema.getProperties());
```

<p tit="Output"></p> 
 
```
[Property(name=name, propertyType=STRING, subPropertyTypes=null, type=string, lte=false, read=null, write=null, schema=null, description=, ignored=false, extra={}, encrypt=null, encrypted=null), Property(name=title, propertyType=STRING, subPropertyTypes=null, type=string, lte=false, read=null, write=null, schema=null, description=, ignored=false, extra={}, encrypt=null, encrypted=null), Property(name=profile, propertyType=STRING, subPropertyTypes=null, type=string, lte=false, read=null, write=null, schema=null, description=, ignored=false, extra={}, encrypt=null, encrypted=null)]
```

### getEdgeSchema()

Retrieves an edge schema from the current graphset.

**Parameters:**

- `String`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved edge schema.

```java
// Retrieves edge schema 'relatesTo' in graphset 'UltipaTeam' and prints its properties

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Schema schema = client.getEdgeSchema("relatesTo", requestConfig);
System.out.println(schema.getProperties());
```

<p tit="Output"></p> 
 
```
[Property(name=type, propertyType=STRING, subPropertyTypes=null, type=string, lte=false, read=null, write=null, schema=null, description=, ignored=false, extra={}, encrypt=null, encrypted=null)]
```

### createSchema()

Creates a new schema in the current graphset.

**Parameters:**

- `Schema`: The schema to be created; the fields `name` and `dbType` must be set, `description` and `properties` are optional.
- `boolean` (Optional): Whether to create properties, the default is `false`.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

// Creates node schema 'utility' (with properties) in graphset 'UltipaTeam' and prints all its information

Schema schema1 = new Schema();
schema1.setName("utility");
schema1.setDescription("Office utilities");
schema1.setDbType(Ultipa.DBType.DBNODE);

Property property1 = new Property();
property1.setName("name");
property1.setType("string");
Property property2 = new Property();
property2.setName("purchaseDate");
property2.setType("datetime");

ArrayList<Property> propertyArrayList = new ArrayList<>();
propertyArrayList.add(property1);
propertyArrayList.add(property2);

schema1.setProperties(propertyArrayList);

Response response1 = client.createSchema(schema1, true, requestConfig);
System.out.println(response1.getStatus().getErrorCode());

Thread.sleep(3000);
Schema newSchema1 = client.getNodeSchema("utility", requestConfig);
System.out.println(new Gson().toJson(newSchema1));

// Creates edge schema 'managedBy' (without properties) in graphset 'UltipaTeam' and prints all its information

Schema schema2 = new Schema();
schema2.setName("managedBy");
schema2.setDbType(Ultipa.DBType.DBEDGE);

Response response2 = client.createSchema(schema2, false, requestConfig);
System.out.println(response2.getStatus().getErrorCode());

Thread.sleep(3000);
Schema newSchema2 = client.getEdgeSchema("managedBy", requestConfig);
System.out.println(new Gson().toJson(newSchema2));
```

<p tit="Output"></p> 
 
```
SUCCESS
{"name":"utility","description":"Office utilities","properties":[{"name":"name","propertyType":"STRING","type":"string","lte":false,"description":"","ignored":false,"extra":"{}"},{"name":"purchaseDate","propertyType":"DATETIME","type":"datetime","lte":false,"description":"","ignored":false,"extra":"{}"}],"dbType":"DBNODE","total":0}
SUCCESS
{"name":"managedBy","description":"null,"properties":[],"dbType":"DBEDGE","total":0}
```

### createSchemaIfNotExist()

Creates a new schema in the current graphset, handling cases where the given schema name already exists by ignoring the error.

**Parameters:**

- `Schema`: The schema to be created; the fields `name` and `dbType` must be set, `description` and `properties` are optional.
- `boolean` (Optional): Whether to create properties, the default is `false`.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `boolean`: Whether the creation happens.

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Schema schema = new Schema();
schema.setName("utility");
schema.setDescription("Office utilities");
schema.setDbType(Ultipa.DBType.DBNODE);

// Creates one schema in graphset 'UltipaTeam' and prints if the creation happens

boolean flag1 = client.createSchemaIfNotExist(schema, requestConfig);
System.out.println(flag1);

// Creates the same schema again and prints if the creation happens

Thread.sleep(3000);

boolean flag2 = client.createSchemaIfNotExist(schema, requestConfig);
System.out.println(flag2);
```

<p tit="Output"></p> 
 
```
true
false
```

### alterSchema()

Alters the name and description of one existing schema in the current graphset by its name.

**Parameters:**

- `Schema`: The existing schema to be altered; the fields `name` and `DbType` must be set. 
- `Schema`: The new configuration for the existing schema; either or both of the fields `name` and `description` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Renames the node schema 'utility' to 'securityUtility' and removes its description in graphset 'UltipaTeam'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Schema schema = client.getSchema("utility", Ultipa.DBType.DBNODE, requestConfig);

Schema newSchema = new Schema();
newSchema.setName("securityUtility");
newSchema.setDescription("yyyy");

Response response = client.alterSchema(schema, newSchema, requestConfig);
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropSchema()

Drops one schema from the current graphset by its name.

**Parameters:**

- `Schema`: The existing schema to be dropped; the fields `name` and `dbType` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Drops the node schema 'utility' in graphset 'UltipaTeam'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Schema schema = client.getSchema("utility", Ultipa.DBType.DBNODE, requestConfig);
Response response = client.dropSchema(schema, requestConfig);
System.out.println(new Gson().toJson(response));
```

<p tit="Output"></p> 
 
```
{"host":"192.168.1.87:60611","statistic":{"rowAffected":0,"totalTimeCost":0,"engineTimeCost":0,"nodeAffected":0,"edgeAffected":0,"totalCost":1,"engineCost":0},"status":{"errorCode":"SUCCESS","msg":"","clusterInfo":{"redirect":"","leaderAddress":"","followers":[]}},"aliases":[],"items":{},"explainPlan":{"planNodes":[]}}
```

## Property

### showProperty()

Retrieves custom properties of nodes or edges from the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `String` (Optional): Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Property>`: The list of all properties retrieved in the current graphset.

```java
// Retrieves all custom node properties in graphset 'UltipaTeam' and prints their names, types and associated schemas

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

List<Property> propertyList = client.showProperty(Ultipa.DBType.DBNODE, requestConfig);
for (Property property : propertyList) {
    System.out.println(property.getName() + "(" + property.getType() + ")" + " is associated with schema named " + property.getSchema());
}
```

<p tit="Output"></p> 
 
```
name(string) is associated with schema named member
title(string) is associated with schema named member
profile(string) is associated with schema named member
name(string) is associated with schema named organization
logo(string) is associated with schema named organization
```

### showNodeProperty()

Retrieves custom properties of nodes from the current graphset.

**Parameters:**

- `String` (Optional): Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Property>`: The list of all properties retrieved in the current graphset.

```java
// Retrieves all custom properties of node schema 'member' in graphset 'UltipaTeam' and prints the count

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

List<Property> propertyList = client.showNodeProperty("member", requestConfig);
System.out.println(propertyList.size());
```

<p tit="Output"></p> 
 
```
3
```

### showEdgeProperty()

Retrieves custom properties of edges from the current graphset.

**Parameters:**

- `String` (Optional): Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Property>`: The list of all properties retrieved in the current graphset.

```java
// Retrieves all custom properties of edge schema 'relatesTo' in graphset 'UltipaTeam' and prints their names

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

List<Property> propertyList = client.showEdgeProperty("relatesTo", requestConfig);
for (Property property : propertyList) {
    System.out.println(property.getName());
}
```

<p tit="Output"></p> 
 
```
type
```

### getProperty()

Retrieves a custom property of nodes or edges from the current graphset.

**Parameters:**

- `String`: Name of the schema.
- `DBType`: Type of the property (node or edge).
- `String`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

```java
// Retrieves node property @member.title in graphset 'UltipaTeam' and prints all its information

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Property property = client.getProperty("member", Ultipa.DBType.DBNODE, "title", requestConfig);
System.out.println(new Gson().toJson(property));
```

<p tit="Output"></p> 
 
```
{"name":"title","propertyType":"STRING","type":"string","lte":false,"read":true,"write":true,"schema":"member","description":"","ignored":false,"extra":"{}","encrypt":"","encrypted":false}
```

### getNodeProperty()

Retrieves a custom property of nodes from the current graphset.

**Parameters:**

- `String`: Name of the schema.
- `String`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

```java
// Retrieves node property @member.title in graphset 'UltipaTeam' and prints all its information

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Property property = client.getNodeProperty("member", "title", requestConfig);
System.out.println(new Gson().toJson(property));
```

<p tit="Output"></p> 
 
```
{"name":"title","propertyType":"STRING","type":"string","lte":false,"read":true,"write":true,"schema":"member","description":"","ignored":false,"extra":"{}","encrypt":"","encrypted":false}
```

### getEdgeProperty()

Retrieves a custom property of edges from the current graphset.

**Parameters:**

- `String`: Name of the schema.
- `String`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

```java
// Retrieves edge property @relatesTo.type in graphset 'UltipaTeam' and prints all its information

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Property property = client.getEdgeProperty("relatesTo", "type", requestConfig);
System.out.println(new Gson().toJson(property));
```

<p tit="Output"></p> 
 
```
{"name":"type","propertyType":"STRING","type":"string","lte":false,"read":true,"write":true,"schema":"relatesTo","description":"","ignored":false,"extra":"{}","encrypt":"","encrypted":false}
```

### createProperty()

Creates a new property for a node or edge schema in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `String`: Name of the schema, write `*` to specify all schemas.
- `Property`: The property to be created; the fields `name` and `type` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
// Creates two properties for node schema 'member' in graphset 'UltipaTeam' and prints error codes

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

String schema = "member";

Property property1 = new Property();
property1.setName("startDate");
property1.setType("datetime");
Property property2 = new Property();
property2.setName("age");
property2.setType("int32");

Response response1 = client.createProperty(Ultipa.DBType.DBNODE, schema, property1, requestConfig);
System.out.println(response1.getStatus().getErrorCode());

Response response2 = client.createProperty(Ultipa.DBType.DBNODE, schema, property2, requestConfig);
System.out.println(response2.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
```

### createPropertyIfNotExist()

Creates a new property for a node or edge schema in the current graphset, handling cases where the given property name already exists by ignoring the error.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `String`: Name of the schema, write `*` to specify all schemas.
- `Property`: The property to be created; the fields `name` and `type` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `boolean`: Whether the creation happens.

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Property property = new Property();
property.setName("startDate");
property.setType("datetime");

// Creates a property for node schema 'member' in graphset 'UltipaTeam' and prints if the creation happens

boolean flag1 = client.createPropertyIfNotExist(Ultipa.DBType.DBNODE, "member", property, requestConfig);
System.out.println(flag1);

// Creates the same property again in graphset 'UltipaTeam' and prints if the creation happens

Thread.sleep(3000);

boolean flag2 = client.createPropertyIfNotExist(Ultipa.DBType.DBNODE, "member", property, requestConfig);
System.out.println(flag2);
```

<p tit="Output"></p> 
 
```
true
false
```

### alterProperty()

Alters the name and description of one existing custom property in the current graphset by its name.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `Property`: The existing property to be altered; the fields `name` and `schema` (write `*` to specify all schemas) must be set. 
- `Property`: The new configuration for the existing property; either or both of the fields `name` and `description` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

// Rename properties 'name' associated with all node schemas to `Name` in graphset 'UltipaTeam'

Property oldProperty = new Property();
oldProperty.setName("name");
oldProperty.setSchema("*");

Property newProperty = new Property();
newProperty.setName("Name");

Response response = client.alterProperty(Ultipa.DBType.DBNODE, oldProperty, newProperty, requestConfig);
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropProperty()

Drops one custom property from the current graphset by its name and the associated schema.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `String` (Optional): Name of the schema; all schemas are specified when it is ignored.
- `String`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

// Drops properties 'startDate' associated with all node schemas in graphset 'UltipaTeam' and prints error code

Response response1 = client.dropProperty(Ultipa.DBType.DBNODE, "startDate", requestConfig);
System.out.println(response1.getStatus().getErrorCode());

// Drops node property @member.name in graphset 'UltipaTeam' and prints error code

Response response2 = client.dropProperty(Ultipa.DBType.DBNODE, "member", "name", requestConfig);
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

import com.ultipa.Ultipa;
import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;
import com.ultipa.sdk.operate.entity.*;
import com.ultipa.sdk.operate.response.Response;
import java.util.ArrayList;

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
            requestConfig.setGraphName("UltipaTeam");
            
            // Creates node schema 'utility' (with properties) in graphset 'UltipaTeam' and prints error code

            Schema schema = new Schema();
            schema.setName("utility");
            schema.setDescription("Office utilities");
            schema.setDbType(Ultipa.DBType.DBNODE);

            Property property1 = new Property();
            property1.setName("name");
            property1.setType("string");
            Property property2 = new Property();
            property2.setName("purchaseDate");
            property2.setType("datetime");

            ArrayList<Property> propertyArrayList = new ArrayList<>();
            propertyArrayList.add(property1);
            propertyArrayList.add(property2);

            schema.setProperties(propertyArrayList);

            Response response = client.createSchema(schema, true, requestConfig);
            System.out.println(response.getStatus().getErrorCode());            
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
