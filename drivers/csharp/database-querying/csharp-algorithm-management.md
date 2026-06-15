# Algorithm Management

This section introduces methods on a `Connection` object for managing <a href="/docs/graph-analytics-algorithms">Ultipa graph algorithms</a> and custom algorithms (EXTA) in the instance.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Ultipa Graph Algorithms

### ShowAlgo()

Retrieves all Ultipa graph algorithms installed in the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Algo>`: The list of all algorithms retrieved.

```csharp
// Retrieves all Ultipa graph algorithms installed and prints the information of the first returned one

var res = await ultipa.ShowAlgo();
Console.WriteLine(JsonConvert.SerializeObject(res[0].Params));
```
<p tit="Output"></p> 
 
```
"{\"name\":\"louvain\",\"description\":\"louvain\",\"version\":\"1.0.4\",\"parameters\":{\"edge_schema_property\":\"optinal,default 1 for each edge if absent\",\"phase1_loop_num\":\"size_t,required\",\"min_modularity_increase\":\"float,required\",\"limit\":\"optional,-1 for all results, >=0 partial results\",\"order\":\"optional, asc or desc, case_unsensitive, only work for 'community:id/count' mode\"},\"write_to_db_parameters\":{\"property\":\"set write back property name for each schema and nodes\"},\"write_to_file_parameters\":{\"filename1\":\"id1:community\",\"filename2\":\"community1: id1,id2...\",\"filename3\":\"community1: count\"},\"write_to_stats_parameters\":{\"enable\":\"0:no stats, 1:enable stats(count of communities)\"},\"write_to_client_normal_parameters\":{\"mode\":\"1:<id1:community>   2:<community1:count>\"},\"write_to_client_stream_parameters\":{\"mode\":\"1:<id1:community>   2:<community1:count>\"},\"result_opt\":\"59\"}"
```

### InstallAlgo()

Installs an Ultipa graph algorithm in the instance.

**Parameters:**

- `string`: File path of the algo installation package (*.so*).
- `string`: File path of the configuration file (*.yml*).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `InstallAlgoReply`: Result of the request.

```csharp
// Installs the algorithm LPA and uses the leader node to guarantee consistency, and prints the error code

RequestConfig requestConfig = new RequestConfig() { UseMaster = true };

var res = await ultipa.InstallAlgo(
    "E:/Algo/libplugin_lpa.so",
    "E:/Algo/lpa.yml",
    requestConfig   
);
Console.WriteLine(res.Status.ErrorCode);
```
<p tit="Output"></p> 
 
```
Success
```

### UninstallAlgo()

Uninstalls an Ultipa graph algorithm in the instance.

**Parameters:**

- `string`: Name of the algorithm.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UninstallAlgoReply`: Result of the request.

```csharp
// Uninstalls the algorithm LPA and prints the error code

var res = ultipa.UninstallAlgo("lpa");
Console.WriteLine(res.Status.ErrorCode);
```
<p tit="Output"></p> 
 
```
Success
```

## EXTA

### ShowExta()

Retrieves all extas installed in the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Exta>`: The list of all extas retrieved.

```csharp
// Retrieves all extas installed and prints the information of the first returned one

var res = await ultipa.ShowExta();
Console.WriteLine(JsonConvert.SerializeObject(res[0]));
```
<p tit="Output"></p> 
 
```
{"Author":"wuchuang","Name":"page_rank","Version":"beta.4.4.41-b4.4.0-tv-ui","Detail":"base:\r\n  category: ExtaExample\r\n  cn:\r\n    name: page_rank\r\n    desc: null\r\n  en:\r\n    name: page_rank\r\n    desc: null\r\n\r\nother_param:\r\n\r\n    \r\nparam_form:\r\n\r\nwrite:\r\n\r\nreturn:\r\n\r\nmedia:\r\n"}
```

### InstallExta()

Installs an exta in the instance.

**Parameters:**

- `string`: File path of the exta installation package (*.so*).
- `string`: File path of the configuration file (*.yml*).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `InstallExtaReply`: Result of the request.

```csharp
// Installs the exta page_rank and uses the leader node to guarantee consistency, and prints the error code

RequestConfig requestConfig = new RequestConfig() { UseMaster = true };

var res = await ultipa.InstallExta(
    "E:/Exta/libexta_page_rank.so",
    "E:/Exta/page_rank.yml",
    requestConfig
);
Console.WriteLine(res.Status.ErrorCode);
```
<p tit="Output"></p> 
 
```
Success
```

### UninstallExta()

Uninstalls an exta in the instance.

**Parameters:**

- `string`: Name of the exta.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `UninstallExtaReply`: Result of the request.

```csharp
// Uninstalls the exta page_rank and prints the error code

var res = ultipa.UninstallExta("page_rank");
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

        // Installs the algorithm LPA
        var res = await ultipa.InstallAlgo(
            "E:/Algo/libplugin_lpa.so",
            "E:/Algo/lpa.yml",
            requestConfig
        );
        Console.WriteLine(res.Status.ErrorCode);
    }
}
```
