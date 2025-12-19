## Server Statistics

This section introduce the method on a `Connection` object for checking the database server statistics.

## Stats()

Retrieves database server statistics.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `DatabaseStats`: The retrieved server statistics.

```csharp
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
        // URI example: Hosts=new[]{"mqj4zouys.us-east-1.cloud.ultipa.com:60010"}
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
        
        // Server Statistics
        var res = await ultipa.Stats();
        Console.WriteLine("CPU usage: " + res.CpuUsage);
        Console.WriteLine("Memory usage: " + res.MemUsage);
        Console.WriteLine("Expiration date: " + res.ExpiredDate);
        Console.WriteLine("CPU cores: " + res.CpuCores);
        Console.WriteLine("Company: " + res.Company);
        Console.WriteLine("Server type: " + res.ServerType);
        Console.WriteLine("Version: " + res.Version);      
    }
}
```

<p tit="Output"></p> 
 
```
CPU usage: 11.535199
Memory usage: 10702.644531
Expiration date: Thu Dec 26 23:59:59 2024
CPU cores: 80
Company: ultipa
Server type: CT
Version: htap_beta.4.5.7-b4.5.0-tv-ui
```
