# Request Configuration

All querying methods support an optional request configuration parameter (`RequestConfig` or `InsertRequestConfig`) to customize the behavior of requests made to the database. This parameter allows you to specify various settings, such as graphset name, timeout, and host, to tailor your requests according to your needs.

# RequestConfig

`RequestConfig` defines the information needed when sending non-insert type of requests to the database.

```csharp
using Newtonsoft.Json;
using UltipaSharp;
using UltipaSharp.configuration;
using UltipaSharp.connection;
using Logger = UltipaSharp.utils.Logger;
using Microsoft.Extensions.Logging;

class Program
{
   
    static async Task Main(string[] args)
    {
        var ultipa = new Ultipa(new UltipaConfig()
        {
            //URI示例: Hosts = new[]{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"}
            Hosts = new[]{ "192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061" },
            CurrentGraph = "default",
            Username = "***",
            Password = "***",
        });

        Console.WriteLine("Connected to the graph database!");

        var requestConfig = new RequestConfig()
        {
            Graph = "miniCircle",
            UseMaster = true,
            RequestType = RequestType.Normal
        };

        var res = await ultipa.Uql("find().nodes() return nodes{*} limit 2", requestConfig);

        Logger.Global.LogInformation(JsonConvert.SerializeObject(res?.Alias("nodes")?.AsNodes()));
    }
   
}
```

`RequestConfig` has the following fields:

|  <div table-width="16">Item</div> | <div table-width="14">Type</div> | <div table-width="17">Default Value</div> |  Description   |
|  ----  | ----  | ----  | ---- |
| `Graph` | string? |  | Name of the graph to use. If not set, use the `CurrentGraph` configured when establishing the connection. | 
| `Timeout` | uint? |  | Request timeout threshold in seconds. |
| `ClusterId` | string? |  | Specifies the cluster to use. | 
| `Host` | string? |  | Sends the request to a designated host node, or to a random host node if not set. |
| `UseMaster` | bool | false | Sends the request to the leader node to guarantee consistency read if set to true. |
| `UseControl` | bool | false | Sends the request to the control node if set to true. |
| `RequestType` | RequestType | RequestType.Normal | Sends the requset to a node according to the request type: <br>`RequestType.Write`: to leader node <br>`RequestType.Task`: to algo<br>`RequestType.Normal`: to a random host  |
| `Uql` | string? |  | UQL for internal program | 
| `Timezone` | string? |  | The time zone to use. |
| `TimezoneOffset` | int? |  | The amount of time that the time zone in use differs from UTC in seconds. |
| `ThreadNumber` | int? |  | Number of threads. |

## InsertRequestConfig

`InsertRequestConfig` defines the settings needed when sending data insertion or deletion requests to the database.

```csharp
using Newtonsoft.Json;
using UltipaSharp;
using UltipaSharp.configuration;
using UltipaSharp.connection;
using Logger = UltipaSharp.utils.Logger;
using Microsoft.Extensions.Logging;
using UltipaService;
using UltipaSharp.structs;
using Property = UltipaSharp.structs.Property;
using Schema = UltipaSharp.structs.Schema;

class Program
{
   
    static void Main(string[] args)
    {
        var ultipa = new Ultipa(new UltipaConfig()
        {
            Hosts = new[]{ "192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061"  },
            Username = "***",
            Password = "***",
        });

        Console.WriteLine("Connected to the graph database!");


        var schema = new Schema()
        {
            Name = "User",
            DbType = DBType.Dbnode,
            Properties = new()
            {
                new ()
                {
                    Name = "name",
                    Type = PropertyType.String,
                },
                new(){
                    Name = "age",
                    Type = PropertyType.Int32
                },
                new()
                {
                    Name = "birth",
                    Type = PropertyType.Datetime
                }
            }
        };
        var nodes = new List<Node>()
        {
            new()
            {
                Id = "C#1",
                Schema = schema.Name,
                Values =
                new (){ 
                    {"name", "name1"},
                    {"age", 28},
                    {"birth", new DateTime(1989,9,12)}
                }
            }
        };
        // Specifies 'test' as the target graphset and sets the insert mode to OVERWRITE
        var insertConfig = new InsertRequestConfig()
        {
           Graph = "test",
           InsertType = InsertType.Overwrite,
        };
        var res = ultipa.InsertNodesBatchBySchema(schema,nodes,insertConfig);
        
        Logger.Global.LogInformation(JsonConvert.SerializeObject(res));
    }
   
}
```

`InsertRequestConfig` has the following fields:

|  <div table-width="16">Item</div> | <div table-width="14">Type</div> | <div table-width="17">Default Value</div> |  Description   |
|  ----  | ----  | ----  | ---- |
| `Graph` | string? |  | Name of the graph to use. If not set, use the `CurrentGraph` configured when establishing the connection. | 
| `Timeout` | uint? |  | Request timeout threshold in seconds. |
| `ClusterId` | string? |  | Specifies the cluster to use. | 
| `Host` | string? |  | Sends the request to a designated host node, or to a random host node if not set. |
| `UseMaster` | bool | false | Sends the request to the leader node to guarantee consistency read if set to true. |
| `UseControl` | bool | false | Sends the request to the control node if set to true. |
| `RequestType` | RequestType | RequestType.Normal | Sends the requset to a node according to the request type: <br>`RequestType.Write`: to leader node <br>`RequestType.Task`: to algo<br>`RequestType.Normal`: to a random host  |
| `Uql` | string? |  | UQL for internal program | 
| `Timezone` | string? |  | The time zone to use. |
| `TimezoneOffset` | int? |  | The amount of time that the time zone in use differs from UTC in seconds. |
| `ThreadNumber` | int? |  | Number of threads. |
| `InsertType` | UltipaService.InsertType | InsertType.Normal | Insert mode: `InsertType.Normal`, `InsertType.Overwrite`, `InsertType.Upsert`. |
| `CreateNodeIfNotExist` | bool | true | Whether to create start/end nodes of an edge if the end nodes do not exist in the graph. |
| `Silent` | bool | true | Whether to keep slient after success insertion, i.e., whether to return the inserted nodes or edges. |
