# Schema and Property Management

This section introduces methods on a `Connection` object for managing schemas and properties of nodes and edges in a graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

# Schema

### ShowSchema()

Retrieves all nodes and edge schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Schema>`: The list of all schemas in the current graphset.

```csharp
// Retrieves all schemas in graphset 'UltipaTeam' and prints their names and types

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };
var schemaInfo = await ultipa.ShowSchema(requestConfig);

foreach (var schema in schemaInfo)
{
    Console.WriteLine(schema.DbType + ": " + schema.Name);
}
```

<p tit="Output"></p> 
 
```
Dbnode: default
Dbnode: member
Dbnode: organization
Dbedge: default
Dbedge: reportsTo
Dbedge: relatesTo
```

### GetSchema()

Retrieves a node or edge schema from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `DBType`: Type of the schema (node or edge).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved schema.

```csharp
// Retrieves node schema 'member' and edge schema 'connectsTo' in graphset 'UltipaTeam', and prints all their information

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var schema1 = await ultipa.GetSchema("member", DBType.Dbnode, requestConfig);
Console.WriteLine("schema1: " + JsonConvert.SerializeObject(schema1));

var schema2 = await ultipa.GetSchema("connectsTo", DBType.Dbedge, requestConfig);
Console.WriteLine("schema2: " + JsonConvert.SerializeObject(schema2));
```

<p tit="Output"></p> 
 
```
schema1: {"Name":"member","Desc":"","DbType":0,"Total":0,"Properties":[{"Name":"title","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"member","Type":7,"SubTypes":[],"Extra":"{}","Encrypt":""},{"Name":"profile","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"member","Type":7,"SubTypes":[],"Extra":"{}","Encrypt":""},{"Name":"startDate","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"member","Type":8,"SubTypes":[],"Extra":"{}","Encrypt":""}]}
schema2: null
```

### ShowNodeSchema()

Retrieves all node schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Schema>`: The list of all node schemas in the current graphset.

```csharp
// Retrieves all node schemas in graphset 'UltipaTeam' and prints their names

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var schemaList = await ultipa.ShowNodeSchema(requestConfig);
foreach (var schema in schemaList)
{
    Console.WriteLine(schema.Name);
}
```

<p tit="Output"></p> 
 
```
default
member
organization
```

### ShowEdgeSchema()

Retrieves all edge schemas from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Schema>`: The list of all edge schemas in the current graphset.

```csharp
// Retrieves all edge schemas in graphset 'UltipaTeam' and prints their names

var schemaList = await ultipa.ShowEdgeSchema(requestConfig);
foreach (var schema in schemaList)
{
    Console.WriteLine(schema.Name);
}
```

<p tit="Output"></p> 
 
```
default
reportsTo
relatesTo
```

### GetNodeSchema()

Retrieves a node schema from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved node schema.

```csharp
// Retrieves node schema 'member' in graphset 'UltipaTeam' and prints its properties

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var schema = await ultipa.GetNodeSchema("member", requestConfig);

foreach (var item in schema.Value.Properties)
{
    Console.WriteLine(JsonConvert.SerializeObject(item));
}
```

<p tit="Output"></p> 
 
```
{"Name":"title","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"member","Type":7,"SubTypes":[],"Extra":"{}","Encrypt":""}
{"Name":"profile","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"member","Type":7,"SubTypes":[],"Extra":"{}","Encrypt":""}
{"Name":"startDate","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"member","Type":8,"SubTypes":[],"Extra":"{}","Encrypt":""}
```

### GetEdgeSchema()

Retrieves an edge schema from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Schema`: The retrieved edge schema.

```csharp
// Retrieves edge schema 'relatesTo' in graphset 'UltipaTeam' and prints its properties

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var schema = await ultipa.GetEdgeSchema("relatesTo", requestConfig);

foreach (var item in schema.Value.Properties)
{
    Console.WriteLine(JsonConvert.SerializeObject(item));
}
```

<p tit="Output"></p> 
 
```
{"Name":"type","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"relatesTo","Type":7,"SubTypes":[],"Extra":"{}","Encrypt":""}
```

### CreateSchema()

Creates a new schema in the current graphset.

**Parameters:**

- `Schema`: The schema to be created; the field `Name` must be set, `DbType` (if not specified, Dbnode is used by default), `Desc` (short for description) and `Properties` are optional.
- `bool` (Optional): Whether to create properties, the default is `false`.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

```csharp
RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

// Creates node schema 'utility' (with properties) in graphset 'UltipaTeam' and prints all its information

var new1 = await ultipa.CreateSchema(
    new Schema()
    {
        Name = "utility",
        DbType = DBType.Dbnode,
        Properties = new List<Property>()
        {
            new Property() { Name = "name", Type = PropertyType.String },
            new Property() { Name = "purchaseDate", Type = PropertyType.Datetime },
        },
    },
    true,
    requestConfig
);
Console.WriteLine(new1.Status.ErrorCode);
Thread.Sleep(3000);
var show1 = await ultipa.GetNodeSchema("utility", requestConfig);
Console.WriteLine(JsonConvert.SerializeObject(show1.Value));

// Creates edge schema 'managedBy' (without properties) in graphset 'UltipaTeam' and prints all its information

var new2 = await ultipa.CreateSchema(
    new Schema()
    {
        Name = "managedBy",
        Desc = "office utilities",
        DbType = DBType.Dbedge,
    },
    requestConfig
);
Console.WriteLine(new2.Status.ErrorCode);
Thread.Sleep(3000);
var show2 = await ultipa.GetEdgeSchema("managedBy", requestConfig);
Console.WriteLine(JsonConvert.SerializeObject(show2.Value));
```

<p tit="Output"></p> 
 
```
Success
{"Name":"utility","Desc":"","DbType":0,"Total":0,"Properties":[{"Name":"name","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"utility","Type":7,"SubTypes":[],"Extra":"{}","Encrypt":""},{"Name":"purchaseDate","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"utility","Type":8,"SubTypes":[],"Extra":"{}","Encrypt":""}]}
Success
{"Name":"managedBy","Desc":"office utilities","DbType":1,"Total":0,"Properties":[]}
```

### CreateSchemaIfNotExist()

Creates a new schema in the current graphset, handling cases where the given schema name already exists by ignoring the error.

**Parameters:**

- `Schema`: The schema to be created; the fields `Name` and `DBType` must be set, `Desc` and `Properties` are optional.
- `bool` (Optional): Whether to create properties, the default is `false`.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.
- `bool`: Whether the schema exists.

```csharp
RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };


// Creates one schema in graphset 'UltipaTeam' and prints if the schema already exists

var new1 = await ultipa.CreateSchemaIfNotExist(
    new Schema() { Name = "utility", DbType = DBType.Dbnode },
    requestConfig
);
Console.WriteLine("Schema already exists: " + new1.Item2);
Thread.Sleep(3000);

// Creates the same schema again and prints if the schema already exists

var new2 = await ultipa.CreateSchemaIfNotExist(
    new Schema() { Name = "utility", DbType = DBType.Dbnode },
    requestConfig
);
Console.WriteLine("Schema already exists: " + new2.Item2);
```

<p tit="Output"></p> 
 
```
Schema already exists: False
Schema already exists: True
```

### AlterSchema()

Alters the name and description of one existing schema in the current graphset by its name.

**Parameters:**

- `Schema`: The existing schema to be altered; the fields `Name` and `DbType` must be set. 
- `Schema`: The new configuration for the existing schema; the fields `Name` and `DbType` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

```csharp
// Renames the node schema 'utility' to 'securityUtility' and removes its description in graphset 'UltipaTeam'

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var alter = await ultipa.AlterSchema(
    new Schema() { Name = "utility", DbType = DBType.Dbnode },
    new Schema()
    {
        Name = "securityUtility",
        DbType = DBType.Dbnode,
        Desc = "yyyy",
    },
    requestConfig
);
Console.WriteLine(alter.Status.ErrorCode);
```

<p tit="Output"></p> 
 
```
Success
```

### DropSchema()

Drops one schema from the current graphset by its name.

**Parameters:**

- `Schema`: The existing schema to be dropped; the fields `Name` and `DbType` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

```csharp
// Drops the node schema 'utility' in graphset 'UltipaTeam'

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var res = await ultipa.DropSchema(
    new Schema() { Name = "utility", DbType = DBType.Dbnode },
    requestConfig
);
Console.WriteLine(res.Status.ErrorCode);
```

<p tit="Output"></p> 
 
```
Success
```

## Property

### ShowProperty()

Retrieves custom properties of nodes or edges from the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string` (Optional): Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Property>`: The list of all properties retrieved in the current graphset.

```csharp
// Retrieves all node properties in graphset 'UltipaTeam' and prints their names and associated schemas

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var res = await ultipa.ShowProperty(DBType.Dbnode, requestConfig);
foreach (var item in res)
{
    Console.WriteLine(
        $"{item.Name}({item.Type}) is associated with schema named {item.Schema}"
    );
}
```

<p tit="Output"></p> 
 
```
name(String) is associated with schema named member
title(String) is associated with schema named member
profile(String) is associated with schema named member
name(String) is associated with schema named organization
logo(String) is associated with schema named organization
```

### ShowNodeProperty()

Retrieves custom properties of nodes from the current graphset.

**Parameters:**

- `string` (Optional): Name of the schema.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Property>`: The list of all properties retrieved in the current graphset.

```csharp
// Retrieves all custom properties of node schema 'member' in graphset 'UltipaTeam' and prints the count

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var res = await ultipa.ShowNodeProperty("member", requestConfig);
Console.WriteLine(res.Count);
```

<p tit="Output"></p> 
 
```
3
```

### ShowEdgeProperty()

Retrieves custom properties of edges from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `string` (Optional): Name of the schema.
- `List<Property>`: The list of all properties retrieved in the current graphset.

```csharp
// Retrieves all custom properties of edge schema 'relatesTo' in graphset 'UltipaTeam' and prints their names

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var res = await ultipa.ShowEdgeProperty("relatesTo", requestConfig);
foreach (var item in res)
{
    Console.WriteLine(item.Name);
}
```

<p tit="Output"></p> 
 
```
type
```

### GetProperty()

Retrieves a custom property of nodes or edges from the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

```csharp
// Retrieves node property @member.title in graphset 'UltipaTeam' and prints all its information

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var res = await ultipa.GetProperty(DBType.Dbnode, "member", "title", requestConfig);
Console.WriteLine(JsonConvert.SerializeObject(res));
```

<p tit="Output"></p> 
 
```
{"Name":"title","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"member","Type":7,"SubTypes":[],"Extra":"{}","Encrypt":""}
```

### GetNodeProperty()

Retrieves a custom property of nodes from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

```csharp
// Retrieves node property @member.title in graphset 'UltipaTeam' and prints all its information

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var res = await ultipa.GetNodeProperty("member", "title", requestConfig);
Console.WriteLine(JsonConvert.SerializeObject(res));
```

<p tit="Output"></p> 
 
```
{"Name":"title","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"member","Type":7,"SubTypes":[],"Extra":"{}","Encrypt":""}
```

### GetEdgeProperty()

Retrieves a custom property of edges from the current graphset.

**Parameters:**

- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Property`: The retrieved property.

```csharp
// Retrieves edge property @relatesTo.type in graphset 'UltipaTeam' and prints all its information

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var res = await ultipa.GetEdgeProperty("relatesTo", "type", requestConfig);
Console.WriteLine(JsonConvert.SerializeObject(res));
```

<p tit="Output"></p> 
 
```
{"Name":"type","Desc":"","Lte":false,"Read":true,"Write":true,"Schema":"relatesTo","Type":7,"SubTypes":[],"Extra":"{}","Encrypt":""}
```

### CreateProperty()

Creates a new property for a node or edge schema in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `Property`: The property to be created; the fields `Schema`, `Name` and `Type` must be set; write `*` in `Schema` to specify all schemas.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

```csharp
// Creates two properties for node schema 'member' in graphset 'UltipaTeam' and prints error codes

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var res1 = await ultipa.CreateProperty(
    DBType.Dbnode,
    new Property()
    {
        Name = "startDate",
        Schema = "member",
        Type = PropertyType.Datetime,
    },
    requestConfig
);
Console.WriteLine(res1.Status.ErrorCode);

var res2 = await ultipa.CreateProperty(
    DBType.Dbnode,
    new Property()
    {
        Name = "age",
        Schema = "member",
        Type = PropertyType.Int32,
    },
    requestConfig
);
Console.WriteLine(res2.Status.ErrorCode);
```

<p tit="Output"></p> 
 
```
Success
Success
```

### CreatePropertyIfNotExist()

Creates a new property for a node or edge schema in the current graphset, handling cases where the given property name already exists by ignoring the error.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `Property`: The property to be created; the fields `Name` and `Type` must be set.
- `RequestConfig` (Optional): Configuration settings for the request. If it is left empty, the function will use default configuration settings.

**Returns:**

- `UqlResponse`: Result of the request.
- `bool`: Whether the property exists.

```csharp
RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

// Creates a property for node schema 'member' in graphset 'UltipaTeam' and prints if the schema already exists

var res1 = await ultipa.CreatePropertyIfNotExist(
    DBType.Dbnode,
    new Property()
    {
        Name = "startDate",
        Schema = "member",
        Type = PropertyType.Datetime,
    },
    requestConfig
);
Console.WriteLine("Property already exists: " + res1.Item2);

// Creates the same property again in graphset 'UltipaTeam' and prints if the schema already exists

var res2 = await ultipa.CreatePropertyIfNotExist(
    DBType.Dbnode,
    new Property()
    {
        Name = "startDate",
        Schema = "member",
        Type = PropertyType.Datetime,
    },
    requestConfig
);
Console.WriteLine("Property already exists: " + res2.Item2);
```

<p tit="Output"></p> 
 
```
Property already exists: False
Property already exists: True
```

### AlterProperty()

Alters the name and description of one existing custom property in the current graphset by its name.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `Property`: The existing property to be altered; the fields `Name` and `Schema` (write `*` to specify all schemas) must be set. 
- `Property`: The new configuration for the existing property; either or both of the fields `Name` and `Desc` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

```csharp
RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

// Rename properties 'name' associated with all node schemas to `Name` in graphset 'UltipaTeam'

var res = await ultipa.AlterProperty(
    DBType.Dbnode,
    new Property() { Name = "name", Schema = "*" },
    new Property() { Name = "Name", Schema = "*" },
    requestConfig
);
Console.WriteLine(res.Status.ErrorCode);
```

<p tit="Output"></p> 
 
```
Success
```

### DropProperty()

Drops one custom property from the current graphset by its name and the associated schema.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

```csharp
RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

// Drops properties 'startDate' assocaited with all node schemas in graphset 'UltipaTeam' and prints error code

var res1 = await ultipa.DropProperty(DBType.Dbnode, "*", "startDate", requestConfig);
Console.WriteLine(res1.Status.ErrorCode);

// Drops node property @member.name in graphset 'UltipaTeam' and prints error code

var res2 = await ultipa.DropProperty(DBType.Dbnode, "member", "name", requestConfig);
Console.WriteLine(res2.Status.ErrorCode);
```

<p tit="Output"></p> 
 
```
Success
Success
```

