# Others

This section introduces methods on a `Connection` object for checking the database server statistics and the driver connection.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Stats()

Retrieves database server statistics.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `DatabaseStats`: The retrieved server statistics.

<p tit= "C#" ></p> 
 
```c#
var res = await ultipa.Stats();
Console.WriteLine("CPU usage: " + res.CpuUsage);
Console.WriteLine("Memory usage: " + res.MemUsage);
Console.WriteLine("Expiration date: " + res.ExpiredDate);
Console.WriteLine("CPU cores: " + res.CpuCores);
Console.WriteLine("Company: " + res.Company);
Console.WriteLine("Server type: " + res.ServerType);
Console.WriteLine("Version: " + res.Version);
```

<p tit= "Output" ></p> 
 
```java
CPU usage: 11.535199
Memory usage: 10702.644531
Expiration date: Thu Dec 26 23:59:59 2024
CPU cores: 80
Company: ultipa
Server type: CT
Version: htap_beta.4.5.7-b4.5.0-tv-ui
```

## Test()

Tests driver and database server connection.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `bool`: Result of the request.

<p tit= "C#" ></p> 
 
```c#
var res = ultipa.Test();
Console.WriteLine("Test succeeds: " + res);
```

<p tit= "Output" ></p> 
 
```java
Test succeeds: True
```

## Full Example

<p tit= "C#" ></p> 

```c#
using System.Security.Cryptography.X509Certificates;
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

        // Request configurations
        RequestConfig requestConfig = new RequestConfig() { UseMaster = true };
        
        // Test connection
        var isSuccess = ultipa.Test();
        Console.WriteLine("Test succeeds: " + isSuccess);
    }
}
```
null
