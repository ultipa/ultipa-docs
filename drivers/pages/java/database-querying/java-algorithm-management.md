# Algorithm Management

This section introduces methods on a `Connection` object for managing <a href="/docs/graph-analytics-algorithms">Ultipa graph algorithms</a> and custom algorithms (EXTA) in the instance.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Ultipa Graph Algorithms

### showAlgo()

Retrieves all Ultipa graph algorithms installed in the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Algo>`: The list of all algorithms retrieved.

<p tit="Java"></p> 
 
```java
// Retrieves all Ultipa graph algorithms installed and prints the information of the first returned one

List<Algo> algos = client.showAlgo();
System.out.println(algos.get(0).toString());
```

<p tit="Output"></p> 
 
```java
Algo(name=louvain, desc={"name":"louvain","description":"louvain","version":"1.0.4","parameters":{"edge_schema_property":"optinal,default 1 for each edge if absent","phase1_loop_num":"size_t,required","min_modularity_increase":"float,required","limit":"optional,-1 for all results, >=0 partial results","order":"optional, asc or desc, case_unsensitive, only work for 'community:id/count' mode"},"write_to_db_parameters":{"property":"set write back property name for each schema and nodes"},"write_to_file_parameters":{"filename1":"id1:community","filename2":"community1: id1,id2...","filename3":"community1: count"},"write_to_stats_parameters":{"enable":"0:no stats, 1:enable stats(count of communities)"},"write_to_client_normal_parameters":{"mode":"1:<id1:community>   2:<community1:count>"},"write_to_client_stream_parameters":{"mode":"1:<id1:community>   2:<community1:count>"},"result_opt":"59"}, version=null, params=null)
```

### installAlgo()

Installs an Ultipa graph algorithm in the instance.

**Parameters:**

- `String`: File path of the algo installation package (*.so*).
- `String`: File path of the configuration file (*.yml*).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p> 
 
```java
// Installs the algorithm LPA and uses the leader node to guarantee consistency, and prints the error code
// The installation package libplugin_lpa.so and the config file lpa.yml are placed under the 'classpath' of current project (./src/main/resources)

RequestConfig requestConfig = new RequestConfig();
requestConfig.setUseMaster(true);

Response response = client.installAlgo("algo/libplugin_lpa.so", "algo/lpa.yml");
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```java
SUCCESS
```

### uninstallAlgo()

Uninstalls an Ultipa graph algorithm in the instance.

**Parameters:**

- `String`: Name of the algorithm.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p> 
 
```java
// Uninstalls the algorithm LPA and prints the error code

Response response = client.uninstallAlgo("lpa");
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```java
SUCCESS
```

## EXTA

### showExta()

Retrieves all extas installed in the instance.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Exta>`: The list of all extas retrieved.

<p tit="Java"></p> 
 
```java
// Retrieves all extas installed and prints the information of the first returned one

List<Exta> extas = client.showExta();
System.out.println(extas.get(0).toString());
```

<p tit="Output"></p> 
 
```java
Exta(name=page_rank, author=wuchuang, version=beta.4.4.41-b4.4.0-tv-ui, detail=base:
  category: ExtaExample
  cn:
    name: page_rank
    desc: null
  en:
    name: page_rank
    desc: null

other_param:

    
param_form:

write:

return:

media:
)
```

### installExta()

Installs an exta in the instance.

**Parameters:**

- `String`: File path of the exta installation package (*.so*).
- `String`: File path of the configuration file (*.yml*).
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p> 
 
```java
// Installs the exta page_rank and uses the leader node to guarantee consistency, and prints the error code
// The installation package libexta_page_rank.so and the config file page_rank.yml are placed under the 'classpath' of current project (./src/main/resources)

RequestConfig requestConfig = new RequestConfig();
requestConfig.setUseMaster(true);

Response response = client.installExta("algo/libexta_page_rank.so", "algo/page_rank.yml", requestConfig);
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```java
SUCCESS
```

### uninstallExta()

Uninstalls an exta in the instance.

**Parameters:**

- `String`: Name of the exta.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p> 
 
```java
// Uninstalls the exta page_rank and prints the error code

Response response = client.uninstallExta("page_rank");
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```java
SUCCESS
```

## Full Example

<p tit="Main.java" ></p> 

```js
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;
import com.ultipa.sdk.operate.response.Response;

public class Main {
    public static void main(String[] args) {
        // Connection configurations
        UltipaConfiguration myConfig = UltipaConfiguration.config()
            // URI example: .hosts("mqj4zouys.us-east-1.cloud.ultipa.com:60010")
            .hosts("192.168.1.85:60611,192.168.1.87:60611,192.168.1.88:60611")
            .username("<username>")
            .password("<password>");

        UltipaClientDriver driver = null;
        try {
            // Establishes connection to the database
            driver = new UltipaClientDriver(myConfig);
            Connection client = driver.getConnection();

            Thread.sleep(3000);
          
            // Request configurations: uses the leader node to guarantee consistency
            RequestConfig requestConfig = new RequestConfig();
            requestConfig.setUseMaster(true);

            // Installs the algorithm LPA: the installation package libplugin_lpa.so and the config file lpa.yml are placed under the 'classpath' of current project (./src/main/resources)
            Response response = client.installAlgo("algo/libplugin_lpa.so", "algo/lpa.yml");
            System.out.println(response.getStatus().getErrorCode());
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        } finally {
            if (driver != null) {
                driver.close();
            }
        }
    }
}
```
