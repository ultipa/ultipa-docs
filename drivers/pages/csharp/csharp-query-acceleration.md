## Query Acceleration

This section introduces methods on a `Connection` object for managing the LTE status for properties, and their indexes and full-text indexes. These mechanisms can be employed to <a target="_blank" href="/docs/uql/indexing-and-caching">accelerate queries</a>.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## LTE

### lte()

Loads one custom property of nodes or edges to the computing engine for query acceleration.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string` (Optional): Name of the schema, write `*` to specify all schemas.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request. 

```csharp
// Loads the edge property @relatesTo.type to engine in graphset 'UltipaTeam' and prints error code

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var res = await ultipa.Lte(DBType.Dbedge, "relatesTo", "type", requestConfig);
Console.WriteLine(res.Status.ErrorCode);
Thread.Sleep(3000);
var prop = await ultipa.GetEdgeProperty("relatesTo", "type", requestConfig);
Console.WriteLine("LTE status of the property: " + prop.Lte);
```

<p tit="Output"></p> 
 
```
Success
LTE status of the property: True
```

### ufe()

Unloads one custom property of nodes or edges from the computing engine to save the memory.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string` (Optional): Name of the schema, write `*` to specify all schemas.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request. 

```csharp
// Unloads the edge property @relatesTo.type from engine in graphset 'UltipaTeam' and prints error code and whether it's LTE-ed

RequestConfig requestConfig = new RequestConfig() { Graph = "UltipaTeam" };

var res = await ultipa.Ufe(DBType.Dbedge, "relatesTo", "type", requestConfig);
Console.WriteLine(res.Status.ErrorCode);
Thread.Sleep(3000);
var prop = await ultipa.GetEdgeProperty("relatesTo", "type", requestConfig);
Console.WriteLine("LTE status of the property: " + prop.Lte);
```

<p tit="Output"></p> 
 
```
Success
LTE status of the property: False
```

## Index

### ShowIndex()

Retrieves all indexes of node and edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all indexes retrieved in the current graphset.

```csharp
// Retrieves indexes in graphset 'Ad_Click' and prints their information

RequestConfig requestConfig = new RequestConfig() { Graph = "Ad_Click", UseMaster = true };

var res = await ultipa.ShowIndex(requestConfig);
foreach (var item in res)
{
    Console.WriteLine(JsonConvert.SerializeObject(item));
}
```

<p tit="Output"></p> 
 
```
{"Schema":"user","Name":"shopping_level","Properties":"shopping_level","Status":"done","size":"4608315"}
{"Schema":"ad","Name":"price","Properties":"price","Status":"done","size":"7828488"}
{"Schema":"clicks","Name":"time","Properties":"time","Status":"done","size":"12809771"}
```

### ShowNodeIndex()

Retrieves all indexes of node properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all indexes retrieved in the current graphset.

```csharp
// Retrieves node indexes in graphset 'Ad_Click' and prints their information

RequestConfig requestConfig = new RequestConfig() { Graph = "Ad_Click", UseMaster = true };

var res = await ultipa.ShowNodeIndex(requestConfig);
foreach (var item in res)
{
    Console.WriteLine(JsonConvert.SerializeObject(item));
}
```

<p tit="Output"></p> 
 
```
{"Schema":"user","Name":"shopping_level","Properties":"shopping_level","Status":"done","size":"4608315"}
{"Schema":"ad","Name":"price","Properties":"price","Status":"done","size":"7828488"}
```

### ShowEdgeIndex()

Retrieves all indexes of edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all indexes retrieved in the current graphset.

```csharp
// Retrieves edge indexes in graphset 'Ad_Click' and prints their information

RequestConfig requestConfig = new RequestConfig() { Graph = "Ad_Click", UseMaster = true };

var res = await ultipa.ShowEdgeIndex(requestConfig);
foreach (var item in res)
{
    Console.WriteLine(JsonConvert.SerializeObject(item));
}
```

<p tit="Output"></p> 
 
```
{"Schema":"clicks","Name":"time","Properties":"time","Status":"done","size":"12809771"}
```

### CreateIndex()

Creates a new index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string` (Optional): Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request. 

```csharp
// Creates indexes for all node properties 'name' in graphset 'Ad_Click' and prints the error code

RequestConfig requestConfig = new RequestConfig() { Graph = "Ad_Click", UseMaster = true };

var res = await ultipa.CreateIndex(DBType.Dbnode, "name", requestConfig);
Console.WriteLine(res.Status.ErrorCode);
```

<p tit="Output"></p> 
 
```
Success
```

### DropIndex()

Drops indexes in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string` (Optional): Name of the schema.
- `string`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request. 

```csharp
// Drops the index of the node property @ad.name in graphset 'Ad_Click' and prints the error code

RequestConfig requestConfig = new RequestConfig() { Graph = "Ad_Click", UseMaster = true };

var res = await ultipa.DropIndex(DBType.Dbnode, "ad", "name", requestConfig);
Console.WriteLine(res.Status.ErrorCode);
```

<p tit="Output"></p> 
 
```
Success
```

## Full-text

### ShowFulltext()

Retrieves all full-text indexes of node and edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all indexes retrieved in the current graphset.

```csharp
// Retrieves the first full-text index returned in graphset 'miniCircle' and prints its information

RequestConfig requestConfig = new RequestConfig() { Graph = "miniCircle" };

var res = await ultipa.ShowFulltext(requestConfig);
Console.WriteLine(JsonConvert.SerializeObject(res[0]));
```

<p tit="Output"></p> 
 
```
{"Schema":"movie","Name":"genreFull","Properties":"genre","Status":"done","size":null}
```

### ShowNodeFulltext()

Retrieves all full-text indexes of node properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all full-text indexes of node properties retrieved in the current graphset.

```csharp
// Retrieves the first node full-text index of node properties returned in graphset 'miniCircle' and prints its information

RequestConfig requestConfig = new RequestConfig() { Graph = "miniCircle" };

var res = await ultipa.ShowNodeFulltext(requestConfig);
Console.WriteLine(JsonConvert.SerializeObject(res[0]));
```

<p tit="Output"></p> 
 
```
{"Schema":"movie","Name":"genreFull","Properties":"genre","Status":"done","size":null}
```

### ShowEdgeFulltext()

Retrieves all full-text indexes of edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all edge full-text indexes of edge properties retrieved in the current graphset.

```csharp
// Retrieves the first edge full-text index of edge properties returned in graphset 'miniCircle' and prints its information

RequestConfig requestConfig = new RequestConfig() { Graph = "miniCircle" };

var res = await ultipa.ShowEdgeFulltext(requestConfig);
Console.WriteLine(JsonConvert.SerializeObject(res[0]));
```

<p tit="Output"></p> 
 
```
{"Schema":"review","Name":"nameFull","Properties":"content","Status":"done","size":null}
```

### CreateFulltext()

Creates a new full-text index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the schema.
- `string`: Name of the property.
- `string`: Name of the full-text index.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request. 

```csharp
// Creates full-text index called 'movieName' for the property @movie.name in graphset 'miniCircle' and prints the error code
RequestConfig requestConfig = new RequestConfig() { Graph = "miniCircle" };

var res = await ultipa.CreateFulltext(
    DBType.Dbnode,
    "movie",
    "name",
    "movieName",
    requestConfig
);
Console.WriteLine(res.Status.ErrorCode);
```

<p tit="Output"></p> 
 
```
Success
```

### DropFulltext()

Drops a full-text index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `string`: Name of the full-text index.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request. 

```csharp
// Drops the node full-index 'movieName' in graphset 'miniCircle' and prints the error code
RequestConfig requestConfig = new RequestConfig() { Graph = "miniCircle" };

var res = await ultipa.DropFulltext(DBType.Dbnode, "movieName", requestConfig);
Console.WriteLine(res.Status.ErrorCode);
```

<p tit="Output"></p> 
 
```
Success
```

## Full Example

```csharp

using System.Security.Cryptography.X509Certificates;
using System.Threading;
using System.Xml.Linq;
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
       
        // Request configurations
        RequestConfig requestConfig = new RequestConfig()
        {
            Graph = "Ad_Click",
            UseMaster = true,
        };

        // Retrieves all indexes in graphset 'Ad_Click' and prints their information
        var res = await ultipa.ShowIndex(requestConfig);
        foreach (var item in res)
        {
            Console.WriteLine(JsonConvert.SerializeObject(item));
        }
    }
}
```
