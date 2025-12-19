## Query Acceleration

This section introduces methods for managing various indexes and LTE status for properties in graphs.

## Index

### showIndex()

Retrieves all indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Index>`: The list of retrieved indexes.

```java
// Retrieves indexes in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Index> indexList = driver.showIndex(requestConfig);
for (Index index : indexList) {
    System.out.println(index);
}
```

<p tit="Output"></p> 
 
```
Index(id=1, name=age_index, properties=year, schema=account, status=DONE, size=null, dbType=DBNODE)
Index(id=2, name=test_index, properties=year,float, schema=account, status=DONE, size=null, dbType=DBNODE)
Index(id=1, name=targetPostInd, properties=targetPost, schema=disagree, status=DONE, size=null, dbType=DBEDGE)
```

### showNodeIndex()

Retrieves all node indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Index>`: The list of retrieved indexes.

```java
// Retrieves node indexes in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Index> indexList = driver.showNodeIndex(requestConfig);
for (Index index : indexList) {
    System.out.println(index);
}
```

<p tit="Output"></p> 
 
```
Index(id=1, name=age_index, properties=year, schema=account, status=DONE, size=null, dbType=DBNODE)
Index(id=2, name=test_index, properties=year,float, schema=account, status=DONE, size=null, dbType=DBNODE)
```

### showEdgeIndex()

Retrieves all edge indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Index>`: The list of retrieved indexes.

```java
// Retrieves edge indexes in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Index> indexList = driver.showEdgeIndex(requestConfig);
for (Index index : indexList) {
    System.out.println(index);
}
```

<p tit="Output"></p> 
 
```
Index(id=1, name=targetPostInd, properties=targetPost, schema=disagree, status=DONE, size=null, dbType=DBEDGE)
```

### dropIndex()

Drops a specified index from the graph.

**Parameters**

- `dbType: DBType`: Type of the index (node or edge).
- `indexName: String`: Name of the index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Drops the node index 'test_index' from the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Response response = driver.dropIndex(Ultipa.DBType.DBNODE, "test_index", requestConfig);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropNodeIndex()

Drops a specified node index from the graph.

**Parameters**

- `indexName: String`: Name of the index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Drops the node index 'test_index' from the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Response response = driver.dropNodeIndex("test_index", requestConfig);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

### dropEdgeIndex()

Drops a specified edge index from the graph.

**Parameters**

- `indexName: String`: Name of the index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Drops the edge index 'targetPostInd' from the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Response response = driver.dropEdgeIndex("targetPostInd", requestConfig);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## Full-text

### showFulltext()

Retrieves all full-text indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Index>`: The list of retrieved full-text indexes.

```java
// Retrieves full-text indexes in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Index> fulltextList = driver.showFulltext(requestConfig);
for (Index fulltext : fulltextList) {
  System.out.println(fulltext);
}
```

<p tit="Output"></p> 
 
```
Index(id=null, name=name, properties=name, schema=account, status=DONE, size=null, dbType=DBNODE)
Index(id=null, name=Content, properties=content, schema=review, status=DONE, size=null, dbType=DBEDGE)
```

### showNodeFulltext()

Retrieves all node full-text indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Index>`: The list of retrieved full-text indexes.

```java
// Retrieves node full-text indexes in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Index> fulltextList = driver.showNodeFulltext(requestConfig);
for (Index fulltext : fulltextList) {
    System.out.println(fulltext);
}
```

<p tit="Output"></p> 
 
```
Index(id=null, name=name, properties=name, schema=account, status=DONE, size=null, dbType=DBNODE)
```

### showEdgeFulltext()

Retrieves all edge full-text indexes from the graph.

**Parameters**

- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `List<Index>`: The list of retrieved full-text indexes.

```java
// Retrieves edge full-text indexes in the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

List<Index> fulltextList = driver.showEdgeFulltext(requestConfig);
for (Index fulltext : fulltextList) {
    System.out.println(fulltext);
}
```

<p tit="Output"></p> 
 
```
Index(id=null, name=Content, properties=content, schema=review, status=DONE, size=null, dbType=DBEDGE)
```

### createFulltext()

Creates a full-text index in the graph.

**Parameters**

- `dbType: DBType`: Type of the full-text index (node or edge).
- `schemaName: String`: Name of the schema.
- `propertyName: String`: Name of the property.
- `fulltextName: String`: Name of the full-text index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```java
// Creates a full-text index 'moviePlot' for the property 'plot' of the 'movie' nodes

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

JobResponse response = driver.createFulltext(Ultipa.DBType.DBNODE, "movie", "plot", "moviePlot", requestConfig);
String jobID = response.getJobId();

Thread.sleep(3000);
List<Job> jobs = driver.showJob(jobID, requestConfig);
for (Job job : jobs) {
    System.out.println(job.getId() + " - " + job.getStatus());
}
```

<p tit="Output"></p> 
 
```
66 - FINISHED
66_1 - FINISHED
66_2 - FINISHED
66_3 - FINISHED
```

### createNodeFulltext()

Creates a node full-text index in the graph.

**Parameters**

- `schemaName: String`: Name of the schema.
- `propertyName: String`: Name of the property.
- `fulltextName: String`: Name of the full-text index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```java
// Creates a full-text index 'moviePlot' for the property 'plot' of the 'movie' nodes

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

JobResponse response = driver.createNodeFulltext("movie", "plot", "moviePlot", requestConfig);
String jobID = response.getJobId();

Thread.sleep(3000);
List<Job> jobs = driver.showJob(jobID, requestConfig);
for (Job job : jobs) {
    System.out.println(job.getId() + " - " + job.getStatus());
}
```

<p tit="Output"></p> 
 
```
68 - FINISHED
68_1 - FINISHED
68_2 - FINISHED
68_3 - FINISHED
```

### createEdgeFulltext()

Creates an edge full-text index in the graph.

**Parameters**

- `schemaName: String`: Name of the schema.
- `propertyName: String`: Name of the property.
- `fulltextName: String`: Name of the full-text index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```java
// Creates a full-text index 'agreeNotes' for the property 'notes' of the 'agree' edges

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

JobResponse response = driver.createEdgeFulltext("agree", "notes", "agreeNotes", requestConfig);
String jobID = response.getJobId();

Thread.sleep(3000);
List<Job> jobs = driver.showJob(jobID, requestConfig);
for (Job job : jobs) {
    System.out.println(job.getId() + " - " + job.getStatus());
}
```

<p tit="Output"></p> 
 
```
69 - FINISHED
69_1 - FINISHED
69_2 - FINISHED
69_3 - FINISHED
```

### dropFulltext()

Drops a full-text index from the graph.

**Parameters**

- `dyType: DBType`: Type of the full-text index (node or edge).
- `fulltextName: String`: Name of the full-text index.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Drops the node full-index 'moviePlot' from the graph 'miniCircle'

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Response response = driver.dropFulltext(Ultipa.DBType.DBNODE, "moviePlot", requestConfig);
System.out.println(response.getStatus().getCode());
```

<p tit="Output"></p> 
 
```
SUCCESS
```

## LTE

### lte()

Loads a property to the computing engine.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `schemaName: String`: Name of the schema.
- `propertyName: String`: Name of the property.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `JobResponse`: Response of the request.

```java
// Loads the property 'year' of 'account' nodes to the computing engine

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

JobResponse response = driver.lte(Ultipa.DBType.DBNODE, "account", "year", requestConfig);
String jobID = response.getJobId();

Thread.sleep(3000);
List<Job> jobs = driver.showJob(jobID, requestConfig);
for (Job job : jobs) {
    System.out.println(job.getId() + " - " + job.getStatus());
}
```

<p tit="Output"></p> 
 
```
53 - FINISHED
53_1 - FINISHED
53_2 - FINISHED
53_3 - FINISHED
```

### ufe()

Unloads a property from the computing engine.

**Parameters**

- `dbType: DBType`: Type of the property (node or edge).
- `schemaName: String`: Name of the schema.
- `propertyName: String`: Name of the property.
- `config: RequestConfig` (Optional): Request configuration.

**Returns**

- `Response`: Response of the request.

```java
// Unloads the property 'year' of 'account' nodes from the computing engine

RequestConfig requestConfig = new RequestConfig();
requestConfig.setGraph("miniCircle");

Response response = driver.ufe(Ultipa.DBType.DBNODE, "account", "year", requestConfig);
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

import com.google.common.collect.Lists;
import com.ultipa.sdk.UltipaDriver;
import com.ultipa.sdk.connect.conf.RequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfig;
import com.ultipa.sdk.operate.entity.*;

import java.util.*;

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

            // Retrieves indexes in the graph 'miniCircle'

            RequestConfig requestConfig = new RequestConfig();
            requestConfig.setGraph("miniCircle");

            List<Index> indexList = driver.showIndex(requestConfig);
            for (Index index : indexList) {
                System.out.println(index);
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
