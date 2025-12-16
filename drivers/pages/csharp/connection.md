# Connection

After <a href="https://www.ultipa.com/doc/drivers/csharp-installation">installing the Ultipa C# SDK</a> and setting up a running Ultipa instance, you should be able to connect your application to the Ultipa graph database.

## Code Configuration Connection

Connection to Ultipa can be established by using `UltipaConfig`, which specifies the information of the connection needed.

### Connect to a Cluster

<p tit= "C#" ></p> 

```c#
using UltipaSharp;
using UltipaSharp.configuration;

class Program
{
    static void Main(string[] args)
    {
        var ultipa = new Ultipa(new UltipaConfig()
        {
            Hosts = new[] { "192.168.1.85:60061", "192.168.1.86:60061", "192.168.1.87:60061" },
            CurrentGraph = "default",
            Username = "***",
            Password = "***",
        });
        Console.WriteLine("Connected to the graph database!");
    }
}
```

### Connect to Ultipa Cloud with TSL

<p tit= "C#" ></p> 

```c#
using UltipaSharp;
using UltipaSharp.configuration;
using UltipaSharp.connection;

class Program
{
   
    static void Main(string[] args)
    {
        var ultipa = new Ultipa(new UltipaConfig()
        {
            Hosts = new[]{ "xaznryn5s.us-east-1.cloud.ultipa.com:60010" },
            CurrentGraph = "myGraph",
            Username = "***",
            Password = "***",
            Protocol = "***"
        });

        Console.WriteLine("Connected to Ultipa Cloud!");

    }

}
```

## Configuration Items

Below are all the configuration items available for `UltipaConfig`:

| <div table-width="20">Item</div> | <div table-width="12">Type</div> | <div table-width="8">Default</div> | Description |
|  ----  | ----  | ----  | ---- |
| `Hosts` | string[] |  | Database host addresses or URI (excluding `https://` or `http://`). For clusters, multiple addresses are separated by commas. Required. |
| `Username` | string |  | Username of the host authentication. Required. |
| `Password` | string |  | Password of the host authentication. Required. |
| `Crt` | char[] |  | Certificate file for encrypted messages. | 
| `PasswordEncrypt` | enum | MD5 | Password encryption method of the driver. Supports `MD5`, `LDAP` and `NOTHING`. `NOTHING` is used when the content is blank. |
| `CurrentGraph` | string | default | Name of the current graphset. | 
| `Protocol` | string | http | Protocol type. | 
| `Consistency` | bool | false | Whether to use the leader node to ensure consistency read. |
| `ClusterId` | string |  | Cluster ID of the nameserver. | 
| `MaxRecvSize` | int | 64 |  Maximum size in megabytes when receiving data. |
| `Timeout` | uint | 15u | Request timeout threshold in seconds. |
| `Debug` | bool | false | Whether to use the debug mode. | 
| `HeartBeat` | int | 0 | Heartbeat interval in milliseconds for all instances, set 0 to disable heartbeat. |
