# Data Insertion and Deletion

This section introduces methods on a `Connection` object for inserting nodes and edges to the graph or deleting nodes and edges from the graphset.

Each example focuses solely on the method's usage. For a complete code example, please refer to the <a href="#Full-Example">full example</a>.

## Example Graph Data Model

The examples below demonstrate how to insert or delete nodes or edges from a graphset with the following schema and property definitions:

<div align=center drawio-diagram='16645' drawio-name="draw_eef958d9d27649c381cb1e470f4963cc.jpg"><img src="https://img.ultipa.cn/draw/draw_eef958d9d27649c381cb1e470f4963cc.jpg?v='1722479101557'"/></div>

## Property Type Mapping

When inserting nodes or edges, you may need to specify property values of different types. The mapping between Ultipa property types and Java/Driver data types is as follows:

| Ultipa Property Type | <div table-width="65">Java/Driver Type</div> |
| -- | -- |
| int32 | `int` |
| uint32 | `long` |
| int64 | `long` |
| uint64 | `long` |
| float | `float` |
| double | `double` |
| decimal | `BigDecimal`, supports various numeric types (`Integer`, `Float`, `Double`, `Long`, etc.) and `String` |
| string | `String` |
| text | `String` |
| datetime | `String`<sup>[1]</sup>, additionally supports `java.util.Date` and `LocalDateTime` with batch insertion |
| timestamp | `String`<sup>[1]</sup>, additionally supports `java.util.Date` with batch insertion |
| point | `Point` (Driver type) |
| blob | `byte[]`, `String` |
| list | `List` |
| set | `Set` |

<sup>[1]</sup> Supported date string formats in batch insertion include `[YY]YY-MM-DD HH:MM:SS`, `[YY]YY-MM-DD HH:MM:SSZ`, `[YY]YY-MM-DDTHH:MM:SSZ`, `[YY]YY-MM-DDTHH:MM:SSXX`, `[YY]YY-MM-DDTHH:MM:SSXXX`, `[YY]YY-MM-DD HH:MM:SS.SSS` and their variations.

## Insertion

### insertNodes()

Inserts new nodes of a schema to the current graph.
 
**Parameters:**

- `String`: Name of the schema.
- `List<Node>`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `nodes` that holds all the inserted nodes when `InsertRequestConfig.silent` is set to false.

```java
// Inserts two nodes into schema 'user' in graphset 'lcc', prints error code and information of the inserted nodes

InsertRequestConfig insertRequestConfig = new InsertRequestConfig();
insertRequestConfig.setInsertType(Ultipa.InsertType.NORMAL);
insertRequestConfig.setGraphName("lcc");
insertRequestConfig.setSilent(false);

List<Node> nodeList = new ArrayList<>();

Node node1 = new Node();
node1.setUUID(1l);
node1.setID("U001");
Value value1 = Value.newBuilder()
        .add("name", "Alice")
        .add("age", 18)
        .add("score", 65.32)
        .add("birthday", "1993-5-4")
        .add("location", new Point(23.63, 104.25))
        .add("profile", "abc")
        .add("interests", Arrays.asList("tennis", "violin"))
        .add("permissionCodes", new HashSet<>(Arrays.asList(2004, 3025, 1025)))
        .build();
node1.setValues(value1);
nodeList.add(node1);

Node node2 = new Node();
node2.setUUID(2l);
node2.setID("U002");
Value value2 = Value.newBuilder().add("name", "Bob").build();
node2.setValues(value2);
nodeList.add(node2);

Response response = client.insertNodes("user", nodeList, insertRequestConfig);
System.out.println(response.getStatus().getErrorCode());
// There is no alias in Response if InsertRequestConfig.silent is true
List<Node> insertedNodes = response.alias("nodes").asNodes();
for (Node node : insertedNodes) {
    System.out.println(node.toString());
}
```

<p tit="Output"></p> 

```
SUCCESS
Node(uuid=1, id=U001, schema=user, values={name=Alice, age=18, score=65.3200000000, birthday=1993-05-04T00:00, location=POINT(23.63 104.25), profile=[B@1e66f1f5, interests=[tennis, violin], permissionCodes=[3025, 1025, 2004]})
Node(uuid=2, id=U002, schema=user, values={name=Bob, age=null, score=null, birthday=null, location=null, profile=null, interests=null, permissionCodes=null})
```

### insertEdges()

Inserts new edges of a schema to the current graph.
 
**Parameters:**

- `String`: Name of the schema.
- `List<Edge>`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `edges` that holds all the inserted edges when `InsertRequestConfig.silent` is set to false.

```java
// Inserts two edges into schema 'follows' in graphset 'lcc', prints error code and information of the inserted edges

InsertRequestConfig insertRequestConfig = new InsertRequestConfig();
insertRequestConfig.setInsertType(Ultipa.InsertType.NORMAL);
insertRequestConfig.setGraphName("lcc");
insertRequestConfig.setSilent(false);

List<Edge> edgeList = new ArrayList<>();

Edge edge1 = new Edge();
edge1.setUUID(1l);
edge1.setFrom("U001");
edge1.setTo("U002");
Value value1 = Value.newBuilder().add("createdOn", "2024-5-6").build();
edge1.setValues(value1);
edgeList.add(edge1);

Edge edge2 = new Edge();
edge2.setUUID(2l);
edge2.setFrom("U002");
edge2.setTo("U001");
Value value2 = Value.newBuilder().add("createdOn", "2024-5-8").build();
edge2.setValues(value2);
edgeList.add(edge2);

Response response = client.insertEdges("follows", edgeList, insertRequestConfig);
System.out.println(response.getStatus().getErrorCode());
// There is no alias in Response if InsertRequestConfig.silent is true
List<Edge> insertedEdges = response.alias("edges").asEdges();
for (Edge edge : insertedEdges) {
    System.out.println(edge.toString());
}
```

<p tit="Output"></p> 

```
SUCCESS
Edge(uuid=1, fromUuid=1, toUuid=2, from=U001, to=U002, schema=follows, values={createdOn=Mon May 06 00:00:00 CST 2024})
Edge(uuid=2, fromUuid=2, toUuid=1, from=U002, to=U001, schema=follows, values={createdOn=Wed May 08 00:00:00 CST 2024})
```

### insertNodesBatchBySchema()

Inserts new nodes of a schema into the current graph through gRPC. The properties within the node values must be consistent with those declared in the schema structure.

**Parameters:**

- `Schema`: The target schema.
- `List<Node>`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. `Response.InsertNodesReply` contains the insertion report when `InsertRequestConfig.silent` is set to false.

```java
// Inserts two nodes into schema 'user' in graphset 'lcc', prints error code and the insert reply

InsertRequestConfig insertRequestConfig = new InsertRequestConfig();
insertRequestConfig.setInsertType(Ultipa.InsertType.NORMAL);
insertRequestConfig.setGraphName("lcc");
insertRequestConfig.setSilent(false);

ArrayList<Property> properties = new ArrayList<>();
Property property1 = new Property(), property2 = new Property(), property3 = new Property(), property4 = new Property(), property5 = new Property(), property6 = new Property(), property7 = new Property(), property8 = new Property();
property1.setName("name");
property1.setType("string");
property2.setName("age");
property2.setType("int32");
property3.setName("score");
property3.setType("decimal");
property4.setName("birthday");
property4.setType("datetime");
property5.setName("location");
property5.setType("point");
property6.setName("profile");
property6.setType("blob");
property7.setName("interests");
property7.setType("string[]");
property8.setName("permissionCodes");
property8.setType("set(int32)");
properties.add(property1);
properties.add(property2);
properties.add(property3);
properties.add(property4);
properties.add(property5);
properties.add(property6);
properties.add(property7);
properties.add(property8);

Schema schema = new Schema();
schema.setName("user");
schema.setProperties(properties);

List<Node> nodeList = new ArrayList<>();

Node node1 = new Node();
node1.setUUID(1l);
node1.setID("U001");
Value value1 = Value.newBuilder()
        .add("name", "Alice")
        .add("age", 18)
        .add("score", 65.32)
        //.add("birthday", "1993-05-04")
        //.add("birthday", new Date(736473600000l)) // Timestamp in milliseconds
        .add("birthday", LocalDateTime.of(1993,5,4,00,00))
        .add("location", new Point(23.63, 104.25))
        .add("profile", "abc")
        .add("interests", Arrays.asList("tennis", "violin"))
        .add("permissionCodes", new HashSet<>(Arrays.asList(2004, 3025, 1025)))
        .build();
node1.setValues(value1);
nodeList.add(node1);

Node node2 = new Node();
node2.setUUID(2l);
node2.setID("U002");
Value value2 = Value.newBuilder()
        .add("name", "Bob")
        .add("age", null)
        .add("score", null)
        .add("birthday", null)
        .add("location", null)
        .add("profile", null)
        .add("interests", null)
        .add("permissionCodes", null)
        .build();
node2.setValues(value2);
nodeList.add(node2);

Response response = client.insertNodesBatchBySchema(schema, nodeList, insertRequestConfig);
System.out.println(response.getStatus().getErrorCode());
// Response.InsertNodesReply is null if InsertRequestConfig.silent is true
System.out.println(response.getInsertNodesReply());
```

<p tit="Output"></p> 

```
SUCCESS
InsertResponse(idList=[], uuidList=[1, 2], errorItems={})
```

### insertEdgesBatchBySchema()

Inserts new edges of a schema into the current graph through gRPC. The properties within the edge values must be consistent with those declared in the schema structure.

**Parameters:**

- `Schema`: The target schema.
- `List<Edge>`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. `Response.InsertNodesReply` contains the insertion report when `InsertRequestConfig.silent` is set to false.

```java
// Inserts two edges into schema 'follows' in graphset 'lcc', prints error code and the insert reply

InsertRequestConfig insertRequestConfig = new InsertRequestConfig();
insertRequestConfig.setInsertType(Ultipa.InsertType.NORMAL);
insertRequestConfig.setGraphName("lcc");
insertRequestConfig.setSilent(false);

ArrayList<Property> properties = new ArrayList<>();
Property property = new Property();
property.setName("createdOn");
property.setType("timestamp");
properties.add(property);

Schema schema = new Schema();
schema.setName("follows");
schema.setProperties(properties);

List<Edge> edgeList = new ArrayList<>();

Edge edge1 = new Edge();
edge1.setUUID(1l);
edge1.setFrom("U001");
edge1.setTo("U002");
Value value1 = Value.newBuilder().add("createdOn", "2024-05-06").build();
edge1.setValues(value1);
edgeList.add(edge1);

Edge edge2 = new Edge();
edge2.setUUID(2l);
edge2.setFrom("U002");
edge2.setTo("U001");
Value value2 = Value.newBuilder().add("createdOn", new Date(1715169600000l)).build();
edge2.setValues(value2);
edgeList.add(edge2);

Response response = client.insertEdgesBatchBySchema(schema, edgeList, insertRequestConfig);
System.out.println(response.getStatus().getErrorCode());
// Response.InsertEdgesReply is null if InsertRequestConfig.silent is true
System.out.println(response.getInsertEdgesReply());
```

<p tit="Output"></p> 

```
SUCCESS
InsertResponse(idList=null, uuidList=[1, 2], errorItems={})
```

### insertNodesBatchAuto()

Inserts new nodes of one or multiple schemas to the current graph through gRPC. The properties within node values must be consistent with those defined in the corresponding schema structure.

**Parameters:**

- `List<Node>`: The list of `Node` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. `Response.InsertNodesReply` contains the insertion report when `InsertRequestConfig.silent` is set to false.

```java
// Inserts two nodes into schema 'user' and one node into schema `product` in graphset 'lcc', prints error code and the insert reply

InsertRequestConfig insertRequestConfig = new InsertRequestConfig();
insertRequestConfig.setInsertType(Ultipa.InsertType.NORMAL);
insertRequestConfig.setGraphName("lcc");
insertRequestConfig.setSilent(false);

List<Node> nodeList = new ArrayList<>();

Node node1 = new Node();
node1.setSchema("user");
node1.setUUID(1l);
node1.setID("U001");
Value value1 = Value.newBuilder()
        .add("name", "Alice")
        .add("age", 18)
        .add("score", 65.32)
        //.add("birthday", "1993-05-04")
        //.add("birthday", new Date(736473600000l)) // Timestamp in milliseconds
        .add("birthday", LocalDateTime.of(1993,5,4,00,00))
        .add("location", new Point(23.63, 104.25))
        .add("profile", "abc")
        .add("interests", Arrays.asList("tennis", "violin"))
        .add("permissionCodes", new HashSet<>(Arrays.asList(2004, 3025, 1025)))
        .build();
node1.setValues(value1);
nodeList.add(node1);

Node node2 = new Node();
node2.setSchema("user");
node2.setUUID(2l);
node2.setID("U002");
Value value2 = Value.newBuilder()
        .add("name", "Bob")
        .add("age", null)
        .add("score", null)
        .add("birthday", null)
        .add("location", null)
        .add("profile", null)
        .add("interests", null)
        .add("permissionCodes", null)
        .build();
node2.setValues(value2);
nodeList.add(node2);

Node node3 = new Node();
node3.setSchema("product");
node3.setUUID(3l);
node3.setID("P001");
Value value3 = Value.newBuilder()
        .add("name", "Wireless Earbud")
        .add("price", 93.2f)
        .build();
node3.setValues(value3);
nodeList.add(node3);

Response response = client.insertNodesBatchAuto(nodeList, insertRequestConfig);
System.out.println(response.getStatus().getErrorCode());
// Response.InsertNodesReply is null if InsertRequestConfig.silent is true
System.out.println(response.getInsertNodesReply());
```

<p tit="Output"></p> 

```
SUCCESS
InsertResponse(idList=[], uuidList=[3, 1, 2], errorItems={})
```

### insertEdgesBatchAuto()

Inserts new edges of one or multiple schemas to the current graph through gRPC. The properties within edge values must be consistent with those defined in the corresponding schema structure.

**Parameters:**

- `List<Edge>`: The list of `Edge` objects to be inserted.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. `Response.InsertEdgesReply` contains the insertion report when `InsertRequestConfig.silent` is set to false.

```java
// Inserts two edges into schema 'follows' and one edge into schema 'purchased' in graphset 'lcc', prints error code and the insert reply

InsertRequestConfig insertRequestConfig = new InsertRequestConfig();
insertRequestConfig.setInsertType(Ultipa.InsertType.NORMAL);
insertRequestConfig.setGraphName("lcc");
insertRequestConfig.setSilent(false);

List<Edge> edgeList = new ArrayList<>();

Edge edge1 = new Edge();
edge1.setSchema("follows");
edge1.setUUID(1l);
edge1.setFrom("U001");
edge1.setTo("U002");
Value value1 = Value.newBuilder().add("createdOn", "2024-05-06").build();
edge1.setValues(value1);
edgeList.add(edge1);

Edge edge2 = new Edge();
edge2.setSchema("follows");
edge2.setUUID(2l);
edge2.setFrom("U002");
edge2.setTo("U001");
Value value2 = Value.newBuilder().add("createdOn", new Date(1715169600000l)).build();
edge2.setValues(value2);
edgeList.add(edge2);

Edge edge3 = new Edge();
edge3.setSchema("purchased");
edge3.setUUID(3l);
edge3.setFrom("U002");
edge3.setTo("P001");
Value value3 = Value.newBuilder().add("qty", 1l).build();
edge3.setValues(value3);
edgeList.add(edge3);

Response response = client.insertEdgesBatchAuto(edgeList, insertRequestConfig);
System.out.println(response.getStatus().getErrorCode());
// Response.InsertEdgesReply is null if InsertRequestConfig.silent is true
System.out.println(response.getInsertEdgesReply());
```

<p tit="Output"></p> 

```
SUCCESS
InsertResponse(idList=[], uuidList=[3, 1, 2], errorItems={})
```

## Deletion

### deleteNodes()

Deletes nodes that meet the given conditions from the current graph. It's important to note that deleting a node leads to the removal of all edges that are connected to it.

**Parameters:**

- `String`: The filtering condition to specify the nodes to delete.
- `Integer` (Optional): The maximum number of nodes to delete; ignores this parameter or sets to `-1` to delete all.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `nodes` that holds all the deleted nodes when `InsertRequestConfig.silent` is set to false.

```java
// Deletes one @user nodes whose name is 'Alice' from graphset 'lcc', prints error code and information of the deleted nodes
// All edges attached to the deleted node are deleted as well

InsertRequestConfig insertRequestConfig = new InsertRequestConfig();
insertRequestConfig.setInsertType(Ultipa.InsertType.NORMAL);
insertRequestConfig.setGraphName("lcc");
insertRequestConfig.setSilent(false);

Response response = client.deleteNodes("@user.name == 'Alice'", 1, insertRequestConfig);
System.out.println(response.getStatus().getErrorCode());
// There is no alias in Response if InsertRequestConfig.silent is true
List<Node> deletedNodes = response.alias("nodes").asNodes();
for (Node node : deletedNodes) {
    System.out.println(node.toString());
}
```

<p tit="Output"></p> 

```
SUCCESS
Node(uuid=1, id=U001, schema=user, values={name=Alice})
```

### deleteEdges()

Deletes edges that meet the given conditions from the current graph.

**Parameters:**

- `String`: The filtering condition to specify the edges to delete.
- `Integer` (Optional): The maximum number of edges to delete; ignores this parameter or sets to `-1` to delete all.
- `InsertRequestConfig` (Optional): Configuration settings for the request.

**Returns:**

- `Response`: Result of the request. The `Response` object contains an alias `edges` that holds all the deleted edges when `InsertRequestConfig.silent` is set to false.

```java
// Deletes all @purchased edges from graphset 'lcc', prints error code and information of the deleted edges

InsertRequestConfig insertRequestConfig = new InsertRequestConfig();
insertRequestConfig.setInsertType(Ultipa.InsertType.NORMAL);
insertRequestConfig.setGraphName("lcc");
insertRequestConfig.setSilent(false);

Response response = client.deleteEdges("@purchased", insertRequestConfig);
System.out.println(response.getStatus().getErrorCode());
// There is no alias in Response if InsertRequestConfig.silent is true
List<Edge> deletedEdges = response.alias("edges").asEdges();
for (Edge edge : deletedEdges) {
    System.out.println(edge.toString());
}
```

<p tit="Output"></p> 

```
SUCCESS
Edge(uuid=3, fromUuid=2, toUuid=3, from=U002, to=P001, schema=purchased, values={})
```

## Full Example

<p tit="Main.java" ></p> 

```js
package com.ultipa.www.sdk.api;

import com.ultipa.Ultipa;
import com.ultipa.sdk.connect.Connection;
import com.ultipa.sdk.connect.conf.InsertRequestConfig;
import com.ultipa.sdk.connect.conf.UltipaConfiguration;
import com.ultipa.sdk.connect.driver.UltipaClientDriver;
import com.ultipa.sdk.operate.entity.*;
import com.ultipa.sdk.operate.response.Response;
import com.ultipa.sdk.data.Point;
import java.time.LocalDateTime;
import java.util.*;
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
          
            // Insert Request configurations
            InsertRequestConfig insertRequestConfig = new InsertRequestConfig();
            insertRequestConfig.setInsertType(Ultipa.InsertType.NORMAL);
            insertRequestConfig.setGraphName("lcc");
            insertRequestConfig.setSilent(false);
          
            // Inserts two nodes into schema 'user' and one node into schema `product` in graphset 'lcc', prints error code and the insert reply
            List<Node> nodeList = new ArrayList<>();

            Node node1 = new Node();
            node1.setSchema("user");
            node1.setUUID(1l);
            node1.setID("U001");
            Value value1 = Value.newBuilder()
                    .add("name", "Alice")
                    .add("age", 18)
                    .add("score", 65.32)
                    //.add("birthday", "1993-05-04")
                    //.add("birthday", new Date(736473600000l)) // Timestamp in milliseconds
                    .add("birthday", LocalDateTime.of(1993,5,4,00,00))
                    .add("location", new Point(23.63, 104.25))
                    .add("profile", "abc")
                    .add("interests", Arrays.asList("tennis", "violin"))
                    .add("permissionCodes", new HashSet<>(Arrays.asList(2004, 3025, 1025)))
                    .build();
            node1.setValues(value1);
            nodeList.add(node1);

            Node node2 = new Node();
            node2.setSchema("user");
            node2.setUUID(2l);
            node2.setID("U002");
            Value value2 = Value.newBuilder()
                    .add("name", "Bob")
                    .add("age", null)
                    .add("score", null)
                    .add("birthday", null)
                    .add("location", null)
                    .add("profile", null)
                    .add("interests", null)
                    .add("permissionCodes", null)
                    .build();
            node2.setValues(value2);
            nodeList.add(node2);

            Node node3 = new Node();
            node3.setSchema("product");
            node3.setUUID(3l);
            node3.setID("P001");
            Value value3 = Value.newBuilder()
                    .add("name", "Wireless Earbud")
                    .add("price", 93.2f)
                    .build();
            node3.setValues(value3);
            nodeList.add(node3);

            Response response1 = client.insertNodesBatchAuto(nodeList, insertRequestConfig);
            System.out.println("Node insertion status: " + response1.getStatus().getErrorCode());
            // Response.InsertNodesReply is null if InsertRequestConfig.silent is true
            System.out.println("Node inserted: " + response1.getInsertNodesReply());

            // Inserts two edges into schema 'follows' and one edge into schema 'purchased' in graphset 'lcc', prints error code and the insert reply
            List<Edge> edgeList = new ArrayList<>();

            Edge edge1 = new Edge();
            edge1.setSchema("follows");
            edge1.setUUID(1l);
            edge1.setFrom("U001");
            edge1.setTo("U002");
            Value value4 = Value.newBuilder().add("createdOn", "2024-05-06").build();
            edge1.setValues(value4);
            edgeList.add(edge1);

            Edge edge2 = new Edge();
            edge2.setSchema("follows");
            edge2.setUUID(2l);
            edge2.setFrom("U002");
            edge2.setTo("U001");
            Value value5 = Value.newBuilder().add("createdOn", new Date(1715169600000l)).build();
            edge2.setValues(value5);
            edgeList.add(edge2);

            Edge edge3 = new Edge();
            edge3.setSchema("purchased");
            edge3.setUUID(3l);
            edge3.setFrom("U002");
            edge3.setTo("P001");
            Value value6 = Value.newBuilder().add("qty", 1l).build();
            edge3.setValues(value6);
            edgeList.add(edge3);

            Response response2 = client.insertEdgesBatchAuto(edgeList, insertRequestConfig);
            System.out.println("Edge insertion status: " + response2.getStatus().getErrorCode());
            // Response.InsertNodesReply is null if InsertRequestConfig.silent is true
            System.out.println("Edge inserted: " + response2.getInsertEdgesReply());
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
