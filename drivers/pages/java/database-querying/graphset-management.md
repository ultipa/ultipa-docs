# Graphset Management

This section introduces methods on a `Connection` object for managing graphsets in the database.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## showGraph()

Retrieves all graphsets from the database.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<GraphSet>`: The list of all graphsets in the database.

<p tit="Java" ></p> 
 
```java
// Retrieves all graphsets and prints the names of the those who have over 2000 edges

List<GraphSet> graphSetList = client.showGraph();
for (GraphSet graphSet : graphSetList) {
    if (graphSet.getTotalEdges() > 2000) {
        System.out.println(graphSet.getName());
    }                
}
```

<p tit= "Output" ></p> 
 
```java
Display_Ad_Click
ERP_DATA2
wikiKG
```

## getGraph()

Retrieves one graphset from the database by its name.

**Parameters:**

- `String`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `GraphSet`: The retrieved graphset.

<p tit="Java" ></p> 
 
```java
// Retrieves the graphsets named 'wikiKG' and prints all its information

GraphSet graph = client.getGraph("wikiKG");
Assert.assertEquals("wikiKG",graph.getName());
System.out.println(new Gson().toJson(graph));
```

<p tit= "Output" ></p> 
 
```java
{"id":615,"name":"wikiKG","totalNodes":3546,"totalEdges":2179,"status":"MOUNTED","description":""}
```

## createGraph()

Creates a new graphset in the database.

**Parameters:**

- `GraphSet`: The graphset to be created; the field `name` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java" ></p> 

```java
// Creates one graphset and prints the error code

GraphSet graph = new GraphSet();
graph.setName("testJavaSDK");
graph.setDescription("testJavaSDK Desc");

Response response = client.createGraph(graph);
System.out.println(response.getStatus().getErrorCode());
```

A new graphset `testJavaSDK` is created in the database, and the driver prints:

<p tit= "Output" ></p> 
 
```java
SUCCEED
```

## createGraphIfNotExist()

Creates a new graphset in the database, handling cases where the given graphset name already exists by ignoring the error.

**Parameters:**

- `GraphSet`: The graphset to be created; the field `name` must be set, `description` is optional.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java" ></p> 

```java
// Creates one graphset and prints the error code

GraphSet graph = new GraphSet();
graph.setName("testJavaSDK");
graph.setDescription("testJavaSDK Desc");

Response response1 = client.createGraphIfNotExist(graph);
System.out.println("First Creation: " + response1.getStatus().getErrorCode());

// Attempts to create the same graphset again and prints the error code

Response response2 = client.createGraphIfNotExist(graph);
System.out.println("Second Creation: " + response2.getStatus().getErrorCode());
```

A new graphset `testJavaSDK` is created in the database, and the driver prints:

<p tit= "Output" ></p> 
 
```java
First Creation: SUCCESS
Second Creation: SUCCESS
```

## dropGraph()

Drops one graphset from the database by its name.

**Parameters:**

- `String`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java" ></p> 
 
```java
// Creates one graphset and then drops it, prints the result

GraphSet graph = new GraphSet();
graph.setName("newGraph");
Response response = client.createGraph(graph);
Assert.assertEquals(Ultipa.ErrorCode.SUCCESS,response.getStatus().getErrorCode());
Thread.sleep(2000);

Response response1 = client.dropGraph("newGraph");
Assert.assertEquals(Ultipa.ErrorCode.SUCCESS,response1.getStatus().getErrorCode());
System.out.println(new Gson().toJson(response1));
```

<p tit= "Output" ></p> 
 
```java
{"host":"192.168.1.85:60611","statistic":{"rowAffected":0,"totalTimeCost":0,"engineTimeCost":0,"nodeAffected":0,"edgeAffected":0,"totalCost":8,"engineCost":0},"status":{"errorCode":"SUCCESS","msg":"","clusterInfo":{"redirect":"","leaderAddress":"","followers":[]}},"aliases":[],"items":{},"explainPlan":{"planNodes":[]}}
```

## alterGraph()

Alters the name and description of one existing graphset in the database by its name.

**Parameters:**

- `GraphSet`: The existing graphset to be altered; the field `name` must be set.
- `GraphSet`: The new configuration for the existing graphset; either or both of the fields `name` and `description` must be set.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java" ></p> 
 
```java
// Renames the graphset 'testJavaSDK' to 'newGraph', sets a description for it, and prints the result

GraphSet oldGraph = new GraphSet();
oldGraph.setName("testJavaSDK");

GraphSet newGraph = new GraphSet();
newGraph.setName("newGraph");
newGraph.setDescription("The graphset is altered");

Response response = client.alterGraph(oldGraph, newGraph);
System.out.println(new Gson().toJson(response));
```

<p tit= "Output" ></p> 
 
```java
{"host":"192.168.1.85:60611","statistic":{"rowAffected":0,"totalTimeCost":0,"engineTimeCost":0,"nodeAffected":0,"edgeAffected":0,"totalCost":1,"engineCost":0},"status":{"errorCode":"SUCCESS","msg":"","clusterInfo":{"redirect":"","leaderAddress":"","followers":[]}},"aliases":[],"items":{},"explainPlan":{"planNodes":[]}}
```

## truncate()

Truncates (Deletes) the specified nodes or edges in the given graphset or truncates the entire graphset. Note that truncating nodes will cause the deletion of edges attached to those affected nodes. The truncating operation retains the definition of schemas and properties while deleting the data.

**Parameters:**

- `Truncate`: The object to truncate; the field `graphName` must be set, `schemaDbType` and `schemaName` are optional, but `schemaName` cannot be set without the setting of `schemaDbType`.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java" ></p> 
 
```java
// Truncates @user nodes in the graphset 'myGraph_1' and prints the error code

Truncate truncate1 = new Truncate();
truncate1.setGraphName("myGraph_1");
truncate1.setSchemaDbType(Ultipa.DBType.DBNODE);
truncate1.setSchemaName("user");

Response response1 = client.truncate(truncate1);
System.out.println(response1.getStatus().getErrorCode());

// Truncates all edges in the graphset 'myGraph_2' and prints the error code	

Truncate truncate2 = new Truncate();
truncate2.setGraphName("myGraph_2");
truncate2.setSchemaDbType(Ultipa.DBType.DBEDGE);

Response response2 = client.truncate(truncate2);
System.out.println(response2.getStatus().getErrorCode());

// Truncates the graphset 'myGraph_3' and prints the error code

Truncate truncate3 = new Truncate();
truncate3.setGraphName("myGraph_3");

Response response3 = client.truncate(truncate3);
System.out.println(response3.getStatus().getErrorCode());
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
SUCCESS
SUCCESS
```

## compact()

Compacts a graphset by clearing its invalid and redundant data on the server disk. Valid data will not be affected.

**Parameters:**

- `String`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java" ></p> 
 
```java
// Compacts the graphset 'miniCircle' and prints the error code

Response response = client.compact("miniCircle");
System.out.println(response.getStatus().getErrorCode());
```

<p tit= "Output" ></p> 
 
```java
SUCCESS
```

## hasGraph()

Checks the existence of a graphset in the database by its name.

**Parameters:**

- `String`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `boolean`: Result of the request.

<p tit="Java" ></p> 
 
```java
// Checks the existence of graphset 'miniCircle' and prints the result

boolean has = client.hasGraph("miniCircle");
System.out.println("has = " + has);
```

<p tit= "Output" ></p> 
 
```java
has = true
```

## unmountGraph()

Unmounts a graphset to save database memory.

**Parameters:**

- `String`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java" ></p> 
 
```java
// Unmounts the graphsets 'miniCircle' and prints its status

client.unmountGraph("miniCircle");
Thread.sleep(3000);
GraphSet graphSet = client.getGraph("miniCircle");
System.out.println(graphSet.getStatus());
```

<p tit= "Output" ></p> 
 
```java
UNMOUNTED
```

## mountGraph()

Mounts a graphset to the database memory.

**Parameters:**

- `String`: Name of the graphset.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java" ></p> 
 
```java
// Mounts the graphsets 'miniCircle' and prints its status

client.mountGraph("miniCircle");
Thread.sleep(3000);
GraphSet graphSet = client.getGraph("miniCircle");
System.out.println(graphSet.getStatus());
```

<p tit= "Output" ></p> 
 
```java
MOUNTED
```

## Full Example

<p tit="Main.java" ></p> 

```js
package com.ultipa.www.sdk.api;

import com.google.gson.Gson;
import com.ultipa.Ultipa;
import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.operate.entity.*;
import com.ultipa.sdk.operate.response.Response;
import org.junit.Assert;

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
          
            // Request configurations
            RequestConfig requestConfig = new RequestConfig();
            requestConfig.setUseMaster(true);

            // Creates new graphset 'newGraph'
            GraphSet graph = new GraphSet();
            graph.setName("newGraph");
            Response response = client.createGraph(graph, requestConfig);
            Assert.assertEquals(Ultipa.ErrorCode.SUCCESS,response.getStatus().getErrorCode());
          
            Thread.sleep(2000);

            // Drops the graphset 'newGraph' just created
            Response response1 = client.dropGraph("newGraph");
            Assert.assertEquals(Ultipa.ErrorCode.SUCCESS,response1.getStatus().getErrorCode());
            System.out.println(new Gson().toJson(response1));
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
