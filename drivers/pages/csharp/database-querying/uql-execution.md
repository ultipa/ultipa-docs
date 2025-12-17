# UQL Execution

This section introduces the `Uql()` and `UqlStream()` methods on a `Connection` object for querying the database using UQL.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

> UQL (Ultipa Query Language) is the language designed for fully interacting with Ultipa graph databases. For detailed information on UQL, refer to the <a href="/docs/uql/">documentation</a>.

## Uql()

Executes a UQL query on the current graphset or the database and returns the result.

**Parameters:**

- `string`: The UQL query to be executed.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. 

<p tit= "C#" ></p> 
 
```c#
// Retrieves 5 @movie nodes in graphset 'miniCircle' and prints their name

RequestConfig requestConfig = new RequestConfig() { Graph = "miniCircle", UseMaster = true };

var res = await ultipa.Uql("find().nodes({@movie}) as n return n{*} limit 5", requestConfig);
var nodeList = res?.Alias("n")?.AsNodes();
foreach (var node in nodeList)
{
    Console.WriteLine(node.Values.GetValueOrDefault("name"));
}
```

<p tit= "Output" ></p> 

```java
The Shawshank Redemption
Farewell My Concubine
Léon: The Professional
Titanic
Life is Beautiful
```

For more examples, please refer to <a href="https://www.ultipa.com/doc/drivers/data-types-mapping-ultipa-and-csharp">Types Mapping Ultipa and C#</a>.

## UqlStream()

Executes a UQL query on the current graphset or the database and returns the result incrementally, allowing handling of large datasets without loading everything into memory at once.

**Parameters:**

- `string`: The UQL query to be executed.
- `UqlResponseStream`: Listener for the streaming process.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `void` 

<p tit= "C#" ></p> 
 
```c#
// Retrieves all 1-step paths in graphset 'miniCircle'
RequestConfig requestConfig = new RequestConfig() { Graph = "miniCircle", UseMaster = true };

var count = 0;
await ultipa.UqlStream(
    "n().e().n() as paths return paths{*}",
    new UqlResponseStream()
    {
        OnStart = () => Console.WriteLine("Start"),
        OnData = (
            resp =>
            {
                if (resp.Status.ErrorCode != ErrorCode.Success)
                {
                    Console.WriteLine(resp.Status.Msg);
                }
                var paths = resp.Get(0).AsPaths();
                count += paths.Count();

                Console.WriteLine($"Count ={count}");
                return true;
            }
        ),

        OnEnd = () => Console.WriteLine("End"),
    },
    requestConfig
);
```

<p tit= "Output" ></p> 

```java
Start
Count =  1390
End
```

## Full Example

<p tit= "C#" ></p> 

```c#
using System.Security.Cryptography.X509Certificates;
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
        RequestConfig requestConfig = new RequestConfig() { Graph = "miniCircle", UseMaster = true };

        // Retrieves 10 nodes and prints the _id and name property value of the first returned one
        var res = await ultipa.Uql(
            "find().nodes({@movie}) as n return n{*} limit 10",
            requestConfig
        );

        var nodeList = res?.Get(0).AsNodes();
        if (nodeList[0].Values.TryGetValue("name", out object? value))
        {
            Console.WriteLine(value);
        }
        Console.WriteLine(nodeList[0].Id);
    }
}
```
