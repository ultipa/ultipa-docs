# Schema and Property

This section introduces methods for managing schemas and properties in a graph.

# Schema

### showSchema()

Retrieves all schemas from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `list[Schema]`: The list of retrieved schemas.

```python
# Retrieves all schemas in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

schemas = Conn.showSchema(requestConfig)
for schema in schemas:
    print(f"{schema.name}, {schema.dbType.name}")
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

- `List[Schema]`: The list of retrieved schemas.

```python
# Retrieves all node schemas in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

schemas = Conn.showNodeSchema(requestConfig)
for schema in schemas:
    print(f"{schema.name}, {schema.dbType.name}")
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

- `List[Schema]`: The list of retrieved schemas.

```python
# Retrieves all edge schemas in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")

schemas = Conn.showEdgeSchema(requestConfig)
for schema in schemas:
    print(f"{schema.name}, {schema.dbType.name}")
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

- `schemaName: str`: Name of the schema.
- `dbType: DBtype`: Type of the schema (node or edge).
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Schema`: The retrieved schema.

```python
# Retrieves the node schema named 'account'

requestConfig = RequestConfig(graph="miniCircle")

schema = Conn.getSchema("account", DBType.DBNODE, requestConfig)
print(schema.total)
```

<p tit="Output"></p> 
 
```
111
```

### getNodeSchema()

Retrieves a specified node schema from the graph.

**Parameters**

- `schemaName: str`: Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Schema`: The retrieved schema.

```python
# Retrieves the node schema named 'account'

requestConfig = RequestConfig(graph="miniCircle")

schema = Conn.getNodeSchema("account", requestConfig)
if schema:
    for property in schema.properties:
        print(property.name)
else:
    print("Not found")
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

- `schemaName: str`: Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Schema`: The retrieved schema.

```python
# Retrieves the edge schema named 'disagree'

requestConfig = RequestConfig(graph="miniCircle")

schema = Conn.getEdgeSchema("disagree", requestConfig)
if schema:
    for property in schema.properties:
        print(property.name)
else:
    print("Not found")
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
- `isCreateProperties: bool` (Optional): Whether to create properties associated with the schema, the default is `False`.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
requestConfig = RequestConfig(graph="miniCircle")

# Creates node schema 'utility' (with properties)

utility = Schema(
    name="utility",
    dbType=DBType.DBNODE,
    properties=[
        Property(name="name", type=UltipaPropertyType.STRING),
        Property(name="type", type=UltipaPropertyType.UINT32)
    ]
)

response1 = Conn.createSchema(utility, True, requestConfig)
print(response1.status.code.name)

time.sleep(3)

# Creates edge schema 'vote' (without properties)

vote = Schema(
    name="vote",
    dbType=DBType.DBEDGE
)

response2 = Conn.createSchema(vote, False, requestConfig)
print(response2.status.code.name)
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
- `isCreateProperties: bool` (Optional): Whether to create properties associated with the schema, the default is `False`.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `ResponseWithExistCheck`: Result of the request.

```python
requestConfig = RequestConfig(graph="miniCircle")

schema = Schema(
    name="utility",
    dbType=DBType.DBNODE,
    properties=[
        Property(name="name", type=UltipaPropertyType.STRING),
        Property(name="type", type=UltipaPropertyType.UINT32)
    ]
)

result = Conn.createSchemaIfNotExist(schema, True, requestConfig)

print("Does the schema already exist?", result.exist)
if result.response.status is None:
    print("Schema creation status: No response")
else:
    print("Schema creation status:", result.response.status.code.name)

print("----- Creates the schema again -----")

result_1 = Conn.createSchemaIfNotExist(schema, True, requestConfig)

print("Does the schema already exist?", result_1.exist)
if result_1.response.status is None:
    print("Schema creation status: No response")
else:
    print("Schema creation status:", result_1.response.status.code.name)
```

<p tit="Output"></p> 
 
```
Does the schema already exist? False
----- Creates the schema again -----
Does the schema already exist? True
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

```python
# Renames the node schema 'utility' to 'securityUtility' in the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")
oldSchema = Schema(name="utility", dbType=DBType.DBNODE)
newSchema = Schema(name="securityUtility")
response = Conn.alterSchema(oldSchema, newSchema, requestConfig)
print(response.status.code.name)
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

```python
# Drops the edge schema 'vote' from the graph 'miniCircle'

requestConfig = RequestConfig(graph="miniCircle")
schema = Schema(name="vote", dbType=DBType.DBEDGE)
response = Conn.dropSchema(schema, requestConfig)
print(response.status.code.name)
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
- `schemaName: str` (Optional): Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Dict[str, List[Property]`: A dictionary where the key is `nodeProperties` or `edgeProperties`, and the value is the list of properties.

```python
# Retrieves all properties in the graph 'citation'

requestConfig = RequestConfig(graph="citation")

properties = Conn.showProperty(config=requestConfig)
nodeProperties = properties["nodeProperties"]
print("Node Properties:")
for nodeProperty in nodeProperties:
    print(f"{nodeProperty.name} is associated with schema {nodeProperty.schema}")

edgeProperties = properties["edgeProperties"]
print("Edge Properties:")
for edgeProperty in edgeProperties:
    print(f"{edgeProperty.name} is associated with schema {edgeProperty.schema}")
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

- `schemaName: str` (Optional): Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Property]`: The list of retrieved properties.

```python
# Retrieves properties associated with the node schema 'Paper' in the graph 'citation'

requestConfig = RequestConfig(graph="citation")

properties = Conn.showNodeProperty("Paper", requestConfig)
for property in properties:
    print(property.name, "-", property.type.name)
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

- `schemaName: str` (Optional): Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List[Property]`: The list of retrieved properties.

```python
# Retrieves properties associated with the edge schema 'Cites' in the graph 'citation'

requestConfig = RequestConfig(graph="citation")

properties = Conn.showEdgeProperty("Cites", requestConfig)
for property in properties:
    print(property.name, "-", property.type.name)
```

<p tit="Output"></p> 
 
```
weight - INT32
```

### getProperty()

Retrieves a specified property from the graph.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `propertyName: str`: Name of the property.
- `schemaName: str`: Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Property`: The retrieved property.

```python
# Retrieves node property 'title' associated with the node schema 'Paper' in the graph 'citation'

requestConfig = RequestConfig(graph="citation")

property = Conn.getProperty(DBType.DBNODE, "title", "Paper", requestConfig)
print(property.toJSON())
```

<p tit="Output"></p> 
 
```
{'type': <UltipaPropertyType.STRING: 7>, 'subType': None, 'description': '', 'name': 'title', 'lte': False, 'schema': 'Paper', 'encrypt': '', 'extra': None, 'read': None, 'write': None}
```

### getNodeProperty()

Retrieves a specified node property from the graph.

**Parameters**

- `propertyName: str`: Name of the property.
- `schemaName: str`: Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Property`: The retrieved property.

```python
# Retrieves node property 'title' associated with the node schema 'Paper' in the graph 'citation'

requestConfig = RequestConfig(graph="citation")

property = Conn.getNodeProperty("title", "Paper", requestConfig)
print(property.toJSON())
```

<p tit="Output"></p> 
 
```
{'type': <UltipaPropertyType.STRING: 7>, 'subType': None, 'description': '', 'name': 'title', 'lte': False, 'schema': 'Paper', 'encrypt': '', 'extra': None, 'read': None, 'write': None}
```

### getEdgeProperty()

Retrieves a specified edge property from the graph.

**Parameters**

- `propertyName: str`: Name of the property.
- `schemaName: str`: Name of the schema.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Property`: The retrieved property.

```python
# Retrieves edge property 'weight' associated with the edge schema 'Cites' in the graph 'citation'

requestConfig = RequestConfig(graph="citation")

property = Conn.getEdgeProperty("weight", "Cites", requestConfig)
print(property.toJSON())
```

<p tit="Output"></p> 
 
```
{'type': <UltipaPropertyType.INT32: 1>, 'subType': None, 'description': '', 'name': 'weight', 'lte': False, 'schema': 'Cites', 'encrypt': '', 'extra': None, 'read': None, 'write': None}
```

### createProperty()

Creates a property in the graph.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `property: Property`: The property to be created; the attributes `name`, `type` (and `subType` if the `type` is `SET` or `LIST`), and `schema` (sets to `*` to specify all schemas) are mandatory, `encrypt` and `description` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```python
# Creates a property 'year' for all node schemas, creates a property 'tags' for the node schema 'Paper'

requestConfig = RequestConfig(graph="citation")

property1 = Property(
    name="year",
    type=UltipaPropertyType.UINT32,
    encrypt="AES128",
    schema="*"
)

property2 = Property(
    name="tags",
    type=UltipaPropertyType.SET,
    subType=[UltipaPropertyType.STRING],
    schema="Paper"
)

response1 = Conn.createProperty(DBType.DBNODE, property1, requestConfig)
print(response1.status.code.name)

response2 = Conn.createProperty(DBType.DBNODE, property2, requestConfig)
print(response2.status.code.name)
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

```python
requestConfig = RequestConfig(graph="citation")

property = Property(
    name="tags",
    type=UltipaPropertyType.SET,
    subType=[UltipaPropertyType.STRING],
    encrypt="AES128",
    schema="Paper"
)

result = Conn.createPropertyIfNotExist(DBType.DBNODE, property, requestConfig)

print("Does the property already exist?", result.exist)
if result.response.status is None:
    print("Property creation status: No response")
else:
    print("Property creation status:", result.response.status.code.name)

print("----- Creates the property again -----")

result_1 = Conn.createPropertyIfNotExist(DBType.DBNODE, property, requestConfig)

print("Does the property already exist?", result_1.exist)
if result_1.response.status is None:
    print("Property creation status: No response")
else:
    print("Property creation status:", result_1.response.status.code.name)
```

<p tit="Output"></p> 
 
```
Does the property already exist? False
Property creation status: SUCCESS
----- Creates the property again -----
Does the property already exist? True
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

```python
# Renames the property 'tags' of the node schema 'Paper' to 'keywords' in the graph 'citation'

requestConfig = RequestConfig(graph="citation")

oldProperty = Property(name="tags", schema="Paper")
newProperty = Property(name="keywords")
response = Conn.alterProperty(DBType.DBNODE, oldProperty, newProperty, requestConfig)
print(response.status.code.name)
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

```python
# Drops the property 'tags' of the node schema in the graph 'citation'

requestConfig = RequestConfig(graph="citation")

property = Property(name="tags", schema="Paper")
response = Conn.dropProperty(DBType.DBNODE, property, requestConfig)
print(response.status.code.name)
```

<p tit="Output"></p> 

```
SUCCESS
```

