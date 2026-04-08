# Data Types

The GQLDB Java driver supports a comprehensive set of data types for storing and querying graph data. This guide covers property types, enums, and type conversions.

## Property Types

The `PropertyType` enum defines all supported data types:

```java
import com.gqldb.types.PropertyType;
```

### Numeric Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `INT32` | 32-bit signed integer | `Integer` |
| `UINT32` | 32-bit unsigned integer | `Long` |
| `INT64` | 64-bit signed integer | `Long` |
| `UINT64` | 64-bit unsigned integer | `Long` |
| `FLOAT` | 32-bit floating point | `Float` |
| `DOUBLE` | 64-bit floating point | `Double` |
| `DECIMAL` | Arbitrary precision decimal | `GqldbDecimal` |

### String Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `STRING` | Variable-length string | `String` |
| `TEXT` | Long text | `String` |

### Boolean and Null

| Type | Description | Java Type |
|------|-------------|-----------|
| `BOOL` | Boolean value | `Boolean` |
| `NULL` | Null value | `null` |
| `UNSET` | Unset/unknown type | `null` |

### Binary

| Type | Description | Java Type |
|------|-------------|-----------|
| `BLOB` | Binary data | `byte[]` |

### Date and Time Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `TIMESTAMP` | Unix timestamp with nanoseconds | `java.time.Instant` |
| `DATETIME` | Date and time (deprecated) | `java.time.Instant` |
| `DATE` | Date only | `java.time.LocalDate` |
| `LOCAL_DATETIME` | Local date and time | `GqldbLocalDateTime` |
| `ZONED_DATETIME` | Date and time with timezone | `GqldbZonedDateTime` |
| `LOCAL_TIME` | Local time of day | `GqldbLocalTime` |
| `ZONED_TIME` | Time with timezone | `GqldbZonedTime` |

### Duration Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `YEAR_TO_MONTH` | Year-month duration | `YearToMonth` |
| `DAY_TO_SECOND` | Day-second duration | `DayToSecond` |

### Geospatial Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `POINT` | 2D geographic point | `Point` |
| `POINT3D` | 3D point | `Point3D` |

### Collection Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `LIST` | Ordered list | `List<?>` |
| `SET` | Unordered unique set | `Set<?>` |
| `MAP` | Key-value map | `Map<String, ?>` |
| `VECTOR` | Numeric vector | `Vector` |

### Graph Types

| Type | Description | Java Type |
|------|-------------|-----------|
| `NODE` | Graph node | `GqldbNode` |
| `EDGE` | Graph edge | `GqldbEdge` |
| `PATH` | Graph path | `GqldbPath` |

## PropertyType Enum

```java
public enum PropertyType {
    UNSET,
    INT32, UINT32, INT64, UINT64,
    FLOAT, DOUBLE,
    STRING, TEXT,
    DATETIME, TIMESTAMP,
    BLOB,
    POINT, POINT3D,
    DECIMAL,
    LIST, SET, MAP,
    NULL, BOOL,
    LOCAL_DATETIME, ZONED_DATETIME,
    DATE, ZONED_TIME, LOCAL_TIME,
    YEAR_TO_MONTH, DAY_TO_SECOND,
    RECORD, VECTOR, TABLE, PATH,
    ERROR, NODE, EDGE
}
```

## Graph Type Enum

```java
public enum GraphType {
    OPEN,      // Schema-less graph
    CLOSED,    // Schema-enforced graph
    ONTOLOGY   // Ontology-enabled graph
}
```

## Health Status Enum

```java
public enum HealthStatus {
    UNKNOWN,
    SERVING,
    NOT_SERVING,
    SERVICE_UNKNOWN
}
```

## Cache Type Enum

```java
public enum CacheType {
    ALL,
    AST,
    PLAN
}
```

## Type Classes

### Node Types

```java
// Data for inserting nodes
public class NodeData {
    public NodeData(List<String> labels, Map<String, Object> properties);
    static NodeData create(String label);
    static NodeData create(String label, Map<String, Object> properties);
    static NodeData create(List<String> labels, Map<String, Object> properties);
    NodeData withProperty(String key, Object value);
    List<String> getLabels();
    Map<String, Object> getProperties();
}

// Node from query results
public class Node {
    String getId();
    List<String> getLabels();
    Map<String, Object> getProperties();
}

// Internal node representation
public class GqldbNode {
    String getId();
    List<String> getLabels();
    Map<String, Object> getProperties();
}
```

### Edge Types

```java
// Data for inserting edges
public class EdgeData {
    public EdgeData(String label, String fromNodeId,
                    String toNodeId, Map<String, Object> properties);
    String getLabel();
    String getFromNodeId();
    String getToNodeId();
    Map<String, Object> getProperties();
}

// Edge from query results
public class Edge {
    String getId();
    String getLabel();
    String getFromNodeId();
    String getToNodeId();
    Map<String, Object> getProperties();
}
```

### Path Type

```java
public class Path {
    List<Node> getNodes();
    List<Edge> getEdges();
}

public class GqldbPath {
    List<GqldbNode> getNodes();
    List<GqldbEdge> getEdges();
}
```

### Geospatial Types

```java
public class Point {
    public Point(double latitude, double longitude);
    double getLatitude();
    double getLongitude();
}

public class Point3D {
    public Point3D(double x, double y, double z);
    double getX();
    double getY();
    double getZ();
}
```

### Duration Types

```java
public class YearToMonth {
    public YearToMonth(int months);
    int getMonths();
}

public class DayToSecond {
    public DayToSecond(long nanos);
    long getNanos();
}
```

### Vector Type

```java
public class Vector {
    public Vector(float[] values);
    float[] getValues();
    int getDimension();
}
```

## TypedValue

The driver uses `TypedValue` internally for type-safe data transfer:

```java
import com.gqldb.types.TypedValue;
import com.gqldb.types.PropertyType;

// Get typed values from a row
Row row = response.first().get();
List<TypedValue> typedValues = row.getTypedValues();

for (TypedValue tv : typedValues) {
    PropertyType type = tv.getType();
    Object javaValue = tv.toJava();
    System.out.println("Type: " + type + ", Value: " + javaValue);
}
```

## Type Conversion Examples

### Working with Dates

```java
import java.time.*;

// Insert with date
client.gql("INSERT (e:Event {" +
    "_id: 'e1', " +
    "name: 'Conference', " +
    "date: DATE('2024-06-15'), " +
    "startTime: DATETIME('2024-06-15T09:00:00Z')" +
    "})");

// Query and convert
Response response = client.gql("MATCH (e:Event) RETURN e.date, e.startTime");
response.first().ifPresent(row -> {
    Object date = row.get(0);      // LocalDate or similar
    Object startTime = row.get(1); // Instant or similar
    System.out.println("Event date: " + date);
    System.out.println("Start time: " + startTime);
});
```

### Working with Points

```java
// Insert with location
client.gql("INSERT (p:Place {" +
    "_id: 'p1', " +
    "name: 'Office', " +
    "location: POINT(37.7749, -122.4194)" +
    "})");

// Query and access point
Response response = client.gql("MATCH (p:Place) RETURN p.location");
response.first().ifPresent(row -> {
    Object location = row.get(0);
    if (location instanceof Point) {
        Point pt = (Point) location;
        System.out.println("Lat: " + pt.getLatitude() + ", Lng: " + pt.getLongitude());
    }
});
```

### Working with Collections

```java
// Insert with list and map
client.gql("INSERT (u:User {" +
    "_id: 'u1', " +
    "name: 'Alice', " +
    "tags: ['developer', 'blogger'], " +
    "metadata: {level: 5, premium: true}" +
    "})");

// Query collections
Response response = client.gql("MATCH (u:User) RETURN u.tags, u.metadata");
response.first().ifPresent(row -> {
    List<?> tags = (List<?>) row.get(0);
    Map<?, ?> metadata = (Map<?, ?>) row.get(1);
    System.out.println("Tags: " + tags);
    System.out.println("Metadata: " + metadata);
});
```

## Complete Example

```java
import com.gqldb.*;
import com.gqldb.types.PropertyType;
import java.util.*;

public class DataTypesExample {
    public static void main(String[] args) {
        GqldbConfig config = GqldbConfig.builder()
            .hosts("localhost:60061")
            .build();

        try (GqldbClient client = new GqldbClient(config)) {
            client.login("admin", "password");
            client.createGraph("typeDemo");
            client.useGraph("typeDemo");

            // Insert data with various types
            client.gql("INSERT (u:User {" +
                "_id: 'u1', " +
                "name: 'Alice', " +
                "age: 30, " +
                "balance: 1234.56, " +
                "active: true, " +
                "joined: DATE('2023-01-15'), " +
                "location: POINT(40.7128, -74.0060), " +
                "tags: ['developer', 'mentor'], " +
                "settings: {theme: 'dark', notifications: true}" +
                "})");

            // Query and check types
            Response response = client.gql(
                "MATCH (u:User {_id: 'u1'}) " +
                "RETURN u.name, u.age, u.balance, u.active, u.joined, " +
                "u.location, u.tags, u.settings"
            );

            response.first().ifPresent(row -> {
                System.out.println("Name (String): " + row.getString(0));
                System.out.println("Age (long): " + row.getLong(1));
                System.out.println("Balance (double): " + row.getDouble(2));
                System.out.println("Active (boolean): " + row.getBoolean(3));
                System.out.println("Joined: " + row.get(4));
                System.out.println("Location: " + row.get(5));
                System.out.println("Tags: " + row.get(6));
                System.out.println("Settings: " + row.get(7));

                // Check property types
                System.out.println("\nProperty types:");
                List<TypedValue> typedValues = row.getTypedValues();
                List<String> columns = response.getColumns();
                for (int i = 0; i < typedValues.size(); i++) {
                    System.out.println("  " + columns.get(i) + ": " +
                        typedValues.get(i).getType());
                }
            });

            client.dropGraph("typeDemo");

        } catch (GqldbException e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
```
