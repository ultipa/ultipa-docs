# Graph

This section introduces methods for managing graphs in the database.

# showGraph()

Retrieves all graphs from the database.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<GraphSet>`: The list of retrieved graphs.

```java
// Retrieves all graphs and prints the names of those with over 2000 edges

List<GraphSet> graphSetList = driver.showGraph();
for (GraphSet graphSet : graphSetList) {
    if (graphSet.getTotalEdges() > 2000) {
        System.out.println(graphSet.getName());
    }
}
```

<p tit="Output"></p> 
 
```
Display_Ad_Click
ERP_DATA2
wikiKG
```

## getGraph()

Retrieves a specified graph from the database.

**Parameters**

- `graphName: String`: Name of the graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `GraphSet`: The retrieved graph.

```java
// Retrieves the graph named 'miniCircle'

GraphSet graph = driver.getGraph("miniCircle");
System.out.println(toJson(graph));
```

<p tit="Output"></p> 
 
```
{"id": "444", "name": "miniCircle", "totalNodes": 304, "totalEdges": 1961, "shards": ["1"], "partitionBy": "CityHash64", "status": "NORMAL", "description": "", "slotNum": 256}
```

## hasGraph()

Checks the existence of a specified graph in the database.

**Parameters**

- `graphName: String`: Name of the graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Boolean`: Check result.

```java
// Checks the existence of a graph named 'miniCircle'

boolean response = driver.hasGraph("miniCircle");
System.out.println(response);
```

<p tit="Output"></p> 
 
```
true
```

## createGraph()

Creates a graph in the database.

**Parameters**

- `graphSet: GraphSet`: The graph to be created; the attribute `name` is mandatory, `shards`, `partitionBy` and `description` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Creates a graph

GraphSet graph = new GraphSet();
graph.setName("testJavaSDK");
graph.setShards(Lists.newArrayList("1"));
graph.setPartitionBy("Crc32");
graph.setDescription("testJavaSDK desc");

Response response = driver.createGraph(graph);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## createGraphIfNotExist()

Creates a graph in the database and returns whether a graph with the same name already exists.

**Parameters**

- `graphSet: GraphSet`: The graph to be created; the attribute `name` is mandatory, `shards`, `partitionBy` and `description` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `ResponseWithExistCheck`: Response of the request.

```java
GraphSet graph = new GraphSet();
graph.setName("testJavaSDK");
graph.setShards(Lists.newArrayList("1"));
graph.setPartitionBy("Crc32");
graph.setDescription("testJavaSDK desc");

ResponseWithExistCheck result = driver.createGraphIfNotExist(graph);

System.out.println("Does the graph already exist? " + result.getExist());
if(result.getResponse() == null) {
    System.out.println("Graph creation status: No response");
} else {
    System.out.println("Graph creation status: " + result.getResponse().getStatus().getCode());
}

Thread.sleep(3000);

System.out.println("----- Creates the graph again -----");

ResponseWithExistCheck result1 = driver.createGraphIfNotExist(graph);

System.out.println("Does the graph already exist? " + result1.getExist());
if(result1.getResponse() == null) {
    System.out.println("Graph creation status: No response");
} else {
    System.out.println("Graph creation status: " + result1.getResponse().getStatus().getCode());
}
```

<p tit="Output"></p> 
 
```
Does the graph already exist? false
Graph creation status: SUCCESS
----- Creates the graph again -----
Does the graph already exist? true
Graph creation status: No response
```

## alterGraph()

Alters the name and description of a graph in the database.

**Parameters**

- `graphName: String`: Name of the graph.
- `alterGraphset: GraphSet`: A `GraphSet` object used to set new `name` and/or `description` for the graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Alters the name and description of the graph 'testPythonSDK'

GraphSet newGraphInfo = new GraphSet();
newGraphInfo.setName("newGraph");
newGraphInfo.setDescription("a new graph");
Response response = driver.alterGraph("testJavaSDK", newGraphInfo);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## dropGraph()

Deletes a specified graph from the database.

**Parameters**

- `graphName: String`: Name of the graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Drops the graph 'testPythonSDK'

Response response = driver.dropGraph("testJavaSDK");
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## truncate()

Truncates (Deletes) the specified nodes or edges in a graph or truncates the entire graph. Note that truncating nodes will cause the deletion of edges attached to those affected nodes. The truncating operation retains the definition of schemas and properties in the graph.

**Parameters**

- `params: TruncateParams`: The truncate parameters; the attribute `graphName` is mandatory, `schemaName` and `dbType` are optional.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Truncates User nodes in 'myGraph'

TruncateParams param1 = new TruncateParams();
param1.setGraphName("myGraph");
param1.setSchemaName("User");
param1.setDbType(Ultipa.DBType.DBNODE);
Response response1 = driver.truncate(param1);
System.out.println(response1.getStatus().getCode());

// Truncates all edges in the 'myGraph'

TruncateParams param2 = new TruncateParams();
param2.setGraphName("myGraph");
param2.setSchemaName("*");
param2.setDbType(Ultipa.DBType.DBEDGE);
Response response2 = driver.truncate(param2);
System.out.println(response2.getStatus().getCode());

// Truncates 'myGraph'

TruncateParams param3 = new TruncateParams();
param3.setGraphName("myGraph");
Response response3 = driver.truncate(param3);
System.out.println(response3.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
SUCCESS
SUCCESS
```

## compact()

Clears invalid and redundant data for a graph. Valid data will not be affected.

**Parameters**

- `graphName: String`: Name of the graph.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```java
// Compacts the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

JobResponse response = driver.compact("miniCircle");

String jobId = response.getJobId();

Thread.sleep(3000);
List<Job> jobs = driver.showJob(jobId, requestConfig);
for (Job job : jobs) {
  System.out.println(job.getId() + " - " + job.getStatus());
}
```

<p tit="Output"></p> 
 
```
45 - FINISHED
45_1 - FINISHED
45_2 - FINISHED
45_3 - FINISHED
```

## Full Example

<p tit="Main.java"></p> 

```java
package com.ultipa.www.sdk.api;

import com.ultipa.sdk.UltipaDriver;
import com.ultipa.sdk.connect.conf.UltipaConfig;
import com.ultipa.sdk.operate.entity.GraphSet;
import com.ultipa.sdk.operate.response.Response;
import org.assertj.core.util.Lists;

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

            // Creates a graph

            GraphSet graph = new GraphSet();
            graph.setName("testJavaSDK");
            graph.setShards(Lists.newArrayList("1"));
            graph.setPartitionBy("Crc32");
            graph.setDescription("testJavaSDK desc");

            Response response = driver.createGraph(graph);
            System.out.println(response.getStatus().getCode());
            }
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
