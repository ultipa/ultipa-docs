# Schema and Property

This section introduces methods for managing schemas and properties in a graph.

# Schema

### ShowSchema()

Retrieves all schemas from the graph.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Schema`: A slice of pointers to the retrieved schemas.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all schemas in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

schemas, _ := driver.ShowSchema(requestConfig)
for _, schema := range schemas {
    fmt.Println(schema.Name, schema.DBType)
}
```

<p tit="Output"></p> 
 
```
default DBNODE
account DBNODE
celebrity DBNODE
country DBNODE
movie DBNODE
default DBEDGE
direct DBEDGE
disagree DBEDGE
filmedIn DBEDGE
follow DBEDGE
wishlist DBEDGE
response DBEDGE
review DBEDGE
```

### ShowNodeSchema()

Retrieves all node schemas from the graph.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Schema`: A slice of pointers to the retrieved schemas.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all node schemas in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

schemas, _ := driver.ShowNodeSchema(requestConfig)
for _, schema := range schemas {
    fmt.Println(schema.Name, schema.DBType)
}
```

<p tit="Output"></p> 
 
```
default DBNODE
account DBNODE
celebrity DBNODE
country DBNODE
movie DBNODE
```

### ShowEdgeSchema()

Retrieves all edge schemas from the graph.

**Parameters**

- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Schema`: A slice of pointers to the retrieved schemas.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all edge schemas in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

schemas, _ := driver.ShowEdgeSchema(requestConfig)
for _, schema := range schemas {
    fmt.Println(schema.Name, schema.DBType)
}
```

<p tit="Output"></p> 
 
```
default DBEDGE
direct DBEDGE
disagree DBEDGE
filmedIn DBEDGE
follow DBEDGE
wishlist DBEDGE
response DBEDGE
review DBEDGE
```

### GetSchema()

Retrieves a specified schema from the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `dbType: ultipa.DBType`: Type of the schema (node or edge).
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `*structs.Schema`: A pointer to the retrieved schema.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves the node schema named 'account'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

schema, _ := driver.GetSchema("account", ultipa.DBType_DBNODE, requestConfig)
fmt.Println(schema.Total)
```

<p tit="Output"></p> 
 
```
111
```

### GetNodeSchema()

Retrieves a specified node schema from the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `*structs.Schema`: A pointer to the retrieved schema.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves the node schema named 'account'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

schema, _ := driver.GetNodeSchema("account", requestConfig)
if schema != nil {
    for _, property := range schema.Properties {
        println(property.Name)
  }
} else {
    print("Not found")
}
```

<p tit="Output"></p> 
 
```
gender
year
industry
name
```

### GetEdgeSchema()

Retrieves a specified edge schema from the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `*structs.Schema`: A pointer to the retrieved schema.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves the edge schema named 'disagree'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

schema, _ := driver.GetEdgeSchema("agree", requestConfig)
if schema != nil {
    for _, property := range schema.Properties {
        println(property.Name)
  }
} else {
    print("Not found")
}
```

<p tit="Output"></p> 
 
```
datetime
timestamp
targetPost
```

### CreateSchema()

Creates a schema in the graph.

**Parameters**

- `schema: *structs.Schema`: The schema to be created; the fields `Name` and `DBType` are mandatory, `Properties` and `Description` are optional.
- `isCreateProperties: bool`: Whether to create properties associated with the schema.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

// Creates node schema 'utility' (with properties)

response1, _ := driver.CreateSchema(&structs.Schema{
    Name:   "utility",
    DBType: ultipa.DBType_DBNODE,
    Properties: []*structs.Property{
    	{Name: "name", Type: ultipa.PropertyType_STRING},
    	{Name: "type", Type: ultipa.PropertyType_UINT32}},
}, true, requestConfig)
fmt.Println(response1.Status.Code)

time.Sleep(3 * time.Second)

// Creates edge schema 'vote' (without properties)

response2, _ := driver.CreateSchema(&structs.Schema{
    Name:   "vote",
    DBType: ultipa.DBType_DBEDGE,
}, false, requestConfig)
fmt.Println(response2.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
```

### CreateSchemaIfNotExist()

Creates a schema in the graph and returns whether a node or edge schema with the same name already exists.

**Parameters**

- `schema: *structs.Schema`: The schema to be created; the fields `Name` and `DBType` are mandatory, `Properties` and `Description` are optional.
- `isCreateProperties: bool`: Whether to create properties associated with the schema.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `ResponseWithExistCheck`: Result of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

schema := &structs.Schema{
    Name:   "utility",
    DBType: ultipa.DBType_DBNODE,
    Properties: []*structs.Property{
    	{Name: "name", Type: ultipa.PropertyType_STRING},
    	{Name: "type", Type: ultipa.PropertyType_UINT32}},
}

result, _ := driver.CreateSchemaIfNotExist(schema, true, requestConfig)
fmt.Println("Does the schema already exist?", result.Exist)
if result.Response == nil {
    fmt.Println("Schema creation status: No response")
} else {
    fmt.Println("Schema creation status:", result.Response.Status.Code)
}

time.Sleep(3 * time.Second)
fmt.Println("----- Creates the schema again -----")

result_1, _ := driver.CreateSchemaIfNotExist(schema, true, requestConfig)
fmt.Println("Does the schema already exist?", result_1.Exist)
if result_1.Response == nil {
    fmt.Println("Schema creation status: No response")
} else {
    fmt.Println("Schema creation status:", result_1.Response.Status.Code)
}
```

<p tit="Output"></p> 
 
```
Does the schema already exist? false
Schema creation status: No response
----- Creates the schema again -----
Does the schema already exist? true
Schema creation status: No response
```

### AlterSchema()

Alters the name and description a schema in the graph.

**Parameters**

- `originalSchema: *structs.Schema`: The schema to be altered; the fields `Name` and `DBType` are mandatory. 
- `newSchema: *structs.Schema`: A pointer to the `Schema` struct used to set new `Name` and/or `Description` for the schema.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Renames the node schema 'utility' to 'securityUtility' in the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

oldSchema := &structs.Schema{Name: "utility", DBType: ultipa.DBType_DBNODE}
newSchema := &structs.Schema{Name: "securityUtility"}
response, _ := driver.AlterSchema(oldSchema, newSchema, requestConfig)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### DropSchema()

Deletes a specified schema from the graph.

**Parameters**

- `schema: *structs.Schema`: The schema to be dropped; the fields `Name` and `DBType` are mandatory. 
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Drops the edge schema 'vote' from the graph 'miniCircle'

requestConfig := &configuration.RequestConfig{
    Graph: "miniCircle",
}

response, _ := driver.DropSchema(&structs.Schema{Name: "vote", DBType: ultipa.DBType_DBEDGE}, requestConfig)
fmt.Println(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Property

### ShowProperty()

Retrieves properties from the graph.

**Parameters**

- `dbType: ultipa.DBType`: Type of the property (node or edge, or global).
- `schemaName: string`: Name of the schema; use an empty string (`""`) to target all schemas.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Property`: A slice of pointers to the retrieved node properties.
- `[]*structs.Property`: A slice of pointers to the retrieved edge properties.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves all properties in the graph 'citation'

requestConfig := &configuration.RequestConfig{
    Graph: "citation",
}

nodeProperties, edgeProperties, _ := driver.ShowProperty(ultipa.DBType_DBGLOBAL, "", requestConfig)

fmt.Println("Node Properties:")
for _, nodeProperty := range nodeProperties {
    fmt.Println(nodeProperty.Name, "is associated with schema", nodeProperty.Schema)
}

fmt.Println("Edge Properties:")
for _, edgeProperty := range edgeProperties {
    fmt.Println(edgeProperty.Name, "is associated with schema", edgeProperty.Schema)
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

### ShowNodeProperty()

Retrieves node properties from the graph.

**Parameters**

- `schemaName: string`: Name of the schema; use an empty string (`""`) to target all schemas.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Property`: A slice of pointers to the retrieved properties.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves properties associated with the node schema 'Paper' in the graph 'citation'

requestConfig := &configuration.RequestConfig{
    Graph: "citation",
}

properties, _ := driver.ShowNodeProperty("Paper", requestConfig)
for _, property := range properties {
    fmt.Println(property.Name, "-", property.Type)
}
```

<p tit="Output"></p> 
 
```
_id - STRING
title - STRING
score - INT32
author - STRING
```

### ShowEdgeProperty()

Retrieves edge properties from the graph.

**Parameters**

- `schemaName: string`: Name of the schema; use an empty string (`""`) to target all schemas.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `[]*structs.Property`: A slice of pointers to the retrieved properties.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves properties associated with the edge schema 'Cites' in the graph 'citation'

requestConfig := &configuration.RequestConfig{
    Graph: "citation",
}

properties, _ := driver.ShowEdgeProperty("Cites", requestConfig)
for _, property := range properties {
    fmt.Println(property.Name, "-", property.Type)
}
```

<p tit="Output"></p> 
 
```
weight - INT32
```

### GetProperty()

Retrieves a specified property from the graph.

**Parameters**

- `dbType: ultipa.DBType`: Type of the property (node or edge).
- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `*structs.Property`: The retrieved property.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves node property 'title' associated with the node schema 'Paper' in the graph 'citation'

requestConfig := &configuration.RequestConfig{
    Graph: "citation",
}

property, _ := driver.GetProperty(ultipa.DBType_DBNODE, "Paper", "title", requestConfig)
fmt.Println(property)
```

<p tit="Output"></p> 
 
```
&{title Paper STRING [] false false false   <nil>}
```

### GetNodeProperty()

Retrieves a specified node property from the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `*structs.Property`: The retrieved property.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves node property 'title' associated with the node schema 'Paper' in the graph 'citation'

requestConfig := &configuration.RequestConfig{
    Graph: "citation",
}

property, _ := driver.GetNodeProperty("Paper", "title", requestConfig)
fmt.Println(property)
```

<p tit="Output"></p> 
 
```
&{title Paper STRING [] false false false   <nil>}
```

### GetEdgeProperty()

Retrieves a specified edge property from the graph.

**Parameters**

- `schemaName: string`: Name of the schema.
- `propertyName: string`: Name of the property.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `*structs.Property`: The retrieved property.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Retrieves edge property 'weight' associated with the edge schema 'Cites' in the graph 'citation'

requestConfig := &configuration.RequestConfig{
    Graph: "citation",
}

property, _ := driver.GetEdgeProperty("Cites", "weight", requestConfig)
fmt.Println(property)
```

<p tit="Output"></p> 
 
```
&{weight Cites INT32 [] false false false   <nil>}
```

### CreateProperty()

Creates a property in the graph.

**Parameters**

- `dbType: ultipa.DBType`: Type of the property (node or edge).
- `property: *structs.Property`: The property to be created; the fields `Name`, `Type` (and `SubType` if the `Type` is `SET` or `LIST`), and `Schema` (sets to `*` to specify all schemas) are mandatory, `Encrypt` and `Description` are optional.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Creates a property 'year' for all node schemas, creates a property 'tags' for the node schema 'Paper'

requestConfig := &configuration.RequestConfig{
    Graph: "citation",
}

response1, _ := driver.CreateProperty(ultipa.DBType_DBNODE, &structs.Property{
    Name:    "year",
    Type:    ultipa.PropertyType_INT32,
    Encrypt: "AES128",
    Schema:  "*",
}, requestConfig)
fmt.Println(response1.Status.Code)

response2, _ := driver.CreateProperty(ultipa.DBType_DBNODE, &structs.Property{
    Name:     "tags",
    Type:     ultipa.PropertyType_SET,
    SubTypes: []ultipa.PropertyType{ultipa.PropertyType_STRING},
    Schema:   "Paper",
}, requestConfig)
fmt.Println(response2.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
```

### CreatePropertyIfNotExist()

Creates a property in the graph and returns whether a node or edge property with the same name already exists for the specified schema.

**Parameters**

- `dbType: ultipa.DBType`: Type of the property (node or edge).
- `property: *structs.Property`: The property to be created; the fields `Name`, `Type` (and `SubType` if the `Type` is `SET` or `LIST`), and `Schema` (sets to `*` to specify all schemas) are mandatory, `Encrypt` and `Description` are optional.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `ResponseWithExistCheck`: Result of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
requestConfig := &configuration.RequestConfig{
    Graph: "citation",
}

property := &structs.Property{
    Name:     "tags",
    Type:     ultipa.PropertyType_SET,
    SubTypes: []ultipa.PropertyType{ultipa.PropertyType_STRING},
    Schema:   "Paper",
}

result, _ := driver.CreatePropertyIfNotExist(ultipa.DBType_DBNODE, property, requestConfig)
fmt.Println("Does the property already exist?", result.Exist)
if result.Response == nil {
    fmt.Println("Property creation status: No response")
} else {
    fmt.Println("Property creation status:", result.Response.Status.Code)
}

time.Sleep(3 * time.Second)
fmt.Println("----- Creates the property again -----")

result_1, _ := driver.CreatePropertyIfNotExist(ultipa.DBType_DBNODE, property, requestConfig)
fmt.Println("Does the property already exist?", result_1.Exist)
if result_1.Response == nil {
    fmt.Println("Property creation status: No response")
} else {
    fmt.Println("Property creation status:", result_1.Response.Status.Code)
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

### AlterProperty()

Alters the name and description a property in the graph.

**Parameters**

- `dbType: ultipa.DBType`: Type of the property (node or edge).
- `originProp: *structs.Property`: The property to be altered; the fields `Name` and `Schema` (writes `*` to specify all schemas) are mandatory.
- `newProp: *structs.Property`: A pointer to the `Property` struct used to set new `Name` and/or `Description` for the property.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Renames the property 'tags' of the node schema 'Paper' to 'keywords' in the graph 'citation'

requestConfig := &configuration.RequestConfig{
    Graph: "citation",
}

response, _ := driver.AlterProperty(ultipa.DBType_DBNODE, &structs.Property{
    Name:   "tags",
    Schema: "Paper",
}, &structs.Property{
    Name: "keywords",
}, requestConfig)
fmt.Print(response.Status.Code)
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### DropProperty()

Deletes specified properties from the graph.

**Parameters**

- `dbType: ultipa.DBType`: Type of the property (node or edge).
- `property: *structs.Property`: The property to be droppped; the fields `Name` and `Schema` (writes `*` to specify all schemas) are mandatory.
- `config: *configuration.RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.
- `error`: An error object that contains details about any issues encountered during the operation. If the operation succeeds, `nil` is returned.

```go
// Drops the property 'tags' of the node schema in the graph 'citation'

requestConfig := &configuration.RequestConfig{
    Graph: "citation",
}

response, _ := driver.DropProperty(ultipa.DBType_DBNODE, &structs.Property{
    Name:   "tags",
    Schema: "Paper",
}, requestConfig)
fmt.Print(response.Status.Code)
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

	ultipa "github.com/ultipa/ultipa-go-driver/v5/rpc"
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

	// Creates schemas and properties in the graph 'social'

	requestConfig := &configuration.RequestConfig{
		Graph: "social",
	}

	user := &structs.Schema{
		Name:   "user",
		DBType: ultipa.DBType_DBNODE,
		Properties: []*structs.Property{
			{Name: "name", Type: ultipa.PropertyType_STRING},
			{Name: "age", Type: ultipa.PropertyType_INT32},
			{Name: "score", Type: ultipa.PropertyType_DECIMAL, DecimalExtra: &structs.DecimalExtra{Precision: 25, Scale: 10}},
			{Name: "birthday", Type: ultipa.PropertyType_DATE},
			{Name: "active", Type: ultipa.PropertyType_BOOL},
			{Name: "location", Type: ultipa.PropertyType_POINT},
			{Name: "interests", Type: ultipa.PropertyType_LIST, SubTypes: []ultipa.PropertyType{ultipa.PropertyType_STRING}},
			{Name: "permissionCodes", Type: ultipa.PropertyType_SET, SubTypes: []ultipa.PropertyType{ultipa.PropertyType_INT32}},
		},
	}

	product := &structs.Schema{
		Name:   "product",
		DBType: ultipa.DBType_DBNODE,
		Properties: []*structs.Property{
			{Name: "name", Type: ultipa.PropertyType_STRING},
			{Name: "price", Type: ultipa.PropertyType_FLOAT},
		},
	}

	follows := &structs.Schema{
		Name:   "follows",
		DBType: ultipa.DBType_DBEDGE,
		Properties: []*structs.Property{
			{Name: "createdOn", Type: ultipa.PropertyType_TIMESTAMP},
			{Name: "weight", Type: ultipa.PropertyType_FLOAT},
		},
	}

	purchased := &structs.Schema{
		Name:   "purchased",
		DBType: ultipa.DBType_DBEDGE,
	}

	schemas := []*structs.Schema{user, product, follows, purchased}
	for _, schema := range schemas {
		response, _ := driver.CreateSchema(schema, true, requestConfig)
		fmt.Println(response.Status.Code)
	}
}
```
