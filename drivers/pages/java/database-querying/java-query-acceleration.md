# Query Acceleration

This section introduces methods on a `Connection` object for managing the LTE status for properties, and their indexes and full-text indexes. These mechanisms can be employed to <a href="/docs/uql/acceleration">accelerate queries</a>.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## LTE

### lte()

Loads one custom property of nodes or edges to the computing engine for query acceleration.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `String` (Optional): Name of the schema; all schemas are specified when it is ignored.
- `String`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p> 
 
```java
// Loads the edge property @relatesTo.type to engine in graphset 'UltipaTeam' and prints error code and whether it's LTE-ed

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Response response = client.lte(Ultipa.DBType.DBEDGE, "relatesTo", "type", requestConfig);
System.out.println(response.getStatus().getErrorCode());
Thread .sleep(3000);
Property property = client.getEdgeProperty("relatesTo", "type", requestConfig);
System.out.println("LTE status of the property: " + property.getLte());
```

<p tit="Output"></p> 
 
```java
SUCCESS
LTE status of the property: true
```

### ufe()

Unloads one custom property of nodes or edges from the computing engine to save the memory.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `String` (Optional): Name of the schema; all schemas are specified when it is ignored.
- `String`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p> 
 
```java
// Unloads the edge property @relatesTo.type from engine in graphset 'UltipaTeam' and prints error code and whether it's LTE-ed

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("UltipaTeam");

Response response = client.ufe(Ultipa.DBType.DBEDGE, "relatesTo", "type", requestConfig);
System.out.println(response.getStatus().getErrorCode());
Thread .sleep(3000);
Property property = client.getEdgeProperty("relatesTo", "type", requestConfig);
System.out.println("LTE status of the property: " + property.getLte());
```

<p tit="Output"></p> 
 
```java
SUCCESS
LTE status of the property: false
```

## Index

### showIndex()

Retrieves all indexes of node and edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all indexes retrieved in the current graphset.

<p tit="Java"></p> 
 
```java
// Retrieves indexes in graphset 'Ad_Click' and prints their information

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("Ad_Click");
requestConfig.setUseMaster(true);

List<Index> indexList = client.showIndex(requestConfig);
for (Index index : indexList) {
    System.out.println(new Gson().toJson(index));
}
```

<p tit="Output"></p> 
 
```java
{"name":"shopping_level","properties":"shopping_level","schema":"user","status":"done","size":"4608287","dbType":"DBNODE"}
{"name":"price","properties":"price","schema":"ad","status":"done","size":"7828760","dbType":"DBNODE"}
{"name":"time","properties":"time","schema":"clicks","status":"done","size":"12811267","dbType":"DBEDGE"}
```

### showNodeIndex()

Retrieves all indexes of node properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all node indexes retrieved in the current graphset.

<p tit="Java"></p> 
 
```java
// Retrieves node indexes in graphset 'Ad_Click' and prints their information

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("Ad_Click");

List<Index> indexList = client.showNodeIndex(requestConfig);
for (Index index : indexList) {
    System.out.println(new Gson().toJson(index));
}
```

<p tit="Output"></p> 
 
```java
{"name":"shopping_level","properties":"shopping_level","schema":"user","status":"done","size":"4608287","dbType":"DBNODE"}
{"name":"price","properties":"price","schema":"ad","status":"done","size":"7828760","dbType":"DBNODE"}
```

### showEdgeIndex()

Retrieves all indexes of edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all edge indexes retrieved in the current graphset.

<p tit="Java"></p> 
 
```java
// Retrieves edge indexes in graphset 'Ad_Click' and prints their information

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("Ad_Click");

List<Index> indexList = client.showEdgeIndex(requestConfig);
for (Index index : indexList) {
    System.out.println(new Gson().toJson(index));
}
```

<p tit="Output"></p> 
 
```java
{"name":"time","properties":"time","schema":"clicks","status":"done","size":"12811267","dbType":"DBEDGE"}
```

### createIndex()

Creates a new index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `String` (Optional): Name of the schema.
- `String`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p> 
 
```java
// Creates indexes for all node properties 'name' in graphset 'Ad_Click' and prints the error code

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("Ad_Click");

Response response = client.createIndex(Ultipa.DBType.DBNODE, "name", requestConfig);
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```java
SUCCESS
```

### dropIndex()

Drops indexes in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `String` (Optional): Name of the schema.
- `String`: Name of the property.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p> 
 
```java
// Drops the index of the node property @ad.name in graphset 'Ad_Click' and prints the error code

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("Ad_Click");

Response response = client.dropIndex(Ultipa.DBType.DBNODE, "ad", "name", requestConfig);
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```java
SUCCESS
```

## Full-text

### showFulltext()

Retrieves all full-text indexes of node and edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all full-text indexes retrieved in the current graphset.

<p tit="Java"></p> 
 
```java
// Retrieves the first full-text index returned in graphset 'miniCircle' and prints its information

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("miniCircle");

List<Index> indexList = client.showFulltext(requestConfig);
System.out.println(new Gson().toJson(indexList.get(0)));
```

<p tit="Output"></p> 
 
```java
{"name":"genreFull","properties":"genre","schema":"movie","status":"done"}
```

### showNodeFulltext()

Retrieves all full-text indexes of node properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all full-text indexes of node properties retrieved in the current graphset.

<p tit="Java"></p> 
 
```java
// Retrieves the first node full-text index of node properties returned in graphset 'miniCircle' and prints its information

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("miniCircle");

List<Index> indexList = client.showNodeFulltext(requestConfig);
System.out.println(new Gson().toJson(indexList.get(0)));
```

<p tit="Output"></p> 
 
```java
{"name":"genreFull","properties":"genre","schema":"movie","status":"done"}
```

### showEdgeFulltext()

Retrieves all full-text indexes of edge properties from the current graphset.

**Parameters:**

- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `List<Index>`: The list of all edge full-text indexes of edge properties retrieved in the current graphset.

<p tit="Java"></p> 
 
```java
// Retrieves the first edge full-text index of edge properties returned in graphset 'miniCircle' and prints its information

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("miniCircle");

List<Index> indexList = client.showEdgeFulltext(requestConfig);
System.out.println(new Gson().toJson(indexList.get(0)));
```

<p tit="Output"></p> 
 
```java
{"name":"contentFull","properties":"content","schema":"review","status":"done"}
```

### createFulltext()

Creates a new full-text index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `String`: Name of the schema.
- `String`: Name of the property.
- `String`: Name of the full-text index.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p> 
 
```java
// Creates full-text index called 'movieName' for the property @movie.name in graphset 'miniCircle' and prints the error code

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("miniCircle");

Response response = client.createFulltext(Ultipa.DBType.DBNODE, "movie", "name", "movieName", requestConfig);
System.out.println(response.getStatus().getErrorCode());
```

<p tit="Output"></p> 
 
```java
SUCCESS
```

### dropFulltext()

Drops a full-text index in the current graphset.

**Parameters:**

- `DBType`: Type of the property (node or edge).
- `String`: Name of the full-text index.
- `RequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request.

<p tit="Java"></p> 
 
```java
// Drops the node full-index 'movieName' in graphset 'miniCircle' and prints the error code

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraphName("miniCircle");

Response response = client.dropFulltext(Ultipa.DBType.DBNODE, "movieName", requestConfig);
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

import com.google.gson.Gson;
import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;
import com.ultipa.sdk.operate.entity.Index;
import java.util.List;

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
            requestConfig.setGraphName("Ad_Click");
            requestConfig.setUseMaster(true);

            // Retrieves all indexes in graphset 'Ad_Click' and prints their information
            List<Index> indexList = client.showIndex(requestConfig);
            for (Index index : indexList) {
                System.out.println(new Gson().toJson(index));
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
