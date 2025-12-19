## HDC Graph and Algorithm

This section introduces methods for managing HDC graph and HDC algorithms. Note that these methods require the deployment of HDC servers for the database.

## HDC Graph

### showHDCGraph()

Retrieves all HDC graphs created from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<HDCGraph>`: The list of retrieved HDC graphs.

```java
// Retrieves all HDC graphs of the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<HDCGraph> hdcGraphs = driver.showHDCGraph(requestConfig);
for (HDCGraph hdcGraph : hdcGraphs) {
    System.out.println(hdcGraph.getName() + " on " + hdcGraph.getHdcServerName());
}
```

<p tit="Output"></p> 
 
```
miniCircle_hdc_graph on hdc-server-1
miniCircle_hdc_graph2 on hdc-server-2
```

### createHDCGraphBySchema()

Creates an HDC graph for the graph.

**Parameters**

- `builder: HDCBuilder`: The HDC graph to be created; the attributes `hdcGraphName` and `hdcServerName` are mandatory, `nodeSchema`, `edgeSchema`, `syncType`, `direction`, `loadId`, and `isDefault` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```java
// Creates an HDC graph named 'test_hdc_graph' for the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Map<String, List<String>> nodeSchema = new HashMap<>();
nodeSchema.put("*", Lists.newArrayList("*"));

Map<String, List<String>> edgeSchema = new HashMap<>();
edgeSchema.put("direct", Lists.newArrayList("*"));
edgeSchema.put("review", Lists.newArrayList("value", "content"));

HDCAPI.HDCBuilder hdcBuilder = new HDCAPI.HDCBuilder()
		.setHdcGraphName("test_hdc_graph")
  		.setHdcServerName("hdc-server-1")
  		.setNodeSchema(nodeSchema)
  		.setEdgeSchema(edgeSchema)
        .setSyncType(HDCAPI.HDCSyncType.STATIC);

JobResponse response = driver.createHDCGraphBySchema(hdcBuilder, requestConfig);
String jobId = response.getJobId();

Thread.sleep(3000);
List<Job> jobs = driver.showJob(jobId, requestConfig);
for (Job job : jobs) {
    System.out.println(job.getId() + " - " + job.getStatus());
}
```

<p tit="Output"></p> 
 
```
61 - FINISHED
61_1 - FINISHED
```

### dropHDCGraph()

Deletes a specified HDC graph of the graph.

**Parameters**

- `hdcGraphName: String`: Name of the HDC graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Drops the HDC graph 'miniCircle_hdc_graph2' of the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Response response = driver.dropHDCGraph("miniCircle_hdc_graph2", requestConfig);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## HDC Algorithms

### showAlgo()

Retrieves all HDC algorithms installed on an HDC server.

**Parameters**

- `hdcServerName: String`: Name of the HDC server.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Algo>`: The list of retrieved HDC algorithms.

```java
// Retrieves all HDC algorithms installed on the HDC server 'hdc-server-1'

List<Algo> algos = driver.showHDCAlgo("hdc-server-1");
for (Algo algo : algos) {
    System.out.println(algo.getName() + " supports writeback types: " + algo.getWriteSupportType());
}
```

<p tit="Output"></p> 
 
```
fastRP supports writeback types: DB,FILE
struc2vec supports writeback types: DB,FILE
```

### installAlgo()

Installs an HDC algorithm on an HDC server.

**Parameters**

- `files: List<String>`: List of the paths of the installation files, the package file (.so) is necessary while the configuration file (.yml) is optional.
- `hdcServerName: String`: Name of the HDC server.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Installs the HDC algorithm LPA on the HDC server 'hdc-server-1'

Response response = driver.installHDCAlgo(Arrays.asList("src/main/resources/algo/libplugin_lpa.so", "src/main/resources/algo/lpa.yml"), "hdc-server-1");
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### uninstallAlgo()

Uninstalls an HDC algorithm from an HDC server.

**Parameters**

- `algoName: String`: Name of the algorithm.
- `hdcServerName: String`: Name of the HDC server.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Uninstalls the HDC algorithm LPA from the HDC server 'hdc-server-1'

Response response = driver.uninstallHDCAlgo("lpa", "hdc-server-1");
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### rollbackHDCAlgo()

Rolls back a specified HDC algorithm on an HDC server.

**Parameters**

- `algoName: String`: Name of the algorithm.
- `hdcServerName: String`: Name of the HDC server.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Rolls back the HDC algorithms LPA on the HDC server 'hdc-server-1'

Response response = driver.rollbackHDCAlgo("lpa", "hdc-server-1");
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full Example

<p tit="Main.java"></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.UltipaDriver;
import com.ultipa.sdk.connect.conf.UltipaConfig;
import com.ultipa.sdk.operate.response.Response;
import org.assertj.core.util.Lists;

import java.util.Arrays;

public class Main {
    public static void main(String[] args) {
        UltipaConfig ultipaConfig = UltipaConfig.config()
               // URI example: .hosts(Lists.newArrayList("d3026ac361964633986849ec43b84877s.eu-south-1.cloud.ultipa.com:8443"))
                .hosts(Lists.newArrayList("192.168.1.85:60061","192.168.1.88:60061","192.168.1.87:60061"))
                .username("<username>")
                .password("<password>");

        UltipaDriver driver = null;

        try {
            driver = new UltipaDriver(ultipaConfig);

            // Installs the HDC algorithm LPA on the HDC server 'hdc-server-1'

            Response response = driver.installHDCAlgo(Arrays.asList("src/main/resources/algo/libplugin_lpa.so", "src/main/resources/algo/lpa.yml"), "hdc-server-1");
            System.out.println(response.getStatus().getCode());
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
