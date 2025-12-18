# Graphset Management

This section introduces methods on a `Connection` object for managing graphsets in the database.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## ShowGraph()

Retrieves all graphsets from the database.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<GraphSet>`: The list of all graphsets in the database.

<p tit="C#" ></p> 
 
```c#
// Retrieves all graphsets and prints the names of the those who have over 2000 edges

var graphsetList = await ultipa.ShowGraph();

foreach (var graph in graphsetList)
{
    if (graph.TotalEdges > 2000)
    {
        Console.WriteLine(graph.Name);
    }
}
```
<p tit="Output"></p> 
 
```java
Display_Ad_Click
ERP_DATA2
wikiKG
```

## GetGraph()

Retrieves one graphset from the database by its name.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `GraphSet`: The retrieved graphset.

<p tit="C#" ></p> 
 
```c#
// Retrieves the graphsets named 'wikiKG' and prints all its information

var graph = await ultipa.GetGraph("wikiKG");
Console.WriteLine(
    $"ID: {graph.Id}\n"
        + $"Name: {graph.Name}\n"
        + $"TotalNodes: {graph.TotalNodes}\n"
        + $"TotalEdges: {graph.TotalEdges}\n"
        + $"Status: {graph.Status}\n"
        + $"Description: {graph.Desc}"
);
```

<p tit="Output"></p> 
 
```java
True
ID: 13844
Name: wikiKG
TotalNodes: 44449
TotalEdges: 167799
Status: MOUNTED
Description:
```

## CreateGraph()

Creates a new graphset in the database.

**Parameters:**

- `GraphSet`: The graphset to be created; the field `name` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit="C#" ></p> 
 
```c#
// Creates one graphset and prints the error code

var graph = new GraphSet();
graph.Name = "testCSharpSDK";
graph.Desc = "Description for testCSharpSDK";

var resp = await ultipa.CreateGraph(graph);
Console.WriteLine(resp.Status.ErrorCode);
```

A new graphset `testCSharpSDK` is created in the database, and the driver prints:

<p tit="Output"></p> 
 
```java
Success
```

## CreateGraphIfNotExist()

Creates a new graphset in the database, handling cases where the given graphset name already exists by ignoring the error.

**Parameters:**

- `GraphSet`: The graphset to be created; the field `name` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.
- `bool`: Whether the graphset already exists.

<p tit="C#" ></p> 

```c#
// Creates one graphset and prints the error code

var graph = new GraphSet();
graph.Name = "testCSharpSDK";
graph.Desc = "Description for testCSharpSDK";

var resp1 = await ultipa.CreateGraphIfNotExist(graph);
Console.WriteLine("Graph already exists: " + resp1.Item2);
Console.WriteLine(
    "First creation: " + (resp1.Item1 != null ? resp1.Item1.Status.ErrorCode : "null")
);

// Attempts to create the same graphset again and prints the error code

var resp2 = await ultipa.CreateGraphIfNotExist(graph);
Console.WriteLine("Graph already exists: " + resp2.Item2);
Console.WriteLine(
    "Second creation: " + (resp2.Item1 != null ? resp2.Item1.Status.ErrorCode : "Failed")
);
```

A new graphset `testCSharpSDK` is created in the database, and the driver prints:

<p tit="Output"></p> 
 
```java
Graph already exists: False
First creation: Success
Graph already exists: True
Second creation: Failed
```

## DropGraph()

Drops one graphset from the database by its name.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit="C#" ></p> 

```c#
// Creates one graphset and then drops it, prints the result

var graph = new GraphSet();
graph.Name = "testCSharpSDK";
graph.Desc = "Description for testCSharpSDK";

var newGraph = await ultipa.CreateGraph(graph);
Console.WriteLine("Creation: " + newGraph.Status.ErrorCode);

Thread.Sleep(2000);

var dropIt = await ultipa.DropGraph("testCSharpSDK");
Console.WriteLine(JsonConvert.SerializeObject(dropIt));
```

<p tit="Output"></p> 

```java
Creation: Success
{"UqlReply":{"Status":{"ErrorCode":0,"Msg":"","ClusterInfo":null},"TotalTimeCost":0,"EngineTimeCost":0,"Alias":[],"Paths":[],"Nodes":[],"Edges":[],"Attrs":[],"Graphs":[],"Tables":[],"Statistics":null,"ExplainPlan":null},"Status":{"ErrorCode":0,"Msg":"","ClusterInfo":null},"Statistic":{"NodeAffected":0,"EdgeAffected":0,"TotalCost":6,"EngineCost":0},"Explain":[]}
```

## AlterGraph()

Alters the name and description of one existing graphset in the database by its name.

**Parameters:**

- `GraphSet`: The existing graphset to be altered; the field `name` must be set.
- `GraphSet`: The new configuration for the existing graphset; either or both of the fields `name` and `description` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit="C#" ></p> 

```c#
// Renames the graphset 'testCSharpSDK' to 'newGraph', sets a description for it, and prints the result

var graph1 = new GraphSet();
graph1.Name = "testCSharpSDK";
var newGraph = await ultipa.CreateGraph(graph1);

var graph2 = new GraphSet();
graph2.Name = "newGraph";
graph2.Desc = "The graphset is altered";

var alterIt = await ultipa.AlterGraph(graph1, graph2);
Console.WriteLine(JsonConvert.SerializeObject(alterIt));
```

<p tit="Output"></p> 

```java
{"UqlReply":{"Status":{"ErrorCode":0,"Msg":"","ClusterInfo":null},"TotalTimeCost":0,"EngineTimeCost":0,"Alias":[],"Paths":[],"Nodes":[],"Edges":[],"Attrs":[],"Graphs":[],"Tables":[],"Statistics":null,"ExplainPlan":null},"Status":{"ErrorCode":0,"Msg":"","ClusterInfo":null},"Statistic":{"NodeAffected":0,"EdgeAffected":0,"TotalCost":1,"EngineCost":0},"Explain":[]}
```

## Truncate()

Truncates (Deletes) the specified nodes or edges in the given graphset or truncates the entire graphset. Note that truncating nodes will cause the deletion of edges attached to those affected nodes. The truncating operation retains the definition of schemas and properties while deleting the data.

**Parameters:**

- `TruncateParams`: The object to truncate; the field `graphName` must be set, `schema` and `DbType` are optional, but if either `schema` or `DbType` is set, the other must also be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit="C#" ></p> 

```c#
// Truncates @user nodes in the graphset 'myGraph_1' and prints the error code

var truncate1 = new GraphAPI.TruncateParams()
{
    graphName = "myGraph_1",
    schema = "user",
    DbType = DBType.Dbnode,
};
var res1 = await ultipa.Truncate(truncate1);
Console.WriteLine(res1.Status.ErrorCode);

// Truncates all edges in the graphset 'myGraph_2' and prints the error code    

var truncate2 = new GraphAPI.TruncateParams()
{
    graphName = "myGraph_2",
    schema = "*",
    DbType = DBType.Dbedge,
};
var res2 = await ultipa.Truncate(truncate2);
Console.WriteLine(res2.Status.ErrorCode); 

// Truncates the graphset 'myGraph_3' and prints the error code

var truncate3 = new GraphAPI.TruncateParams() { graphName = "myGraph_3" };
var res3 = await ultipa.Truncate(truncate3);
Console.WriteLine(res3.Status.ErrorCode);
```

<p tit="Output"></p> 

```java
Success
Success
Success
```

## CompactGraph()

Compacts a graphset by clearing its invalid and redundant data on the server disk. Valid data will not be affected.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit="C#" ></p> 

```c#
// Compacts the graphset 'miniCircle' and prints the error code

var res = await ultipa.CompactGraph("miniCircle");
Console.WriteLine(res.Status.ErrorCode);
```

<p tit="Output"></p> 

```java
Success
```

## HasGraph()

Checks the existence of a graphset in the database by its name.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `bool`: Result of the request.

<p tit="C#" ></p> 

```c#
// Checks the existence of graphset 'miniCircle' and prints the result

var res = await ultipa.HasGraph("miniCircle");
Console.WriteLine("Graph exists: " + res);
```

<p tit="Output"></p> 

```java
Graph exists: True
```

## UnmountGraph()

Unmounts a graphset to save database memory.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit="C#" ></p> 

```c#
// / Unmounts the graphsets 'miniCircle' and prints the result

var res = await ultipa.UnMountGraph("miniCircle");
Console.WriteLine(res.Status.ErrorCode);
```

<p tit="Output"></p> 

```java
Success
```

## MountGraph()

Mounts a graphset to the database memory.

**Parameters:**

- `string`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UqlResponse`: Result of the request.

<p tit="C#" ></p> 

```c#
// Mounts the graphsets 'miniCircle' and prints the result

var res = await ultipa.MountGraph("miniCircle");
Console.WriteLine(res.Status.ErrorCode);
```

<p tit="Output"></p> 

```java
Success
```

## Full Example

<p tit="C#" ></p> 

```c#
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
        //URI example: Hosts=new[]{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"}
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
        RequestConfig requestConfig = new RequestConfig() { UseMaster = true };
  

        // Creates new graphset 'testCSharpSDK'  

        var graph = new GraphSet();
        graph.Name = "testCSharpSDK";
        graph.Desc = "Description for testCSharpSDK";

        var newGraph = await ultipa.CreateGraph(graph);
        Console.WriteLine("Creation: " + newGraph.Status.ErrorCode);

        Thread.Sleep(2000);

        // Drops the graphset 'testCSharpSDK' just created
        var dropIt = await ultipa.DropGraph("testCSharpSDK");
        Console.WriteLine(dropIt.Status.ErrorCode);

  }
}
```

