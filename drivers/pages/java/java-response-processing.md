# Response Processing

The GQLDB Java driver provides the `Response` and `Row` classes for working with query results. This guide covers how to extract and convert data from query responses.

## Response Class

The `gql()` method returns a `Response` object containing query results:

```java
import com.gqldb.*;

public void queryExample(GqldbClient client) {
    Response response = client.gql("MATCH (n:User) RETURN n.name, n.age");

    System.out.println("Columns: " + response.getColumns());      // ["n.name", "n.age"]
    System.out.println("Row count: " + response.getRowCount());   // Number of rows
    System.out.println("Has more: " + response.hasMore());        // Pagination indicator
    System.out.println("Warnings: " + response.getWarnings());    // Any query warnings
    System.out.println("Rows affected: " + response.getRowsAffected());  // For write operations
}
```

### Response Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `getColumns()` | `List<String>` | Column names from the query |
| `getRows()` | `List<Row>` | List of result rows |
| `getRowCount()` | `long` | Total number of rows |
| `hasMore()` | `boolean` | Whether more results are available |
| `getWarnings()` | `List<String>` | Query warnings |
| `getRowsAffected()` | `long` | Rows affected by write operations |
| `size()` | `int` | Same as `getRows().size()` |
| `isEmpty()` | `boolean` | Whether response has no rows |

## Row Class

Each row contains values that can be accessed by index:

```java
Response response = client.gql("MATCH (n:User) RETURN n.name, n.age, n.active");

for (Row row : response) {
    // Access by index
    Object name = row.get(0);      // First column
    Object age = row.get(1);       // Second column
    Object active = row.get(2);    // Third column

    // Typed accessors
    String nameStr = row.getString(0);     // Returns String
    long ageNum = row.getLong(1);          // Returns long
    boolean activeBool = row.getBoolean(2); // Returns boolean

    System.out.println(nameStr + ", age " + ageNum + ", active: " + activeBool);
}
```

### Row Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `get(index)` | `Object` | Get value at index |
| `getString(index)` | `String` | Get value as String |
| `getLong(index)` | `long` | Get value as long |
| `getDouble(index)` | `double` | Get value as double |
| `getBoolean(index)` | `boolean` | Get value as boolean |
| `size()` | `int` | Number of values in row |
| `getTypedValues()` | `List<TypedValue>` | Get raw TypedValue list |

## Iterating Results

### Using for-each

```java
Response response = client.gql("MATCH (n) RETURN n");

// Response implements Iterable<Row>
for (Row row : response) {
    System.out.println(row.get(0));
}
```

### Using forEach

```java
response.forEach(row -> {
    System.out.println(row.get(0));
});
```

### Using map

```java
List<String> names = response.map(row -> row.getString(0));
System.out.println("Names: " + names);
```

## Quick Access Methods

### First and Last Row

```java
Optional<Row> first = response.first();  // First row or empty
Optional<Row> last = response.last();    // Last row or empty

first.ifPresent(row -> {
    System.out.println("First result: " + row.get(0));
});
```

### Check if Empty

```java
if (response.isEmpty()) {
    System.out.println("No results found");
}
```

### Single Value

For queries that return a single row with a single column:

```java
Response countResponse = client.gql("MATCH (n) RETURN count(n)");
Object count = countResponse.singleValue();  // Returns the single value

// Typed single value accessors
long countNum = countResponse.singleLong();    // As long
String countStr = countResponse.singleString(); // As String
```

## Converting to Maps

### toMaps()

Convert rows to a list of maps:

```java
Response response = client.gql("MATCH (u:User) RETURN u.name AS name, u.age AS age");
List<Map<String, Object>> users = response.toMaps();

// Result: [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 25}]
for (Map<String, Object> user : users) {
    System.out.println(user.get("name") + " is " + user.get("age") + " years old");
}
```

### Get Value by Column Name

```java
Response response = client.gql("MATCH (u:User) RETURN u.name AS name, u.age AS age");

for (Row row : response) {
    Object name = response.getByName(row, "name");
    Object age = response.getByName(row, "age");
    System.out.println(name + ": " + age);
}
```

## Accessing Aliases

### alias() and get()

Query results are organized by aliases. Use `alias()` or `get()` to access a specific `AliasResult`, then call extraction methods on it:

```java
import com.gqldb.*;

Response response = client.gql("MATCH (u:User)-[e:Follows]->(f:User) RETURN u, e, f");

// Access by alias name
AliasResult uResult = response.alias("u");
AliasResult eResult = response.alias("e");

// Access by index
AliasResult firstAlias = response.get(0);  // Same as response.alias("u")
```

### AliasResult Class

| Method | Return Type | Description |
|--------|-------------|-------------|
| `asNodes()` | `NodeResult` | Extract nodes from this alias |
| `asEdges()` | `EdgeResult` | Extract edges from this alias |
| `asPaths()` | `List<Path>` | Extract paths from this alias |
| `asTable()` | `Table` | Get alias data as a table |
| `asAttr()` | `Attr` | Extract attribute values from this alias |

## Extracting Graph Elements

### asNodes()

Extract nodes from the response via an alias:

```java
import com.gqldb.*;

Response response = client.gql("MATCH (u:User) RETURN u");
NodeResult result = response.alias("u").asNodes();

// Access nodes
for (Node node : result.getNodes()) {
    System.out.println("ID: " + node.getId());
    System.out.println("Labels: " + node.getLabels());
    System.out.println("Properties: " + node.getProperties());
}

// Access inferred schemas
for (Map.Entry<String, Schema> entry : result.getSchemas().entrySet()) {
    System.out.println("Schema for " + entry.getKey() + ": " + entry.getValue());
}
```

### Node Class

```java
public class Node {
    String getId();
    List<String> getLabels();
    Map<String, Object> getProperties();
}

public class NodeResult {
    List<Node> getNodes();
    Map<String, Schema> getSchemas();
}
```

### asEdges()

Extract edges from the response via an alias:

```java
Response response = client.gql("MATCH ()-[e:Follows]->() RETURN e");
EdgeResult result = response.alias("e").asEdges();

for (Edge edge : result.getEdges()) {
    System.out.println("ID: " + edge.getId());
    System.out.println("Label: " + edge.getLabel());
    System.out.println("From: " + edge.getFromNodeId());
    System.out.println("To: " + edge.getToNodeId());
    System.out.println("Properties: " + edge.getProperties());
}
```

### Edge Class

```java
public class Edge {
    String getId();
    String getLabel();
    String getFromNodeId();
    String getToNodeId();
    Map<String, Object> getProperties();
}

public class EdgeResult {
    List<Edge> getEdges();
    Map<String, Schema> getSchemas();
}
```

### asPaths()

Extract paths from the response via an alias:

```java
Response response = client.gql("MATCH p = (a)->{1,3}(b) RETURN p LIMIT 10");
List<Path> paths = response.alias("p").asPaths();

for (Path path : paths) {
    System.out.println("Path nodes: " + path.getNodes().size());
    System.out.println("Path edges: " + path.getEdges().size());

    // Print path
    for (int i = 0; i < path.getNodes().size(); i++) {
        System.out.println("  Node: " + path.getNodes().get(i).getId());
        if (i < path.getEdges().size()) {
            System.out.println("    -[" + path.getEdges().get(i).getLabel() + "]->");
        }
    }
}
```

### Path Class

```java
public class Path {
    List<Node> getNodes();
    List<Edge> getEdges();
}
```

## Table Format

### asTable()

Get the response as a generic table:

```java
Response response = client.gql("MATCH (u:User) RETURN u.name AS name, u.age AS age");
Table table = response.get(0).asTable();

System.out.println("Headers: " + table.getHeaders().stream()
    .map(Header::getName).collect(Collectors.toList()));
System.out.println("Rows: " + table.getRows());
```

### Table Class

```java
public class Table {
    String getName();
    List<Header> getHeaders();
    List<List<Object>> getRows();
}

public class Header {
    String getName();
    PropertyType getType();
}
```

## Attribute Extraction

### asAttr()

Extract values from a specific column:

```java
Response response = client.gql("MATCH (u:User) RETURN u.age AS age");
Attr ageAttr = response.alias("age").asAttr();

System.out.println("Column name: " + ageAttr.getName());
System.out.println("Type: " + ageAttr.getType());
System.out.println("Values: " + ageAttr.getValues());

// Calculate statistics
List<Object> ages = ageAttr.getValues();
double avgAge = ages.stream()
    .filter(a -> a instanceof Number)
    .mapToDouble(a -> ((Number) a).doubleValue())
    .average()
    .orElse(0);
System.out.println("Average age: " + avgAge);
```

### Attr Class

```java
public class Attr {
    String getName();
    PropertyType getType();
    List<Object> getValues();
}
```

## Complete Example

```java
import com.gqldb.*;
import java.util.*;

public class ResponseProcessingExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:60061")
            .defaultGraph("socialNetwork")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");

            // Query nodes
            System.out.println("=== Query Nodes ===");
            Response nodeResponse = client.gql("MATCH (u:User) RETURN u LIMIT 5");
            NodeResult nodeResult = nodeResponse.alias("u").asNodes();
            for (Node node : nodeResult.getNodes()) {
                System.out.println("User " + node.getId() + ": " + node.getProperties().get("name"));
            }

            // Query with multiple columns
            System.out.println("\n=== Query Columns ===");
            Response colResponse = client.gql(
                "MATCH (u:User) RETURN u.name AS name, u.age AS age ORDER BY u.age DESC LIMIT 3"
            );
            List<Map<String, Object>> users = colResponse.toMaps();
            System.out.println("Top 3 oldest users: " + users);

            // Query paths
            System.out.println("\n=== Query Paths ===");
            Response pathResponse = client.gql(
                "MATCH p = (a:User)-[:Follows]->{1,2}(b:User) RETURN p LIMIT 3"
            );
            List<Path> paths = pathResponse.alias("p").asPaths();
            for (Path path : paths) {
                String route = path.getNodes().stream()
                    .map(n -> (String) n.getProperties().getOrDefault("name", n.getId()))
                    .collect(Collectors.joining(" -> "));
                System.out.println("Path: " + route);
            }

            // Aggregate query
            System.out.println("\n=== Aggregate Query ===");
            Response countResponse = client.gql("MATCH (n) RETURN count(n)");
            System.out.println("Total nodes: " + countResponse.singleLong());

            // Extract attribute values
            System.out.println("\n=== Attribute Extraction ===");
            Response ageResponse = client.gql("MATCH (u:User) RETURN u.age AS age");
            Attr ages = ageResponse.alias("age").asAttr();
            List<Number> numericAges = ages.getValues().stream()
                .filter(a -> a instanceof Number)
                .map(a -> (Number) a)
                .collect(Collectors.toList());

            if (!numericAges.isEmpty()) {
                System.out.println("Ages: " + numericAges);
                long min = numericAges.stream().mapToLong(Number::longValue).min().orElse(0);
                long max = numericAges.stream().mapToLong(Number::longValue).max().orElse(0);
                System.out.println("Min age: " + min);
                System.out.println("Max age: " + max);
            }

        } catch (GqldbException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```
