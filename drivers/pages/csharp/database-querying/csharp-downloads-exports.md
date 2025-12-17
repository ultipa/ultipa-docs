# Downloads and Exports

This section introduces methods on a `Connection` object for downloading algorithm result files and exporting nodes and edges from a graphset. 

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## DownloadAlgoResultFile()

Downloads one result file from an algorithm task in the current graph.
 
**Parameters:**

- `int`: ID of the algorithm task that generated the file.
- `string`: Name of the file.
- `AlgoAPI.OnData`: Function that receives the request result.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
RequestConfig requestConfig = new RequestConfig()
{
    UseMaster = true,
    Graph = "miniCircle",
};

// Runs the Louvain algorithm in graphset 'miniCircle' and prints the task ID

var res = await ultipa.Uql(
    "algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})",
    requestConfig
);

var task = res.Alias("_task").AsTable();
var taskId = int.Parse((string)task.Rows[0][0]);
var filename = "communityID";

Thread.Sleep(2000);
var stream = new MemoryStream();

Console.WriteLine("TaskId :" + taskId);
Console.WriteLine("Content of the file '" + filename + "'");
await ultipa.DownloadAlgoResultFile(
    taskId,
    filename,
    (reply, filename) =>
    {
        stream.Write(reply.Chunk.ToByteArray());
    }
);

var bs = stream.ToArray();
Console.Write(Encoding.UTF8.GetString(bs));
```

<p tit= "Output" ></p> 
 
```java
TaskId :77218
Content of the file 'communityID'
```

## DownloadAllAlgoResultFile()

Downloads all result files from an algorithm task in the current graph.
 
**Parameters:**

- `int`: ID of the algorithm task that generated the file(s).
- `AlgoAPI.OnData`: Function that receives the request result.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
// Runs the Louvain algorithm in graphset 'miniCircle' and prints the task ID

RequestConfig requestConfig = new RequestConfig() { UseMaster = true, Graph = "miniCircle" };

{
    var res = await ultipa.Uql(
        "algo(louvain).params({phase1_loop_num: 20, min_modularity_increase: 0.001}).write({file:{filename_community_id: 'communityID', filename_ids: 'ids', filename_num: 'num'}})",
        requestConfig
    );

    var task = res.Alias("_task").AsTable();
    var taskId = int.Parse((string)task.Rows[0][0]);
    Thread.Sleep(2000);

    Console.WriteLine("TaskId :" + taskId);
    var streams = new Dictionary<string, MemoryStream>();
    await ultipa.DownloadAlgoAllResultFile(
        taskId,
        (reply, filename) =>
        {
            if (!streams.ContainsKey(filename))
            {
                streams[filename] = new MemoryStream();
            }

            streams[filename].Write(reply.Chunk.ToByteArray());
        }
    );

    foreach (var kv in streams)
    {
        var bs = kv.Value.ToArray();
        Console.WriteLine("Content of the file'" + kv.Key + "'");
        Console.WriteLine("Download complete");
    }
}
```

<p tit= "Output" ></p> 
 
```java
TaskId :79667
Content of the file 'communityID'
Download complete
Content of the file 'ids'
Download complete
Content of the file 'num'
Download complete
```

## Export()

Exports nodes and edges from the current graph.

**Parameters:**

- `ExportRequest`: Configurations for the export request, including `DbType:ULTIPA.DBType`, `Schema:string`, `Limit:number` and `selectProperties:List<string>`.
- `ExportAPI.OnData`: Function that receives the request result.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `ExportReply`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
// Exports 10 nodes of schema 'account' with selected properties in graphset 'miniCircle' and prints the result
RequestConfig requestConfig = new RequestConfig()
{
    UseMaster = true,
    Graph = "miniCircle",
};

ExportRequest exportConfig = new ExportRequest()
{
    Schema = "account",
    Limit = 10,
    DbType = DBType.Dbnode,
    SelectProperties = { "name", "year" },
};

await ultipa.Export(
    exportConfig,
    (nodes, edges) =>
    {
        foreach (var node in nodes)
        {
            Console.WriteLine(JsonConvert.SerializeObject(node));
        }
    },
    requestConfig
);
```

<p tit= "Output" ></p> 
 
```java
{"Uuid":1,"Id":"ULTIPA8000000000000001","Schema":"account","Values":{"name":"Yu78","year":1978}}
{"Uuid":2,"Id":"ULTIPA8000000000000002","Schema":"account","Values":{"name":"jibber-jabber","year":1989}}
{"Uuid":3,"Id":"ULTIPA8000000000000003","Schema":"account","Values":{"name":"mochaeach","year":1982}}
{"Uuid":4,"Id":"ULTIPA8000000000000004","Schema":"account","Values":{"name":"Win-win0","year":2007}}
{"Uuid":5,"Id":"ULTIPA8000000000000005","Schema":"account","Values":{"name":"kevinh","year":1973}}
{"Uuid":6,"Id":"ULTIPA8000000000000006","Schema":"account","Values":{"name":"alexyhel","year":1974}}
{"Uuid":7,"Id":"ULTIPA8000000000000007","Schema":"account","Values":{"name":"hooj","year":1986}}
{"Uuid":8,"Id":"ULTIPA8000000000000008","Schema":"account","Values":{"name":"vv67","year":1990}}
{"Uuid":9,"Id":"ULTIPA8000000000000009","Schema":"account","Values":{"name":"95smith","year":1988}}
{"Uuid":10,"Id":"ULTIPA800000000000000A","Schema":"account","Values":{"name":"jo","year":1992}}
```

## Full Example

<p tit= "C#" ></p> 

```c#
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
        RequestConfig requestConfig = new RequestConfig()
        {
            UseMaster = true,
            Graph = "miniCircle",
        };

        // Exports 10 nodes of schema 'account' with selected properties in graphset 'miniCircle' and prints the result
        ExportRequest exportConfig = new ExportRequest();
        exportConfig.Schema = "account";
        exportConfig.Limit = 10;
        exportConfig.DbType = DBType.Dbnode;
        exportConfig.SelectProperties = ["_id", "_uuid", "name", "year"];
        await ultipa.Export(
            exportConfig,
            (nodes, edges) =>
            {
                foreach (var node in nodes)
                {
                    Console.WriteLine(JsonConvert.SerializeObject(node));
                }
            },
            requestConfig
        );
    }
}
```
