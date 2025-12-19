# Schema and Property

This section introduces methods for managing schemas and properties in a graph.

# Schema

### showSchema()

Retrieves all schemas from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `list<Schema>`: The list of retrieved schemas.

```java
// Retrieves all schemas in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Schema> schemas = driver.showSchema(requestConfig);
for (Schema schema : schemas) {
    System.out.println(schema.getName() + ", " + schema.getDbType());
}
```

<p tit="Output"></p> 
 
```
default, DBNODE
account, DBNODE
celebrity, DBNODE
country, DBNODE
movie, DBNODE
default, DBEDGE
direct, DBEDGE
disagree, DBEDGE
filmedIn, DBEDGE
follow, DBEDGE
wishlist, DBEDGE
response, DBEDGE
review, DBEDGE
```

### showNodeSchema()

Retrieves all node schemas from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Schema>`: The list of retrieved schemas.

```java
// Retrieves all node schemas in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Schema> schemas = driver.showNodeSchema(requestConfig);
for (Schema schema : schemas) {
    System.out.println(schema.getName() + ", " + schema.getDbType());
}
```

<p tit="Output"></p> 
 
```
default, DBNODE
account, DBNODE
celebrity, DBNODE
country, DBNODE
movie, DBNODE
```

### showEdgeSchema()

Retrieves all edge schemas from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Schema>`: The list of retrieved schemas.

```java
// Retrieves all edge schemas in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Schema> schemas = driver.showEdgeSchema(requestConfig);
for (Schema schema : schemas) {
    System.out.println(schema.getName() + ", " + schema.getDbType());
}
```

<p tit="Output"></p> 
 
```
default, DBEDGE
direct, DBEDGE
disagree, DBEDGE
filmedIn, DBEDGE
follow, DBEDGE
wishlist, DBEDGE
response, DBEDGE
review, DBEDGE
```

### getSchema()

Retrieves a specified schema from the graph.

**Parameters**

- `schemaName: String`: Name of the schema.
- `dbType: DBtype`: Type of the schema (node or edge).
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Schema`: The retrieved schema.

```java
// Retrieves the node schema named 'account'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Schema schema = driver.getSchema("account", Ultipa.DBType.DBNODE, requestConfig);
System.out.println(schema.getTotal());
```

<p tit="Output"></p> 
 
```
111
```

### getNodeSchema()

etrieves a specified node schema from the graph.

**Parameters**

- `schemaName: String`: Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Schema`: The retrieved schema.

```java
// Retrieves the node schema named 'account'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Schema schema = driver.getNodeSchema("account", requestConfig);
if (schema != null) {
    List<Property> properties = schema.getProperties();
    if (properties != null) {
        for (Property property : properties) {
            System.out.println(property.getName());
        }
    }
} else {
    System.out.println("Not found");
}
```

<p tit="Output"></p> 
 
```
gender
year
industry
name
```

### getEdgeSchema()

Retrieves a specified edge schema from the graph.

**Parameters**

- `schemaName: String`: Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Schema`: The retrieved schema.

```java
// Retrieves the edge schema named 'disagree'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Schema schema = driver.getEdgeSchema("disagree", requestConfig);
if (schema != null) {
    List<Property> properties = schema.getProperties();
    if (properties != null) {
        for (Property property : properties) {
          System.out.println(property.getName());
        }
    }
} else {
  System.out.println("Not found");
}
```

<p tit="Output"></p> 
 
```
datetime
timestamp
targetPost
```

### createSchema()

Creates a schema in the graph.

**Parameters**

- `schema: Schema`: The schema to be created; the attributes `name` and `dbType` are mandatory, `properties` and `description` are optional.
- `isCreateProperties: boolean` (Optional): Whether to create properties associated with the schema, the default is `false`.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

// Creates node schema 'utility' (with properties)

Schema utility = new Schema();
utility.setName("utility");
utility.setDbType(Ultipa.DBType.DBNODE);
utility.setProperties(new ArrayList<Property>() {{
    add(new Property() {{
        setName("name");
        setType(Ultipa.PropertyType.STRING);
    }});
    add(new Property() {{
        setName("type");
        setType(Ultipa.PropertyType.UINT32);
    }});
}});

Response response1 = driver.createSchema(utility, true, requestConfig);
System.out.println(response1.getStatus().getCode());

Thread.sleep(3000);

// Creates edge schema 'vote' (without properties)

Schema vote = new Schema();
vote.setName("vote");
vote.setDbType(Ultipa.DBType.DBEDGE);

Response response2 = driver.createSchema(vote, false, requestConfig);
System.out.println(response2.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
```

### createSchemaIfNotExist()

Creates a schema in the graph and returns whether a node or edge schema with the same name already exists.

**Parameters**

- `schema: Schema`: The schema to be created; the attributes `name` and `dbType` are mandatory, `properties` and `description` are optional.
- `isCreateProperties: boolean` (Optional): Whether to create properties associated with the schema, the default is `false`.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `ResponseWithExistCheck`: Result of the request.

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Schema schema = new Schema();
schema.setName("utility");
schema.setDbType(Ultipa.DBType.DBNODE);
schema.setProperties(new ArrayList<Property>() {{
    add(new Property() {{
        setName("name");
        setType(Ultipa.PropertyType.STRING);
    }});
    add(new Property() {{
        setName("type");
        setType(Ultipa.PropertyType.UINT32);
    }});
}});

ResponseWithExistCheck result = driver.createSchemaIfNotExist(schema, true, requestConfig);

System.out.println("Does the schema already exist? " + result.getExist());
if(result.getResponse() == null) {
    System.out.println("Schema creation status: No response");
} else {
    System.out.println("Schema creation status: " + result.getResponse().getStatus().getCode());
}

System.out.println("----- Creates the schema again -----");

ResponseWithExistCheck result_1 = driver.createSchemaIfNotExist(schema, true, requestConfig);

System.out.println("Does the schema already exist? " + result_1.getExist());
if(result_1.getResponse() == null) {
    System.out.println("Schema creation status: No response");
} else {
    System.out.println("Schema creation status: " + result_1.getResponse().getStatus().getCode());
}
```

<p tit="Output"></p> 
 
```
Does the schema already exist? false
----- Creates the schema again -----
Does the schema already exist? true
Schema creation status: No response
```

### alterSchema()

Alters the name and description a schema in the graph.

**Parameters**

- `originalSchema: Schema`: The schema to be altered; the attributes `name` and `dbType` are mandatory. 
- `newSchema: Schema`: A `Schema` object used to set new `name` and/or `description` for the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Renames the node schema 'utility' to 'securityUtility' in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Schema oldSchema = new Schema();
oldSchema.setName("utility");
oldSchema.setDbType(Ultipa.DBType.DBNODE);
Schema newSchema = new Schema();
newSchema.setName("securityUtility");

Response response = driver.alterSchema(oldSchema, newSchema, requestConfig);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropSchema()

Deletes a specified schema from the graph.

**Parameters**

- `schema: Schema`: The schema to be dropped; the attributes `name` and `dbType` are mandatory. 
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

<p tit="Java" ></p> 
 
 ```js
// Drops the edge schema 'vote' from the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Schema schema = new Schema();
schema.setName("vote");
schema.setDbType(Ultipa.DBType.DBEDGE);

Response response = driver.dropSchema(schema, requestConfig);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Property

### showProperty()

Retrieves properties from the graph.

**Parameters**

- `dbType: DBType` (Optional): Type of the property (node or edge).
- `schemaName: String` (Optional): Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `AllProperties`: A class that groups two lists: `nodeProperties` and `edgeProperties`, both of which are lists of `Property` objects.

```java
// Retrieves all properties in the graph 'citation'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("citation");

AllProperties properties = driver.showProperty(requestConfig);

List<Property> nodeProperties = properties.getNodeProperties();
System.out.println("Node Properties:");
for (Property property : nodeProperties) {
    System.out.println(property.getName() + " is associated with schema " + property.getSchema());
}

List<Property> edgeProperties = properties.getEdgeProperties();
System.out.println("Edge Properties:");
for (Property property : edgeProperties) {
    System.out.println(property.getName() + " is associated with schema " + property.getSchema());
}
```

<p tit="Output"></p> 
 
```
Node Properties:
_id is associated with schema default
_id is associated with schema Paper
title is associated with schema Paper
score is associated with schema Paper
author is associated with schema Paper
Edge Properties:
weight is associated with schema Cites
```

### showNodeProperty()

Retrieves node properties from the graph.

**Parameters**

- `schemaName: String` (Optional): Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Property>`: The list of retrieved properties.

```java
// Retrieves properties associated with the node schema 'Paper' in the graph 'citation'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("citation");

List<Property> properties = driver.showNodeProperty("Paper", requestConfig);
for (Property property : properties) {
    System.out.println(property.getName() + " - " + property.getType());
}
```

<p tit="Output"></p> 
 
```
_id - STRING
title - STRING
score - INT32
author - STRING
```

### showEdgeProperty()

Retrieves edge properties from the graph.

**Parameters**

- `schemaName: String` (Optional): Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Property>`: The list of retrieved properties.

```java
// Retrieves properties associated with the edge schema 'Cites' in the graph 'citation'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("citation");

List<Property> properties = driver.showEdgeProperty("Cites", requestConfig);
for (Property property : properties) {
    System.out.println(property.getName() + " - " + property.getType());
}
```

<p tit="Output"></p> 
 
```
weight - INT32
```

### getProperty()

Retrieves a specified property from the graph.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `schemaName: String`: Name of the schema.
- `propertyName: String`: Name of the property.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Property`: The retrieved property.

```java
// Retrieves node property 'title' associated with the node schema 'Paper' in the graph 'citation'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("citation");

Property property = driver.getProperty(Ultipa.DBType.DBNODE, "Paper", "title", requestConfig);
System.out.println(property);
```

<p tit="Output"></p> 
 
```
Property(name=title, type=STRING, subType=null, typeString=string, lte=false, read=true, write=true, schema=Paper, description=, ignored=false, extra=null, encrypt=, encrypted=false)
```

### getNodeProperty()

Retrieves a specified node property from the graph.

**Parameters**

- `schemaName: String`: Name of the schema.
- `propertyName: String`: Name of the property.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Property`: The retrieved property.

```java
// Retrieves node property 'title' associated with the node schema 'Paper' in the graph 'citation'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("citation");

Property property = driver.getNodeProperty("Paper", "title", requestConfig);
System.out.println(property);
```

<p tit="Output"></p> 
 
```
Property(name=title, type=STRING, subType=null, typeString=string, lte=false, read=true, write=true, schema=Paper, description=, ignored=false, extra=null, encrypt=, encrypted=false)
```

### getEdgeProperty()

Retrieves a specified edge property from the graph.

**Parameters**

- `schemaName: String`: Name of the schema.
- `propertyName: String`: Name of the property.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Property`: The retrieved property.

```java
// Retrieves edge property 'weight' associated with the edge schema 'Cites' in the graph 'citation'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("citation");

Property property = driver.getEdgeProperty("Cites", "weight", requestConfig);
System.out.println(property);
```

<p tit="Output"></p> 
 
```
Property(name=weight, type=INT32, subType=null, typeString=int32, lte=false, read=true, write=true, schema=Cites, description=, ignored=false, extra=null, encrypt=, encrypted=false)
```

### createProperty()

Creates a property in the graph.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `property: Property`: The property to be created; the attributes `name`, `type` (and `subType` if the `type` is `SET` or `LIST`), and `schema` (sets to `*` to specify all schemas) are mandatory, `encrypt` and `description` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Creates a property 'year' for all node schemas, creates a property 'tags' for the node schema 'Paper'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("citation");

Property property1 = new Property();
property1.setName("year");
property1.setType(Ultipa.PropertyType.UINT32);
property1.setEncrypt("AES128");
property1.setSchema("*");

Property property2 = new Property();
property2.setName("tags");
property2.setType(Ultipa.PropertyType.STRING);
property2.setEncrypt("AES128");
property2.setSchema("*");

Response response1 = driver.createProperty(Ultipa.DBType.DBNODE, property1, requestConfig);
System.out.println(response1.getStatus().getCode());

Response response2 = driver.createProperty(Ultipa.DBType.DBNODE, property2, requestConfig);
System.out.println(response2.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
```

### createPropertyIfNotExist()

Creates a property in the graph and returns whether a node or edge property with the same name already exists for the specified schema.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `property: Property`: The property to be created; the attributes `name`, `type` (and `subType` if the `type` is `SET` or `LIST`), and `schema` (sets to `*` to specify all schemas) are mandatory, `encrypt` and `description` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `ResponseWithExistCheck`: Result of the request.

```java
RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("citation");

Property property = new Property();
property.setName("tags");
property.setType(Ultipa.PropertyType.SET);
property.setSubType(Lists.newArrayList(Ultipa.PropertyType.STRING));
property.setEncrypt("AES128");
property.setSchema("Paper");

ResponseWithExistCheck result = driver.createPropertyIfNotExist(Ultipa.DBType.DBNODE, property, requestConfig);

System.out.println("Does the property already exist? " + result.getExist());
if(result.getResponse() == null) {
    System.out.println("Property creation status: No response");
} else {
    System.out.println("Property creation status: " + result.getResponse().getStatus().getCode());
}

System.out.println("----- Creates the property again -----");

ResponseWithExistCheck result_1 = driver.createPropertyIfNotExist(Ultipa.DBType.DBNODE, property, requestConfig);

System.out.println("Does the property already exist? " + result_1.getExist());
if(result_1.getResponse() == null) {
    System.out.println("Property creation status: No response");
} else {
    System.out.println("Property creation status: " + result_1.getResponse().getStatus().getCode());
}
```

<p tit="Output"></p> 
 
```
Does the property already exist? false
Property creation status: SUCCESS
----- Creates the property again -----
Does the property already exist? true
Property creation status: No response
```

### alterProperty()

Alters the name and description a property in the graph.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `originProp: Property`: The property to be altered; the attributes `name` and `schema` (writes `*` to specify all schemas) are mandatory.
- `newProp: Property`: A `Property` object used to set new `name` and/or `description` for the `property`.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Renames the property 'tags' of the node schema 'Paper' to 'keywords' in the graph 'citation'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("citation");

Property oldProperty = new Property();
oldProperty.setName("tags");
oldProperty.setSchema("Paper");

Property newProperty = new Property();
newProperty.setName("keywords");

Response response = driver.alterProperty(Ultipa.DBType.DBNODE, oldProperty, newProperty, requestConfig);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropProperty()

Deletes specified properties from the graph.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `property: Property`: The property to be droppped; the attributes `name` and `schema` (writes `*` to specify all schemas) are mandatory.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Drops the property 'tags' of the node schema in the graph 'citation'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("citation");

Property property = new Property();
property.setName("tags");
property.setSchema("Paper");

Response response = driver.dropProperty(Ultipa.DBType.DBNODE, property, requestConfig);
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

import com.ultipa.Ultipa;
import com.ultipa.sdk.UltipaDriver;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfig;
import com.ultipa.sdk.operate.entity.*;
import com.ultipa.sdk.operate.response.Response;
import org.assertj.core.util.Lists;

import java.util.ArrayList;
import java.util.List;

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

            // Creates schemas and properties in the graph 'social'

            RequestConfig requestConfig = new RequestConfig();
            requestConfig.setGraph("social");

            Schema user = new Schema();
            user.setName("user");
            user.setDbType(Ultipa.DBType.DBNODE);
            user.setProperties(new ArrayList<Property>() {{
                add(new Property() {{
                    setName("name");
                    setType(Ultipa.PropertyType.STRING);
                }});
                add(new Property() {{
                    setName("age");
                    setType(Ultipa.PropertyType.INT32);
                }});
                add(new Property() {{
                    setName("score");
                    setType(Ultipa.PropertyType.DECIMAL);
                    setDecimalExtra(25, 10);
                }});
                add(new Property() {{
                    setName("birthday");
                    setType(Ultipa.PropertyType.DATE);
                }});
                add(new Property() {{
                    setName("active");
                    setType(Ultipa.PropertyType.BOOL);
                }});
                add(new Property() {{
                    setName("location");
                    setType(Ultipa.PropertyType.POINT);
                }});
                add(new Property() {{
                    setName("interests");
                    setType(Ultipa.PropertyType.LIST);
                    setSubType(Lists.newArrayList(Ultipa.PropertyType.STRING));
                }});
                add(new Property() {{
                    setName("permissionCodes");
                    setType(Ultipa.PropertyType.SET);
                    setSubType(Lists.newArrayList(Ultipa.PropertyType.INT32));
                }});
            }});

            Schema product = new Schema();
            product.setName("product");
            product.setDbType(Ultipa.DBType.DBNODE);
            product.setProperties(new ArrayList<Property>() {{
                add(new Property() {{
                    setName("name");
                    setType(Ultipa.PropertyType.STRING);
                }});
                add(new Property() {{
                    setName("price");
                    setType(Ultipa.PropertyType.FLOAT);
                }});
            }});

            Schema follows = new Schema();
            follows.setName("follows");
            follows.setDbType(Ultipa.DBType.DBEDGE);
            follows.setProperties(new ArrayList<Property>() {{
                add(new Property() {{
                    setName("createdOn");
                    setType(Ultipa.PropertyType.TIMESTAMP);
                }});
                add(new Property() {{
                    setName("weight");
                    setType(Ultipa.PropertyType.FLOAT);
                }});
            }});

            Schema purchased = new Schema();
            purchased.setName("purchased");
            purchased.setDbType(Ultipa.DBType.DBEDGE);

            List<Schema> schemas = Lists.newArrayList(user, product, follows, purchased);

            for (Schema schema : schemas) {
                Response response = driver.createSchema(schema, true, requestConfig);
                System.out.println(response.getStatus().getCode());
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
