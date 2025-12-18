# Schema and Property Management

This section introduces methods on a `Connection` object for managing schemas and properties of nodes and edges in a graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Schema

### showSchema()

Retrieves all nodes and edge schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `ResponseListSchema`: The list of all schemas in the current graphset.

```python
# Retrieves all schemas in graphset 'UltipaTeam' and prints their names and types

requestConfig = RequestConfig(graphName="UltipaTeam")

schemas = Conn.showSchema(requestConfig)
for schema in schemas:
    print(f"{schema.name}, type: {schema.DBType}")
```

<p tit="Output"></p>

```
default, type: 0
member, type: 0
organization, type: 0
default, type: 1
reportsTo, type: 1
relatesTo, type: 1
```

### getSchema()

Retrieves a node or edge schema from the current graphset.

**Parameters:**

- `str`: Name of the schema.
- `DBtype`: Type of the schema (node or edge).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved schema.

```python
# Retrieves node schema 'organization' and edge schema 'connectsTo' in graphset 'UltipaTeam', and prints all their information

requestConfig = RequestConfig(graphName="UltipaTeam")

schema1 = Conn.getSchema("organization", DBType.DBNODE, requestConfig)
if schema1:
    print(schema1.toJSON())
else:
    print("Not found")

schema2 = Conn.getSchema("connectsTo", DBType.DBEDGE, requestConfig)
if schema2:
  print(schema2.toJSON())
else:
    print("Not found")
```

<p tit="Output"></p>

```
{"DBType": 0, "description": "", "name": "organization", "properties": [{"description": "", "lte": true, "name": "name", "schema": null, "subTypes": null, "type": "string"}, {"description": "", "lte": false, "name": "logo", "schema": null, "subTypes": null, "type": "string"}], "total": "19", "type": "node"}
Not found
```

### showNodeSchema()

Retrieves all node schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Schema]`: The list of all node schemas in the current graphset.

```python
# Retrieves all node schemas in graphset 'UltipaTeam' and prints their names

requestConfig = RequestConfig(graphName="UltipaTeam")

schemas = Conn.showNodeSchema(requestConfig)
for schema in schemas:
    print(schema.name)
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

- `List[Schema]`: The list of all edge schemas in the current graphset.

```python
# Retrieves all edge schemas in graphset 'UltipaTeam' and prints their names

requestConfig = RequestConfig(graphName="UltipaTeam")

schemas = Conn.showEdgeSchema(requestConfig)
for schema in schemas:
    print(schema.name)
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

- `str`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved node schema.

```python
# Retrieves node schema 'member' in graphset 'UltipaTeam' and prints its property names

requestConfig = RequestConfig(graphName="UltipaTeam")

schema = Conn.getNodeSchema("member", requestConfig)
for property in schema.properties:
    print(property.name)
```

<p tit="Output"></p>

```
title
profile
age
```

### getEdgeSchema()

Retrieves an edge schema from the current graphset.

**Parameters:**

- `String`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved edge schema.

```python
# Retrieves edge schema 'relatesTo' in graphset 'UltipaTeam' and prints its property names

requestConfig = RequestConfig(graphName="UltipaTeam")

schema = Conn.getEdgeSchema("relatesTo", requestConfig)
for property in schema.properties:
    print(property.name)
```

<p tit="Output"></p>

```
type
```

### createSchema()

Creates a new schema in the current graphset.

**Parameters:**

- `Schema`: The schema to be created; the fields `name` and `dbType` must be set, `description` and `properties` are optional.
- `bool` (Optional): Whether to create properties, the default is `False`.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

```python
requestConfig = RequestConfig(graphName="UltipaTeam")

# Creates node schema 'utility' (with properties) in graphset 'UltipaTeam' and prints all its information

utility = Schema(
    name="utility",
    description="Office utilities",
    dbType=DBType.DBNODE,
    properties=[
        Property(name="name", type=PropertyTypeStr.PROPERTY_STRING),
        Property(name="purchaseDate", type=PropertyTypeStr.PROPERTY_DATETIME)
    ]
)

response1 = Conn.createSchema(utility, True, requestConfig)
print(response1.status.code)

time.sleep(3)

schema1 = Conn.getNodeSchema("utility", requestConfig)
print(schema1.toJSON())

# Creates edge schema 'managedBy' (without properties) in graphset 'UltipaTeam' and prints all its information

managedBy = Schema(
    name="managedBy",
    dbType=DBType.DBEDGE
)

response2 = Conn.createSchema(managedBy, False, requestConfig)
print(response2.status.code)

time.sleep(3)

schema2 = Conn.getEdgeSchema("managedBy", requestConfig)
print(schema2.toJSON())
```

<p tit="Output"></p>

```
0
{"DBType": 0, "description": "Office utilities", "name": "utility", "properties": [{"description": "", "lte": false, "name": "name", "schema": null, "subTypes": null, "type": "string"}, {"description": "", "lte": false, "name": "purchaseDate", "schema": null, "subTypes": null, "type": "datetime"}], "total": "0", "type": "node"}
0
{"DBType": 1, "description": "", "name": "managedBy", "properties": [], "total": "0", "type": "edge"}
```

### createSchemaIfNotExist()

Creates a new schema in the current graphset, handling cases where the given schema name already exists by ignoring the error.

**Parameters:**

- `Schema`: The schema to be created; the fields `name` and `dbType` must be set, `description` and `properties` are optional.
- `bool` (Optional): Whether to create properties, the default is `False`.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `bool`: Whether the schema already exists.
- `UltipaResponse`: Result of the request.

```python
requestConfig = RequestConfig(graphName="UltipaTeam")

utility = Schema(
    name="utility",
    description="Office utilities",
    dbType=DBType.DBNODE
)

# Creates one schema in graphset 'UltipaTeam' and prints if the creation happens

response1 = Conn.createSchemaIfNotExist(schema=utility, requestConfig=requestConfig)
if response1[0] is False:
    print("Code =", response1[1].status.code)
else:
    print("No response")

# Creates the same schema again and prints if the creation happens

time.sleep(3)

response2 = Conn.createSchemaIfNotExist(utility, requestConfig)
if response2[0] is False:
    print("Code =", response1[1].status.code)
else:
    print("No response")
```

<p tit="Output"></p>

```
Code = 0
No response
```

### alterSchema()

Alters the name and description of one existing schema in the current graphset by its name.

**Parameters:**

- `Schema`: The existing schema to be altered; the fields `name` and `dbType` must be set. 
- `Schema`: The new configuration for the existing schema; the field `dbType` must be set, and either or both of the fields `name` and `description` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

```python
# Renames the node schema 'utility' to 'securityUtility' and removes its description in graphset 'UltipaTeam'

requestConfig = RequestConfig(graphName="UltipaTeam")

schema = Conn.getNodeSchema("utility", requestConfig)
newSchema = Schema(name="securityUtility", description="yyyy", dbType=DBType.DBNODE)
response = Conn.alterSchema(schema, newSchema, requestConfig)
print(response.status.code)
```

<p tit="Output"></p>

```
0
```

### dropSchema()

Drops one schema from the current graphset by its name.

**Parameters:**

- `Schema`: The existing schema to be dropped; the fields `name` and `dbType` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

```python
# Drops the node schema 'utility' in graphset 'UltipaTeam'

requestConfig = RequestConfig(graphName="UltipaTeam")

schema = Conn.getNodeSchema("utility", requestConfig)
response = Conn.dropSchema(schema, requestConfig)
print(response.status.code)
```

<p tit="Output"></p>

```
0
```

## Property

### showProperty()

Retrieves custom properties of nodes or edges from the current graphset.

**Parameters:**

- `dbType`: Type of the property (node or edge).
- `str` (Optional): Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Property]`: The list of all properties retrieved in the current graphset.

```python
# Retrieves all custom node properties in graphset 'UltipaTeam' and prints their names, types and associated schemas

requestConfig = RequestConfig(graphName="UltipaTeam")

properties = Conn.showProperty(dbType=DBType.DBNODE,requestConfig=requestConfig)
for property in properties:
    print(f"{property.name} ({property.type}) is associated with schema named {property.schema}")
```

<p tit="Output"></p>

```
name (string) is associated with schema named member
title (string) is associated with schema named member
profile (string) is associated with schema named member
name (string) is associated with schema named organization
logo (string) is associated with schema named organization
```

### showNodeProperty()

Retrieves custom properties of nodes from the current graphset.

**Parameters:**

- `str` (Optional): Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Property]`: The list of all properties retrieved in the current graphset.

```python
# Retrieves all custom properties of node schema 'member' in graphset 'UltipaTeam' and prints the count

requestConfig = RequestConfig(graphName="UltipaTeam")

properties = Conn.showNodeProperty("member", requestConfig)
print(len(properties))
```

<p tit="Output"></p>

```
3
```

### showEdgeProperty()

Retrieves custom properties of edges from the current graphset.

**Parameters:**

- `str` (Optional): Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List[Property]`: The list of all properties retrieved in the current graphset.

```python
# Retrieves all custom properties of edge schema 'relatesTo' in graphset 'UltipaTeam' and prints their names

requestConfig = RequestConfig(graphName="UltipaTeam")

properties = Conn.showEdgeProperty("relatesTo", requestConfig)
for property in properties:
    print(property.name)
```

<p tit="Output"></p>

```
type
```

### getProperty()

Retrieves a custom property of nodes or edges from the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `str`: Name of the property.
- `str`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

```python
# Retrieves node property @member.title in graphset 'UltipaTeam' and prints all its information

requestConfig = RequestConfig(graphName="UltipaTeam")

property = Conn.getProperty(DBType.DBNODE, "title", "member", requestConfig)
print(property.toJSON())
```

<p tit="Output"></p>

```
{"description": "", "encrypt": "", "encrypted": false, "extra": "{}", "ignored": false, "lte": false, "name": "title", "propertyType": "", "read": true, "schema": "member", "subTypes": null, "type": "string", "write": true}
```

### getNodeProperty()

Retrieves a custom property of nodes from the current graphset.

**Parameters:**

- `str`: Name of the property.
- `str`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

```python
# Retrieves node property @member.title in graphset 'UltipaTeam' and prints all its information

requestConfig = RequestConfig(graphName="UltipaTeam")

property = Conn.getNodeProperty("title", "member", requestConfig)
print(property.toJSON())
```

<p tit="Output"></p>

```
{"description": "", "encrypt": "", "encrypted": false, "extra": "{}", "ignored": false, "lte": false, "name": "title", "propertyType": "", "read": true, "schema": "member", "subTypes": null, "type": "string", "write": true}
```

### getEdgeProperty()

Retrieves a custom property of edges from the current graphset.

**Parameters:**

- `str`: Name of the property.
- `str`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

```python
# Retrieves edge property @relatesTo.type in graphset 'UltipaTeam' and prints all its information

requestConfig = RequestConfig(graphName="UltipaTeam")

property = Conn.getEdgeProperty("type", "relatesTo", requestConfig)
print(property.toJSON())
```

<p tit="Output"></p>

```
{"description": "", "encrypt": "", "encrypted": false, "extra": "{}", "ignored": false, "lte": false, "name": "type", "propertyType": "", "read": true, "schema": "relatesTo", "subTypes": null, "type": "string", "write": true}
```

### createProperty()

Creates a new property for a node or edge schema in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `str`: Name of the schema, write `*` to specify all schemas.
- `Property`: The property to be created; the fields `name` and `type` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

```python
# Creates two properties for node schema 'member' in graphset 'UltipaTeam' and prints error codes

requestConfig = RequestConfig(graphName="UltipaTeam")

property1 = Property(
    name="startDate",
    type="datetime"
)

property2 = Property(
    name="age",
    type="int32"
)

response1 = Conn.createProperty(DBType.DBNODE, "member", property1, requestConfig)
print(response1.status.code)

response2 = Conn.createProperty(DBType.DBNODE, "member", property2, requestConfig)
print(response2.status.code)
```

<p tit="Output"></p>

```
0
0
```

### createPropertyIfNotExist()

Creates a new property for a node or edge schema in the current graphset, handling cases where the given property name already exists by ignoring the error.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `str`: Name of the schema, write `*` to specify all schemas.
- `Property`: The property to be created; the fields `name` and `type` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `boolean`: Whether the property already exists.
- `UltipaResponse`: Result of the request.

```python
requestConfig = RequestConfig(graphName="UltipaTeam")

prop = Property(
    name="startDate",
    type="datetime"
)

# Creates a property for node schema 'member' in graphset 'UltipaTeam' and prints if the creation happens

response1 = Conn.createPropertyIfNotExist(DBType.DBNODE, "member", prop, requestConfig)
if response1[0] is False:
    print("Code =", response1[1].status.code)
else:
    print("No response")

# Creates the same property again in graphset 'UltipaTeam' and prints if the creation happens

time.sleep(3)

response2 = Conn.createPropertyIfNotExist(DBType.DBNODE, "member", prop, requestConfig)
if response2[0] is False:
    print("Code =", response2[1].status.code)
else:
    print("No response")
```

<p tit="Output"></p>

```
Code = 0
No response
```

### alterProperty()

Alters the name and description of one existing custom property in the current graphset by its name.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `Property`: The existing property to be altered; the fields `name` and `schema` (write `*` to specify all schemas) must be set. 
- `Property`: The new configuration for the existing property; either or both of the fields `name` and `description` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UltipaResponse`: Result of the request.

```python
requestConfig = RequestConfig(graphName="UltipaTeam")

# Rename properties 'name' associated with all node schemas to `Name` in graphset 'UltipaTeam'

oldProperty = Property(
    name="name",
    schema="*"
)

newProperty = Property(
    name="Name"
)

response = Conn.alterProperty(DBType.DBNODE, oldProperty, newProperty, requestConfig)
print(response.status.code)
```

<p tit="Output"></p>

```
0
```

### dropProperty()

Drops one custom property from the current graphset by its name and the associated schema.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `str`: Name of the schema; write `*` to specify all schemas. 
- `str`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

```python
requestConfig = RequestConfig(graphName="UltipaTeam")

# Drops properties 'startDate' associated with all node schemas in graphset 'UltipaTeam' and prints error code

response1 = Conn.dropProperty(DBType.DBNODE, "*", "startDate", requestConfig)
print(response1.status.code)

# Drops node property @member.name in graphset 'UltipaTeam' and prints error code

response2 = Conn.dropProperty(DBType.DBNODE, "member", "name", requestConfig)
print(response2.status.code)
```

<p tit="Output"></p> 

```
0
0
```

## Full Example

<p tit="Example.py" ></p> 

```python
from ultipa.configuration.RequestConfig import RequestConfig
from ultipa import Connection, UltipaConfig, Schema, DBType
from ultipa.structs import Property

ultipaConfig = UltipaConfig()
# URI example: ultipaConfig.hosts = ["mqj4zouys.us-east-1.cloud.ultipa.com:60010"]
ultipaConfig.hosts = ["192.168.1.85:60061", "192.168.1.87:60061", "192.168.1.88:60061"]
ultipaConfig.username = "<username>"
ultipaConfig.password = "<password>"

Conn = Connection.NewConnection(defaultConfig=ultipaConfig)
          
# Request configurations
requestConfig = RequestConfig(graphName="UltipaTeam")

# Creates node schema 'utility' (with properties) in graphset 'UltipaTeam' and prints error code

utility = Schema(
    name="utility",
    description="Office utilities",
    dbType=DBType.DBNODE,
    properties=[
        Property(name="name", type="string"),
        Property(name="purchaseDate", type="datetime")
    ]
)

response = Conn.createSchema(utility, True, requestConfig)
print(response.status.code)
```
