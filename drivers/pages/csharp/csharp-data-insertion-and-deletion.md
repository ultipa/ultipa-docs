# Data Insertion and Deletion

This section introduces methods on a `Connection` object for inserting nodes and edges to the graph or deleting nodes and edges from the graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Example Graph Data Model

The examples below demonstrate how to insert or delete nodes or edges from a graphset with the following schema and property definitions:

<div align=center drawio-diagram='16645' drawio-name="draw_eef958d9d27649c381cb1e470f4963cc.jpg"><img src="https://img.ultipa.cn/draw/draw_eef958d9d27649c381cb1e470f4963cc.jpg?v='1735117958802'"/></div>

## Property Type Mapping

When inserting nodes or edges, you may need to specify property values of different types. The mapping between Ultipa property types and C#/Driver data types is as follows:

| Ultipa Property Type | <div table-width="65">C#/Driver Type</div> |
| -- | -- |
| int32 | `int` |
| uint32 | `uint` |
| int64 | `long` |
| uint64 | `ulong` |
| float | `float` |
| double | `double` |
| decimal | `Decimal` (Driver type) |
| string | `String` |
| text | `String` |
| datetime | `UltipaDatetime` (Driver type) |
| timestamp | `UltipaDatetime` (Driver type) |
| point | `Point` (Driver type) |
| blob | `byte[]` and `String` |
| list | `List` |
| set | `HashSet` |

## Insertion

### InsertNodes()

Inserts new nodes of a schema to the current graph.
 
**Parameters:**

- `string`: Name of the schema.
- `List<Node>`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. 

**Returns:**

- `UqlResponse`: Result of the request. The `Response` object contains an alias `nodes` that holds all the inserted nodes when `InsertRequestConfig.Slient` is set to false.

```csharp
InsertRequestConfig insertRequestConfig = new InsertRequestConfig()
{
    InsertType = InsertType.Normal,
    Graph = "lcc",
    Silent = false,
};

// Inserts two nodes into schema 'user' in graphset 'lcc', prints error code and information of the inserted nodes

var myPoint = new Point();
myPoint.X = 23.63M;
myPoint.Y = 104.25M;

Node node1 = new Node()
{
    Uuid = 1,
    Id = "U001",
    Values = new()
    {
        { "name", "Alice" },
        { "age", 18 },
        { "score", 65.32M },
        { "birthday", new DateTime(1993, 5, 4) },
        { "location", myPoint },
        { "profile", "abc" },
        {
            "interests",
            new List<string>() { "tennis", "violin" }
        },
        {
            "permissionCodes",
            new HashSet<int> { 2004, 3025, 1025 }
        },
    },
};

Node node2 = new Node()
{

    Uuid = 2,
    Id = "U002",
    Values = new() { { "name", "Bob" } },
};

List<Node> nodeList = new List<Node>();

nodeList.Add(node1);
nodeList.Add(node2);

var res = await ultipa.InsertNodes("user", nodeList, insertRequestConfig);
if (res.Status.ErrorCode == 0)
{
    Console.WriteLine("Insertion succeeds");
}

// There is no alias in Response if InsertRequestConfig.Slient is true

List<Node> insertedNodes = res?.Alias("nodes")?.AsNodes();
foreach (var node in insertedNodes)
{
    Console.WriteLine(JsonConvert.SerializeObject(node));
}
```
<p tit="Output"></p> 
 
```
Insertion succeeds
{"Uuid":1,"Id":"U001","Schema":"user","Values":{"name":"Alice","age":18,"score":65.3200000000,"birthday":"1993-05-04T00:00:00Z","location":{"X":23.630000,"Y":104.250000},"profile":"YWJj","interests":["tennis","violin"],"permissionCodes":null}}
{"Uuid":2,"Id":"U002","Schema":"user","Values":{"name":"Bob","age":null,"score":null,"birthday":null,"location":null,"profile":null,"interests":null,"permissionCodes":null}}
```

### InsertEdges()

Inserts new edges of a schema to the current graph.
 
**Parameters:**

- `string`: Name of the schema.
- `List<Edge>`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. 

**Returns:**

- `UqlResponse`: Result of the request. The `Response` object contains an alias `edges` that holds all the inserted edges when `InsertRequestConfig.Slient` is set to false.

```csharp
InsertRequestConfig insertRequestConfig = new InsertRequestConfig()
{
    InsertType = InsertType.Normal,
    Graph = "lcc",
    Silent = false,
};

// Inserts two edges into schema 'follows' in graphset 'lcc', prints error code and information of the inserted edges

List<Edge> edgeList = new List<Edge>();
Edge edge1 = new Edge()
{
    Uuid = 1,
    FromId = "U001",
    ToId = "U002",
    Values = new() { { "createdOn", new DateTime(2024, 5, 6) } },
};
Edge edge2 = new Edge()
{
    Uuid = 2,
    FromId = "U002",
    ToId = "U001",
    Values = new() { { "createdOn", new DateTime(2024, 5, 8) } },
};

edgeList.Add(edge1);
edgeList.Add(edge2);

var res = await ultipa.InsertEdges("follows", edgeList, insertRequestConfig);
if (res.Status.ErrorCode == 0)
{
    Console.WriteLine("Insertion succeeds");
}

// There is no alias in Response if InsertRequestConfig.Slient is true

List<Edge> insertedEdges = res?.Alias("edges")?.AsEdges();
foreach (var edge in insertedEdges)
{
    Console.WriteLine(JsonConvert.SerializeObject(edge));
}
```

<p tit="Output"></p> 
 
```
Insertion succeeds
{"Uuid":1,"FromUuid":1,"ToUuid":2,"Id":"","FromId":"U001","ToId":"U002","Schema":"follows","Values":{"createdOn":"2024-05-05T16:00:00Z"}}
{"Uuid":2,"FromUuid":2,"ToUuid":1,"Id":"","FromId":"U002","ToId":"U001","Schema":"follows","Values":{"createdOn":"2024-05-07T16:00:00Z"}}
```

### InsertNodesBatchBySchema()

Inserts new nodes of a schema into the current graph through gRPC. The properties within the node values must be consistent with those declared in the schema structure.

**Parameters:**

- `Schema`: The target schema.
- `List<Node>`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. 

**Returns:**

- `InsertResponse`: Result of the request.

```csharp
// Inserts two nodes into schema 'user' in graphset 'lcc' and prints error code 
InsertRequestConfig insertRequestConfig = new InsertRequestConfig()
{
    InsertType = InsertType.Normal,
    Graph = "lcc",
    Silent = false,
};

List<Property> properties = new List<Property>();
Property property1 = new Property() { Name = "name", Type = PropertyType.String };
Property property2 = new Property() { Name = "age", Type = PropertyType.Int32 };
Property property3 = new Property() { Name = "score", Type = PropertyType.Decimal };
Property property4 = new Property() { Name = "birthday", Type = PropertyType.Datetime };
Property property5 = new Property() { Name = "location", Type = PropertyType.Point };
Property property6 = new Property() { Name = "profile", Type = PropertyType.Blob };
Property property7 = new Property()
{
    Name = "interests",
    Type = PropertyType.List,
    SubTypes = new PropertyType[] { PropertyType.String },
};
Property property8 = new Property()
{
    Name = "permissionCodes",
    Type = PropertyType.Set,
    SubTypes = new PropertyType[] { PropertyType.Int32 },
};
properties.Add(property1);
properties.Add(property2);
properties.Add(property3);
properties.Add(property4);
properties.Add(property5);
properties.Add(property6);
properties.Add(property7);
properties.Add(property8);

Schema schema = new Schema()
{
    Name = "user",
    Properties = properties,
    DbType = DBType.Dbnode,
};

var myPoint = new Point();
myPoint.X = 23.63M;
myPoint.Y = 104.25M;

Node node1 = new Node()
{
    Uuid = 1,
    Id = "U001",
    Values = new()
    {
        { "name", "Alice" },
        { "age", 18 },
        { "score", 65.32M },
        { "birthday", new DateTime(1993, 5, 4) },
        { "location", myPoint },
        { "profile", new byte[] { 123 } },
        {
            "interests",
            new List<string> { "tennis", "violin" }
        },
        {
            "permissionCodes",
            new HashSet<int> { 2004, 3025, 1025 }
        },
    },
};

Node node2 = new Node()
{
    Uuid = 2,
    Id = "U002",
    Values = new() { { "name", "Bob" } },
};

List<Node> nodeList = new List<Node>();
nodeList.Add(node1);
nodeList.Add(node2);

var res = ultipa.InsertNodesBatchBySchema(schema, nodeList, insertRequestConfig);
Console.WriteLine(res.Status.ErrorCode);
Console.WriteLine(JsonConvert.SerializeObject(res));
```
<p tit="Output"></p> 
 
```
Success
{"Status":{"ErrorCode":0,"Msg":"","ClusterInfo":null},"Statistic":{"NodeAffected":0,"EdgeAffected":0,"TotalCost":0,"EngineCost":0},"Data":{"Uuids":[1,2],"Ids":[],"ErrorItem":{}}}
```

### InsertEdgesBatchBySchema()

Inserts new edges of a schema into the current graph through gRPC. The properties within the edge values must be consistent with those declared in the schema structure.

**Parameters:**

- `Schema`: The target schema.
- `List<Edge>`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. 

**Returns:**

- `InsertResponse`: Result of the request.

```csharp
// Inserts two edges into schema 'follows' in graphset 'lcc' and prints error code

InsertRequestConfig insertRequestConfig = new InsertRequestConfig()
{
    InsertType = InsertType.Normal,
    Graph = "lcc",
    Silent = false,
};

List<Property> properties = new List<Property>();
Property property = new Property() { Name = "createdOn", Type = PropertyType.Datetime };
properties.Add(property);

Schema schema = new Schema() { Name = "follows", Properties = properties };

List<Edge> edgeList = new List<Edge>();
Edge edge1 = new Edge()
{
    Uuid = 1,
    FromId = "U001",
    ToId = "U002",
    Values = new() { { "createdOn", new DateTime(2024, 5, 6) } },
};
Edge edge2 = new Edge()
{
    Uuid = 2,
    FromId = "U002",
    ToId = "U001",
    Values = new() { { "createdOn", new DateTime(2024, 5, 8) } },
};
edgeList.Add(edge1);
edgeList.Add(edge2);

var res = ultipa.InsertEdgesBatchBySchema(schema, edgeList, insertRequestConfig);
Console.WriteLine(res.Status.ErrorCode);
Console.WriteLine(JsonConvert.SerializeObject(res.Data));
```
<p tit="Output"></p> 
 
```
Success
{"Uuids":[1,2],"Ids":[],"ErrorItem":{}}
```

### InsertNodesBatchAuto()

Inserts new nodes of one or multiple schemas to the current graph through gRPC. The properties within node values must be consistent with those defined in the corresponding schema structure.

**Parameters:**

- `List<Node>`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. 

**Returns:**

- `Dictionary<string,InsertResponse>`: Result of the request. 

```csharp
// Inserts two nodes into schema 'user' and one node into schema `product` in graphset 'lcc' and prints error code

InsertRequestConfig insertRequestConfig = new InsertRequestConfig()
{
    InsertType = InsertType.Normal,
    Graph = "lcc",
    Silent = false,
};

var myPoint = new Point();
myPoint.X = 23.63M;
myPoint.Y = 104.25M;

Node node1 = new Node()
{
    Schema = "user",
    Uuid = 1,
    Id = "U001",
    Values = new()
    {
        { "name", "Alice" },
        { "age", 18 },
        { "score", 65.32M },
        { "birthday", new DateTime(1993, 5, 4) },
        { "location", myPoint },
        { "profile", new byte[] { 123 } },
        {
            "interests",
            new List<string>() { "tennis", "violin" }
        },
        {
            "permissionCodes",
            new HashSet<int> { 2004, 3025, 1025 }
        },
    },
};

Node node2 = new Node()
{
    Schema = "user",
    Uuid = 2,
    Id = "U002",
    Values = new() { { "name", "Bob" } },
};

Node node3 = new Node()
{
    Schema = "product",
    Uuid = 3,
    Id = "P001",
    Values = new() { { "name", "Wireless Earbud" }, { "price", 93.2F } },
};

List<Node> nodeList = new List<Node>();

nodeList.Add(node1);
nodeList.Add(node2);
nodeList.Add(node3);

var res = await ultipa.InsertNodesBatchAuto(nodeList, insertRequestConfig);
Console.WriteLine(JsonConvert.SerializeObject(res));
```

<p tit="Output"></p> 
 
```
{"user":{"Status":{"ErrorCode":0,"Msg":"","ClusterInfo":null},"Statistic":{"NodeAffected":0,"EdgeAffected":0,"TotalCost":0,"EngineCost":0},"Data":{"Uuids":[1,2],"Ids":[],"ErrorItem":{}}},"product":{"Status":{"ErrorCode":0,"Msg":"","ClusterInfo":null},"Statistic":{"NodeAffected":0,"EdgeAffected":0,"TotalCost":0,"EngineCost":0},"Data":{"Uuids":[3],"Ids":[],"ErrorItem":{}}}}
```

### InsertEdgesBatchAuto()

Inserts new edges of one or multiple schemas to the current graph through gRPC. The properties within edge values must be consistent with those defined in the corresponding schema structure.

**Parameters:**

- `List<Edge>`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request. 

**Returns:**

- `Dictionary<string,InsertResponse>`: Result of the request.

```csharp
// Inserts two edges into schema 'follows' and one edge into schema 'purchased' in graphset 'lcc' and prints error code

InsertRequestConfig insertRequestConfig = new InsertRequestConfig()
{
    InsertType = InsertType.Normal,
    Graph = "lcc",
    Silent = false,
};

List<Edge> edgeList = new List<Edge>();
Edge edge1 = new Edge()
{
    Schema = "follows",
    Uuid = 1,
    FromId = "U001",
    ToId = "U002",
    Values = new() { { "createdOn", new DateTime(2024, 5, 6) } },
};
Edge edge2 = new Edge()
{
    Schema = "follows",
    Uuid = 2,
    FromId = "U002",
    ToId = "U001",
    Values = new() { { "createdOn", new DateTime(2024, 5, 8) } },
};
Edge edge3 = new Edge()
{
    Schema = "purchased",
    Uuid = 3,
    FromId = "U002",
    ToId = "P001",
    Values = new() { { "qty", 1u } },
};

edgeList.Add(edge1);
edgeList.Add(edge2);
edgeList.Add(edge3);

var res = await ultipa.InsertEdgesBatchAuto(edgeList, insertRequestConfig);
Console.WriteLine(JsonConvert.SerializeObject(res));
```
<p tit="Output"></p> 
 
```
{"follows":{"Status":{"ErrorCode":0,"Msg":"insert edges succeed!","ClusterInfo":null},"Statistic":{"NodeAffected":0,"EdgeAffected":0,"TotalCost":0,"EngineCost":0},"Data":{"Uuids":[1,2],"Ids":[],"ErrorItem":{}}},"purchased":{"Status":{"ErrorCode":0,"Msg":"insert edges succeed!","ClusterInfo":null},"Statistic":{"NodeAffected":0,"EdgeAffected":0,"TotalCost":0,"EngineCost":0},"Data":{"Uuids":[3],"Ids":[],"ErrorItem":{}}}}
```

## Deletion

### DeleteNodes()

Deletes nodes that meet the given conditions from the current graph. It's important to note that deleting a node leads to the removal of all edges that are connected to it.

**Parameters:**

- `string`: The filtering condition to specify the nodes to delete.
- `InsertRequestConfig` (Optional): Configuration settings for the request. 

**Returns:**

- `<UqlResponse, List<Node>?>`: Result of the request. The `Response` object contains an alias `nodes` that holds all the deleted nodes when `InsertRequestConfig.Slient` is set to false.

```csharp
// Deletes one @user nodes whose name is 'Alice' from graphset 'lcc' and prints error code
// All edges attached to the deleted node are deleted as well

InsertRequestConfig insertRequestConfig = new InsertRequestConfig()
{
    InsertType = InsertType.Normal,
    Graph = "lcc",
    Silent = false,
};

var res = await ultipa.DeleteNodes("@user.name == 'Alice'", insertRequestConfig);
Console.WriteLine(res.Item1.Status.ErrorCode);
Console.WriteLine(JsonConvert.SerializeObject(res.Item2));
```
<p tit="Output"></p> 
 
```
Success
[{"Uuid":1,"Id":"U001","Schema":"user","Values":{}}]
```

### DeleteEdges()

Deletes edges that meet the given conditions from the current graph.

**Parameters:**

- `string`: The filtering condition to specify the edges to delete.
- `InsertRequestConfig` (Optional): Configuration settings for the request. 

**Returns:**

- `<UqlResponse, List<Edge>?>`: Result of the request. The `Response` object contains an alias `edges` that holds all the deleted edges when `InsertRequestConfig.Slient` is set to false.

```csharp
// Deletes all @purchased edges from graphset 'lcc' and prints error code

InsertRequestConfig insertRequestConfig = new InsertRequestConfig()
{
    InsertType = InsertType.Normal,
    Graph = "lcc",
    Silent = false,
};

var res = await ultipa.DeleteEdges("@purchased", insertRequestConfig);
Console.WriteLine(res.Item1.Status.ErrorCode);
Console.WriteLine(JsonConvert.SerializeObject(res.Item2));
```
<p tit="Output"></p> 
 
```
Success
[{"Uuid":3,"FromUuid":2,"ToUuid":3,"Id":"","FromId":"U002","ToId":"P001","Schema":"purchased","Values":{}}]
```

## Full Example
```csharp
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
        // URI example: Hosts=new[]{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"}
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

        // Insert Request configurations
        InsertRequestConfig insertRequestConfig = new InsertRequestConfig()
        {
            InsertType = InsertType.Normal,
            Graph = "lcc",
            Silent = false,
        };

       // Inserts two nodes into schema 'user' and one node into schema `product` in graphset 'lcc', prints error code and the insert reply
       var myPoint = new Point();
       myPoint.X = 23.63M;
       myPoint.Y = 104.25M;

       Node node1 = new Node()
       {
           Schema = "user",
           Uuid = 1,
           Id = "U001",
           Values = new()
           {
               { "name", "Alice" },
               { "age", 18 },
               { "score", 65.32M },
               { "birthday", new DateTime(1993, 5, 4) },
               { "location", myPoint },
               { "profile", new byte[] { 123 } },
               {
                   "interests",
                   new List<string>() { "tennis", "violin" }
               },
               {
                   "permissionCodes",
                   new HashSet<int> { 2004, 3025, 1025 }
               },
           },
       };

       Node node2 = new Node()
       {
           Schema = "user",
           Uuid = 2,
           Id = "U002",
           Values = new() { { "name", "Bob" } },
       };

       Node node3 = new Node()
       {
           Schema = "product",
           Uuid = 3,
           Id = "P001",
           Values = new() { { "name", "Wireless Earbud" }, { "price", 93.2F } },
       };

       List<Node> nodeList = new List<Node>();

       nodeList.Add(node1);
       nodeList.Add(node2);
       nodeList.Add(node3);

       var nodeInsert = await ultipa.InsertNodesBatchAuto(nodeList, insertRequestConfig);
       Console.WriteLine(JsonConvert.SerializeObject(nodeInsert));

       // Inserts two edges into schema 'follows' and one edge into schema 'purchased' in graphset 'lcc', prints error code and the insert reply

       List<Edge> edgeList = new List<Edge>();
       Edge edge1 = new Edge()
       {
           Schema = "follows",
           Uuid = 1,
           FromId = "U001",
           ToId = "U002",
           Values = new() { { "createdOn", new DateTime(2024, 5, 6) } },
       };
       Edge edge2 = new Edge()
       {
           Schema = "follows",
           Uuid = 2,
           FromId = "U002",
           ToId = "U001",
           Values = new() { { "createdOn", new DateTime(2024, 5, 8) } },
       };
       Edge edge3 = new Edge()
       {
           Schema = "purchased",
           Uuid = 3,
           FromId = "U002",
           ToId = "P001",
           Values = new() { { "qty", 1u } },
       };

       edgeList.Add(edge1);
       edgeList.Add(edge2);
       edgeList.Add(edge3);

       var edgeInsert = await ultipa.InsertEdgesBatchAuto(edgeList, insertRequestConfig);
       Console.WriteLine(JsonConvert.SerializeObject(edgeInsert));
   }
}
```
